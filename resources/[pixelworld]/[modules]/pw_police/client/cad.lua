function openPoliceCadSystem(bool, cid)
    SetNuiFocus(bool, bool) -- focus, cursor
        if bool == true then
            SendNUIMessage({action = "showTablet", cid = cid})
        else
            SendNUIMessage({action = "hideTablet"})
        end
    return bool
end