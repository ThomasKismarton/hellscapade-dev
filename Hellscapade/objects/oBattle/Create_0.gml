instance_deactivate_layer("Instances");
instance_activate_layer("Deck");

units = [];
unit = noone;
currentUser = noone;
currentCard = noone;
currentTargets = noone;
unitTurnOrder = [];
unitRenderOrder = [];

turn = 0;
turnCount = 0;
roundCount = 0;
battleWaitTimeFrames = 15;
battleWaitTimeRemaining = 0;

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

var _xpad = 0;
// Make enemies
for (var i = 0; i < array_length(enemies); i++)
{
	_xpad = int64(i/3) * 40;
	enemyUnits[i] = instance_create_depth(x+120+(i*10)+_xpad, y+48+(i*40) - (3*_xpad), depth-10, oBattleUnitEnemy, enemies[i]);
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
	
    if (oDeck.handSize == 0) {
        // Grab current unit
        var _unit = array_pop(unitTurnOrder);
        currentUser = _unit;
        
        // Check if the unit can act
        if(!instance_exists(_unit) || _unit.hp <= 0) {
            battleState = battleStateVictoryCheck;
            exit;
        }
        
        // Select an action to perform        
        if (_unit.object_index == oBattleUnitPC) {
			cursor.activeUser = _unit;
			
			// Draw cards at the start of the turn equal to max hand size
            // Signals 'start of turn'
            if (statusCheck(_unit, "Bastion")) {
                _unit.block += _unit.statuses[$ "Bastion"];
            }

			if (oDeck.handSize == 0) {
				oDeck.drawCards(_unit.maxHandSize);
				for (var c = 0; c < oDeck.handSize; c++) {
					var _card = oDeck.cardsInHand[c];
					var _cardName = _card.name;
				}
			}
			
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
				if (checkAllDead(partyUnits) || checkAllDead(enemyUnits)) {
					battleState = battleStateVictoryCheck;
				} else if (currentUser.object_index == oBattleUnitPC && (oDeck.handSize != 0 || oDeck.beingDrawn != 0)) {
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
        instance_deactivate_layer("Deck");
		instance_destroy(oBattleUnit);
        instance_destroy(oEndTurn);
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