function newEncounter(_creator, _enemies, _bg)
{
	instance_create_depth 
	( 
		camera_get_view_x(view_camera[0]),
		camera_get_view_y(view_camera[0]),
		-99,
		oBattle,
		{creator: _creator, enemies: _enemies, battleBackground: _bg}
	);
	global.handLeft = HAND_LEFT + camera_get_view_x(view_camera[0]);
	global.handHeight = HAND_HEIGHT + camera_get_view_y(view_camera[0]);
	show_debug_message(global.handLeft);
	show_debug_message(global.handHeight);
}

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

function battleChangeHp(_units, _amount, _aliveDeadOrEither = 0) {
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
        instance_create_depth(
            _target.x,
            _target.y,
            _target.depth-1,
            oBattleFloatingText,
            {font: fnM5x7, col: _col, text: string(_amt)}
        );
        if (!_failed) {
            _target.hp = clamp(_target.hp + _amt, 0, _target.hpMax);
        }
		_amt = _amount;
    }
}

function bounceStatus(_units, _status, _stacks, _bounces, _mod = 0) {
	_units = is_array(_units) ? _units : [_units]; 
	for (var i = 0; i < array_length(_units), i++) {
		var _target = _units[i];
		// Apply status to the target
		modifyStatus(_target, _status, _stacks);
		// Bounce to the next
		if (_bounces > 0) {
			bounceStatus(getBounceTarget(_target), _status, _stacks + _mod, _bounces-1, _mod);
		}
	}
}

function bounceDamage(_units, _damage, _bounces, _mod = 0) {
	_units = is_array(_units) ? _units : [_units]; 
	for (var i = 0; i < array_length(_units), i++) {
		var _target = _units[i];
		// Damage the target
		battleChangeHp(_target, -_damage);
		// Bounce to the next
		if (_bounces > 0) {
			bounceDamage(getBounceTarget(_target), _damage + _mod, _bounces-1, _mod);
		}
	}
}

// Need to determine if targeting oneself - should not be able to
function getBounceTarget(_target) {
	var _bounceTargets = (_target.obeject_index == oBattleUnitEnemy) ? oBattle.enemyUnits : oBattle.partyUnits;
	// Exclude self & dead targets from valid bounces
	_bounceTargets = array_filter(_units, method({target: _target}, function(_element) {
			return (target != _element && _element.hp > 0);
	}));
	show_debug_message("Filtered list of bounceable targets");
	show_debug_message(_bounceTargets);
	// Return next target
	return _bounceTargets[irandom(array_length(_bounceTargets)-1)];
}

function getAdjacent(_target, _units) {
	var _findSelf = function(_el, _ind) {
		return _target.id == _el.id;
	}
	// Locate self
	var _self_index = array_find_index(_units, _findSelf);
	// Find targets adjacent to self
	return [_units[max(_self_index - 1, 0)], _target, _units[min(_self_index + 1, array_length(_units))]];
}

function splashDamage(_units, _damage) {
	// Convert targets to array if needed
	_units = is_array(_units) ? _units : [_units];
	// Apply splash damage to each target
	for (var i = 0; i < array_length(_units); i++) {
		var _target = _units[i];
		// Determine side to 'splash' on
		var _unitSide = (_unit.object_index == oBattleUnitPC) ? oBattle.partyUnits : oBattle.enemyUnits;
		// Grab adjacent units
		var _hitList = getAdjacent(_unit, _unitSide);
		battleChangeHp(_hitList, -_damage);
	}
}

function splashStatus(_units, _status, _stacks) {
	// Convert targets to array if needed
	_units = is_array(_units) ? _units : [_units];
	// Apply splash damage to each target
	for (var i = 0; i < array_length(_units); i++) {
		var _target = _units[i];
		// Determine side to 'splash' on
		var _unitSide = (_unit.object_index == oBattleUnitPC) ? oBattle.partyUnits : oBattle.enemyUnits;
		// Grab adjacent units
		var _hitList = getAdjacent(_unit, _unitSide);
		modifyStatus(_hitList, _status, _stacks);
	}
}

function modifyStatus(_units, _status, _stacks) {
	// Convert
	_units = is_array(_units) ? _units : [_units];
	for (var _u = 0; _u < array_length(_units); _u++) {
		var _target = _units[_u];
		if !(variable_instance_exists(_target.statuses, _status)) {
			_target.statuses[$ _status] = _stacks;
		} else {
			_target.statuses[$ _status] = max(_target.statuses[$ _status] + _stacks, 0);
		}
	}
}

function poisonDamage(_units) {
	_units = is_array(_units) ? _units : [_units];
	for (var _u = 0; _u < array_length(_units); _u++) {
		var _target = _units[_u];
		if statusCheck(_target, "Poison") {
			battleChangeHp(_target, -_target.statuses[$ "Poison"]);
			modifyStatus(_target, "Poison", -1);
		}
	}
}

function statusCheck(_unit, _status) {
	if (variable_instance_exists(_unit.statuses, _status)) {
		return _unit.statuses[$ _status > 0];
	}
	return false;
}

function damageStatusMod(_user, _damage) {
	if (statusCheck(_user, "Might")) {
		_damage += _user.statuses[$ "Might"];
	}
	if (statusCheck(_user, "Empowered")) {
		_damage += _user.statuses[$ "Empowered"];
		modifyStatus(_unit, "Empowered", -9999);
	}
	if (statusCheck(_user, "Weakened")) {
		_damage -= _user.statuses[$ "Weakened"];
		modifyStatus(_unit, "Weakened", -9999);
	}
	if (statusCheck(_user, "Intimidated")) {
		_damage = ceil(_damage * 0.66);
		modifyStatus(_unit, "Intimidated", -1);
	}
	if (statusCheck(_user, "Emboldened")) {
		_damage = ceil(_damage * 1.5);
		modifyStatus(_unit, "Emboldened", -1);
	}
	return _damage;
}

// Stump of a function for taking block into account
function damageBlockCheck(_target, _damage) {};

function addSpeed(_units, _turnOrder) {
	for (var _k = 0; _k < array_length(_units); _k++) {
		with (_units[_k]) {
			// var = condition ? val_if_true : val_if_false
			spdBar = (hp > 0) ? min(spdMax, spdBar + spd) : 0
			if (spdBar >= spdMax) {
				array_push(_turnOrder, self);
				spdBar = 0;
			}
		}
    }
}

function checkAllDead(_units) {
    for (var _current = 0; _current < array_length(_units); _current++) {
        if (_units[_current].hp > 0) {
            return false;
        }
    }
	for (var _u = 0; _u < array_length(_units); _u++) {
		instance_destroy(_units[_u]);
	}
    return true;
}