--[[
    Task creation service.

    Run with: shell.run("taskService")

    Other services can wait for the configured event:
      local _, task = os.pullEvent("winery_task_created")
]]

local TaskService = {}
local DIGIT_KEYS = {
    { "1", "2", "3", "4", "5", "CANCEL" },
    { "6", "7", "8", "9", "0", "ENTER" },
}

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

local function writeClipped(monitor, x, y, value)
    local width, height = monitor.getSize()
    if y < 1 or y > height or x > width then
        return
    end
    local text = tostring(value)
    if x < 1 then
        text = text:sub(2 - x)
        x = 1
    end
    monitor.setCursorPos(x, y)
    monitor.write(text:sub(1, width - x + 1))
end

local function show(monitor, lines)
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.white)
    monitor.clear()
    local _, height = monitor.getSize()
    for lineNumber, line in ipairs(lines) do
        if lineNumber > height then
            break
        end
        writeClipped(monitor, 1, lineNumber, line)
    end
end

local function drawKey(monitor, x, y, width, height, label, fillColor)
    -- A monitor character is taller than it is wide. The keypad therefore
    -- uses more character columns than rows to make buttons look square.
    local borderColor = colors.lightGray
    local innerWidth = width - 2
    monitor.setBackgroundColor(borderColor)
    monitor.setTextColor(colors.white)
    for row = 0, height - 1 do
        writeClipped(monitor, x, y + row, string.rep(" ", width))
    end
    if innerWidth > 0 and height > 2 then
        monitor.setBackgroundColor(fillColor)
        for row = 1, height - 2 do
            writeClipped(monitor, x + 1, y + row, string.rep(" ", innerWidth))
        end
        label = label:sub(1, innerWidth)
        local labelX = x + 1 + math.floor((innerWidth - #label) / 2)
        local labelY = y + math.floor(height / 2)
        monitor.setCursorPos(labelX, labelY)
        monitor.write(label)
    end
end

local function drawNumberPad(monitor, label, value, message)
    local width, height = monitor.getSize()
    local firstRow = 5
    -- Six square buttons per row, centred below the input summary. The
    -- adjacent border cells form the visible separators without empty gaps.
    local keyWidth = math.max(3, math.floor((width + 5) / 6))
    -- In the default monitor font a character is about 1.5 times taller than
    -- wide, hence this 2:3 row-to-column ratio for visual squares.
    local keyHeight = math.max(3, math.min(
        math.floor(keyWidth * 2 / 3),
        math.floor((height - firstRow + 2) / 2)
    ))
    local columnStep = keyWidth - 1
    local rowStep = keyHeight - 1
    local padWidth = keyWidth + columnStep * 5
    local padHeight = keyHeight + rowStep
    local left = math.max(1, math.floor((width - padWidth) / 2) + 1)
    local top = math.max(firstRow, math.floor((height - padHeight) / 2) + 1)

    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.white)
    monitor.clear()
    writeClipped(monitor, 1, 1, "Winery task service")
    writeClipped(monitor, 1, 2, label)
    monitor.setTextColor(colors.yellow)
    writeClipped(monitor, 1, 3, value == "" and "_" or value)
    monitor.setTextColor(colors.white)
    writeClipped(monitor, 1, 4, message or "Tap digits, then ENTER")

    for row, labels in ipairs(DIGIT_KEYS) do
        for column, key in ipairs(labels) do
            local x = left + (column - 1) * columnStep
            local fillColor = colors.black
            if key == "CANCEL" then
                fillColor = colors.red
            elseif key == "ENTER" then
                fillColor = colors.green
            end
            drawKey(monitor, x, top + (row - 1) * rowStep, keyWidth, keyHeight, key, fillColor)
        end
    end

    return {
        left = left,
        keyWidth = keyWidth,
        keyHeight = keyHeight,
        columnStep = columnStep,
        rowStep = rowStep,
        padWidth = padWidth,
        padHeight = padHeight,
        top = top,
    }
end

local function numberAtKeypad(layout, x, y)
    if x >= layout.left and x < layout.left + layout.padWidth and
        y >= layout.top and y < layout.top + layout.padHeight then
        local column = math.min(6, math.floor((x - layout.left) / layout.columnStep) + 1)
        local row = math.min(2, math.floor((y - layout.top) / layout.rowStep) + 1)
        return DIGIT_KEYS[row][column]
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
            if key == "CANCEL" then
                -- Returning to run() discards both the current and prior
                -- parameter, restoring the task form to its initial state.
                return nil, "cancel"
            elseif key == "ENTER" then
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

local function bucketToJuice(bucket)
    if type(bucket) ~= "string" then
        return nil
    end
    return bucket:gsub("_bucket$", "_juice")
end

local function availableFluid(repository, juiceName)
    local tankAddress
    for _, fluid in ipairs(repository.FLUID or {}) do
        if fluid.fluid == juiceName then
            tankAddress = fluid.address
            break
        end
    end
    if not tankAddress then
        return nil, "no tank is configured for " .. tostring(juiceName)
    end

    local tank = peripheral.wrap(tankAddress)
    if not tank or type(tank.tanks) ~= "function" then
        return nil, "cannot read juice tank " .. tostring(tankAddress)
    end

    local available = 0
    for _, contents in pairs(tank.tanks()) do
        if contents and contents.name == juiceName and type(contents.amount) == "number" then
            available = available + contents.amount
        end
    end
    return available
end

local function availableItem(address, itemName)
    local inventory = peripheral.wrap(address)
    if not inventory or type(inventory.list) ~= "function" then
        return nil, "cannot read material warehouse " .. tostring(address)
    end

    local available = 0
    for _, item in pairs(inventory.list()) do
        if item and item.name == itemName and type(item.count) == "number" then
            available = available + item.count
        end
    end
    return available
end

-- Returns either true, or false with a user-facing reason.  Recipe quantities
-- describe one batch, and every batch produces exactly sixteen bottles.
local function validateTask(recipeList, repository, wine, count)
    if wine < 1 or wine > #recipeList then
        return false, "Unknown wine type"
    end
    if count < 16 or count % 16 ~= 0 then
        return false, "Count must be a multiple of 16 bottles"
    end

    local recipe = recipeList[wine]
    if type(recipe) ~= "table" then
        return false, "Unknown wine type"
    end
    if type(repository) ~= "table" or type(repository.RESOURCE) ~= "table" then
        return false, "Material repository configuration is invalid"
    end
    if type(repository.RESOURCE.address) ~= "string" or repository.RESOURCE.address == "" then
        return false, "Material warehouse address is invalid"
    end

    local batches = count / 16
    local maxBatches = math.huge
    local juiceName = bucketToJuice(recipe.liquid)
    local liquidPerBatch = tonumber(recipe.liquid_amount)
    if not juiceName or not liquidPerBatch or liquidPerBatch <= 0 then
        return false, "Recipe liquid configuration is invalid"
    end

    local liquidAvailable, liquidError = availableFluid(repository, juiceName)
    if liquidAvailable == nil then
        return false, liquidError
    end
    maxBatches = math.min(maxBatches, math.floor(liquidAvailable / (liquidPerBatch * 1000)))

    local requiredIngredients = {}
    for _, ingredient in ipairs(recipe.ingredients or {}) do
        local name, amount = ingredient[1], ingredient[2]
        if type(name) ~= "string" or type(amount) ~= "number" or amount <= 0 then
            return false, "Recipe ingredient configuration is invalid"
        end
        requiredIngredients[name] = (requiredIngredients[name] or 0) + amount
    end

    for name, amountPerBatch in pairs(requiredIngredients) do
        local available, itemError = availableItem(repository.RESOURCE.address, name)
        if available == nil then
            return false, itemError
        end
        maxBatches = math.min(maxBatches, math.floor(available / amountPerBatch))
    end

    if maxBatches < batches then
        return false, ("Insufficient inventory. Maximum: %d bottles"):format(maxBatches * 16)
    end
    return true
end

local function waitForMonitorTouch(address)
    while true do
        local _, touchedAddress = os.pullEvent("monitor_touch")
        if touchedAddress == address then
            return
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
    local recipeList = require("recipe_config")
    local repository = require("repository_config")

    while true do
        local wine = readNumberFromMonitor(monitor, config.TASK_MONITOR_ADDRESS, "Wine type (1 or greater)", 1)
        if wine then
            local count = readNumberFromMonitor(monitor, config.TASK_MONITOR_ADDRESS, "Count (multiple of 16)", 16)
            if count then
                local checked, validationOrError, validationReason = pcall(
                    validateTask, recipeList, repository, wine, count
                )
                local valid = checked and validationOrError
                local reason = checked and validationReason or
                    ("Inventory check failed: " .. tostring(validationOrError))
                if not valid then
                    show(monitor, { reason, "Task was not created.", "Touch display to start again..." })
                else
                    local ok, taskOrError = pcall(TaskService.create, state, storagePath, wine, count, eventName)
                    if ok then
                        local task = taskOrError
                        show(monitor, {
                            "Task created",
                            "ID: " .. task.taskid,
                            "Wine: " .. task.wine,
                            "Count: " .. task.count,
                            "Status: " .. task.status,
                            "User: " .. task.user,
                            "",
                            "Touch display to create another task...",
                        })
                    else
                        show(monitor, { "Task was not created:", tostring(taskOrError), "Touch display to retry..." })
                    end
                end
                waitForMonitorTouch(config.TASK_MONITOR_ADDRESS)
            end
        end
    end
end

if ... == nil then
    TaskService.run()
end

return TaskService
