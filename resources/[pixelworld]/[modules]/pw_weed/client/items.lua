local MFD = MF_DopePlant

RegisterNetEvent('pw_weed:Usewateringcan')
AddEventHandler('pw_weed:Usewateringcan', function(data)
    local template = MFD:ItemTemplate()
    template.Type = "Water"
    template.Quality = 0.1
    TriggerEvent('pw_weed:UseItem', template, "weed", data)
end)

RegisterNetEvent('pw_weed:Usepurifiedwater')
AddEventHandler('pw_weed:Usepurifiedwater', function(data)
    local template = MFD:ItemTemplate()
    template.Type = "Water"
    template.Quality = 0.2
    TriggerEvent('pw_weed:UseItem', template, "weed", data)
end)

RegisterNetEvent('pw_weed:Uselgfert')
AddEventHandler('pw_weed:Uselgfert', function(data)
    local template = MFD:ItemTemplate()
    template.Type = "Food"
    template.Quality = 0.1
    TriggerEvent('pw_weed:UseItem', template, "weed", data)
end)

RegisterNetEvent('pw_weed:Usehgfert')
AddEventHandler('pw_weed:Usehgfert', function(data)
    local template = MFD:ItemTemplate()
    template.Type = "Food"
    template.Quality = 0.2
    TriggerEvent('pw_weed:UseItem', template, "weed", data)
end)

RegisterNetEvent('pw_weed:Uselgmseed')
AddEventHandler('pw_weed:Uselgmseed', function()
    local exists = PW.Game.CheckInventory('plantpot')
    if exists > 0 then
        local template = MFD:PlantTemplate()
        template.Gender = "Male"
        template.Quality = math.random(1,100)/10
        template.Food =  math.random(100,200)/10
        template.Water = math.random(100,200)/10
        TriggerEvent('pw_weed:UseSeed', template, "lgmseed")
    else
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = "You need a plant pot to plant the seed"})
    end
end)

RegisterNetEvent('pw_weed:Usehgmseed')
AddEventHandler('pw_weed:Usehgmseed', function()
    local exists = PW.Game.CheckInventory('plantpot')
    if exists > 0 then
        local template = MFD:PlantTemplate()
        template.Gender = "Male"
        template.Quality = 0.2
        template.Quality = math.random(200,500)/10
        template.Food =  math.random(200,400)/10
        template.Water = math.random(200,400)/10
        TriggerEvent('pw_weed:UseSeed', template, "hgmseed")
    else
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = "You need a plant pot to plant the seed"})
    end
end)

RegisterNetEvent('pw_weed:Uselgfseed')
AddEventHandler('pw_weed:Uselgfseed', function()
    local exists = PW.Game.CheckInventory('plantpot')
    if exists > 0 then
        local template = MFD:PlantTemplate()
        template.Gender = "Female"
        template.Quality = 0.1
        template.Quality = math.random(1,100)/10
        template.Food =  math.random(100,200)/10
        template.Water = math.random(100,200)/10
        TriggerEvent('pw_weed:UseSeed', template, "lgfseed")
    else
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = "You need a plant pot to plant the seed"})
    end
end)

RegisterNetEvent('pw_weed:Usehgfseed')
AddEventHandler('pw_weed:Usehgfseed', function()
    local exists = PW.Game.CheckInventory('plantpot')
    if exists > 0 then
        local template = MFD:PlantTemplate()
        template.Gender = "Female"
        template.Quality = 0.2
        template.Quality = math.random(200,500)/10
        template.Food =  math.random(200,400)/10
        template.Water = math.random(200,400)/10
        TriggerEvent('pw_weed:UseSeed', template, "hgfseed")
    else
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = "You need a plant pot to plant the seed"})
    end
end)

