--[[
    you should write own timers, those are only for test purpose!!
]]

local timers = {}

function setTimer(callback, interval, timesToExec, ...)
    local timer = {
        callback = callback,
        timesToExec = timesToExec,
        args = {...},
        executed = 0,
        interval = interval,
        endTime = getTickCount() + interval,
    }
    table.insert(timers, timer)
    return timer
end

function killTimer(timer)
    for i, t in ipairs(timers) do
        if t == timer then
            table.remove(timers, i)
            return true
        end
    end
    return false
end

function updateTimers()
    local now = getTickCount()
    for i, timer in ipairs(timers) do
        if now >= timer.endTime then
            timer.callback(unpack(timer.args))
            timer.executed = timer.executed + 1
            timer.endTime = now + timer.interval
            if timer.executed >= timer.timesToExec and timer.timesToExec ~= 0 then
                table.remove(timers, i)
            end
        end
    end
end