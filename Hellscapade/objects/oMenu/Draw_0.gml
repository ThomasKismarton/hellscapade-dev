draw_sprite_stretched(sBox, 0, x, y, widthFull, heightFull);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_font(fnM5x7);

// _scrollPush stores how many items we need to cutoff from the top of our menu
var _scrollPush = max(0, hover - (visibleOptionsMax-1));
var _desc = (description != -1); // Whether or not description exists for the action

for (var l = 0; l < (visibleOptionsMax + _desc); l++) {
    // Prevents descriptions from causing null-index errors
    if (l >= array_length(options)) {
        break;
    }

    // Reset draw color
    draw_set_color(c_white);

    // Draws the description
    if (l == 0) && _desc {
        draw_text(x + xmargin, y + ymargin, description);
    } else {
        var _optionToShow = l - _desc + _scrollPush;
        var _str = options[_optionToShow].name;
        if (hover == _optionToShow - _desc) {
            draw_set_color(c_yellow);
        }
        if (options[_optionToShow].avail == false) {
            draw_set_color(c_gray);
        }
        draw_text(x + xmargin, y + ymargin + l * heightLine, _str);
    }
}
// ymargin is initial offset, hover - SP is the item minus cutoff
// Prevents pointer going crazy for item #5 in a 3 item menu
draw_sprite(sPointer, 0, x + xmargin + 8, y + ymargin + ((hover - _scrollPush) * heightLine) + 7);

// If we can't currently see all the options, and we're not on the last one yet,
// Draw a down arrow to let user know there's more options
if (visibleOptionsMax < array_length(options) && hover < array_length(options)-1) {
    draw_sprite(sDownArrow, 0, x + widthFull * 0.5, y + heightFull - 7);
}