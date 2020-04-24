PW = nil
characterLoaded, playerData = false, nil

Citizen.CreateThread(function()
    while PW == nil do
        TriggerEvent('pw:loadFramework', function(obj) PW = obj end)
        Citizen.Wait(1)
    end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(unload, ready, data)
    if not unload then
        if ready then
            characterLoaded = true
            createBlippers()
        else
            playerData = data
        end
    else
        playerData = nil
        characterLoaded = false
        deleteBlippers()
        showingtext = false
    end
end)

local enabled, player, cam, customCam, oldPed, InCharCreator = false, false, false, false, false, false
local cameras
local showingtxt, drawingMarker = false, false

local drawable_names = {"face", "masks", "hair", "torsos", "legs", "bags", "shoes", "neck", "undershirts", "vest", "decals", "jackets"}
local prop_names = {"hats", "glasses", "earrings", "mouth", "lhand", "rhand", "watches", "braclets"}
local head_overlays = {"Blemishes","FacialHair","Eyebrows","Ageing","Makeup","Blush","Complexion","SunDamage","Lipstick","MolesFreckles","ChestHair","BodyBlemishes","AddBodyBlemishes"}
local face_features = {"Nose_Width","Nose_Peak_Hight","Nose_Peak_Lenght","Nose_Bone_High","Nose_Peak_Lowering","Nose_Bone_Twist","EyeBrown_High","EyeBrown_Forward","Cheeks_Bone_High","Cheeks_Bone_Width","Cheeks_Width","Eyes_Openning","Lips_Thickness","Jaw_Bone_Width","Jaw_Bone_Back_Lenght","Chimp_Bone_Lowering","Chimp_Bone_Lenght","Chimp_Bone_Width","Chimp_Hole","Neck_Thikness"}
local tattoo_categories = GetTatCategs()
local tattooHashList = CreateTattooHashList()

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if characterLoaded then
            local playerPed = PlayerPedId()
            local pedCoords = GetEntityCoords(playerPed)  
            for k,v in pairs(Config.ShopLocations) do     
                for t,q in pairs(v) do          
                    local dist = #(pedCoords - vector3(q.x, q.y, q.z)) 
                    if dist < q.radius * 2.0 then
                        if not drawingMarker then
                            drawingMarker = k..t
                            DrawShit(q.x, q.y, q.z, drawingMarker)
                        end
                        if dist < q.radius then
                            if not showingtxt then
                                showingtxt = k..t
                                DrawText(k, showingtxt)
                            end
                        elseif showingtxt == k..t then
                            showingtxt = false
                            TriggerEvent('pw_drawtext:hideNotification')
                            --TriggerEvent('pw_items:showUsableKeys', false)
                        end  
                    elseif drawingMarker == k..t then
                        showingtxt = false
                        drawingMarker = false
                        TriggerEvent('pw_drawtext:hideNotification')
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
            DrawMarker(2, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 84, 122, 255, 100, false, true, 2, false, nil, nil, false)
        end
    end)
end


function DrawText(type, var)
    print(type)
    local title, message, icon, key
    if type == 'clothing' then
        title = "Clothing Store"
        message = "Open Clothing Store and Change Clothes. Cost: <span class='text-danger'>$".. Config.Costs['clothing'] .."</span>"
        icon = "fad fa-tshirt" 
        key = "Change Clothes"
    elseif type == 'barbers' then
        title = "Barber Shop"
        message = "Open Barber Shop and Get a Haircut. Cost: <span class='text-danger'>$".. Config.Costs['barbers'] .."</span>"
        icon = "fad fa-cut" 
        key = "Get Haircut"
    elseif type == 'tattoos' then
        title = "Tattoo Shop"
        message = "Open Tattoo Shop and Get a Tattoo. Cost: <span class='text-danger'>$".. Config.Costs['tattoos'] .."</span>"
        icon = "fad fa-pen-nib" 
        key = "Get Tattoo"
    elseif type == 'cosmetics' then
        title = "Plastic Surgery"
        message = "Open Plastic Surgery and Alter Face. Cost: <span class='text-danger'>$".. Config.Costs['cosmetics'] .."</span>"
        icon = "fad fa-scalpel-path" 
        key = "Get Surgery"
    elseif type == 'wardrobes' then
        title = "Wardrobe"
        message = "Open Wardbrobe and Manage Outfits"
        icon = "fad fa-tshirt" 
        key = "Manage Outfits"
    elseif type == 'clothing_free' then
        title = "Clothing Store"
        message = "Open Clothing Options and Change Your Clothes"
        icon = "fad fa-tshirt" 
        key = "Change Clothes"
    end      
    if title ~= nil and message ~= nil and icon ~= nil and key ~= nil then
        TriggerEvent('pw_drawtext:showNotification', { title = title, message = message, icon = icon })
        --TriggerEvent('pw_items:showUsableKeys', true, {{['key'] = "e", ['label'] = key}})
    end

    Citizen.CreateThread(function()
        while showingtxt == var do
            Citizen.Wait(5)
            if IsControlJustPressed(0, 38) and type ~= nil then
                PW.TriggerServerCallback('pw_character:server:doesCharHaveEnoughMoney', function(cash)
                    if Config.Costs[type] ~= nil and (cash >= Config.Costs[type]) then
                        if type == 'clothing' then
                            OpenMenu('clothesmenu', false)
                        elseif type == 'barbers' then
                            OpenMenu('barbermenu', false)
                        elseif type == 'tattoos' then
                            OpenMenu('tattoomenu', false)
                        elseif type == 'cosmetics' then
                            OpenMenu('cosmeticsmenu', false)
                        end   
                    elseif type == 'clothing_free' then
                        OpenMenu('clothesmenu', true)
                    elseif type == 'wardrobes' then
                        TriggerEvent('pw_character:client:openOutfitManagement')
                    else
                        exports.pw_notify:SendAlert('error', 'Not Enough Cash for This', 2500)
                    end  
                end)
            end
        end
    end)
