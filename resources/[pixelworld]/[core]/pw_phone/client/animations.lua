local phoneProp, currentStatus, lastDist, lastAnim, lastIsFreeze = 0, 'out', nil, nil, false

local PhoneAnims = {
	['cellphone@'] = {
		['out'] = {
			['text'] = 'cellphone_text_in',
			['call'] = 'cellphone_call_listen_base',
			
		},
		['text'] = {
			['out'] = 'cellphone_text_out',
			['call'] = 'cellphone_text_to_call',
		},
		['call'] = {
			['out'] = 'cellphone_call_out',
			['text'] = 'cellphone_call_to_text',
		}
	},
	['anim@cellphone@in_car@ps'] = {
		['out'] = {
			['text'] = 'cellphone_text_in',
			['call'] = 'cellphone_call_in',
		},
		['text'] = {
			['out'] = 'cellphone_text_out',
			['call'] = 'cellphone_text_to_call',
		},
		['call'] = {
			['out'] = 'cellphone_horizontal_exit',
			['text'] = 'cellphone_call_to_text',
		}
	}
}

function newPhoneProp(type)
    local phoneModel = `prop_player_phone_01`
    if type == 'radio' then
        phoneModel = `prop_cs_hand_radio`
    end
	deletePhone()
	RequestModel(phoneModel)
	while not HasModelLoaded(phoneModel) do
		Citizen.Wait(1)
	end
	phoneProp = CreateObject(phoneModel, 1.0, 1.0, 1.0, 1, 1, 0)
	local bone = GetPedBoneIndex(GLOBAL_PED, 28422)
	AttachEntityToEntity(phoneProp, GLOBAL_PED, bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
end

function deletePhone()
	if phoneProp ~= 0 then
        Citizen.InvokeNative(0xAE3CBE5BF394C9C9 , Citizen.PointerValueIntInitialized(phoneProp))
		phoneProp = 0
	end
end

function PhonePlayAnim(status, type, freeze)
	if currentStatus == status then
		return
	end
	local freeze = freeze or false

	local dict = "cellphone@"
	if IsPedInAnyVehicle(GLOBAL_PED, false) then
		dict = "anim@cellphone@in_car@ps"
	end
	loadAnimDict(dict)

	local anim = PhoneAnims[dict][currentStatus][status]
	if currentStatus ~= 'out' then
		StopAnimTask(GLOBAL_PED, lastDict, lastAnim, 1.0)
	end
	local flag = 50
	if freeze == true then
		flag = 14
	end
	TaskPlayAnim(GLOBAL_PED, dict, anim, 3.0, -1, -1, flag, 0, false, false, false)

	if status ~= 'out' and currentStatus == 'out' then
        Citizen.Wait(380)
		newPhoneProp(type)
	end

	lastDict = dict
	lastAnim = anim
	lastIsFreeze = freeze
	currentStatus = status

	if status == 'out' then
		Citizen.Wait(180)
		deletePhone()
		StopAnimTask(GLOBAL_PED, lastDict, lastAnim, 1.0)
	end
end

function loadAnimDict(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(1)
	end
end

function PhonePlayOut()
	PhonePlayAnim('out')
end

function PhonePlayText(type)
	PhonePlayAnim('text', type)
end

function PhonePlayCall(freeze)
	PhonePlayAnim('call', 'phone', freeze)
end

function PhonePlayIn() 
	if currentStatus == 'out' then
		PhonePlayText('phone')
	end
end

function RadioPlayIn() 
	if currentStatus == 'out' then
		PhonePlayText('radio')
	end
end


