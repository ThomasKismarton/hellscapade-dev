function NewEncounter(_creator, _enemies, _bg)
{
	instance_create_depth 
	( 
		camera_get_view_x(view_camera[0]),
		camera_get_view_y(view_camera[0]),
		-99,
		oBattle,
		{creator: _creator, enemies: _enemies, battleBackground: _bg}
	);
}

function BattleChangeHp(_targets, _amount, _aliveDeadOrEither = 0) {
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