local basalt = require("basalt")

local function createSelectionBase(selectionLabel, okFunction, args)
  local main = basalt.createFrame():setTheme({ButtonBG=colors.black, ButtonText=colors.white})
  if not main then
    error("Unable to create main Frame")
  end

  local header = main:addFrame():setSize("parent.w", 3)
  main:addFrame("mainContent"):setSize("parent.w", "parent.h - 6"):setPosition("1", 4):setBackground(colors.lightGray)
  local footer = main:addFrame():setSize("parent.w", 3):setPosition("1", "parent.h - 2")

  -- header
  header:addLabel():setText("Current Exchange rate"):setTextAlign("right"):setPosition("parent.w - self.w + 1")
  header:addLabel():setPosition("self.x", 2):setTextAlign("right"):setPosition("parent.w - self.w + 1"):setText(string.format("1 %s = %s %s", CONFIG.CURRENCYNAME, CONFIG.EXCHANGERATE, CONFIG.COINNAME))
  header:addLabel():setText(selectionLabel):setForeground(colors.purple)
  -- footer
  footer:addButton():setText("CANCEL"):setBackground(colors.red):onClick(function() ChangeScreen(SCREENS.mainScreen, nil, {acc = args.acc}) end)
  footer:addButton("OKButton"):setText("OK"):setBackground(colors.green):setPosition("parent.w + 1 - self.w"):onClick(okFunction)

  return main
end

return createSelectionBase