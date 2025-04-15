instance_deactivate_all(true);

units = [];
turn = 0;
unitTurnOrder = [];
unitRenderOrder = [];

cursor = {
    activeUser: noone,
    playedCard: noone,
    activeTargets: [],
    activeReticle: noone,
    numTargets: 0,
    activeAction: -1,
    targetSide: -1,
    targetIndex: 0,
    targetAll: false,
    comfirmDelay: 0,
    active: false
}
turnCount = 0;
roundCount = 0;
battleWaitTimeFrames = 30;
battleWaitTimeRemaining = 0;
unit = noone;
currentUser = noone;
currentCard = noone;
currentTargets = noone;

// Tester code for an oDeck object
// oDeck should not be created in oBattle, needs to persist beyond combat
Deck(global.playerData.startDeck, global.playerData.maxHandSize);
oDeck.initDeck();

// Make enemies
for (var i = 0; i < array_length(enemies); i++)
{
	enemyUnits[i] = instance_create_depth(x+250+(i*10), y+48+(i*40), depth-10, oBattleUnitEnemy, enemies[i]);
	array_push(units, enemyUnits[i]);
}

// Make party
for (var i = 0; i < array_length(global.party); i++)
{
    // Magic numbers here used for rendering in proper locations
	partyUnits[i] = instance_create_depth(x+70-(i*10), y+48+(i*40), depth-10, oBattleUnitPC, global.party[i]);
	array_push(units, partyUnits[i]);
}

// Get render order
// Generally, higher y value = futher down the screen, and thus drawn 1st.
RefreshRenderOrder = function() {
    unitRenderOrder = [];
    array_copy(unitRenderOrder , 0, units, 0, array_length(units));
    array_sort(unitRenderOrder, function(_1, _2) {
        return _1.y = _2.y;
    });
}
RefreshRenderOrder();

function battleStateSelectAction () {
    // At the start of selecting an action, draw the menus
	// To be replaced by drawing cards
	
    if (!array_length(oDeck.cardsInHand) > 0) {
        // Grab current unit
        var _unit = array_pop(unitTurnOrder);
        
        // Check if the unit can act
        if(!instance_exists(_unit) || _unit.hp <= 0) {
            battleState = battleStateVictoryCheck;
            exit;
        }
        
        // Select an action to perform        
        if (_unit.object_index == oBattleUnitPC) {
			cursor.activeUser = _unit;
			
			// Draw cards at the start of the turn equal to max hand size
			if (oDeck.handSize == 0) {
				oDeck.drawCards(_unit.maxHandSize);
				for (var c = 0; c < oDeck.handSize; c++) {
					var _card = oDeck.cardsInHand[c];
					var _cardName = _card.name;
				}
			}
			show_debug_message(oDeck.cardsInHand);
			
        } else { 
            // Signal to trigger enemy AI code when they take their turn.
            // Calling AIscript returns an array of [action, targets]
            var _enemyAction = _unit.AIscript();
            if (_enemyAction != -1) beginAction(_unit.id, _enemyAction[0], _enemyAction[1]);
        }
    }
}

// Card objects are essentially the same as action structs
// Just have an object reference, but they contain all the same data
// Even referenced the same way (. operator)
function beginAction(_user, _card, _targets) {
	show_debug_message(_targets);
    currentUser = _user;
    currentCard = _card;
    currentTargets = _targets;
    
    // Converts current targets into an array for later iterability.
    if(!is_array(currentTargets)) currentTargets = [currentTargets];
        
    // Sets the turn delay timer via battleWaitTimeRemaining, to be decremented later.
    battleWaitTimeRemaining = battleWaitTimeFrames;
    
    with(_user) {
        acting = true;
        // Play user animation for the specified action
        if (variable_instance_exists(_card, "userAnimation") && (!is_undefined(_user.sprites[$ _card.userAnimation]))) {
            sprite_index = sprites[$ _card.userAnimation];
            image_index = 0;
        }
    }
    battleState = battleStatePerformAction;
}

function battleStatePerformAction () {
    // Check to see if animation is still playing
    if (currentUser.acting) {
        // Compare current animation frame to total # of frames in animation
        if (currentUser.image_index >= currentUser.image_number - 1) {
            // Reset animation frame to 0 and set sprite to idle
            with (currentUser) {
                sprite_index = sprites.idle;
                image_index = 0;
                acting = false;
            }
            
            // If there's an effect sprite for the current action,
            if (variable_instance_exists(currentCard, "effectSprite")) {
                // Check if single/multi-target or screen-wide effect
                if (currentCard.effectOnTarget == MODE.ALWAYS) || ((currentCard.effectOnTarget == MODE.VARIES) && (array_length(currentTargets) <= 1)) {
                    for (var i = 0; i < array_length(currentTargets); i++) {
                        // Create an instance of an effect on each valid target
                        entity = currentTargets[i];
                        instance_create_depth(entity.x, entity.y, entity.depth-1, oBattleEffect, {sprite_index: currentCard.effectSprite});
                    }
                } else {
                    // Creating a screen-wide effect
                    var _effectSprite = currentCard._effectSprite;
                    if (variable_instance_exists(currentCard, "effectSpriteNoTarget")) _effectSprite = currentCard.effectSpriteNoTarget;
                    instance_create_depth(x, y, depth-100, oBattleEffect, {sprite_index: _effectSprite});
                }
            }
            // Actually perform the mechanics of the action on the targets
            currentCard.func(currentUser, currentTargets);
        }
    } else {
        if (!instance_exists(oBattleEffect)) {
            battleWaitTimeRemaining--;
            if (battleWaitTimeRemaining == 0) {
                if (currentUser.object_id == oBattleUnitPC && oDeck.handSize != 0) {
                    battleState = battleStateSelectAction;
                } else {
                    battleState = battleStateEndTurn;
                }
            }
        }
    }
}

function battleStateEndTurn() {
    // Add functions for taking damage / reducing effects
	poisonDamage(currentUser);
	battleState = battleStateVictoryCheck;
}

function battleStateVictoryCheck () {
    // Check to see if all party members are dead
    var _partyLoss = checkAllDead(partyUnits);
    var _partyWin = checkAllDead(enemyUnits);

	// Deactivate the battle, activate all else
	// Currently destroying enemy on battle start
    if (_partyLoss || _partyWin) {
        instance_activate_all();
        oDeck.emptyHand(0);
        instance_deactivate_object(oDeck);
        instance_deactivate_object(oCard);
        instance_destroy(oBattle);
    }
    battleState = battleStateTurnProgression;
}

function battleStateTurnProgression () {
    if (array_length(unitTurnOrder) > 0) {
		battleState = battleStateSelectAction;
	} else {
		addSpeed(units, unitTurnOrder);
	}
}

battleState = battleStateSelectAction;