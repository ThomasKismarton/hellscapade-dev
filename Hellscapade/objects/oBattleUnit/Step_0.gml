if (!instance_exists(oBattle)) {
	instance_destroy();
}

if hover {
    hoverTime = min(hoverTime + 1, 30);
} else {
    hoverTime = 0;
}