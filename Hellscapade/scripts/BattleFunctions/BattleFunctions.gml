// Creates a new battle, sets camera position
function newEncounter(_creator, _enemies, _bg)
{
	global.battle_width = 320;
	global.battle_height = 180;
    global.cam_x = camera_get_view_x(view_camera[0]);
    global.cam_y = camera_get_view_y(view_camera[0]);
	instance_create_depth 
	( 
		global.cam_x,
		global.cam_y,
		-99,
		oBattle,
		{creator: _creator, enemies: _enemies, battleBackground: _bg}
	);
	oAudioMgr.switchBgm("Battle");
	global.handLeft = HAND_LEFT + global.cam_x;
	global.handHeight = HAND_HEIGHT + camera_get_view_y(view_camera[0]);
    if (instance_exists(oEndTurn)) {
        oEndTurn.x = global.cam_x + camera_get_view_width(view_camera[0]) - 64;
        oEndTurn.y = global.cam_y + camera_get_view_height(view_camera[0]) - 20;
    } else {
        instance_create_layer (
            global.cam_x + camera_get_view_width(view_camera[0]) - 64,
            global.cam_y + camera_get_view_height(view_camera[0]) - 20,
            "Deck",
            oEndTurn
        );
    }
}

// Finds the lowest hp unit out of a set
function lowestHp(_units) {
    var _lowest = 99999;
    var _ret = -1;
    for (var k = 0; k < array_length(_units); k++) {
        if (_units[k].hp < _lowest) {
            _lowest = _units[k].hp;
            _ret = _units[k].id;
        }
    }
    return _ret;
}

// Damages or heals a unit
// Can be specified to fail on dead units
function battleChangeHp(_units, _amount, _aliveDeadOrEither = 0) {
	// Convert single-target to an array as needed.
    _units = is_array(_units) ? _units : [_units];
	var _amt = _amount;
	for (var k = 0; k < array_length(_units); k++) {
        _target = _units[k];
        // 0 = Alive, 1 = Dead, 2 = Either
        var _failed = false;
        if (_aliveDeadOrEither == 0) && _target.hp <= 0 _failed = true;
        if (_aliveDeadOrEither == 1) && _target.hp > 0 _failed = true;
            
        var _col = c_white;
        if (_amt > 0) _col = c_lime;
        if (_failed) {
            _col = c_white;
            _amt = "failed!";
        }
		// Creates floating numbers for animation
        instance_create_depth(
            _target.x,
            _target.y,
            _target.depth-1,
            oBattleFloatingText,
            {font: fnM5x7, col: _col, text: string(_amt)}
        );
		// Changes the hp.
        if (!_failed) {
            _target.hp = clamp(_target.hp + _amt, 0, _target.hpMax);
        }
		_amt = _amount;
    }
}

// Bounces a function across a side in battle several times
function bounceFunc(_units, _bounces, _func, _params) {
	if (_units != noone) {
		_units = is_array(_units) ? _units : [_units]; 
		for (var i = 0; i < array_length(_units); i++) {
			var _target = _units[i];
			_params[0] = _target;
			method_call(_func, _params);
			// Bounce to the next
			if (_bounces > 0) {
				bounceFunc(getBounceTarget(_target), _bounces-1, _func, _params);
				bounceFunc(getBounceTarget(_target), _bounces-1, _func, _params);
			}
		}
	}
}

// Applies a function to all adjacent targets + primary target
function splashFunc(_units, _func, _params) {
	// Convert targets to array if needed
	_units = is_array(_units) ? _units : [_units];
	// Apply splash damage to each target
	for (var i = 0; i < array_length(_units); i++) {
		var _unit = _units[i];
		// Determine side to 'splash' on
		var _unitSide = (_unit.object_index == oBattleUnitPC) ? oBattle.partyUnits : oBattle.enemyUnits;
		// Grab adjacent units
		var _hitList = getAdjacent(_unit, _unitSide);
		_params[0] = _hitList
		method_call(_func, _params);
	}
}

// Modifies a status by a specified amount
function modifyStatus(_units, _status, _stacks) {
	_units = is_array(_units) ? _units : [_units];
	for (var _u = 0; _u < array_length(_units); _u++) {
		var _target = _units[_u];
		// Creates the status if not currently present
		if !(variable_instance_exists(_target.statuses, _status)) {
			_target.statuses[$ _status] = max(_stacks, 0);
		} else {
			_target.statuses[$ _status] = max(_target.statuses[$ _status] + _stacks, 0);
		}
	}
}

// Damages a unit equal to their poison, then decrements
function poisonDamage(_units) {
	_units = is_array(_units) ? _units : [_units];
	for (var _u = 0; _u < array_length(_units); _u++) {
		var _target = _units[_u];
		if statusCheck(_target, "Poison") {
			takeDamage(_target, _target.statuses[$ "Poison"], 1);
			modifyStatus(_target, "Poison", -1);
		}
	}
}

