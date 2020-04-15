simCards = {}

function simCard(number)
    local self = {}
    local rTable = {}

    self.number = number
    self.query = MySQL.Sync.fetchAll("SELECT * FROM `phone_simcards` WHERE `number` = @number", { ['@number'] = self.number })
    self.oncall = false
    self.callaccepted = false
    self.receivingCall = false

    if self.query[1] ~= nil then
        self.owner = self.query[1].cid
        self.simid = self.query[1].simcard_id
        self.active = self.query[1].active
        if self.query[1].meta ~= nil then
            self.meta = json.decode(self.query[1].meta)
        else
            self.meta = { ['contacts'] = {}, ['conversations'] = {}, ['calllog'] = {}, ['messages'] = {}, ['gps'] = { ['x'] = 0.0, ['y'] = 0.0, ['z'] = 0.0, ['updated'] = false } }
        end
    end

    self.saveCard = function()
        MySQL.Sync.execute("UPDATE `phone_simcards` SET `active` = @active, `cid` = @owner, `meta` = @meta WHERE `simcard_id` = @id", {['@active'] = self.active, ['@owner'] = self.owner, ['@id'] = self.simid, ['@meta'] = json.encode(self.meta)})
    end

    rTable.updateStatus = function()
        self.active = not self.active
        self.saveCard()
    end

    rTable.getCallLog = function(calltype)
        if calltype == nil then
            return self.meta.calllog
        else
            local returnTable = {}
            for k, v in pairs(self.meta.calllog) do
                if v.type == calltype then
                    table.insert(returnTable, v)
                end
            end
        end
    end

    rTable.retreiveConversation = function(conid)
        local returnTable = {}
        for k, v in pairs(self.meta.messages) do
            if v.toName then
                v.toName = nil
            end
            if v.fromName then
                v.fromName = nil
            end
            if v.conversation_id == conid and (v.hidden == nil or v.hidden == false) then
                if v.to == self.number then
                    v.read = true
                end
                table.insert(returnTable, v)
            end
        end

        for x, y in pairs(returnTable) do
            for p, q in pairs(self.meta.contacts) do
                if q.number == y.from then
                    y.fromName = q.name
                end
                if q.number == y.to then
                    y.toName = q.name
                end
            end
        end

        return returnTable
    end

    rTable.deleteMessage = function(mid)
        for k, v in pairs(self.meta.messages) do
            if v.message_id == mid and (v.hidden == nil or v.hidden == false) then
                v.hidden = true
                break
            end
        end
    end

    rTable.deleteConversation = function(coid)
        for k, v in pairs(self.meta.conversations) do
            if coid == v.convo_id and (v.hidden == nil or v.hidden == false) then
                v.hidden = true
                break
            end
        end
    end

    rTable.getUnreadMessages = function(convoid)
        local unread = 0
        if convoid == nil then
            for k, v in pairs(self.meta.messages) do
                if v.read == false and v.to == self.number and (v.hidden == nil or v.hidden == false) then
                    unread = unread + 1
                end
            end
        else
            for k, v in pairs(self.meta.messages) do
                if v.read == false and v.to == self.number and v.conversation_id == convoid and (v.hidden == nil or v.hidden == false) then
                    unread = unread + 1
                end
            end
        end
        return unread
    end

    rTable.createConversation = function(to, from, sendtoparty, generate)
            if generate ~= false then
                newConvoId = generate
            else
                newConvoId = math.random(10000000,99999999)
            end
            local _to = tonumber(to)
        if simCards[_to] then
            local time = os.date("%Y-%m-%d %H:%M:%S")

                if sendtoparty then
                    simCards[_to].createConversation(to, from, false, newConvoId)
                end

            table.insert(self.meta.conversations, {['convo_id'] = newConvoId, ['from'] = from, ['to'] = _to, ['datetime'] = time})
            self.saveCard()
            return newConvoId
        end
    end

    rTable.getContactName = function(number)
        for k, v in pairs(self.meta.contacts) do
            if v.number == number then
                return v.name
            end
        end
        return nil
    end

    rTable.ConvoDetails = function(convoid)
        local returnTable = {}
        for k, v in pairs(self.meta.conversations) do
            if v.convo_id == convoid then
                if v.fromName then
                    v.fromName = nil
                end
                table.insert(returnTable, v)
            end
        end

        for a, b in pairs(returnTable) do
            for p, q in pairs(self.meta.contacts) do
                if q.number == b.from then
                    b.fromName = q.name
                end
                if q.number == b.to then
                    b.toName = q.name
                end
            end
        end
        return returnTable
    end

    rTable.createNewMessage = function(to, message, new, conid)
        local time = os.date("%Y-%m-%d %H:%M:%S")
        if new then
            conid = rTable.createConversation(to, self.number, true, false)
            repeat Wait(0) until conid ~= nil
        end

        table.insert(self.meta.messages, { ['conversation_id'] = conid, ['message'] = message, ['datetime'] = time, ['read'] = false, ['to'] = to, ['message_id'] = math.random(10000000,999999999) })

        if new then
            if simCards[tonumber(to)] then
                simCards[tonumber(to)].addMeta("messages", { ['conversation_id'] = conid, ['message'] = message, ['datetime'] = time, ['read'] = false, ['to'] = to, ['message_id'] = math.random(10000000,999999999) })
            end
        end
        self.saveCard()
    end

    rTable.addMeta = function(pkey, data)
        if pkey ~= nil and data ~= nil then
            if self.meta[pkey] then
                table.insert(self.meta[pkey], data)
                self.saveCard()
            end
        end
    end

    rTable.getMeta = function(pkey)
        if pkey ~= nil then
            if self.meta[pkey] then
                return self.meta[pkey]
            end
        end
    end

    rTable.getConversations = function()
        local returnTable = {}
        for k, v in pairs(self.meta.conversations) do
            if v.toName then
                v.toName = nil
            end
            if v.fromName then
                v.fromName = nil
            end
            if v.hidden == nil or v.hidden == false then
                table.insert(returnTable, v)
            end
        end

        for k2, v2 in pairs(returnTable) do
            v2.unread = rTable.getUnreadMessages(v2.convo_id) > 0 and true or false
            for p, q in pairs(self.meta.contacts) do
                if q.number == v2.from then
                    v2.fromName = q.name
                end
                if q.number == v2.to then
                    v2.toName = q.name
                end
            end
        end

        return returnTable
    end

    rTable.removeMeta = function(pkey, tid)
        if pkey ~= nil then
            if self.meta[pkey] then
                table.remove(self.meta[pkey], tid)
                self.saveCard()
            end
        end
    end 

    rTable.getStatus = function()
        return self.active
    end

    rTable.getGPS = function()
        return self.meta.gps
    end

    rTable.updateGPS = function(x,y,z)
        self.meta.gps = { ['x'] = x, ['y'] = y, ['z'] = z, ['updated'] = true }
        self.saveCard()
    end

    rTable.getNumber = function()
        return self.number
    end

    rTable.getOwner = function()
        return self.owner
    end

    rTable.updateOwner = function(cid)
        self.owner = cid
        self.saveCard()
    end

    -- DOING THIS --

    rTable.attemptCallConnection = function(src, to)
        if self.meta.calllog == nil then
            self.meta.calllog = {}
        end
        if self.active then
            self.oncall = true
            local name = to
            for k, v in pairs(self.meta.contacts) do
                if v.number == to then
                    name = v.name
                    break
                end
            end
            self.callIdent = {['to'] = to, ['id'] = math.random(10000000,99999999)}

            if simCards[tonumber(to)] then
                local state, reason = simCards[tonumber(to)].receiveCallConnection(self.number, self.callIdent.id)
                if state then
                    TriggerClientEvent('pw_phone:client:ringPhone', src, name, false, false, false, false)
                else
                    self.oncall = false
                    TriggerClientEvent('pw_phone:client:ringPhone', src, name, false, true, reason, false)
                    table.insert(self.meta.calllog, { ['callid'] = self.callIdent.id, ['from'] = self.number, ['to'] = to, ['toname'] = name, ['status'] = "failed", ['reason'] = reason, ['type'] = "outgoing", ['hidden'] = false })
                end
            else
                self.oncall = false
                TriggerClientEvent('pw_phone:client:ringPhone', src, name, false, true, "Incorrect Number", false)
                table.insert(self.meta.calllog, { ['callid'] = self.callIdent.id, ['from'] = self.number, ['to'] = to, ['toname'] = name, ['status'] = "failed", ['reason'] = "Incorrect Number", ['type'] = "outgoing", ['hidden'] = false })
            end
            self.saveCard()
        end
    end

    rTable.receiveCallConnection = function(from, callident)
        if self.meta.calllog == nil then
            self.meta.calllog = {}
        end
        print(self.number, 'Is receiving a call from', from)
        self.callIdent = { ['from'] = from, ['id'] = callident }
        if self.active then
            local name = from
            for k, v in pairs(self.meta.contacts) do
                if v.number == from then
                    name = v.name
                    break
                end
            end
            if not self.oncall then
                self.oncall = true
                local online = exports['pw_base']:checkOnline(self.owner)
                if online ~= false then
                    self.callaccepted = false
                    self.receivingCall = true
                    Citizen.CreateThread(function()
                        while self.receivingCall do
                            TriggerClientEvent('pw_phone:client:ringPhone', tonumber(online), name, true, false, false, false, self.number)
                            Wait(30000)
                            if not self.callaccepted and self.receivingCall then
                                self.receivingCall = false
                                self.callaccepted = false
                                simCards[tonumber(self.callIdent.from)].outGoingCallRejected()
                                TriggerClientEvent('pw_phone:client:ringPhone', tonumber(online), name, true, false, false, true)
                                self.callIdent = nil
                                self.oncall = false
                            end
                        end
                    end)
                    return true
                else
                    return false, "Inactive"
                end
            else
                return false, "Engaged"
            end
        else
            return false, "Inactive"
        end
    end

    rTable.terminateCall = function()
        local curentCal
        local online = exports['pw_base']:checkOnline(self.owner)
        if online ~= false then
            TriggerClientEvent('pw_phone:client:connectCall', online, false, self.callIdent.id)
        end
        self.oncall = false
        self.callIdent = nil
        self.callaccepted = false
        self.receivingCall = false
    end

    rTable.partyAcceptedCall = function(callid)
        local online = exports['pw_base']:checkOnline(self.owner)
        if online ~= false then
            local name = self.callIdent.to
            for k, v in pairs(self.meta.contacts) do
                if v.number == self.callIdent.to then
                    name = v.name
                    break
                end
            end
            TriggerClientEvent('pw_phone:client:connectCall', online, callid, name, self.callIdent.to)
        end
    end

    rTable.acceptCall = function(src)
        if self.receivingCall then
            self.receivingCall = false
            self.callaccepted = true
            self.oncall = true
            local name = self.callIdent.from
            for k, v in pairs(self.meta.contacts) do
                if v.number == self.callIdent.from then
                    name = v.name
                    break
                end
            end
            simCards[tonumber(self.callIdent.from)].partyAcceptedCall(self.callIdent.id)
            TriggerClientEvent('pw_phone:client:connectCall', src, self.callIdent.id, name, self.callIdent.from)
        end
    end

    rTable.outGoingCallRejected = function()
        local online = exports['pw_base']:checkOnline(self.owner)
        if online ~= false then
            local name = self.callIdent.to
            for k, v in pairs(self.meta.contacts) do
                if v.number == self.callIdent.to then
                    name = v.name
                    break
                end
            end
            TriggerClientEvent('pw_phone:client:ringPhone', online, name, false, true, "No Anwser / Rejected", true)
            table.insert(self.meta.calllog, { ['callid'] = self.callIdent.id, ['from'] = self.number, ['to'] = self.callIdent.to, ['toname'] = name, ['status'] = "failed", ['reason'] = "Call Rejected", ['type'] = "outgoing", ['hidden'] = false })
            self.callIdent = nil
            self.receivingCall = false
            self.callaccepted = false
            self.oncall = false
            self.saveCard()
        end 
    end

    rTable.rejectCall = function(src)
        print('you rejected the call')
        if self.receivingCall then
            simCards[tonumber(self.callIdent.from)].outGoingCallRejected()
            self.receivingCall = false
            self.callaccepted = false
            self.oncall = false
            self.callIdent = nil

            local online = exports['pw_base']:checkOnline(self.owner)
            if online ~= false then
                TriggerClientEvent('pw_phone:client:ringPhone', tonumber(online), name, true, false, false, true)
            end
        end
    end

    return rTable
end

function registerSimCard(cid)
    local self = {}
    local genNumber = "555"..math.random(100000,999999)
    self.cid = cid
    self.number = tonumber(genNumber)
    self.meta = { ['contacts'] = {}, ['conversations'] = {}, ['calllog'] = {}, ['messages'] = {}, ['gps'] = { ['x'] = 0.0, ['y'] = 0.0, ['z'] = 0.0, ['updated'] = false } }
    MySQL.Sync.insert("INSERT INTO `phone_simcards` (`cid`,`number`,`active`,`meta`) VALUES (@cid, @number, 0, @meta)", { ['@cid'] = self.cid, ['@number'] = self.number, ['meta'] = json.encode(self.meta) })

    simCards[self.number] = simCard(self.number)

    return self.number
end

exports('simCard', function(num)
    if (simCards[tonumber(num)]) then 
        return simCards[tonumber(num)]
    end
end)

exports('registerSim', function(cid)
    return registerSimCard(cid)
end)