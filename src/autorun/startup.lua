require(settings.get("ghu.base") .. "core/apis/ghu")
local basalt = require("basalt")
require("screenManager")
require("config")

ChangeScreen(SCREENS.enterDiskScreen)

basalt.onEvent(function(event)
    if event == "disk_eject" then
        ChangeScreen(SCREENS.enterDiskScreen, nil, nil)
    end
end)

basalt.autoUpdate()