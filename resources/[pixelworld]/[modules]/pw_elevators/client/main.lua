PW = nil
characterLoaded, playerData = false, nil
GLOBAL_PED, GLOBAL_COORDS = nil, nil
local showing, drawingMarker, addingFloor = false, false, false
local elevators = {}

Citizen.CreateThread(function()
    while PW == nil do
        TriggerEvent('pw:loadFramework', function(framework) PW = framework end)
        Citizen.Wait(1)
    end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(unload, ready, data)
    if not unload then
        if ready then
            PW.TriggerServerCallback('pw_elevators:server:requestElevators', function(els)
                GLOBAL_PED = PlayerPedId()
                GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
                elevators = els
                characterLoaded = true
            end)
        else
            playerData = data
        end
    else
        elevators = {}
        playerData = nil
        characterLoaded = false
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if characterLoaded then
            GLOBAL_PED = PlayerPedId()
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if characterLoaded and GLOBAL_PED then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)

RegisterNetEvent('pw_elevators:client:updateElevators')
AddEventHandler('pw_elevators:client:updateElevators', function(table)
    elevators = table
end)

RegisterNetEvent('pw_elevators:client:goFuckYourself')
AddEventHandler('pw_elevators:client:goFuckYourself', function(data)
    DoScreenFadeOut(1000)
    Citizen.Wait(1001)
    SetEntityCoords(GLOBAL_PED, tonumber(data.x), tonumber(data.y), tonumber(data.z), 0.0, 0.0, 0.0, false)
    SetEntityHeading(GLOBAL_PED, tonumber(data.h))
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
    showing = false
    drawingMarker = false
end)

function processElevatorMenu(k, v)
    local menu = {}
    if elevators[k] then
        for t, p in pairs(elevators[k].elevators) do
            if t ~= v then
                table.insert(menu, {['label'] = p.label, ['action'] = "pw_elevators:client:goFuckYourself", ['value'] = p, ['triggertype'] = 'client', ['color'] = 'primary' })
            end
        end
        TriggerEvent('pw_interact:generateMenu', menu, elevators[k].name.." - Select Floor")
    end
end

function controlKeys(k, v, var)
    Citizen.CreateThread(function()
        while showing == var do
            if IsControlJustPressed(0, 38) then
                processElevatorMenu(k, v)
            end
            Citizen.Wait(10)
        end
    end)
end

function DrawShit(x, y, z, var)
    Citizen.CreateThread(function()
        while drawingMarker == var do
            Citizen.Wait(1)
            DrawMarker(2, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 133, 219, 72, 100, false, true, 2, false, nil, nil, false)
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300)
        if characterLoaded and GLOBAL_PED then
            for k, q in pairs(elevators) do
                for p, v in pairs(q.elevators) do
                    local dist = #(GLOBAL_COORDS - vector3(v.x, v.y, v.z))
                    if dist < 3.5 then
                        if not drawingMarker then
                            drawingMarker = k..p
                            DrawShit(v.x, v.y, v.z, drawingMarker)
                        end

                        if dist < 1.0 then
                            if not showing then
                                TriggerServerEvent('pw_keynote:server:triggerShowable', true, {{['type'] = "key", ['key'] = "e", ['action'] = "Use Elevator"}})
                                TriggerEvent('pw_drawtext:showNotification', { title = q.name, message = "<span style='font-size:24px;'>"..v.label.."</span>", icon = "fad fa-sort-circle" })
                                showing = k..p
                                controlKeys(k, p, showing)
                            end
                        elseif showing == k..p then
                            TriggerServerEvent('pw_keynote:server:triggerShowable', false)
                            TriggerEvent('pw_drawtext:hideNotification')
                            showing = false
                        end
                    elseif drawingMarker == k..p then
                        drawingMarker = false
                    end
                end
            end
        end
    end
end)

