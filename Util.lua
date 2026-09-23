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
 
 
 
function Util.Transit(fromAddress, toAddress, itemName, count)
 
    if type(itemName) ~= "string" or itemName == "" then
 
        error("Transit: item name must be a non-empty string", 2)
 
    end
 
 
 
    if type(count) ~= "number" or count <= 0 or count ~= math.floor(count) then
 
        error("Transit: count must be a positive integer", 2)
 
    end
 
 
 
    local fromInventory = wrapInventory(fromAddress, "source")
 
    local toInventory = wrapInventory(toAddress, "target")
 
    local sourceItems = fromInventory.list()
 
    local available = 0
 
 
 
    for slot = 1, fromInventory.size() do
 
        local item = sourceItems[slot]
 
        if item and item.name == itemName then
 
            available = available + item.count
 
        end
 
    end
 
 
 
    if available < count then
 
        error(
 
            ("Transit: not enough '%s' in '%s', need %d, found %d"):format(
 
                itemName,
 
                fromAddress,
 
                count,
 
                available
 
            ),
 
            2
 
        )
 
    end
 
 
 
    local targetItems = toInventory.list()
 
    local emptySlots = {}
 
    local emptyCapacity = 0
 
 
 
    for slot = 1, toInventory.size() do
 
        if targetItems[slot] == nil then
 
            emptySlots[#emptySlots + 1] = slot
 
            if type(toInventory.getItemLimit) == "function" then
 
                emptyCapacity = emptyCapacity + toInventory.getItemLimit(slot)
 
            end
 
        end
 
    end
 
 
 
    if #emptySlots == 0 then
 
        error(("Transit: no empty slots in '%s'"):format(toAddress), 2)
 
    end
 
 
 
    if type(toInventory.getItemLimit) == "function" and emptyCapacity < count then
 
        error(
 
            ("Transit: not enough empty capacity in '%s', need %d, found %d"):format(
 
                toAddress,
 
                count,
 
                emptyCapacity
 
            ),
 
            2
 
        )
 
    end
 
 
 
    local remaining = count
 
    local transferred = 0
 
    local targetIndex = 1
 
 
 
    for sourceSlot = 1, fromInventory.size() do
 
        local item = sourceItems[sourceSlot]
 
        if remaining <= 0 then
 
            break
 
        end
 
 
 
        if item and item.name == itemName then
 
            local sourceRemaining = item.count
 
 
 
            while sourceRemaining > 0 and remaining > 0 and targetIndex <= #emptySlots do
 
                local targetSlot = emptySlots[targetIndex]
 
                local limit = math.min(sourceRemaining, remaining)
 
                local moved = fromInventory.pushItems(toAddress, sourceSlot, limit, targetSlot)
 
 
 
                if moved <= 0 then
 
                    targetIndex = targetIndex + 1
 
                else
 
                    sourceRemaining = sourceRemaining - moved
 
                    remaining = remaining - moved
 
                    transferred = transferred + moved
 
 
 
                    local targetItem = toInventory.getItemDetail and toInventory.getItemDetail(targetSlot)
 
                    if targetItem and targetItem.maxCount and targetItem.count >= targetItem.maxCount then
 
                        targetIndex = targetIndex + 1
 
                    end
 
                end
 
            end
 
        end
 
    end
 
 
 
    if remaining > 0 then
 
        error(
 
            ("Transit: only transferred %d of %d '%s' to '%s'"):format(
 
                transferred,
 
                count,
 
                itemName,
 
                toAddress
 
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
