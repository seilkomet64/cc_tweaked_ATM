local basalt = require("basalt")
local atmAPI = require("atmAPI")

local main = nil
local label = nil

local function checkForDisk()
    local drive = peripheral.find("drive")

    if not drive.isDiskPresent() then
        os.pullEvent("disk")
    end

    if not main or not label then return end

    label:setText("Card Detected! Checking for matches...")

    local success, result = pcall(function() return atmAPI.existsAccount(drive.getDiskID()) end)
    if not success then
        local errorMessage = result:match(":%d+: (.+)") or result
        -- Handle server unreachable error
        if errorMessage == "Failed to contact the server!" then
            label:setText("Server not reachable. Please try again later."):setForeground(colors.red)
        else
            -- Handle any other unexpected errors
            label:setText("An error occurred: " .. errorMessage):setForeground(colors.red)
        end
    elseif result then
        -- If account exists, proceed to main screen
        ChangeScreen(SCREENS.mainScreen, nil, {acc = drive.getDiskID()})
    else
        -- If account does not exist, show registration message
        label:setText("This Credit Card is not registered at our Bank!\nVisit the Bank to create a new Account!"):setForeground(colors.red)
    end

    os.pullEvent("disk_eject")

    if label then label:setText("Enter your Credit Card to continue!"):setForeground(colors.black) end

    checkForDisk()
end

return function()
    main = basalt.createFrame()
    if not main then error("Something went wrong creating the Main Frame") end

    label = main:addLabel():setText("Enter your Credit Card to continue!"):setPosition("parent.w / 2 - self.w / 2 + 1", "parent.h / 2")


    local diskCheckThread = main:addThread()
    diskCheckThread:start(checkForDisk)

    return main
end