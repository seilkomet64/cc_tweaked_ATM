local basalt = require("basalt")

local pinScreen = require("Screens.pinScreen")
local mainScreen = require("Screens.mainScreen")
local balanceScreen = require("Screens.BalanceScreen")
local depositScreen = require("Screens.DepositScreen")
local withdrawScreen = require("Screens.WithdrawScreen")
local transferScreen = require("Screens.TransferScreen")
local enterDiskScreen = require("Screens.enterDiskScreen")
local accountSelectionScreen = require("Screens.accountSelectionScreen")

SCREENS = {
    mainScreen = "mainScreen",
    pinScreen = "pinScreen",
    balanceScreen = "balanceScreen",
    depositScreen = "depositScreen",
    transferScreen = "transferScreen",
    withdrawScreen = "withdrawScreen",
    enterDiskScreen = "enterDiskScreen",
    accountSelectionScreen = "accountSelectionScreen"
}

local currentScreen = nil

-- NewScreen: The new Screen, NextScreen: The Screen the new Screen should switch to, args: Any arguments to be given to new Screen
function ChangeScreen(newScreen, nextScreen, args)
    -- hide old screen
    if currentScreen then currentScreen:hide() end

    -- set new Screen
    if newScreen == SCREENS.mainScreen then currentScreen = mainScreen(args)
    elseif newScreen == SCREENS.pinScreen then currentScreen = pinScreen(nextScreen, args)
    elseif newScreen == SCREENS.balanceScreen then currentScreen = balanceScreen(args)
    elseif newScreen == SCREENS.depositScreen then currentScreen = depositScreen(args)
    elseif newScreen == SCREENS.withdrawScreen then currentScreen = withdrawScreen(args)
    elseif newScreen == SCREENS.transferScreen then currentScreen = transferScreen(args)
    elseif newScreen == SCREENS.enterDiskScreen then currentScreen = enterDiskScreen()
    elseif newScreen == SCREENS.accountSelectionScreen then currentScreen = accountSelectionScreen(args)
    else error("Invalid Screen")
    end

    -- Change screen or go back to mainScreen
    if currentScreen then currentScreen:show() else ChangeScreen(SCREENS.mainScreen) end
end
