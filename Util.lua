
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

local function wrapInventoryForQuery(address)
    if type(address) ~= "string" or address == "" then
        error("Query: inventory address must be a non-empty string", 3)
    end

    local inventory = peripheral.wrap(address)
    if not inventory then
        error(("Query: cannot find peripheral '%s'"):format(address), 3)
    end

    if type(inventory.list) ~= "function" or type(inventory.size) ~= "function" then
        error(("Query: peripheral '%s' is not an inventory"):format(address), 3)
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

function Util.Query(inventoryAddress, itemName)
    if type(itemName) ~= "string" or itemName == "" then
        error("Query: item name must be a non-empty string", 2)
    end

    local inventory = wrapInventoryForQuery(inventoryAddress)
    local items = inventory.list()
    local total = 0

    for slot = 1, inventory.size() do
        local item = items[slot]
        if item and item.name == itemName then
            total = total + item.count
        end
    end

    return total
end

return Util
