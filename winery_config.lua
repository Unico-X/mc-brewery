-- Winery-wide service configuration.
local WINERY = {
    TASK_MONITOR_ADDRESS = "monitor_76",

    -- Kept separate from program files so a restart can restore the queue.
    TASK_STORAGE_PATH = "inventory/tasks.db",
    TASK_EVENT = "winery_task_created",


    WINERY_MACHINE = {

        {

            BUFFER_BOX = "create:deployer_168",
            SWITCH_OPEN = "Create_SequencedGearshift_21",
            SWITCH_BUFFER = "Create_SequencedGearshift_22",
            MACHINE_ADDRESS = "blockReader_20",

            ID = 1,
            NAME = "winery-01",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_BOX = "create:deployer_169",
                SWITCH_PUSH = "Create_SequencedGearshift_23",
                SWITCH_OPEN = "Create_SequencedGearshift_12",
                SWITCH_PULL = "Create_SequencedGearshift_24"
            }

        },
        {

            BUFFER_BOX = "create:deployer_170",
            SWITCH_OPEN = "Create_SequencedGearshift_25",
            SWITCH_BUFFER = "Create_SequencedGearshift_26",
            MACHINE_ADDRESS = "blockReader_21",

            ID = 2,
            NAME = "winery-02",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_BOX = "create:deployer_171",
                SWITCH_PUSH = "Create_SequencedGearshift_14",
                SWITCH_OPEN = "Create_SequencedGearshift_27",
                SWITCH_PULL = "Create_SequencedGearshift_28"
            }
        },
        {

            BUFFER_BOX = "create:deployer_172",
            SWITCH_OPEN = "Create_SequencedGearshift_29",
            SWITCH_BUFFER = "Create_SequencedGearshift_30",
            MACHINE_ADDRESS = "blockReader_22",

            ID = 3,
            NAME = "winery-03",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_BOX = "create:deployer_173",
                SWITCH_PUSH = "Create_SequencedGearshift_31",
                SWITCH_OPEN = "Create_SequencedGearshift_13",
                SWITCH_PULL = "Create_SequencedGearshift_32"
            }
        },
        {

            BUFFER_BOX = "create:deployer_174",
            SWITCH_OPEN = "Create_SequencedGearshift_33",
            SWITCH_BUFFER = "Create_SequencedGearshift_34",
            MACHINE_ADDRESS = "blockReader_23",

            ID = 4,
            NAME = "winery-04",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_BOX = "create:deployer_175",
                SWITCH_PUSH = "Create_SequencedGearshift_36",
                SWITCH_OPEN = "Create_SequencedGearshift_35",
                SWITCH_PULL = "Create_SequencedGearshift_37"
            }
        },
        {

            BUFFER_BOX = "create:deployer_176",
            SWITCH_OPEN = "Create_SequencedGearshift_38",
            SWITCH_BUFFER = "Create_SequencedGearshift_39",
            MACHINE_ADDRESS = "blockReader_24",

            ID = 5,
            NAME = "winery-05",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_BOX = "create:deployer_177",
                SWITCH_PUSH = "Create_SequencedGearshift_40",
                SWITCH_OPEN = "Create_SequencedGearshift_15",
                SWITCH_PULL = "Create_SequencedGearshift_41"
            }
        },
        {
            BUFFER_BOX = "create:deployer_178",
            SWITCH_OPEN = "Create_SequencedGearshift_42",
            SWITCH_BUFFER = "Create_SequencedGearshift_43",
            MACHINE_ADDRESS = "blockReader_25",

            ID = 6,
            NAME = "winery-06",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_BOX = "create:deployer_179",
                SWITCH_PUSH = "Create_SequencedGearshift_45",
                SWITCH_OPEN = "Create_SequencedGearshift_44",
                SWITCH_PULL = "Create_SequencedGearshift_46"
            }
        },
        {
            BUFFER_BOX = "create:deployer_180",
            SWITCH_OPEN = "Create_SequencedGearshift_48",
            SWITCH_BUFFER = "Create_SequencedGearshift_47",
            MACHINE_ADDRESS = "blockReader_26",

            ID = 7,
            NAME = "winery-07",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_BOX = "create:deployer_181",
                SWITCH_PUSH = "Create_SequencedGearshift_50",
                SWITCH_OPEN = "Create_SequencedGearshift_49",
                SWITCH_PULL = "Create_SequencedGearshift_51"
            }
        },
        {
            BUFFER_BOX = "create:deployer_182",
            SWITCH_OPEN = "Create_SequencedGearshift_52",
            SWITCH_BUFFER = "Create_SequencedGearshift_53",
            MACHINE_ADDRESS = "blockReader_28",

            ID = 8,
            NAME = "winery-08",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_BOX = "create:deployer_183",
                SWITCH_PUSH = "Create_SequencedGearshift_54",
                SWITCH_OPEN = "Create_SequencedGearshift_55",
                SWITCH_PULL = "Create_SequencedGearshift_56"
            }
        },
        {
            BUFFER_BOX = "create:deployer_184",
            SWITCH_OPEN = "Create_SequencedGearshift_57",
            SWITCH_BUFFER = "Create_SequencedGearshift_58",
            MACHINE_ADDRESS = "blockReader_27",

            ID = 9,
            NAME = "winery-09",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_BOX = "create:deployer_185",
                SWITCH_PUSH = "Create_SequencedGearshift_59",
                SWITCH_OPEN = "Create_SequencedGearshift_60",
                SWITCH_PULL = "Create_SequencedGearshift_61"
            }
        },
        {
            BUFFER_BOX = "create:deployer_186",
            SWITCH_OPEN = "Create_SequencedGearshift_62",
            SWITCH_BUFFER = "Create_SequencedGearshift_63",
            MACHINE_ADDRESS = "blockReader_29",

            ID = 10,
            NAME = "winery-10",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_BOX = "create:deployer_187",
                SWITCH_PUSH = "Create_SequencedGearshift_64",
                SWITCH_OPEN = "Create_SequencedGearshift_65",
                SWITCH_PULL = "Create_SequencedGearshift_66"
            }
        },
        {
            BUFFER_BOX = "create:deployer_188",
            SWITCH_OPEN = "Create_SequencedGearshift_67",
            SWITCH_BUFFER = "Create_SequencedGearshift_68",
            MACHINE_ADDRESS = "blockReader_30",

            ID = 11,
            NAME = "winery-11",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_BOX = "create:deployer_189",
                SWITCH_PUSH = "Create_SequencedGearshift_69",
                SWITCH_OPEN = "Create_SequencedGearshift_70",
                SWITCH_PULL = "Create_SequencedGearshift_71"
            }
        },
        {
            BUFFER_BOX = "create:deployer_190",
            SWITCH_OPEN = "Create_SequencedGearshift_72",
            SWITCH_BUFFER = "Create_SequencedGearshift_73",
            MACHINE_ADDRESS = "blockReader_31",

            ID = 12,
            NAME = "winery-12",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_BOX = "create:deployer_191",
                SWITCH_PUSH = "Create_SequencedGearshift_74",
                SWITCH_OPEN = "Create_SequencedGearshift_75",
                SWITCH_PULL = "Create_SequencedGearshift_76"
            }
        },
        {
            BUFFER_BOX = "create:deployer_192",
            SWITCH_OPEN = "Create_SequencedGearshift_17",
            SWITCH_BUFFER = "Create_SequencedGearshift_77",
            MACHINE_ADDRESS = "blockReader_32",

            ID = 13,
            NAME = "winery-13",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_BOX = "create:deployer_193",
                SWITCH_PUSH = "Create_SequencedGearshift_78",
                SWITCH_OPEN = "Create_SequencedGearshift_79",
                SWITCH_PULL = "Create_SequencedGearshift_19"
            }
        },
        {
            BUFFER_BOX = "create:deployer_194",
            SWITCH_OPEN = "Create_SequencedGearshift_80",
            SWITCH_BUFFER = "Create_SequencedGearshift_81",
            MACHINE_ADDRESS = "blockReader_33",

            ID = 14,
            NAME = "winery-14",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_BOX = "create:deployer_195",
                SWITCH_PUSH = "Create_SequencedGearshift_82",
                SWITCH_OPEN = "Create_SequencedGearshift_83",
                SWITCH_PULL = "Create_SequencedGearshift_84"
            }
        },
        {
            BUFFER_BOX = "create:deployer_196",
            SWITCH_OPEN = "Create_SequencedGearshift_85",
            SWITCH_BUFFER = "Create_SequencedGearshift_86",
            MACHINE_ADDRESS = "blockReader_34",

            ID = 15,
            NAME = "winery-15",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_BOX = "create:deployer_197",
                SWITCH_PUSH = "Create_SequencedGearshift_87",
                SWITCH_OPEN = "Create_SequencedGearshift_88",
                SWITCH_PULL = "Create_SequencedGearshift_89"
            }
        },
        {
            BUFFER_BOX = "create:deployer_198",
            SWITCH_OPEN = "Create_SequencedGearshift_90",
            SWITCH_BUFFER = "Create_SequencedGearshift_16",
            MACHINE_ADDRESS = "blockReader_35",

            ID = 16,
            NAME = "winery-16",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_BOX = "create:deployer_199",
                SWITCH_PUSH = "Create_SequencedGearshift_91",
                SWITCH_OPEN = "Create_SequencedGearshift_92",
                SWITCH_PULL = "Create_SequencedGearshift_18"
            }
        },
    },
    INJECTOR = {
           OUTPUT_BUFFER = "minecraft:chest_357",

           INPUT_BUFFER = {
                        
                        {
                           INVENTORY = "minecraft:chest_352",
                           FLUID = "create:spout_97"
                        },
                        {
                           INVENTORY = "minecraft:chest_353",
                           FLUID = "create:spout_98"
                        },
                        {
                           INVENTORY = "minecraft:chest_354",
                           FLUID = "create:spout_99"
                        },
                        {
                           INVENTORY = "minecraft:chest_355",
                           FLUID = "create:spout_100"
                        },
                        {
                           INVENTORY = "minecraft:chest_356",
                           FLUID = "create:spout_101"
                        }

           }
    }
}

return WINERY