end


function RefreshUI()
    hairColors = {}
    for i = 0, GetNumHairColors()-1 do
        local outR, outG, outB= GetPedHairRgbColor(i)
        hairColors[i] = {outR, outG, outB}
    end

    makeupColors = {}
    for i = 0, GetNumMakeupColors()-1 do
        local outR, outG, outB= GetPedMakeupRgbColor(i)
        makeupColors[i] = {outR, outG, outB}
    end

    SendNUIMessage({
        type="colors",
        hairColors=hairColors,
        makeupColors=makeupColors,
        hairColor=GetPedHair()
    })
    SendNUIMessage({
        type = "menutotals",
        drawTotal = GetDrawablesTotal(),
        propDrawTotal = GetPropDrawablesTotal(),
        textureTotal = GetTextureTotals(),
        headoverlayTotal = GetHeadOverlayTotals(),
        skinTotal = GetSkinTotal()
    })
    SendNUIMessage({
        type = "barbermenu",
        headBlend = GetPedHeadBlendData(),
        headOverlay = GetHeadOverlayData(),
        headStructure = GetHeadStructureData()
    })
    SendNUIMessage({
        type = "clothesmenudata",
        drawables = GetDrawables(),
        props = GetProps(),
        drawtextures = GetDrawTextures(),
        proptextures = GetPropTextures(),
        skin = GetSkin(),
        oldPed = oldPed,
    })
    SendNUIMessage({
        type = "tattoomenu",
        totals = tattoo_categories,
        values = GetTats()
    })
end

function GetSkin()
    for i = 1, #frm_skins do
        if (GetHashKey(frm_skins[i]) == GetEntityModel(PlayerPedId())) then
            return {name="skin_male", value=i}
        end
    end
    for i = 1, #fr_skins do
        if (GetHashKey(fr_skins[i]) == GetEntityModel(PlayerPedId())) then
            return {name="skin_female", value=i}
        end
    end
    return false
end

function GetDrawables()
    drawables = {}
    local model = GetEntityModel(PlayerPedId())
    local mpPed = false
    if (model == `mp_f_freemode_01` or model == `mp_m_freemode_01`) then
        mpPed = true
    end
    for i = 0, #drawable_names-1 do
        if mpPed and drawable_names[i+1] == "undershirts" and GetPedDrawableVariation(player, i) == -1 then
            SetPedComponentVariation(player, i, 15, 0, 2)
        end
        drawables[tonumber(i)] = {drawable_names[i+1], GetPedDrawableVariation(player, i)}
    end
    return drawables
end

function GetProps()
    props = {}
    for i = 0, #prop_names-1 do
        props[i] = {prop_names[i+1], GetPedPropIndex(player, i)}
    end
    return props
end

function GetDrawTextures()
    textures = {}
    for i = 0, #drawable_names-1 do
        table.insert(textures, {drawable_names[i+1], GetPedTextureVariation(player, i)})
    end
    return textures
end

function GetPropTextures()
    textures = {}
    for i = 0, #prop_names-1 do
        table.insert(textures, {prop_names[i+1], GetPedPropTextureIndex(player, i)})
    end
    return textures
end

function GetDrawablesTotal()
    drawables = {}
    for i = 0, #drawable_names - 1 do
        drawables[i] = {drawable_names[i+1], GetNumberOfPedDrawableVariations(player, i)}
    end
    return drawables
end

function GetPropDrawablesTotal()
    props = {}
    for i = 0, #prop_names - 1 do
        props[i] = {prop_names[i+1], GetNumberOfPedPropDrawableVariations(player, i)}
    end
    return props
end

function GetTextureTotals()
    local values = {}
    local draw = GetDrawables()
    local props = GetProps()

    for idx = 0, #draw-1 do
        local name = draw[idx][1]
        local value = draw[idx][2]
        values[name] = GetNumberOfPedTextureVariations(player, idx, value)
    end

    for idx = 0, #props-1 do
        local name = props[idx][1]
        local value = props[idx][2]
        values[name] = GetNumberOfPedPropTextureVariations(player, idx, value)
    end
    return values
end

