require("timers")
require("async")

local __tick = 0

function getTickCount()
    return __tick
end

function love.update(dt)
    __tick = __tick + dt*1000

    updateTimers()
end

function sleep(ms)
    return Promise(function(resolve, reject)
        setTimer(resolve, ms, 1)
    end)
end

local test = async(function(self)
    print("1")
    for i = 2, 10, 1 do
        async(function(self)
            self:await(sleep(1))
            print(i)
        end)()
    end
    print("Out of scope")
end)

test()