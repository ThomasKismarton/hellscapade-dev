// Drawing the battlefield sprite
draw_sprite(battleBackground,0,x,y);

// Draw units in order of depth
var _unitWithCurrentTurn = unitRenderOrder[turn].id; // '.id' grabs the referenced object instance by ID value
for (var i = 0; i < array_length(unitRenderOrder); i++) {
    // Using the 'with' keyword here allows us to reference the iterated instance as 'self'.
    // This lets us use methods such as 'draw_self()'
    with (unitRenderOrder[i]) {
        draw_self();
    }
}

// Drawing ui boxes
draw_sprite_stretched(sBox,0,x+75,y+120,245,60);
draw_sprite_stretched(sBox,0,x,y+120,74,60);

// Positions - magic number constants for later tweaking as necessary.
#macro COLUMN_ENEMY 5
#macro COLUMN_NAME 90
#macro COLUMN_HP 160
#macro COLUMN_MP 220
#macro INFO 260

// Draw UI headers
// valign + halign used to set drawing reference to the top left corner of oBattle.
draw_set_font(fnM3x6);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_gray);
draw_text(x+COLUMN_ENEMY, y+120, "ENEMY");
draw_text(x+COLUMN_NAME, y+120, "NAME");
draw_text(x+COLUMN_HP, y+120, "HP");
draw_text(x+COLUMN_MP, y+120, "MP");
draw_text(x+INFO, y+120, $"{mouse_x}, {mouse_y}")

// Drawing list of enemies
draw_set_font(fnOpenSansPX);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
var _drawLimit = 3;
var _drawn = 0;

for (var i = 0; (i < array_length(enemyUnits) && _drawn < _drawLimit); i++) {
    // Grabs the enemy to display text for
    var _char = enemyUnits[i];
    if (_char.hp > 0) {
        _drawn++;
        if (_char.id == _unitWithCurrentTurn) {
            draw_set_color(c_yellow);
        } else {
            draw_set_color(c_white);
        }
        draw_text(x + COLUMN_ENEMY, y + 130 + (i*12), $"{_char.name}: {_char.hp}");
    }
}

// Draw Party information
for (var i = 0; i < array_length(partyUnits); i++) {
    draw_set_halign(fa_left);
    draw_set_color(c_white);
    
    var _char = partyUnits[i];
    if (_char.id == _unitWithCurrentTurn)  draw_set_color(c_yellow);
    if (_char.hp <= 0) draw_set_color(c_red);
    draw_text(x + COLUMN_NAME, y + 130 + (i*12), _char.name);
    
    draw_set_halign(fa_right);
    if (_char.hp <= (_char.hpMax * 0.5)) draw_set_color(c_orange);
    if (_char.hp <= 0) draw_set_color(c_red);
    draw_text(x + COLUMN_HP + 50, y + 130 + (i*12), string(_char.hp) + "/" + string(_char.hpMax));
    
    if (_char.mp <= (_char.mpMax * 0.5)) draw_set_color(c_orange);
    if (_char.mp <= 0) draw_set_color(c_red);
    draw_text(x + COLUMN_MP + 50, y + 130 + (i*12), string(_char.mp) + "/" + string(_char.mpMax));
    
    draw_set_color(c_white);
}

if (cursor.active) {
    with (cursor) {
        // Single targeting
        if (activeReticle != noone) {
            if (!is_array(activeReticle)) {
                // Draw a solid pointer sprite
                draw_sprite(sPointer, 0, activeReticle.x, activeReticle.y);
            } else {
                // Draw a flashing pointer on all targets
                // Flashing indicates AoE
                draw_set_alpha(sin(get_timer()/50000) + 1);
                for (var k = 0; k < array_length(activeReticle); k++) {
                    draw_sprite(sPointer, 0, activeReticle[k].x, activeReticle[k].y);
                }
                draw_set_alpha(1.0);
            }
        }
    }
}