local atmAPI = require("atmAPI")
local selectionBase = require("Screens.selectionBase")
local errorDialog = require("Screens.errorDialog")

local function createScreen(args)
    local account = 0
    local main
    local mainContent
    local inputThread
    local listenKeyInputs, submitFunction, updateLabel

    function listenKeyInputs()
        while true do
            local event, key, is_held = os.pullEvent()

            if event == "key" then
                if key == keys.backspace then
                    local currentAccount = tostring(account)
                    currentAccount = currentAccount:sub(1, -2)
                    if currentAccount == "" then currentAccount = "0" end
                    account = tonumber(currentAccount) or account
                    updateLabel(0)  -- Update the label to reflect the change
                end

                if key == keys.enter then
                    -- On Submit Function maybe stop the thread?
                    submitFunction()
                end
            elseif event == "char" then
                local currentAccount = tostring(account)
                currentAccount = currentAccount .. key
                account = tonumber(currentAccount) or account
                updateLabel(0)  -- Update the label to reflect the change
            end
        end
    end

    function submitFunction()
        if account == 0 then
            errorDialog(main, mainContent, {"Please enter a valid account number."})
            return
        elseif args.acc == account then
            errorDialog(main, mainContent, {"Cannot transfer to the same account."})
            return
        end

        local success, result = pcall(function() return atmAPI.existsAccount(account) end)

        if not success then
            errorDialog(main, mainContent, {"Error checking account number."})
            return
        elseif not result then
            errorDialog(main, mainContent, {"Account does not exist."})
            return
        else
            ChangeScreen(SCREENS.transferScreen, nil, {acc = args.acc, targetAcc = account, pin = args.pin})
        end
    end

    main = selectionBase("Select Account", submitFunction, args)
    mainContent = main:getChild("mainContent")

     -- Label
    local labelRow = mainContent:addFrame():setSize("parent.w", "parent.h * 0.5 - 1"):setBackground(colors.lightGray)
    -- Add Labels
    labelRow:addLabel():setText("Which Account do you want to transfer to?"):setPosition("parent.w * 0.5 + 1 - self.w * 0.5", "parent.h - 1")

    -- ButtonRow
    local buttonRow = mainContent:addFrame():setSize("parent.w", 3):setPosition(1, "parent.h * 0.5"):setBackground(colors.lightGray)
    local buttonSize = {5, 3}
    local accountLabel = buttonRow:addLabel():setText(0):setPosition("parent.w * 0.5 + 1 - self.w * 0.5", 2)


    --- Updates the label with the given account.
    -- @param change number: The account to change the label by.
    function updateLabel(change)
        account = account + change

        if account < 0 then account = 0 end
        accountLabel:setText(account)
    end

    buttonRow:addButton():setText("-10"):setSize(buttonSize[1], buttonSize[2]):setPosition(2):onClick(function() updateLabel(-10) end)
    buttonRow:addButton():setText("-5"):setSize(buttonSize[1], buttonSize[2]):setPosition(8):onClick(function() updateLabel(-5) end)
    buttonRow:addButton():setText("-1"):setSize(buttonSize[1], buttonSize[2]):setPosition(14):onClick(function() updateLabel(-1) end)
    buttonRow:addButton():setText("+1"):setSize(buttonSize[1], buttonSize[2]):setPosition("parent.w - 17"):onClick(function() updateLabel(1) end)
    buttonRow:addButton():setText("+5"):setSize(buttonSize[1], buttonSize[2]):setPosition("parent.w - 11"):onClick(function() updateLabel(5) end)
    buttonRow:addButton():setText("+10"):setSize(buttonSize[1], buttonSize[2]):setPosition("parent.w - 5"):onClick(function() updateLabel(10) end)

    inputThread = main:addThread()
    inputThread:start(listenKeyInputs)
    return main
end

return createScreen
