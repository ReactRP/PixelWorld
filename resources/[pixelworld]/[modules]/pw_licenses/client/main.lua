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
            createBlip()
        else
            playerData = data
        end
    else
        playerData = nil
        characterLoaded = false
        destroyBlip()
        if ondrivingtest then
            exports.pw_notify:PersistentAlert('end', 'driving_test_speed')
            RemoveTestBlip()
        end
    end
end)

Citizen.CreateThread(function()
    while true do
    Citizen.Wait(500)
        if characterLoaded then
            local playerPed = PlayerPedId()
            if playerPed ~= GLOBAL_PED then
                GLOBAL_PED = playerPed
            end
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

local showingtxt, drawingMarker = false, false
local testblip, showingMarker, maxspeed, ondrivingtest, faults, maxfaults, lasthealth, awaitingreturn, vehicleinuse, testposition = {}, false, 20, false, 0, 5, 1000, false, nil, 1
local testid, attempts = 1, 1


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)
        if characterLoaded and playerData then  
            for k,v in pairs(Config.Points) do   
                for f,s in pairs(v) do
                    local dist = #(GLOBAL_COORDS - vector3(s.coords.x, s.coords.y, s.coords.z)) 
                    if dist < 5.0 then
                        if not drawingMarker then
                            drawingMarker = k .. f
                            DrawShit(s.coords.x, s.coords.y, s.coords.z, drawingMarker)
                        end
                        if dist < 1.0 then
                            if not showingtxt then
                                showingtxt = k .. f
                                DrawText(k, showingtxt)
                            end
                        elseif showingtxt == k .. f then
                            showingtxt = false
                            TriggerEvent('pw_drawtext:hideNotification')
                            TriggerServerEvent('pw_keynote:server:triggerShowable', false)
                        end  
                    elseif drawingMarker == k .. f then
                        drawingMarker = false   
                        showingtxt = false
                        TriggerEvent('pw_drawtext:hideNotification')
                        TriggerServerEvent('pw_keynote:server:triggerShowable', false)
                    end     
                end        
            end   
        end    
    end
end) 

function DrawShit(x, y, z, var)
    Citizen.CreateThread(function()
        while drawingMarker == var do
            Citizen.Wait(1)
            DrawMarker(2, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 255, 153, 51, 100, false, true, 2, false, nil, nil, false)
        end
    end)
end

function DrawText(type, var)
    local title, message, icon, key
    if type == 'roadTest' then
        title = "Department of Motor Vehicles"
        message = "<span style='font-size:25px'>Get A <span class='text-primary'>Vehicle</span> License</span>"
        icon = "fad fa-file-certificate"   
        key = "Vehicle Licenses"
    elseif type == 'licenseCheck' then
        title = "View Your Licenses"
        message = "<span style='font-size:25px'>View Your Own Licenses</span>"
        icon = "fad fa-file-certificate"   
        key = "View License Info"
    end      
    if title ~= nil and message ~= nil and icon ~= nil and key ~= nil then
        TriggerEvent('pw_drawtext:showNotification', { title = title, message = message, icon = icon })
        TriggerServerEvent('pw_keynote:server:triggerShowable', true, {{['type'] = "key", ['key'] = "e", ['action'] = key}})
    end

    Citizen.CreateThread(function()
        while showingtxt == var do
            Citizen.Wait(1)
            if IsControlJustPressed(0, 38) then
                if type == 'roadTest' then
                    OpenTestSelectMenu()
                elseif type == 'licenseCheck' then
                    TriggerServerEvent('pw_licenses:server:checkOwnLicenses')
                end
            end
        end
    end)
end


