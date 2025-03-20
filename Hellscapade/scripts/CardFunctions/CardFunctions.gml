global.handLeft = 160;
global.handHeight = 100;

function Deck(_cards, _handSize) {
	var cam_x = camera_get_view_x(view_camera[0]);
	var cam_y = camera_get_view_y(view_camera[0]);
	with instance_create_depth(cam_x, cam_y, -999, oDeck, {maxHandSize: _handSize}) {
		for (var i = 0; i < array_length(_cards); i++) {
			for (var qty = 0; qty < _cards[i][1]; qty++) {
				var _card = Card(_cards[i][0], oDeck.x, oDeck.y);
				addCard(_card, true);
			}
		}
	}
}

function Card(_cardname, _x, _y) {
	return instance_create_depth(_x, _y, oBattle.depth-100, oCard, global.cards[$ _cardname]);
}