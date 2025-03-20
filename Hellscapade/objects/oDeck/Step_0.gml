if (handSize == array_length(cardsInHand)) exit;
handSize = array_length(cardsInHand);
global.handLeft = 160 - oDeck.handSize * 8;