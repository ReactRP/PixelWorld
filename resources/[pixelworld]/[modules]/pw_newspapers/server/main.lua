PW = nil

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

exports.pw_chat:AddChatCommand('newspaper', function(source, args, rawCommand)
    local _src = source
    local onlineChars = exports['pw_core']:getOnlineCharacters()
    local charsInPrison = {}
    for k, v in pairs(onlineChars) do
        local _char = exports['pw_core']:getCharacter(v.source)
        local prisonState = _char:Custody().getPrisonState()
        if prisonState.inPrison then
            local charName = _char.getFullName()
            table.insert(charsInPrison, { ['name'] = charName, ['inPrison'] = prisonState.inPrison, ['time'] = prisonState.total })
        end
    end
    TriggerClientEvent('pw_newspaper:client:buyNewspaper', _src, charsInPrison)
end, {
    help = "Get Newspaper from Newspaper Stand",
}, -1)