local signal = {}
    signal.MULTI_THREAD = false

local signalmeta = {}
signalmeta.__index = signalmeta

function signal.new()
    local self = {}
    self.connections = {}

    return setmetatable(self, signalmeta)
end

function signalmeta:connect(f)
    table.insert(self.connections, {func = f})
    local pos = #self.connections
    return {
        disconnect = function()
            if not pos then return end
            self.connections[pos] = nil
            pos = nil
        end
    }
end

function signalmeta:connect_once(f)
    table.insert(self.connections, {func = f, once = true})
    local pos = #self.connections
    return {
        disconnect = function()
            if not pos then return end
            self.connections[pos] = nil
            pos = nil
        end
    }
end

function signalmeta:fire(...)
    for i, v in pairs(self.connections) do
        if signal.MULTI_THREAD then
            require("task").spawn(v.func, ...)
        else
            v.func(...)
        end

        if v.once then
            self.connections[i] = nil
        end
    end
end

return signal