function FloorChosen(elev)
    local form = {
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = '<b>You are adding a new floor to<br><span class="text-primary">' .. elevators[elev].name .. '</span></b>' },
        { ['type'] = 'text', ['label'] = 'Floor name', ['name'] = 'name' },
        { ['type'] = 'hr' },
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = '<b>Confirm settings?</b>' },
        { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' },
        { ['type'] = 'hidden', ['name'] = 'elevator', ['value'] = elev },
        { ['type'] = 'hidden', ['name'] = 'coords', ['data'] = { ['x'] = GLOBAL_COORDS.x, ['y'] = GLOBAL_COORDS.y, ['z'] = GLOBAL_COORDS.z } }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_elevators:server:newFloor', 'server', form, "New floor | " .. elevators[elev].name, {}, false, '350px', { { ['trigger'] = 'pw_elevators:client:adminManageElevators', ['method'] = 'client' } })
end

RegisterNetEvent('pw_elevators:client:addFloor')
AddEventHandler('pw_elevators:client:addFloor', function(elev)
    if not addingFloor then
        addingFloor = true

        exports['pw_notify']:PersistentAlert('start', 'addFloor', 'inform', 'Head to the desired place and press <b><span style="color:#ffff00">SHIFT+X</span></b> to add it to this elevator<br><b><span style="color:#ffff00">SHIFT+C</span></b> will cancel the operation')

        Citizen.CreateThread(function()
            while addingFloor and characterLoaded do
                Citizen.Wait(1)
                if IsControlJustPressed(0, 73) and IsControlPressed(0, 21) then -- Shift+x
                    FloorChosen(elev)
                    addingFloor = false
                    exports['pw_notify']:PersistentAlert('end', 'addFloor')
                end

                if IsControlJustPressed(0, 79) and IsControlPressed(0, 21) then -- Shift+c
                    addingFloor = false
                    exports['pw_notify']:PersistentAlert('end', 'addFloor')
                    TriggerEvent('pw_elevators:client:adminManageElevators')
                end
            end
        end)
    end
end)

RegisterNetEvent('pw_elevators:client:deleteFloor')
AddEventHandler('pw_elevators:client:deleteFloor', function(data)
    local form = {
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = '<b>Delete <span class="text-primary">'..elevators[data.elevator].elevators[data.floor].label..'</span> of <span class="text-primary">'..elevators[data.elevator].name .. '</span>?</b>' },
        { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' },
        { ['type'] = 'hidden', ['name'] = 'elevator', ['value'] = data.elevator },
        { ['type'] = 'hidden', ['name'] = 'floor', ['value'] = data.floor }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_elevators:server:deleteFloor', 'server', form, "Delete " .. elevators[data.elevator].elevators[data.floor].label .. " | " .. elevators[data.elevator].name, {}, false, '350px', { { ['trigger'] = 'pw_elevators:client:adminManageElevators', ['method'] = 'client' } })
end)

RegisterNetEvent('pw_elevators:client:changeNameFloor')
AddEventHandler('pw_elevators:client:changeNameFloor', function(data)
    local form = {
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = '<b>Changing <span class="text-primary">' .. elevators[data.elevator].name .. '</span>\'s floor <span class="text-primary">' .. elevators[data.elevator].elevators[data.floor].label .. '</span></b>'},
        { ['type'] = 'text', ['label'] = 'New name for this floor', ['name'] = 'floorName' },
        { ['type'] = 'hr' },
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = '<b>Confirm new name?</b>' },
        { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' },
        { ['type'] = 'hidden', ['name'] = 'elevator', ['value'] = data.elevator },
        { ['type'] = 'hidden', ['name'] = 'floor', ['value'] = data.floor }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_elevators:server:changeNameFloor', 'server', form, 'New Floor Name | ' .. elevators[data.elevator].elevators[data.floor].label .. " | " .. elevators[data.elevator].name, {}, false, '350px', { { ['trigger'] = 'pw_elevators:client:adminManageElevators', ['method'] = 'client' } })
end)

RegisterNetEvent('pw_elevators:client:manageFloors')
AddEventHandler('pw_elevators:client:manageFloors', function(elev)
    local menu = {}
    for k,v in pairs(elevators[elev].elevators) do
        local subMenu = {}
        table.insert(subMenu, { ['label'] = '<b><span class="text-primary">Change Name</span></b>', ['action'] = 'pw_elevators:client:changeNameFloor', ['value'] = { ['elevator'] = elev, ['floor'] = k }, ['triggertype'] = 'client' })
        table.insert(subMenu, { ['label'] = '<b><span class="text-danger">Delete Floor</span></b>', ['action'] = 'pw_elevators:client:deleteFloor', ['value'] = { ['elevator'] = elev, ['floor'] = k }, ['triggertype'] = 'client' })
        table.insert(menu, { ['label'] = v.label, ['color'] = 'primary', ['subMenu'] = subMenu })
    end

    TriggerEvent('pw_interact:generateMenu', menu, "Manage Floors | " .. elevators[elev].name, { { ['trigger'] = 'pw_elevators:client:adminManageElevators', ['method'] = 'client' } })
end)

RegisterNetEvent('pw_elevators:client:deleteElevator')
AddEventHandler('pw_elevators:client:deleteElevator', function(elev)
    local form = {
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = '<b>Are you sure you want to<br><span class="text-danger">DELETE</span> <span class="text-primary">' .. elevators[elev].name ..'</span> elevator?</b>' },
        { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' },
        { ['type'] = 'hidden', ['name'] = 'elevator', ['value'] = elev }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_elevators:server:deleteElevator', 'server', form, 'Confirm Deletion', {}, false, '350px', { { ['trigger'] = 'pw_elevators:client:adminManageElevators', ['method'] = 'client' } } )
end)

RegisterNetEvent('pw_elevators:client:adminManageElevators')
AddEventHandler('pw_elevators:client:adminManageElevators', function()
    local menu = {}
    for k,v in pairs(elevators) do
        local subMenu = {}
        table.insert(subMenu, { ['label'] = '<span class="text-success"><b>Add New Floor</b>', ['action'] = 'pw_elevators:client:addFloor', ['value'] = k, ['triggertype'] = 'client' })
        table.insert(subMenu, { ['label'] = '<span class="text-primary"><b>Manage Floors</b>', ['action'] = 'pw_elevators:client:manageFloors', ['value'] = k, ['triggertype'] = 'client' })
        table.insert(subMenu, { ['label'] = '<span class="text-danger"><b>Delete Elevator</b>', ['action'] = 'pw_elevators:client:deleteElevator', ['value'] = k, ['triggertype'] = 'client' })
        table.insert(menu, { ['label'] = v.name, ['color'] = 'primary', ['subMenu'] = subMenu })
    end

    TriggerEvent('pw_interact:generateMenu', menu, "Manage Elevators", { { ['trigger'] = 'pw_elevators:client:adminMenu', ['method'] = 'client' } })
end)

RegisterNetEvent('pw_elevators:client:adminNewElevator')
AddEventHandler('pw_elevators:client:adminNewElevator', function()
    local form = {
        { ['type'] = 'text', ['label'] = 'Name for this Elevator', ['name'] = 'elevatorName' },
        { ['type'] = 'hr' },
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = '<b>Confirm new elevator?</b>' },
        { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_elevators:server:createElevator', 'server', form, 'New Elevator', {}, false, '350px', { { ['trigger'] = 'pw_elevators:client:adminMenu', ['method'] = 'client' } })
end)

RegisterNetEvent('pw_elevators:client:adminMenu')
AddEventHandler('pw_elevators:client:adminMenu', function()
    local menu = {}

    table.insert(menu, { ['label'] = 'Create New Elevator', ['action'] = 'pw_elevators:client:adminNewElevator', ['triggertype'] = 'client', ['color'] = 'primary' })
    table.insert(menu, { ['label'] = 'Manage Existing Elevators', ['action'] = 'pw_elevators:client:adminManageElevators', ['triggertype'] = 'client', ['color'] = 'primary' })

    TriggerEvent('pw_interact:generateMenu', menu, "Elevators Management")
end)