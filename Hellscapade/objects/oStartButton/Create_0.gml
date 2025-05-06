image_index = 0;
image_speed = 0;

// oDeck should not be created in oBattle, needs to persist beyond combat
Deck(global.playerData.startDeck, global.playerData.maxHandSize);
oDeck.initDeck();