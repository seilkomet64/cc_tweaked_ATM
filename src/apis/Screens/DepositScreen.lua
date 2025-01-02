local basalt = require("basalt")
local selectionBase = require("Screens.selectionBase")
local dialogBox = require("Screens.confirmDialog")
local errorBox = require("Screens.errorDialog")
local acceptBox = require("Screens.acceptDialog")
local atmAPI = require("atmAPI")
local itemManager = require("itemManager")

local function createScreen(arguments)
    local main
    local mainContent
    local args

    local function submitButton()
        local digitalIDs = itemManager.digitizeAllItems(CONFIG.CURRENCYITEM)
        local success, result = pcall(function() return atmAPI.deposit(args.acc, digitalIDs, args.pin) end)

        if not success then
            -- Handle the error
            local errorMessage = result:match(":%d+: (.+)") or result  -- Clean up error message (removes file/line info)
        
            -- Display specific error messages based on known issues
            if errorMessage == "Failed to contact the server!" then
                errorBox(main, mainContent, {"Server not reachable.", "Try again later!"})
            elseif errorMessage == "Error: Incorrect PIN entered." then
                errorBox(main, mainContent, {"Incorrect PIN", "Please try again."} )
            else
                -- Generic error message for any other issues
                errorBox(main, mainContent, {"An error occurred: ", errorMessage})
            end

            -- if Error return diamonmds
            itemManager.materializeItems(digitalIDs)
        else
            -- If deposit was successful, you can process the balance
            acceptBox(main, mainContent, {"Your balance is now:", result}, args)
        end
    end

    local function openDialog()
        local amount = itemManager.getCurrency(CONFIG.CURRENCYITEM)
        if amount == 0 then
            errorBox(main, mainContent, {"You can't deposit nothing!"})
        else
            dialogBox(main, mainContent, "Deposit " .. amount .. " " .. CONFIG.CURRENCYNAME .. ("(s)"), submitButton)
        end
    end


    args = arguments
    main = selectionBase("Deposit", openDialog, args)
    mainContent = main:getChild("mainContent")

    mainContent:addLabel():setText("Add " .. CONFIG.CURRENCYNAME .. "s inside the Dropper beneath you!"):setTextAlign("center"):setPosition("parent.w * 0.5 - self.w * 0.5 + 1", "parent.h * 0.5")
    return main
end

return createScreen