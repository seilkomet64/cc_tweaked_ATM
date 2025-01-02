return function(mainFrame, wrapperFrame, errorLabels)
    local errorBox = wrapperFrame:addMovableFrame():setSize("parent.w * 0.8", "parent.h * 0.8"):setPosition("parent.w * 0.1 + 1", 2):setBorder(colors.black)
    errorBox:addLabel():setText("ERROR"):setPosition("parent.w * 0.5 - self.w * 0.5 + 1", 2):setForeground(colors.red)
    errorBox:addLabel():setText(errorLabels[1] or ""):setTextAlign("center"):setPosition("parent.w * 0.5 - self.w * 0.5 + 1", 4)
    errorBox:addLabel():setText(errorLabels[2] or ""):setTextAlign("center"):setPosition("parent.w * 0.5 - self.w * 0.5 + 1", 5)
    errorBox:addButton():setText("CONFIRM"):setBackground(colors.green):setPosition("parent.w / 2 - self.w / 2", "parent.h - self.h"):onClick(function() errorBox:hide() mainFrame:show() end)
end
