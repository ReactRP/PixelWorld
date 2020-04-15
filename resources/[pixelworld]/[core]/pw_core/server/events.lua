RegisterServerEvent('pw:toggleDuty')
AddEventHandler('pw:toggleDuty', function()
    local _src = source
    if Characters[_src] then
        Characters[_src]:Job().toggleDuty()
    end
end)