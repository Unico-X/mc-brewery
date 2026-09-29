-- Winery-wide service configuration.
local WINERY = {
    TASK_MONITOR_ADDRESS = "monitor_76",

    -- Kept separate from program files so a restart can restore the queue.
    TASK_STORAGE_PATH = "inventory/tasks.db",
    TASK_EVENT = "winery_task_created",
}

return WINERY
