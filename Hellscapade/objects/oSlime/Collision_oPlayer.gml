instance_destroy()
var _slimes = irandom(8) + 1;
var _encounter = [];
for (var i = 0; i < _slimes; i++) {
	array_push(_encounter, global.enemies.slimeG);
}
newEncounter(self.id,  _encounter, sBgField);