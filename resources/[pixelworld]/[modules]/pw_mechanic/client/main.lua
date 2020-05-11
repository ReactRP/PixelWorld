local Vehicles, blips, curVeh, shoppingCart = {}, {}, {}, {}
local showing, previewing, smoking = false, false, false
local prevMenu, curMenu, curGarage, lastVeh

PW = nil
playerLoaded, GLOBAL_PED, GLOBAL_COORDS, playerData = false, nil, nil, nil

Citizen.CreateThread(function()
    while PW == nil do
        TriggerEvent('pw:loadFramework', function(framework) PW = framework end)
        Citizen.Wait(1)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if playerLoaded then
            GLOBAL_PED = PlayerPedId()
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if playerLoaded then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(unload, ready, data)
    if not unload then
        if ready then
            CreateBlips()
            PW.TriggerServerCallback('pw_vehicleshop:server:requestVehicles', function(vehs)
                Vehicles = vehs
                PW.TriggerServerCallback('pw_mechanic:server:getConfig', function(settings)
                    Config.MySQL = settings
                    GLOBAL_PED = PlayerPedId()
                    GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
                    playerLoaded = true
                end)
            end)
        else
            playerData = data
        end
    else
        RemoveBlips()
        if curVeh ~= nil and curVeh['obj'] ~= nil then
            FreezeEntityPosition(curVeh.obj, false)
        end
        curVeh = {}
        shoppingCart = {}
        playerData = nil
        playerLoaded = false
    end
end)

RegisterNetEvent('pw:updateJob')
AddEventHandler('pw:updateJob', function(data)
    if playerData ~= nil then
        playerData.job = data
    end
    if showing then
        showing = false
        TriggerEvent('pw_drawtext:hideNotification')
    end
end)

RegisterNetEvent('pw:toggleDuty')
AddEventHandler('pw:toggleDuty', function(toggle)
    if playerData then
        playerData.job.duty = toggle
    end
end)

RegisterNetEvent('pw_mechanic:client:openMechanicActions')
AddEventHandler('pw_mechanic:client:openMechanicActions', function()
    OpenMechanicActions()
end)

RegisterNetEvent('pw_mechanic:client:spawnVehicle')
AddEventHandler('pw_mechanic:client:spawnVehicle', function(props, id)
    local coords = Config.Locations[id].garage.spawn
    local cV = GetClosestVehicle(coords.x, coords.y, coords.z, 7.0, 0, 71)
    if cV == 0 or cV == nil then
        PW.Game.SpawnOwnedVehicle(props.model, coords, coords.h, function(vehicle)
            TriggerEvent('pw_interact:closeMenu')
            PW.Game.SetVehicleProperties(vehicle, props)
            SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0)
            SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0)
            exports.pw_notify:SendAlert('inform', 'Vehicle taken out of the garage', 5000)
        end)
    else
        exports.pw_notify:SendAlert('error', 'There\'s a vehicle blocking the garage exit', 5000)
    end
end)

RegisterNetEvent('pw_mechanic:client:openGarage')
AddEventHandler('pw_mechanic:client:openGarage', function(garage)
    PW.TriggerServerCallback('pw_mechanic:server:getJobGarage', function(vehs)
        if vehs then
            local menu = {}
            for k,v in pairs(vehs) do
                table.insert(menu, { ['label'] = PW.Vehicles.GetName(v.props.model), ['action'] = 'pw_mechanic:server:getVeh', ['value'] = {props = v.props, vin = v.vid, garage = garage}, ['triggertype'] = 'server', ['color'] = 'primary' })
            end

            TriggerEvent('pw_interact:generateMenu', menu, "Garage")
        else
            exports.pw_notify:SendAlert('error', 'No vehicles parked', 3500)
        end
    end, garage)
end)

RegisterNetEvent('pw_mechanic:client:openOptions')
AddEventHandler('pw_mechanic:client:openOptions', function(data)
    OpenCustomizationOptions(data)
end)

RegisterNetEvent('pw_mechanic:client:openMenu')
AddEventHandler('pw_mechanic:client:openMenu', function(cat, garage)
    OpenCustomizationMenu(cat, garage)
end)

RegisterNetEvent('pw_mechanic:client:openPrev')
AddEventHandler('pw_mechanic:client:openPrev', function()
    Wait(50)
    if prevMenu == 'boss' then
        OpenBossActions(curGarage)
    else
        SetVehicleLights(curVeh.obj, 0)
        if prevMenu ~= nil then
            if curVeh.props then 
                if curVeh.props['windowTint'] == -1 then curVeh.props['windowTint'] = 4; end
                ClearVehicleCustomPrimaryColour(curVeh.obj)
                ClearVehicleCustomSecondaryColour(curVeh.obj)
                SetVehicleModColor_1(curVeh.obj, curVeh.props['paintType'][1], 0, 0)
                SetVehicleModColor_2(curVeh.obj, curVeh.props['paintType'][2], 0, 0)
                PW.Game.SetVehicleProperties(curVeh.obj, curVeh.props)
            end
            TriggerEvent('pw_mechanic:client:openMenu', prevMenu)
        else
            FreezeEntityPosition(curVeh.obj, false)
            curVeh = nil
        end
    end
end)

RegisterNetEvent('pw_mechanic:client:addRepair')
AddEventHandler('pw_mechanic:client:addRepair', function(cat, opt, args)
    local label = Config.Menu[cat].options[opt].label
    
    local checkPart = CheckForExisting(label)

    if checkPart ~= nil and checkPart ~= false then
        exports.pw_notify:SendAlert('error', 'You already added this service to the cart', 5000)
    else
        table.insert(shoppingCart, { ['label'] = label, ['repair'] = opt, ['args'] = args })
    end
    TriggerEvent('pw_mechanic:client:openMenu', Config.Menu[cat].parent, curVeh.garage)
end)

RegisterNetEvent('pw_mechanic:client:installPart')
AddEventHandler('pw_mechanic:client:installPart', function(data)
    local option, cat, part, level
    local cost = {}
    local newProps = {}
    local toUse = {}
    if data['data']['data'] ~= nil then
        toUse = data['data']['data']
        option = toUse.option
        cat = toUse.cat
    elseif data['data'] ~= nil then
        toUse = data['data']
        option = toUse.option
        cat = toUse.cat
    else
        toUse = data
    end

    part = data.part
    level = data.level
    cost = data.cost or data.data.cost
    
    
    local label = Config.Menu[cat].options[option].label
    if cost ~= nil then
        cost['item'] = option
        cost['label'] = label
    end

    local description
    if option == 'tyreSmokeColor' or option == 'neonColor' or option == 'bodyPrimaryColor' or option == 'bodySecondaryColor' then
        local colors = {}
        colors[1] = data.r
        colors[2] = data.g
        colors[3] = data.b
        
        description = "<b><span style='color: rgba("..colors[1]..","..colors[2]..","..colors[3]..",1.0)'>Color</span></b>: "..colors[1]..", "..colors[2]..", "..colors[3]
        
        if option == 'bodyPrimaryColor' or option == 'bodySecondaryColor' then
            cost.item = 'bodyColor'
            if option == 'bodyPrimaryColor' then
                newProps = { ['paintType'] = { data.data.type, curVeh.props['paintType'][2] }, ['color1'] = colors, ['dirtLevel'] = 0.0 }
            else
                newProps = { ['paintType'] = { curVeh.props['paintType'][1], data.data.type }, ['color2'] = colors, ['dirtLevel'] = 0.0 }
            end
        else
            if option == 'neonColor' then
                local neonAmt = 0
                for i = 1, 4, 1 do
                    if curVeh.props['neonEnabled'][i] then
                        neonAmt = neonAmt + 1
                    end
                end
                cost.hours = math.floor(cost.hours * neonAmt)
                cost.parts = math.floor((cost.parts / 4) * neonAmt)
            end
            newProps = { [option] = colors, ['dirtLevel'] = 0.0 }
        end

    elseif cat == 'wheelTypes' then
        local wheel = data.wheel -- front or back = modFrontWheels, modBackWheels
        local wheelType = data.wheelType -- wheel category
        local wheelIndex = data.wheelIndex -- wheel

        description = (wheel == 23 and 'Wheels' or 'Back Wheels').." (Model: "..wheelIndex..")"
        label = 'Wheels'
        cost.item = 'wheels'
        cost.label = 'Wheels'
        newProps = { [(wheel == 23 and 'modFrontWheels' or 'modBackWheels')] = wheelIndex, ['wheels'] = wheelType }

    elseif cat == 'neons' then
        if data.pricing then 
            data.pricing.option = 'Neon'
        else
            data.data.option = 'Neon'
        end
        if level == 'all' then
            local allNeons = true
            for i = 1, 4, 1 do
                if not curVeh.props['neonEnabled'][i] then
                    allNeons = false
                    break
                end
            end
            if allNeons then
                data.level = 'none'
                description = 'Removal of all neons'
                newProps = { ['neonEnabled'] = {false, false, false, false} }
            else
                newProps = { ['neonEnabled'] = {true, true, true, true} }
                description = 'Four sides'
            end
        else
            local neonNames = { "Left", "Right", "Front", "Back" }
            newProps['neonEnabled'] = {}
            description = (cost.parts == 0 and "Removal of " or "") .. neonNames[level].." side"
            newProps['neonEnabled'][level] = not curVeh.props['neonEnabled'][level]
        end
    else
        if option == 'pearlescentColor' then
            cost.item = 'bodyColor'
        end
        description = (option == 'modXenon' and (level and 'Xenon Install' or 'Xenon Removal')) or (option == 'modTurbo' and (level and 'Turbo Install' or 'Turbo Removal')) or ((level+1) > 0 and "Type: "..((option == 'pearlescentColor' or option == 'wheelColor') and level..' ('..exports.pw_core:getVehicleColor(level)..')' or (cat == 'performance' and (level+1) or level)) or "Stock")
        newProps = { [option] = level }
    end

    local sendData = {}
    if data['pricing'] then
        sendData = { ['vehPrice'] = curVeh.price, ['cat'] = data.pricing.cat, ['piece'] = data.pricing.option, ['level'] = data.level }
    else
        sendData = { ['vehPrice'] = curVeh.price, ['cat'] = data.data.cat, ['piece'] = data.data.option, ['level'] = data.level }
    end

    local checkPart = CheckForExisting(label)
    if checkPart ~= nil and checkPart ~= false then
        AskForReplacement(label, description, newProps, sendData, checkPart, cost)
    else
        table.insert(shoppingCart, { ['label'] = label, ['description'] = description, ['install'] = newProps, ['data'] = sendData, ['cost'] = cost, ['level'] = data.level })
        TriggerEvent('pw_mechanic:client:openMenu', cat)
    end
end)

RegisterNetEvent('pw_mechanic:client:replacePart')
AddEventHandler('pw_mechanic:client:replacePart', function(data)
    shoppingCart[tonumber(data.part.value)] = { ['label'] = data.label.value, ['description'] = data.desc.value, ['install'] = data.props.data, ['data'] = data.data.data, ['cost'] = data.cost.data }
    TriggerEvent('pw_mechanic:client:openPrev')
end)

function AskForReplacement(label, desc, props, data, part, cost)
    local form = {}
    table.insert(form, { ['type'] = 'writting', ['align'] = 'center', ['value'] = "<b>You already have a part of this type added to the cart</b>" })
    table.insert(form, { ['type'] = 'hr' })
    table.insert(form, { ['type'] = 'writting', ['align'] = 'center', ['value'] = "Do you wish to replace it with this one?" })
    table.insert(form, { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'No' })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'label', ['value'] = label })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'desc', ['value'] = desc })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'props', ['data'] = props })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'data', ['data'] = data })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'part', ['value'] = part })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'cost', ['data'] = cost })

    TriggerEvent('pw_interact:generateForm', 'pw_mechanic:client:replacePart', 'client', form)
end

function CheckForExisting(label, desc)
    for k,v in pairs(shoppingCart) do
        if v.label == label then
            if label == "Neon Layout" then
                if v.description == desc then
                    return k
                end
            else
                return k
            end
        end
    end
    return false
end

RegisterNetEvent('pw_mechanic:client:customerAccepts')
AddEventHandler('pw_mechanic:client:customerAccepts', function(data)
    local menu = {}

    table.insert(menu, { ['label'] = "Cash",        ['action'] = 'pw_mechanic:server:payStuff', ['value'] = { ['stuff'] = data, ['type'] = 'cash', ['vehVin'] = data.vin.value, ['vehPlate'] = data.veh.data.plate }, ['triggertype'] = 'server', ['color'] = 'primary' })
    table.insert(menu, { ['label'] = "Debit Card",  ['action'] = 'pw_mechanic:server:payDebit', ['value'] = { ['stuff'] = data, ['type'] = 'debit', ['vehVin'] = data.vin.value, ['vehPlate'] = data.veh.data.plate, ['curGarage'] = tonumber(data.garage.value) }, ['triggertype'] = 'server', ['color'] = 'primary' })

    TriggerEvent('pw_interact:generateMenu', menu, "Choose a Payment Method")
end)

