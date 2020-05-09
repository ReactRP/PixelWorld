
local passwordCard = {
    ["type"]="AdaptiveCard",
    ["minHeight"]="200px",
    ["body"]={
        {
            ["type"]="Container",
            ["items"]={
                {
                    ["type"]="TextBlock",
                    ["horizontalAlignment"]="Left",
                    ["text"]="Welcome to PixelWorldRP, Please login below using your OTP authenticator application."
                },
                {
                    ["type"]="TextBlock",
                    ["horizontalAlignment"]="Left",
                    ["text"]="One Time Passcode"
                },
                {
                    ["type"]="Input.Text",
                    ["id"]="otp",
                    ["value"]=""
                },
                {
                    ["type"]="Container",
                    ["isVisible"]=false,
                    ["items"]={
                        {
                            ["type"]="TextBlock",
                            ["weight"]="Bolder",
                            ["color"]="Attention",
                            ["horizontalAlignment"]="Right",
                            ["text"]="Error: Invalid One Time Passcode entered!"
                        }
                    }
                }
            }
        }
    },
    ["actions"]={
        {
            ["type"]="Action.Submit",
            ["title"]="Enter"
        }
    },
    ["$schema"]="http://adaptivecards.io/schemas/adaptive-card.json",
    ["version"]="1.2"
}

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local player = source
    local name = GetPlayerName(player)
   
    print(json.encode(passwordCard))

    function showPasswordCard(deferrals, callback, showError, errorMessage)
        local card = passwordCard
        card.body[1].items[4].isVisible = showError and true or false
        if showError and errorMessage then
            card.body[1].items[4].items[1].text = errorMessage
        end
        deferrals.presentCard(card, callback)
    end


    deferrals.defer()

    if not serverStarted then
        deferrals.done(string.format("Welcome to PixelWorld %s, The server is still currently starting up please retry connecting in a few minutes.", name))
        repeat Wait(0) until serverStarted == true
    else

        deferrals.update('Connecting to PixelWorld Roleplay please wait...')
        Wait(500)
        deferrals.update('Accessing Steam ID')
        local _steam = PW.LoadSteamIdent(player)
        Wait(500)
        if _steam ~= false then
            deferrals.update('Loading Login')
        else
            DropPlayer(player, "We could not locate your SteamID")
        end

        if PWBase['StartUp'].CreateUser(_steam, player) then
            PWBase['StartUp'].LoadUser(_steam, player, true)
        else
            DropPlayer(player, "Failed to create a User Account on PixelWorld, please try reconnecting.")
        end

        local function passwordCardCallback(data, rawData)
            local match = false
            tempUsers[_steam].verifyOTP(data.otp, function(result)
                if not result.success then
                    showPasswordCard(deferrals, passwordCardCallback, true, result.reason)
                else
                    tempPasswords[_steam] = result
                    PW.Print(tempPasswords[_steam])
                    local added = false
                    if result.owner and not added then   
                        Queue.AddPriority(_steam, 100)
                        added = true 
                    elseif result.developer and not added then
                        Queue.AddPriority(_steam, 99)
                        added = true
                    elseif result.privAccess and not added then
                        Queue.AddPriority(_steam, 90)
                        added = true
                    else
                        Queue.AddPriority(_steam, 50)
                        added = true
                    end

                    if added then
                        tempUsers[_steam] = nil
                        playerConnect(name, setKickReason, deferrals, player)
                    end
                end        
            end)
        end
        showPasswordCard(deferrals, passwordCardCallback)
    end
end)