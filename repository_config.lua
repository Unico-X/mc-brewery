local REPOSITORY = {
FLUID = {
    {
        id = 1,
        
        address = "fluidTank_167",

        fluid = "kaleidoscope_tavern:green_grape_juice",

        capacity = 2160000
    },

    {
        id = 2,
        
        address = "fluidTank_166",

        fluid = "kaleidoscope_tavern:grape_juice",

        capacity = 2160000
    },

    {
        id = 3,
        
        address = "fluidTank_165",

        fluid = "kaleidoscope_tavern:gold_grape_juice",

        capacity = 2160000
    },

    {
        id = 4,

        address = "fluidTank_164",

        fluid = "kaleidoscope_tavern:ice_grape_juice",

        capacity = 2160000
    }
},

RESOURCE = {

    address = "create:item_vault_665",

    grape_capacityLimit = 34560,

    grape_type = {

        "kaleidoscope_tavern:grape",
        "kaleidoscope_tavern:green_grape",
        "kaleidoscope_tavern:ice_grape",
        "kaleidoscope_tavern:gold_grape"
    }


},


RESOURCE_PACKAGE_RULE = {

    green_grape = {
        name = "kaleidoscope_tavern:green_grape",
        _requestCount = 64,
        count = {
            _op = ">",
            value = 128,
        }
    },

    gold_grape = {
        name = "kaleidoscope_tavern:gold_grape",
        _requestCount = 64,
        count = {
            _op = ">",
            value = 128,
        }
    },

    ice_grape = {
        name = "kaleidoscope_tavern:ice_grape",
        _requestCount = 64,
        count = {
            _op = ">",
            value = 128,
        }
    },

    grape = {
        name = "kaleidoscope_tavern:grape",
        _requestCount = 64,
        count = {
            _op = ">",
            value = 128,
        }
    },
},

RESOURCE_REQUIRER = peripheral.wrap("Create_StockTicker_14"),

RESOURCE_ADDRESS = "winery"


}

return REPOSITORY