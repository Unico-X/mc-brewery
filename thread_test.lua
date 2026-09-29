local Milking = require("milking")
local Requirer = require("resource_request")

parallel.waitForAll(
    function()
        Milking.milking()
    end,
    function()
        Requirer.requestResource()
    end
)
