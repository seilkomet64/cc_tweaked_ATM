return function(mainFrame, wrapperFrame, labels, args)
    local acceptBox = wrapperFrame:addMovableFrame():setSize("parent.w * 0.8", "parent.h * 0.8"):setPosition("parent.w * 0.1 + 1", 2):setBorder(colors.black)
    acceptBox:addLabel():setText("Confirm"):setPosition("parent.w * 0.5 - self.w * 0.5 + 1", 2):setForeground(colors.red)
    acceptBox:addLabel():setText(labels[1]):setTextAlign("center"):setPosition("parent.w * 0.5 - self.w * 0.5 + 1", 4)
    acceptBox:addLabel():setText(labels[2]):setTextAlign("center"):setPosition("parent.w * 0.5 - self.w * 0.5 + 1", 5)
    acceptBox:addButton():setText("CONFIRM"):setBackground(colors.green):setPosition("parent.w / 2 - self.w / 2", "parent.h - self.h"):onClick(function() ChangeScreen(SCREENS.mainScreen, nil, {acc = args.acc}) end):setFocus()

    local function listenKeyInputs()
        while true do
            local event, key, is_held = os.pullEvent("key")
            if key == keys.enter then
                ChangeScreen(SCREENS.mainScreen, nil, {acc = args.acc})
                break
            end
        end
    end

    local thread = acceptBox:addThread()
    thread:start(listenKeyInputs)
end
