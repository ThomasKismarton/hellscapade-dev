if (handPosition == -1) exit;

x = global.handLeft + (handPosition * (sprite_width + 2)) + camera_get_view_x(view_camera[0]);
y = global.handHeight + camera_get_view_y(view_camera[0]);