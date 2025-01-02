local basalt = require("basalt")
local selectionBase = require("Screens.selectionBase")
local atmAPI = require("atmAPI")



local function createScreen(args)
    local function okButton()
        ChangeScreen(SCREENS.mainScreen, nil, args)
    end

    local main = selectionBase("Balance", okButton, args)
    local mainContent = main:getChild("mainContent")

    mainContent:addLabel():setText("Current Balance in " .. CONFIG.COINNAME):setTextAlign("center"):setPosition("parent.w * 0.5 - self.w / 2", 5):setFontSize(1)

    local success, result = pcall(function() return atmAPI.balance(args.acc, args.pin) end)

    if success then
        mainContent:addLabel():setText(result):setTextAlign("center"):setPosition("parent.w * 0.5 - self.w / 2", 8):setFontSize(2)
    else
        local errorMessage = result:match(":%d+: (.+)") or result
        mainContent:addLabel():setText(errorMessage):setTextAlign("center"):setPosition("parent.w * 0.5 - self.w / 2", 8):setFontSize(1):setForeground(colors.red)
    end

    return main
end

return createScreen