PW = nil
characterLoaded, GLOBAL_PED, GLOBAL_COORDS, playerData = false, nil, nil, nil

local blips, showing, showingMarker = {}, false, false

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
    TriggerEvent('pw_drawtext:showNotification', { title = "Job Center", message = "<span style='font-size:30px' class='text-primary'>Job Center</span></b>", icon = "fad fa-briefcase" })
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
        for i = 1, #data do
            table.insert(menu, { ['label'] = data[i].label .. (playerData.job.name == data[i].name and " <i>(Current)</i>" or ""), ['action'] = 'pw_jobcenter:client:openJobForm', ['value'] = { ['job'] = data[i].name, ['label'] = data[i].label, ['grade'] = data[i].grade, ['desc'] = data[i].description, ['expect'] = data[i].expectations, ['instructions'] =  data[i].instructions, ['license'] = data[i].license, ['license_label'] = data[i].license_label }, ['triggertype'] = 'client', ['color'] = (playerData.job.name == data[i].name and 'primary disabled' or 'primary') })
        end
        if playerData.job.name ~= 'unemployed' then
            table.insert(menu, { ['label'] = 'Quit Current Job', ['action'] = 'pw_jobcenter:client:quitJob', ['triggertype'] = 'client', ['color'] = 'danger' })
        end
        TriggerEvent('pw_interact:generateMenu', menu, "<strong>Job Center</strong><br>Please Select a Job You Are Interested In")
    end)
end

RegisterNetEvent('pw_jobcenter:client:openJobForm')
AddEventHandler('pw_jobcenter:client:openJobForm', function(data)
    local jobform = {
        { ['type'] = "writting", ['align'] = 'center', ['value'] = 'This is an application form for <strong>' .. playerData.name .. ' </strong>to recieve the role of ' .. data.grade .. ' at <strong> ' .. data.label .. '</strong>'},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = '<strong>Job Description</strong><br>' .. data.desc},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = '<strong>Job Expectations</strong><br>' .. data.expect .. (data.license ~= nil and '<br><strong>Required Licenses</strong><br>We May not accept you for the job if you don\'t have the required licenses.<br>' .. data.license_label or '')},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = 'Please place your signature below if you agree to all of the above terms and would like the job here at<strong> ' .. data.label .. ' </strong>and we do hope to see you here soon.'},
        { ['type'] = "checkbox", ['label'] = '<br><i>Sign Here: <u>&nbsp;&nbsp;'.. playerData.name ..'&nbsp;&nbsp;</u></i>', ['name'] = "contractReview", ['value'] = 'yes'},
        { ['type'] = "hidden", ['name'] = "job", ['value'] = data.job},
        { ['type'] = "hidden", ['name'] = "jobLabel", ['value'] = data.label},
        { ['type'] = "hidden", ['name'] = "jobGrade", ['value'] = data.grade },
        { ['type'] = "hidden", ['name'] = "jobInstructs", ['value'] = data.instructions },
        { ['type'] = "hidden", ['name'] = "license", ['value'] = data.license }
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
    local jobintruct = {
        { ['type'] = "writting", ['align'] = 'center', ['value'] = 'Hello <strong>' .. playerData.name .. '</strong>! Welcome to your new job: <strong>' .. data.jobLabel.value .. '</strong>!'},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = data.jobInstructs.value},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = 'We hope you enjoy your new job and understand the basic instructions provided to you.'},
    }
    TriggerEvent('pw_interact:generateForm', '', '', jobintruct, "Job Information for <strong>" .. data.jobLabel.value .. '</strong>', { }, false, '500px')
end)

RegisterNetEvent('pw_jobcenter:client:quitJob')
AddEventHandler('pw_jobcenter:client:quitJob', function()
    local quitjobmenu = {
        { ['type'] = "writting", ['align'] = 'center', ['value'] = '<strong>' .. playerData.name .. '</strong>, are you sure you want to quit your job: <strong>' .. playerData.job.label .. ' - ' .. playerData.job.grade_label .. '</strong>!'},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = 'If you quit your job you will lose all access that it have brought to you. You may not be able to get the job back if it is unavailable in the job center.'},
        { ['type'] = "yesno", ['success'] = "Quit Job", ['reject'] = "Cancel Action"  }
    }
    TriggerEvent('pw_interact:generateForm', 'pw_jobcenter:server:quitjob', 'server', quitjobmenu, "Quit Your Job?", { }, false, '500px')
end)



function createBlip()
    Citizen.CreateThread(function()
        blips = AddBlipForCoord(Config.Location.coords.x, Config.Location.coords.y, Config.Location.coords.z)
        SetBlipSprite(blips, Config.Location.blip.type)
        SetBlipDisplay(blips, 4)
        SetBlipScale  (blips, Config.Location.blip.scale)
        SetBlipColour (blips, Config.Location.blip.color)
        SetBlipAsShortRange(blips, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.Location.blip.name)
        EndTextCommandSetBlipName(blips)
    end)
end

function destroyBlip()
    RemoveBlip(blips)
end