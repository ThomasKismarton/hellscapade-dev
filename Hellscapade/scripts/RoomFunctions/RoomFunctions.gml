global.cam_x = 0;
global.cam_y = 0;

function enemyGen(_roomName, _number) {
	var _info = room_get_info(_roomName, false, false, false, false, false);
	var _x = 0;
	var _y = 0;
	for (var i = 0; i < _number; i++) {
		_x = irandom(_info.width);
		_y = irandom(_info.height);
		room_instance_add(_roomName, _x, _y, oSlime);
	}
}