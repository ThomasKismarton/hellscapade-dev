// Initial version uses arrays - using structs will be more efficient, just not copyable. Attempting to rework w/ structs here.
// Menu - makes a menu, options provided in the form [{name, function, args}, [...]
/* 
E.g. options = 
[
    {action1},
    {name: “Fireball”, func: functFireball, args: _targets, avail: true}
]
*/
// Description tied to the menu, not to the options

// Creates a new menu at x, y
// Determines height and width of the menu
function Menu(_x, _y, _options, _description = -1, _menuWidth = undefined, _menuHeight = undefined) {
    with (instance_create_depth(_x, _y, -99999, oMenu)) {
        options = _options;
        description = _description;
        var _optionsCount = array_length(_options);
        visibleOptionsMax = _optionsCount;
        
        xmargin = 10;
        ymargin = 10;
        draw_set_font(fnM5x7);
        heightLine = 12; // Manually setting line height, font auto height unpredictable
        
        if (_menuWidth == undefined) {
            width = 1;
            // Set menu width to allow for long description
            if (description != -1) width = max(width, string_width(_description));
            for (var i = 0; i < _optionsCount; i++) {
                width = max(width, string_width(_options[i].name))
            }
            widthFull = width + xmargin * 2;
        } else {
            widthFull = _menuWidth
        }

        if (_menuHeight == undefined) {
            height = heightLine * (_optionsCount + (description != -1));
            heightFull = height + ymargin * 2;
        } else {
            heightFull = _menuHeight;
            if (heightLine * (_optionsCount + (description != -1)) > _menuHeight - (ymargin*2)) {
                scrolling = true;
                visibleOptionsMax = (_menuHeight - ymargin * 2) div heightLine;
            }
        }
    }
}

// Stores the menu's "higher level" options for referencing later
// Allows us to dive deeper & backtrack
function SubMenu(_options) {
    // Stores current menu options in the optionsAbove array
    // Can be referenced later to reload options
    optionsAbove[subMenuLevel] = options;
    // Increments depth of current menu
    subMenuLevel++;
    // Loads next options
    options = _options;
    // Hover represents the current selection
    // Need to reset cursor when traversing back up the menu
    hover = 0;
}

function MenuGoBack() {
    subMenuLevel--;
    options = optionsAbove[subMenuLevel];
    hover = 0;
}

function MenuSelectAction(_user, _action) {
    with (oMenu) active = false;
    with (oBattle) {
        // If a target is required, begin targeting
        if (_action.targetRequired) {
            // Use pointer cursor object
            with (cursor) {
                active = true;
                activeAction = _action;
                targetAll = _action.targetAll;
                numTargets = _action.numTargets;
                if (targetAll == MODE.VARIES) {
                    targetAll = true;
                }
                activeUser = _user;
				
                if (_action.targetEnemyByDefault) {
                    targetIndex = 0;
                    targetSide = oBattle.enemyUnits;
                    activeReticle = oBattle.enemyUnits[targetIndex];
                } else {
                    targetSide = oBattle.partyUnits;
                    activeReticle = activeUser;
                    // findSelf returns the index in an array of a specified element
                    var _findSelf = function(_element) {
                        return (_element == activeReticle);
                    }
                    // In this case, returns the index of the user
                    targetIndex = array_find_index(oBattle.partyUnits, _findSelf);
                }
            }
        } else {
            beginAction(_user, _action, -1);
            with (oMenu) instance_destroy();
        }
    }
}

