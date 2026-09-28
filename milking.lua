local Util = require("Util")
local MILKING = require("milking_config")
local REPOSITORY = require("repository_config")

local Milking = {}

local GRAPES_PER_BATCH = 8
local PRESS_COUNT = 8
local PULSE_SECONDS = 0.2
local SWITCH_INTERVAL_SECONDS = 1
local DEFAULT_RELAY_SIDE = "front"
local unpackValues = table.unpack or unpack

local function wrapFluidStorage(address, label)
    if type(address) ~= "string" or address == "" then
        error(("milking: %s address must be a non-empty string"):format(label), 3)
    end

    local storage = peripheral.wrap(address)
    if not storage then
        error(("milking: cannot find peripheral '%s'"):format(address), 3)
    end

    if type(storage.tanks) ~= "function" then
        error(("milking: peripheral '%s' is not a fluid storage"):format(address), 3)
    end

    return storage
end

local function wrapRelay(address)
    if type(address) ~= "string" or address == "" then
        error("milking: machine switch must be a non-empty string", 3)
    end

    local relay = peripheral.wrap(address)
    if not relay then
        error(("milking: cannot find relay '%s'"):format(address), 3)
    end

    if type(relay.setOutput) ~= "function" then
        error(("milking: peripheral '%s' is not a redstone relay"):format(address), 3)
    end

    return relay
end

local function buildFluidTargets()
    local targets = {}

    for _, fluid in ipairs(REPOSITORY.FLUID or {}) do
        if type(fluid.fluid) ~= "string" or fluid.fluid == "" then
            error("milking: each fluid repository requires a fluid name", 3)
        end

        if type(fluid.address) ~= "string" or fluid.address == "" then
            error(("milking: fluid repository '%s' requires an address"):format(fluid.fluid), 3)
        end

        if targets[fluid.fluid] then
            error(("milking: duplicate repository for fluid '%s'"):format(fluid.fluid), 3)
        end

        targets[fluid.fluid] = fluid.address
    end

    return targets
end