function OpenTestSelectMenu()
    local menu = {}
    local proceed = false
    PW.TriggerServerCallback('pw_license:server:isPlayerElegibleForVehicleLicense', function(allowedVehLicense, points)
        local licenseName = 'VEHICLE'
        if allowedVehLicense then
            table.insert(menu, { ['label'] = Config.LicenseLabels[licenseName] .. " - $".. Config.TestCost, ['action'] = 'pw_license:client:testselect', ['value'] = { ['test'] = licenseName, ['name'] = Config.LicenseLabels }, ['triggertype'] = 'client', ['color'] = 'primary' })
        else
            table.insert(menu, { ['label'] = Config.LicenseLabels[licenseName] .. (points == 15 and " <i>(Too Many License Points)</i>" or " <i>(You Already Have the License)</i>"), ['action'] = '', ['value'] = {}, ['triggertype'] = 'client', ['color'] = 'primary disabled' })
        end
        proceed = true
    end)
    repeat Wait(10) until proceed == true
    TriggerEvent('pw_interact:generateMenu', menu, "Vehicle License")
end

RegisterNetEvent('pw_license:client:testselect')
AddEventHandler('pw_license:client:testselect', function(test)
    OpenCarTest()
end)

function OpenCarTest()
    local proceed = false
    PW.TriggerServerCallback('pw_license:server:getTheoryQuestions', function(results)
        Config.DriversQuestions = results['VEHICLE']
        proceed = true
    end)
    repeat Wait(10) until proceed == true
    local testform = {}
    table.insert(testform, { ['type'] = "hidden", ['name'] = "questionsamount", ['value'] = #Config.DriversQuestions.questions})
    table.insert(testform, { ['type'] = "writting", ['align'] = 'center', ['value'] = '<img src="https://i.imgur.com/GrFfnc0.png" style="width:200px;height:200px;">'})
    table.insert(testform, { ['type'] = "writting", ['align'] = 'center', ['value'] = "<span style='font-size:25px' class='text-primary'><b>"..  Config.DriversQuestions.title .."</b><span>"})
    table.insert(testform, { ['type'] = "writting", ['align'] = 'center', ['value'] = "<span style='font-size:20px' class='text-primary'><b>Test Information</b><span>"})
    table.insert(testform, { ['type'] = "writting", ['align'] = 'center', ['value'] = Config.DriversQuestions.information})
    table.insert(testform, { ['type'] = "writting", ['align'] = 'center', ['value'] = "Please make sure to only check one option per question, otherwise it will become invalid which could cause you to fail.<br>You will be charged a license fee when you submit this form."})
    for i = 1, #Config.DriversQuestions.questions do
        table.insert(testform, { ['type'] = "writting", ['align'] = 'center', ['value'] = '<br><u>Question Number <b>'.. i .. '</b><br><br></u>' })
        table.insert(testform, { ['type'] = "writting", ['align'] = 'left', ['value'] = '<b>' .. Config.DriversQuestions.questions[i].question .. '</b>' })
        table.insert(testform, { ['type'] = "checkbox", ['label'] = '<b>Option A.</b> '.. Config.DriversQuestions.questions[i].choices.a, ['name'] = "ans" .. i .. "a", ['value'] = 'yes'})
        table.insert(testform, { ['type'] = "checkbox", ['label'] = '<b>Option B.</b> '.. Config.DriversQuestions.questions[i].choices.b, ['name'] = "ans" .. i .. "b", ['value'] = 'yes'})
        table.insert(testform, { ['type'] = "checkbox", ['label'] = '<b>Option C.</b> '.. Config.DriversQuestions.questions[i].choices.c, ['name'] = "ans" .. i .. "c", ['value'] = 'yes'})
        table.insert(testform, { ['type'] = "checkbox", ['label'] = '<b>Option D.</b> '.. Config.DriversQuestions.questions[i].choices.d, ['name'] = "ans" .. i .. "d", ['value'] = 'yes'})
    end    
    table.insert(testform, { ['type'] = "yesno", ['success'] = "Submit Test", ['reject'] = "Cancel Test"  })
    TriggerEvent('pw_interact:generateForm', 'pw_license:server:payRoadVehicleTest', 'server', testform, "Theory Test", true, false, '1000px')
end

RegisterNetEvent('pw_license:client:vehtestresults')
AddEventHandler('pw_license:client:vehtestresults', function(data)
    local questionamount = tonumber(data.questionsamount.value)
    local questiondata = {}
    for i = 1, questionamount do
        local ans = false
        local questiona = "ans" .. i .. "a"
        local questionb = "ans" .. i .. "b"
        local questionc = "ans" .. i .. "c"
        local questiond = "ans" .. i .. "d"

        if data[questiona].value and data[questionb].value and data[questionc].value and data[questiond].value then
            ans = false
        else   
            if data[questiona].value and Config.DriversQuestions.questions[i].correct == 'a' then
                ans = true
            elseif data[questionb].value and Config.DriversQuestions.questions[i].correct == 'b' then
                ans = true
            elseif data[questionc].value and Config.DriversQuestions.questions[i].correct == 'c' then
                ans = true
            elseif data[questiond].value and Config.DriversQuestions.questions[i].correct == 'd' then
                ans = true
            end 
        end 
        table.insert(questiondata, ans) 
    end   
    local correctans = 0
    for i = 1, #questiondata do
        if questiondata[i] then
            correctans = correctans + 1
        end
    end
    if correctans > 7 then -- need 7 out of 10
        OpenCarTestPass(correctans)
    else
        exports.pw_notify:SendAlert('error', 'You Have Failed the Test - With Only ' .. correctans .. ' Correct!', 7000)  
    end    
end)

function OpenCarTestPass(correct, type)
    local passedform = {
        { ['type'] = "writting", ['align'] = 'center', ['value'] = "<span style='font-size:25px' class='text-primary'><b>Theory Test Results</b><span>"},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = '<br>You Got <b>'.. correct ..' / 10</b><br>' },
        { ['type'] = "writting", ['align'] = 'center', ['value'] =  Config.DriversQuestions.pass },
        { ['type'] = "writting", ['align'] = 'center', ['value'] = '<br>If you wish to continue with your license, please agree below, if you don\'t agree the driving test will be cancelled and the theory test will become invalid.' },
        { ['type'] = "yesno", ['success'] = "Agree to the Conditions", ['reject'] = "Cancel"  },
    }
    TriggerEvent('pw_interact:generateForm', 'pw_license:client:startpracticaltest', 'client', passedform, "Theory Test Results", true, false, '1000px')
end

RegisterNetEvent('pw_license:client:startpracticaltest')
AddEventHandler('pw_license:client:startpracticaltest', function(data)
    showingtxt = false
    TriggerEvent('pw_drawtext:hideNotification')
    attempts = 1
    StartDrivingTest()
end)

function StartDrivingTest()
    testid = math.random(1, #Config.DrivingTestPoint) 
    faults, testposition, ondrivingtest = 0, 1, true
    local found = false
    for spawnPos = 1, #Config.DrivingTestSpawnPoints do
        local coords = Config.DrivingTestSpawnPoints[spawnPos]
        local cV = GetClosestVehicle(coords.x, coords.y, coords.z, 7.0, 0, 71)
        if cV == 0 or cV == nil then
            found = spawnPos
            break
        end
    end
    if found then
        PW.Game.SpawnOwnedVehicle(Config.TestVehicle, Config.DrivingTestSpawnPoints[found], Config.DrivingTestSpawnPoints[found].h, function(spawnedVeh)
            vehicleinuse = spawnedVeh
            --Set Fuel to Full Here
            TaskWarpPedIntoVehicle(GLOBAL_PED, spawnedVeh, -1)
            exports.pw_notify:SendAlert('inform', 'Welcome to the testing vehicle, please begin by making sure to fasten your seatbelt. Then pull forward to the marker on your GPS. Follow All Instructions', 12000)
            lasthealth = GetEntityHealth(spawnedVeh)
            maxspeed = Config.DrivingTestPoint[testid][testposition].max_speed
            CreateBlip(Config.DrivingTestPoint[testid][testposition].coords)
            BeginDrivingTest()
            StartSpeedAndDamageChecking() 
        end)
    else
        if attempts <= 5 then
            exports.pw_notify:SendAlert('error', 'All Spaces in the Carpark Are Blocked. Please Wait For One to Open Up and The Practical Test Will Start', 20000)
            waitForParkingSpace()
        else
            exports.pw_notify:SendAlert('error', 'Failed Finding Space After 5 Attempts', 6000)
        end
    end
end

function waitForParkingSpace()
    attempts = attempts + 1
    Citizen.SetTimeout(60000, function()
        StartDrivingTest()
    end)
end

function ParkTestVehicle()
    local pedVeh = GetVehiclePedIsIn(GLOBAL_PED)
    if vehicleinuse ~= nil and vehicleinuse == pedVeh then
        SetEntityAsMissionEntity(pedVeh, true, true)
        DeleteEntity(pedVeh)
        exports.pw_notify:SendAlert('error', 'Vehicle Parked', 7000) 
    end 
end 

function StartSpeedAndDamageChecking()
    Citizen.CreateThread(function()
        while ondrivingtest and characterLoaded do
            Citizen.Wait(1000)   
            local vehicle = GetVehiclePedIsIn(GLOBAL_PED)
            local speed = GetEntitySpeed(vehicle)
            local mph = math.ceil(speed * 2.236936)
            if mph > (maxspeed + 4) then -- allow 4 mph over the limit
                faults = faults + 1
                --Error Sound
                exports.pw_notify:SendAlert('error', 'That is too fast! The Speed Limit is '.. maxspeed .. ' MPH! <br>You Now Have <b>'.. faults .. '/' .. maxfaults .. '</b> Faults!', 15000)
                Citizen.Wait(2000)
            end 
            if GetEntityHealth(vehicle) < lasthealth then
                faults = faults + 1
                --Error Sound
                exports.pw_notify:SendAlert('error', 'Don\'t Crash the Vehicle! <br>You Now Have <b>'.. faults .. '/' .. maxfaults .. '</b> Faults!', 15000)
                Citizen.Wait(2000)
            end   
            lasthealth = GetEntityHealth(vehicle)
            if faults == maxfaults then
                exports.pw_notify:PersistentAlert('end', 'driving_test_speed')
                exports.pw_notify:SendAlert('error', 'You Have Failed the Test with <b>' .. faults .. '</b> Faults! Return Back to the Licensing Center.', 15000)
                RemoveTestBlip()
                showingMarker, ondrivingtest, awaitingreturn = false, false, true
                ReturnTestVehicle()
            end  
        end
    end)
end   

function MarkerDraw(x, y, z)
    Citizen.CreateThread(function()
        while showingMarker and characterLoaded do
            Citizen.Wait(1)   
            DrawMarker(2, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.6, 0.6, 0.6, 39, 70, 151, 100, true, true, 2, true, nil, nil, false)  
        end
    end)
end

function BeginDrivingTest()
    Citizen.CreateThread(function()
        while ondrivingtest and characterLoaded do
            Citizen.Wait(300)
            local playerCoords = GetEntityCoords(GLOBAL_PED)
            local dist = #(playerCoords - vector3(Config.DrivingTestPoint[testid][testposition].coords.x, Config.DrivingTestPoint[testid][testposition].coords.y, Config.DrivingTestPoint[testid][testposition].coords.z))
            if dist < 30 then
                if not showingMarker then
                    showingMarker = true
                    MarkerDraw(Config.DrivingTestPoint[testid][testposition].coords.x, Config.DrivingTestPoint[testid][testposition].coords.y, Config.DrivingTestPoint[testid][testposition].coords.z)
                end    
            else
                showingMarker = false
            end    
            if dist < 4 then
                if IsPedInAnyVehicle(GLOBAL_PED) then
                    NextPlease()    
                end    
            end    
        end    
    end)
end

function NextPlease()
    if testposition == #Config.DrivingTestPoint[testid] then
        TriggerServerEvent('pw_license:server:completeRoadVehicleTest')
        RemoveTestBlip()
        ondrivingtest, showingMarker, awaitingreturn = false, false, true
        exports.pw_notify:PersistentAlert('end', 'driving_test_speed')
        ReturnTestVehicle()
    else  
        exports.pw_notify:PersistentAlert('end', 'driving_test_speed')
        maxspeed = Config.DrivingTestPoint[testid][testposition].max_speed  
        local testmessage = Config.DrivingTestPoint[testid][testposition].message
        testposition = testposition + 1
        showingMarker = false
        RemoveTestBlip()
        CreateBlip(Config.DrivingTestPoint[testid][testposition].coords)
        --Success Sound?
        exports.pw_notify:SendAlert('inform', testmessage, 15000)
        Citizen.Wait(1200)
        exports.pw_notify:PersistentAlert('start', 'driving_test_speed', 'info', 'Current Speed Limit: '.. maxspeed .. 'MPH')
    end    
end

function ReturnTestVehicle()
    Citizen.CreateThread(function()
        CreateBlip(Config.DrivingTestReturn.coords)
        exports.pw_notify:PersistentAlert('end', 'driving_test_speed')
        exports.pw_notify:SendAlert('info', 'Return the Vehicle back to the DMV', 5000)
        while awaitingreturn and characterLoaded do
            Citizen.Wait(1000)
            if DoesEntityExist(vehicleinuse) then
                local playerCoords = GetEntityCoords(GLOBAL_PED)
                local dist = #(playerCoords - vector3(Config.DrivingTestReturn.coords.x, Config.DrivingTestReturn.coords.y, Config.DrivingTestReturn.coords.z))
                if dist < 30.0 then
                    if not showingMarker then
                        showingMarker = true
                        MarkerDraw(Config.DrivingTestReturn.coords.x, Config.DrivingTestReturn.coords.y, Config.DrivingTestReturn.coords.z)
                    end 
                    if dist < 3.0 then
                        RemoveTestBlip()
                        showingMarker, awaitingreturn = false, false
                        ParkTestVehicle()  
                    end     
                else
                    showingMarker = false
                end  
            else
                RemoveTestBlip()
                showingMarker, awaitingreturn = false, false
            end
        end    
    end)
end

function CreateBlip(coords)
    if coords ~= nil then
        testblip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipColour(testblip, 1)
        SetBlipRoute(testblip, true)
        SetBlipRouteColour(testblip, 1)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString('Delivery Point')
        EndTextCommandSetBlipName(testblip)
    end    
end

function RemoveTestBlip()
    if testblip ~= {} then
        RemoveBlip(testblip)
        testblip = {}
    end
end

local blips = {}

function createBlip()
    Citizen.CreateThread(function()
        for k,v in pairs(Config.Points) do
            print(k)
            if Config.Blips[k] ~= nil then
                for j,b in pairs(v) do
                    local current = k .. j
                    print(current)
                    blips[current] = AddBlipForCoord(b.coords.x, b.coords.y, b.coords.z)
                    PW.Print(Config.Blips[k])
                    SetBlipSprite(blips[current], Config.Blips[k].type)
                    SetBlipDisplay(blips[current], 4)
                    SetBlipScale  (blips[current], Config.Blips[k].scale)
                    SetBlipColour (blips[current], Config.Blips[k].color)
                    SetBlipAsShortRange(blips[current], true)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString(Config.Blips[k].name)
                    EndTextCommandSetBlipName(blips[current])
                end
            end
        end
    end)
end

function destroyBlip()
    for k,v in pairs(blips) do
        RemoveBlip(v)
    end
end
