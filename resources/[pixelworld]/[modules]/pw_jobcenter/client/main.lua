PW = nil
characterLoaded, GLOBAL_PED, GLOBAL_COORDS, playerData = false, nil, nil, nil

local blip, showing, showingMarker = nil, false, false

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

RegisterNetEvent('pw:updateJob')
AddEventHandler('pw:updateJob', function(data)
    if playerData ~= nil then
        playerData.job = data
    end
end)

function MarkerDraw()
    Citizen.CreateThread(function()
        while showingMarker and characterLoaded do
            Citizen.Wait(1)
            DrawMarker(Config.Location.markerType, Config.Location.coords.x, Config.Location.coords.y, Config.Location.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Location.markerSize.x, Config.Location.markerSize.y, Config.Location.markerSize.z, Config.Location.markerColor.r, Config.Location.markerColor.g, Config.Location.markerColor.b, 100, false, true, 2, true, nil, nil, false)
        end
    end)
end

function DrawText()
    TriggerEvent('pw_drawtext:showNotification', { title = "Job Center", message = "<span style='font-size:25px'>Job Center</span></b>", icon = "fad fa-briefcase" })
    TriggerServerEvent('pw_keynote:server:triggerShowable', true, {{['type'] = "key", ['key'] = "e", ['action'] = "Get Job"}})
    
    Citizen.CreateThread(function()
        while showing and characterLoaded do
            Citizen.Wait(5)
            if IsControlJustPressed(0, 38) then
                OpenJobSelectMenu()
            end
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if characterLoaded and playerData then
            local dist = #(GLOBAL_COORDS - vector3(Config.Location.coords.x, Config.Location.coords.y, Config.Location.coords.z))
            if dist < Config.Location.markerDistance then
                if not showingMarker then
                    showingMarker = true
                    MarkerDraw()
                end
                if dist < Config.Location.drawDistance then
                    if not showing then
                        showing = true
                        DrawText()
                    end
                elseif showing then
                    showing = false
                    TriggerEvent('pw_drawtext:hideNotification')
                    TriggerServerEvent('pw_keynote:server:triggerShowable', false)
                end
            elseif showingMarker then
                showingMarker = false
                showing = false
                TriggerEvent('pw_drawtext:hideNotification')
                TriggerServerEvent('pw_keynote:server:triggerShowable', false)
            end  
        end
    end
end)

function OpenJobSelectMenu()
    local menu = {}
    PW.TriggerServerCallback('pw_jobcenter:getJobsList', function(data)
        for k,v in pairs(data) do
            table.insert(menu, { ['label'] = v.label .. (playerData.job.name == v.name and " <i>(Current)</i>" or ""), ['action'] = 'pw_jobcenter:client:openJobForm', ['value'] = v, ['triggertype'] = 'client', ['color'] = (playerData.job.name == v.name and 'primary disabled' or 'primary') })
        end
        if playerData.job.name ~= 'unemployed' then
            table.insert(menu, { ['label'] = 'Quit Current Job', ['action'] = 'pw_jobcenter:client:quitJob', ['value'] = data, ['triggertype'] = 'client', ['color'] = 'danger' })
        end
        TriggerEvent('pw_interact:generateMenu', menu, "<strong>Job Center</strong><br>Please Select a Job You Are Interested In")
    end)
end

