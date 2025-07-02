// Leaving this blank intentionally
if (hover && oBattle.cursor.active && oBattle.cursor.targetAll == false) {
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

statOrder = 0;
statusCount = struct_names_count(statuses); // May need to rework to account for statuses = 0
tboxYoff = statusCount * 45;
tboxHeight = statusCount * 50;
tboxWidth = 100;

if (hoverTime >= 30) {
    draw_sprite_stretched(sBox, -1, x - self.sprite_width, y - self.sprite_height, tboxWidth, tboxHeight);
}

struct_foreach(statuses, function(_name, _value) {
	if (_value > 0 && hp > 0) {
        // Set coordinates for sprite of status
		var _statusX = x - 4 * statusCount + statOrder * 8;
		var _statusY = y + self.sprite_height - self.sprite_yoffset + 4;
		var _spName = "s" + _name;
        // Use placeholder for missing sprites
		var _statSprite = sprite_exists(asset_get_index(_spName)) ? asset_get_index(_spName) : sMissingStatus;
		draw_sprite_ext(_statSprite, -1, _statusX, _statusY, 0.5, 0.5, 0, c_white, masterAlpha);

        // Offset & draw number of stacks next to each status
        var _statTextX = _statusX + 8;
        var _statTextY = _statusY + 2;
        draw_text_color(_statTextX, _statTextY, _value, c_white, c_white, c_white, c_white, masterAlpha * 0.95);

        // If hovered for half a second, display descriptions for statuses
        // Continue updating for dynamic height of hovered status tooltips.
        var _lastPos = 0;
        if (hoverTime >= 30) {
            draw_set_font(fnM5x7);
            draw_set_halign(fa_left);
            var _statDesc = global.statusDescriptions[$ _name];
            show_debug_message(string_length(_statDesc));
            draw_text_ext(x - self.sprite_width + 10, y - self.sprite_height + _lastPos, _statDesc, 10, int64(0.8 * tboxWidth));
        }
        statOrder += 1;
	}
});
