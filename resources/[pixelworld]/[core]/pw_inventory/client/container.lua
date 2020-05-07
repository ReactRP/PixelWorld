local isLoggedIn = false
local dropsNear = {}
local containerList = {}
containerId = nil

local containers = {
    [666561306] = true,
    [218085040] = true,
    [-58485588] = true,
    [682791951] = true,
    [-206690185] = true,
    [364445978] = true,
    [143369] = true,
    [1511880420] = true,
}

function openContainer()
    if containerId ~= nil then
        PWBase.Inventory.Open:Third(containerList[containerId])
    end
end

function ScanContainer() 
    local player = PlayerPedId()
    local startPos = GetOffsetFromEntityInWorldCoords(player, 0, 0.1, 0)
    local endPos = GetOffsetFromEntityInWorldCoords(player, 0, 3.0, 0.4)

    local rayHandle = StartShapeTestRay(startPos, endPos, 16, 0, 0)
    local a, b, c, d, result = GetShapeTestResult(rayHandle)

    if hitData ~= 2 then
        if containers[GetEntityModel(result)] ~= nil then
            if DecorExistOn(result, 'Container-Inventory') then
                containerId = DecorGetInt(result, 'Container-Inventory')
            else
                containerId = #containerList + 1
                DecorSetInt(result, 'Container-Inventory', containerId)
                table.insert(containerList, { type = 3, owner = containerId })
            end

            return containerList[containerId]
        end
    end
end