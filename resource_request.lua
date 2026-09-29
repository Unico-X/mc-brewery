local REQUIRER = {}

local Util = require("Util")

local REPOSITORY = require("repository_config")

local function updateGrapeRequestState(itemName, active, minimum, maximum, address)
    local count = Util.count(itemName, address)

    if active then
        if count > maximum then
            return false
        end
    elseif count < minimum then
        return true
    end

    return active
end

function REQUIRER.requestResource()
    local resource = REPOSITORY.RESOURCE
    local grapeMin = resource.grape_capacityLimit_min
    local grapeMax = resource.grape_capacityLimit_max

    if type(grapeMin) ~= "number" or type(grapeMax) ~= "number" or grapeMin < 0 or grapeMin > grapeMax then
        error("resource_request: invalid grape_capacityLimit_min/max", 2)
    end

    local grapeRequestActive = {
        grape = false,
        green_grape = false,
        ice_grape = false,
        gold_grape = false,
    }

     local sand = Util.count("minecraft:sand",REPOSITORY.RESOURCE.glass_address)

     while 1 do
        os.sleep(0.5)
        local requestedGrape = false

        grapeRequestActive.grape = updateGrapeRequestState(
            "kaleidoscope_tavern:grape",
            grapeRequestActive.grape,
            grapeMin,
            grapeMax,
            resource.address
        )
        if grapeRequestActive.grape then
            REPOSITORY.RESOURCE_REQUIRER.requestFiltered(
                REPOSITORY.RESOURCE_ADDRESS,
                REPOSITORY.RESOURCE_PACKAGE_RULE.grape
            )
            requestedGrape = true
        end

        grapeRequestActive.green_grape = updateGrapeRequestState(
            "kaleidoscope_tavern:green_grape",
            grapeRequestActive.green_grape,
            grapeMin,
            grapeMax,
            resource.address
        )
        if grapeRequestActive.green_grape then
            REPOSITORY.RESOURCE_REQUIRER.requestFiltered(
                REPOSITORY.RESOURCE_ADDRESS,
                REPOSITORY.RESOURCE_PACKAGE_RULE.green_grape
            )
            requestedGrape = true
        end

        grapeRequestActive.ice_grape = updateGrapeRequestState(
            "kaleidoscope_tavern:ice_grape",
            grapeRequestActive.ice_grape,
            grapeMin,
            grapeMax,
            resource.address
        )
        if grapeRequestActive.ice_grape then
            REPOSITORY.RESOURCE_REQUIRER.requestFiltered(
                REPOSITORY.RESOURCE_ADDRESS,
                REPOSITORY.RESOURCE_PACKAGE_RULE.ice_grape
            )
            requestedGrape = true
        end

        grapeRequestActive.gold_grape = updateGrapeRequestState(
            "kaleidoscope_tavern:gold_grape",
            grapeRequestActive.gold_grape,
            grapeMin,
            grapeMax,
            resource.address
        )
        if grapeRequestActive.gold_grape then
            REPOSITORY.RESOURCE_REQUIRER.requestFiltered(
                REPOSITORY.RESOURCE_ADDRESS,
                REPOSITORY.RESOURCE_PACKAGE_RULE.gold_grape
            )
            requestedGrape = true
        end

        if requestedGrape then
            os.sleep(1)
        end

        sand = Util.count("minecraft:sand",REPOSITORY.RESOURCE.glass_address)

        if(sand < REPOSITORY.RESOURCE.sand_capacityLimit) then  

            REPOSITORY.RESOURCE_REQUIRER.requestFiltered(REPOSITORY.RESOURCE_ADDRESS,REPOSITORY.RESOURCE_PACKAGE_RULE.sand)
            Util.Transit(REPOSITORY.RESOURCE.address,REPOSITORY.RESOURCE.glass_address,"minecraft:sand",64)
            os.sleep(1)
        end

        
     end
end

return REQUIRER
