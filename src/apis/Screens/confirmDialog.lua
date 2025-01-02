return function(mainFrame, wrapperFrame, label, submitFunction)
    local dialogBox = wrapperFrame:addMovableFrame():setSize("parent.w * 0.8", "parent.h * 0.8"):setPosition("parent.w * 0.1 + 1", 2):setBorder(colors.black)
    dialogBox:addLabel():setText("Confirm"):setPosition("parent.w * 0.5 - self.w * 0.5 + 1", 2):setForeground(colors.red)
    dialogBox:addLabel():setText(label):setTextAlign("center"):setPosition("parent.w * 0.5 - self.w * 0.5 + 1", 4)
    dialogBox:addButton():setText("CANCEL"):setBackground(colors.red):setPosition(2, "parent.h - self.h"):onClick(function() dialogBox:hide() mainFrame:show() end)
    dialogBox:addButton():setText("CONFIRM"):setBackground(colors.green):setPosition("parent.w - self.w", "parent.h - self.h"):onClick(function() dialogBox:hide() submitFunction() end)
end
