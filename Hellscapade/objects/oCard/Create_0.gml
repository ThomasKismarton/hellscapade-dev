handPosition = -1;

function playCard() {
    var _pc = self;
    // If we need targeting,
    if (numTargets != -1) {
        with (oBattle) {
            // Activates cursor, which throws us into targeting mode
            with (cursor) {
                active = true;
                playedCard = _pc;
                activeUser = oBattle.unitTurnOrder[turn];
            }
            if (playedCard.targetEnemyByDefault) {
                targetIndex = 0;
                targetSide = enemyUnits;
                activeReticle = enemyUnits[targetIndex];
            } else {
                targetSide = partyUnits;
                activeReticle = activeUser;
                // findSelf returns the index in an array of a specified element
                var _findSelf = function(_element) {
                    return (_element == activeReticle);
                }
                // In this case, returns the index of the user
                targetIndex = array_find_index(oBattle.partyUnits, _findSelf);
            }
        }
    } else {
        beginAction(_user, _pc, -1);
        oDeck.discardCard(handPosition-1, 0);
    }
}