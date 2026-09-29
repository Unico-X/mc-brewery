-- Winery-wide service configuration.
local WINERY = {
    TASK_MONITOR_ADDRESS = "monitor_76",

    -- Kept separate from program files so a restart can restore the queue.
    TASK_STORAGE_PATH = "inventory/tasks.db",
    TASK_EVENT = "winery_task_created",


    WINERY_MACHINE = {

        {

            BUFFER_BOX = "",
            SWITCH_OPEN = "",
            SWITCH_BUFFER = "",
            MACHINE_ADDRESS = "",

            ID = 1,
            NAME = "winery-01",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_SOURCE = "",
                BOTTLE_BOX = "",
                SWITCH_PUSH = "",
                SWITCH_OPEN = "",
                SWITCH_PULL = ""
            }

        },
        {

            BUFFER_BOX = "",
            SWITCH_OPEN = "",
            SWITCH_BUFFER = "",
            MACHINE_ADDRESS = "",

            ID = 2,
            NAME = "winery-02",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_SOURCE = "",
                BOTTLE_BOX = "",
                SWITCH_PUSH = "",
                SWITCH_OPEN = "",
                SWITCH_PULL = ""
            }
        },
        {

            BUFFER_BOX = "",
            SWITCH_OPEN = "",
            SWITCH_BUFFER = "",
            MACHINE_ADDRESS = "",

            ID = 3,
            NAME = "winery-03",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_SOURCE = "",
                BOTTLE_BOX = "",
                SWITCH_PUSH = "",
                SWITCH_OPEN = "",
                SWITCH_PULL = ""
            }
        },
        {

            BUFFER_BOX = "",
            SWITCH_OPEN = "",
            SWITCH_BUFFER = "",
            MACHINE_ADDRESS = "",

            ID = 4,
            NAME = "winery-04",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_SOURCE = "",
                BOTTLE_BOX = "",
                SWITCH_PUSH = "",
                SWITCH_OPEN = "",
                SWITCH_PULL = ""
            }
        },
        {

            BUFFER_BOX = "",
            SWITCH_OPEN = "",
            SWITCH_BUFFER = "",
            MACHINE_ADDRESS = "",

            ID = 5,
            NAME = "winery-05",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_SOURCE = "",
                BOTTLE_BOX = "",
                SWITCH_PUSH = "",
                SWITCH_OPEN = "",
                SWITCH_PULL = ""
            }
        },
        {

            BUFFER_BOX = "",
            SWITCH_OPEN = "",
            SWITCH_BUFFER = "",
            MACHINE_ADDRESS = "",

            ID = 6,
            NAME = "winery-06",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_SOURCE = "",
                BOTTLE_BOX = "",
                SWITCH_PUSH = "",
                SWITCH_OPEN = "",
                SWITCH_PULL = ""
            }
        },
        {

            BUFFER_BOX = "",
            SWITCH_OPEN = "",
            SWITCH_BUFFER = "",
            MACHINE_ADDRESS = "",

            ID = 7,
            NAME = "winery-07",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_SOURCE = "",
                BOTTLE_BOX = "",
                SWITCH_PUSH = "",
                SWITCH_OPEN = "",
                SWITCH_PULL = ""
            }
        },
        {

            BUFFER_BOX = "",
            SWITCH_OPEN = "",
            SWITCH_BUFFER = "",
            MACHINE_ADDRESS = "",

            ID = 8,
            NAME = "winery-08",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_SOURCE = "",
                BOTTLE_BOX = "",
                SWITCH_PUSH = "",
                SWITCH_OPEN = "",
                SWITCH_PULL = ""
            }
        },
        {

            BUFFER_BOX = "",
            SWITCH_OPEN = "",
            SWITCH_BUFFER = "",
            MACHINE_ADDRESS = "",

            ID = 9,
            NAME = "winery-09",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_SOURCE = "",
                BOTTLE_BOX = "",
                SWITCH_PUSH = "",
                SWITCH_OPEN = "",
                SWITCH_PULL = ""
            }
        },
        {

            BUFFER_BOX = "",
            SWITCH_OPEN = "",
            SWITCH_BUFFER = "",
            MACHINE_ADDRESS = "",

            ID = 10,
            NAME = "winery-10",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_SOURCE = "",
                BOTTLE_BOX = "",
                SWITCH_PUSH = "",
                SWITCH_OPEN = "",
                SWITCH_PULL = ""
            }
        },
        {

            BUFFER_BOX = "",
            SWITCH_OPEN = "",
            SWITCH_BUFFER = "",
            MACHINE_ADDRESS = "",

            ID = 11,
            NAME = "winery-11",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_SOURCE = "",
                BOTTLE_BOX = "",
                SWITCH_PUSH = "",
                SWITCH_OPEN = "",
                SWITCH_PULL = ""
            }
        },
        {

            BUFFER_BOX = "",
            SWITCH_OPEN = "",
            SWITCH_BUFFER = "",
            MACHINE_ADDRESS = "",

            ID = 12,
            NAME = "winery-12",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_SOURCE = "",
                BOTTLE_BOX = "",
                SWITCH_PUSH = "",
                SWITCH_OPEN = "",
                SWITCH_PULL = ""
            }
        },
        {

            BUFFER_BOX = "",
            SWITCH_OPEN = "",
            SWITCH_BUFFER = "",
            MACHINE_ADDRESS = "",

            ID = 13,
            NAME = "winery-13",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_SOURCE = "",
                BOTTLE_BOX = "",
                SWITCH_PUSH = "",
                SWITCH_OPEN = "",
                SWITCH_PULL = ""
            }
        },
        {

            BUFFER_BOX = "",
            SWITCH_OPEN = "",
            SWITCH_BUFFER = "",
            MACHINE_ADDRESS = "",

            ID = 14,
            NAME = "winery-14",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_SOURCE = "",
                BOTTLE_BOX = "",
                SWITCH_PUSH = "",
                SWITCH_OPEN = "",
                SWITCH_PULL = ""
            }
        },
        {

            BUFFER_BOX = "",
            SWITCH_OPEN = "",
            SWITCH_BUFFER = "",
            MACHINE_ADDRESS = "",

            ID = 15,
            NAME = "winery-15",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_SOURCE = "",
                BOTTLE_BOX = "",
                SWITCH_PUSH = "",
                SWITCH_OPEN = "",
                SWITCH_PULL = ""
            }
        },
        {

            BUFFER_BOX = "",
            SWITCH_OPEN = "",
            SWITCH_BUFFER = "",
            MACHINE_ADDRESS = "",

            ID = 16,
            NAME = "winery-16",
            STATUS = "IDLE",
            ENABLED = true,
            CURRENT_TASK_ID = false,
            CURRENT_WINE = false,
            UPDATED_AT = 0,
            ERROR_MESSAGE = false,

            GATHER = {
                BOTTLE_SOURCE = "",
                BOTTLE_BOX = "",
                SWITCH_PUSH = "",
                SWITCH_OPEN = "",
                SWITCH_PULL = ""
            }
        },
    }
}

return WINERY
