PW, characterLoaded, playerData = nil, false, nil
local showing, drawingMarker = false, false
local input = nil
local blips = {}

PW = nil
characterLoaded, GLOBAL_PED, GLOBAL_COORDS, playerData = false, nil, nil, nil

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
            createBlips()
        else
            playerData = data
        end
    else
        destroyBlips()
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

local fishing, waiting, bait = false, false, 0


function IsFacingWater(playerLocation, playerHeading) 
    local axis = nil
    local facingWater = false
    if playerHeading >= 135 and playerHeading <= 225 then
        axis = '-y'
    elseif playerHeading >= 0 and playerHeading <= 45 then
        axis = '+y'
    elseif playerHeading >= 315 and playerHeading <= 360 then
        axis = '+y'    
    elseif playerHeading >= 45 and playerHeading <= 135 then
        axis = '-x' 
    else
        axis = 'x'   
    end    
    if axis == '-y' then
        facingWater = GetWaterHeight(playerLocation.x, playerLocation.y - 2.5, playerLocation.z)
    elseif axis == '-x' then
        facingWater = GetWaterHeight(playerLocation.x - 2.5, playerLocation.y, playerLocation.z)
    elseif axis == 'y' then
        facingWater = GetWaterHeight(playerLocation.x, playerLocation.y + 2.5, playerLocation.z)
    elseif axis == 'x' then
        facingWater = GetWaterHeight(playerLocation.x + 2.5, playerLocation.y, playerLocation.z)        
    end
	return facingWater
end


RegisterNetEvent('pw_fishing:startFishing')
AddEventHandler('pw_fishing:startFishing', function()
    local playerHeading = GetEntityHeading(GLOBAL_PED)

	if IsPedInAnyVehicle(GLOBAL_PED) then
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = "Cannot Start Fishing, Get Out of the Vehicle.", length = 5000})
        
    elseif IsPedSwimming(GLOBAL_PED) or IsPedFatallyInjured(GLOBAL_PED) then -- Checks
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = "Cannot Start Fishing", length = 5000})
    else
        if IsFacingWater(GLOBAL_COORDS, playerHeading) ~= false then
            TriggerEvent('pw:notification:SendAlert', {type = "inform", text = "Starting Fishing", length = 2500})
			TaskStartScenarioInPlace(GLOBAL_PED, "WORLD_HUMAN_STAND_FISHING", 0, true) 
            fishing = true
            StartFishingCancelChecks()
            StartFishingCatchChecks()
            StartFishingCatchChecks2()

            local title, msg, icon
            title = "<span style='font-size:25px; color:#009bde'><center>Fishing</center></span>"
            msg = "<span style='font-size:20px;'>Press <span style='color:#cf0000;'>[<strong>E</strong>]</span> to pull<br>Press <span style='color:#cf0000;'>[<strong>X</strong>]</span> to stop<br>Bait: <span style='color:#cf0000;'><strong>No Bait</strong></span></span>"
            icon = "fas fa-fish"

            TriggerEvent('pw_drawtext:showNotification', {title = title, message = msg, icon = icon })
		else
			TriggerEvent('pw:notification:SendAlert', {type = "error", text = "Cannot Start Fishing, Not Facing Water", length = 5000})
        end
        
	end
end)

RegisterNetEvent('pw_fishing:setbait')
AddEventHandler('pw_fishing:setbait', function(baitType)
    bait = baitType
    local baitlabel = 'No bait'
    if baitType and baitType > 0 then
        if baitType == 1 then
            baitlabel = 'Regular Fish Bait'
        elseif baitType == 2 then
            baitlabel = 'Advanced Fish Bait'  
        elseif baitType == 3 then
            baitlabel = 'Turtle Meat' 
        end         
        TriggerEvent('pw:notification:SendAlert', {type = "success", text = "Attached " .. baitlabel .. " to Fishing Rod!", length = 5000})
    else
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = "You lost your bait", length = 5000})
    end

    local title, msg, icon
    title = "<span style='font-size:25px; color:#009bde'><center>Fishing</center></span>"
    msg = "<span style='font-size:20px;'>Press <span style='color:#cf0000;'>[<strong>E</strong>]</span> to pull<br>Press <span style='color:#cf0000;'>[<strong>X</strong>]</span> to stop<br>Bait: <span style='color:#" .. (baitType > 0 and "1a9e00" or "cf0000") .. ";'><strong>" .. baitlabel .. "</strong></span></span>"
    icon = "fas fa-fish"
    TriggerEvent('pw_drawtext:showNotification', {title = title, message = msg, icon = icon })