function SetClothing(drawables, props, drawTextures, propTextures)
    for i = 1, #drawable_names do
        if drawables[0] == nil then
            if drawable_names[i] == "undershirts" and drawables[tostring(i-1)][2] == -1 then
                SetPedComponentVariation(player, i-1, 15, 0, 2)
            else
                SetPedComponentVariation(player, i-1, drawables[tostring(i-1)][2], drawTextures[i][2], 2)
            end
        else
            if drawable_names[i] == "undershirts" and drawables[i-1][2] == -1 then
                SetPedComponentVariation(player, i-1, 15, 0, 2)
            else
                SetPedComponentVariation(player, i-1, drawables[i-1][2], drawTextures[i][2], 2)
            end
        end
    end

    for i = 1, #prop_names do
        local propZ = (drawables[0] == nil and props[tostring(i-1)][2] or props[i-1][2])
        ClearPedProp(player, i-1)
        SetPedPropIndex(
            player,
            i-1,
            propZ,
            propTextures[i][2], true)
    end
end

function GetSkinTotal()
	return { #frm_skins, #fr_skins }
end

local toggleClothing = {}
function ToggleProps(data)
    local name = data["name"]

    selectedValue = DoesTableHaveValue(drawable_names, name)
    if (selectedValue > -1) then
        if (toggleClothing[name] ~= nil) then
            SetPedComponentVariation(player, tonumber(selectedValue), tonumber(toggleClothing[name][1]), tonumber(toggleClothing[name][2]), 2)
            toggleClothing[name] = nil
        else
            toggleClothing[name] = {
                GetPedDrawableVariation(player, tonumber(selectedValue)),
                GetPedTextureVariation(player, tonumber(selectedValue))
            }

            local value = -1
            if name == "undershirts" or name == "torsos" then
                value = 15
                if name == "undershirts" and GetEntityModel(PlayerPedId()) == GetHashKey('mp_f_freemode_01') then
                    value = -1
                end
            end
            if name == "legs" then
                value = 14
            end

            SetPedComponentVariation(player, tonumber(selectedValue), value, 0, 2)
        end
    else
        selectedValue = DoesTableHaveValue(prop_names, name)
        if (selectedValue > -1) then
            if (toggleClothing[name] ~= nil) then
                SetPedPropIndex(
                    player,
                    tonumber(selectedValue),
                    tonumber(toggleClothing[name][1]),
                    tonumber(toggleClothing[name][2]), true)
                toggleClothing[name] = nil
            else
                toggleClothing[name] = {
                    GetPedPropIndex(player, tonumber(selectedValue)),
                    GetPedPropTextureIndex(player, tonumber(selectedValue))
                }
                ClearPedProp(player, tonumber(selectedValue))
            end
        end
    end
end

function SaveToggleProps()
    for k in pairs(toggleClothing) do
        local name  = k
        selectedValue = DoesTableHaveValue(drawable_names, name)
        if (selectedValue > -1) then
            SetPedComponentVariation(
                player,
                tonumber(selectedValue),
                tonumber(toggleClothing[name][1]),
                tonumber(toggleClothing[name][2]), 2)
            toggleClothing[name] = nil
        else
            selectedValue = DoesTableHaveValue(prop_names, name)
            if (selectedValue > -1) then
                SetPedPropIndex(
                    player,
                    tonumber(selectedValue),
                    tonumber(toggleClothing[name][1]),
                    tonumber(toggleClothing[name][2]), true)
                toggleClothing[name] = nil
            end
        end
    end
end

function LoadPed(data)
    SetSkin(data.model, true)
    SetClothing(data.drawables, data.props, data.drawtextures, data.proptextures)
    Citizen.Wait(500)
    SetPedHairColor(player, tonumber(data.hairColor[1]), tonumber(data.hairColor[2]))
    SetPedHeadBlend(data.headBlend)
    SetHeadStructure(data.headStructure)
    SetHeadOverlayData(data.headOverlay)
    return
end


function GetCurrentPed()
    player = GetPlayerPed(-1)
    return {
        model = GetEntityModel(PlayerPedId()),
        hairColor = GetPedHair(),
        headBlend = GetPedHeadBlendData(),
        headOverlay = GetHeadOverlayData(),
        headStructure = GetHeadStructure(),
        drawables = GetDrawables(),
        props = GetProps(),
        drawtextures = GetDrawTextures(),
        proptextures = GetPropTextures(),
    }
end


function PlayerModel(data)
    local skins = nil
    if (data['name'] == 'skin_male') then
        skins = frm_skins
    else
        skins = fr_skins
    end
    local skin = skins[tonumber(data['value'])]
    RotatePlayer(180.0)
    SetSkin(GetHashKey(skin), true)
    Citizen.Wait(1)
    RotatePlayer(180.0)
end


function SetSkin(model, setDefault)
    SetEntityInvincible(PlayerPedId(),true)
    if IsModelInCdimage(model) and IsModelValid(model) then
        RequestModel(model)
        while (not HasModelLoaded(model)) do
            Citizen.Wait(0)
        end
        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
        player = GetPlayerPed(-1)
        FreezePedCameraRotation(player, true)
        if setDefault and model ~= nil then
            if (model ~= `mp_f_freemode_01` and model ~= `mp_m_freemode_01`) then
                SetPedRandomComponentVariation(GetPlayerPed(-1), true)
            else
                SetPedHeadBlendData(player, 0, 0, 0, 15, 0, 0, 0, 1.0, 0, false)
                SetPedComponentVariation(player, 11, 0, 11, 0)
                SetPedComponentVariation(player, 8, 0, 1, 0)
                SetPedComponentVariation(player, 6, 1, 2, 0)
                SetPedHeadOverlayColor(player, 1, 1, 0, 0)
                SetPedHeadOverlayColor(player, 2, 1, 0, 0)
                SetPedHeadOverlayColor(player, 4, 2, 0, 0)
                SetPedHeadOverlayColor(player, 5, 2, 0, 0)
                SetPedHeadOverlayColor(player, 8, 2, 0, 0)
                SetPedHeadOverlayColor(player, 10, 1, 0, 0)
                SetPedHeadOverlay(player, 1, 0, 0.0)
                SetPedHairColor(player, 1, 1)
            end
        end
    end
    SetEntityInvincible(PlayerPedId(),false)
end


RegisterNUICallback('updateclothes', function(data, cb)
    toggleClothing[data["name"]] = nil
    selectedValue = DoesTableHaveValue(drawable_names, data["name"])
    if (selectedValue > -1) then
        SetPedComponentVariation(player, tonumber(selectedValue), tonumber(data["value"]), tonumber(data["texture"]), 2)
        cb({ GetNumberOfPedTextureVariations(player, tonumber(selectedValue), tonumber(data["value"])) })
    else
        selectedValue = DoesTableHaveValue(prop_names, data["name"])
        if (tonumber(data["value"]) == -1) then
            ClearPedProp(player, tonumber(selectedValue))
        else
            SetPedPropIndex(player, tonumber(selectedValue), tonumber(data["value"]), tonumber(data["texture"]), true)
        end
        cb({ GetNumberOfPedPropTextureVariations(player, tonumber(selectedValue), tonumber(data["value"])) })
    end
end)


RegisterNUICallback('setped', function(data, cb)
    PlayerModel(data)
    RefreshUI()
end)


RegisterNUICallback('resetped', function(data, cb)
    LoadPed(oldPed)
end)


function GetPedHeadBlendData()
    local blob = string.rep("\0\0\0\0\0\0\0\0", 6 + 3 + 1) -- Generate sufficient struct memory.
    if not Citizen.InvokeNative(0x2746BD9D88C5C5D0, player, blob, true) then -- Attempt to write into memory blob.
        return nil
    end

    return {
        shapeFirst = string.unpack("<i4", blob, 1),
        shapeSecond = string.unpack("<i4", blob, 9),
        shapeThird = string.unpack("<i4", blob, 17),
        skinFirst = string.unpack("<i4", blob, 25),
        skinSecond = string.unpack("<i4", blob, 33),
        skinThird = string.unpack("<i4", blob, 41),
        shapeMix = string.unpack("<f", blob, 49),
        skinMix = string.unpack("<f", blob, 57),
        thirdMix = string.unpack("<f", blob, 65),
        hasParent = string.unpack("b", blob, 73) ~= 0,
    }
end

function SetPedHeadBlend(data)
    if data ~= nil then
        SetPedHeadBlendData(player, tonumber(data['shapeFirst']), tonumber(data['shapeSecond']), tonumber(data['shapeThird']), tonumber(data['skinFirst']), tonumber(data['skinSecond']), tonumber(data['skinThird']), tonumber(data['shapeMix']), tonumber(data['skinMix']), tonumber(data['thirdMix']), false)
    end        
end

function GetHeadOverlayData()
    local headData = {}
    for i = 1, #head_overlays do
        local retval, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(player, i-1)
        if retval then
            headData[i] = {}
            headData[i].name = head_overlays[i]
            headData[i].overlayValue = overlayValue
            headData[i].colourType = colourType
            headData[i].firstColour = firstColour
            headData[i].secondColour = secondColour
            headData[i].overlayOpacity = overlayOpacity
        end
    end
    return headData
end

function SetHeadOverlayData(data)
    if json.encode(data) ~= "[]" then
        for i = 1, #head_overlays do
            SetPedHeadOverlay(player,  i-1, tonumber(data[i].overlayValue),  tonumber(data[i].overlayOpacity))
            -- SetPedHeadOverlayColor(player, i-1, data[i].colourType, data[i].firstColour, data[i].secondColour)
        end

        SetPedHeadOverlayColor(player, 0, 0, tonumber(data[1].firstColour), tonumber(data[1].secondColour))
        SetPedHeadOverlayColor(player, 1, 1, tonumber(data[2].firstColour), tonumber(data[2].secondColour))
        SetPedHeadOverlayColor(player, 2, 1, tonumber(data[3].firstColour), tonumber(data[3].secondColour))
        SetPedHeadOverlayColor(player, 3, 0, tonumber(data[4].firstColour), tonumber(data[4].secondColour))
        SetPedHeadOverlayColor(player, 4, 2, tonumber(data[5].firstColour), tonumber(data[5].secondColour))
        SetPedHeadOverlayColor(player, 5, 2, tonumber(data[6].firstColour), tonumber(data[6].secondColour))
        SetPedHeadOverlayColor(player, 6, 0, tonumber(data[7].firstColour), tonumber(data[7].secondColour))
        SetPedHeadOverlayColor(player, 7, 0, tonumber(data[8].firstColour), tonumber(data[8].secondColour))
        SetPedHeadOverlayColor(player, 8, 2, tonumber(data[9].firstColour), tonumber(data[9].secondColour))
        SetPedHeadOverlayColor(player, 9, 0, tonumber(data[10].firstColour), tonumber(data[10].secondColour))
        SetPedHeadOverlayColor(player, 10, 1, tonumber(data[11].firstColour), tonumber(data[11].secondColour))
        SetPedHeadOverlayColor(player, 11, 0, tonumber(data[12].firstColour), tonumber(data[12].secondColour))
    end
end

function GetHeadOverlayTotals()
    local totals = {}
    for i = 1, #head_overlays do
        totals[head_overlays[i]] = GetNumHeadOverlayValues(i-1)
    end
    return totals
end

function GetPedHair()
    local hairColor = {}
    hairColor[1] = GetPedHairColor(player)
    hairColor[2] = GetPedHairHighlightColor(player)
    return hairColor
end

function GetHeadStructureData()
    local structure = {}
    for i = 1, #face_features do
        structure[face_features[i]] = GetPedFaceFeature(player, i-1)
    end
    return structure
end

function GetHeadStructure(data)
    local structure = {}
    for i = 1, #face_features do
        structure[i] = GetPedFaceFeature(player, i-1)
    end
    return structure
end

function SetHeadStructure(data)
    for i = 1, #face_features do
        SetPedFaceFeature(player, i-1, data[i])
    end
end

RegisterNUICallback('saveheadblend', function(data, cb)
    SetPedHeadBlendData(player, tonumber(data.shapeFirst), tonumber(data.shapeSecond), tonumber(data.shapeThird), tonumber(data.skinFirst), tonumber(data.skinSecond), tonumber(data.skinThird), tonumber(data.shapeMix) / 100, tonumber(data.skinMix) / 100, tonumber(data.thirdMix) / 100, false)
end)

RegisterNUICallback('savehaircolor', function(data, cb)
    SetPedHairColor(player, tonumber(data['firstColour']), tonumber(data['secondColour']))
end)

RegisterNUICallback('savefacefeatures', function(data, cb)
    local index = DoesTableHaveValue(face_features, data["name"])
    if (index <= -1) then return end
    local scale = tonumber(data["scale"]) / 100
    SetPedFaceFeature(player, index, scale)
end)

RegisterNUICallback('saveheadoverlay', function(data, cb)
    local index = DoesTableHaveValue(head_overlays, data["name"])
    SetPedHeadOverlay(player,  index, tonumber(data["value"]), tonumber(data["opacity"]) / 100)
end)

RegisterNUICallback('saveheadoverlaycolor', function(data, cb)
    local index = DoesTableHaveValue(head_overlays, data["name"])
    local success, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(player, index)
    local sColor = tonumber(data['secondColour'])
    if (sColor == nil) then
        sColor = tonumber(data['firstColour'])
    end
    SetPedHeadOverlayColor(player, index, colourType, tonumber(data['firstColour']), sColor)
end)


function DoesTableHaveValue(tab, val)
    for index = 1, #tab do
        if tab[index] == val then
            return index-1
        end
    end
    return -1
end

function EnableGUI(enable, menu, free)
    enabled = enable
    SetNuiFocus(enable, enable)
    SendNUIMessage({
        type = "enableclothesmenu",
        enable = enable,
        menu = menu,
        free = free,
        isService = isService,
    })

    if (not enable) then
        SaveToggleProps()
        oldPed = {}
    end
end

function CustomCamera(position)
    if InCharCreator then
        TaskClearLookAt(GetPlayerPed(-1))
        if position == "head" then
            SetCamActive(cameras.facial, true)
        elseif position == "torso" then
            SetCamActive(cameras.clothing, true)
        elseif position == "leg" then
            SetCamActive(cameras.shoes, true)
        end
        RenderScriptCams(true, true, 500, true, true)
    else
        if customCam or position == "torso" then
            FreezePedCameraRotation(player, false)
            SetCamActive(cam, false)
            RenderScriptCams(false,  false,  0,  true,  true)
            if (DoesCamExist(cam)) then
                DestroyCam(cam, false)
            end
            customCam = false
        else
            if (DoesCamExist(cam)) then
                DestroyCam(cam, false)
            end

            local pos = GetEntityCoords(player, true)
            SetEntityRotation(player, 0.0, 0.0, 0.0, 1, true)
            FreezePedCameraRotation(player, true)

            cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
            SetCamCoord(cam, player)
            SetCamRot(cam, 0.0, 0.0, 0.0)

            SetCamActive(cam, true)
            RenderScriptCams(true,  false,  0,  true,  true)

            SwitchCam(position)
            customCam = true
        end
    end
end

function RotatePlayer(dir)
    local pedRot = GetEntityHeading(PlayerPedId())+dir
    SetEntityHeading(PlayerPedId(), pedRot % 360)
end

function TogRotation()
    local pedRot = GetEntityHeading(PlayerPedId())+90 % 360
    SetEntityHeading(PlayerPedId(), math.floor(pedRot / 90) * 90.0)
end

function SwitchCam(name)
    if name == "cam" then
        TogRotation()
        return
    end

    local pos = GetEntityCoords(player, true)
    local bonepos = false
    if (name == "head") then
        bonepos = GetPedBoneCoords(player, 31086)
        bonepos = vector3(bonepos.x - 0.1, bonepos.y + 0.4, bonepos.z + 0.05)
    end
    if (name == "torso") then
        bonepos = GetPedBoneCoords(player, 11816)
        bonepos = vector3(bonepos.x - 0.4, bonepos.y + 2.2, bonepos.z + 0.2)
    end
    if (name == "leg") then
        bonepos = GetPedBoneCoords(player, 46078)
        bonepos = vector3(bonepos.x - 0.1, bonepos.y + 1, bonepos.z)
    end

    SetCamCoord(cam, bonepos.x, bonepos.y, bonepos.z)
    SetCamRot(cam, 0.0, 0.0, 180.0)
end

RegisterNUICallback('escape', function(data, cb)
    SaveSkin(data['save'], data['menu'], data['clothingTrigger'], data['outfitName'], data['isFree'])
    EnableGUI(false, false)
end)

RegisterNUICallback('togglecursor', function(data, cb)
    CustomCamera("torso")
    SetNuiFocus(false, false)
    FreezePedCameraRotation(player, false)
end)

RegisterNUICallback('rotate', function(data, cb)
    if (data["key"] == "left") then
        RotatePlayer(20)
    else
        RotatePlayer(-20)
    end
end)

RegisterNUICallback('switchcam', function(data, cb)
    CustomCamera(data['name'])
end)

RegisterNUICallback('toggleclothes', function(data, cb)
    ToggleProps(data)
end)

-- currentTats [[collectionHash, tatHash], [collectionHash, tatHash]]
-- loop tattooHashList [categ] find [tatHash, collectionHash]

function GetTats()
    local tempTats = {}
    if currentTats == nil then return {} end
    for i = 1, #currentTats do
        for key in pairs(tattooHashList) do
            for j = 1, #tattooHashList[key] do
                if tattooHashList[key][j][1] == currentTats[i][2] then
                    tempTats[key] = j
                end
            end
        end
    end
    return tempTats
end

function SetTats(data)
    currentTats = {}
    for k, v in pairs(data) do
        for categ in pairs(tattooHashList) do
            if k == categ then
                local something = tattooHashList[categ][tonumber(v)]
                if something ~= nil then
                    table.insert(currentTats, {something[2], something[1]})
                end
            end
        end
    end
    ClearPedDecorations(PlayerPedId())
    for i = 1, #currentTats do
        ApplyPedOverlay(PlayerPedId(), currentTats[i][1], currentTats[i][2])
    end
end

RegisterNUICallback('settats', function(data, cb)
    SetTats(data["tats"])
end)

function OpenMenu(name, free)
    player = GetPlayerPed(-1)
    oldPed = GetCurrentPed()
    FreezePedCameraRotation(player, true)
    RefreshUI()
    EnableGUI(true, name, free)
end

function SaveSkin(save, menu, cTrigger, outfitname, isFree)
    if save then
        data = GetCurrentPed()
        if not InCharCreator then
            local menutype = menu
            if menutype == "clothesmenu" then
                if cTrigger == 'onlycurrentsession' then
                    if not isFree then
                        -- Process Payment Here?
                    end
                elseif cTrigger == 'savenewoutfit' then
                    PW.TriggerServerCallback('pw_character:server:saveNewOutfit', function(success, total)
                        if success then
                            print('Successfully Updated Outfit')
                            if not isFree then
                                TriggerServerEvent('pw_character:server:payForMenu', 'clothing', 'a New Outfit')
                            end
                        else -- Double Checks
                            if total >= 10 then -- If Reach Outfit Limit!
                                exports.pw_notify:SendAlert('error', 'You Have Reached Your Max Outfits - Replace or Delete Old Outfits', 5000)
                            end

                            spawnCharacterSkin()
                        end
                    end, data, outfitname)
                elseif cTrigger == 'replacecurrentoutfit' then
                    PW.TriggerServerCallback('pw_character:server:replaceCurrentOutfit', function(success)
                        if success then
                            print('Successfully Updated Current Outfit')
                            if not isFree then
                                TriggerServerEvent('pw_character:server:payForMenu', 'clothing', 'a New Outfit')
                            end
                        else -- Double Checks
                            spawnCharacterSkin()
                        end
                    end, data)
                end
            elseif (menutype == "barbersmenu" or "cosmeticsmenu") and menutype ~= "tattoomenu" then
                PW.TriggerServerCallback('pw_character:server:updateSkinData', function(success)
                    if success then
                        print('Successfully Updated Skin')
                        TriggerServerEvent('pw_character:server:payForMenu', (menutype == 'barbersmenu' and 'barbers' or 'cosmetics'), (menutype == 'barbersmenu' and 'a New Haircut' or 'some Plastic Surgery'))
                    else -- Double Checks
                        spawnCharacterSkin() -- Reset to Last Outfit and Saved Skin
                    end
                end, data)
            elseif menutype == "tattoomenu" then
                if data.model == `mp_f_freemode_01` or data.model == `mp_m_freemode_01` then
                    if currentTats ~= nil then
                        PW.TriggerServerCallback('pw_character:server:updateTattoos', function(success)
                            if success then
                                print('Successfully Updated Tattoos')
                                TriggerServerEvent('pw_character:server:payForMenu', 'tattoos', 'new Tattoos')
                            else -- Double Checks
                                PW.TriggerServerCallback('pw_character:server:getTattooData', function(tattoos)
                                    TriggerEvent('pw_character:client:refreshCharTattoos', tattoos)
                                end)
                            end
                        end, currentTats)
                    end
                end
            end
        end
        if InCharCreator then
            TriggerServerEvent('pw_character:server:exitCharCreator', data)
        end
    else
        LoadPed(oldPed)
        PW.TriggerServerCallback('pw_character:server:getTattooData', function(tattoos)
            TriggerEvent('pw_character:client:refreshCharTattoos', tattoos)
        end)
    end
    CustomCamera('torso')
end

RegisterNetEvent('pw_character:client:completedCharCreation')
AddEventHandler('pw_character:client:completedCharCreation', function()
    InCharCreator = false
    RenderScriptCams(false, false, 0, false, false)
    DestroyAllCams(false)
    EnableAllControlActions(0)
    TriggerEvent('pw_core:client:enterCityFirstTime')
end)

RegisterNetEvent('pw_character:client:setupCharCreation')
AddEventHandler('pw_character:client:setupCharCreation', function(charGender, selectionCoords)   
    InCharCreator = true
    DisableAllControlActions(0)
    DoScreenFadeOut(1000)
    Citizen.Wait(1001)

    if charGender then
        SetSkin(`mp_m_freemode_01`, true)
    else
        SetSkin(`mp_f_freemode_01`, true)
    end
    local playerPed = PlayerPedId() 

    SetEntityCoords(playerPed, selectionCoords.x, selectionCoords.y, selectionCoords.z, 0,0,0,0)
    SetEntityHeading(playerPed, selectionCoords.h)
    Citizen.Wait(1000)
    local pedCoords = GetEntityCoords(playerPed, true)
    FreezeEntityPosition(playerPed, true)
    local cam1 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", (selectionCoords.x + 1.8), (selectionCoords.y + 0.03), (selectionCoords.z + 0.3), 0.00, 0.00, 0.00, 75.0, false, 2)
    local cam2 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", (selectionCoords.x + 0.5), (selectionCoords.y + 0.03), (selectionCoords.z + 0.7), 0.00, 0.00, 0.00, 75.0, false, 2)
    local cam3 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", (selectionCoords.x + 0.8), (selectionCoords.y + 0.03), (selectionCoords.z - 0.1), 0.00, 0.00, 0.00, 75.0, false, 2)
    
    cameras = {
        ['clothing'] = cam1,
        ['facial'] = cam2,
        ['shoes'] = cam3
    }
    PointCamAtCoord(cameras.clothing, selectionCoords.x, selectionCoords.y, selectionCoords.z)
    PointCamAtCoord(cameras.facial,  selectionCoords.x, selectionCoords.y, (selectionCoords.z + 0.50))
    PointCamAtCoord(cameras.shoes,  selectionCoords.x, selectionCoords.y,  selectionCoords.z - 0.99)

    SetCamActive(cameras.clothing, true)
    RenderScriptCams(true, true, 500, true, true)
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
    Citizen.Wait(1001)
    OpenMenu('charcreator')
end)

RegisterNetEvent('pw_character:client:refreshCharTattoos')
AddEventHandler('pw_character:client:refreshCharTattoos', function(charTattooList)
    currentTats = charTattooList
    SetTats(GetTats())
end)

RegisterNetEvent('pw_character:client:openOutfitManagement')
AddEventHandler('pw_character:client:openOutfitManagement', function()
    local menu = {}
    table.insert(menu, { ['label'] = 'Change into Outfit', ['action'] = 'pw_character:client:openOutfitChange', ['value'] = {action = "select"}, ['triggertype'] = 'client', ['color'] = 'success'})
    table.insert(menu, { ['label'] = 'Delete an Outfit', ['action'] = 'pw_character:client:openOutfitChange', ['value'] = {action = "delete"}, ['triggertype'] = 'client', ['color'] = 'danger'})
    TriggerEvent('pw_interact:generateMenu', menu, playerData.name .. " | Character Wardrobe")
end)

RegisterNetEvent('pw_character:client:openOutfitChange')
AddEventHandler('pw_character:client:openOutfitChange', function(action)
    local menu = {}
    PW.TriggerServerCallback('pw_character:server:getCharactersOutfits', function(outfits)
        if outfits[1] ~= nil then
            table.insert(menu, { ['label'] = #outfits .. ' / 10 Outfit Slots Used', ['action'] = '', ['value'] = {}, ['triggertype'] = 'client', ['color'] = 'info disabled'})
            for k, v in pairs(outfits) do
                table.insert(menu, { ['label'] = v.name, ['action'] = (action.action == "select" and 'pw_character:client:setPlayerToOutfit' or 'pw_character:server:deleteCharacterOutfit'), ['value'] = {action = action.action, outfit = v.outfit_id, outfitName = v.name}, ['triggertype'] = (action.action == "select" and 'client' or 'server'), ['color'] = (action.action == "select" and 'info' or 'warning')})
            end
        else
            table.insert(menu, { ['label'] = 'No Saved Outfits', ['action'] = '', ['value'] = "select", ['triggertype'] = 'client', ['color'] = 'warning disabled'})
        end
        TriggerEvent('pw_interact:generateMenu', menu, (action.action == "select" and "Select an Outfit to Wear" or "Delete an Outfit").." | ".. playerData.name)
    end)
end)

RegisterNetEvent('pw_character:client:setPlayerToOutfit')
AddEventHandler('pw_character:client:setPlayerToOutfit', function(data)
    local outfitID = data.outfit
    PW.TriggerServerCallback('pw_character:server:getOutfitData', function(skin, tattoos)
        if skin and skin ~= nil then
            LoadPed(skin)
            Citizen.Wait(400)
            if tattoos ~= nil then
                TriggerEvent('pw_character:client:refreshCharTattoos', tattoos)
            end
        else
            exports.pw_notify:SendAlert('error', 'Error Changing to Outfit', 2500)
        end
    end, outfitID)
end)

RegisterNetEvent('pw_character:client:characterAccessoryMenu')
AddEventHandler('pw_character:client:characterAccessoryMenu', function()
    local menu = {}
    for i = 1, #Config.ToggleableAccessories do
        table.insert(menu, { ['label'] = Config.ToggleableAccessories[i].name, ['action'] = 'pw_character:client:toggleCharacterAccess', ['value'] = Config.ToggleableAccessories[i].accessory, ['triggertype'] = 'client', ['color'] = 'info'})
    end
    TriggerEvent('pw_interact:generateMenu', menu, '<strong>Toggle Clothing Items</strong')
end)

RegisterNetEvent('pw_character:client:toggleCharacterAccess')
AddEventHandler('pw_character:client:toggleCharacterAccess', function(clothingType)
    local fuckingData = {
        ['name'] = clothingType,
    }
    local playerPed = PlayerPedId()
    if clothingType == 'hats' or clothingType == 'masks' then
        LoadAnimDict('mp_masks@on_foot')
        TaskPlayAnim(playerPed, 'mp_masks@on_foot', 'put_on_mask', 4.0, 3.0, -1, 49, 1.0, 0, 0, 0)
    elseif clothingType == 'glasses' then
        LoadAnimDict('clothingspecs')
        TaskPlayAnim(playerPed, 'clothingspecs', 'take_off', 4.0, 3.0, -1, 49, 1.0, 0, 0, 0)
        Citizen.Wait(500)
    end
    Citizen.Wait(500)
    ClearPedTasks(playerPed)
    ToggleProps(fuckingData)
end)

function LoadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(3)
    end
end

function spawnCharacterSkin()
    local done = nil
    PW.TriggerServerCallback('pw_character:server:getCharSkin', function(data, tattoos)
        LoadPed(data)
        Citizen.Wait(400)
        if tattoos ~= nil then
            TriggerEvent('pw_character:client:refreshCharTattoos', tattoos)
        end
        done = true
    end)
    repeat Wait(0) until done ~= nil
    return done
end

exports('spawnCharacterSkin', spawnCharacterSkin)

-- LoadPed(data) Sets clothing based on the data structure given, the same structure that GetCurrentPed() returns
-- GetCurrentPed() Gives you the data structure of the currently worn clothes

local blips = {}


function createBlippers()
    for k, v in pairs(Config.ShopLocations) do
        for t,q in pairs(v) do
            local blipIndex = k..t
            if Config.Blips[k] ~= nil then
                blips[blipIndex] = AddBlipForCoord(q.x, q.y, q.z)
                SetBlipSprite(blips[blipIndex], Config.Blips[k].blipSprite)
                SetBlipDisplay(blips[blipIndex], 4)
                SetBlipScale  (blips[blipIndex], Config.Blips[k].blipScale)
                SetBlipColour (blips[blipIndex], Config.Blips[k].blipColor)
                SetBlipAsShortRange(blips[blipIndex], true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(tostring(Config.Blips[k].blipName))
                EndTextCommandSetBlipName(blips[blipIndex])
            end
        end
    end
end

function deleteBlippers()
    for k, v in pairs(blips) do 
        RemoveBlip(v)
    end
end
