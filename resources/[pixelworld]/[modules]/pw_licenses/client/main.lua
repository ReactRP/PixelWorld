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


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)
        if characterLoaded and playerData then  
            for k,v in pairs(Config.Points) do   
                local dist = #(GLOBAL_COORDS - vector3(v.coords.x, v.coords.y, v.coords.z)) 
                if dist < 5.0 then
                    if not drawingMarker then
                        drawingMarker = k
                        DrawShit(v.coords.x, v.coords.y, v.coords.z, drawingMarker)
                    end

                    if dist < 1.0 then
                        if not showingtxt then
                            showingtxt = k
                            DrawText(k, showingtxt)
                        end
                    elseif showingtxt == k then
                        showingtxt = false
                        TriggerEvent('pw_drawtext:hideNotification')
                        TriggerServerEvent('pw_keynote:server:triggerShowable', false)
                    end  
                elseif drawingMarker == k then
                    drawingMarker = false   
                    showingtxt = false
                    TriggerEvent('pw_drawtext:hideNotification')
                    TriggerServerEvent('pw_keynote:server:triggerShowable', false)
                end             
            end   
        end    
    end
end) 

function DrawShit(x, y, z, var)
    Citizen.CreateThread(function()
        while drawingMarker == var do
            Citizen.Wait(1)
            DrawMarker(Config.Marker.markerType, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.markerSize.x, Config.Marker.markerSize.y, Config.Marker.markerSize.z, Config.Marker.markerColor.r, Config.Marker.markerColor.g, Config.Marker.markerColor.b, 100, false, true, 2, false, nil, nil, false)
        end
    end)
end

function DrawText(type, var, heading, rockID)
    local title, message, icon, key
    if type == 'roadTest' then
        title = "Vehicle Licensing"
        message = "Get A <span class='text-primary'>Road Vehicle</span> License"
        icon = "fad fa-file-certificate"   
        key = "Vehicle Licenses"
    elseif type == 'weaponCert' then
        title = "Firearms Certificate"
        message = "Get A <span class='text-primary'>Firearms</span> Certification"
        icon = "fad fa-file-certificate"   
        key = "Firearms Certificate"
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
                elseif type == 'weaponCert' then
                    OpenWeaponCertificateMenu()
                end
            end
        end
    end)
end

-- Vehicle Tests (Car, CDL etc)

function OpenTestSelectMenu()
    local menu = {}
    local proceed = false
    PW.TriggerServerCallback('pw_license:server:getPlayerLicenses', function(licenses)
        for a = 1, #Config.AvailableVehicleTests do
            local found = false
            if licenses then
                for b = 1, #licenses do
                    if Config.AvailableVehicleTests[a].test ==  licenses[b].type then
                        found = true
                    end   
                end     
            end
            table.insert(menu, { ['label'] = Config.AvailableVehicleTests[a].name .. (found and " <i>(You Already Hold This License)</i>" or " - $".. Config.TestCost[Config.AvailableVehicleTests[a].test]), ['action'] = 'pw_license:client:testselect', ['value'] = { ['test'] = Config.AvailableVehicleTests[a].test, ['name'] = Config.AvailableVehicleTests[a].name }, ['triggertype'] = 'client', ['color'] = (found and 'primary disabled' or 'primary') })
        end
        proceed = true
    end)
    repeat Wait(10) until proceed == true
    TriggerEvent('pw_interact:generateMenu', menu, "What Vehicle License Do You Want to Apply For?")
end

RegisterNetEvent('pw_license:client:testselect')
AddEventHandler('pw_license:client:testselect', function(test)
    OpenCarTest(test.test)
end)

