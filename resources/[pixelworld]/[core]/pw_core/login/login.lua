local passwordCard = {
    type = "AdaptiveCard",
    body = {
        {
        type =  "ColumnSet",
        columns =  {
                    {
                    type =  "Column",
                    items =  {
                        {
                            type =  "Image",
                            url =  "https://forums.pixelworldrp.com/uploads/monthly_2020_05/PW-1024px.thumb.png.bfd4a2f16a7caf9c72a404cc7ed82aea.png",
                            size =  "Small"
                        }
                    },
                    width =  "auto"
                    },
                    {
                    type =  "Column",
                    items =  {
                        {
                            type =  "TextBlock",
                            weight =  "Bolder",
                            text =  "PixelWorld Roleplay",
                            wrap =  true
                        },
                        {
                            type =  "TextBlock",
                            spacing =  "None",
                            text =  "https://www.pixelworldrp.com",
                            isSubtle =  true,
                            wrap =  true
                        }
                    },
                        width =  "stretch"
                    },
                    {
                        type =  "Column",
                        isVisible = false,
                        items =  {
                            {
                                type = "TextBlock",
                                weight = "Bolder",
                                color = "Attention",
                                horizontalAlignment = "Right",
                                text = "Error: Invalid One Time Passcode entered!"
                            },
                        },
                            width =  "stretch"
                        }
            }
        },
      {
        type =  "Container",
        items =  {
          {
            type =  "TextBlock",
            text =  "Enter your One Time Passcode",
            wrap =  true,
            spacing =  "None"
          }
        }
      },
      {
        type =  "Input.Text",
        placeholder =  "OTP",
        inlineAction =  {
          type =  "Action.Submit",
          title =  "Submit"
        },
        spacing =  "Medium",
        id =  "otp"
      }
    },
    version =  "1.0",
    ["$schema"] =  "http://adaptivecards.io/schemas/adaptive-card.json"
  }
--[[
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
]]
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local player = source
    local name = GetPlayerName(player)
    
    deferrals.defer()

    if not serverStarted then
        deferrals.done(string.format("Welcome to PixelWorld %s, The server is still currently starting up please retry connecting in a few minutes.", name))
        repeat Wait(0) until serverStarted == true
    else
        playerConnect(name, setKickReason, deferrals, player)0
    end
end)