local RECIPE = require("recipe_config")
local firstSwitch = peripheral.wrap("Create_SequencedGearshift_9")
local gather = require("gather")
local source_box = "minecraft:chest_37"
local targetMachineBox = "create:deployer_73"
local openSwitch = peripheral.wrap("Create_SequencedGearshift_10")
local secondSwitch = peripheral.wrap("Create_SequencedGearshift_11")
local targetBrewey = peripheral.wrap("blockReader_1")
<<<<<<< HEAD
local bottleAmount = 2
local bottleItemName = "kaleidoscope_tavern:empty_bottle"
 
=======
local bottleAmount = 3
local bottleItemName = "kaleidoscope_tavern:empty_bottle"

>>>>>>> 157d389 (添加遍历所有物品的工具函数)
gather.gather(RECIPE[1], 
        source_box, 
        targetMachineBox,
        firstSwitch,
        openSwitch,
        secondSwitch,
        targetBrewey,
        bottleAmount,
<<<<<<< HEAD
        bottleItemName)
=======
        bottleItemName)
>>>>>>> 157d389 (添加遍历所有物品的工具函数)
