function loadMotelRoom(rid)
    if rid == nil then return; end

    local self = {}
    self.rid = rid

    self.roomqry = MySQL.Sync.fetchAll("SELECT * FROM `motel_rooms` WHERE `room_id` = @rid", {['@rid'] = self.rid})[1] or nil
    if self.roomqry == nil then return; end
        if self.roomqry ~= nil then
            self.motelName = MySQL.Sync.fetchScalar("SELECT `name` FROM `motels` WHERE `motel_id` = @motel", {['@motel'] = self.roomqry.motel_id})
            self.roomMeta = json.decode(self.roomqry.roomMeta)
            local rTable = {}

                self.updateClients = function()
                    local tbl 
                    if self.roomqry.motel_type == "Teleport" then
                        tbl = { ['room_id'] = self.roomqry.room_id, ['locked'] = self.roomMeta.doorLocked, ['motel_name'] = self.motelName, ['motel_id'] = self.roomqry.motel_id, ['room_number'] = self.roomqry.room_number, ['motel_type'] = self.roomqry.motel_type, ['teleport_meta'] = json.decode(self.roomqry.teleport_meta), ['inventories'] = json.decode(self.roomqry.inventories), ['occupied'] = self.roomqry.occupied, ['occupier'] = self.roomqry.occupier, ['occupierCID'] = self.roomqry.occupierCID, ['charSpawn'] = self.roomqry.charSpawn, ['roomMeta'] = self.roomqry.roomMeta}
                    else
                        tbl = { ['room_id'] = self.roomqry.room_id, ['motel_name'] = self.motelName, ['motel_id'] = self.roomqry.motel_id, ['mainEntrance'] = json.decode(self.roomqry.mainEntrance), ['room_number'] = self.roomqry.room_number, ['motel_type'] = self.roomqry.motel_type, ['inventories'] = json.decode(self.roomqry.inventories), ['occupied'] = self.roomqry.occupied, ['occupier'] = self.roomqry.occupier, ['occupierCID'] = self.roomqry.occupierCID, ['charSpawn'] = self.roomqry.charSpawn, ['roomMeta'] = self.roomqry.roomMeta}
                    end
                    print('sending update for motels')
                    TriggerClientEvent('pw_motels:client:updateRoom', -1, self.rid, tbl)
                end

                rTable.roomID = function()
                    return self.roomqry.room_id
                end

                rTable.roomNumber = function()
                    return self.roomqry.room_number
                end

                rTable.motelId = function()
                    return self.roomqry.motel_id
                end

                rTable.getMotel = function()
                    return MySQL.Sync.fetchAll("SELECT * FROM `motels` WHERE `motel_id` = @motel", {['@motel'] = self.roomqry.motel_id})[1] or nil
                end

                rTable.motelName = function()
                    return self.motelName
                end

                rTable.getLocation = function()
                    return json.decode(self.roomqry.charSpawn)
                end

                rTable.getInventories = function()
                    return json.decode(self.roomqry.inventories)
                end

                if self.roomqry.motel_type == "Teleport" then

                    rTable.getTeleports = function()
                        return json.decode(self.roomqry.teleport_meta)
                    end

                    rTable.updateLock = function()
                        self.roomMeta.doorLocked = not self.roomMeta.doorLocked
                        
                        self.updateClients()
                    end

                end

                rTable.occupied = function()
                    return self.roomqry.occupied
                end

                rTable.occupier = function()
                    local occupier = {
                        ['source'] = self.roomqry.occupier, ['cid'] = self.roomqry.occupierCID
                    }
                    return occupier
                end

                rTable.updateOccupier = function(src, cid)
                    print('Motel Room Assigned', self.motelName, self.roomqry.room_number, cid)
                    self.roomqry.occupied = true
                    self.roomqry.occupier = src
                    self.roomqry.occupierCID = cid
                    self.updateClients()
                    MySQL.Async.execute("UPDATE `motel_rooms` SET `occupied` = 1, `occupier` = @src, `occupierCID` = @cid WHERE `room_id` = @rid", {['@cid'] = cid, ['@src'] = src, ['@rid'] = self.rid })
                end

                rTable.unassignRoom = function()
                    print('Motel Room Unassigned', self.motelName, self.roomqry.room_number)
                    self.roomqry.occupied = false
                    self.roomqry.occupier = 0
                    self.roomqry.occupierCID = 0
                    self.updateClients()
                    MySQL.Async.execute("UPDATE `motel_rooms` SET `occupied` = 0, `occupier` = @src, `occupierCID` = @cid WHERE `room_id` = @rid", {['@cid'] = 0, ['@src'] = 0, ['@rid'] = self.rid })
                end
            return rTable    
        end
end