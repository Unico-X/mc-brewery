local MILKING = require("milking")
local Util = require("Util")
local REPOSITORY = require("repository_config")

local source = peripheral.wrap(REPOSITORY.RESOURCE.address)
print(("source: %s, slots: %d"):format(REPOSITORY.RESOURCE.address, source.size()))
for slot, item in pairs(source.list()) do
    print(("slot %d: %s x%d"):format(slot, item.name, item.count))
end

for _, grapeName in ipairs(REPOSITORY.RESOURCE.grape_type) do
    print(("%s: %d"):format(grapeName, Util.count(grapeName, REPOSITORY.RESOURCE.address)))
end

local processed = MILKING.milking()
print(("milking: completed %d batch(es)"):format(processed))
