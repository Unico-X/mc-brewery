local ok, Util = pcall(require, "Util")
if not ok then
    ok, Util = pcall(require, "inventory.Util")
end
 
if not ok then
    error("gather: cannot load Util.lua", 0)
end
 
local Gather = {}
 
local DEFAULT_BOTTLE_ITEM = "minecraft:glass_bottle"
 
local function wrapPeripheral(value, name)
    if type(value) == "string" then
        local wrapped = peripheral.wrap(value)
        if not wrapped then
            error(("gather: cannot find peripheral '%s' for %s"):format(value, name), 3)
        end
        return wrapped
    end
 
    if type(value) ~= "table" then
        error(("gather: %s must be a peripheral object or address string"):format(name), 3)
    end
 
    return value
end
 
local function assertInventoryAddress(value, name)
    if type(value) ~= "string" or value == "" then
        error(("gather: %s must be a non-empty inventory address string"):format(name), 3)
    end
 
    return value
end
 
local function assertPositiveInteger(value, name)
    if type(value) ~= "number" or value <= 0 or value ~= math.floor(value) then
        error(("gather: %s must be a positive integer"):format(name), 3)
    end
 
    return value
end
 
local function assertRotator(value, name)
    local object = wrapPeripheral(value, name)
 
    if type(object.rotate) ~= "function" then
        error(("gather: %s must provide rotate(degrees)"):format(name), 3)
    end
 
    return object
end
 
local function getTargetLevel(recipeItem)
    local targetLevel = recipeItem.TARGET_level
 
    if type(targetLevel) ~= "number" then
        error("gather: recipe.TARGET_level must be a number", 3)
    end
 
    return targetLevel
end
 
local function getBreweyData(breweyObject)
    if type(breweyObject.getBlockData) ~= "function" then
        error("gather: brewey must provide getBlockData()", 3)
    end
 
    local data = breweyObject.getBlockData()
 
    if type(data) ~= "table" then
        error("gather: brewey.getBlockData() did not return a table", 3)
    end
 
    return data
end
 
local function coerceLevel(value)
    if type(value) == "number" then
        return value
    end
 
    if type(value) == "string" then
        return tonumber(value)
    end
 
    return nil
end
 
local function readBreweyLevel(breweyObject)
    local data = getBreweyData(breweyObject)
 
    local candidateKeys = {
        "level",
        "Level",
        "stage",
        "Stage",
        "liquor_level",
        "LiquorLevel",
        "brew_level",
        "BrewLevel",
        "fermentation",
        "Fermentation",
    }
 
    for _, key in ipairs(candidateKeys) do
        local level = coerceLevel(data[key])
        if level ~= nil then
            return level
        end
    end
 
    for key, value in pairs(data) do
        if type(key) == "string" and string.find(string.lower(key), "level", 1, true) then
            local level = coerceLevel(value)
            if level ~= nil then
                return level
            end
        end
    end
 
    error("gather: cannot find numeric brewey level in block data", 3)
end
 
local function buildConfig(
    selectedRecipe,
    bottleSource,
    targetMachineBox,
    firstSwitch,
    openSwitch,
    secondSwitch,
    targetBrewey,
    bottleAmount,
    bottleItemName
)
    return {
        recipe = selectedRecipe or recipe or (RECIPE and RECIPE[1]),
        sourcebox_bottle = bottleSource or sourcebox_bottle,
        machine_box1 = targetMachineBox or machine_box1,
        machine_switch1 = firstSwitch or machine_switch1,
        machine_open = openSwitch or machine_open,
        machine_switch2 = secondSwitch or machine_switch2,
        brewey = targetBrewey or brewey or bewery,
        amount = bottleAmount or amount,
        bottle_item = bottleItemName or bottle_item or DEFAULT_BOTTLE_ITEM,
    }
end
 
function Gather.gather(
    selectedRecipe,
    bottleSource,
    targetMachineBox,
    firstSwitch,
    openSwitch,
    secondSwitch,
    targetBrewey,
    bottleAmount,
    bottleItemName
)
    local config = buildConfig(
        selectedRecipe,
        bottleSource,
        targetMachineBox,
        firstSwitch,
        openSwitch,
        secondSwitch,
        targetBrewey,
        bottleAmount,
        bottleItemName
    )
 
    local recipeItem = config.recipe
    if type(recipeItem) ~= "table" then
        error("gather: recipe is required", 2)
    end
 
    local targetLevel = getTargetLevel(recipeItem)
    local breweyObject = wrapPeripheral(config.brewey, "brewey")
 
    local currentLevel = readBreweyLevel(breweyObject)
    if currentLevel < targetLevel then
        return false, currentLevel
    end
 
    local sourceBoxBottleAddress = assertInventoryAddress(config.sourcebox_bottle, "sourcebox_bottle")
    local machineBox1Address = assertInventoryAddress(config.machine_box1, "machine_box1")
    local machineSwitch1Object = assertRotator(config.machine_switch1, "machine_switch1")
    local machineOpenObject = assertRotator(config.machine_open, "machine_open")
    local machineSwitch2Object = assertRotator(config.machine_switch2, "machine_switch2")
    local gatherAmount = assertPositiveInteger(config.amount, "amount")
 
    if type(config.bottle_item) ~= "string" or config.bottle_item == "" then
        error("gather: bottle_item must be a non-empty item name", 2)
    end
 
    Util.Transit(sourceBoxBottleAddress, machineBox1Address, config.bottle_item, gatherAmount)
 
    for _ = 1, gatherAmount do
        machineSwitch1Object.rotate(360)
        os.sleep(1)
        machineOpenObject.rotate(360)
        os.sleep(3)
        machineSwitch2Object.rotate(360)
        os.sleep(2)
    end
 
    return true, currentLevel
end
 
gather = Gather.gather
 
return Gather