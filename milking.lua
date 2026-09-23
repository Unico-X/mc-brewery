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
        while true do
            local machinePlans
            machinePlans, batches = prepareBatches()
            activeMachinePlans = machinePlans
            if #batches == 0 then
                break
            end

            local workers = {}
            for _, machinePlan in ipairs(machinePlans) do
                if #machinePlan.batches > 0 then
                    local plan = machinePlan
                    workers[#workers + 1] = function()
                        runMachine(plan, fluidTargets)
                    end
                end
            end

            parallel.waitForAll(unpackValues(workers))
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
