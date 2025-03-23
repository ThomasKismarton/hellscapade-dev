handPosition = -1;

function playCard(_targets) {
    func(_targets);
    oDeck.discardCard(handPosition-1);
}