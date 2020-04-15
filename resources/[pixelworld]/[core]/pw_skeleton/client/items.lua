RegisterNetEvent("pw_skeleton:items:gauze")
AddEventHandler("pw_skeleton:items:gauze", function()
    exports['pw_progbar']:Progress({
        name = "firstaid_action",
        duration = 1500,
        label = "Packing Wounds",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "missheistdockssetup1clipboard@idle_a",
            anim = "idle_a",
            flags = 49,
        },
        prop = {
            model = "prop_paper_bag_small",
        }
    }, function(status)
        if not status then
            TriggerEvent('pw_skeleton:client:FieldTreatBleed')
        end
    end)
end)

RegisterNetEvent("pw_skeleton:items:bandage")
AddEventHandler("pw_skeleton:items:bandage", function()
    exports['pw_progbar']:Progress({
        name = "firstaid_action",
        duration = 5000,
        label = "Using Bandage",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "missheistdockssetup1clipboard@idle_a",
            anim = "idle_a",
            flags = 49,
        },
        prop = {
            model = "prop_paper_bag_small",
        }
    }, function(status)
        if not status then
            local playerPed = PlayerPedId()
			local maxHealth = GetEntityMaxHealth(playerPed)
			local health = GetEntityHealth(playerPed)
			local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 16))
			SetEntityHealth(playerPed, newHealth)
        end
    end)
end)

RegisterNetEvent("pw_skeleton:items:firstaid")
AddEventHandler("pw_skeleton:items:firstaid", function()
    exports['pw_progbar']:Progress({
        name = "firstaid_action",
        duration = 10000,
        label = "Using First Aid",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "missheistdockssetup1clipboard@idle_a",
            anim = "idle_a",
            flags = 49,
        },
        prop = {
            model = "prop_stat_pack_01"
        },
    }, function(status)
        if not status then
            local playerPed = PlayerPedId()
			local maxHealth = GetEntityMaxHealth(playerPed)
			local health = GetEntityHealth(playerPed)
			local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 8))
			SetEntityHealth(playerPed, newHealth)
        end
    end)
end)

RegisterNetEvent("pw_skeleton:items:medkit")
AddEventHandler("pw_skeleton:items:medkit", function()
    exports['pw_progbar']:Progress({
        name = "firstaid_action",
        duration = 20000,
        label = "Using Medkit",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "missheistdockssetup1clipboard@idle_a",
            anim = "idle_a",
            flags = 49,
        },
        prop = {
            model = "prop_ld_health_pack"
        },
    }, function(status)
        if not status then
            local playerPed = PlayerPedId()
            SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
            TriggerEvent('pw_skeleton:client:ResetLimbs')
        end
    end)
end)

RegisterNetEvent("pw_skeleton:items:vicodin")
AddEventHandler("pw_skeleton:items:vicodin", function()
    exports['pw_progbar']:Progress({
        name = "firstaid_action",
        duration = 1000,
        label = "Taking Vicodin",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "mp_suicide",
            anim = "pill",
            flags = 49,
        },
        prop = {
            model = "prop_cs_pills",
            bone = 58866,
            coords = { x = 0.1, y = 0.0, z = 0.001 },
            rotation = { x = -60.0, y = 0.0, z = 0.0 },
        },
    }, function(status)
        if not status then
            TriggerEvent('pw_skeleton:client:UsePainKiller', 1)
        end
    end)
end)

RegisterNetEvent("pw_skeleton:items:hydrocodone")
AddEventHandler("pw_skeleton:items:hydrocodone", function()
    exports['pw_progbar']:Progress({
        name = "firstaid_action",
        duration = 1000,
        label = "Taking Hydrocodone",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "mp_suicide",
            anim = "pill",
            flags = 49,
        },
        prop = {
            model = "prop_cs_pills",
            bone = 58866,
            coords = { x = 0.1, y = 0.0, z = 0.001 },
            rotation = { x = -60.0, y = 0.0, z = 0.0 },
        },
    }, function(status)
        if not status then
            TriggerEvent('pw_skeleton:client:UsePainKiller', 2)
        end
    end)
end)

RegisterNetEvent("pw_skeleton:items:morphine")
AddEventHandler("pw_skeleton:items:morphine", function()
    exports['pw_progbar']:Progress({
        name = "firstaid_action",
        duration = 2000,
        label = "Taking Morphine",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "mp_suicide",
            anim = "pill",
            flags = 49,
        },
        prop = {
            model = "prop_cs_pills",
            bone = 58866,
            coords = { x = 0.1, y = 0.0, z = 0.001 },
            rotation = { x = -60.0, y = 0.0, z = 0.0 },
        },
    }, function(status)
        if not status then
            TriggerEvent('pw_skeleton:client:UsePainKiller', 6)
        end
    end)
end)