function OpenCarTest(type)
    local proceed = false
    PW.TriggerServerCallback('pw_license:server:getTheoryQuestions', function(results)
        Config.DriversQuestions = results
        proceed = true
    end)
    repeat Wait(10) until proceed == true
    local testform = {}
    table.insert(testform, { ['type'] = "hidden", ['name'] = "testtype", ['value'] = type})
    table.insert(testform, { ['type'] = "hidden", ['name'] = "questionsamount", ['value'] = #Config.DriversQuestions[type].questions})
    table.insert(testform, { ['type'] = "writting", ['align'] = 'center', ['value'] = '<img src="https://i.imgur.com/GrFfnc0.png" style="width:200px;height:200px;">'})
    table.insert(testform, { ['type'] = "writting", ['align'] = 'center', ['value'] = "<span style='font-size:25px' class='text-primary'><b>"..  Config.DriversQuestions[type].title .."</b><span>"})
    table.insert(testform, { ['type'] = "writting", ['align'] = 'center', ['value'] = "<span style='font-size:20px' class='text-primary'><b>Test Information</b><span>"})
    table.insert(testform, { ['type'] = "writting", ['align'] = 'center', ['value'] = Config.DriversQuestions[type].information})
    table.insert(testform, { ['type'] = "writting", ['align'] = 'center', ['value'] = "Please make sure to only check one option per question, otherwise it will become invalid which could cause you to fail.<br>You will be charged a license fee when you submit this form."})
    for i = 1, #Config.DriversQuestions[type].questions do
        table.insert(testform, { ['type'] = "writting", ['align'] = 'center', ['value'] = '<br><u>Question Number <b>'.. i .. '</b><br><br></u>' })
        table.insert(testform, { ['type'] = "writting", ['align'] = 'left', ['value'] = '<b>' .. Config.DriversQuestions[type].questions[i].question .. '</b>' })
        table.insert(testform, { ['type'] = "checkbox", ['label'] = '<b>Option A.</b> '.. Config.DriversQuestions[type].questions[i].choices.a, ['name'] = "ans" .. i .. "a", ['value'] = 'yes'})
        table.insert(testform, { ['type'] = "checkbox", ['label'] = '<b>Option B.</b> '.. Config.DriversQuestions[type].questions[i].choices.b, ['name'] = "ans" .. i .. "b", ['value'] = 'yes'})
        table.insert(testform, { ['type'] = "checkbox", ['label'] = '<b>Option C.</b> '.. Config.DriversQuestions[type].questions[i].choices.c, ['name'] = "ans" .. i .. "c", ['value'] = 'yes'})
        table.insert(testform, { ['type'] = "checkbox", ['label'] = '<b>Option D.</b> '.. Config.DriversQuestions[type].questions[i].choices.d, ['name'] = "ans" .. i .. "d", ['value'] = 'yes'})
    end    
    table.insert(testform, { ['type'] = "yesno", ['success'] = "Submit Test", ['reject'] = "Cancel Test"  })
    TriggerEvent('pw_interact:generateForm', 'pw_license:server:payRoadVehicleTest', 'server', testform, "Theory Test", true, false, '1000px')
end

RegisterNetEvent('pw_license:client:vehtestresults')
AddEventHandler('pw_license:client:vehtestresults', function(data)
    local testtype = data.testtype.value
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
            if data[questiona].value and Config.DriversQuestions[testtype].questions[i].correct == 'a' then
                ans = true
            elseif data[questionb].value and Config.DriversQuestions[testtype].questions[i].correct == 'b' then
                ans = true
            elseif data[questionc].value and Config.DriversQuestions[testtype].questions[i].correct == 'c' then
                ans = true
            elseif data[questiond].value and Config.DriversQuestions[testtype].questions[i].correct == 'd' then
                ans = true
            end 
        end 
        table.insert(questiondata, ans) 
    end  
    PW.Print(questiondata)  
    local correctans = 0
    for i = 1, #questiondata do
        if questiondata[i] then
            correctans = correctans + 1
        end
    end
    print(correctans, '/', #questiondata)   
    if correctans > 7 then -- need 7 out of 10
        OpenCarTestPass(correctans, testtype)
    else
        exports.pw_notify:SendAlert('error', 'You Have Failed the Test - With Only ' .. correctans .. ' Correct!', 7000)  
    end    
end)

function OpenCarTestPass(correct, type)
    local passedform = {
        { ['type'] = "hidden", ['name'] = "testtype", ['value'] = type},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = "<span style='font-size:25px' class='text-primary'><b>Theory Test Results</b><span>"},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = '<br>You Got <b>'.. correct ..' / 10</b><br>' },
        { ['type'] = "writting", ['align'] = 'center', ['value'] =  Config.DriversQuestions[type].pass },
        { ['type'] = "writting", ['align'] = 'center', ['value'] = '<br>If you wish to continue with your license, please agree below, if you don\'t agree the driving test will be cancelled and the theory test will become invalid.' },
        { ['type'] = "yesno", ['success'] = "Agree to the Conditions", ['reject'] = "Cancel"  },
    }
    TriggerEvent('pw_interact:generateForm', 'pw_license:client:startpracticaltest', 'client', passedform, "Theory Test Results", true, false, '1000px')
end

RegisterNetEvent('pw_license:client:startpracticaltest')
AddEventHandler('pw_license:client:startpracticaltest', function(data)
    showingtxt = false
    TriggerEvent('pw_drawtext:hideNotification')
    StartDrivingTest(data.testtype.value)
end)

local testblip, showingMarker, maxspeed, ondrivingtest, faults, maxfaults, lasthealth, awaitingreturn, vehicleinuse, testposition = {}, false, 20, false, 0, 5, 1000, false, nil, 1
local testtype, testid = 'CAR', 1

function StartDrivingTest(type)
    testtype = type
    testid = math.random(1, #Config.DrivingTestPoint[testtype]) 
    faults, testposition, ondrivingtest = 0, 1, true
    SpawnTestVehicle()
    lasthealth = GetEntityHealth(vehicle)
    maxspeed = Config.DrivingTestPoint[testtype][testid][testposition].max_speed
    CreateBlip(Config.DrivingTestPoint[testtype][testid][testposition].coords)
    BeginDrivingTest()
    StartSpeedAndDamageChecking()
end

function SpawnTestVehicle()
    local coords = Config.DrivingTestSpawnPoint.coords
    local cV = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
    if cV == 0 or cV == nil then
        PW.Game.SpawnOwnedVehicle(Config.TestVehicle[testtype], coords, coords.h, function(spawnedVeh)
            --[[PW.TriggerServerCallback('pw_vehicleshop:server:registerPotentialVin', function(vin)
                TriggerServerEvent('pw_keys:issueKey', "Vehicle", vin, false, true)
                vehicleinuse = vin
            end, props, spawnedVeh)]]
            vehicleinuse = spawnedVeh
            --exports['pw_fuel2']:setFuelLevel(spawnedVeh, 100) Set Fuel to Full Here
            TaskWarpPedIntoVehicle(GLOBAL_PED, spawnedVeh, -1)
            exports.pw_notify:SendAlert('inform', 'Welcome to the testing vehicle, please begin by making sure to fasten your seatbelt. Then pull forward to the marker on your GPS. Follow All Instructions', 12000) 
        end)
    else
        exports.pw_notify:SendAlert('error', 'There\'s a vehicle blocking the vehicle exit', 7000) 
    end
end

function ParkTestVehicle()
    local pedVeh = GetVehiclePedIsIn(GLOBAL_PED)
    if vehicleinuse ~= nil and vehicleinuse == pedVeh then
        --TriggerServerEvent('pw_keys:revokeKeys', 'Vehicle', vin, true, nil)
        SetEntityAsMissionEntity(pedVeh, true, true)
        DeleteEntity(pedVeh)
        exports.pw_notify:SendAlert('error', 'Vehicle Parked', 7000) 
    else
        exports.pw_notify:SendAlert('error', 'This Isn\'t the Vehicle so You Cannot Return it Here!', 7000) 
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
                --PlaySound(-1, 'LOSER', 'HUD_AWARDS', false, 0, true)
                exports.pw_notify:SendAlert('error', 'That is too fast! The Speed Limit is '.. maxspeed .. ' MPH! <br>You Now Have <b>'.. faults .. '/' .. maxfaults .. '</b> Faults!', 9000)
                Citizen.Wait(2000)
            end 
            if GetEntityHealth(vehicle) < lasthealth then
                faults = faults + 1
                --PlaySound(-1, 'LOSER', 'HUD_AWARDS', false, 0, true)
                exports.pw_notify:SendAlert('error', 'Don\'t Crash the Vehicle! <br>You Now Have <b>'.. faults .. '/' .. maxfaults .. '</b> Faults!', 9000)
                Citizen.Wait(2000)
            end   
            lasthealth = GetEntityHealth(vehicle)
            if faults == maxfaults then
                exports.pw_notify:SendAlert('error', 'You Have Failed the Test with <b>' .. faults .. '</b> Faults! Return Back to the Licensing Center.', 10000)
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
            DrawMarker(2, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 39, 70, 151, 100, true, true, 2, true, nil, nil, false)  
        end
    end)
end

function BeginDrivingTest()
    Citizen.CreateThread(function()
        while ondrivingtest and characterLoaded do
            Citizen.Wait(300)
            local playerCoords = GetEntityCoords(GLOBAL_PED)
            local dist = #(playerCoords - vector3(Config.DrivingTestPoint[testtype][testid][testposition].coords.x, Config.DrivingTestPoint[testtype][testid][testposition].coords.y, Config.DrivingTestPoint[testtype][testid][testposition].coords.z))
            if dist < 30 then
                if not showingMarker then
                    showingMarker = true
                    MarkerDraw(Config.DrivingTestPoint[testtype][testid][testposition].coords.x, Config.DrivingTestPoint[testtype][testid][testposition].coords.y, Config.DrivingTestPoint[testtype][testid][testposition].coords.z)
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
    if testposition == #Config.DrivingTestPoint[testtype][testid] then
        TriggerServerEvent('pw_license:server:completeRoadVehicleTest', testtype)
        RemoveTestBlip()
        ondrivingtest, showingMarker, awaitingreturn = false, false, true
        ReturnTestVehicle()
    else  
        maxspeed = Config.DrivingTestPoint[testtype][testid][testposition].max_speed  
        local testmessage = Config.DrivingTestPoint[testtype][testid][testposition].message
        testposition = testposition + 1
        showingMarker = false
        RemoveTestBlip()
        CreateBlip(Config.DrivingTestPoint[testtype][testid][testposition].coords)
        --PlaySound(-1, 'SELECT', 'HUD_FREEMODE_SOUNDSET', false, 0, true)

        exports.pw_notify:SendAlert('inform', testmessage .. '<br>The Speed Limit is '.. maxspeed .. 'MPH!', 5000)
    end    
end

function ReturnTestVehicle()
    Citizen.CreateThread(function()
        CreateBlip(Config.DrivingTestReturn.coords)
        while awaitingreturn and characterLoaded do
            Citizen.Wait(2000)
            local playerCoords = GetEntityCoords(GLOBAL_PED)
            local dist = #(playerCoords - vector3(Config.DrivingTestReturn.coords.x, Config.DrivingTestReturn.coords.y, Config.DrivingTestReturn.coords.z))
            if dist < 30 then
                if not showingMarker then
                    showingMarker = true
                    MarkerDraw(Config.DrivingTestReturn.coords.x, Config.DrivingTestReturn.coords.y, Config.DrivingTestReturn.coords.z)
                end    
            else
                showingMarker = false
            end    
            if dist < 3 then
                RemoveTestBlip()
                showingMarker, awaitingreturn = false, false
                ParkTestVehicle()  
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

----

-- Weapons Licenses


function OpenWeaponCertificateMenu()
    local menu = {}
    local proceed = false
    PW.TriggerServerCallback('pw_license:server:doesCharacterHaveWeaponCertApproval', function(hasWeaponCertificate)
        print(hasWeaponCertificate)
        table.insert(menu, { ['label'] = Config.WeaponsTest.name .. (hasWeaponCertificate and " <i>(You Already Hold This Certificate)</i>" or " - $".. Config.TestCost[Config.WeaponsTest.test]), ['action'] = 'pw_license:client:startAWeaponCertTest', ['value'] = { ['test'] = Config.WeaponsTest.test, ['name'] = Config.WeaponsTest.name }, ['triggertype'] = 'client', ['color'] = (hasWeaponCertificate and 'primary disabled' or 'primary') })
        proceed = true
    end)
    repeat Wait(10) until proceed == true
    TriggerEvent('pw_interact:generateMenu', menu, "Firearms Certificate Application")
end


RegisterNetEvent('pw_license:client:startAWeaponCertTest')
AddEventHandler('pw_license:client:startAWeaponCertTest', function()
    local proceed = false
    PW.TriggerServerCallback('pw_license:server:getTheoryQuestions', function(results)
        PW.Print(results)
        Config.WeaponsQuestions = results['FIREARM']
        proceed = true
    end)
    repeat Wait(10) until proceed == true
    local testform = {}
    table.insert(testform, { ['type'] = "hidden", ['name'] = "testtype", ['value'] = type})
    table.insert(testform, { ['type'] = "hidden", ['name'] = "questionsamount", ['value'] = #Config.WeaponsQuestions.questions})
    table.insert(testform, { ['type'] = "writting", ['align'] = 'center', ['value'] = '<img src="https://i.imgur.com/GrFfnc0.png" style="width:200px;height:200px;">'})
    table.insert(testform, { ['type'] = "writting", ['align'] = 'center', ['value'] = "<span style='font-size:25px' class='text-primary'><b>"..  Config.WeaponsQuestions.title .."</b><span>"})
    table.insert(testform, { ['type'] = "writting", ['align'] = 'center', ['value'] = "<span style='font-size:20px' class='text-primary'><b>Test Information</b><span>"})
    table.insert(testform, { ['type'] = "writting", ['align'] = 'center', ['value'] = Config.WeaponsQuestions.information})
    table.insert(testform, { ['type'] = "writting", ['align'] = 'center', ['value'] = "Please make sure to only check one option per question, otherwise it will become invalid which could cause you to fail.<br>You will be charged a license fee when you submit this form."})
    for i = 1, #Config.WeaponsQuestions.questions do
        table.insert(testform, { ['type'] = "writting", ['align'] = 'center', ['value'] = '<br><u>Question Number <b>'.. i .. '</b><br><br></u>' })
        table.insert(testform, { ['type'] = "writting", ['align'] = 'left', ['value'] = '<b>' .. Config.WeaponsQuestions.questions[i].question .. '</b>' })
        table.insert(testform, { ['type'] = "checkbox", ['label'] = '<b>Option A.</b> '.. Config.WeaponsQuestions.questions[i].choices.a, ['name'] = "ans" .. i .. "a", ['value'] = 'yes'})
        table.insert(testform, { ['type'] = "checkbox", ['label'] = '<b>Option B.</b> '.. Config.WeaponsQuestions.questions[i].choices.b, ['name'] = "ans" .. i .. "b", ['value'] = 'yes'})
        if Config.WeaponsQuestions.questions[i].choices.c ~= nil and Config.WeaponsQuestions.questions[i].choices.d ~= nil then
            table.insert(testform, { ['type'] = "checkbox", ['label'] = '<b>Option C.</b> '.. Config.WeaponsQuestions.questions[i].choices.c, ['name'] = "ans" .. i .. "c", ['value'] = 'yes'})
            table.insert(testform, { ['type'] = "checkbox", ['label'] = '<b>Option D.</b> '.. Config.WeaponsQuestions.questions[i].choices.d, ['name'] = "ans" .. i .. "d", ['value'] = 'yes'})
        end
    end    
    table.insert(testform, { ['type'] = "yesno", ['success'] = "Submit Test", ['reject'] = "Cancel Test"  })
    TriggerEvent('pw_interact:generateForm', 'pw_license:server:confirmWeaponCert', 'server', testform, "Firearm Safety Test", true, false, '1000px')
end)

RegisterNetEvent('pw_license:client:sendWeaponCertResults')
AddEventHandler('pw_license:client:sendWeaponCertResults', function(data)
    local testtype = data.testtype.value
    local questionamount = tonumber(data.questionsamount.value)
    local questiondata = {}
    for i = 1, questionamount do
        local ans = false
        local questiona = "ans" .. i .. "a"
        local questionb = "ans" .. i .. "b"
        local questionc = "ans" .. i .. "c"
        local questiond = "ans" .. i .. "d"
        if data[questiona].value and data[questionb].value and (data[questionc] ~= nil and data[questionc].value) and (data[questiond] ~= nil and data[questiond].value) then
            ans = false
        elseif data[questiona].value and data[questionb].value then
            ans = false
        else
            if data[questiona].value and Config.WeaponsQuestions.questions[i].correct == 'a' then
                ans = true
            elseif data[questionb].value and Config.WeaponsQuestions.questions[i].correct == 'b' then
                ans = true
            elseif data[questionc].value and Config.WeaponsQuestions.questions[i].correct == 'c' then
                ans = true
            elseif data[questiond].value and Config.WeaponsQuestions.questions[i].correct == 'd' then
                ans = true
            end 
        end 
        table.insert(questiondata, ans) 
    end  
    PW.Print(questiondata)  
    local correctans = 0
    for i = 1, #questiondata do
        if questiondata[i] then
            correctans = correctans + 1
        end
    end
    print(correctans, '/', #questiondata)   
    if correctans > 7 then 
        TriggerServerEvent('pw_license:server:completedWeaponTheoryTestSuccess', correctans)
    else
        exports.pw_notify:SendAlert('error', 'You Have Failed the Test - With Only ' .. correctans .. ' Correct!', 7000)  
    end    
end)




function createBlip()
    Citizen.CreateThread(function()
        blips = AddBlipForCoord(Config.Points.roadTest.coords.x, Config.Points.roadTest.coords.y, Config.Points.roadTest.coords.z)
        SetBlipSprite(blips, Config.Blip.type)
        SetBlipDisplay(blips, 4)
        SetBlipScale  (blips, Config.Blip.scale)
        SetBlipColour (blips, Config.Blip.color)
        SetBlipAsShortRange(blips, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.Blip.name)
        EndTextCommandSetBlipName(blips)
    end)
end

function destroyBlip()
    RemoveBlip(blips)
end
