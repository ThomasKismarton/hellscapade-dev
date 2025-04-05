// Leaving this blank intentionally
if (hover && oBattle.cursor.active && oBattle.cursor.targetAll == false) {
    draw_sprite(sReticle, -1, x - 16, y - 16);
}

if (hp > 0) {
	var barLen = self.spdMax/3;
	var spd_x = (x - (self.sprite_width/2) * image_xscale) - barLen/4;
	var spd_y = y + self.sprite_height - self.sprite_yoffset;

	draw_sprite_stretched_ext(sBoxMin, -1, spd_x, spd_y, barLen, 4, c_white, 0.5);
	draw_sprite_stretched_ext(sBoxMin, -1, spd_x, spd_y, self.spdBar/3, 4, c_yellow, 1.0);
}