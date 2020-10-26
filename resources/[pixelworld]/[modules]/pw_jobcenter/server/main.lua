PW = nil

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

PW.RegisterServerCallback('pw_jobcenter:getJobsList', function(source, cb)
	MySQL.Async.fetchAll('SELECT * FROM avaliable_jobs WHERE whitelisted = @whitelisted', {
		['@whitelisted'] = false
	}, function(result)
		local data = {}
		for i=1, #result, 1 do
			table.insert(data, {
				name   = result[i].name,
                label   = result[i].label,
                grade   = result[i].default_grade,
                description = result[i].job_desc,
                expectations = result[i].job_expects,
                instructions = result[i].job_instructions,
                license = result[i].license_required,
                license_label = result[i].license_required_label,
			})
		end
		cb(data)
	end)
end)

RegisterServerEvent('pw_jobcenter:server:setjob')
AddEventHandler('pw_jobcenter:server:setjob', function(data)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
	local _cid = _char.getCID()
    if data.license.value == 'undefined' or (data.license.value ~= nil and exports['pw_licenses']:DoesPlayerHaveLicense(_cid, data.license.value)) then
        _char:Job().setJob(data.job.value, data.jobGrade.value, 0)
        TriggerClientEvent('pw_jobcenter:client:viewJobInformation', _src, data)
    else 
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "You do not have the required license for this job, check the licenses that the job requires before applying!", length = 8000})  	
    end
end)

RegisterServerEvent('pw_jobcenter:server:quitjob')
AddEventHandler('pw_jobcenter:server:quitjob', function()
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    _char:Job().removeJob()
end)
