-- Own exactly one lobby or mission session, including while its module downloads.
return function(api)
    local controller = {slot=nil, stopped=false, observed=nil, since=0, retryAt=0}
    local function report(message)
        if api.report then pcall(api.report, message) end
    end
    local function stopSlot(slot)
        if not slot or not slot.active then return end
        slot.active = false
        slot.session.active = false
        if controller.slot == slot then controller.slot = nil end
        local stop = slot.kind == "lobby" and slot.session.stopLobby or slot.session.stopMission
        if type(stop) == "function" then pcall(stop) end
        if slot.handle and type(slot.handle.Stop) == "function" and slot.handle.Stop ~= stop then
            pcall(slot.handle.Stop)
        end
        if slot.thread and api.cancel and (not api.currentThread or slot.thread ~= api.currentThread()) then
            pcall(api.cancel, slot.thread)
        end
    end
    local function start(kind)
        local slot = {kind=kind, active=true, ready=false}
        local session = setmetatable({active=true}, {__index=api.context or {}})
        slot.session = session
        controller.slot = slot
        function session.mode()
            if not slot.active or controller.stopped or controller.slot ~= slot then return "inactive" end
            return api.mode()
        end
        function session.isCurrent()
            return session.mode() == kind
        end
        slot.thread = api.spawn(function()
            local ok, result = pcall(function()
                if not session.isCurrent() then return end
                return api.load(kind, session)
            end)
            -- A stale download must never adopt a module or clean up a newer session.
            if not session.isCurrent() then
                if ok and type(result) == "table" and type(result.Stop) == "function" then pcall(result.Stop) end
                stopSlot(slot)
                return
            end
            if ok and kind == "lobby" and (type(result) ~= "table" or type(result.Stop) ~= "function") then
                ok, result = false, "Lobby module did not provide cleanup"
            end
            if not ok then
                stopSlot(slot)
                controller.retryAt = api.clock() + (api.retryDelay or 5)
                report(kind .. " load failed: " .. tostring(result))
                return
            end
            slot.handle, slot.ready = type(result) == "table" and result or nil, true
            report(kind == "lobby" and "Lobby script active" or "Mission script active")
        end)
    end
    function controller:Tick()
        if self.stopped then return end
        local current = api.mode()
        local now = api.clock()
        if current ~= self.observed then
            self.observed, self.since, self.retryAt = current, now, 0
        end
        if self.slot and self.slot.kind ~= current then stopSlot(self.slot) end
        if current ~= "lobby" and current ~= "mission" then return end
        if not self.slot and now >= self.retryAt and now - self.since >= (api.settleDelay or 2) then
            start(current)
        end
    end
    function controller:Stop()
        if self.stopped then return end
        self.stopped = true
        stopSlot(self.slot)
    end
    return controller
end
