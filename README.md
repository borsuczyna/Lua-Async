# Lua Async Library

## Examples
```lua
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
```

```lua
local test = async(function(self)
    print("pre " .. getTickCount())

    local test = Promise(function(resolve, reject)
        setTimer(resolve, 1000, 1, "Hey")
    end)

    print(test) -- "Promise <pending>"
    local result = self:await(test)
    print(result, getTickCount()) -- "Hey"
    print(test, getTickCount()) -- "Promise <resolved>"
end)
test()
```

```lua
function sleep(ms)
    return Promise(function(resolve, reject)
        setTimer(resolve, ms, 1)
    end)
end

local test = async(function(self)
    print("hello")
    self:await(sleep(1000))
    print("world")
end)
test()```