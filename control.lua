local ok, Util = pcall(require, "Util")
if not ok then
    ok, Util = pcall(require, "inventory.Util")
end
<<<<<<< HEAD
 
if not ok then
    error("control_brewey: cannot load Util.lua", 0)
end
 
 
 
local Control = {}
 
 
=======

if not ok then
    error("control_brewey: cannot load Util.lua", 0)
end



local Control = {}


>>>>>>> 157d389 (添加遍历所有物品的工具函数)
local function wrapPeripheral(value, name)
    if type(value) == "string" then
        local wrapped = peripheral.wrap(value)
        if not wrapped then
            error(("control_brewey: cannot find peripheral '%s' for %s"):format(value, name), 3)
        end
        return wrapped
    end
<<<<<<< HEAD
 
    if type(value) ~= "table" then
        error(("control_brewey: %s must be a peripheral object or address string"):format(name), 3)
    end
 
    return value
end
 
=======

    if type(value) ~= "table" then
        error(("control_brewey: %s must be a peripheral object or address string"):format(name), 3)
    end

    return value
end

>>>>>>> 157d389 (添加遍历所有物品的工具函数)
local function assertInventoryAddress(value, name)
    if type(value) ~= "string" or value == "" then
        error(("control_brewey: %s must be a non-empty inventory address string"):format(name), 3)
    end
<<<<<<< HEAD
 
    return value
end
 
local function readBreweyOpen(breweyObject)
    local data = breweyObject.getBlockData()
 
    if type(data) ~= "table" then
        error("control_brewey: brewey.getBlockData() did not return a table", 3)
    end
 
    return data.open == 1
end
 
=======

    return value
end

local function readBreweyOpen(breweyObject)
    local data = breweyObject.getBlockData()

    if type(data) ~= "table" then
        error("control_brewey: brewey.getBlockData() did not return a table", 3)
    end

    return data.open == 1
end

>>>>>>> 157d389 (添加遍历所有物品的工具函数)
local function waitBreweyOpenState(breweyObject, expectedOpen)
    while readBreweyOpen(breweyObject) ~= expectedOpen do
        os.sleep(0.1)
    end
end
<<<<<<< HEAD
 
=======

>>>>>>> 157d389 (添加遍历所有物品的工具函数)
local function setBreweyOpen(switchOpenObject, breweyObject, shouldOpen)
    if type(switchOpenObject.rotate) ~= "function" then
        error("control_brewey: switchOpen must provide rotate(degrees)", 3)
    end
<<<<<<< HEAD
 
    if readBreweyOpen(breweyObject) == shouldOpen then
        return
    end
 
    switchOpenObject.rotate(360)
    waitBreweyOpenState(breweyObject, shouldOpen)
end
 
local function isInventoryEmpty(inventoryAddress, name)
    local inventory = wrapPeripheral(inventoryAddress, name)
 
    if type(inventory.list) ~= "function" then
        error(("control_brewey: %s is not an inventory"):format(name), 3)
    end
 
    return next(inventory.list()) == nil
end
 
=======

    if readBreweyOpen(breweyObject) == shouldOpen then
        return
    end

    switchOpenObject.rotate(360)
    waitBreweyOpenState(breweyObject, shouldOpen)
end

local function isInventoryEmpty(inventoryAddress, name)
    local inventory = wrapPeripheral(inventoryAddress, name)

    if type(inventory.list) ~= "function" then
        error(("control_brewey: %s is not an inventory"):format(name), 3)
    end

    return next(inventory.list()) == nil
end

>>>>>>> 157d389 (添加遍历所有物品的工具函数)
local function pulseOpenSwitch2(relay)
    if type(relay.rotate) ~= "function" then
        error("control_brewey: openSwitch2 must provide rotate(degrees)", 3)
    end
<<<<<<< HEAD
 
    relay.rotate(360)
    os.sleep(0.8)
end
 
=======

    relay.rotate(360)
    os.sleep(0.8)
end

>>>>>>> 157d389 (添加遍历所有物品的工具函数)
local function feedUntilInputBoxEmpty(inputBoxAddress, openSwitch2Object)
    while not isInventoryEmpty(inputBoxAddress, "inputBox") do
        pulseOpenSwitch2(openSwitch2Object)
    end
end
<<<<<<< HEAD
 
local function hasBreweyOutput(breweyObject)
    local data = breweyObject.getBlockData()
 
    if type(data) ~= "table" then
        error("control_brewey: brewey.getBlockData() did not return a table", 3)
    end
 
=======

local function hasBreweyOutput(breweyObject)
    local data = breweyObject.getBlockData()

    if type(data) ~= "table" then
        error("control_brewey: brewey.getBlockData() did not return a table", 3)
    end

>>>>>>> 157d389 (添加遍历所有物品的工具函数)
    local output = data.Output
    if type(output) ~= "table" then
        return output ~= nil
    end
<<<<<<< HEAD
 
    return next(output) ~= nil
end
 
=======

    return next(output) ~= nil
end

>>>>>>> 157d389 (添加遍历所有物品的工具函数)
local function getRecipeIngredient(ingredient)
    if type(ingredient) ~= "table" then
        error("control_brewey: ingredient must be a table", 3)
    end
<<<<<<< HEAD
 
    local itemName = ingredient[1]
    local amount = ingredient[2]
 
    if type(itemName) ~= "string" or itemName == "" then
        error("control_brewey: ingredient item name is required", 3)
    end
 
    if type(amount) ~= "number" or amount <= 0 or amount ~= math.floor(amount) then
        error(("control_brewey: invalid amount for ingredient '%s'"):format(itemName), 3)
    end
 
    return itemName, amount
end
 
