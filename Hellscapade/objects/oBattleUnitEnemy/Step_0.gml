event_inherited();
if (hp <= 0) {
    self.masterAlpha -= 0.02;
    image_alpha = self.masterAlpha;
    image_blend = c_red;
}