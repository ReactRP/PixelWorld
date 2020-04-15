AddEventHandler('onResourceStart', function(res)
    if res == "karts" then
        exports['pw_base']:ServerStartupSequence()
    end
end)