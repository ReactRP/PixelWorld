PW = nil
evidenceDrops = {}

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

AddEventHandler('pw:databaseCachesLoaded', function(caches)

end)

RegisterServerEvent('pw_evidence:server:registerProjectile')
AddEventHandler('pw_evidence:server:registerProjectile', function(det)
    if det then
        local addEvidence = true
        for k, v in pairs(evidenceDrops) do
            local distance = #(vector3(v.hitCoords.x, v.hitCoords.y, v.hitCoords.z) - vector3(det.hitCoords.x, det.hitCoords.y, det.hitCoords.z))
            if distance < 0.5 and (v.evidenceType == det.evidenceType) then
                addEvidence = false
                return;
            end
        end

        if addEvidence then
            det.evidenceIdent = math.random(1000,99999999)
            table.insert(evidenceDrops, det)
        end
    end
end)

RegisterServerEvent('pw_evidence:server:evidencePickedUp')
AddEventHandler('pw_evidence:server:evidencePickedUp', function(ident)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    for k, v in pairs(evidenceDrops) do
        if v.evidenceIdent == ident then
            PW.Print(v)
            evidenceDrops[k] = nil
            TriggerClientEvent('pw_evidence:client:removeLocalEvidence', -1, ident)
            break;
        end
    end
end)

RegisterServerEvent('pw_evidence:server:clearArea')
AddEventHandler('pw_evidence:server:clearArea', function(coords, reqDistance)
    local _src = source
    local toDelete = {}
    for k, v in pairs(evidenceDrops) do
        local distance = #(coords - vector3(v.hitCoords.x, v.hitCoords.y, v.hitCoords.z))
        if distance < reqDistance then
            toDelete[k] = true
        end
    end

    for t, q in pairs(toDelete) do
        evidenceDrops[t] = nil
    end
end)

PW.RegisterServerCallback('pw_evidence:server:requestEvidenceZone', function(source, cb, zoneid)
    local evidence = {}
    for k, v in pairs(evidenceDrops) do
        if v.zoneid == zoneid then
            table.insert(evidence, v)
        end
    end
    cb((evidence or {}))
end)

exports.pw_chat:AddChatCommand('clearevidence', function(source, args, rawCommand)
    TriggerClientEvent('pw_evidence:client:requestCoordstoClear', source)
end, {
    help = '[POLICE] - Clear Remaining Uncollected Evidence around the scene',
}, -1, { 'police' })