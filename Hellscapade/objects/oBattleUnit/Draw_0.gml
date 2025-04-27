// Leaving this blank intentionally
if (hover && oBattle.cursor.active && oBattle.cursor.targetAll == false) {
    draw_sprite(sReticle, -1, x - 16, y - 16);
}

var barLen = self.spdMax/3;
var spd_x = (x - (self.sprite_width/2) * image_xscale) - barLen/4;
var spd_y = y + self.sprite_height - self.sprite_yoffset;

draw_sprite_stretched_ext(sBoxMin, -1, spd_x, spd_y, barLen, 4, c_white, 0.5 * image_alpha);
draw_sprite_stretched_ext(sBoxMin, -1, spd_x, spd_y, self.spdBar/3, 4, c_yellow, image_alpha);

struct_foreach(statuses, function(_name, _value) {
	if (_value > 0) {
		var _statusX = x - 8 * struct_names_count(statuses);
		var _statusY = y + self.sprite_height - self.sprite_yoffset + 4;
		var _spName = "s" + _name;
		var _statSprite = sprite_exists(asset_get_index(_spName)) ? asset_get_index(_spName) : sMissingStatus;
	
		draw_sprite_ext(_statSprite, -1, _statusX, _statusY, 1, 1, 0, c_white, image_alpha);
	
		var _statTextX = _statusX + 2;
		var _statTextY = _statusY + 2;
		draw_text(_statTextX, _statTextY, _value);
	}
});