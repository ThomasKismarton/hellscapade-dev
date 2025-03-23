// Variables for managing the deck
fullDeck = [];
toDraw = [];
discard = []
expended = [];
fullDecksize = array_length(fullDeck);

// Variables for managing the hand
cardsInHand = [];
handSize = 0;

function drawCards(_num) {
	for (var i = 0; i < _num; i++) {
		// Check for max hand size
		if (handSize < maxHandSize) {
			// Check if draw pile is empty
			if (array_length(toDraw) > 0) {
				// Draw a card
				var _card = array_pop(toDraw);
				array_push(cardsInHand, _card);
				_card.handPosition = array_length(cardsInHand);
                handSize++;
			} else {
				// Check if cards are in discard pile
				if (array_length(discard) > 0) {
					// Refill draw pile with discards
					for (var k = 0; k < array_length(discard); k++) {
						array_push(toDraw, array_pop(discard));
					}
					// Shuffle draw pile
					toDraw = array_shuffle(toDraw);
                    show_debug_message("Shuffling");
                    drawCards(1);
				} else {
					show_debug_message("No cards to draw!");
				}
			}
		} else {
			show_debug_message("Max hand size reached!");
		}
	}			
}

function discardCard(_pos) {
    // Shift handPos of all cards to the right of the card
    for (var p = _pos; p < array_length(cardsInHand); p++) {
        cardsInHand[p].handPosition--;
    }
    // Reset card HandPos, delete from hand, add to discarded.
    var _card = cardsInHand[_pos];
    _card.handPosition = -1;
    array_push(discard, _card);
    array_delete(cardsInHand, _pos, 1);
}

function addCard(_card, _permanent) {
	if (_permanent) {
		array_push(fullDeck, _card);
	} else {
		array_push(toDraw, _card);
		toDraw = array_shuffle(toDraw);
	}
}

function initDeck() {
	toDraw = array_shuffle(fullDeck);
}