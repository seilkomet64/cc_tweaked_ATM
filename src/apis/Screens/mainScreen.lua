local basalt = require("basalt")

local function createMainScreen(args)
  local main = basalt.createFrame():setTheme({ButtonBG=colors.black, ButtonText=colors.white})
  if not main then
    return
  end



  main:addFrame():setSize("parent.w", "parent.h * 0.15")
  local mainContent = main:addFrame():setSize("parent.w - 2", "parent.h * 0.7"):setPosition("2", "parent.h * 0.15 + 1"):setBackground(colors.lightGray)
  main:addFrame():setSize("parent.w", "parent.h * 0.15"):setPosition("1", "parent.h * 0.85 + 1")

  -- header


  -- mainContent
  local flexFrame = mainContent:addFrame():setPosition("2", "2"):setSize("parent.w - 2", "parent.h - 2"):setBackground(colors.gray):setBorder(colors.black)
  local flex = flexFrame:addFlexbox():setWrap("wrap"):setJustifyContent("center"):setSize("parent.w - 2", "parent.h - 2"):setSpacing(2):setPosition(2, 2)

  flex:addButton():setText("Balance"):setSize("parent.w * 0.4", "parent.h * 0.3"):onClick(function()
    ChangeScreen(SCREENS.pinScreen, SCREENS.balanceScreen, args)
  end)
  flex:addButton():setText("Deposit"):setSize("parent.w * 0.4", "parent.h * 0.3"):onClick(function()
    ChangeScreen(SCREENS.pinScreen, SCREENS.depositScreen, args)
  end)

  flex:addBreak()

  flex:addButton():setText("Withdraw"):setSize("parent.w * 0.4", "parent.h * 0.3"):onClick(function()
    ChangeScreen(SCREENS.pinScreen, SCREENS.withdrawScreen, args)
  end)
  flex:addButton():setText("Transfer"):setSize("parent.w * 0.4", "parent.h * 0.3"):onClick(function()
    ChangeScreen(SCREENS.pinScreen, SCREENS.accountSelectionScreen, args)
  end)



  -- footer
  return main
end

return createMainScreen