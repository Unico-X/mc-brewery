CRAFTAPI = {}
    
    local Util = require("Util")
    local MAX_COUNT_BOTTLE = 4096
    local MIN_COUNT_BOTTLE = 1024
    local SIGNAL_CRAFT = false 
    local ADDRESS_BOTTLE = "create:item_vault_409"
    local ADDRESS_TURTLE = "turtle_161"
    local BOTTLE_NAME = "kaleidoscope_tavern:bottle"
    local GLASS_NAME = "minecraft:glass"
    local GLASS_PER_INPUT_SLOT = 5
    local INPUT_SLOTS = { 5, 7, 10 }
    local OUTPUT_SLOTS = { 6, 16 }

    local function returnToBottleVault(sourceSlot, itemName, count)
        local remaining = count

        while remaining > 0 do
            local stack = turtle.getItemDetail(sourceSlot)
            local before = stack and stack.count or 0
            local selectedSlot = turtle.getSelectedSlot()

            turtle.select(sourceSlot)
            local ok, dropped = pcall(turtle.drop, remaining)
            turtle.select(selectedSlot)

            local afterStack = turtle.getItemDetail(sourceSlot)
            local after = afterStack and afterStack.count or 0
            local moved = before - after

            if not ok then
                error(dropped, 3)
            end

            if not dropped or moved <= 0 then
                error(
                    ("craft: only returned %d of %d '%s' to '%s'"):format(
                        count - remaining,
                        count,
                        itemName,
                        ADDRESS_BOTTLE
                    ),
                    3
                )
            end

            remaining = remaining - moved
        end
    end

    -- Recover a partial batch left in the turtle after its chunk or computer was unloaded.
    -- Keep at most one five-glass stack in each crafting slot, clear produced or invalid
    -- items to the bottle vault, and refill any missing glass before crafting resumes.
    local function recoverCraftingBatch()
        local retainedGlass = {}
        local hasPartialBatch = false

        for _, inputSlot in ipairs(INPUT_SLOTS) do
            local stack = turtle.getItemDetail(inputSlot)
            if stack and type(stack.name) == "string" and type(stack.count) == "number" and stack.count > 0 then
                if stack.name == GLASS_NAME then
                    hasPartialBatch = true
                    retainedGlass[inputSlot] = math.min(stack.count, GLASS_PER_INPUT_SLOT)

                    local excess = stack.count - retainedGlass[inputSlot]
                    if excess > 0 then
                        returnToBottleVault(inputSlot, GLASS_NAME, excess)
                    end
                else
                    returnToBottleVault(inputSlot, stack.name, stack.count)
                end
            else
                retainedGlass[inputSlot] = 0
            end
        end

        for _, outputSlot in ipairs(OUTPUT_SLOTS) do
            local stack = turtle.getItemDetail(outputSlot)
            if stack and type(stack.name) == "string" and type(stack.count) == "number" and stack.count > 0 then
                returnToBottleVault(outputSlot, stack.name, stack.count)
            end
        end

        if not hasPartialBatch then
            return false
        end

        for _, inputSlot in ipairs(INPUT_SLOTS) do
            local retained = retainedGlass[inputSlot] or 0
            if retained < GLASS_PER_INPUT_SLOT then
                Util.Transit(
                    ADDRESS_BOTTLE,
                    ADDRESS_TURTLE,
                    GLASS_NAME,
                    GLASS_PER_INPUT_SLOT - retained,
                    inputSlot
                )
            end
        end

        return true
    end

    local function checkAmount()
          
        local bottle_count = Util.count(BOTTLE_NAME,ADDRESS_BOTTLE)

            if bottle_count < MIN_COUNT_BOTTLE then
                
                 SIGNAL_CRAFT = false

                 redstone.setOutput("back",false)

                 
            end

            if bottle_count > MAX_COUNT_BOTTLE then
                
                SIGNAL_CRAFT = true

                redstone.setOutput("back",true)

            end
    end

    local function craftBatch()
        turtle.select(6)
        sleep(0.5)
        turtle.craft()
        turtle.select(16)
        sleep(0.5)
        turtle.craft()
        sleep(0.5)
        turtle.drop(64)
    end

    local function loadAndCraftBatch()
        if Util.count(GLASS_NAME, ADDRESS_BOTTLE) > 15 then
            for _, inputSlot in ipairs(INPUT_SLOTS) do
                Util.Transit(ADDRESS_BOTTLE, ADDRESS_TURTLE, GLASS_NAME, GLASS_PER_INPUT_SLOT, inputSlot)
            end

            craftBatch()
        end
    end

    -- Finish a batch interrupted by chunk unloading before loading a new one.
    if recoverCraftingBatch() then
        craftBatch()
    end

    while true do
        checkAmount()

        if not SIGNAL_CRAFT then
            loadAndCraftBatch()
        end
    end
