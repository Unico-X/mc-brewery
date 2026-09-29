--[[
    Task creation service.

    Run with: shell.run("taskService")

    Other services can wait for the configured event:
      local _, task = os.pullEvent("winery_task_created")
]]

local TaskService = {}

local function loadConfig()
    local ok, config = pcall(require, "winery_config")
    if not ok then
        error("taskService: cannot load winery_config: " .. tostring(config), 0)
    end
    if type(config) ~= "table" then
        error("taskService: winery_config must return a table", 0)
    end
    return config
end

local function copyTask(task)
    return {
        taskid = task.taskid,
        wine = task.wine,
        count = task.count,
        status = task.status,
        user = task.user,
        createdAt = task.createdAt,
    }
end

local function readState(path)
    if not fs.exists(path) then
        return { nextTaskId = 0, tasks = {} }
    end

    local file = fs.open(path, "r")
    if not file then
        error("taskService: cannot open task storage for reading: " .. path, 0)
    end
    local encoded = file.readAll()
    file.close()

    local state = textutils.unserialize(encoded)
    if type(state) ~= "table" or type(state.nextTaskId) ~= "number" or type(state.tasks) ~= "table" then
        error("taskService: task storage is invalid: " .. path, 0)
    end
    return state
end

local function writeState(path, state)
    local directory = fs.getDir(path)
    if directory ~= "" and not fs.exists(directory) then
        fs.makeDir(directory)
    end

    local file = fs.open(path, "w")
    if not file then
        error("taskService: cannot open task storage for writing: " .. path, 0)
    end

    local ok, err = pcall(function()
        file.write(textutils.serialize(state))
    end)
    file.close()
    if not ok then
        error("taskService: cannot persist task storage: " .. tostring(err), 0)
    end
end

local function asInteger(value, field, minimum)
    local number = tonumber(value)
    if not number or number ~= math.floor(number) or number < minimum then
        return nil, ("%s must be an integer greater than or equal to %d"):format(field, minimum)
    end
    return number
end

local function getMonitor(address)
    if type(address) ~= "string" or address == "" then
        error("taskService: winery_config.TASK_MONITOR_ADDRESS is required", 0)
    end
    local monitor = peripheral.wrap(address)
    if not monitor or type(monitor.write) ~= "function" then
        error("taskService: TASK_MONITOR_ADDRESS is not a monitor: " .. address, 0)
    end
    return monitor
end

local function show(monitor, lines)
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.white)
    monitor.clear()
    monitor.setCursorPos(1, 1)
    for _, line in ipairs(lines) do
        monitor.write(line)
        local _, height = monitor.getSize()
        local x, y = monitor.getCursorPos()
        if y < height then
            monitor.setCursorPos(1, y + 1)
        elseif x > 1 then
            break
        end
    end
end

local function drawKey(monitor, x, y, width, label, background)
    monitor.setBackgroundColor(background)
    monitor.setTextColor(colors.white)
    monitor.setCursorPos(x, y)
    monitor.write(string.rep(" ", width))
    local labelX = x + math.floor((width - #label) / 2)
    monitor.setCursorPos(labelX, y)
    monitor.write(label)
end

local function drawNumberPad(monitor, label, value, message)
    local width = monitor.getSize()
    local keyWidth = math.max(3, math.floor((width - 4) / 3))
    local padWidth = keyWidth * 3 + 2
    local left = math.max(1, math.floor((width - padWidth) / 2) + 1)
    local firstRow = 5
    local keys = {
        { "1", "2", "3" },
        { "4", "5", "6" },
        { "7", "8", "9" },
        { "", "0", "ENTER" },
    }

    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.white)
    monitor.clear()
    monitor.setCursorPos(1, 1)
    monitor.write("Winery task service")
    monitor.setCursorPos(1, 2)
    monitor.write(label)
    monitor.setCursorPos(1, 3)
    monitor.setTextColor(colors.yellow)
    monitor.write(value == "" and "_" or value)
    monitor.setTextColor(colors.white)
    monitor.setCursorPos(1, 4)
    monitor.write(message or "Tap digits, then ENTER")

    for row, labels in ipairs(keys) do
        for column, key in ipairs(labels) do
            local x = left + (column - 1) * (keyWidth + 1)
            if key ~= "" then
                drawKey(monitor, x, firstRow + row - 1, keyWidth, key,
                    key == "ENTER" and colors.green or colors.gray)
            end
        end
    end

    return {
        left = left,
        keyWidth = keyWidth,
        firstRow = firstRow,
    }
end

local function numberAtKeypad(layout, x, y)
    local row = y - layout.firstRow + 1
    if row < 1 or row > 4 then
        return nil
    end

    for column = 1, 3 do
        local left = layout.left + (column - 1) * (layout.keyWidth + 1)
        if x >= left and x < left + layout.keyWidth then
            local keys = {
                { "1", "2", "3" },
                { "4", "5", "6" },
                { "7", "8", "9" },
                { "", "0", "ENTER" },
            }
            return keys[row][column]
        end
    end
    return nil
end

local function readNumberFromMonitor(monitor, address, label, minimum)
    local value = ""
    local message

    while true do
        local layout = drawNumberPad(monitor, label, value, message)
        local _, touchedAddress, x, y = os.pullEvent("monitor_touch")
        if touchedAddress == address then
            local key = numberAtKeypad(layout, x, y)
            if key == "ENTER" then
                local number, reason = asInteger(value, label, minimum)
                if number then
                    return number
                end
                message = reason
            elseif key and key ~= "" then
                value = value .. key
                message = nil
            end
        end
    end
end

function TaskService.create(state, storagePath, wine, count, eventName)
    local task = {
        taskid = state.nextTaskId,
        wine = wine,
        count = count,
        status = "pending",
        -- Touch monitors do not reveal the player who touched them.  Until an
        -- authentication peripheral is added, the service is the source.
        user = "system",
        createdAt = os.epoch and os.epoch("utc") or os.time(),
    }

    -- Persist the task and its next id before announcing it.  A listener can
    -- therefore always reload the task after receiving the event.
    state.tasks[#state.tasks + 1] = task
    state.nextTaskId = state.nextTaskId + 1
    writeState(storagePath, state)
    os.queueEvent(eventName, copyTask(task))
    return task
end

function TaskService.run()
    local config = loadConfig()
    local monitor = getMonitor(config.TASK_MONITOR_ADDRESS)
    local storagePath = config.TASK_STORAGE_PATH or "tasks.db"
    local eventName = config.TASK_EVENT or "winery_task_created"
    local state = readState(storagePath)

    while true do
        local wine = readNumberFromMonitor(monitor, config.TASK_MONITOR_ADDRESS, "Wine type (0 or greater)", 0)
        local count = readNumberFromMonitor(monitor, config.TASK_MONITOR_ADDRESS, "Count (1 or greater)", 1)

        local ok, taskOrError = pcall(TaskService.create, state, storagePath, wine, count, eventName)
        if ok then
            local task = taskOrError
            show(monitor, {
                "Task persisted and announced",
                ("ID: %d  Wine: %d  Count: %d"):format(task.taskid, task.wine, task.count),
                "Status: " .. task.status,
                "",
                "Touch display to create another task...",
            })
        else
            show(monitor, { "Task was not created:", tostring(taskOrError), "Touch display to retry..." })
        end
        os.pullEvent("monitor_touch")
    end
end

if ... == nil then
    TaskService.run()
end

return TaskService
