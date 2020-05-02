local Signed = {}
local activeService = false
local activeSignup
PW = nil

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

AddEventHandler('onResourceStart', function(res)
    if res == GetCurrentResourceName() then
        activeSignup = Config.Locations.Signup[math.random(1, #Config.Locations.Signup)]
        PW.SetTimeout(Config.Delay * 1000, function()
            NewCar()
        end)
    end
end)

PW.RegisterServerCallback('pw_chopshop:server:connected', function(source, cb)
    cb(activeSignup)
end)

RegisterServerEvent('pw_chopshop:server:stopService')
AddEventHandler('pw_chopshop:server:stopService', function()
    local _src = source
    PW.ClearTimeout(activeService[_src])
    activeService[_src] = false
    Signed[_src] = nil
end)

RegisterServerEvent('pw_chopshop:server:signUp')
AddEventHandler('pw_chopshop:server:signUp', function(data)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)

    if data.email.value ~= nil and string.len(data.email.value) > 16 and string.sub(data.email.value, -15) == '@pixelworld.com' and not HasEmail(data.email.value) then
        local charEmail = _char.getEmail()
        if data.email.value == charEmail then
            Signed[_src] = { ['cid'] = _char.getCID(), ['email'] = charEmail, ['cooldown'] = false, ['streak'] = 0 }
            TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'inform', text = 'You have successfully signed up.<br>Stand-by for instructions' })
            TriggerClientEvent('pw_chopshop:client:signedUp', _src)
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'Invalid email address' })
        end
    end
end)

RegisterServerEvent('pw_chopshop:server:vehDelivered')
AddEventHandler('pw_chopshop:server:vehDelivered', function(model, props)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)

    local vehInfo
    for k,v in pairs(Config.VehicleModels) do
        if v.model == model then
            vehInfo = v
        end
    end

    local depositCut = 0
    local totalDamage = math.abs(2000 - props.bodyHealth - props.engineHealth) / 2000
    if totalDamage > 0.10 then
        depositCut = totalDamage
    end
    local payout = math.random(vehInfo.payout.min, vehInfo.payout.max) + (Signed[_src]['streak'] * Config.BonusPerCompletion)
    local finalPayout = math.ceil(payout * (1-depositCut))
    _char:Cash().addCash(finalPayout, function(done) end)
    TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'inform', text = 'Vehicle delivered and confirmed. You got $' .. finalPayout .. ' for it.' .. (depositCut > 0 and "<br>" .. math.ceil(depositCut * 100) .. "% damage detected" or ""), length = 5000 })
    PW.ClearTimeout(activeService[_src])
    activeService = false
    Signed[_src]['streak'] = Signed[_src]['streak'] + 1
end)

RegisterServerEvent('pw_chopshop:server:sendNpcLocation')
AddEventHandler('pw_chopshop:server:sendNpcLocation', function(coords)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    local charEmail = _char.getEmail()

    local message = Signed[_src]['streak'] > 0 and "You proved your value. We got a new target for you. Meet our associate at the attached location.<br><b>Do not let us down</b>." or "If you want to show what you are worth to us, meet our contact at the attached location, alone.<br><b>NO COPS</b>."
    TriggerEvent('pw_phone:server:sendEmail', charEmail, 'Start Mission', message, { ['waypoint'] = { ['x'] = coords.x, ['y'] = coords.y, ['z'] = coords.z} })
end)

RegisterServerEvent('pw_chopshop:server:sendVehInfo')
AddEventHandler('pw_chopshop:server:sendVehInfo', function(info)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    local charEmail = _char.getEmail()

    local message = "Deliever a <b>" .. info.vehLabel .. "</b> to the attached location within <b>30 minutes</b>. We have sighted one around the location marked in your GPS.<br>We only got a partial plate number: <b>XXXX" .. string.sub(info.vehPlate, -4) .. "</b>.<br>Make sure it is in good condition or your payout will get a <b>CUT</b>"
    TriggerEvent('pw_phone:server:sendEmail', charEmail, 'Mission', message, { ['waypoint'] = { ['x'] = info.coords.x, ['y'] = info.coords.y, ['z'] = info.coords.z} })
end)

function NewCar()
    if not activeService then
        if #Signed > 0 then
            local online = false
            repeat
                local chosen = math.random(1, #Signed)
                online = exports.pw_core:checkOnline(Signed[chosen].cid)
                if not online then
                    Signed[chosen] = nil
                end
            until online ~= false
            TriggerClientEvent('pw_chopshop:client:newService', online)
            activeService = {}
            activeService[online] = PW.SetTimeout(Config.TimeToComplete * 1000, function()
                TriggerClientEvent('pw_chopshop:client:serviceTimeout', online)
                activeService = false
                Signed[online] = nil

                TriggerClientEvent('pw:notification:SendAlert', online, 'You failed to complete the mission in time.<br>You are now signed out.')
            end)
        end
    end

    PW.SetTimeout(Config.Delay * 1000, function()
        NewCar()
    end)
end

function HasEmail(email)
    if #Signed > 0 then
        for k,v in pairs(Signed) do
            if v.email == email then
                return true
            end
        end
    end

    return false
end