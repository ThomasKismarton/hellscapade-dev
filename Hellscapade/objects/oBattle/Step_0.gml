battleState();

// Enters the targeting phase of the cursor
if (cursor.active) {
    with (cursor) {
        var _keyUp = keyboard_check_pressed(ord("W"));
        var _keyDown = keyboard_check_pressed(ord("S"));
        var _keyLeft = keyboard_check_pressed(ord("A"));
        var _keyRight = keyboard_check_pressed(ord("D"));
        var _keyToggle = false;
        var _keyConfirm = false;
        var _keyCancel = false;
        var _click = false;
        
        comfirmDelay += 1;
        
        if (comfirmDelay > 1) {
            _keyConfirm = keyboard_check_pressed(vk_enter);
            _keyCancel = keyboard_check_pressed(vk_escape);
            _keyToggle = keyboard_check_pressed(vk_shift);
            _click = mouse_check_button_pressed(mb_left);
        }
        
        var _moveH = _keyRight - _keyLeft;
        var _moveV = _keyDown - _keyUp;
        
        if (_moveH == -1) targetSide = oBattle.partyUnits;
        if (_moveH == 1) targetSide = oBattle.enemyUnits;
            
        // Simple filter prevents us from targeting dead enemy units.
        if (targetSide == oBattle.enemyUnits) {
            targetSide = array_filter(targetSide, function (_element, _index) {
                return _element.hp > 0;    
            });
        }
        
        if (targetAll == false) {
            targetIndex += _moveV;
            
            // Target wrapping to prevent going outside array of enemies
            var _targets = array_length(targetSide);
            if (targetIndex < 0) targetIndex = _targets - 1;
            if (targetIndex > (_targets - 1)) targetIndex = 0;
                
            activeReticle = targetSide[targetIndex];
            
            // Switch to AoE mode
            if (playedCard.targetAll == MODE.VARIES) && (_keyToggle) {
                targetAll = true;
                activeTargets = [];
            }
            
            // Keyboard targeting
            if (_keyConfirm) {
                array_push(activeTargets, activeReticle);
                // show_debug_message(activeTargets);
            }
            
            // Click targeting
            if (_click) {
                activeReticle = collision_point(mouse_x, mouse_y, oBattleUnit, false, false);
                if (activeReticle != -4) {
                    array_push(activeTargets, activeReticle);
                }
                // show_debug_message(activeTargets);
            }
            
            // Confirm and execute action
            // This would likely be translated as the condition of (array_length(targets) == num_targets) from prev. project
            if (array_length(activeTargets) >= numTargets) {
                    with (oBattle) beginAction(cursor.activeUser, cursor.playedCard, cursor.activeTargets);
                    with (oMenu) instance_destroy();
                    active = false;
                    confirmDelay = 0;
                    activeTargets = [];
            }
        } else {
            activeReticle = targetSide;
            
            // Switch to single target mode
            if (activeAction.targetAll == MODE.VARIES) && (_keyToggle) {
                targetAll = false;
            }
            
            // Confirm and execute action
            // This would likely be translated as the condition of (array_length(targets) == num_targets) from prev. project
            if (_keyConfirm || _click) {
                activeTargets = targetSide;
                with (oBattle) beginAction(cursor.activeUser, cursor.playedCard, cursor.activeTargets);
                with (oMenu) instance_destroy();
                active = false;
                confirmDelay = 0;
                activeTargets = [];
            }
        } 
        
        // Cancel and return to previous menu
        if (_keyCancel) && (!_keyConfirm) {
            with (oMenu) active = true;
            active = false;
            confirmDelay = 0;
            activeTargets = [];
        }
    }
}