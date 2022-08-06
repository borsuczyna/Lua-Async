local __type = type
function type(a)
    local t = __type(a)
    if t == "table" and a.__isPromise then
        return "promise"
    else
        return t
    end
end

function Promise(callback)
    local t = {
        pending = true,
        __isPromise = true,
        callback = callback,
    }

    setmetatable(t, {
        __tostring = function(self)
            return "Promise <" .. (self.pending and "pending" or "resolved") .. ">"
        end,
        __type = "Promise",
        __call = function(self, ...)
            self.pending = false
            return self.callback(...)
        end
    })

    return t
end

function sleep(ms)
    return Promise(function(resolve, reject)
        setTimer(function()
            resolve()
        end, ms, 1)
    end)
end

function async(callback)
    local t = {
        callback = coroutine.create(callback),
        pendingPromise = false,
        await = function(self, exec, ...)
            local args = {...}
            assert(type(exec) == "promise", "Attempt to await a non-promise")

            local resolve = function(...)
                self.pendingPromise.rejected = false
                self.pendingPromise.returnValue = {...}
                self.pendingPromise.resolved = true
                self.pendingPromise.called = true
                -- if coroutine.status(self.callback) == "dead" then return end
                coroutine.resume(self.callback, ...)
            end
            local reject = function(...)
                self.pendingPromise.rejected = {...}
                self.pendingPromise.returnValue = {}
                self.pendingPromise.resolved = true
                self.pendingPromise.called = true
                -- if coroutine.status(self.callback) == "dead" then return end
                coroutine.resume(self.callback, ...)
            end

            self.pendingPromise = {
                returnValue = false,
                rejected = false,
                resolved = false,
                exec = exec,
                args = args,
                called = false,
                resolve = resolve,
                reject = reject,
            }

            self.timer = setTimer(self.heartBeat, 1, 1, self)

            coroutine.yield(self.callback)
            assert(not self.pendingPromise.rejected, table.concat(self.pendingPromise.rejected or {}, " "))

            killTimer(self.timer)

            local returnValue = self.pendingPromise.returnValue
            self.pendingPromise = false

            return unpack(returnValue)
        end,
        heartBeat = function(self)
            if self.pendingPromise then
                if not self.pendingPromise.called then
                    self.pendingPromise.exec(self.pendingPromise.resolve, self.pendingPromise.reject, unpack(self.pendingPromise.args))
                    self.pendingPromise.called = true
                end
            end
        end,
    }

    setmetatable(t, {
        __call = function(self)
            status = coroutine.resume(self.callback, self)
        end,
    })

    return t
end