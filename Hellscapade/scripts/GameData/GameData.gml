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
            BattleChangeHp(_targets, -_damage, 0);
        }
    },
    kaboom: {
        name: "Kaboom",
        description: "{0} kabooms!",
        subMenu: -1,
        targetRequired : true,
        targetEnemyByDefault: true,
        numTargets: -1,
        targetAll: MODE.ALWAYS,
        userAnimation: "attack",
        effectSprite: sAttackBonk,
        effectOnTarget: MODE.ALWAYS,
        // The actual function to be performed when the action is taken
        // Keep in mind for playing cards later
        func: function(_user, _targets) {
            var _damage = 50;
            BattleChangeHp(_targets, -_damage, 0);
        }
    },
    ice:
    {
        name: "Ice",
        description: "{0} casts Ice!",
        subMenu: "Magic",
        mpCost: 4,
        targetRequired: true,
        targetEnemyByDefault: true,
        numTargets: 1,
        targetAll: MODE.VARIES,
        userAnimation: "cast",
        effectSprite: sAttackIce,
        effectOnTarget: MODE.ALWAYS,
        func: function (_user, _targets) {
            var _damage = 0;
            if (array_length(_targets) > 1) {
                _damage = irandom_range(5, 15);    
            } else {
                _damage = irandom_range(15, 25);
            }
            BattleChangeHp(_targets, -_damage);
            // BattleChangeMP(_user, -mpCost);
        }
    }
}

// Card Library
global.cards = {
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
		cardSprite: sCardBasic,
        // The actual function to be performed when the action is taken
        // Keep in mind for playing cards later
        func: function(_targets) {
            var _damage = ceil(5 + random_range(-2, 2));
            BattleChangeHp(_targets, -_damage, 0);
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
		maxHandSize: 5,
		strength: 6,
		sprites : { idle: sLuluIdle, attack: sLuluAttack, defend: sLuluDefend, down: sLuluDown},
		actions : [global.actionLibrary.attack, global.actionLibrary.kaboom]
	}
	,
	{
		name: "Questy",
		hp: 18,
		hpMax: 44,
		mp: 20,
		mpMax: 30,
		strength: 4,
		maxHandSize: 5,
		sprites : { idle: sQuestyIdle, attack: sQuestyCast, cast: sQuestyCast, down: sQuestyDown},
		actions : [global.actionLibrary.attack, global.actionLibrary.ice, global.actionLibrary.kaboom]
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
	maxHandSize: 5,
	strength: 6,
	startDeck: [["attack", 7]]
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
		strength: 5,
		sprites: {idle: sSlime, attack: sSlimeAttack},
		actions: [global.actionLibrary.attack],
		xpValue : 15,
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
            mp: 0,
            mpMax: 0,
            strength: 7,
            sprites: {idle: sLegionnaire, attack: sLegionnaireAttack},
            actions: [global.actionLibrary.attack],
            xpValue : 25,
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
		hpMax: 15,
		mp: 0,
		mpMax: 0,
		strength: 4,
		sprites: { idle: sBat, attack: sBatAttack},
		actions: [global.actionLibrary.attack],
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