local function getAvailableGrapes()
    local resource = REPOSITORY.RESOURCE
    if type(resource) ~= "table" or type(resource.address) ~= "string" or resource.address == "" then
        error("milking: REPOSITORY.RESOURCE.address must be a non-empty string", 3)
    end

    if type(resource.grape_type) ~= "table" then
        error("milking: REPOSITORY.RESOURCE.grape_type must be a table", 3)
    end

    local available = {}
    local grapeTypes = {}

    for _, grapeName in ipairs(resource.grape_type) do
        if type(grapeName) ~= "string" or grapeName == "" then
            error("milking: each grape type must be a non-empty string", 3)
        end

        grapeTypes[#grapeTypes + 1] = grapeName
        available[grapeName] = Util.count(grapeName, resource.address)
    end

    return resource.address, grapeTypes, available
end

local function getRecoveryGrapes()
    local resource = REPOSITORY.RESOURCE
    if type(resource) ~= "table" or type(resource.address) ~= "string" or resource.address == "" then
        error("milking: REPOSITORY.RESOURCE.address must be a non-empty string", 3)
    end

    if type(resource.grape_type) ~= "table" then
        error("milking: REPOSITORY.RESOURCE.grape_type must be a table", 3)
    end

    local grapeTypes = {}
    local grapes = {}
    for _, grapeName in ipairs(resource.grape_type) do
        if type(grapeName) ~= "string" or grapeName == "" then
            error("milking: each grape type must be a non-empty string", 3)
        end

        grapeTypes[#grapeTypes + 1] = grapeName
        grapes[grapeName] = true
    end

    return resource.address, grapeTypes, grapes
end

local function selectGrape(slot, grapeTypes, available)
    if type(slot.batch) == "string" and available[slot.batch] and
        available[slot.batch] > GRAPES_PER_BATCH then
        return slot.batch
    end

    for _, grapeName in ipairs(grapeTypes) do
        if available[grapeName] > GRAPES_PER_BATCH then
            return grapeName
        end
    end

    return nil
end

local function prepareBatches()
    local resourceAddress, grapeTypes, available = getAvailableGrapes()
    local machinePlans = {}
    local batches = {}

    for _, machine in ipairs(MILKING.MACHINE or {}) do
        if type(machine.slot) ~= "table" then
            error("milking: each machine requires a slot table", 3)
        end

        local machinePlan = { machine = machine, batches = {} }
        machinePlans[#machinePlans + 1] = machinePlan

        for _, slot in ipairs(machine.slot) do
            if slot.status == nil or slot.status == "idle" then
                if type(slot.address) ~= "string" or slot.address == "" then
                    error("milking: each slot requires an address", 3)
                end

                local grapeName = selectGrape(slot, grapeTypes, available)
                if grapeName then
                    available[grapeName] = available[grapeName] - GRAPES_PER_BATCH

                    local batch = {
                        slot = slot,
                        grape = grapeName,
                        machinePlan = machinePlan,
                    }

                    slot.status = "loading"
                    machinePlan.batches[#machinePlan.batches + 1] = batch
                    batches[#batches + 1] = batch
                end
            end
        end
    end

    for _, batch in ipairs(batches) do
        Util.Transit(resourceAddress, batch.slot.address, batch.grape, GRAPES_PER_BATCH)
        batch.slot.status = "pressing"
    end

    return machinePlans, batches
end

local function pulseMachine(machine)
    local relay = wrapRelay(machine.switch)
    local side = machine.side or machine.output_side or DEFAULT_RELAY_SIDE

    if type(side) ~= "string" or side == "" then
        error("milking: machine relay side must be a non-empty string", 3)
    end

    local outputOn = false
    local ok, result = pcall(function()
        for _ = 1, PRESS_COUNT do
            relay.setOutput(side, true)
            outputOn = true
            os.sleep(PULSE_SECONDS)
            relay.setOutput(side, false)
            outputOn = false
            os.sleep(SWITCH_INTERVAL_SECONDS)
        end
    end)

    if outputOn then
        pcall(relay.setOutput, side, false)
    end

    if not ok then
        error(result, 2)
    end
end

local function switchMachineOff(machine)
    local relay = peripheral.wrap(machine.switch)
    local side = machine.side or machine.output_side or DEFAULT_RELAY_SIDE

    if relay and type(relay.setOutput) == "function" and type(side) == "string" and side ~= "" then
        pcall(relay.setOutput, side, false)
    end
end

local function drainSlot(slot, fluidTargets)
    local storage = wrapFluidStorage(slot.address, "slot")

    for _, tank in pairs(storage.tanks()) do
        if tank and type(tank.name) == "string" and type(tank.amount) == "number" and tank.amount > 0 then
            local targetAddress = fluidTargets[tank.name]
            if not targetAddress then
                error(("milking: no repository configured for fluid '%s'"):format(tank.name), 3)
            end

            Util.TransitFluid(slot.address, targetAddress, tank.amount, tank.name)
        end
    end
end

local function wrapSlotInventory(address)
    if type(address) ~= "string" or address == "" then
        error("milking: slot address must be a non-empty string", 3)
    end

    local inventory = peripheral.wrap(address)
    if not inventory or type(inventory.list) ~= "function" or type(inventory.size) ~= "function" then
        error(("milking: peripheral '%s' is not an inventory"):format(address), 3)
    end

    return inventory
end

-- Util.Transit intentionally writes only to empty target slots.  A recovered
-- pressing tub already has its one item slot occupied, so topping it up needs
-- to push into that matching slot explicitly.
local function topUpRecoveredGrapes(resourceAddress, slotAddress, grapeName, count)
    if count <= 0 then
        return
    end

    local resource = wrapSlotInventory(resourceAddress)
    if type(resource.pushItems) ~= "function" then
        error(("milking: resource '%s' cannot push items"):format(resourceAddress), 3)
    end

    local tub = wrapSlotInventory(slotAddress)
    local targetSlot
    for index, item in pairs(tub.list()) do
        if item and item.name == grapeName and item.count > 0 then
            targetSlot = index
            break
        end
    end

    if not targetSlot then
        error(("milking: recovered tub '%s' has no '%s' slot"):format(slotAddress, grapeName), 3)
    end

    local remaining = count
    for sourceSlot = 1, resource.size() do
        if remaining <= 0 then
            break
        end

        local item = resource.list()[sourceSlot]
        if item and item.name == grapeName and item.count > 0 then
            local moved = resource.pushItems(slotAddress, sourceSlot, remaining, targetSlot)
            if type(moved) == "number" and moved > 0 then
                remaining = remaining - moved
            end
        end
    end

    if remaining > 0 then
        error(
            ("milking: only added %d of %d '%s' to recovered tub '%s'"):format(
                count - remaining,
                count,
                grapeName,
                slotAddress
            ),
            3
        )
    end
end

-- Recover items left in a pressing tub after the computer or its chunk was unloaded.
-- A tub can only press one grape variety at a time: retain one variety (up to one
-- batch), return anything else to the resource vault, then fill the batch to eight.
local function recoverSlot(slot, resourceAddress, grapeTypes, grapes, fluidTargets)
    drainSlot(slot, fluidTargets)

    local inventory = wrapSlotInventory(slot.address)
    local items = inventory.list()
    local grapeCounts = {}

    for index = 1, inventory.size() do
        local item = items[index]
        if item and type(item.name) == "string" and type(item.count) == "number" and item.count > 0 then
            if grapes[item.name] then
                grapeCounts[item.name] = (grapeCounts[item.name] or 0) + item.count
            else
                Util.Transit(slot.address, resourceAddress, item.name, item.count)
            end
        end
    end

    local grapeName
    if type(slot.batch) == "string" and grapeCounts[slot.batch] then
        grapeName = slot.batch
    else
        for _, name in ipairs(grapeTypes) do
            if grapeCounts[name] then
                grapeName = name
                break
            end
        end
    end

    if not grapeName then
        return nil
    end

    -- Mixed varieties cannot form one valid batch, so retain the selected type only.
    for _, name in ipairs(grapeTypes) do
        local count = grapeCounts[name] or 0
        if name ~= grapeName and count > 0 then
            Util.Transit(slot.address, resourceAddress, name, count)
        end
    end

    local retained = math.min(grapeCounts[grapeName], GRAPES_PER_BATCH)
    local excess = grapeCounts[grapeName] - retained
    if excess > 0 then
        Util.Transit(slot.address, resourceAddress, grapeName, excess)
    end

    if retained < GRAPES_PER_BATCH then
        topUpRecoveredGrapes(resourceAddress, slot.address, grapeName, GRAPES_PER_BATCH - retained)
    end

    return {
        slot = slot,
        grape = grapeName,
    }
end

local function prepareRecoveryBatches(fluidTargets)
    local resourceAddress, grapeTypes, grapes = getRecoveryGrapes()
    local machinePlans = {}
    local batches = {}

    for _, machine in ipairs(MILKING.MACHINE or {}) do
        if type(machine.slot) ~= "table" then
            error("milking: each machine requires a slot table", 3)
        end

        local machinePlan = { machine = machine, batches = {} }
        machinePlans[#machinePlans + 1] = machinePlan

        for _, slot in ipairs(machine.slot) do
            local batch = recoverSlot(slot, resourceAddress, grapeTypes, grapes, fluidTargets)
            if batch then
                batch.machinePlan = machinePlan
                slot.status = "pressing"
                machinePlan.batches[#machinePlan.batches + 1] = batch
                batches[#batches + 1] = batch
            else
                slot.status = "idle"
            end
        end
    end

    return machinePlans, batches
end

local function runMachine(machinePlan, fluidTargets)
    if #machinePlan.batches == 0 then
        return
    end

    pulseMachine(machinePlan.machine)

    for _, batch in ipairs(machinePlan.batches) do
        drainSlot(batch.slot, fluidTargets)
        batch.slot.status = "idle"
    end
end

local function runMachinePlans(machinePlans, fluidTargets)
    local workers = {}
    for _, machinePlan in ipairs(machinePlans) do
        if #machinePlan.batches > 0 then
            local plan = machinePlan
            workers[#workers + 1] = function()
                runMachine(plan, fluidTargets)
            end
        end
    end

    if #workers > 0 then
        parallel.waitForAll(unpackValues(workers))
    end
end

local function resetBatches(batches)
    if not batches then
        return
    end

    for _, batch in ipairs(batches) do
        batch.slot.status = "idle"
    end
end

function Milking.milking()
    local fluidTargets = buildFluidTargets()
    local activeMachinePlans
    local batches
    local processed = 0

    local ok, result = pcall(function()
        activeMachinePlans, batches = prepareRecoveryBatches(fluidTargets)
        if #batches > 0 then
            runMachinePlans(activeMachinePlans, fluidTargets)
            processed = processed + #batches
        end
        batches = nil
        activeMachinePlans = nil

        while true do
            local machinePlans
            machinePlans, batches = prepareBatches()
            activeMachinePlans = machinePlans
            if #batches == 0 then
                break
            end

            runMachinePlans(machinePlans, fluidTargets)
            processed = processed + #batches
            batches = nil
            activeMachinePlans = nil
        end
    end)

    if not ok then
        for _, machinePlan in ipairs(activeMachinePlans or {}) do
            switchMachineOff(machinePlan.machine)
        end

        resetBatches(batches)
        error(result, 2)
    end

    return processed
end


return Milking
