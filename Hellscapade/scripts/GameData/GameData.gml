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

global.statusDescriptions = {
    Poison: "Poison: Take X damage at the end of your turn.",
	Ignite: "Ignite: Take X damage each time the ignition gauge fills",
	Hindered: "Hindered: Speed reduced by 25% until your next turn.",
	Unbalanced: "Unbalanced: Damage taken from next attack increased by 50%",
	Sundered: "Sundered: Block gained reduced by 50%",
	Emboldened: "Emboldened: Your next hit deals 50% more damage",
	Empowered: "Empowered: Damage dealt reduced by X",
	Intimidated: "Intimidated: Your next hit deals 50% less damage",
	Weakened: "Weakened: Damage dealt reduced by X",
	Might: "Might: All damage dealt increased by X",
	Cunning: "Cunning: Draw an additional X cards at the start of your turn",
	Bastion: "Bastion: Gain X block at the start of your turn",
	Thorns: "Thorns: Deal X damage when attacked",
	Dodge: "Dodge: Avoid the next X harmful effects",
	Combo: "Combo: Attacks deal X additional damage until the end of the turn.",
	Spirit: "Spirit: At the start of your turn, heal X.",
	Transcendence: "Transcendence: Gain X Spirit at the start of your turn.",
	Grit: "Grit: Reduce damage taken from the next hit by 50%",
	TrueGrit: "True Grit: Reduce damage taken from the next hit by 80%",
	Retaliation: "Retaliation: When hit, consume all stacks and deal damage to the attacker equal to stacks consumed.",
	Leadership: "Leadership: Increases potency of Legionnaire's effects by X"
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