RegisterNetEvent('pw_jobcenter:client:openJobForm')
AddEventHandler('pw_jobcenter:client:openJobForm', function(data)
    PW.Print(data)
    local jobform = {
        { ['type'] = "writting", ['align'] = 'center', ['value'] = 'This is an application form for <strong>' .. playerData.name .. ' </strong>to recieve the role of ' .. data.jobCenter.default_grade .. ' at <strong> ' .. data.label .. '</strong>'},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = '<strong>Job Description</strong><br>' .. data.jobCenter.description},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = '<strong>Job Expectations</strong><br>' .. data.jobCenter.expectations .. (data.jobCenter.drivingLicense and '<br><br>To apply for this job, you are required to have a <strong>valid drivers license.</strong><br>' or '')},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = 'Please place your signature below if you agree to all of the above terms and would like the job here at<strong> ' .. data.label .. ' </strong>and we do hope to see you here soon.'},
        { ['type'] = "checkbox", ['label'] = '<br><i>Sign Here: <u>&nbsp;&nbsp;'.. playerData.name ..'&nbsp;&nbsp;</u></i>', ['name'] = "contractReview", ['value'] = 'yes'},
        { ['type'] = "hidden", ['name'] = "job", ['value'] = data.name},
        { ['type'] = "hidden", ['name'] = "jobLabel", ['value'] = data.label},
        { ['type'] = "hidden", ['name'] = "jobGrade", ['value'] = data.jobCenter.default_grade},
        { ['type'] = "hidden", ['name'] = "drivingLicense", ['value'] = data.jobCenter.drivingLicense },
        { ['type'] = "hidden", ['name'] = "instructions", ['value'] = data.jobCenter.instructions },
    }
    TriggerEvent('pw_interact:generateForm', 'pw_jobcenter:client:getJob', 'client', jobform, "Job Application Form For: <strong>" .. data.label .. '</strong>', { }, false, '500px')
end)

RegisterNetEvent('pw_jobcenter:client:getJob')
AddEventHandler('pw_jobcenter:client:getJob', function(data)
    if data.contractReview.value then
        TriggerServerEvent('pw_jobcenter:server:setjob', data)
    else
        exports.pw_notify:SendAlert('error', 'You didn\'t Sign the Form so You Didn\'t Recieve the Job!', 10000)
    end
end)

RegisterNetEvent('pw_jobcenter:client:viewJobInformation')
AddEventHandler('pw_jobcenter:client:viewJobInformation', function(data)
    PW.Print(data)
    local jobintruct = {
        { ['type'] = "writting", ['align'] = 'center', ['value'] = 'Hello <strong>' .. playerData.name .. '</strong>! Welcome to your new job: <strong>' .. data.jobLabel.value .. '</strong>!'},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = data.instructions.value },
        { ['type'] = "writting", ['align'] = 'center', ['value'] = 'We hope you enjoy your new job and understand the basic instructions provided to you.'},
    }
    TriggerEvent('pw_interact:generateForm', '', '', jobintruct, "Job Information for <strong>" .. data.jobLabel.value .. '</strong>', { }, false, '500px')
end)

RegisterNetEvent('pw_jobcenter:client:quitJob')
AddEventHandler('pw_jobcenter:client:quitJob', function(data)
    local allowedToQuit = false
    for k,v in pairs(data) do
        if playerData.job.name == v.name then
            allowedToQuit = true
            break
        end
    end
    if allowedToQuit then
        local quitjobmenu = {
            { ['type'] = "writting", ['align'] = 'center', ['value'] = '<strong>' .. playerData.name .. '</strong>, are you sure you want to quit your job: <strong>' .. playerData.job.label .. ' - ' .. playerData.job.grade_label .. '</strong>!'},
            { ['type'] = "writting", ['align'] = 'center', ['value'] = 'If you quit your job you will lose all access that it have brought to you. You may not be able to get the job back if it is unavailable in the job center.'},
            { ['type'] = "yesno", ['success'] = "Quit Job", ['reject'] = "Cancel Action"  }
        }
        TriggerEvent('pw_interact:generateForm', 'pw_jobcenter:server:quitjob', 'server', quitjobmenu, "Quit Your Job?", { }, false, '500px')
    else
        exports.pw_notify:SendAlert('error', 'Cannot Quit This Job', 2500)
    end
end)

function createBlip()
    Citizen.CreateThread(function()
        if blip == nil then
            blip = AddBlipForCoord(Config.Location.coords.x, Config.Location.coords.y, Config.Location.coords.z)
            SetBlipSprite(blip, Config.Location.blip.type)
            SetBlipDisplay(blip, 4)
            SetBlipScale  (blip, Config.Location.blip.scale)
            SetBlipColour (blip, Config.Location.blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Config.Location.blip.name)
            EndTextCommandSetBlipName(blip)
        end
    end)
end

function destroyBlip()
    if blip ~= nil then
        RemoveBlip(blip)
        blip = nil
    end
end