local Util = {}
 
 
 
local function wrapInventory(address, label)
 
    if type(address) ~= "string" or address == "" then
 
        error(("Transit: %s address must be a non-empty string"):format(label), 3)
 
    end
 
 
 
    local inventory = peripheral.wrap(address)
 
    if not inventory then
 
        error(("Transit: cannot find peripheral '%s'"):format(address), 3)
 
    end
 
 
 
    if type(inventory.list) ~= "function" or
 
        type(inventory.size) ~= "function" or
 
        type(inventory.pushItems) ~= "function" then
 
        error(("Transit: peripheral '%s' is not an inventory"):format(address), 3)
 
    end
 
 
 
    return inventory
 
end
 
 
 
function Util.Transit(from, to, item, count, slot)
 
    if type(item) ~= "string" or item == "" then
 
        error("Transit: item name must be a non-empty string", 2)
 
    end
 
 
 
    if type(count) ~= "number" or count <= 0 or count ~= math.floor(count) then
 
        error("Transit: count must be a positive integer", 2)
 
    end
 
    if type(slot) ~= "number" or slot <= 0 or slot ~= math.floor(slot) then

        error("Transit: slot must be a positive integer", 2)

    end

 
 
    local fromInventory = wrapInventory(from, "source")
 
    local sourceItems = fromInventory.list()
 
    local available = 0
 
 
 
    for slot = 1, fromInventory.size() do
 
        local sourceItem = sourceItems[slot]
 
        if sourceItem and sourceItem.name == item then
 
            available = available + sourceItem.count
 
        end
 
    end
 
 
 
    if available < count then
 
        error(
 
            ("Transit: not enough '%s' in '%s', need %d, found %d"):format(
 
                item,
 
                from,
 
                count,
 
                available
 
            ),
 
            2
 
        )
 
    end
 
 
 
    local remaining = count
 
    local transferred = 0
 
 
 
    for sourceSlot = 1, fromInventory.size() do
 
        local sourceItem = sourceItems[sourceSlot]
 
        if remaining <= 0 then
 
            break
 
        end
 
 
 
        if sourceItem and sourceItem.name == item then
 
            local sourceRemaining = sourceItem.count
 
 
 
            while sourceRemaining > 0 and remaining > 0 do
 
                local limit = math.min(sourceRemaining, remaining)
 
                local moved = fromInventory.pushItems(to, sourceSlot, limit, slot)
 
 
 
                if moved <= 0 then
 
                    break
 
                else
 
                    sourceRemaining = sourceRemaining - moved
 
                    remaining = remaining - moved
 
                    transferred = transferred + moved
 
 
                end
 
            end
 
        end
 
    end
 
 
 
    if remaining > 0 then
 
        error(
 
            ("Transit: only transferred %d of %d '%s' to '%s'"):format(
 
                transferred,
 
                count,
 
                item,
 
                to
 
            ),
 
            2
 
        )
 
    end
 
 
 
    return transferred
 
end
 
function Util.count(inventory, address)
 
    if type(inventory) ~= "string" or inventory == "" then
 
        error("Count: inventory must be a non-empty string", 2)
 
    end
 
 
 
    local targetInventory = wrapInventory(address, "inventory")
 
    local items = targetInventory.list()
 
    local total = 0
 
 
 
    for slot = 1, targetInventory.size() do
 
        local item = items[slot]
 
        if item and item.name == inventory then
 
            total = total + item.count
 
        end
 
    end
 
 
 
    return total
 
end

local function wrapFluidStorage(address, label)
 
    if type(address) ~= "string" or address == "" then
 
        error(("TransitFluid: %s address must be a non-empty string"):format(label), 3)
 
    end
 
 
 
    local storage = peripheral.wrap(address)
 
    if not storage then
 
        error(("TransitFluid: cannot find peripheral '%s'"):format(address), 3)
 
    end
 
 
 
    if type(storage.tanks) ~= "function" or type(storage.pushFluid) ~= "function" then
 
        error(("TransitFluid: peripheral '%s' is not a fluid storage"):format(address), 3)
 
    end
 
 
 
    return storage
 
end
 
function Util.TransitFluid(fromAddress, toAddress, amount, fluidName)
 
    if type(amount) ~= "number" or amount <= 0 or amount ~= math.floor(amount) then
 
        error("TransitFluid: amount must be a positive integer", 2)
 
    end
 
 
 
    if fluidName ~= nil and (type(fluidName) ~= "string" or fluidName == "") then
 
        error("TransitFluid: fluid name must be a non-empty string", 2)
 
    end
 
 
 
    local fromStorage = wrapFluidStorage(fromAddress, "source")
 
    wrapFluidStorage(toAddress, "target")
 
 
 
    local available = 0
 
    for _, tank in pairs(fromStorage.tanks()) do
 
        if tank and type(tank.amount) == "number" and
            (fluidName == nil or tank.name == fluidName) then
 
            available = available + tank.amount
 
        end
 
    end
 
 
 
    if available < amount then
 
        local description = fluidName or "fluid"
 
        error(
 
            ("TransitFluid: not enough '%s' in '%s', need %d, found %d"):format(
 
                description,
 
                fromAddress,
 
                amount,
 
                available
 
            ),
 
            2
 
        )
 
    end
 
 
 
    local moved = fromStorage.pushFluid(toAddress, amount, fluidName)
 
    local movedAmount = type(moved) == "number" and moved or 0
 
    if movedAmount < amount then
 
        error(
 
            ("TransitFluid: only transferred %d of %d from '%s' to '%s'"):format(
 
                movedAmount,
 
                amount,
 
                fromAddress,
 
                toAddress
 
            ),
 
            2
 
        )
 
    end
 
 
 
    return moved
 
end
 
 
return Util
