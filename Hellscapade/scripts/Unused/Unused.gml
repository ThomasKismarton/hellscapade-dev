function bounceStatus(_units, _status, _stacks, _bounces, _mod = 0) {
	_units = is_array(_units) ? _units : [_units]; 
	for (var i = 0; i < array_length(_units); i++) {
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
	for (var i = 0; i < array_length(_units); i++) {
		var _target = _units[i];
		// Damage the target
		battleChangeHp(_target, -_damage);
		// Bounce to the next
		if (_bounces > 0) {
			bounceDamage(getBounceTarget(_target), _damage + _mod, _bounces-1, _mod);
		}
	}
}

function splashDamage(_units, _damage) {
	// Convert targets to array if needed
	_units = is_array(_units) ? _units : [_units];
	// Apply splash damage to each target
	for (var i = 0; i < array_length(_units); i++) {
		var _unit = _units[i];
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
		var _unit = _units[i];
		// Determine side to 'splash' on
		var _unitSide = (_unit.object_index == oBattleUnitPC) ? oBattle.partyUnits : oBattle.enemyUnits;
		// Grab adjacent units
		var _hitList = getAdjacent(_unit, _unitSide);
		modifyStatus(_hitList, _status, _stacks);
	}
}