=======

    local itemName = ingredient[1]
    local amount = ingredient[2]

    if type(itemName) ~= "string" or itemName == "" then
        error("control_brewey: ingredient item name is required", 3)
    end

    if type(amount) ~= "number" or amount <= 0 or amount ~= math.floor(amount) then
        error(("control_brewey: invalid amount for ingredient '%s'"):format(itemName), 3)
    end

    return itemName, amount
end

>>>>>>> 157d389 (添加遍历所有物品的工具函数)
local function buildConfig(selectedRecipe, liquidSource, ingredientSource, targetInputBox, openSwitch, targetBrewey, secondOpenSwitch)
    return {
        recipe = selectedRecipe or recipe or (RECIPE and RECIPE[1]),
        liquidBox = liquidSource or liquidBox,
        ingredientBox = ingredientSource or ingredientBox,
        inputBox = targetInputBox or inputBox,
        switchOpen = openSwitch or switchOpen,
        brewey = targetBrewey or brewey,
        openSwitch2 = secondOpenSwitch or openSwitch2,
    }
end
<<<<<<< HEAD
 
=======

>>>>>>> 157d389 (添加遍历所有物品的工具函数)
function Control.control_brewey(selectedRecipe, liquidSource, ingredientSource, targetInputBox, openSwitch, targetBrewey, openSwitch2Value, _probeBoxValue)
    local config = buildConfig(
        selectedRecipe,
        liquidSource,
        ingredientSource,
        targetInputBox,
        openSwitch,
        targetBrewey,
        openSwitch2Value
    )
<<<<<<< HEAD
 
=======

>>>>>>> 157d389 (添加遍历所有物品的工具函数)
    local recipeItem = config.recipe
    if type(recipeItem) ~= "table" then
        error("control_brewey: recipe is required", 2)
    end
<<<<<<< HEAD
 
=======

>>>>>>> 157d389 (添加遍历所有物品的工具函数)
    local liquidBoxAddress = assertInventoryAddress(config.liquidBox, "liquidBox")
    local ingredientBoxAddress = assertInventoryAddress(config.ingredientBox, "ingredientBox")
    local inputBoxAddress = assertInventoryAddress(config.inputBox, "inputBox")
    local switchOpenObject = wrapPeripheral(config.switchOpen, "switchOpen")
    local breweyObject = wrapPeripheral(config.brewey, "brewey")
    local openSwitch2Object = wrapPeripheral(config.openSwitch2, "openSwitch2")
<<<<<<< HEAD
 
    if type(breweyObject.getBlockData) ~= "function" then
        error("control_brewey: brewey must provide getBlockData()", 2)
    end
 
    if type(recipeItem.liquid) ~= "string" or recipeItem.liquid == "" then
        error("control_brewey: recipe.liquid is required", 2)
    end
 
=======

    if type(breweyObject.getBlockData) ~= "function" then
        error("control_brewey: brewey must provide getBlockData()", 2)
    end

    if type(recipeItem.liquid) ~= "string" or recipeItem.liquid == "" then
        error("control_brewey: recipe.liquid is required", 2)
    end

>>>>>>> 157d389 (添加遍历所有物品的工具函数)
    local liquidAmount = recipeItem.liquid_amount
    if type(liquidAmount) ~= "number" or liquidAmount <= 0 or liquidAmount ~= math.floor(liquidAmount) then
        error("control_brewey: recipe.liquid_amount must be a positive integer", 2)
    end
<<<<<<< HEAD
 
    local ingredients = recipeItem.ingredients or {}
    local lidOpened = false
 
    local function run()
        setBreweyOpen(switchOpenObject, breweyObject, true)
        lidOpened = true
 
        Util.Transit(liquidBoxAddress, inputBoxAddress, recipeItem.liquid, liquidAmount)
        feedUntilInputBoxEmpty(inputBoxAddress, openSwitch2Object)
 
=======

    local ingredients = recipeItem.ingredients or {}
    local lidOpened = false

    local function run()
        setBreweyOpen(switchOpenObject, breweyObject, true)
        lidOpened = true

        Util.Transit(liquidBoxAddress, inputBoxAddress, recipeItem.liquid, liquidAmount)
        feedUntilInputBoxEmpty(inputBoxAddress, openSwitch2Object)

>>>>>>> 157d389 (添加遍历所有物品的工具函数)
        for _, ingredient in ipairs(ingredients) do
            local itemName, amount = getRecipeIngredient(ingredient)
            Util.Transit(ingredientBoxAddress, inputBoxAddress, itemName, amount)
            feedUntilInputBoxEmpty(inputBoxAddress, openSwitch2Object)
        end
<<<<<<< HEAD
 
        setBreweyOpen(switchOpenObject, breweyObject, false)
        lidOpened = false
 
        os.sleep(0.5)
        if not hasBreweyOutput(breweyObject) then
            error("control_brewey: brewey Output is empty after feeding", 2)
        end
 
        return true
    end
 
=======

        setBreweyOpen(switchOpenObject, breweyObject, false)
        lidOpened = false

        os.sleep(5)
        if not hasBreweyOutput(breweyObject) then
            error("control_brewey: brewey Output is empty after feeding", 2)
        end

        return true
    end

>>>>>>> 157d389 (添加遍历所有物品的工具函数)
    local success, result = pcall(run)
    if not success then
        if lidOpened then
            pcall(setBreweyOpen, switchOpenObject, breweyObject, false)
        end
        error(result, 2)
    end
<<<<<<< HEAD
 
    return result
end
 
control_brewey = Control.control_brewey
 
return Control
=======

    return result
end

control_brewey = Control.control_brewey

return Control
>>>>>>> 157d389 (添加遍历所有物品的工具函数)
