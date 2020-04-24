local createdShape
local drawShape = false

RegisterNetEvent("polyzone:polystart")
AddEventHandler("polyzone:polystart", function(name)
  if createdShape ~= nil then exports.pw_notify:SendAlert('error', 'A shape is already being created!', 5000); return; end

  local coords = GetEntityCoords(PlayerPedId())

  createdShape = {
    points = {vector2(coords.x, coords.y)},
    options = {minZ = coords.z, maxZ = coords.z, name = tostring(name)}
  }

  drawShape = true
  drawThread()
end)

RegisterNetEvent("polyzone:polyadd")
AddEventHandler("polyzone:polyadd", function()
  if createdShape == nil then
    return
  end

  local coords = GetEntityCoords(PlayerPedId())

  if (coords.z > createdShape.options.maxZ) then
    createdShape.options.maxZ = coords.z
  end

  if (coords.z < createdShape.options.minZ) then
    createdShape.options.minZ = coords.z
  end

  createdShape.points[#createdShape.points + 1] = vector2(coords.x, coords.y)
end)

RegisterNetEvent("polyzone:polyundo")
AddEventHandler("polyzone:polyundo", function()
  if createdShape == nil then
    return
  end

  createdShape.points[#createdShape.points] = nil
end)

RegisterNetEvent("polyzone:polyfinish")
AddEventHandler("polyzone:polyfinish", function()
  if createdShape == nil then
    return
  end

  TriggerServerEvent("polyzone:printShape", createdShape)

  exports.pw_notify:SendAlert('inform', 'Check your server root folder for polyzone_created_shapes.txt to get the shape!', 5000)

  drawShape = false
  createdShape = nil
end)

RegisterNetEvent("polyzone:polycancel")
AddEventHandler("polyzone:polycancel", function()
  if createdShape == nil then
    return
  end

  exports.pw_notify:SendAlert('inform', 'Shape creation canceled!', 5000)

  drawShape = false
  createdShape = nil
end)

-- Drawing
function drawThread()
  Citizen.CreateThread(function()
    while drawShape do
      PolyZone.drawPoly(createdShape, {drawPoints=true})
      Citizen.Wait(1)
    end
  end)
end