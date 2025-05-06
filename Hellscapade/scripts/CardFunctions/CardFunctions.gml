#macro HAND_LEFT 160
#macro HAND_HEIGHT 94

global.handLeft = 0;
global.handHeight = 0;

function fillDeck(_deck, _cards, _handSize) {
	var cam_x = camera_get_view_x(view_camera[0]);
	var cam_y = camera_get_view_y(view_camera[0]);
    _deck.maxHandSize = _handSize;
    with _deck {
		for (var i = 0; i < array_length(_cards); i++) {
			for (var qty = 0; qty < _cards[i][1]; qty++) {
				var _card = Card(_cards[i][0], _deck.x, _deck.y);
				addCard(_card, true);
			}
		}
	}
}

function Card(_cardname, _x, _y) {
	return instance_create_layer(_x, _y, "Deck", oCard, global.cards[$ _cardname]);
}