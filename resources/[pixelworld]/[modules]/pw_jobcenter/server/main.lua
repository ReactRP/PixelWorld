PW = nil

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

local jobData = {}

AddEventHandler('pw:databaseCachesLoaded', function(caches)
	MySQL.Async.fetchAll('SELECT * FROM avaliable_jobs WHERE whitelisted = @whitelisted', {
		['@whitelisted'] = false
	}, function(result)
        for k,v in pairs(result) do
            v.jobCenter = json.decode(v.jobCenter)
        end
		jobData = result
    end)
end)

PW.RegisterServerCallback('pw_jobcenter:getJobsList', function(source, cb)
	cb(jobData)
end)

RegisterServerEvent('pw_jobcenter:server:setjob')
AddEventHandler('pw_jobcenter:server:setjob', function(data)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
	local _cid = _char.getCID()
    if not data.drivingLicense.value or (data.drivingLicense.value and exports['pw_licenses']:doesCharHaveDrivingLicense(_cid)) then
        _char:Job().setJob(data.job.value, data.jobGrade.value, 0)
        TriggerClientEvent('pw_jobcenter:client:viewJobInformation', _src, data)
    else 
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "You don\'t have a valid drivers license which is required for this job", length = 8000})  	
    end
end)

RegisterServerEvent('pw_jobcenter:server:quitjob')
AddEventHandler('pw_jobcenter:server:quitjob', function()
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    _char:Job().removeJob()
end)



--[[[

	('licensetheory', '{"VEHICLE":{"title":"Vehicle License Theory Test","pass":"Now it is time for you to do the practical driving test so you can get your full vehicle license. You will be put into a car and will have to follow the GPS and instructions given. Make sure not to go over the speed limit or cause any damage to the vehicle.","information":"This test is required before you will be able to get a vehicle license. You will have to complete these questions and then you will have to do a practical test to be able to get your license.","questions":[{"correct":"b","choices":{"d":"65 MPH","c":"80 MPH","b":"70 MPH","a":"50 MPH"},"question":"What is the speedlimit on a highway?"},{"correct":"b","choices":{"d":"Let Go of the Steering Wheel and let the car do the work.","c":"Apply the brakes as hard as possible.","b":"Hold the steering wheel firmly, and ease up on the gas.","a":"Speed up to gain traction and then pull to the right."},"question":"If your tire blows, what should you do?"},{"correct":"c","choices":{"d":"Take the right-of-way since you have the light.","c":"Wait in the center of the intersection for traffic to clear.","b":"Wait at the crosswalk for traffic to clear.","a":"Use the next intersection."},"question":"You want to turn left at an intersection. The light is green but oncoming traffic is heavy. What should you do?"},{"correct":"a","choices":{"d":"All of the above","c":"Wear a lap belt around your stomach, not your hips.","b":"Use your safety belt only for long trips or on high-speed highways.","a":"Fasten your safety belt snugly across your hips."},"question":"Which of the following statements is true?"},{"correct":"c","choices":{"d":"Sound your horn to get the drivers attention.","c":"Give the proper turn signal to show you are changing lanes.","b":"Turn on your four-way flashers to warn the driver.","a":"Flash your headlights to alert the driver."},"question":"Before passing another vehicle you should do what?"},{"correct":"b","choices":{"d":"You must always drive at the same speed as the rest of the traffic.","c":"Increase your speed even if the way is not clear.","b":"You must yield the right-of-way to vehicles already on the freeway.","a":"Vehicles on the freeway must always yield the right-of-way to vehicles that are entering the freeway."},"question":"When entering a freeway, what should you do?"},{"correct":"c","choices":{"d":"Stop exactly where you are.","c":"Pull to the curb and stop.","b":"Keep driving in your lane.","a":"Slow down and keep moving in your lane."},"question":"When you see an emergency vehicle with flashing lights behind you, you must do what?"},{"correct":"a","choices":{"d":"Flash your headlights.","c":"Use your emergency lights.","b":"Wave your arms.","a":"Sound your horn."},"question":"If another car is in danger of hitting you, you should do what?"},{"correct":"c","choices":{"d":"It is fine to do so at all times.","c":"It is never legal to block an intersection.","b":"There is extremely heavy traffic.","a":"You entered on a green light."},"question":"When may you legally block an intersection?"},{"correct":"b","choices":{"d":"Stop only for traffic on an intersecting road.","c":"Proceed carefully through the intersection, not always stopping.","b":"Come to a full stop, then go when it is safe to do so.","a":"Slow down and prepare to stop only if cars are approaching you."},"question":"What does a stop sign mean?"}]}}');

        `licenses` longtext DEFAULT NULL,
        `licensePoints` int(11) DEFAULT 0,


        ]]