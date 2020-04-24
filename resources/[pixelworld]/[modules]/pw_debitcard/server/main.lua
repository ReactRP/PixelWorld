PW = nil

TriggerEvent('pw:loadFramework', function(obj)
    PW = obj
end)
 
PW.RegisterServerCallback('pw_debitcard:server:requestCards', function(source, cb)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    MySQL.Async.fetchAll("SELECT * FROM `stored_items` WHERE `type` = 'Bankcard' AND `identifier` = @cid AND `inventoryType` = 1", {['@cid'] = _char.getCID()}, function(cards)
        local sendCards = {}
        for k, v in pairs(cards) do 
            local jsonCheck = json.decode(v.metaprivate)
            local cardData = MySQL.Sync.fetchAll("SELECT * FROM `debitcards` WHERE `record_id` = @record", {['@record'] = jsonCheck.debitcardid})[1] or nil
            local cardOwner = exports['pw_core']:getOffline(tonumber(cardData.owner_cid)).getFullName()
            if cardData ~= nil then
                table.insert(sendCards, {['metaprivate'] = v.metaprivate, ['metapublic'] = v.metapublic, ['owner_name'] = cardOwner, ['card_type'] = cardData.type, ['cardmeta'] = json.decode(cardData.cardmeta), ['item'] = v.item, ['slot'] = v.slot, ['type'] = v.type, ['count'] = v.count, ['character_id'] = v.identifier, ['record_id'] = v.record_id})
            end
        end
        cb(sendCards)
    end)
end)

PW.RegisterServerCallback('pw_debitcard:anyDebitCards', function(source, cb)
    if authed == GetConvar("PWResponseCode", "invalid") then
        local _src = source
        local _char = exports.pw_core:getCharacter(_src)
        _char:Inventory().getItemCountofType('Bankcard', function(total)
            cb(total)
        end)
    end
end)

RegisterServerEvent('pw_debitcard:server:autherisePayment')
AddEventHandler('pw_debitcard:server:autherisePayment', function(data)
    local _src = source
    if data ~= nil then
        MySQL.Async.fetchAll("SELECT * FROM `debitcards` WHERE `cardnumber` = @cn", {['@cn'] = data.cardNumber}, function(current)
            if current[1] ~= nil then
                local cardMeta = json.decode(current[1].cardmeta)
                if not cardMeta.stolen then
                    if not cardMeta.locked then
                        -- Pin Check
                        if cardMeta.cardPin == tonumber(data.enteredPin) then
                            local userOnline = exports['pw_core']:checkOnline(tonumber(current[1].owner_cid))

                            if userOnline ~= false and userOnline > 0 then
                                -- User is online so can do via user functions
                                local _char = exports['pw_core']:getCharacter(userOnline)
                                local _curBal = _char:Bank().getBalance()
                                if _curBal >= tonumber(data.amount) then
                                    _char:Bank().removeMoney(tonumber(data.amount), data.statement, function(success)
                                        if success then
                                            if data.triggerType == "client" then
                                                TriggerClientEvent(data.trigger, _src, data.data)
                                            else
                                                TriggerEvent(data.trigger, data.data)
                                            end
                                        else
                                            TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "There was an error processing your payment.", length = 5000})
                                        end
                                    end)
                                else
                                    TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "Not enough funds avaliable in account.", length = 5000})
                                end
                            else
                                local _loadBank = exports['pw_banking']:getOfflineAccount(tonumber(current[1].owner_cid))
                                -- User is offline load offline account loads
                                local _curBal = _loadBank.getBalance()
                                print(_curBal, data.amount)
                                if _curBal >= tonumber(data.amount) then
                                    _loadBank.removeMoney(tonumber(data.amount), data.statement, function(success)
                                        if success then
                                            if data.triggerType == "client" then
                                                TriggerClientEvent(data.trigger, _src, data.data)
                                            else
                                                TriggerEvent(data.trigger, data.data)
                                            end
                                        else
                                            TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "There was an error processing your payment.", length = 5000})
                                        end
                                    end)
                                else
                                    TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "Not enough funds avaliable in account.", length = 5000})
                                end
                            end

                        else
                            TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "Your pin has been rejected.", length = 5000})
                        end
                    else
                        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "The card you are attempting to use is frozen, please unlock at a nearest bank.", length = 5000})
                    end
                else
                    TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "This card has been reported lost or stolen and can no longer be used.", length = 5000})
                end
            else
                TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "This card has been reported lost or stolen and can no longer be used.", length = 5000})
            end
        end)
    end
end)