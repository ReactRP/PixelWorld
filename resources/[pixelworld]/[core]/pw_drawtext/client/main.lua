-- [[
--    You can find icons on the fontawesome.com website, We operate using the Pro Packages 
--    and are wanting icons as DUOTONE only. unless there is not a specific duotone icon
--    Most icons have duotone support so select the one which is duotone, 
--    We also only need the icon name so for example most icons are listed in HTML I format.
--   Example on FontAwesome Website: <i class="fad fa-question-square"></i>
--    we only need the fad fa-question-square mark specified, not the <i class=""></i> part.
--    ]]--

RegisterNetEvent('pw:playerUnLoaded')
AddEventHandler('pw:playerUnLoaded', function()
	TriggerEvent('pw_drawtext:hideNotification')
end)

RegisterNetEvent('pw_drawtext:showNotification')
AddEventHandler('pw_drawtext:showNotification', function(args)
    if args and args.message ~= nil and args.title ~= nil then
        TriggerEvent('pw_hud:client:toggleLogo', false)
        icon = args.icon or "fad fa-question-square"
        SendNUIMessage({
            action = "showNotification",
            message = args.message,
            title = args.title,
            icon = icon
        })
    end
end)

RegisterNetEvent('pw_drawtext:hideNotification')
AddEventHandler('pw_drawtext:hideNotification', function()
    TriggerEvent('pw_hud:client:toggleLogo', true)
    SendNUIMessage({
        action = "hideNotification",
    })
end)