end)

RegisterNetEvent('pw_fishing:breakrod') -- Break Fishing Rod and Stop Fishing
AddEventHandler('pw_fishing:breakrod', function()
	fishing = false
    ClearPedTasks(GLOBAL_PED)
    TriggerEvent('pw:notification:SendAlert', {type = "error", text = "Fishing Rod Broke, the Fish was too Heavy", length = 5000})
end)

function StartFishingCancelChecks()
    Citizen.CreateThread(function()
        while fishing do
            Citizen.Wait(1)
            sleeping = false
            local playerHeading = GetEntityHeading(GLOBAL_PED)
            if IsFacingWater(GLOBAL_COORDS, playerHeading) == false or IsPedSwimming(GLOBAL_PED) or IsPedFatallyInjured(GLOBAL_PED) or IsPedInAnyVehicle(GLOBAL_PED) or IsControlJustPressed(0, 73) then -- For When to Stop Fishing
                fishing = false
                TriggerEvent('pw:notification:SendAlert', {type = "inform", text = "Stopped Fishing", length = 5000})
                ClearPedTasks(GLOBAL_PED)
                TriggerEvent('pw_drawtext:hideNotification')
            end       
        end
    end)
end

function StartFishingCatchChecks()
    Citizen.CreateThread(function()
        while fishing do 
            Citizen.Wait(1)
            if IsControlJustPressed(0, 38) then -- Checks if E is pressed for pulling the fish in
                if input and input == 0 then
                    input = 1
                end
            end
            if input and input > 0 then
                if waiting then
                    waiting = false
                    if input == 1 then
                        input = nil
                        TriggerServerEvent('pw_fishing:catch', bait, GLOBAL_COORDS)
                    end
                else
                    input = nil
                    TriggerEvent('pw:notification:SendAlert', {type = "error", text = "Unlucky! The Fish Escaped.", length = 5000})
                end
            end     
        end
    end)
end    

function StartFishingCatchChecks2()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(100)
            if fishing then
                local randomwait = math.random((Config.WaitTime.min * 1000), (Config.WaitTime.max * 1000))
                Citizen.Wait(randomwait)
                waiting = true
                TriggerEvent('pw:notification:SendAlert', {type = "warning", text = "You feel a fish pulling on the rod", length = 5000})
                input = 0
                local randomCatchWait = math.random(Config.CatchTime.min, Config.CatchTime.max) * 1000
                Citizen.SetTimeout(randomCatchWait, function()
                    waiting = false
                end)
            else
                Citizen.Wait(1000)
                break
            end       
        end
    end)
end   


function DrawShit(x, y, z, var)
    Citizen.CreateThread(function()
        while drawingMarker == var do
            Citizen.Wait(1)
            DrawMarker(Config.Marker.markerType, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.markerSize.x, Config.Marker.markerSize.y, Config.Marker.markerSize.z, Config.Marker.markerColor.r, Config.Marker.markerColor.g, Config.Marker.markerColor.b, 100, false, true, 2, false, nil, nil, false)
        end
    end)
end

