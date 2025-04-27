instance_destroy()
var _slimes = irandom(4);
var _encounter = [];
for (var i = 0; i < _slimes + 1; i++) {
	array_push(_encounter, global.enemies.slimeG);
}
newEncounter(self.id,  _encounter, sBgField);