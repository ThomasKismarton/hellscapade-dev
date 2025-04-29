persistent = true;
_bgm = noone;
_nBgm = bgmMerchant;

function switchBgm(_sound) {
	_nBgm = getMusic(_sound);
	audio_stop_sound(_bgm);
	_bgm = audio_play_sound(_nBgm, 1, true);
}
