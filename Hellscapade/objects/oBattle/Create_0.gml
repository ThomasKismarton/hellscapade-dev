instance_deactivate_all(true);

units = [];
turn = 0;
unitTurnOrder = [];
unitRenderOrder = [];

cursor = {
    activeUser: noone,
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
currentUser = noone;
currentAction = -1;
currentTargets = noone;

Deck(global.playerData.startDeck, global.playerData.maxHandSize);

// Make enemies
for (var i = 0; i < array_length(enemies); i++)
{
	enemyUnits[i] = instance_create_depth(x+250+(i*10), y+68+(i*20), depth-10, oBattleUnitEnemy, enemies[i]);
	array_push(units, enemyUnits[i]);
}

// Make party
for (var i = 0; i < array_length(global.party); i++)
{
    // Magic numbers here used for rendering in proper locations
	partyUnits[i] = instance_create_depth(x+70-(i*10), y+68+(i*15), depth-10, oBattleUnitPC, global.party[i]);
	array_push(units, partyUnits[i]);
}

// Shuffle Turn Order
unitTurnOrder = array_shuffle(units);

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
	
    if (!instance_exists(oMenu)) {
        // Grab current unit
        var _unit = unitTurnOrder[turn];
        
        // Check if the unit can act
        if(!instance_exists(_unit) || _unit.hp <= 0) {
            battleState = battleStateVictoryCheck;
            exit;
        }
		
		// Right now, populating an array called hand in GameData structs
		// Instead, want to create a new deck object when entering battle
		// oDeck can manage hand-based functions
		// oCard has actual card data & functionality
        
        // Select an action to perform        
        if (_unit.object_index == oBattleUnitPC) {
			
			// Draw cards at the start of the turn equal to max hand size.
			oDeck.initDeck();
			oDeck.drawCards(_unit.maxHandSize);
			
			for (var c = 0; c < array_length(oDeck.cardsInHand); c++) {
				var _card = oDeck.cardsInHand[c];
				var _cardName = _card.name;
			}
			
			show_debug_message(oDeck.cardsInHand);
			
            var _menuOptions = [];
            var _subMenus = {};
            var _actionList = _unit.actions;
            
            for (var i = 0; i < array_length(_actionList); i++) {
                var _action = _actionList[i];
                var _available = true;
                var _nameAndCount = _action.name;
                
                // Push the action directly into the menu if it is not contained within a submenu
                if (_action.subMenu == -1) {
                    array_push(_menuOptions, {name: _nameAndCount, func: MenuSelectAction, args: [_unit, _action], avail: _available});
                } else {
                    if (is_undefined(_subMenus[$ _action.subMenu])) {
                        variable_struct_set(_subMenus, _action.subMenu, [{name: _nameAndCount, func: MenuSelectAction, args: [_unit, _action], avail: _available}]);
                    } else {
                        array_push(_subMenus[$ _action.subMenu], [{name: _nameAndCount, func: MenuSelectAction, args: [_unit, _action], avail: _available}]);
                    }
                }
            }
            
            var _subMenusArray = variable_struct_get_names(_subMenus);
            for (var i = 0; i < array_length(_subMenusArray); i++) {
                // Add an option to go back a level
                array_push(_subMenus[$ _subMenusArray[i]], {name: "Back", func: MenuGoBack, args: -1, avail: true});
                
                // Add menu options for all other choices
                array_push(_menuOptions, {name:_subMenusArray[i], func: SubMenu, args: [_subMenus[$ _subMenusArray[i]]], avail: true});
            }
            
			// Create the instance of the Menu object, after populating menuOptions with all relevant data
			// Luckily, cards are a fair bit simpler than menus
            Menu(x+10, y+10, _menuOptions, , 74, 60);
			
        } else { 
            // Signal to trigger enemy AI code when they take their turn.
            // Calling AIscript returns an array of [action, targets]
            var _enemyAction = _unit.AIscript();
            if (_enemyAction != -1) beginAction(_unit.id, _enemyAction[0], _enemyAction[1]);
        }
    }
}

function beginAction(_user, _action, _targets) {
    currentUser = _user;
    currentAction = _action;
    currentTargets = _targets;
    
    // Converts current targets into an array for later iterability.
    if(!is_array(currentTargets)) currentTargets = [currentTargets];
        
    // Sets the turn delay timer via battleWaitTimeRemaining, to be decremented later.
    battleWaitTimeRemaining = battleWaitTimeFrames;
    
    with(_user) {
        acting = true;
        // Play user animation for the specified action
        if (!is_undefined(_action[$ "userAnimation"])) && (!is_undefined(_user.sprites[$ _action.userAnimation])) {
            sprite_index = sprites[$ _action.userAnimation];
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
            if (variable_struct_exists(currentAction, "effectSprite")) {
                // Check if single/multi-target or screen-wide effect
                if (currentAction.effectOnTarget == MODE.ALWAYS) || ((currentAction.effectOnTarget == MODE.VARIES) && (array_length(currentTargets) <= 1)) {
                    for (var i = 0; i < array_length(currentTargets); i++) {
                        // Create an instance of an effect on each valid target
                        entity = currentTargets[i];
                        instance_create_depth(entity.x, entity.y, entity.depth-1, oBattleEffect, {sprite_index: currentAction.effectSprite});
                    }
                } else {
                    // Creating a screen-wide effect
                    var _effectSprite = currentAction._effectSprite;
                    if (variable_instance_exists(currentAction, "effectSpriteNoTarget")) _effectSprite = currentAction.effectSpriteNoTarget;
                    instance_create_depth(x, y, depth-100, oBattleEffect, {sprite_index: _effectSprite});
                }
            }
            // Actually perform the mechanics of the action on the targets
            currentAction.func(currentUser, currentTargets)
        }
    } else {
        if (!instance_exists(oBattleEffect)) {
            battleWaitTimeRemaining--;
            if (battleWaitTimeRemaining == 0) {
                battleState = battleStateVictoryCheck;
            }
        }
    }
}

function battleStateEndTurn() {
    // Add functions for taking damage / reducing effects
}

function battleStateVictoryCheck () {
    // Check to see if all party members are dead
    var _partyLoss = checkAllDead(partyUnits);
    var _partyWin = checkAllDead(enemyUnits);

	// Deactivate the battle, activate all else
	// Currently destroying enemy on battle start
    if (_partyLoss || _partyWin) {
        instance_activate_all();
        instance_deactivate_object(oDeck);
        instance_deactivate_object(oCard);
        instance_deactivate_object(oBattle);
    }
    battleState = battleStateTurnProgression;
}

function battleStateTurnProgression () {
    turnCount++;
    turn++;
    
    if (turn > array_length(unitTurnOrder) - 1) {
        turn = 0;
        roundCount++;
    }
    
    battleState = battleStateSelectAction;
}

battleState = battleStateSelectAction;