PW = nil

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)


RegisterServerEvent('pw_newsreporter:server:toggleDuty')
AddEventHandler('pw_newsreporter:server:toggleDuty', function()
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    _char:Job().toggleDuty()
end)

exports.pw_chat:AddChatCommand('newscam', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent("pw_newsreporter:client:ToggleCam", _src)
end, {
    help = 'Use the News Camera',
    params = {}
}, -1, { 'newsreporter' })

exports.pw_chat:AddChatCommand('newsmic', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent("pw_newsreporter:client:ToggleMic", _src)
end, {
    help = 'Use the News Microphone',
    params = {}
}, -1, { 'newsreporter' })

exports.pw_chat:AddChatCommand('newsboommic', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent("pw_newsreporter:client:ToggleBMic", _src)
end, {
    help = 'Use the News Boom Mic',
    params = {}
}, -1, { 'newsreporter' })