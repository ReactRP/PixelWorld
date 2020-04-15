local issuedRadios = {}

function checkUserHasRadio(src, cb)
    local _src = src
    local _char = exports['pw_core']:getCharacter(_src)
    _char:Inventory().getItemCount("radio", function(count)
        if count ~= nil and count > 0 then
            cb(true)
        else
            cb(false)
        end
    end)
end


RegisterNetEvent('pw_voip:autheriseRadio')
AddEventHandler('pw_voip:autheriseRadio', function(toggle, job)
    local _src = source
    if job.name == "ems" or job.name == "police" then
        local _char = exports['pw_core']:getCharacter(_src)
        local stations = { ['ems'] = 2, ['police'] = 1}
        if toggle then
            checkUserHasRadio(_src, function(hasRadio)
                if not hasRadio then
                    _char:Inventory():Add().Default(1, "radio", 1, {['channel'] = stations[job.name]}, {['channel'] = stations[job.name]}, function(item)
                        if item then
                            issuedRadios[_src] = item.record_id
                        end
                    end, _char.getCID())
                end
            end)
        else
            if issuedRadios[_src] then
                _char:Inventory():Remove().Default(issuedRadios[_src], 1, function(item)
                    if item then
                        issuedRadios[_src] = nil
                    end
                end)
            end
        end
    end
end)

AddEventHandler('playerDropped', function()
	local _src = source
    if issuedRadios[_src] then
        MySQL.Async.execute("DELETE FROM `stored_items` WHERE `record_id` = @record AND `inventoryType` = 1", {['@record'] = issuedRadios[_src]}, function(done)
            issuedRadios[_src] = nil
        end)
    end
end)