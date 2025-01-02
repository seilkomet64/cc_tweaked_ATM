local function fancyButton(btn)
    local originalBG = btn:getBackground()
    btn:onClick(function(self) btn:setBackground(colors.lightGray) end)
    btn:onClickUp(function(self) btn:setBackground(originalBG) end)
    btn:onLoseFocus(function(self) btn:setBackground(originalBG) end)
end

return fancyButton