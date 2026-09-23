local REQUIRER = {}

local Util = require("Util")

local REPOSITORY = require("repository_config")

 function REQUIRER.requestResource()
     
     local grape_green = Util.count("kaleidoscope_tavern:green_grape",REPOSITORY.RESOURCE.address)

     local grape = Util.count("kaleidoscope_tavern:grape",REPOSITORY.RESOURCE.address)

     local grape_gold = Util.count("kaleidoscope_tavern:gold_grape",REPOSITORY.RESOURCE.address)

     local grape_ice = Util.count("kaleidoscope_tavern:ice_grape",REPOSITORY.RESOURCE.address)

     while 1 do
        
        if( grape_gold + grape_green + grape + grape_ice < REPOSITORY.RESOURCE.grape_capacityLimit) then
            
            REPOSITORY.RESOURCE_REQUIRER.requestFiltered(REPOSITORY.RESOURCE_ADDRESS,
            REPOSITORY.RESOURCE_PACKAGE_RULE.grape,
            REPOSITORY.RESOURCE_PACKAGE_RULE.green_grape,
            REPOSITORY.RESOURCE_PACKAGE_RULE.ice_grape,
            REPOSITORY.RESOURCE_PACKAGE_RULE.gold_grape            
        )

        os.sleep(1)

        end
     end
end

return REQUIRER