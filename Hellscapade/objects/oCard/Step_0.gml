if (handPosition == -1) exit;

x = global.handLeft + ((handPosition - floor(oDeck.handSize/2)) * (sprite_width+2));
y = global.handHeight;  