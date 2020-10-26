PW = nil

TriggerEvent('pw:loadFramework', function(framework)
     PW = framework
end)

RegisterServerEvent('pw_core:itemUsed')
AddEventHandler('pw_core:itemUsed', function(_src, data)
     if data.item == "fishingrod" then
          TriggerClientEvent('pw_fishing:startFishing', _src)
     else
          local _char = exports.pw_core:getCharacter(_src)
          local usedItem = false
          
          if data.item == "fishbait" then
               TriggerClientEvent('pw_fishing:setbait', _src, 1)
               usedItem = true
          elseif data.item == "advfishbait" then
               TriggerClientEvent('pw_fishing:setbait', _src, 2)
               usedItem = true
          elseif data.item == "turtle" then
               TriggerClientEvent('pw_fishing:setbait', _src, 3)
               usedItem = true
          end

          if usedItem then
               _char:Inventory():Remove().Default(data.record_id, 1, function(done) end)
          end
     end
end)

function randomFish()
     local randomFish = { 'fishKelp', 'fishBass', 'fishYellow' }
     return randomFish[math.random(1, #randomFish)]
end  


-- Need to Mess with the chances
RegisterNetEvent('pw_fishing:catch') 
AddEventHandler('pw_fishing:catch', function(bait, position)
     local _source = source
     local amount = 1
     local randomNum = math.random(1,100)
     local _char = exports.pw_core:getCharacter(_source)
     local fish = randomFish()
     if bait == 1 then
          if randomNum >= 75 then
               TriggerClientEvent('pw_fishing:setbait', _source, 0)
               amount = math.random(2, 5)
               TriggerClientEvent('pw:notification:SendAlert', _source, {type = "success", text = "You Caught " .. amount .. " Fish!", length = 5000})
          else
               amount = math.random(1, 3)
               TriggerClientEvent('pw:notification:SendAlert', _source, {type = "success", text = "You Caught " .. amount .. " Fish!", length = 5000})
          end
          _char:Inventory():Add().Default(1, fish, amount, {}, {}, function(item) end)
     elseif bait == 2 then
          if position.y >= 7700 or position.y <= -4000 or position.x <= -3700 or position.x >= 4300 then -- If Very Far from shore you get chance of the illegal fish
               if randomNum >= 85 then 
                    if randomNum >= 91 then
                         TriggerClientEvent('pw_fishing:setbait', _source, 0)
                         TriggerClientEvent('pw_fishing:breakrod', _source)
                         _char:Inventory():Remove().ByName('fishingrod', 1)
                    else
                         TriggerClientEvent('pw_fishing:setbait', _source, 0)
                         TriggerClientEvent('pw:notification:SendAlert', _source, {type = "success", text = "You Caught a Turtle!", length = 5000})
                         _char:Inventory():Add().Default(1, 'turtle', 1, {}, {}, function(item) end)
                    end
               else
                    if randomNum >= 75 then
                         amount = math.random(4, 6)
                         TriggerClientEvent('pw:notification:SendAlert', _source, {type = "success", text = "You Caught " .. amount .. " Fish!", length = 5000})
                    else
                         amount = math.random(2, 4)
                         TriggerClientEvent('pw:notification:SendAlert', _source, {type = "success", text = "You Caught " .. amount .. " Fish!", length = 5000})
                    end
                    _char:Inventory():Add().Default(1, fish, amount, {}, {}, function(item) end)
               end
          else
               if randomNum >= 75 then
                    TriggerClientEvent('pw_fishing:setbait', _source, 0)
                    amount = math.random(5, 7)
                    TriggerClientEvent('pw:notification:SendAlert', _source, {type = "success", text = "You Caught " .. amount .. " Fish!", length = 5000})
               else
                    amount = math.random(2, 4)
                    TriggerClientEvent('pw:notification:SendAlert', _source, {type = "success", text = "You Caught " .. amount .. " Fish!", length = 5000})
               end
               _char:Inventory():Add().Default(1, fish, amount, {}, {}, function(item) end)
          end
     elseif bait == 3 then
          if position.y >= 7700 or position.y <= -4000 or position.x <= -3700 or position.x >= 4300 then -- If Very Far from shore you get chance of the illegal fish
               if randomNum >= 82 then
                    if randomNum >= 91 then
                         TriggerClientEvent('pw_fishing:setbait', _source, 0)
                         TriggerClientEvent('pw_fishing:breakrod', _source)
                         _char:Inventory():Remove().ByName('fishingrod', 1)
                    else
                         TriggerClientEvent('pw:notification:SendAlert', _source, {type = "success", text = "You Caught a Shark!", length = 5000})
                         --TriggerClientEvent('fishing:spawnPed', _source)
                         _char:Inventory():Add().Default(1, 'shark', 1, {}, {}, function(item) end)
                         TriggerClientEvent('pw_fishing:setbait', _source, 0)
                    end	
               else
                    amount = math.random(6, 9)
                    TriggerClientEvent('pw:notification:SendAlert', _source, {type = "success", text = "You Caught " .. amount .. " Fish!", length = 5000})
                    _char:Inventory():Add().Default(1, fish, amount, {}, {}, function(item) end)
               end
          end
     elseif bait == 0 then
          TriggerClientEvent('pw:notification:SendAlert', _source, {type = "warning", text = "You Are Fishing Without Bait. You Probably Won't Catch Anything!", length = 5000})	
          if randomNum >= 95 then
               TriggerClientEvent('pw:notification:SendAlert', _source, {type = "success", text = "You're Lucky! You Caught a Fish With No Bait!", length = 5000})
               _char:Inventory():Add().Default(1, fish, 1, {}, {}, function(item) end)
          end  
     end
end)

RegisterServerEvent('pw_fishing:server:sellFish')
AddEventHandler('pw_fishing:server:sellFish', function(data)
     local _src = source 
     local _char = exports.pw_core:getCharacter(_src)
     local indexid = data.saleid
     local fish_item = Config.FishSales[indexid].item
     local fish_label = Config.FishSales[indexid].label
     local min_price = Config.FishSales[indexid].price_min
     local max_price = Config.FishSales[indexid].price_max

     local final_price = math.random(min_price, max_price)
     _char:Inventory().getItemCount(fish_item, function(fishAmount)
          if fishAmount > 0 then 
               _char:Inventory():Remove().ByName(fish_item, fishAmount, function(done) end)
               local cash = (final_price * fishAmount)
               local _balance = _char:Cash().addCash(cash, function(done)
                    TriggerClientEvent('pw:notification:SendAlert', _src, {type = "success", text = "You Have Sold " .. fishAmount .. " " .. fish_label ..  " for $" .. cash .. "!", length = 7000})
               end)
          else
               TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "You Have None to Sell!", length = 5000})     
          end
     end)
end)