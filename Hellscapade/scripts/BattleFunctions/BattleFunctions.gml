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

function battleChangeHp(_targets, _amount, _aliveDeadOrEither = 0) {
    var _amt = _amount;
	for (var k = 0; k < array_length(_targets); k++) {
        _target = _targets[k];
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

function bounceStatus(_target, _targets, _status, _stacks, _bounces, _mod = 0) {
	modifyStatus([_target], _status, _stacks);
	if (_bounces > 0) {
		var _newTarget = getBounceTarget(_target, _targets);
	}
	bounceStatus(_newTarget, _targets, _status, _stacks + _mod, _bounces-1, _mod);
}

function bounceDamage(_target, _targets, _damage, _bounces, _mod) {
	battleChangeHp([_target], -_damage);
	if (_bounces > 0) {
		var _newTarget = getBounceTarget(_target, _targets);
	}
	bounceDamage(_newTarget, _targets, _damage + _mod, _bounces-1, _mod)
}

function getBounceTarget(_target, _targets) {
	var _bounceTargets = array_filter(_targets, function(_element, _index) {
			return _element.id != _target.id;
	});
	return irandom(array_length(bounceTargets)-1);
}

function getAdjacent(_target, _targets) {
	var _findSelf = function(_el, _ind) {
		return _target.id == _el.id;
	}
	var _self_index = array_find_index(_targets, _findSelf);
	return [_targets[_self_index - 1], _target, _targets[_self_index + 1]];
}

function modifyStatus(_units, _status, _stacks) {
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
		if variable_instance_exists(_target.statuses, "Poison") {
			if (_target.statuses[$ "Poison"] > 0) {
				battleChangeHp([_target], -_target.statuses[$ "Poison"]);
				modifyStatus(_target, "Poison", -1);
			}
		}
	}
}

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