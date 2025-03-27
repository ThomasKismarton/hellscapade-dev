handPosition = -1;

function playCard() {
    var _pc = self;
    // If we need targeting,
    if (numTargets != -1) {
        // Activates cursor, which throws us into targeting mode
        with (oBattle.cursor) {
            active = true;
			numTargets = _pc.numTargets;
            playedCard = _pc;
            activeUser = oBattle.unitTurnOrder[oBattle.turn];
	        if (playedCard.targetEnemyByDefault) {
	            targetIndex = 0;
	            targetSide = oBattle.enemyUnits;
	            activeReticle = oBattle.enemyUnits[targetIndex];
	        } else {
	            targetSide = oBattle.partyUnits;
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