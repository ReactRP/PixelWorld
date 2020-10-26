local MFD = MF_CokePlant

RegisterNetEvent('pw_coke:Usewateringcan')
AddEventHandler('pw_coke:Usewateringcan', function(data)
    local template = MFD:ItemTemplate()
    template.Type = "Water"
    template.Quality = 0.1
    TriggerEvent('pw_coke:UseItem', template, "coke", data)
end)

RegisterNetEvent('pw_coke:Usepurifiedwater')
AddEventHandler('pw_coke:Usepurifiedwater', function(data)
    local template = MFD:ItemTemplate()
    template.Type = "Water"
    template.Quality = 0.2
    TriggerEvent('pw_coke:UseItem', template, "coke", data)
end)

RegisterNetEvent('pw_coke:Uselgfert')
AddEventHandler('pw_coke:Uselgfert', function(data)
    local template = MFD:ItemTemplate()
    template.Type = "Food"
    template.Quality = 0.1
    TriggerEvent('pw_coke:UseItem', template, "coke", data)
end)

RegisterNetEvent('pw_coke:Usehgfert')
AddEventHandler('pw_coke:Usehgfert', function(data)
    local template = MFD:ItemTemplate()
    template.Type = "Food"
    template.Quality = 0.2
    TriggerEvent('pw_coke:UseItem', template, "coke", data)
end)

RegisterNetEvent('pw_coke:Uselgmcokeseed')
AddEventHandler('pw_coke:Uselgmcokeseed', function()
    local exists = PW.Game.CheckInventory('plantpot')
    if exists > 0 then
        local items = {}
        table.insert(items, { ['name'] = "plantpot", ['qty'] = 1 })
        local template = MFD:PlantTemplate()
        template.Gender = "Male"
        template.Quality = math.random(1,100)/10
        template.Food =  math.random(100,200)/10
        template.Water = math.random(100,200)/10
        TriggerEvent('pw_coke:UseCokeSeed', template, "lgmcokeseed")
    else
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = "You need a plant pot to plant the seed"})
    end
end)

RegisterNetEvent('pw_coke:Usehgmcokeseed')
AddEventHandler('pw_coke:Usehgmcokeseed', function()
    local exists = PW.Game.CheckInventory('plantpot')
    if exists > 0 then
        local items = {}
        table.insert(items, { ['name'] = "plantpot", ['qty'] = 1 })
        local template = MFD:PlantTemplate()
        template.Gender = "Male"
        template.Quality = 0.2
        template.Quality = math.random(200,500)/10
        template.Food =  math.random(200,400)/10
        template.Water = math.random(200,400)/10

        TriggerEvent('pw_coke:UseCokeSeed', template, "hgmcokeseed")
    else
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = "You need a plant pot to plant the seed"})
    end
end)

RegisterNetEvent('pw_coke:Uselgfcokeseed')
AddEventHandler('pw_coke:Uselgfcokeseed', function()
    local exists = PW.Game.CheckInventory('plantpot')
    if exists > 0 then
        local items = {}
        table.insert(items, { ['name'] = "plantpot", ['qty'] = 1 })
        local template = MFD:PlantTemplate()
        template.Gender = "Female"
        template.Quality = 0.1
        template.Quality = math.random(1,100)/10
        template.Food =  math.random(100,200)/10
        template.Water = math.random(100,200)/10
        TriggerEvent('pw_coke:UseCokeSeed', template, "lgfcokeseed")
    else
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = "You need a plant pot to plant the seed"})
    end
end)

RegisterNetEvent('pw_coke:Usehgfcokeseed')
AddEventHandler('pw_coke:Usehgfcokeseed', function()
    local exists = PW.Game.CheckInventory('plantpot')
    if exists > 0 then
        local items = {}
        table.insert(items, { ['name'] = "plantpot", ['qty'] = 1 })
        local template = MFD:PlantTemplate()
        template.Gender = "Female"
        template.Quality = 0.2
        template.Quality = math.random(200,500)/10
        template.Food =  math.random(200,400)/10
        template.Water = math.random(200,400)/10
        TriggerEvent('pw_coke:UseCokeSeed', template, "hgfcokeseed")
    else
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = "You need a plant pot to plant the seed"})
    end
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
