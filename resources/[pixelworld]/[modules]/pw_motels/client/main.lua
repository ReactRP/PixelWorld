PW = nil
characterLoaded, GLOBAL_PED, GLOBAL_COORDS, playerData = false, nil, nil, nil
motelComplexes, motelBlips, motelRooms = {}, {}, {}
local motelsLoaded = false

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
            GLOBAL_PED = PlayerPedId()
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
            characterLoaded = true
        else
            playerData = data
            PW.TriggerServerCallback('pw_motels:server:receiveComplexes', function(complexes, rooms)
                motelComplexes = complexes
                motelRooms = rooms
                doBlips(complexes)
                motelsLoaded = true
            end)
        end
    else
        removeBlips()
        playerData = nil
        characterLoaded = false
    end
end)

RegisterNetEvent('pw_motels:client:updateRoom')
AddEventHandler('pw_motels:client:updateRoom', function(rid, data)
    repeat Wait(0) until motelsLoaded == true
    if motelRooms[rid] then 
        motelRooms[rid] = data
        PW.Print(motelRooms)
    end
end)

function doBlips(comp)
    for k, v in pairs(comp) do
        motelBlips[k] = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
        SetBlipSprite(motelBlips[k], 475)
        SetBlipDisplay(motelBlips[k], 4)
        SetBlipScale  (motelBlips[k], 0.8)
        SetBlipColour (motelBlips[k], 8)
        SetBlipAsShortRange(motelBlips[k], true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.name)
        EndTextCommandSetBlipName(motelBlips[k])
    end
end

function removeBlips()
    for k, v in pairs(motelBlips) do 
        RemoveBlip(v)
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if characterLoaded then
            GLOBAL_PED = GLOBAL_PED
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if characterLoaded then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)

exports('getOccupier', function(room)
    print('Dor Req', room)
    return motelRooms[room].occupierCID
end)