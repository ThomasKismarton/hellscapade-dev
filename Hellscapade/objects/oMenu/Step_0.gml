// Only uses keyboard for control - could be good practice to generalize
// this piece to allow for mouse selection
if (active) {
    hover += keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
    // Wraps cursor around if we exceed current options
    if (hover > array_length(options)-1) hover = 0;
    if (hover < 0) hover = array_length(options) - 1;

    // Attempt to execute the selected function
    if (keyboard_check_pressed(vk_enter)) {
        if (options[hover].func != undefined) {
            var _func = options[hover].func;
            if (options[hover].args != -1) {
                script_execute_ext(_func, options[hover].args);
            } else {
                _func();
            }
        }
    }
    if (keyboard_check_pressed(vk_escape) && subMenuLevel > 0) {
        MenuGoBack();
    }
}