RegisterNetEvent('pw_mechanic:client:showBill')
AddEventHandler('pw_mechanic:client:showBill', function(parts, mech, garage, veh, vin)
    local form = {}
    local totalAmount = 0
    
    for i = 1, #parts do
        if parts[i].repair == nil then
            totalAmount = totalAmount + parts[i].hours + ((parts[i].partsCost ~= nil and parts[i].partsCost > 0) and parts[i].partsCost or 0)
            table.insert(form, { ['type'] = 'writting', ['align'] = 'left', ['value'] = "<b>"..i.."</b>. <b>".. parts[i].itemLabel .. " </b>(" .. parts[i].type .. ")<br>Hour Rate: <b><span class='text-success'>$" .. parts[i].hours .. "</span></b>" .. ((parts[i].partsCost ~= nil and parts[i].partsCost > 0) and " | Parts Cost: <b><span class='text-success'>$"..parts[i].partsCost.."</span></b>" or "")})
            table.insert(form, { ['type'] = 'hr' })
        else
            totalAmount = totalAmount + ((parts[i].partsCost ~= nil and parts[i].partsCost > 0) and parts[i].partsCost or 0)
            table.insert(form, { ['type'] = 'writting', ['align'] = 'left', ['value'] = "<b>"..i.."</b>. <b>".. parts[i].label .. " </b><br>" .. ((parts[i].partsCost ~= nil and parts[i].partsCost > 0) and "Service Cost: <b><span class='text-success'>$"..parts[i].partsCost.."</span></b>" or "")})
            table.insert(form, { ['type'] = 'hr' })
        end
    end
    table.insert(form, { ['type'] = 'writting', ['align'] = 'center', ['value'] = "<b>Total</b>: <b><span class='text-primary'>$"..totalAmount })
    table.insert(form, { ['type'] = 'yesno', ['success'] = 'Pay now', ['reject'] = 'Cancel' })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'parts', ['data'] = parts })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'mech', ['value'] = mech })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'garage', ['value'] = garage })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'veh', ['data'] = veh })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'vin', ['value'] = vin })

    TriggerEvent('pw_interact:generateForm', 'pw_mechanic:client:customerAccepts', 'client', form, "Confirm your order <i>("..#parts..(#parts > 1 and " items" or " item")..")</i>")
end)

RegisterNetEvent('pw_mechanic:client:formAmount')
AddEventHandler('pw_mechanic:client:formAmount', function(data)    
    local form = {}
    local items = data.data

    table.insert(form, { ['type'] = 'writting', ['align'] = 'center', ['value'] = "Confirm everything before submitting"  } )
    table.insert(form, { ['type'] = 'hr' })
    
    for i = 1, #items do    
        if items[i].repair == nil then
            table.insert(form, { ['type'] = 'writting', ['align'] = 'left', ['value'] = "<b>"..i.."</b>. <b>".. items[i].itemLabel .. " </b>(" .. items[i].type .. ")<br>Hour Rate: <b><span class='text-success'>$" .. items[i].hours .. "</b>" })
            if items[i].qty > 0 then
                table.insert(form, { ['type'] = 'number', ['label'] = "Cost of the <b>".. items[i].qty .. " " .. items[i].itemLabel .. "</b> parts (in $)", ['name'] = 'cost'..i })
            end
            if i ~= #items then
                table.insert(form, { ['type'] = 'hr' })
            end
        else
            table.insert(form, { ['type'] = 'writting', ['align'] = 'left', ['value'] = "<b>"..i.."</b>. <b>".. items[i].label .. " </b>" })
            table.insert(form, { ['type'] = 'number', ['label'] = "Cost of this service (in $)", ['name'] = 'cost'..i })
        end
    end
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'parts', ['data'] = data.data })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'garage', ['value'] = data.garage })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'mech', ['value'] = data.mech })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'target', ['value'] = data.target })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'veh', ['data'] = curVeh.props })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'vin', ['value'] = curVeh.vin })

    TriggerEvent('pw_interact:generateForm', 'pw_mechanic:server:sendFormAmount', 'server', form, "Confirm order of " .. #items.." items")
end)

RegisterNetEvent('pw_mechanic:client:paymentConfirmed')
AddEventHandler('pw_mechanic:client:paymentConfirmed', function(props, garage)
    PW.Game.SetVehicleProperties(curVeh.obj, curVeh.props)
    local neons = {}
    for i = 1, #props do
        if props[i].repair == nil then
            if props[i].item == 'neonEnabled' then
                for k,v in pairs(props[i].install.neonEnabled) do
                    neons[k] = v
                end
            else
                if props[i].install['modXenon'] then
                    PW.Game.SetVehicleProperties(curVeh.obj, { ['modXenonColor'] = -1 } )
                end
                PW.Game.SetVehicleProperties(curVeh.obj, props[i].install )
            end
        else
            CarService(props[i].repair, props[i].args)
        end
    end
    for i = 1, 4, 1 do
        if neons[i] == nil then
            neons[i] = curVeh.props['neonEnabled'][i]
        end
    end
    PW.Game.SetVehicleProperties(NetworkGetEntityFromNetworkId(curVeh.net), { ['neonEnabled'] = {neons[1], neons[2], neons[3], neons[4]} } )
    curVeh['props'] = PW.Game.GetVehicleProperties(NetworkGetEntityFromNetworkId(curVeh.net))
    local vin = curVeh.vin
    TriggerServerEvent('pw_mechanic:server:updateProps', vin, curVeh.props, curVeh.net)
    TriggerServerEvent('pw_mechanic:server:deletePending', vin, garage, curVeh.hasPending.order_id)
    curVeh['hasPending'] = false
end)

function CarService(service, args)
    if service == 'clean' then
        PW.Game.SetVehicleProperties(NetworkGetEntityFromNetworkId(curVeh.net), { ['dirtLevel'] = 0.0 })
    elseif service == 'defRepair' then
        SetVehicleDeformationFixed(NetworkGetEntityFromNetworkId(curVeh.net))
        PW.Game.SetVehicleProperties(NetworkGetEntityFromNetworkId(curVeh.net), { ['bodyHealth'] = 1000.0 })
    elseif service == 'repairAll' then
        SetVehicleFixed(NetworkGetEntityFromNetworkId(curVeh.net))
        SetVehicleDeformationFixed(NetworkGetEntityFromNetworkId(curVeh.net))
        PW.Game.SetVehicleProperties(NetworkGetEntityFromNetworkId(curVeh.net), { ['bodyHealth'] = 1000.0 })
    elseif service == 'engineRepair' then
        PW.Game.SetVehicleProperties(NetworkGetEntityFromNetworkId(curVeh.net), { ['engineHealth'] = 1000.0 })
    end
end

RegisterNetEvent('pw_mechanic:client:updateEveryone')
AddEventHandler('pw_mechanic:client:updateEveryone', function(props, vNet)
    PW.Game.SetVehicleProperties(NetworkGetEntityFromNetworkId(vNet), props)
end)

RegisterNetEvent('pw_mechanic:client:previewPart')
AddEventHandler('pw_mechanic:client:previewPart', function(data)
    showing = false
    previewing = true
    local oldProps = PW.Game.GetVehicleProperties(curVeh.obj)
    local newProp = { [data.data.option] = data.level }
    PW.Game.SetVehicleProperties(curVeh.obj, newProp)
    if data.data.option == 'modHorns' then exports.pw_notify:PersistentAlert('start', 'horn', 'inform', 'Play the horn for the customer'); end
    Citizen.Wait(3000)
    if data.data.option == 'modHorns' then exports.pw_notify:PersistentAlert('end', 'horn'); end
    PW.Game.SetVehicleProperties(curVeh.obj, oldProps)
    previewing = false
    OpenCustomizationOptions(data.data)
end)

RegisterNetEvent('pw_mechanic:client:loadPart')
AddEventHandler('pw_mechanic:client:loadPart', function(data)
    if not IsVehicleModLoadDone(curVeh.obj) then
        Wait(10)
    end

    PW.Game.SetVehicleProperties(curVeh.obj, { [data.data.option] = data.level })
    TriggerEvent('pw_interact:enableSlider')
end)

function OpenDoors(doors)
    for i = 1, #doors do
        SetVehicleDoorOpen(curVeh.obj, doors[i], false)
    end
end

function GetMakeParts(make)
    local avg, sendParts, tier
    PW.TriggerServerCallback('pw_mechanic:server:getMakeAvg', function(avrg)
        avg = math.floor(avrg)
        for i = 1, #Config.AvgMakes do
            if avg < Config.AvgMakes[i].maxValue then
                sendParts = Config.AvgMakes[i].cost
                tier = i
                break
            end
        end
        if sendParts == nil then
            sendParts = 5
            tier = 4
        end
    end, make)

    repeat Wait(0) until sendParts ~= nil
    return sendParts, tier
end

function GetPiecePrice(cat, opt, level, withParts)
    local sendHour, sendParts, tier
    local make = exports.pw_vehicleshop:vehicleMakes(GetDisplayNameFromVehicleModel(curVeh.props['model']))
    if withParts == nil then withParts = false; end
    if make == nil then make = 'Stock'; end
    if not withParts then
        for k,v in pairs(Config.Prices) do
            if k == make then
                sendHour = v[cat]
            end
        end
    end
    
    sendParts, tier = GetMakeParts(make)

    if level ~= nil then
        if not level or level == -1  then
            if not withParts then
                return sendHour, 0
            else
                return 0, 0
            end
        elseif level == true then level = 1; end        
    else
        level = 1
    end
    if not withParts then
        sendParts = sendParts + (level * tier)
        return sendHour, sendParts
    else
        return sendParts, tier
    end
end

RegisterNetEvent('pw_mechanic:client:pickColor')
AddEventHandler('pw_mechanic:client:pickColor', function(data)
    PickColor(data.color, data.color, data.data)
end)

function PickColor(type, color, data)
    local hourlyCost, partsCost = GetPiecePrice(data.cat, data.option, 1)
    TriggerEvent('pw_interact:generateColorPicker', { ['saveTrigger'] = { ['trigger'] = "pw_mechanic:client:installPart", ['type'] = "client" }, ['previewTrigger'] = { ['trigger'] = "pw_mechanic:client:previewPaintColor", ['type'] = "client" } }, 'Vehicle '..(color == 'color1' and 'Primary' or 'Secondary')..' Color', { ['type'] = type, ['data'] = data, ['cost'] = { ['hours'] = (Config.MySQL[curVeh.garage].hourRate * hourlyCost), ['parts'] = partsCost } }, { menuSwitcher = true, autoPreview = true }, { { ['trigger'] = 'pw_mechanic:client:openPrev', ['method'] = 'client' } })
end

function ColorType(part, data)
    local menu = {}
    for k,v in pairs(Config.PaintTypes) do
        table.insert(menu, { ['label'] = v.label, ['action'] = 'pw_mechanic:client:pickColor', ['value'] = { ['color'] = v.index, ['part'] = part, ['data'] = data }, ['triggertype'] = 'client', ['color'] = 'primary' } )
    end

    TriggerEvent('pw_interact:generateMenu', menu, "Paint Type")
end

