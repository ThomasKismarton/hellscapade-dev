#macro HAND_LEFT 160
#macro HAND_HEIGHT 94

global.handLeft = 0;
global.handHeight = 0;

function fillDeck(_deck, _cards, _handSize) {
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

// Card Library
global.cards = {
	attack: {
		name: "Attack",
        description: "{0} attacks!",
        targetRequired : true,
        targetEnemyByDefault: true,
        numTargets: 3,
        targetAll: MODE.NEVER,
        userAnimation: "attack",
        effectSprite: sAttackBonk,
        effectOnTarget: MODE.ALWAYS,
		cardSprite: sCardBasic,
        // The actual function to be performed when the action is taken
        // Keep in mind for playing cards later
		// Mimics, but is different from attack action listed in actionLibrary
        func: function(_user, _targets) {
            var _damage = 5;
            takeDamage(_targets, damageStatusMod(_user, _damage), 0);
        }
	},
	poisonCloud: {
		name: "Poison Cloud",
        description: "{0} spits poison!",
        targetRequired : true,
        targetEnemyByDefault: true,
        numTargets: 1,
        targetAll: MODE.NEVER,
        userAnimation: "cast",
        effectSprite: sAttackFire,
        effectOnTarget: MODE.ALWAYS,
		cardSprite: sCardPoisonCloud,
        func: function(_user, _targets) {
            var _stacks = 5;
            modifyStatus(_targets, "Poison", _stacks);
        }
	},
    boomerang: {
		name: "Boomerang",
        description: "{0} hucks a boomerang!",
        targetRequired : true,
        targetEnemyByDefault: true,
        numTargets: 1,
        targetAll: MODE.NEVER,
        userAnimation: "attack",
        effectSprite: sCardBoomerang,
        effectOnTarget: MODE.ALWAYS,
		cardSprite: sCardBoomerang,
        func: function(_user, _targets) {
            bounceFunc(_targets, 2, takeDamage, [noone, damageStatusMod(_user, 5)]);
        }
	},
    venorang: {
		name: "Venorang",
        description: "{0} hucks a venomous boomerang!",
        targetRequired : true,
        targetEnemyByDefault: true,
        numTargets: 1,
        targetAll: MODE.NEVER,
        userAnimation: "attack",
        effectSprite: sAttackBonk,
        effectOnTarget: MODE.ALWAYS,
		cardSprite: sCardVenorang,
        func: function(_user, _targets) {
            bounceFunc(_targets, 3, modifyStatus, [noone, "Poison", 2]);
        }
	},
    bombshot: {
        name: "Bomb Shot",
        description: "{0} shoots a bomb!",
        targetRequired : true,
        targetEnemyByDefault: true,
        numTargets: 1,
        targetAll: MODE.NEVER,
        userAnimation: "attack",
        effectSprite: sAttackFire,
        effectOnTarget: MODE.ALWAYS,
		cardSprite: sCardBombShot,
        func: function(_user, _targets) {
            splashFunc(_targets, takeDamage, [noone, damageStatusMod(_user, 10)]);
        }
    },
	poisonboom: {
        name: "Poison Boom",
        description: "{0} sprays poison everywhere!",
        targetRequired : true,
        targetEnemyByDefault: true,
        numTargets: 1,
        targetAll: MODE.NEVER,
        userAnimation: "attack",
        effectSprite: sAttackFire,
        effectOnTarget: MODE.ALWAYS,
		cardSprite: sCardPoisonBoom,
        func: function(_user, _targets) {
            splashFunc(_targets, modifyStatus, [noone, "Poison", 4]);
        }
    },
	bomberang: {
        name: "Bomberang",
        description: "{0} is making an ill-advised decision!",
        targetRequired : true,
        targetEnemyByDefault: true,
        numTargets: 1,
        targetAll: MODE.NEVER,
        userAnimation: "attack",
        effectSprite: sAttackFire,
        effectOnTarget: MODE.ALWAYS,
		cardSprite: sCardBomberang,
        func: function(_user, _targets) {
            bounceFunc(_targets, 3, splashFunc, [noone, takeDamage, [noone, damageStatusMod(_user, 2)]]);
        }
    },
	scrapper: {
		jab: {
			name: "Jab",
			description: "{0} jabs!",
			targetRequired : true,
			targetEnemyByDefault: true,
			numTargets: 1,
			targetAll: MODE.NEVER,
			userAnimation: "attack",
			effectSprite: sAttackBonk,
			effectOnTarget: MODE.ALWAYS,
			cardSprite: sCardBasic,
			func: function(_user, _targets) {
				takeDamage(_targets, damageStatusMod(_user, 3), 0);
				modifyStatus(_user, "Combo", 1);
			}
		},
		rightHook: {
			name: "Right Hook",
			description: "{0} goes wide!",
			targetRequired : true,
			targetEnemyByDefault: true,
			numTargets: 1,
			targetAll: MODE.NEVER,
			userAnimation: "attack",
			effectSprite: sAttackBonk,
			effectOnTarget: MODE.ALWAYS,
			cardSprite: sCardBasic,
			func: function(_user, _targets) {
				var _hookDamage = 7 + 2*statusCheck(_user, "Combo");
				takeDamage(_targets, damageStatusMod(_user, _hookDamage), 0);
				modifyStatus(_user, "Combo", -9999);
			}
		},
		guard: {
			name: "Guard",
			description: "{0} goes wide!",
			targetRequired : false,
			targetEnemyByDefault: false,
			numTargets: -1,
			targetAll: MODE.NEVER,
			userAnimation: "attack",
			effectSprite: sAttackBonk,
			effectOnTarget: MODE.ALWAYS,
			cardSprite: sCardBasic,
			func: function(_user) {
				_user.block += 5;
			}
		},
		duck: {
			name: "Duck",
			description: "{0} ducks low!",
			targetRequired : false,
			targetEnemyByDefault: false,
			numTargets: -1,
			targetAll: MODE.NEVER,
			userAnimation: "attack",
			effectSprite: sAttackBonk,
			effectOnTarget: MODE.ALWAYS,
			cardSprite: sCardBasic,
			func: function(_user) {
				modifyStatus(_user, "Grit", 1);
				if (checkStatus(_user, "Combo") > 3) {
					modifyStatus(_user, "Dodge", 1);
				}
			}
		}
	}
}