RegisterNetEvent('pw_weed:Usedopebag')
AddEventHandler('pw_weed:Usedopebag', function()
    local canUse = false
    local exists = PW.Game.CheckInventory('trimmedweed')
    local exists2 = PW.Game.CheckInventory('dopebag')
    if exists >= MFD.WeedPerBag and exists2 >= 1 then
        exists = PW.Game.CheckInventory('drugscales')
        if exists > 0 then
            local takeItems = {}
            local giveItems = {}
            table.insert(takeItems, { ['name'] = "trimmedweed", ['qty'] = MFD.WeedPerBag })
            table.insert(takeItems, { ['name'] = "dopebag", ['qty'] = 1 })
            table.insert(giveItems, { ['name'] = "bagofdope", ['qty'] = 1 })
            canUse = true
            msg = "You put "..MFD.WeedPerBag.." trimmed weed into a ziplock bag"
            TriggerServerEvent('pw_coke:RemoveThisShit', takeItems)
            Citizen.Wait(1500)
            TriggerServerEvent('pw_coke:GiveThisShits', giveItems)
        else
            msg = "You need a set of scales to weigh the bag up correctly"
        end
    else
        msg = "You don/'t have enough trimmed weed to do this"
    end

    TriggerEvent('pw_weed:UseBag', canUse, msg)
end)

RegisterNetEvent('pw_weed:Usejoint')
AddEventHandler('pw_weed:Usejoint', function()
    local canUse = false
    local exists = PW.Game.CheckInventory('joint')

    if exists > 0 then 
        canUse = true
        if canUse then

        end
    end
end)

RegisterNetEvent('pw_weed:Userollingpapers')
AddEventHandler('pw_weed:Userollingpapers', function()
    local takeItems = {}
    local giveItems = {}
    local canUse = false
    local process = false
    local exists = PW.Game.CheckInventory('bagofdope')
    if exists >= MFD.DopePerJoints.neededDope then
        local papers = PW.Game.CheckInventory('rollingpapers')
        if papers >= MFD.DopePerJoints.neededPapers then
            canUse = true
            if canUse then
                table.insert(takeItems, { ['name'] = "bagofdope", ['qty'] = MFD.DopePerJoints.neededDope })
                table.insert(takeItems, { ['name'] = "rollingpapers", ['qty'] = MFD.DopePerJoints.neededPapers })
                table.insert(giveItems, { ['name'] = "joint", ['qty'] = MFD.DopePerJoints.awardedJoints })
                exports['pw_progbar']:Progress({
                    name = "rolling_action",
                    duration = 6000,
                    label = "Rolling Joints",
                    useWhileDead = true,
                    canCancel = true,
                    controlDisables = {
                        disableMovement = false,
                        disableCarMovement = false,
                        disableMouse = false,
                        disableCombat = false,
                    },
                }, function(status)
                    if not status then
                        msg = "You have rolled "..MFD.DopePerJoints.awardedJoints.." joints."
                        exports['pw_notify']:SendAlert('inform', msg)
                        canUse = false
                        process = true
                        TriggerServerEvent('pw_coke:RemoveThisShit', takeItems)
                        TriggerServerEvent('pw_coke:GiveThisShits', giveItems)
                    else
                        canUse = false
                    end
                end)
            end
        else
            local reqPapers = MFD.DopePerJoints.neededPapers - papers
            msg = "You don/'t have enough Rolling Papers to roll joints, "..reqPapers.."x more required."
            exports['pw_notify']:SendAlert('error', msg)
            process = true
        end
    else
        local reqWeed = MFD.DopePerJoints.neededDope - exists
        msg = "You don/'t have enough weighed weed to roll joints, "..reqWeed.."x more required."
        exports['pw_notify']:SendAlert('error', msg)
        process = true
    end
    while not process do Citizen.Wait(0) end
end)

function MFD:ItemTemplate()
    return {
        ["Type"] = "Water",
        ["Quality"] = 0.0,
    }
end

function MFD:PlantTemplate()
    return {
        ["Gender"] = "Female",
        ["Quality"] = 0.0,
        ["Growth"] = 0.0,
        ["Water"] = 20.0,
        ["Food"] = 20.0,
        ["Stage"] = 1,
        ["PlantID"] = math.random(math.random(999999,9999999),math.random(99999999,999999999))
    }
end
