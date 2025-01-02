local dropper = peripheral.find("minecraft:dropper")
local digitizer = peripheral.find("digitizer")

-- Check how much of an Item is inside the dropper
local function getCurrency(itemName)
    local total = 0
    for slot, item in pairs(dropper.list()) do
        if item.name == itemName then
            total = total + item.count
        end
    end

    return total
end

-- Check if an amount of items can still fit
local function canFit(itemName, amountToPush, stackSize)
    local fitableAmount = 0
    for i = 1, dropper.size() do
        local item = dropper.getItemDetail(i)
        if item == nil then fitableAmount = fitableAmount + stackSize
        elseif item.name == itemName then fitableAmount = fitableAmount + (stackSize - item.count) end
    end

    return fitableAmount >= amountToPush
end

local function digitizeAllItems(itemName)
    local digitizedIds = {}
    for slot, item in pairs(dropper.list()) do
        if item.name == itemName then
            dropper.pushItems(peripheral.getName(digitizer), slot)
            digitizedIds[#digitizedIds+1] = digitizer.digitize()
        end
    end

    return digitizedIds
end

local function materializeItems(digitizedIds)
    local count = 0
    for _, id in ipairs(digitizedIds) do
        local success, item = pcall(function() return digitizer.getIDInfo(id).item end)
        if not success then return end

        while not canFit(item.name, item.count, CONFIG.CURRENCYSTACKSIZE) do
            os.sleep(1)
        end
        count = count + item.count

        digitizer.rematerialize(id)
        digitizer.pushItems(peripheral.getName(dropper), 1)
    end

    return count
end

return {getCurrency = getCurrency, canFit = canFit, digitizeAllItems = digitizeAllItems, materializeItems = materializeItems}

