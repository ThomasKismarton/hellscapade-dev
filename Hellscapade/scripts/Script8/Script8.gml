global.bgmDict = {
	"StartMenu": bgmMerchant,
	"Room1": bgmValley,
	"Battle": bgmValleyBattle,
}

function getMusic(_roomName) {
	if (variable_struct_exists(global.bgmDict, _roomName)) {
		return global.bgmDict[$ _roomName];
	}
	return bgmMerchant;
}