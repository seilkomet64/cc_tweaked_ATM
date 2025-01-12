local basalt = require("basalt")
local atmAPI = {}

peripheral.find("modem", rednet.open)
local protocol = "bank"
local bankServer

-- Wait for the bank server to be available
while not bankServer do
    bankServer = rednet.lookup(protocol, "bankController")
    print("No Bankserver found! Retrying in 1 second...")
    sleep(1)
end

-- message balance = {atmNumber, type, acc, pin}
-- message deposit = {atmNumber, type, acc, amount, pin}
-- message withdraw = {atmNumber, type, acc, amount, pin}
-- message transfer = {atmNumber, type, acc, amount, targetAcc, pin}

-- @returns {success, balance}
function atmAPI.balance(acc, pin)
    rednet.send(bankServer, {atmNumber = os.getComputerID(), type = "balance", acc = acc, pin = pin}, protocol)

    local senderID, message = rednet.receive(protocol, 5)

    -- Handle failure to receive a message
    if not message then
        error("Failed to contact the server!")

    -- If there's a specific error
    elseif message.error then
        if message.error == "Incorrect Pin" then
            error("Error: Incorrect PIN entered.")
        else
            -- Handle unexpected errors (if any)
            error(message.error)
        end
    end

    return message.balance
end

-- @returns {success, balance}
function atmAPI.deposit(acc, digitalIDs, pin)
    rednet.send(bankServer, {atmNumber = os.getComputerID(), type = "deposit", acc = acc, ids = digitalIDs, pin = pin}, protocol)
    local senderID, message = rednet.receive(protocol, 10)

    -- Handle failure to receive a message
    if not message then
        error("Failed to contact the server!")

    -- If there's a specific error
    elseif message.error then
        if message.error == "Incorrect Pin" then
            error("Error: Incorrect PIN entered.")
        else
            -- Handle unexpected errors (if any)
            error(message.error)
        end
    end

    -- Return the balance on success
    return message.balance
end

-- @returns {balance, ids}
function atmAPI.withdraw(acc, amount, pin)
    rednet.send(bankServer, {atmNumber = os.getComputerID(), type = "withdraw", acc = acc, amount = amount, pin = pin}, protocol)
    local senderID, message = rednet.receive(protocol, 20)

    -- Handle failure to receive a message
    if not message then
        error("Failed to contact the server!")
        
    -- If there's a specific error
    elseif message.error then
        if message.error == "Incorrect Pin" then
            error("Error: Incorrect PIN entered.")
        elseif message.error == "Insufficient Funds" then
            error("Error: Not enough funds to complete the transaction.")
        else
            -- Handle unexpected errors (if any)
            error(message.error)
        end
    end

    return message.balance, message.ids, message.transactionID
end

-- @returns {success, balance}
function atmAPI.transfer(acc, targetAcc, amount, pin)
    rednet.send(bankServer, {atmNumber = os.getComputerID(), type = "transfer", acc = acc, amount = amount, targetAcc = targetAcc, pin = pin}, protocol)
    local senderID, message = rednet.receive(protocol, 5)

    -- Handle failure to receive a message
    if not message then
        error("Failed to contact the server!")

    -- If there's a specific error
    elseif message.error then
        if message.error == "Incorrect Pin" then
            error("Error: Incorrect PIN entered.")
        else
            -- Handle unexpected errors (if any)
            error(message.error)
        end
    end

    return message.balance
end

-- @return boolean
function atmAPI.checkPin(acc, pin)
    rednet.send(bankServer, {atmNumber = os.getComputerID(), type = "checkPin", acc = acc, pin = pin}, protocol)
    local senderID, message = rednet.receive(protocol, 5)

    if message then
        return message.status
    else
        error("Failed to contact the server!")
    end
end

-- @return boolean
function atmAPI.existsAccount(acc)
    rednet.send(bankServer, {atmNumber = os.getComputerID(), type = "checkCard", acc = acc}, protocol)
    local senderID, message = rednet.receive(protocol, 5)

    if message then
        return message.status
    else
        error("Failed to contact the server!")
    end
end

function atmAPI.confirmWithdrawal(acc, transactionID)
    -- Attempt to send a confirmation message to the bank server
    -- If it does not reach it will not affect the user
    rednet.send(bankServer, {atmNumber = os.getComputerID(), type = "confirmTransaction", acc = acc, transactionID = transactionID}, protocol)
end

return atmAPI