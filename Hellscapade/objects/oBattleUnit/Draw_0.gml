// Leaving this blank intentionally
if (self.hp > 0 && hover && oBattle.cursor.active && oBattle.cursor.targetAll == false) {
    draw_sprite(sReticle, -1, x - 16, y - 16);
}

var barLen = 33;
var hp_x = ((x - (self.sprite_width/2) * image_xscale) - barLen/4);
var hp_y = y + self.sprite_height - self.sprite_yoffset;

// Drawing the health bar
draw_sprite_stretched_ext(sBoxMin, -1, hp_x, hp_y, barLen, 4, c_white, 0.5 * masterAlpha);
draw_sprite_stretched_ext(sBoxMin, -1, hp_x, hp_y, ceil((self.hp/self.hpMax)*33), 4, c_red, masterAlpha);

// Drawing the speed bar
var spdBarLen = self.spdMax/3;
var spd_x = (x - (self.sprite_width/2) * image_xscale) - spdBarLen/4;
var spd_y =  hp_y + 4;

draw_sprite_stretched_ext(sBoxMin, -1, spd_x, spd_y, spdBarLen, 4, c_white, 0.5 * masterAlpha);
draw_sprite_stretched_ext(sBoxMin, -1, spd_x, spd_y, self.spdBar/3, 4, c_yellow, masterAlpha);

struct_foreach(statuses, function(_name, _value) {
	if (_value > 0 && hp > 0) {
		var _statusX = x - 8 * struct_names_count(statuses);
		var _statusY = y + self.sprite_height - self.sprite_yoffset + 4;
		var _spName = "s" + _name;
		var _statSprite = sprite_exists(asset_get_index(_spName)) ? asset_get_index(_spName) : sMissingStatus;
	
		draw_sprite_ext(_statSprite, -1, _statusX, _statusY, 1, 1, 0, c_white, masterAlpha);
	
		var _statTextX = _statusX + 2;
		var _statTextY = _statusY + 2;
		draw_text_color(_statTextX, _statTextY, _value, c_white, c_white, c_white, c_white, masterAlpha);
	}
});