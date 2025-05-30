// Action Library
global.actionLibrary = {
    attack: {
        name: "Attack",
        description: "{0} attacks!",
        subMenu: -1,
        targetRequired : true,
        targetEnemyByDefault: true,
        numTargets: 3,
        targetAll: MODE.NEVER,
        userAnimation: "attack",
        effectSprite: sAttackBonk,
        effectOnTarget: MODE.ALWAYS,
        // The actual function to be performed when the action is taken
        // Keep in mind for playing cards later
        func: function(_user, _targets) {
            var _damage = ceil(_user.strength + random_range(_user.strength * -0.25, _user.strength * 0.25));
            takeDamage(_targets, _damage, 0);
        }
    }
}

//Party data
global.party = 
[
	{
		name: "Lulu",
		hp: 89,
		hpMax: 89,
		mp: 10,
		mpMax: 15,
        block: 0,
        strength: 20,
		maxHandSize: 11,
        baseHandSize: 11,
		spd: 1.2,
		spdMax: 100,
		spdBar: 0,
		sprites : { idle: sLuluIdle, attack: sLuluAttack, defend: sLuluDefend, down: sLuluDown}
	}
	,
	{
		name: "Questy",
		hp: 18,
		hpMax: 44,
		mp: 20,
		mpMax: 30,
        block: 0,
		strength: 4,
		maxHandSize: 12,
        baseHandSize: 12,
		spd: 1.2,
		spdMax: 100,
		spdBar: 0,
		sprites : { idle: sQuestyIdle, attack: sQuestyCast, cast: sQuestyCast, down: sQuestyDown}
	}
]

global.playerData = {
	name: "Scrapper",
	hp: 10,
	hpMax: 10,
	mp: 20,
	mpMax: 30,
	block: 0,
	hand: [],
	handSize: 1,
	maxHandSize: 4,
    baseHandSize: 4,
	strength: 6,
	spd: 1,
	spdMax: 100,
	spdBar: 0,
	startDeck: [["attack", 1], ["poisonCloud", 0], ["boomerang", 0], ["venorang", 0], ["bombshot", 1], ["poisonboom", 1], ["bomberang", 1]]
}

//Enemy Data
global.enemies =
{
	slimeG: 
	{
		name: "Slime",
		hp: 30,
		hpMax: 30,
		mp: 0,
		mpMax: 0,
	    block: 5,
		strength: 5,
		sprites: {idle: sSlime, attack: sSlimeAttack},
        actions: [global.actionLibrary.attack],
		xpValue : 15,
		spd: 1.0,
		spdMax: 100,
		spdBar: 0,
		AIscript : function()
		{
			// Attack random party member
            var _action = actions[0];
            var _possibleTargets = array_filter(oBattle.partyUnits, function(_unit, _index) {
               return (_unit.hp > 0); 
            });
            var _target_id = irandom(array_length(_possibleTargets) - 1);
            var _target = _possibleTargets[_target_id];
            return [_action, _target]
		}
	},
    skeleton: 
        {
            name: "Skeleton",
            hp: 60,
            hpMax: 60,
	        block: 0,
            mp: 0,
            mpMax: 0,
            strength: 7,
            sprites: {idle: sLegionnaire, attack: sLegionnaireAttack},
            actions: [global.actionLibrary.attack],
            xpValue : 25,
			spd: 1.2,
			spdMax: 100,
			spdBar: 0,
            AIscript : function()
            {
                // Attack random party member
                var _action = actions[0];
                var _possibleTargets = array_filter(oBattle.partyUnits, function(_unit, _index) {
                    return (_unit.hp > 0); 
                });
                
                var _target = lowestHp(_possibleTargets);
                return [_action, _target]
            }
        },
	bat: 
	{
		name: "Bat",
		hp: 15,
	    block: 0,		
        hpMax: 15,
		mp: 0,
		mpMax: 0,
		strength: 4,
        actions: [global.actionLibrary.attack],
		sprites: { idle: sBat, attack: sBatAttack},
		xpValue : 18,
		AIscript : function()
		{
            // Attack random party member
            var _action = actions[0];
            var _possibleTargets = array_filter(oBattle.partyUnits, function(_unit, _index) {
            return (_unit.hp > 0); 
            });
            var _target_id = irandom(array_length(_possibleTargets) - 1);
            var _target = _possibleTargets[_target_id];
            return [_action, _target]
		}
	}
}

enum MODE
{
	NEVER = 0,
	ALWAYS = 1,
	VARIES = 2,
}






