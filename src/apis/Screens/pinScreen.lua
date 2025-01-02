local basalt = require("basalt")
local atmAPI = require("atmAPI")
local fancyButton = require("helpers")

local function createPinScreen(nextScreen, args)
    local pinMainFrame = basalt.createFrame():setTheme({ButtonBG=colors.black, ButtonText=colors.white}):setBackground(colors.gray)
    local flex = pinMainFrame:addFlexbox():setWrap("wrap"):setJustifyContent("center"):setSize("parent.w", "parent.h"):setSpacing(1):setPosition(2, 2):setJustifyContent("center")

    -- Threads
    local keyThread = pinMainFrame:addThread()
    local pinCheckThread = pinMainFrame:addThread()

    -- pin pad
    local input = flex:addLabel():setText("_____"):setSize(5, 1)
    local pin = ""
    flex:addBreak()

    local function updateInput()
        local maskedPin = string.rep("*", string.len(pin))
        input:setText(maskedPin .. string.rep("_", 5 - string.len(pin)))
    end

    -- header
    local incorrectPinLabel = pinMainFrame:addLabel():setText(""):setForeground(colors.red)

    local function updateLabel(text)
        incorrectPinLabel:setText(text)
        local labelSize = incorrectPinLabel:getSize()
        incorrectPinLabel:setPosition("2 + parent.w * 0.5 - ".. labelSize * 0.5)
    end

    pinMainFrame:addButton():setText("CANCEL"):setPosition("parent.w - 5", 1):setSize(6, 1):setForeground(colors.red):setBackground(colors.black):onClick(function() ChangeScreen(SCREENS.mainScreen, nil, {acc = args.acc}) end)

    local function submitPin()
        if string.len(pin) < 5 then
            updateLabel("Incorrect Pin! Try again...")
            return
        end

        updateLabel("Checking...")
        pinCheckThread:start(function()
            -- Try to check the pin and handle possible errors
            local success, result = pcall(function()
                return atmAPI.checkPin(args.acc, pin)
            end)
            
            if not success then
                local errorMessage = result:match(":%d+: (.+)") or result
                -- Handle the server error
                if errorMessage == "Failed to contact the server!" then
                    updateLabel("Server not reachable!")
                else
                    -- Handle any other unexpected errors
                    updateLabel("An error occurred: " .. errorMessage)
                end
            elseif result then
                -- If pin is correct
                updateLabel("Success!")
                ChangeScreen(nextScreen, nil, {pin = pin, acc = args.acc})
            else
                -- If pin is incorrect
                updateLabel("Incorrect Pin! Try again...")
            end
        end)
    end

    local buttonLabels = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "C", "0", "OK"}
    for i, v in ipairs(buttonLabels) do
        local button = flex:addButton():setText(v)

        if i % 3 == 0 then
            flex:addBreak()
        end

        if v == "C" then
            button:setBackground(colors.red)
        elseif v == "OK" then
            button:setBackground(colors.green)
        end

        fancyButton(button)

        button:onClick(function(self)
            if self:getText() == "C" then
                pin = pin:sub(1, -2)
                updateInput()
            elseif self:getText() == "OK" then
                submitPin()
            elseif string.len(pin) == 5 then
                return
            else
                pin = pin .. self:getText()
                updateInput()
            end
        end)
    end



    -- os.pullEvent is blocking, so we need to run it in a separate thread
    local function listenKeyInputs()
        while true do
            ::continue::
            local event, key, is_held = os.pullEvent()

            if event == "key" then
                if key == keys.backspace then
                    pin = pin:sub(1, -2)
                    updateInput()
                end

                if key == keys.enter then
                    submitPin()
                end
            elseif event == "char" then
                if string.len(pin) == 5 then
                    goto continue
                end

                -- Returns nil if not a number
                if tonumber(key) == nil then
                    goto continue
                end

                pin = pin .. key
                updateInput()
            end
            
        end
    end

    keyThread:start(listenKeyInputs)
    return pinMainFrame
end

return createPinScreen