// Grabs a random unit from a side in the battle
// Cannot target self twice in a row
function getBounceTarget(_target) {
	// Determine if we're bouncing between enemies or allies
	var _bounceTargets = (_target.object_index == oBattleUnitEnemy) ? oBattle.enemyUnits : oBattle.partyUnits;
	// Exclude self & dead targets from valid bounces
	_bounceTargets = array_filter(_bounceTargets, method({target: _target}, function(_element) {
			return (target != _element && _element.hp > 0);
	}));
	// Return next target
	if (array_length(_bounceTargets) == 0) {
		return noone;
	}
	return _bounceTargets[irandom(array_length(_bounceTargets)-1)];
}

// Grabs the adjacent units to a battle entity
// Save for reworking later
function getAdjacent(_target, _units) {
	// Define predicate function for finding self
	var _findSelf = method({target: _target}, function(_el, _ind) {
		return target == _el;
	});
    
	// Locate index of self
	var _self_index = array_find_index(_units, _findSelf);
    var _self_row = _self_index % 3;
    var _potential_hits = [];
    
    if (_self_row == 0) { // Top Row
        array_push(_potential_hits, _target, _units[min(_self_index + 1, array_length(_units) - 1)]); // Target and next unit
    } else if (_self_row == 1) { // Middle row
        array_push(_potential_hits, _units[max(_self_index - 1, 0)], _target, _units[min(_self_index + 1, array_length(_units) - 1)]); // Target, Up & Down
    } else { // Bottom row
        array_push(_potential_hits, _units[max(_self_index - 1, 0)], _target); // Target and next unit up
    }
    if (_self_index - 3 >= 0) {
        array_push(_potential_hits, _units[_self_index-3]);
    }
    if (_self_index + 3 <= array_length(_units) - 1) {
        array_push(_potential_hits, _units[_self_index+3])
    }
	return array_unique(_potential_hits);
}

// Returns num stacks of specified status, if greater than 0
// Else returns 0
function statusCheck(_unit, _status) {
	if (variable_instance_exists(_unit.statuses, _status) && _unit.statuses[$ _status] > 0) {
		return _unit.statuses[$ _status];
	}
	return 0;
}

function damageStatusMod(_user, _damage) {
	// Boost damage by flat amount (can be negative)
	_damage += statusCheck(_user, "Might");
	
	// Reduce damage by flat amount (one time)
	_damage -= statusCheck(_user, "Weakened");
	modifyStatus(_user, "Weakened", -9999);
	
	// Boost damage by flat amount (one time)
	_damage += statusCheck(_user, "Empowered");
	modifyStatus(_user, "Empowered", -9999);

	// Reduce damage if intimidated
	if (statusCheck(_user, "Intimidated") > 0) {
		_damage = ceil(_damage * 0.66);
		modifyStatus(_user, "Intimidated", -1);
	}
	
	// Boost damage if emboldened
	if (statusCheck(_user, "Emboldened") > 0) {
		_damage = ceil(_damage * 1.5);
		modifyStatus(_user, "Emboldened", -1);
	}
	
	// Return modified damage
	return _damage;
}

// Function that reduces damage according to block
function takeDamage(_units, _damage, _piercing, _aDoE = 0) {
    var _modDamage = _damage;
	_units = is_array(_units) ? _units : [_units];
	for (var i = 0; i < array_length(_units); i++) {
		var _unit = _units[i];
		if (!_piercing) {
			var _newblock = max(_unit.block - _damage, 0);
			_modDamage = max(_damage - _unit.block, 0);
			_unit.block = _newblock;
		}
		battleChangeHp(_unit, -_modDamage, _aDoE);
	}
};

// Determines who acts next
// Adds speed to bars based on entity stats
function addSpeed(_units, _turnOrder) {
	// For each unit
	for (var _k = 0; _k < array_length(_units); _k++) {
		with (_units[_k]) {
			// var = condition ? val_if_true : val_if_false
			if (hp > 0) {
				spd = (statusCheck(self, "Hastened") > 0) ? spd + 0.25 : spd;
				spd = (statusCheck(self, "Hindered") > 0) ? spd - 0.25 : spd;
				spdBar = min(spdMax, spdBar + spd)
			}
			// If speed has reached threshold, take turn
			if (spdBar >= spdMax) {
				array_push(_turnOrder, self);
				modifyStatus([self], "Hindered", -1);
				modifyStatus([self], "Hastened", -1);
				spdBar = 0;
			}
		}
    }
}

function checkAllDead(_units) {
	// Checks if all units on one side of the battle are dead
    for (var _current = 0; _current < array_length(_units); _current++) {
        if (_units[_current].hp > 0) {
            return false;
        }
    }
    return true;
}