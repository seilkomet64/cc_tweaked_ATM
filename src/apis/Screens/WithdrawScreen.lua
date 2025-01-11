local basalt = require("basalt")
local atmAPI = require("atmAPI")
local selectionBase = require("Screens.selectionBase")
local errorDialog = require("Screens.errorDialog")
local confirmDialog = require("Screens.confirmDialog")
local acceptDialog = require("Screens.acceptDialog")
local itemManager = require("itemManager")

local function createScreen(args)
    local amount = 0
    local finalAmount = 0
    local newBalance
    local main
    local mainContent
    local inputThread
    local listenKeyInputs, confirmButton, submitFunction, updateLabel, activateKeyboardInput, deactivateKeyboardInput

    function activateKeyboardInput()
        inputThread:start(listenKeyInputs)
    end

    function listenKeyInputs()
        while true do
            local event, key, is_held = os.pullEvent()

            if event == "key" then
                if key == keys.backspace then
                    local currentAmount = tostring(amount)
                    currentAmount = currentAmount:sub(1, -2)
                    if currentAmount == "" then currentAmount = "0" end
                    amount = tonumber(currentAmount) or amount
                    updateLabel(0)  -- Update the label to reflect the change
                end

                if key == keys.enter then
                    -- On Submit Function maybe stop the thread?
                    submitFunction()
                end
            elseif event == "char" then
                local currentAmount = tostring(amount)
                currentAmount = currentAmount .. key
                amount = tonumber(currentAmount) or amount
                updateLabel(0)  -- Update the label to reflect the change
            end
        end
    end

    function confirmButton()
        local success, balance, ids, transIndex = pcall(function() return atmAPI.withdraw(args.acc, finalAmount, args.pin) end)
        finalAmount = 0
        if not success then
            -- Handle the error
            local errorMessage = balance:match(":%d+: (.+)") or balance  -- Clean up error message (removes file/line info)
        
            -- Display specific error messages based on known issues
            if errorMessage == "Failed to contact the server!" then
                errorDialog(main, mainContent, {"Server not reachable.", "Try again later!"})
            elseif errorMessage == "Error: Incorrect PIN entered." then
                errorDialog(main, mainContent, {"Incorrect PIN", "Please try again."})
            else
                -- Generic error message for any other issues
                errorDialog(main, mainContent, {"An error occurred: ", errorMessage})
            end
        else
            itemManager.materializeItems(ids)
            atmAPI.confirmWithdrawal(args.acc, transIndex)
            acceptDialog(main, mainContent, {"Please pick up your " .. CONFIG.CURRENCYNAME .. "s", "from the Dropper!"}, args)
        end
    end

    function submitFunction()
        if amount == 0 then
            errorDialog(main, mainContent, {"You can't withdraw nothing!"})
        elseif newBalance < 0 then
            errorDialog(main, mainContent, {"You don't have enough " .. CONFIG.COINNAME .."!"})
        else
            finalAmount = amount
            confirmDialog(main, mainContent, string.format("Withdraw %s %ss?", finalAmount, CONFIG.CURRENCYNAME), confirmButton)
        end
    end

    main = selectionBase("Withdraw", submitFunction, args)
    mainContent = main:getChild("mainContent")
    inputThread = main:addThread()

    -- Label
    local labelRow = mainContent:addFrame():setSize("parent.w", "parent.h * 0.7 - 1"):setBackground(colors.lightGray)
    local newBalanceLabel
    -- Load Balance
    local success, result = pcall(function() return atmAPI.balance(args.acc, args.pin) end)

    if success then
        labelRow:addLabel():setText("Your Balance will be"):setPosition("parent.w * 0.5 + 1 - self.w * 0.5", 2)
        newBalanceLabel = labelRow:addLabel():setText(result):setPosition("parent.w * 0.5 + 1 - self.w * 0.5", 4)
    else
        local errorMessage = result:match(":%d+: (.+)") or result
        errorDialog(main, mainContent, {errorMessage})
    end

    -- Add Labels
    labelRow:addLabel():setText("How many " .. CONFIG.CURRENCYNAME .. "s do you want to withdraw?"):setPosition("parent.w * 0.5 + 1 - self.w * 0.5", "parent.h - 1")

    -- ButtonRow
    local buttonRow = mainContent:addFrame():setSize("parent.w", 3):setPosition(1, "parent.h * 0.7"):setBackground(colors.lightGray)
    local buttonSize = {5, 3}
    local amountLabel = buttonRow:addLabel("amountLabel"):setText(0):setPosition("parent.w * 0.5 + 1 - self.w * 0.5", 2)


    --- Updates the label with the given amount.
    -- @param change number: The amount to change the label by.
    function updateLabel(change)
        amount = amount + change

        if amount < 0 then amount = 0 end
        amountLabel:setText(amount)

        newBalance = result - amount * CONFIG.EXCHANGERATE
        newBalanceLabel:setText(newBalance)

        if newBalance < 0 then newBalanceLabel:setForeground(colors.red) else newBalanceLabel:setForeground(colors.black) end
    end

    buttonRow:addButton():setText("-64"):setSize(buttonSize[1], buttonSize[2]):setPosition(2):onClick(function() updateLabel(-64) end)
    buttonRow:addButton():setText("-16"):setSize(buttonSize[1], buttonSize[2]):setPosition(8):onClick(function() updateLabel(-16) end)
    buttonRow:addButton():setText("-1"):setSize(buttonSize[1], buttonSize[2]):setPosition(14):onClick(function() updateLabel(-1) end)
    buttonRow:addButton():setText("+1"):setSize(buttonSize[1], buttonSize[2]):setPosition("parent.w - 17"):onClick(function() updateLabel(1) end)
    buttonRow:addButton():setText("+16"):setSize(buttonSize[1], buttonSize[2]):setPosition("parent.w - 11"):onClick(function() updateLabel(16) end)
    buttonRow:addButton():setText("+64"):setSize(buttonSize[1], buttonSize[2]):setPosition("parent.w - 5"):onClick(function() updateLabel(64) end)

    activateKeyboardInput()
    return main
end

return createScreen