function OpenCustomizationOptions(data)

    SetVehicleModKit(curVeh.obj, 0)
    curVeh['props'] = PW.Game.GetVehicleProperties(curVeh.obj)
    
    local menuStyle = 'menu'
    local sub, menu = {}, {}
    local installed = false

    local chosen = Config.Menu[data.cat].options[data.option]
    prevMenu = chosen.parent
    local modCount = GetNumVehicleMods(curVeh.obj, (chosen.part == 'modLivery' and 48 or chosen.part))
    
    if chosen.open ~= nil and chosen.open[1] ~= nil then
        OpenDoors(chosen.open)
    else
        SetVehicleDoorsShut(curVeh.obj, false)
    end
    local hourlyCost, partsCost, hCalc
    if data.cat == 'performance' then
        if data.option == 'modTurbo' then
            local turboLabel
            hourlyCost, partsCost = GetPiecePrice(data.cat, data.option, 1)
            hCalc = hourlyCost * Config.MySQL[curVeh.garage]['hourRate']
            if curVeh.props[data.option] then
                turboLabel = chosen.label .. " (Installed)"
                installed = true
            else
                sub = {}
                table.insert(sub, { ['label'] = "Cost: <b><span class='text-success'>$" .. hCalc  .."</span></b>", ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' } )
                table.insert(sub, { ['label'] = "+ <b><span class='text-primary'>" .. partsCost .. "</span></b> " .. chosen.label .. " parts", ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' })
                table.insert(sub, { ['label'] = "<b>Install</b>", ['action'] = 'pw_mechanic:client:installPart', ['value'] = { ['data'] = data, ['part'] = chosen.part, ['level'] = true, ['cost'] = { ['hours'] = (hourlyCost * Config.MySQL[curVeh.garage]['hourRate']), ['parts'] = partsCost }, ['pricing'] = { ['cat'] = data.cat, ['option'] = data.option, ['item'] = chosen.item } }, ['triggertype'] = 'client' })
                turboLabel = chosen.label
                installed = false
            end

            table.insert(menu, { ['label'] = "Stock"..(not installed and " (Installed)" or ""), ['color'] = (not installed and "success disabled" or "primary") })
            if installed then 
                sub = {}
                table.insert(sub, { ['label'] = "Cost: <b><span class='text-success'>$" .. hCalc  .."</span></b>", ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' } )
                table.insert(sub, { ['label'] = "<b>Install</b>", ['action'] = 'pw_mechanic:client:installPart', ['value'] = { ['data'] = data, ['part'] = chosen.part, ['level'] = false, ['cost'] = { ['hours'] = (hourlyCost * Config.MySQL[curVeh.garage]['hourRate']), ['parts'] = 0 } }, ['triggertype'] = 'client' })
                menu[#menu]['subMenu'] = sub
            end
            table.insert(menu, { ['label'] = turboLabel, ['color'] = (installed and "success disabled" or "primary")})
            if not installed then menu[#menu]['subMenu'] = sub; end
        else
            local tempTablePerf = {}
            hourlyCost, partsCost = GetPiecePrice(data.cat, data.option, 1)
            hCalc = hourlyCost * Config.MySQL[curVeh.garage]['hourRate']
            installed = (curVeh.props[data.option] == -1 and true or false)
            table.insert(menu, { ['label'] = (installed and "Stock (Installed)" or "Stock"), ['color'] = (installed and "success disabled" or "primary") })
            if not installed then 
                sub = {}
                table.insert(sub, { ['label'] = "Cost: <b><span class='text-success'>$" .. hCalc  .."</span></b>", ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' } )
                table.insert(sub, { ['label'] = "<b>Install</b>", ['action'] = 'pw_mechanic:client:installPart', ['value'] = { ['data'] = data, ['part'] = chosen.part, ['level'] = -1, ['cost'] = { ['hours'] = (hourlyCost * Config.MySQL[curVeh.garage]['hourRate']), ['parts'] = 0 } }, ['triggertype'] = 'client' })
                menu[#menu]['subMenu'] = sub
            end
            partsCost, tier = GetPiecePrice(data.cat, data.option, 1, true)
            for i = 0, modCount-1, 1 do
                local menuLabel
                if i == curVeh.props[data.option] then
                    menuLabel = "Level "..(i+1).." (Installed)"
                    installed = true
                else
                    sub = {}
                    menuLabel ="Level "..(i+1)
                    installed = false
                    local newPartsCost = partsCost + ((i+1) * tier)
                    table.insert(sub, { ['label'] = "Cost: <b><span class='text-success'>$" .. hourlyCost * Config.MySQL[curVeh.garage]['hourRate'] .."</span></b>", ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' } )
                    table.insert(sub, { ['label'] = "+ <b><span class='text-primary'>" .. newPartsCost .. "</span></b> " .. chosen.label .. " parts", ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' })
                    if data.option == 'modSuspension' then
                        table.insert(sub, { ['label'] = "Preview", ['action'] = 'pw_mechanic:client:previewPart', ['value'] = { ['data'] = data, ['part'] = chosen.part, ['level'] = i }, ['triggertype'] = 'client' })
                    end
                    table.insert(sub, { ['label'] = "<b>Install</b>", ['action'] = 'pw_mechanic:client:installPart', ['value'] = { ['data'] = data, ['part'] = chosen.part, ['level'] = i, ['cost'] = { ['hours'] = (hourlyCost * Config.MySQL[curVeh.garage]['hourRate']), ['parts'] = newPartsCost }, ['pricing'] = { ['cat'] = data.cat, ['option'] = data.option } }, ['triggertype'] = 'client' })
                end
                table.insert(tempTablePerf, { ['label'] = menuLabel, ['color'] = (installed and 'success disabled' or 'primary') })
                if not installed then tempTablePerf[#tempTablePerf]['subMenu'] = sub; end
            end
            table.sort(tempTablePerf, function(a,b) return a.label < b.label end)
            for k,v in pairs(tempTablePerf) do
                table.insert(menu, v)
            end
        end
    elseif data.cat == 'cosmetics' then
        hourlyCost, partsCost = GetPiecePrice(data.cat, data.option, 1)
        if chosen.part == 'windowTint' then
            menuStyle = 'slider'
            local tempTableWindow = {}
            for k,v in pairs(Config.WindowName) do
                local windowLabel = v.label
                if v.index == curVeh.props['windowTint'] then
                    installed = true
                    windowLabel = windowLabel .. "<br>(Installed)"
                else
                    installed = false
                    windowLabel = windowLabel .. "<br>$"
                end
                table.insert(menu, { ['label'] = windowLabel, ['data'] = { ['data'] = data, ['part'] = chosen.part, ['level'] = v.index, ['cost'] = { ['hours'] = (hourlyCost * Config.MySQL[curVeh.garage]['hourRate']), ['parts'] = partsCost }, ['trigger'] = "pw_mechanic:client:loadPart", ['triggerType'] = "client"}, ['infoHtml'] = { ['type'] = "popover", ['title'] = "Requirements", ['content'] = "Cost: <b><span class='text-success'>$"..(hourlyCost * Config.MySQL[curVeh.garage]['hourRate']).."</span></b><br>+ <b><span class='text-primary'>" .. partsCost .. "</span></b> " .. chosen.label .. " parts" } })
            end
            
            table.sort(menu, function(a,b) return a.label < b.label end)
        
            TriggerEvent('pw_interact:generateSlider', menu, 'pw_mechanic:client:installPart', 'client', chosen.label, "", {vehicle = true, menuSwitcher = true }, { { ['trigger'] = 'pw_mechanic:client:openPrev', ['method'] = 'client' } } )
        elseif data.option == 'modHorns' then
            local tempTableHorns = {}
            for i = 0, 51, 1 do
                local hornLabel = GetHornName(i)
                if i == curVeh.props[data.option] then
                    hornLabel = hornLabel .. " (Installed)"
                    installed = true
                else
                    hornLabel = hornLabel .. " $"
                    installed = false
                    sub = {}
                    table.insert(sub, { ['label'] = "Cost: <b><span class='text-success'>$" .. hourlyCost * Config.MySQL[curVeh.garage]['hourRate'] .."</span></b>", ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' } )
                    table.insert(sub, { ['label'] = "+ <b><span class='text-primary'>" .. partsCost .. "</span></b> " .. chosen.label .. " parts", ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' })
                    table.insert(sub, { ['label'] = "Preview", ['action'] = 'pw_mechanic:client:previewPart', ['value'] = { ['data'] = data, ['part'] = chosen.part, ['level'] = i }, ['triggertype'] = 'client' })
                    table.insert(sub, { ['label'] = "<b>Install</b>", ['action'] = 'pw_mechanic:client:installPart', ['value'] = { ['data'] = data, ['part'] = chosen.part, ['level'] = i, ['cost'] = { ['hours'] = (hourlyCost * Config.MySQL[curVeh.garage]['hourRate']), ['parts'] = partsCost } }, ['triggertype'] = 'client' })
                end
                table.insert(tempTableHorns, { ['label'] = hornLabel, ['color'] = (installed and 'success disabled' or 'primary') })
                if not installed then tempTableHorns[#tempTableHorns]['subMenu'] = sub; end
                table.sort(tempTableHorns, function(a,b) return a.label < b.label end)
            end
            installed = (curVeh.props[data.option] == -1 and true or false)
            table.insert(menu, { ['label'] = (installed and "Stock (Installed)" or "Stock"), ['color'] = (installed and "success disabled" or "primary") })
            if not installed then 
                sub = {}
                table.insert(sub, { ['label'] = "<b>Install</b>", ['action'] = 'pw_mechanic:client:installPart', ['value'] = { ['data'] = data, ['part'] = chosen.part, ['level'] = -1, ['cost'] = { ['hours'] = (hourlyCost * Config.MySQL[curVeh.garage]['hourRate']), ['parts'] = 0 } }, ['triggertype'] = 'client' })
                menu[#menu]['subMenu'] = sub
            end
            for k,v in pairs(tempTableHorns) do
                table.insert(menu, v)
            end
        elseif (chosen.part and type(chosen.part) == 'number') then
            menuStyle = 'slider'
            local tempTableCosmetics = {}
            for i = 0, modCount, 1 do
                local partLabel = GetModTextLabel(curVeh.obj, chosen.part, i)
                if partLabel then
                    local newLabel = GetLabelText(partLabel)
                    if newLabel == "NULL" then newLabel = chosen.label .. " " .. i; end
                    if i == curVeh.props[data.option] then
                        newLabel = newLabel .. " <br>(Installed)"
                        installed = true
                    else
                        newLabel = newLabel .. " <br>$"
                        installed = false
                    end
                    table.insert(tempTableCosmetics, { ['label'] = newLabel, ['data'] = { ['data'] = data, ['part'] = chosen.part, ['level'] = i, ['cost'] = { ['hours'] = (hourlyCost * Config.MySQL[curVeh.garage]['hourRate']), ['parts'] = partsCost }, ['trigger'] = "pw_mechanic:client:loadPart", ['triggerType'] = "client"}, ['infoHtml'] = { ['type'] = "popover", ['title'] = "Requirements", ['content'] = "Cost: <b><span class='text-success'>$"..(hourlyCost * Config.MySQL[curVeh.garage]['hourRate']).."</span></b><br>+ <b><span class='text-primary'>" .. partsCost .. "</span></b> " .. chosen.label .. " parts" } })
                end
            end
            table.sort(tempTableCosmetics, function(a,b) return a.label < b.label end)
            installed = (curVeh.props[data.option] == -1 and true or false)
            table.insert(menu, { ['label'] = (installed and "Stock <br>(Installed)" or "Stock"), ['data'] = { ['data'] = data, ['part'] = chosen.part, ['level'] = -1, ['cost'] = { ['hours'] = (hourlyCost * Config.MySQL[curVeh.garage]['hourRate']), ['parts'] = 0 }, ['trigger'] = "pw_mechanic:client:loadPart", ['triggerType'] = "client"} })
            for k,v in pairs(tempTableCosmetics) do
                table.insert(menu, v)
            end
            TriggerEvent('pw_interact:generateSlider', menu, 'pw_mechanic:client:installPart', 'client', chosen.label, "", {vehicle = true, menuSwitcher = true}, { { ['trigger'] = 'pw_mechanic:client:openPrev', ['method'] = 'client' } } )
        end
    elseif data.cat == 'bodyParts' or (data.cat == 'plates' and chosen.part ~= 'plateIndex') then
        hourlyCost, partsCost = GetPiecePrice(data.cat, data.option, 1)
        menuStyle = 'slider'
        local tempTableBody = {}
        for i = 0, modCount, 1 do
            local partLabel = GetModTextLabel(curVeh.obj, chosen.part, i)
            if partLabel then
                local newLabel = GetLabelText(partLabel)
                if newLabel == "NULL" then newLabel = chosen.label .. " " .. i; end
                if i == curVeh.props[data.option] then
                    newLabel = newLabel .. " <br>(Installed)"
                    installed = true
                else
                    newLabel = newLabel .. " <br>$"
                    installed = false
                end
                table.insert(tempTableBody, { ['label'] = newLabel, ['data'] = { ['data'] = data, ['part'] = chosen.part, ['level'] = i, ['cost'] = { ['hours'] = (hourlyCost * Config.MySQL[curVeh.garage]['hourRate']), ['parts'] = partsCost },  ['trigger'] = "pw_mechanic:client:loadPart", ['triggerType'] = "client"}, ['infoHtml'] = { ['type'] = "popover", ['title'] = "Type: "..i, ['content'] = "Cost: <b><span class='text-success'>$"..(hourlyCost * Config.MySQL[curVeh.garage]['hourRate']).."</span></b><br>+ <b><span class='text-primary'>" .. partsCost .. "</span></b> " .. chosen.label .. " parts" } })
                --table.insert(tempTableBody, { ['label'] = newLabel, ['data'] = { ['data'] = data, ['part'] = chosen.part, ['level'] = i, ['trigger'] = "pw_mechanic:client:loadPart", ['triggerType'] = "client"} })
            end
        end
        table.sort(tempTableBody, function(a,b) return a.label < b.label end)
        installed = (curVeh.props[data.option] == -1 and true or false)
        table.insert(menu, { ['label'] = (installed and "Stock <br>(Installed)" or "Stock"), ['data'] = { ['data'] = data, ['part'] = chosen.part, ['level'] = -1, ['item'] = data.option, ['cost'] = { ['hours'] = (hourlyCost * Config.MySQL[curVeh.garage]['hourRate']), ['parts'] = 0 }, ['trigger'] = "pw_mechanic:client:loadPart", ['triggerType'] = "client"}, ['infoHtml'] = { ['type'] = "popover", ['title'] = "Requirements", ['content'] = "Cost: <b><span class='text-success'>$"..(hourlyCost * Config.MySQL[curVeh.garage]['hourRate']).."</span></b>" } })
        for k,v in pairs(tempTableBody) do
            table.insert(menu, v)
        end
        TriggerEvent('pw_interact:generateSlider', menu, 'pw_mechanic:client:installPart', 'client', chosen.label, "", {vehicle = true, menuSwitcher = true}, { { ['trigger'] = 'pw_mechanic:client:openPrev', ['method'] = 'client' } } )
    elseif data.cat == 'colors' then
        hourlyCost, partsCost = GetPiecePrice(data.cat, data.option, 1)
        if chosen.part == 'color1' or chosen.part == 'color2' then
            ColorType(chosen.part, data)            
        elseif chosen.part ~= 'modLivery' then
            for k,v in pairs(Config.Colors) do
                table.insert(menu, { ['label'] = v.label, ['action'] = 'pw_mechanic:client:paint', ['value'] = { ['option'] = Config.Menu['colors'].options[data.option].part, ['colorGroup'] = v.value, ['data'] = data }, ['triggertype'] = 'client', ['color'] = 'primary' })
            end
            table.sort(menu, function(a,b) return a.label < b.label end)
        else
            menuStyle = 'slider'
            SetVehicleModKit(curVeh.obj, 0)
            local tempLivery = {}
            local found = false
            local liveryCount = (GetVehicleLiveryCount(curVeh.obj) > 0 and GetVehicleLiveryCount(curVeh.obj)) or modCount
            for i = 0, liveryCount-1, 1 do
                local liveryLabel = GetLabelText(GetModTextLabel(curVeh.obj, 48, i))
                if liveryLabel == nil or liveryLabel == "NULL" then liveryLabel = "Livery "..(i+1); end
                if i == GetVehicleLivery(curVeh.obj) then
                    liveryLabel = liveryLabel .. " <br>(Installed)"
                    found = true
                end
                table.insert(tempLivery, { ['label'] = liveryLabel, ['data'] = { ['level'] = i, ['part'] = chosen.part, ['data'] = data, ['cost'] = { ['hours'] = (hourlyCost * Config.MySQL[curVeh.garage]['hourRate']), ['parts'] = partsCost }, ['trigger'] = "pw_mechanic:client:loadPaint", ['triggerType'] = "client"}, ['infoHtml'] = { ['type'] = "popover", ['title'] = "Type: "..i, ['content'] = "Cost: <b><span class='text-success'>$"..(hourlyCost * Config.MySQL[curVeh.garage]['hourRate']).."</span></b><br>+ <b><span class='text-primary'>" .. partsCost .. "</span></b> " .. chosen.label .. " parts" } })
            end
            table.insert(menu, { ['label'] = "No Livery"..(not found and "<br>(Installed)" or "<br>$"), ['data'] = { ['level'] = -1, ['part'] = chosen.part, ['data'] = data, ['cost'] = { ['hours'] = (hourlyCost * Config.MySQL[curVeh.garage]['hourRate']), ['parts'] = 0 }, ['trigger'] = "pw_mechanic:client:loadPaint", ['triggerType'] = "client"}, ['infoHtml'] = { ['type'] = "popover", ['title'] = "Stock", ['content'] = "Cost: <b><span class='text-success'>$"..(hourlyCost * Config.MySQL[curVeh.garage]['hourRate']).."</span></b>" } })
            table.sort(tempLivery, function(a,b) return a.data.level < b.data.level end)
            for k,v in pairs(tempLivery) do
                table.insert(menu, v)
            end
            TriggerEvent('pw_interact:generateSlider', menu, 'pw_mechanic:client:installPart', 'client', chosen.label, "", {vehicle = true, menuSwitcher = true}, { { ['trigger'] = 'pw_mechanic:client:openPrev', ['method'] = 'client' } } )
        end
    elseif data.cat == 'xenonHeadlights' then
        hourlyCost, partsCost = GetPiecePrice(data.cat, data.option, 1)
        SetVehicleLights(curVeh.obj, 2)
        if chosen.part == 'modXenon' then
            if curVeh.props['modXenon'] then
                installed = true
            end
            table.insert(menu, { ['label'] = "Stock"..(not installed and " (Installed)" or ""), ['color'] = (not installed and "success disabled" or "primary") })
            if installed then
                sub = {}
                table.insert(sub, { ['label'] = "Cost: <b><span class='text-success'>$" .. hourlyCost * Config.MySQL[curVeh.garage]['hourRate'] .."</span></b>", ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' } )
                table.insert(sub, { ['label'] = "<b>Install</b>", ['action'] = 'pw_mechanic:client:installPart', ['value'] = { ['data'] = data, ['part'] = chosen.part, ['level'] = false, ['cost'] = { ['hours'] = (hourlyCost * Config.MySQL[curVeh.garage]['hourRate']), ['parts'] = 0 } }, ['triggertype'] = 'client' })
                menu[#menu]['subMenu'] = sub
            end
            table.insert(menu, { ['label'] = "Xenon"..(installed and " (Installed)" or ""), ['color'] = (installed and "success disabled" or "primary") })
            if not installed then
                sub = {}
                table.insert(sub, { ['label'] = "Cost: <b><span class='text-success'>$" .. hourlyCost * Config.MySQL[curVeh.garage]['hourRate'] .."</span></b>", ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' } )
                table.insert(sub, { ['label'] = "+ <b><span class='text-primary'>" .. partsCost .. "</span></b> " .. chosen.label .. " parts", ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' })
                table.insert(sub, { ['label'] = "<b>Install</b>", ['action'] = 'pw_mechanic:client:installPart', ['value'] = { ['data'] = data, ['part'] = chosen.part, ['level'] = true, ['cost'] = { ['hours'] = (hourlyCost * Config.MySQL[curVeh.garage]['hourRate']), ['parts'] = partsCost } }, ['triggertype'] = 'client' })
                menu[#menu]['subMenu'] = sub
            end
        elseif chosen.part == 'modXenonColor' then
            menuStyle = 'slider'
            for k,v in pairs(Config.XenonColors) do
                local xenonLabel = v.label
                if v.color == curVeh.props['modXenonColor'] then
                    xenonLabel = xenonLabel.." (Installed)"
                end
            
                table.insert(menu, { ['label'] = xenonLabel, ['data'] = { ['level'] = v.color, ['part'] = chosen.part, ['data'] = data, ['cost'] = { ['hours'] = (hourlyCost * Config.MySQL[curVeh.garage]['hourRate']), ['parts'] = partsCost }, ['trigger'] = "pw_mechanic:client:loadPaint", ['triggerType'] = "client"}, ['infoHtml'] = { ['type'] = "popover", ['title'] = "Type: "..v.label, ['content'] = "Cost: <b><span class='text-success'>$"..(hourlyCost * Config.MySQL[curVeh.garage]['hourRate']).."</span></b><br>+ <b><span class='text-primary'>" .. partsCost .. "</span></b> " .. chosen.label .. " parts" } })
            end
            table.sort(menu, function(a,b) return a.data.level < b.data.level end)
            TriggerEvent('pw_interact:generateSlider', menu, 'pw_mechanic:client:installPart', 'client', "Xenon Headlight Color", "", {vehicle = true, menuSwitcher = true}, { { ['trigger'] = 'pw_mechanic:client:openPrev', ['method'] = 'client' } } )
        end
    elseif data.cat == 'plates' then
        hourlyCost, partsCost = GetPiecePrice(data.cat, data.option, 1)
        if chosen.part == 'plateIndex' then
            menuStyle = 'slider'
            for i = 0, #Config.PlateIndex-1, 1 do
                local plateLabel = Config.PlateIndex[i+1].label
                if i == curVeh.props['plateIndex'] then
                    plateLabel = plateLabel .. " <br>(Installed)"
                    installed = true
                else
                    plateLabel = plateLabel .. " <br>$"
                    installed = false
                end
                table.insert(menu, { ['label'] = plateLabel, ['data'] = { ['level'] = Config.PlateIndex[i+1].index, ['part'] = chosen.part, ['data'] = data, ['cost'] = { ['hours'] = (hourlyCost * Config.MySQL[curVeh.garage]['hourRate']), ['parts'] = partsCost }, ['trigger'] = "pw_mechanic:client:loadPaint", ['triggerType'] = "client"}, ['infoHtml'] = { ['type'] = "popover", ['title'] = "Type: "..i, ['content'] = "Cost: <b><span class='text-success'>$"..(hourlyCost * Config.MySQL[curVeh.garage]['hourRate']).."</span></b><br>+ <b><span class='text-primary'>" .. partsCost .. "</span></b> " .. chosen.label .. " parts" } })
            end
            table.sort(menu, function(a,b) return a.label < b.label end)
            TriggerEvent('pw_interact:generateSlider', menu, 'pw_mechanic:client:installPart', 'client', "Plate Styling", "", {vehicle = true, menuSwitcher = true}, { { ['trigger'] = 'pw_mechanic:client:openPrev', ['method'] = 'client' } } )
        end
    elseif data.cat == 'speakers' then
        hourlyCost, partsCost = GetPiecePrice(data.cat, data.option, 1)
        if (chosen.part and type(chosen.part) == 'number') then
            menuStyle = 'slider'
            local tempTableSpeakers = {}
            for i = 0, modCount, 1 do
                local partLabel = GetModTextLabel(curVeh.obj, chosen.part, i)
                if partLabel then
                    local newLabel = GetLabelText(partLabel)
                    if newLabel == "NULL" then newLabel = chosen.label .. " " .. i; end
                    if i == curVeh.props[data.option] then
                        newLabel = newLabel .. " <br>(Installed)"
                        installed = true
                    else
                        newLabel = newLabel .. " <br>$"
                        installed = false
                    end
                    table.insert(tempTableSpeakers, { ['label'] = newLabel, ['data'] = { ['data'] = data, ['part'] = chosen.part, ['level'] = i, ['cost'] = { ['hours'] = (hourlyCost * Config.MySQL[curVeh.garage]['hourRate']), ['parts'] = partsCost }, ['trigger'] = "pw_mechanic:client:loadPart", ['triggerType'] = "client"}, ['infoHtml'] = { ['type'] = "popover", ['title'] = "Type: "..i, ['content'] = "Cost: <b><span class='text-success'>$"..(hourlyCost * Config.MySQL[curVeh.garage]['hourRate']).."</span></b><br>+ <b><span class='text-primary'>" .. partsCost .. "</span></b> " .. chosen.label .. " parts" } })
                end
            end
            table.sort(tempTableSpeakers, function(a,b) return a.label < b.label end)
            installed = (curVeh.props[data.option] == -1 and true or false)
            table.insert(menu, { ['label'] = (installed and "Stock <br>(Installed)" or "Stock"), ['data'] = { ['data'] = data, ['part'] = chosen.part, ['level'] = -1, ['cost'] = { ['hours'] = (hourlyCost * Config.MySQL[curVeh.garage]['hourRate']), ['parts'] = 0 }, ['trigger'] = "pw_mechanic:client:loadPart", ['triggerType'] = "client"}, ['infoHtml'] = { ['type'] = "popover", ['title'] = "Stock", ['content'] = "Cost: <b><span class='text-success'>$"..(hourlyCost * Config.MySQL[curVeh.garage]['hourRate']).."</span></b>" } })
            for k,v in pairs(tempTableSpeakers) do
                table.insert(menu, v)
            end
            TriggerEvent('pw_interact:generateSlider', menu, 'pw_mechanic:client:installPart', 'client', chosen.label, "", {vehicle = true, menuSwitcher = true}, { { ['trigger'] = 'pw_mechanic:client:openPrev', ['method'] = 'client' } } )
        end
    elseif data.cat == 'wheelTypes' then
        local class = GetVehicleClass(curVeh.obj)
        if class == 8 then
            OpenWheelsMenu(chosen.type, chosen.label, true, data)
        else
            OpenWheelsMenu(chosen.type, chosen.label, false, data)
        end
    elseif data.cat == 'wheels' then
        if chosen.part == 'tyreSmokeColor' then
            hourlyCost, partsCost = GetPiecePrice(data.cat, data.option, 1)
            TriggerEvent('pw_interact:generateColorPicker', { ['saveTrigger'] = { ['trigger'] = "pw_mechanic:client:installPart", ['type'] = "client" }, ['previewTrigger'] = { ['trigger'] = "pw_mechanic:client:previewSmokeColor", ['type'] = "client" } }, 'Smoke Color', { ['data'] = data, ['cost'] = { ['hours'] = (Config.MySQL[curVeh.garage].hourRate * hourlyCost), ['parts'] = partsCost } }, { menuSwitcher = true, autoPreview = true }, { { ['trigger'] = 'pw_mechanic:client:openPrev', ['method'] = 'client' } })
        end
    elseif data.cat == 'neons' then
        hourlyCost, partsCost = GetPiecePrice(data.cat, data.option, 1)
        if chosen.part == 'neonColor' then
            TriggerEvent('pw_interact:generateColorPicker', { ['saveTrigger'] = { ['trigger'] = "pw_mechanic:client:installPart", ['type'] = "client" }, ['previewTrigger'] = { ['trigger'] = "pw_mechanic:client:previewNeonColor", ['type'] = "client" } }, 'Neon Color', { ['data'] = data, ['cost'] = { ['hours'] = (Config.MySQL[curVeh.garage].hourRate * hourlyCost), ['parts'] = partsCost } }, { menuSwitcher = true, autoPreview = true }, { { ['trigger'] = 'pw_mechanic:client:openPrev', ['method'] = 'client' } })
        elseif chosen.part == 'neonEnabled' then
            local neonNames = { "Left", "Right", "Front", "Back" }
            hourlyCost, partsCost = GetPiecePrice(data.cat, data.option, 1)
            for i = 1, 4, 1 do
                sub = {}
                local enabled = curVeh.props['neonEnabled'][i]
                table.insert(sub, { ['label'] = "Cost: <b><span class='text-success'>$" .. hourlyCost * Config.MySQL[curVeh.garage]['hourRate'] .."</span></b>", ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' } )
                if not enabled then
                    table.insert(sub, { ['label'] = "+ <b><span class='text-primary'>" .. (math.floor(partsCost / 4)) .. "</span></b> Neon parts", ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' })
                end
                table.insert(sub, { ['label'] = (enabled and 'Remove' or '<b>Install</b>'), ['action'] = 'pw_mechanic:client:installPart', ['value'] = {['data'] = data, ['part'] = 'neon', ['level'] = i, ['cost'] = { ['hours'] = (hourlyCost * Config.MySQL[curVeh.garage]['hourRate']), ['parts'] = (not enabled and (partsCost / 4) or 0), ['removal'] = enabled}}, ['triggertype'] = 'client' } )
                table.insert(menu, { ['label'] = neonNames[i], ['color'] = (enabled and "success" or "primary"), ['subMenu'] = sub })
            end
            local allNeons = true
            local missingNeons = 0
            for i = 1, 4, 1 do
                if not curVeh.props['neonEnabled'][i] then
                    allNeons = false
                    missingNeons = missingNeons + 1
                end
            end
            sub = {}
            hourlyCost = hourlyCost * (missingNeons == 0 and 4 or missingNeons)
            table.insert(sub, { ['label'] = "Cost: <b><span class='text-success'>$" .. hourlyCost * Config.MySQL[curVeh.garage]['hourRate'] .."</span></b>", ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' } )
            if not allNeons then
                partsCost = (partsCost / 4) * missingNeons
                table.insert(sub, { ['label'] = "+ <b><span class='text-primary'>" .. (math.floor(partsCost)) .. "</span></b> Neon parts", ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' })
            end
            table.insert(sub, { ['label'] = (allNeons and 'Remove' or '<b>Install</b>'), ['action'] = 'pw_mechanic:client:installPart', ['value'] = {['data'] = data, ['part'] = 'neon', ['level'] = 'all', ['cost'] = { ['hours'] = (hourlyCost * Config.MySQL[curVeh.garage]['hourRate']), ['parts'] = (allNeons and 0 or partsCost), ['removal'] = allNeons}}, ['triggertype'] = 'client' } )
            table.insert(menu, { ['label'] = "All", ['color'] = (allNeons and "success" or "primary"), ['subMenu'] = sub })
        end
    elseif data.cat == "bodyRepair" or "mechRepair" then
        if data.option ~= "bodyhealth" then
            TriggerEvent('pw_mechanic:client:addRepair', data.cat, data.option)
        end
    end

    if menuStyle == 'menu' then
        if #menu > 0 then
            TriggerEvent('pw_interact:generateMenu', menu, "<b>"..Config.Menu[data.cat].options[data.option].label.."</b>", { { ['trigger'] = 'pw_mechanic:client:openPrev', ['method'] = 'client' } })
        end
    end
end

RegisterNetEvent('pw_mechanic:client:previewPaintColor')
AddEventHandler('pw_mechanic:client:previewPaintColor', function(data)
    local colors = {}
    colors[1] = tonumber(data.r)
    colors[2] = tonumber(data.g)
    colors[3] = tonumber(data.b)
    
    --local oldProps = PW.Game.GetVehicleProperties(curVeh.obj)
    

    local newProp = { ['paintType'] =  {( data.data.data.option == 'bodyPrimaryColor' and data.data.type or curVeh.props['paintType'][1] ) , (data.data.data.option == 'bodySecondaryColor' and data.data.type or curVeh.props['paintType'][2])}, [(data.data.data.option == 'bodyPrimaryColor' and 'color1' or 'color2')] = colors }
    PW.Game.SetVehicleProperties(curVeh.obj, newProp)
    --OpenCustomizationOptions(data.data.data)]]
end)

RegisterNetEvent('pw_mechanic:client:previewNeonColor')
AddEventHandler('pw_mechanic:client:previewNeonColor', function(data)    
    local colors = {}
    colors[1] = tonumber(data.r)
    colors[2] = tonumber(data.g)
    colors[3] = tonumber(data.b)
    
    --local oldProps = PW.Game.GetVehicleProperties(curVeh.obj)
    local newProp = { ['neonColor'] = colors }
    PW.Game.SetVehicleProperties(curVeh.obj, newProp)
    for i = 0, 3, 1 do
        SetVehicleNeonLightEnabled(curVeh.obj, i, true)
    end
    --OpenCustomizationOptions(data.data.data)
end)

RegisterNetEvent('pw_mechanic:client:previewSmokeColor')
AddEventHandler('pw_mechanic:client:previewSmokeColor', function(data)    
    local colors = {}
    colors[1] = tonumber(data.r)
    colors[2] = tonumber(data.g)
    colors[3] = tonumber(data.b)
    
    --local oldProps = PW.Game.GetVehicleProperties(curVeh.obj)
    local newProp = { ['tyreSmokeColor'] = colors }
    PW.Game.SetVehicleProperties(curVeh.obj, newProp)
    if not smoking then
        smoking = true
        FreezeEntityPosition(curVeh.obj, false)
        TaskVehicleTempAction(GLOBAL_PED, curVeh.obj, 30, 2000)
        Wait(2000)
        FreezeEntityPosition(curVeh.obj, true)
        smoking = false
    end
    --OpenCustomizationOptions(data.data.data)
end)

function CheckNeons()
    local count = 0
    for i = 1, 4, 1 do
        if curVeh.props['neonEnabled'][i] then
            count = count + 1
        end
    end
    if count > 0 then
        return true
    else
        return false
    end
end

RegisterNetEvent('pw_mechanic:client:loadWheels')
AddEventHandler('pw_mechanic:client:loadWheels', function(data)
    local prop = (data.wheel == 23 and "modFrontWheels" or "modBackWheels")
    PW.Game.SetVehicleProperties(curVeh.obj, { ['wheels'] = data.wheelType, [prop] = data.wheelIndex })
    TriggerEvent('pw_interact:enableSlider')
end)

RegisterNetEvent('pw_mechanic:client:openWheelCat')
AddEventHandler('pw_mechanic:client:openWheelCat', function(data)
    local hourlyCost, partsCost = GetPiecePrice('wheelTypes', data.option, 1)
    local slider = {}

    PW.Game.SetVehicleProperties(curVeh.obj, { ['wheels'] = data.cat })
    local modCount = GetNumVehicleMods(curVeh.obj, 23)
    
    for i = 0, modCount-1, 1 do
        local wheelLabel = GetLabelText(GetModTextLabel(curVeh.obj, 23, i))
        if wheelLabel == nil or wheelLabel == "NULL" then wheelLabel = "Wheel "..i; end
        if curVeh.props['wheelType'] == i then
            wheelLabel = wheelLabel .. " <br>(Installed)"
        end
        table.insert(slider, { ['label'] = wheelLabel, ['data'] = { ['data'] = data, ['wheelType'] = data.cat, ['wheelIndex'] = i, ['wheel'] = data.wheel, ['cost'] = { ['hours'] = (hourlyCost * Config.MySQL[curVeh.garage]['hourRate']), ['parts'] = partsCost }, ['trigger'] = "pw_mechanic:client:loadWheels", ['triggerType'] = "client"}, ['infoHtml'] = { ['type'] = "popover", ['title'] = "Type: "..i, ['content'] = "Cost: <b><span class='text-success'>$"..(hourlyCost * Config.MySQL[curVeh.garage]['hourRate']).."</span></b><br>+ <b><span class='text-primary'>" .. partsCost .. "</span></b> Wheel parts" } })
    end

    TriggerEvent('pw_interact:generateSlider', slider, 'pw_mechanic:client:installPart', 'client', data.catLabel, "", {vehicle = true, menuSwitcher = true}, { { ['trigger'] = 'pw_mechanic:client:openPrev', ['method'] = 'client' } } )
end)

function OpenWheelsMenu(cat, label, moto, data)
    local menu = {}
    
    if moto then
        table.insert(menu, { ['label'] = 'Front Wheel', ['action'] = 'pw_mechanic:client:openWheelCat', ['value'] = { ['wheel'] = 23, ['cat'] = cat, ['catLabel'] = label, ['data'] = data } , ['triggertype'] = 'client', ['color'] = 'primary' })
        table.insert(menu, { ['label'] = 'Back Wheel', ['action'] = 'pw_mechanic:client:openWheelCat', ['value'] = { ['wheel'] = 24, ['cat'] = cat, ['catLabel'] = label, ['data'] = data }, ['triggertype'] = 'client', ['color'] = 'primary' })
        TriggerEvent('pw_interact:generateMenu', menu, "Choose wheel")
    else
        TriggerEvent('pw_mechanic:client:openWheelCat', { ['wheel'] = 23, ['cat'] = cat, ['catLabel'] = label, ['data'] = data })
    end
end

RegisterNetEvent('pw_mechanic:client:loadPaint')
AddEventHandler('pw_mechanic:client:loadPaint', function(data)
    PW.Game.SetVehicleProperties(curVeh.obj, { [data.part] = data.level })
    TriggerEvent('pw_interact:enableSlider')
end)

RegisterNetEvent('pw_mechanic:client:paint')
AddEventHandler('pw_mechanic:client:paint', function(data)
    hourlyCost, partsCost = GetPiecePrice(data.data.cat, data.data.option, 1)
    local slider = {}
    local colors = GetColors(data.colorGroup)
    for k,v in pairs(colors) do
        if exports.pw_core:getVehicleColor(v.index) then
            table.insert(slider, { ['label'] = exports.pw_core:getVehicleColor(v.index), ['data'] = { ['level'] = v.index, ['part'] = data.option, ['data'] = data.data, ['cost'] = { ['hours'] = (hourlyCost * Config.MySQL[curVeh.garage]['hourRate']), ['parts'] = partsCost }, ['trigger'] = "pw_mechanic:client:loadPaint", ['triggerType'] = "client"}, ['infoHtml'] = { ['type'] = "popover", ['title'] = "Type: "..v.index, ['content'] = "Cost: <b><span class='text-success'>$"..(hourlyCost * Config.MySQL[curVeh.garage]['hourRate']).."</span></b><br>+ <b><span class='text-primary'>" .. partsCost .. "</span></b> Body Color parts" } })
        else
            print('Missing color name for index: '..v.index)
        end
    end
    table.sort(slider, function(a,b) return a.label < b.label end)

    TriggerEvent('pw_interact:generateSlider', slider, 'pw_mechanic:client:installPart', 'client', "Paint", "", {vehicle = true, menuSwitcher = true}, { { ['trigger'] = 'pw_mechanic:client:openPrev', ['method'] = 'client' } } )
end)

function GetVehPrice(model)
    for k,v in pairs(Vehicles) do
        for j,b in pairs(v.vehicles) do
            if j == model then
                return b.price
            end
        end
    end
    return Config.DefaultPrice
end

RegisterNetEvent('pw_mechanic:client:newOrder')
AddEventHandler('pw_mechanic:client:newOrder', function(order)
    curVeh['hasPending'] = order
end)

RegisterNetEvent('pw_mechanic:client:c')
AddEventHandler('pw_mechanic:client:c', function()
    if curVeh.obj then
        FreezeEntityPosition(curVeh.obj, false)
        prevMenu, curVeh = nil, nil
    end
end)

function OpenCustomizationMenu(cat, garage)
    if garage == nil and curVeh['garage'] ~= nil then garage = curVeh.garage; end
    local checkVeh = false
    if cat == 'main' then
        local ped = GLOBAL_PED
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)
            if GetPedInVehicleSeat(veh, -1) == ped then
                if curVeh == nil or curVeh['obj'] == nil then
                    curVeh = { ['obj'] = veh, ['props'] = PW.Game.GetVehicleProperties(veh), ['net'] = VehToNet(veh) }
                    local vin = PW.Vehicles.GetVehId(curVeh.props.plate)
                    if vin then curVeh['vin'] = vin; end
                    SetNetworkIdCanMigrate(curVeh.net, true)
                    NetworkRegisterEntityAsNetworked(curVeh.net)
                    curVeh['price'] = GetVehPrice(string.lower(GetDisplayNameFromVehicleModel(curVeh.props.model)))
                    curVeh['garage'] = garage
                    SetVehicleAutoRepairDisabled(NetworkGetEntityFromNetworkId(curVeh.net), true)

                    local gucci = false
                    PW.TriggerServerCallback('pw_mechanic:server:getPending', function(data)
                        if data then
                            curVeh['hasPending'] = data
                        else
                            curVeh['hasPending'] = false
                        end
                        gucci = true
                    end, curVeh.vin, curVeh.garage)
                    repeat Wait(0) until gucci == true

                    checkVeh = true
                    FreezeEntityPosition(curVeh.obj, true)
                else
                    checkVeh = true
                end
            else
                curVeh = {}
            end
        end
    else
        checkVeh = true
    end
    if checkVeh then        
        if lastVeh ~= curVeh.obj then
            shoppingCart = {}
            lastVeh = curVeh.obj
        end

        SetVehicleDoorsShut(curVeh.obj, true)
        SetVehicleModKit(curVeh.obj, 0)
        PW.Game.SetVehicleProperties(curVeh.obj, curVeh.props)
        
        local menu = {}
        prevMenu = Config.Menu[cat].parent
        local vClass = GetVehicleClass(curVeh.obj)
        for k,v in pairs(Config.Menu[cat].options) do
            if cat == 'main' and k == 'shopCart' then
                if not curVeh.hasPending then
                    local sub = {}
                    if CountBasketItems() > 0 then
                        table.insert(sub, { ['label'] = "Items: <b><span class='text-primary'>"..#shoppingCart.."</span></b>", ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' })
                        table.insert(sub, { ['label'] = "Total: <b><span class='text-success'>$".. SumBasket() .."</span></b>", ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' })
                        table.insert(sub, { ['label'] = "<b><span class='text-info'>View</span></b>", ['action'] = "pw_mechanic:client:viewCart", ['value'] = curVeh.garage, ['triggertype'] = "client", ['color'] = "warning" })
                        table.insert(sub, { ['label'] = "<b><span class='text-success'>Checkout</span></b>", ['action'] = "pw_mechanic:client:checkoutCart", ['value'] = curVeh.garage, ['triggertype'] = "client", ['color'] = "warning" })
                        table.insert(sub, { ['label'] = "<b><span class='text-danger'>Empty Cart</span></b>", ['action'] = "pw_mechanic:client:emptyCart", ['value'] = curVeh.garage, ['triggertype'] = "client", ['color'] = "warning" })
                    else
                        table.insert(sub, { ['label'] = "Your cart is empty", ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' } )
                    end

                    table.insert(menu, { ['label'] = "Shopping Cart", ['color'] = "info", ['subMenu'] = sub })
                else
                    exports.pw_notify:SendAlert('inform', 'This vehicle has a pending installation', 5000)
                end
            elseif cat == 'wheelTypes' then
                if vClass == 8 then
                    if k == 'motorcycles' then
                        table.insert(menu, { ['label'] = v.label, ['action'] = (v.target and 'pw_mechanic:client:openMenu' or 'pw_mechanic:client:openOptions'), ['value'] = (v.target or { ['cat'] = cat, ['option'] = k }), ['triggertype'] = 'client', ['color'] = 'primary' })
                    end
                elseif k ~= 'motorcycles' then
                    table.insert(menu, { ['label'] = v.label, ['action'] = (v.target and 'pw_mechanic:client:openMenu' or 'pw_mechanic:client:openOptions'), ['value'] = (v.target or { ['cat'] = cat, ['option'] = k }), ['triggertype'] = 'client', ['color'] = 'primary' })
                end
            elseif (v.part == nil or v.part == 17 or v.part == 22 or (v.part == 'modXenonColor' and curVeh['props'].modXenon) or (v.part ~= 'modXenonColor' and type(v.part) == 'string') or (type(v.part) == 'number' and GetNumVehicleMods(curVeh.obj, v.part) > 0)) then
                if (v.part == 'neonColor' and CheckNeons()) or v.part ~= 'neonColor' then
                    if v.label == 'bodydmg' then
                        local bodysub = {}
                        local hasBrokenShit = false
                        local getDoors = GetFuckedDoors()
                        if getDoors ~= false then
                            table.insert(bodysub, { ['label'] = '<b>Doors broken</b>:'..getDoors } )
                            hasBrokenShit = true
                        end

                        local getWindows = GetFuckedWindows()
                        if getWindows ~= false then
                            table.insert(bodysub, { ['label'] = '<b>Windows broken</b>:'..getWindows } )
                            hasBrokenShit = true
                        end

                        local getHeadlights = GetFuckedHeadlights()
                        if getHeadlights ~= false then
                            table.insert(bodysub, { ['label'] = '<b>Headlights broken</b>:'..getHeadlights } )
                            hasBrokenShit = true
                        end

                        local bodydmg = math.ceil(((GetVehicleBodyHealth(curVeh.obj) - 100.0) / 900) * 100)
                        table.insert(menu, { ['label'] = "Body Status: "..(bodydmg > 0 and bodydmg or 0).."%", ['action'] = (v.target and 'pw_mechanic:client:openMenu' or 'pw_mechanic:client:openOptions'), ['value'] = (v.target or { ['cat'] = cat, ['option'] = k }), ['triggertype'] = 'client', ['color'] = (bodydmg < 25 and 'danger' or bodydmg < 50 and 'warning' or bodydmg < 99 and 'success' or 'info') })
                        
                        if hasBrokenShit then
                            menu[#menu]['subMenu'] = bodysub
                        end
                    elseif v.label == 'enginedmg' then
                        local enginedmg = math.ceil(((GetVehicleEngineHealth(curVeh.obj) > 0 and GetVehicleEngineHealth(curVeh.obj) or 0) / 1000) * 100)
                        table.insert(menu, { ['label'] = "Engine Status: "..(enginedmg > 0 and enginedmg or 0).."%", ['action'] = (v.target and 'pw_mechanic:client:openMenu' or 'pw_mechanic:client:openOptions'), ['value'] = (v.target or { ['cat'] = cat, ['option'] = k }), ['triggertype'] = 'client', ['color'] = (enginedmg < 25 and 'danger' or enginedmg < 50 and 'warning' or enginedmg < 99 and 'success' or 'info') })
                    
                    else
                        table.insert(menu, { ['label'] = v.label, ['action'] = (v.target and 'pw_mechanic:client:openMenu' or 'pw_mechanic:client:openOptions'), ['value'] = (v.target or { ['cat'] = cat, ['option'] = k }), ['triggertype'] = 'client', ['color'] = 'primary' })
                    end
                end
            end
        end

        if #menu > 0 then
            table.sort(menu, function(a,b) return a.label < b.label end)
        else
            table.insert(menu, { ['label'] = "No available parts", ['color'] = 'danger disabled' })
        end

        if cat == 'main' then
            local pendingData = curVeh['hasPending']
            if pendingData then
                local installStuff = json.decode(pendingData.install)
                local metaStuff = json.decode(pendingData.meta)
                local pendSub = {}
                table.insert(pendSub, { ['label'] = "<b>Items</b>: "..CountPending(installStuff), ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' })
                table.insert(pendSub, { ['label'] = "<b>Mechanic</b>: "..metaStuff.mech, ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' })
                table.insert(pendSub, { ['label'] = "<b>Date</b>: "..metaStuff.date, ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' })
                table.insert(pendSub, { ['label'] = "<b><span class='text-primary'>View Items</span></b>", ['action'] = 'pw_mechanic:client:viewPendingItems', ['value'] = installStuff, ['triggertype'] = 'client' })
                table.insert(pendSub, { ['label'] = "<b><span class='text-success'>Install</span></b>", ['action'] = 'pw_mechanic:client:installPending', ['value'] = { parts = installStuff, garage = metaStuff.garage }, ['triggertype'] = 'client' })
                table.insert(menu, { ['label'] = 'Pending Installation', ['color'] = 'warning', ['subMenu'] = pendSub })
            end
        end

        TriggerEvent('pw_interact:generateMenu', menu, Config.Menu[cat].label, {{ ['trigger'] = 'pw_mechanic:client:openPrev', ['method'] = 'client' }})
    else
        exports.pw_notify:SendAlert('error', 'You need to be in the driver seat of a vehicle')
    end
end

RegisterNetEvent('pw_mechanic:client:installPending')
AddEventHandler('pw_mechanic:client:installPending', function(data)
    TriggerEvent('pw_mechanic:client:paymentConfirmed', data.parts, data.garage)
    TriggerEvent('pw_mechanic:client:openMenu', 'main', data.garage)
end)

RegisterNetEvent('pw_mechanic:client:viewPendingItems')
AddEventHandler('pw_mechanic:client:viewPendingItems', function(parts)
    local menu = {}
    local loopThis = {}
    
    if parts['type'] ~= nil then
        prevMenu = 'boss'
        loopThis = parts.parts
    else
        prevMenu = 'main'
        loopThis = parts
    end

    for k,v in pairs(loopThis) do
        local sub = {}
        if v.type ~= nil then
            table.insert(sub, { ['label'] = v.type, ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' })
            table.insert(menu, { ['label'] = v.itemLabel, ['color'] = 'primary', ['subMenu'] = sub })
        else
            table.insert(menu, { ['label'] = v.label, ['color'] = 'primary' })
        end
    end

    TriggerEvent('pw_interact:generateMenu', menu, "Pending Installation", { { ['trigger'] = 'pw_mechanic:client:openPrev', ['method'] = 'client' } } )
end)

function CountPending(parts)
    local count = 0
    for k,v in pairs(parts) do
        count = count + 1
    end
    return count
end

function GetFuckedDoors()
    local Doors = {
        { ['index'] = 0, ['label'] = "Front Left" },
        { ['index'] = 1, ['label'] = "Front Right" },
        { ['index'] = 2, ['label'] = "Back Left" },
        { ['index'] = 3, ['label'] = "Back Right" },
        { ['index'] = 4, ['label'] = "Hood" },
        { ['index'] = 5, ['label'] = "Trunk" }
    }
    local damaged = ""
    for k,v in pairs(Doors) do
        if DoesVehicleHaveDoor(NetworkGetEntityFromNetworkId(curVeh.net), v.index) then
            if IsVehicleDoorDamaged(NetworkGetEntityFromNetworkId(curVeh.net), v.index) then
                damaged = damaged .. "<br>" .. v.label
            end
        end
    end
    if damaged == "" then
        damaged = false
    end

    return damaged
end

function GetFuckedWindows()
    if AreAllVehicleWindowsIntact(NetworkGetEntityFromNetworkId(curVeh.net)) then
        return false
    else
        local Windows = {
            { ['index'] = 0, ['label'] = "Front Left" },
            { ['index'] = 1, ['label'] = "Front Right" },
            { ['index'] = 2, ['label'] = "Back Left" },
            { ['index'] = 3, ['label'] = "Back Right" }
        }
        local damaged = ""
        for k,v in pairs(Windows) do
            if not IsVehicleWindowIntact(NetworkGetEntityFromNetworkId(curVeh.net), v.index) then
                damaged = damaged .. "<br>" .. v.label
            end
        end

        if damaged == "" then
            damaged = false
        end

        return damaged
    end
end

function GetFuckedHeadlights()
    local damaged = ""
    if GetIsLeftVehicleHeadlightDamaged(NetworkGetEntityFromNetworkId(curVeh.net)) then
        damaged = damaged .. "<br> Left"
    end

    if GetIsRightVehicleHeadlightDamaged(NetworkGetEntityFromNetworkId(curVeh.net)) then
        damaged = damaged .. "<br> Right"
    end

    if damaged == "" then
        damaged = false
    end

    return damaged
end

RegisterNetEvent('pw_mechanic:client:checkoutParts')
AddEventHandler('pw_mechanic:client:checkoutParts', function(parts, garage)
    local closestPlayer, closestDistance = PW.Game.GetClosestPlayer()
    local nearbyPlayersSub = {}
    table.insert(nearbyPlayersSub, { ['label'] = "Self", ['action'] = "pw_mechanic:client:formAmount", ['value'] = { ['garage'] = garage, ['mech'] = GetPlayerServerId(PlayerId()), ['target'] = GetPlayerServerId(PlayerId()), ['data'] = parts }, ['triggertype'] = 'client', ['color'] = 'primary' })
    if closestDistance <= 6.0 and closestPlayer ~= -1 then
        local pName 
        PW.TriggerServerCallback('pw_vehicleshop:server:getNearbyName', function(name)
            pName = name
        end, GetPlayerServerId(closestPlayer))

        while pName == nil do
            Wait(10)
        end

        if pName then
            table.insert(nearbyPlayersSub, { ['label'] = pName, ['action'] = "pw_mechanic:client:formAmount", ['value'] = { ['garage'] = garage, ['mech'] = GetPlayerServerId(PlayerId()), ['target'] = GetPlayerServerId(closestPlayer), ['data'] = parts }, ['triggertype'] = 'client', ['color'] = 'primary' })
        end
    end

    local menu = {}
    table.insert(menu, { ['label'] = "Costumer", ['color'] = 'warning', ['subMenu'] = nearbyPlayersSub })

    TriggerEvent('pw_interact:generateMenu', menu, "Choose Costumer")
end)

RegisterNetEvent('pw_mechanic:client:checkoutCart')
AddEventHandler('pw_mechanic:client:checkoutCart', function(garage)
    prevMenu = 'main'
    local sendParts = {}
    for k,v in pairs(shoppingCart) do
        if v.repair then
            table.insert(sendParts, { ['label'] = v.label, ['repair'] = v.repair })
        else
            table.insert(sendParts, { ['item'] = v.cost.item, ['qty'] = v.cost.parts, ['itemLabel'] = v.cost.label, ['hours'] = v.cost.hours, ['type'] = v.description, ['install'] = v.install })
        end
    end
    TriggerServerEvent('pw_mechanic:server:checkout', sendParts, garage)
end)

RegisterNetEvent('pw_mechanic:client:emptyCart')
AddEventHandler('pw_mechanic:client:emptyCart', function(data)
    shoppingCart = {}
    
    TriggerEvent('pw_mechanic:client:openMenu', 'main', data)
end)

RegisterNetEvent('pw_mechanic:client:removeItem')
AddEventHandler('pw_mechanic:client:removeItem', function(data)
    shoppingCart[data.item] = nil
    if CountBasketItems() > 0 then
        TriggerEvent('pw_mechanic:client:viewCart', data.garage)
    else
        TriggerEvent('pw_mechanic:client:openMenu', 'main', data.garage)
    end
end)

RegisterNetEvent('pw_mechanic:client:viewCart')
AddEventHandler('pw_mechanic:client:viewCart', function(garage)
    prevMenu = 'main'
    local menu = {}
    local tbd = false
    for k,v in pairs(shoppingCart) do
        local sub = {}
        if v.description ~= nil then
            table.insert(sub, { ['label'] = v.description })
        end
        
        if v.repair == nil then
            table.insert(sub, { ['label'] = "Costs: <b><span class = 'text-success'>$" .. v.cost.hours .. "</span></b>", ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' })
            if v.cost.parts ~= nil and v.cost.parts > 0 then
                table.insert(sub, { ['label'] = "+ <b><span class = 'text-primary'>" .. ((v.cost.parts == 'bodyPrimaryColor' or v.cost.parts == 'bodySecondaryColor') and 'Body Color' or v.cost.parts) .. "</span> ".. v.label .. "</b> parts", ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' })
            end
        else
            tbd = true
        end
        table.insert(sub, { ['label'] = '<b><span class="text-danger">Remove</span></b>', ['action'] = 'pw_mechanic:client:removeItem', ['value'] = { ['item'] = k, ['garage'] = garage }, ['triggertype'] = 'client' })
        table.insert(menu, { ['label'] = v.label, ['color'] = 'primary', ['subMenu'] = sub })
    end
    table.insert(menu, { ['label'] = "Total: $"..SumBasket()..(tbd and " + TBD" or ""), ['color'] = "success" })

    TriggerEvent('pw_interact:generateMenu', menu, "Shopping Cart", { { ['trigger'] = 'pw_mechanic:client:openPrev', ['method'] = 'client' } })
end)

function SumBasket()
    local amt = 0
    if CountBasketItems() > 0 then
        for k,v in pairs(shoppingCart) do
            if v.repair == nil then
                amt = amt + v.cost.hours
            end
        end
        return amt
    else
        return 0
    end
end

function CountBasketItems()
    local count = 0
    for k,v in pairs(shoppingCart) do
        count = count + 1
    end
    return count
end

function StoreVehicle(k)
    local ped = GLOBAL_PED
    local pedVeh = GetVehiclePedIsIn(ped, false)
    if GetPedInVehicleSeat(pedVeh, -1) == ped then
        local props = PW.Game.GetVehicleProperties(pedVeh)
        local vin = PW.Vehicles.GetVehId(props.plate)
        if vin then
            PW.TriggerServerCallback('pw_mechanic:server:getVehicleJob', function(result)
                if result == playerData.job.name and k == tonumber(playerData.job.workplace) then
                    TriggerServerEvent('pw_mechanic:server:storeVehicle', vin, k)
                    SetEntityAsMissionEntity(pedVeh, true, true)
                    DeleteEntity(pedVeh)
                    exports.pw_notify:SendAlert('inform', 'Vehicle parked')
                else
                    exports.pw_notify:SendAlert('error', 'This vehicle doesn\'t belong to this company', 5000)
                end
            end, vin)
        else
            exports.pw_notify:SendAlert('error', 'This vehicle doesn\'t belong to this company', 5000)
        end
    end
end

function OpenMechanicActions(k)
    local menu = {}
    table.insert(menu, { ['label'] = "Job duty: "..(playerData.job.duty and "ON" or "OFF"), ['action'] = 'pw_mechanic:server:toggleDuty', ['triggertype'] = 'server', ['color'] = (playerData.job.duty and "success" or "danger")  })
    if playerData.job.duty then
        table.insert(menu, { ['label'] = "Garage", ['action'] = 'pw_mechanic:client:openGarage', ['value'] = k, ['triggertype'] = 'client', ['color'] = 'primary' })
    end

    TriggerEvent('pw_interact:generateMenu', menu, "Mechanic Actions")
end

RegisterNetEvent('pw_mechanic:client:sendContractForm')
AddEventHandler('pw_mechanic:client:sendContractForm', function(formCopy, grade, boss, garage)
    local form = formCopy

    table.insert(form, { ['type'] = "checkbox", ['label'] = '<i>'..playerData.name.."</i>", ['name'] = "contractReview", ['value'] = 'yes'})
    table.insert(form, { ['type'] = "hidden", ['name'] = "grade", ['value'] = grade })
    table.insert(form, { ['type'] = "hidden", ['name'] = "bossSrc", ['value'] = boss })
    table.insert(form, { ['type'] = "hidden", ['name'] = "garage", ['value'] = garage })

    TriggerEvent('pw_interact:generateForm', 'pw_mechanic:server:contractSigned', 'server', form, 'Employment Contract', {}, false, '500px')
end)

RegisterNetEvent('pw_mechanic:client:bossHireReview')
AddEventHandler('pw_mechanic:client:bossHireReview', function(result)
    local selectedLabel
    for k,v in pairs(result.allGrades.data) do
        if v.value == result.grades.value then
            selectedLabel = v.label
        end
    end
    local formCopy = {
        { ['type'] = "writting", ['align'] = 'center', ['value'] = "<span style='font size:22px;'><b>Employment Contract<br><span class='text-primary' style='font size:28px;'>"..result.data.data.name.."</span> | <span class='text-primary' style='font size:28px;'>" .. selectedLabel .. "</b></span>"},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = 'BE IT KNOWN, that this COMMISSION AGREEMENT, entered into by <b><span class="text-info">Mechanic 1</span></b>, (hereafter referred to as the "Company"), located in <b><span class="text-info">Los Santos</span></b>, and <b><span class="text-info">'.. result.data.data.name .. '</span></b> (hereafter referred to as the "Employee").'},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = '<b>1. EMPLOYMENT</b><br>The Company does hereby employ in the position of dealer and the Employee does hereby agree to serve in such capacity. This contract may be terminated at any time at the owners discretion.'},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = '<b>2. COMPENSATION & BENEFITS</b><br>In accordance with the following terms and conditions of this Agreement, and throughout Employees period of employment, compensation for his/her services will be as follows:<br>Employee will receive daily base income of <b><span class="text-success">$'..PW.Base.GetGradeSalery('mechanic', result.grades.value)..'</span></b>, by way of direct deposit.'},
        --{ ['type'] = "writting", ['align'] = 'center', ['value'] = '<b>3. COMMISSION PAYMENTS</b><br>In addition to the Employee\'s daily base salary the Company shall provide <b><span class="text-info">' .. Config.MySQL.DealerMargin .. '%</span></b> commission on the dollar for new sales revenue generated by the Employee.'},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = 'Upon termination or death of Employee and/or this agreement, payments at such time will cease.'},
    }

    local form = {}
    for k, v in pairs(formCopy) do
        table.insert(form, { ['type'] = v.type, ['align'] = v.align, ['value'] = v.value })
    end

    table.insert(form, { ['type'] = "hidden", ['name'] = "formCopy", ['data'] = formCopy })
    table.insert(form, { ['type'] = "hidden", ['name'] = "target", ['value'] = result.data.data.target })
    table.insert(form, { ['type'] = "hidden", ['name'] = "garage", ['value'] = result.data.data.garage })
    table.insert(form, { ['type'] = "hidden", ['name'] = "grade", ['value'] = result.grades.value })
    table.insert(form, { ['type'] = "hidden", ['name'] = "bossSrc", ['value'] = GetPlayerServerId(PlayerId()) })

    TriggerEvent('pw_interact:generateForm', 'pw_mechanic:server:sendContractForm', 'server', form, 'Contract Review', {}, false, '500px')
end)

RegisterNetEvent('pw_mechanic:client:bossHire')
AddEventHandler('pw_mechanic:client:bossHire', function(result)
    local grades = {}
    local form = {}
    PW.Base.GetAvaliableGrades('mechanic', function(resGrades)
        for k,v in pairs(resGrades) do
            table.insert(grades, {['value'] = v.grade, ['label'] = v.label})
        end

        table.insert(form, { ['type'] = "writting", ['align'] = 'center', ['value'] = "<span style='font size:22px;'><b>Employment Contract Details<br><span class='text-primary' style='font size:28px;'>"..result.name.."</span></b></span>" })
        table.insert(form, { ['type'] = "dropdown", ['label'] = 'Grade', ['name'] = "grades", ['options'] = grades })
        table.insert(form, { ['type'] = "hidden", ['name'] = "data", ['data'] = result })
        table.insert(form, { ['type'] = "hidden", ['name'] = "allGrades", ['data'] = grades })
        
        TriggerEvent('pw_interact:generateForm', 'pw_mechanic:client:bossHireReview', 'client', form, 'Set Contract Details', {}, false, '350px', { { ['trigger'] = 'pw_mechanic:client:openStaff', ['method'] = 'client' } } )
    end)
end)


RegisterNetEvent('pw_mechanic:client:changeGrade')
AddEventHandler('pw_mechanic:client:changeGrade', function(result)
    local grades = {}
    local form = {}
    PW.Base.GetAvaliableGrades('mechanic', function(resGrades)
        for k,v in pairs(resGrades) do
            table.insert(grades, {['value'] = v.grade, ['label'] = (v.grade == result.job.grade and v.label .. "  (Current)" or v.label), ['level'] = v.level })
        end

        table.insert(form, { ['type'] = "writting", ['align'] = 'center', ['value'] = "<span style='font size:22px;'><b>Employee<br><span class='text-primary' style='font size:28px;'>"..result.name.."</span></b></span>" })
        table.insert(form, { ['type'] = "dropdown", ['label'] = 'Grade', ['name'] = "grades", ['options'] = grades })
        table.insert(form, { ['type'] = "hidden", ['name'] = "data", ['data'] = {result = result, grades = grades, garage = curGarage} })
        
        TriggerEvent('pw_interact:generateForm', 'pw_mechanic:server:setNewGrade', 'server', form, 'Set Employee Grade', {}, false, '350px', { { ['trigger'] = 'pw_mechanic:client:openStaff', ['method'] = 'client' } } )
    end)
end)

RegisterNetEvent('pw_mechanic:client:fireStaff')
AddEventHandler('pw_mechanic:client:fireStaff', function(result)
    local form = {}
    table.insert(form, { ['type'] = "writting", ['align'] = 'left', ['value'] = "<b><span class='text-primary'>"..result.name.."</span></b>," })
    table.insert(form, { ['type'] = "writting", ['align'] = 'left', ['value'] = "This letter is to inform you that your employment with <b>Mechanics</b> will end as of <b>today</b>."})
    table.insert(form, { ['type'] = "writting", ['align'] = 'left', ['value'] = "This decision is not reversible." })
    table.insert(form, { ['type'] = "checkbox", ['label'] = 'Mechanics Owner,<br><i>'..playerData.name..'</i>', ['name'] = "fire", ['value'] = 'yes' })
    table.insert(form, { ['type'] = "hidden", ['name'] = "data", ['data'] = result })

    TriggerEvent('pw_interact:generateForm', 'pw_mechanic:server:fireStaff', 'server', form, 'Contract Termination | '..result.name, {}, false, '350px', { { ['trigger'] = 'pw_mechanic:client:openStaff', ['method'] = 'client' } } )
end)

RegisterNetEvent('pw_mechanic:client:manageStaff')
AddEventHandler('pw_mechanic:client:manageStaff', function()
    local menu = {}
    
    PW.TriggerServerCallback('pw_mechanic:server:getStaff', function(list)
        for k, v in pairs(list) do
            local staffSub = {}
            table.insert(staffSub, {['label'] = "Promote/Demote", ['action'] = "pw_mechanic:client:changeGrade", ['triggertype'] = 'client', ['value'] = v })
            table.insert(staffSub, {['label'] = "<b><span class='text-danger'>Fire</span></b>", ['action'] = "pw_mechanic:client:fireStaff", ['triggertype'] = 'client', ['value'] = v })

            table.insert(menu, {['label'] = v.name, ['color'] = 'primary', ['subMenu'] = staffSub })
        end

        TriggerEvent('pw_interact:generateMenu', menu, "Staff List", { { ['trigger'] = 'pw_mechanic:client:openStaff', ['method'] = 'client' } } )
    end, curGarage)    
end)

RegisterNetEvent('pw_mechanic:client:openStaff')
AddEventHandler('pw_mechanic:client:openStaff', function(k)
    if k == nil then k = curGarage; end
    prevMenu = 'boss'
    local closestPlayer, closestDistance = PW.Game.GetClosestPlayer()
        local nearbyPlayersSub = {}
        if closestPlayer ~= -1 and closestDistance <= 3.0 then
            local pName
            PW.TriggerServerCallback('pw_vehicleshop:server:getNearbyName', function(name)
                pName = name
            end, GetPlayerServerId(closestPlayer))

            while pName == nil do
                Wait(10)
            end

            if pName then
                table.insert(nearbyPlayersSub, { ['label'] = pName, ['action'] = "pw_mechanic:client:bossHire", ['value'] = {target = GetPlayerServerId(closestPlayer), name = pName, garage = k}, ['triggertype'] = "client", ['color'] = "warning" })
            else
                table.insert(nearbyPlayersSub, { ['label'] = "No players nearby", ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' })
            end
        else
            table.insert(nearbyPlayersSub, { ['label'] = "No players nearby" })
        end
    
    local menu = {}

    table.insert(menu, { ['label'] = "Hire", ['color'] = 'success', ['subMenu'] = nearbyPlayersSub })
    table.insert(menu, { ['label'] = "Manage Current Staff", ['action'] = 'pw_mechanic:client:manageStaff', ['value'] = k, ['triggertype'] = 'client', ['color'] = 'warning' })
    TriggerEvent('pw_interact:generateMenu', menu, "Staff Management", { { ['trigger'] = 'pw_mechanic:client:openPrev', ['method'] = 'client' } })
end)

RegisterNetEvent('pw_mechanic:client:updateRates')
AddEventHandler('pw_mechanic:client:updateRates', function(garage, rate, value)
    Config.MySQL[garage][rate] = value
end)

RegisterNetEvent('pw_mechanic:client:changeRate')
AddEventHandler('pw_mechanic:client:changeRate', function(data)
    local form = {}
    local title
    if data.type == 'hourRate' then
        title = 'Hour Rates'
        table.insert(form, { ['type'] = 'writting', ['align'] = 'center', ['value'] = "Changing Hour Rates<br><b>Current Rate: <span class='text-primary'>$"..Config.MySQL[data.garage]['hourRate'].."</span>/hour</b>" })
        table.insert(form, { ['type'] = 'range', ['label'] = "Set Rate", ['default'] = Config.MySQL[data.garage]['hourRate'], ['min'] = Config.LimitRates['hourRate'].min, ['max'] = Config.LimitRates['hourRate'].max, ['name'] = 'range', ['suffix'] = "$/hour"})
    end
    table.insert(form, { ['type'] = 'hidden', ['name'] = "rates", ['data'] = data })

    TriggerEvent('pw_interact:generateForm', 'pw_mechanic:server:changeRates', 'server', form, title, {}, false, '350px', { { ['trigger'] = 'pw_mechanic:client:openRates', ['method'] = 'client' } })
end)

RegisterNetEvent('pw_mechanic:client:openRates')
AddEventHandler('pw_mechanic:client:openRates', function(garage)
    prevMenu = 'boss'
    if garage == nil then
        garage = curGarage
    end
    
    local menu = {}
    table.insert(menu, { ['label'] = "Hourly Cost", ['action'] = 'pw_mechanic:client:changeRate', ['value'] = { ['type'] = 'hourRate', ['garage'] = garage }, ['triggertype'] = 'client', ['color'] = 'primary' })

    TriggerEvent('pw_interact:generateMenu', menu, "Rates", { { ['trigger'] = 'pw_mechanic:client:openPrev', ['method'] = 'client' } } )
end)

RegisterNetEvent('pw_mechanic:client:openPending')
AddEventHandler('pw_mechanic:client:openPending', function(garage)
    prevMenu = 'boss'
    curGarage = garage
    local menu = {}
    PW.TriggerServerCallback('pw_mechanic:server:getPendings', function(list)
        if list then
            for k,v in pairs(list) do
                local installStuff = json.decode(v.install)
                local metaStuff = json.decode(v.meta)
                local sub = {}
                table.insert(sub, { ['label'] = "<b>Items</b>: "..CountPending(installStuff), ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' })
                table.insert(sub, { ['label'] = "<b>Mechanic</b>: "..metaStuff.mech, ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' })
                table.insert(sub, { ['label'] = "<b>Date</b>: "..metaStuff.date, ['action'] = 'pw_mechanic:client:c', ['triggertype'] = 'client' })
                table.insert(sub, { ['label'] = "<b><span class='text-primary'>View Items</span></b>", ['action'] = 'pw_mechanic:client:viewPendingItems', ['value'] = {type = 'boss', parts = installStuff}, ['triggertype'] = 'client' })
                table.insert(menu, { ['label'] = v.plate, ['color'] = 'primary', ['subMenu'] = sub } )
            end

            TriggerEvent('pw_interact:generateMenu', menu, "Pending Installations", { { ['trigger'] = 'pw_mechanic:client:openPrev', ['method'] = 'client' } } )
        else
            exports.pw_notify:SendAlert('inform', 'There are no pending installations')
            OpenBossActions(garage)
        end
    end, garage)
end)

function OpenBossActions(k)
    curGarage = k
    local menu = {}
    table.insert(menu, { ['label'] = "Pending Installations", ['action'] = 'pw_mechanic:client:openPending', ['value'] = k, ['triggertype'] = 'client', ['color'] = 'primary' })
    table.insert(menu, { ['label'] = "Staff Management", ['action'] = 'pw_mechanic:client:openStaff', ['value'] = k, ['triggertype'] = 'client', ['color'] = 'primary' })
    table.insert(menu, { ['label'] = "Rates", ['action'] = 'pw_mechanic:client:openRates', ['value'] = k, ['triggertype'] = 'client', ['color'] = 'primary' })

    TriggerEvent('pw_interact:generateMenu', menu, "Boss Actions | Mechanic")
end

function CreateBlips()
    RemoveBlips()

    for k,v in pairs(Config.Locations) do
        DrawBlips(k)
    end
end

function DrawBlips(id)
    if blips and blips[id] then
        RemoveBlip(blips[id])
        blips[id] = nil
    end

    local blip = AddBlipForCoord(Config.Locations[id].customize.x, Config.Locations[id].customize.y, Config.Locations[id].customize.z)
    
    SetBlipSprite(blip, Config.Blips.blipSprite)
    SetBlipScale(blip, Config.Blips.blipScale)
    SetBlipColour(blip, Config.Blips.blipColor)
    SetBlipDisplay(blip, 4)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Mechanic")
    EndTextCommandSetBlipName(blip)

    blips[id] = blip
end

function RemoveBlips()
    if blips and #blips > 0 then
        for k,v in pairs(blips) do
            RemoveBlip(v)
            blips[k] = nil
        end
    end

    blips = {}
end

function DrawNotif(k, id)
    local title, message, icon
    if k == 'customize' then
        title = "Customize Vehicle"
        message = "<span style='font-size: 15px'>Press <span style='color:#187200;'>[E]</span> to open the customization menu</span>"
        icon = "fad fa-screwdriver"
    elseif k == 'mechanicactions' then
        title = "Mechanic Actions"
        message = "<span style='font-size: 15px'>Press <span style='color:#187200;'>[E]</span> to open the actions menu</span>"
        icon = "fad fa-wrench"
    elseif k == 'bossactions' then
        title = "Boss Actions"
        message = "<span style='font-size: 15px'>Press <span style='color:#187200;'>[E]</span> to open the boss menu</span>"
        icon = "fad fa-user-tie"
    elseif k == 'garage' then
        title = "Garage"
        message = "<span style='font-size: 15px'>Press <span style='color:#187200;'>[E]</span> to store the vehicle</span>"
        icon = "fad fa-car-mechanic"
    elseif k == 'storage' then
        title = "Storage"
        message = "<span style='font-size: 15px'>Press <span style='color:#187200;'>[E]</span> to access the storage</span>"
        icon = "fad fa-box-open"
        TriggerEvent('pw_inventory:client:setupThird', 19, id, "Mechanic Storage")
    end
    if ((k == 'customize' or k == 'garage') and IsPedInAnyVehicle(GLOBAL_PED, true)) or (k ~= 'customize' and k ~= 'garage') then
        TriggerEvent('pw_drawtext:showNotification', { title = title, message = message, icon = icon })
    end
end

function WaitingKeys(k, type, var)
    Citizen.CreateThread(function()
        while showing == var do
            Citizen.Wait(1)
            if playerLoaded then
                if IsControlJustPressed(0,38) then
                    if type == 'customize' then
                        TriggerEvent('pw_mechanic:client:openMenu', 'main', k)
                    elseif type == 'mechanicactions' then
                        OpenMechanicActions(k)
                    elseif type == 'bossactions' then
                        OpenBossActions(k)
                    elseif type == 'garage' then
                        if IsPedInAnyVehicle(GLOBAL_PED, false) then
                            StoreVehicle(k)
                        else
                            exports.pw_notify:SendAlert('error', 'You must be inside a business vehicle', 4000)
                        end
                    end
                end
            end
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(50)
        if playerData and playerLoaded and playerData.job.name == 'mechanic' then
            local pedCoords = GLOBAL_COORDS
            local dist
            for k,v in pairs(Config.Locations) do
                if k == tonumber(playerData.job.workplace) then
                    for j,b in pairs(v) do
                        if j == 'garage' then
                            dist = #(pedCoords - vector3(b.enter.x, b.enter.y, b.enter.z))
                        else
                            dist = #(pedCoords - vector3(b.x, b.y, b.z))
                        end
                        if (j == 'bossactions' and playerData.job.grade == 'boss' and playerData.job.duty) or (j ~= 'bossactions' and ((b.dutyNeeded and playerData.job.duty) or not b.dutyNeeded)) then
                            if dist < Config.DrawDistance then
                                if not showing then
                                    showing = k..j
                                    if not previewing then
                                        DrawNotif(j, k)
                                        if ((j == 'customize' or j == 'garage') and IsPedInAnyVehicle(GLOBAL_PED, true)) or (j ~= 'customize' and j ~= 'garage') then
                                            WaitingKeys(k, j, showing)
                                        end
                                    else
                                        TriggerEvent('pw_drawtext:hideNotification')
                                    end
                                end
                            elseif showing == k..j then
                                showing = false
                                TriggerEvent('pw_drawtext:hideNotification')
                                if j == 'storage' then TriggerEvent('pw_inventory:client:removeThird', "Mechanic Storage"); end
                            end
                        end
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('pw_mechanic:client:enterVehCheck')
AddEventHandler('pw_mechanic:client:enterVehCheck', function(veh)
    if playerData and playerData.job.name == 'mechanic' and playerData.job.duty then
        for k,v in pairs(Config.Locations) do
            if k == playerData.job.workplace then
                local vehCoords = GetEntityCoords(veh)
                local dist = #(vehCoords - vector3(v.customize.x, v.customize.y, v.customize.z))
                if dist < Config.DrawDistance then
                    showing = k..'customize'
                    DrawNotif('customize', k)
                    WaitingKeys(k, 'customize', showing)
                end
                break
            end
        end
    end
end)

RegisterNetEvent('pw_mechanic:client:exitVehCheck')
AddEventHandler('pw_mechanic:client:exitVehCheck', function(veh)
    if playerData and playerData.job.name == 'mechanic' and playerData.job.duty then
        for k,v in pairs(Config.Locations) do
            if k == playerData.job.workplace then
                local vehCoords = GetEntityCoords(veh)
                local dist = #(vehCoords - vector3(v.customize.x, v.customize.y, v.customize.z))
                if dist < Config.DrawDistance then
                    showing = false
                    TriggerEvent('pw_drawtext:hideNotification')
                end
                break
            end
        end
    end
end)