function DrawText(type, var)
    local title, message, icon, key
    
    if type == 'fishSales' then
        title = "Fish Sales"
        message = "<span style='font-size:20px'><b><span class='text-primary'>Sell Fish</span></b></span>"
        icon = "fas fa-fish"
        key = "Sell Fish"

    end

    if title ~= nil and message ~= nil and icon ~= nil and key ~= nil then
        TriggerEvent('pw_drawtext:showNotification', { title = title, message = message, icon = icon })
        TriggerEvent('pw_keynote:server:triggerShowable', true, {{['type'] = 'key', ['key'] = "e", ['action'] = key}})
    end

    Citizen.CreateThread(function()
        while showing == var do
            Citizen.Wait(1)
            if IsControlJustPressed(0, 38) then
                if type == 'fishSales' then
                    OpenFishSaleMenu()
                --elseif type == 'illegalFishSales' then
                    --print("OPEN ILLEGAL FISH SALES")
                end
            end
        end
    end)
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if characterLoaded and playerData then

            for k,v in pairs(Config.Points) do
                local dist = #(GLOBAL_COORDS - vector3(v.coords.x, v.coords.y, v.coords.z))
                if dist < 15.0 then
                    if not drawingMarker then
                        drawingMarker = k
                        DrawShit(v.coords.x, v.coords.y, v.coords.z, drawingMarker)
                    end

                    if dist < v.drawDistance then
                        if not showing then
                            showing = k
                            DrawText(showing, k)
                        end
                    elseif showing == k then
                        showing = false
                        TriggerEvent('pw_drawtext:hideNotification')
                        TriggerEvent('pw_keynote:server:triggerShowable', false)
                    end
                elseif drawingMarker == k then
                    drawingMarker = false   
                end      
            end
        end    
    end
end)

function OpenFishSaleMenu()
    local menu = {}

    for i = 1, #Config.FishType do
        table.insert(menu, { ['label'] = Config.FishType[i].label, ['action'] = 'pw_fishing:sellFish', ['value'] = { ['name'] = Config.FishType[i].name, ['label'] = Config.FishType[i].label }, ['triggertype'] = 'server', ['color'] = 'primary' })
    end

    TriggerEvent('pw_interact:generateMenu', menu, "Fish Sales")
end

-- (Selling) --

function OpenFishSaleMenu()
    local menu = {}
    local menuItems = 0
    for i = 1, #Config.FishSales do
        local itemCount = PW.Game.CheckInventory(Config.FishSales[i].item)
        if itemCount > 0 then
            table.insert(menu, { ['label'] = Config.FishSales[i].label .. " <i>(You Have " .. itemCount ..")</i>", ['action'] = 'pw_fishing:client:sellingFish', ['value'] = { ['saleid'] = i, ['label'] = Config.FishSales[i].label, ['amount'] = itemCount }, ['triggertype'] = 'client', ['color'] = "primary" })
            menuItems = (menuItems + 1)
        end    
    end
    if menuItems ~= 0 then
        TriggerEvent('pw_interact:generateMenu', menu, "Sell Fish")
    else
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = "You Don't have Any Fish that we Buy!", length = 5000})
    end  
end

RegisterNetEvent('pw_fishing:client:sellingFish')
AddEventHandler('pw_fishing:client:sellingFish', function(data)
    TriggerEvent('pw:progressbar:progress',
    {
        name = 'inspecting_rock',
        duration = (3000 * data.amount),
        label = 'Selling ' .. data.amount .. ' '.. data.label,
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "missheistdockssetup1clipboard@base",
            anim = "base",
            flags = 49,
        },
        prop = {
            model = "p_amb_clipboard_01",
            bone = 18905,
            coords = { x = 0.10, y = 0.02, z = 0.08 },
            rotation = { x = -80.0, y = 0.0, z = 0.0 },
        },
        propTwo = {
            model = "prop_pencil_01",
            bone = 58866,
            coords = { x = 0.12, y = 0.0, z = 0.001 },
            rotation = { x = -150.0, y = 0.0, z = 0.0 },
        },
    },
    function(status)
        if not status then
            TriggerServerEvent('pw_fishing:server:sellFish', data)
        else
            TriggerEvent('pw:notification:SendAlert', {type = "error", text = "Cancelled Selling Fish", length = 5000})
        end
    end)       
end)



function createBlips()
    Citizen.CreateThread(function()
        for k, v in pairs(Config.Points) do
            blips[k] = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
            SetBlipSprite(blips[k], Config.Blips.type)
            SetBlipDisplay(blips[k], 4)
            SetBlipScale  (blips[k], Config.Blips.scale)
            SetBlipColour (blips[k], Config.Blips.color)
            SetBlipAsShortRange(blips[k], true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Config.Blips.name)
            EndTextCommandSetBlipName(blips[k])
        end
    end)
end

function destroyBlips()
    for k, v in pairs(blips) do
        RemoveBlip(v)
    end
end