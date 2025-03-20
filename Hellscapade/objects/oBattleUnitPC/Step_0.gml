event_inherited();
if (hp <= 0) {
    // Sprite index determines which sprite from the sprite struct to use for our object when it's being drawn.
    sprite_index = sprites.down;
} else {
    if (sprite_index == sprites.down) {
        sprite_index = sprites.idle;
    }
}