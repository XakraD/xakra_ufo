local active = false
local ufo
local cam

RegisterNetEvent('xakra_ufo:UFO')
AddEventHandler('xakra_ufo:UFO', function(item)
    local player = PlayerPedId()

    if not active then
        DisableControlAction(0, 0xB238FE0B, true)
        DisableControlAction(0, 0x3C0A40F2, true)

        local spawn_ufo = GetOffsetFromEntityInWorldCoords(player, 0.0, 0.0, 10.0)
        if Config.TypeUFO == 'big' then
            ufo = CreateObject(GetHashKey("s_ufo01x"), spawn_ufo, true, true, true)
        elseif Config.TypeUFO == 'small' then
            ufo = CreateObject(GetHashKey("s_ufo02x"), spawn_ufo, true, true, true)
        end

        local animDict = "script_story@gng2@ig@ig12_bullard_controls"
        local animName = "calm_looking_up"
        local speed = 8.0 
        local speedX = 3.0 
        local duration = 3000
        local flags = 2
        RequestAnimDict(animDict)
        TaskPlayAnim(PlayerPedId(), animDict, animName, speed, speedX, duration, flags, 0, 0, 0, 0 )
        Citizen.Wait(3000)
        
        local pcoords = GetEntityCoords(player, true)
        local high = 0
        while high < 10 do
            Wait(40)
            SetEntityCoordsNoOffset(player, pcoords.x, pcoords.y, pcoords.z + high, false, false, false)
            high = high + 0.08
        end

        local bone = GetEntityBoneIndexByName(player, "OH_TorsoDir")
        AttachEntityToEntity(player, ufo, bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
        FreezeEntityPosition(player, true)

        if Config.TypeUFO == 'small' then
            SetEntityVisible(player, false, false)
        end

        active = true

        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    elseif active then
        DestroyAllCams(true)

        SetEntityVisible(player, true, true)
        DetachEntity(player, true, false)

        local ufo_coords = GetEntityCoords(ufo)
        local pcoords = GetEntityCoords(player, true)
        local _,ground = GetGroundZAndNormalFor_3dCoord(ufo_coords.x, ufo_coords.y, ufo_coords.z)

        local high = 0
        local high_ground = ufo_coords.z - ground

        while high < high_ground-1 do
            Wait(40)
            SetEntityCoordsNoOffset(player, pcoords.x, pcoords.y, pcoords.z - high, false, false, false)
            high = high + 0.08
        end

        FreezeEntityPosition(player, false)
        DisableControlAction(0, 0xB238FE0B, false)
        DisableControlAction(0, 0x3C0A40F2, false)
        DeleteEntity(ufo)
        active = false

        TriggerServerEvent('xakra_ufo:SubItem', item)

        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    end
end)

Citizen.CreateThread(function()
    local player = PlayerPedId()
    local index = 1
    local CurrentSpeed = Config.Speeds[index].speed

    while true do
        local t = 4
        if active then
            local yoff = 0.0
            local zoff = 0.0

            if Config.TypeUFO == 'big' then
                AttachCamToEntity(cam , ufo, 0.0, -18.0, 8.0, true)
                SetCamRot(cam, -5.0,0.0,GetEntityHeading(ufo))
            elseif Config.TypeUFO == 'small' then
                AttachCamToEntity(cam , ufo, 0.0, -8.0, 3.0, true)
                SetCamRot(cam, -1.0,0.0,GetEntityHeading(ufo))   
            end
            RenderScriptCams(true, true, 0, 1, 0)

            if IsDisabledControlJustPressed(1, Config.Controls.changeSpeed) then
                timer = 2000
                if index ~= #Config.Speeds then
                    index = index + 1
                    CurrentSpeed = Config.Speeds[index].speed
                else
                    CurrentSpeed = Config.Speeds[1].speed
                    index = 1
                end

            end
            if IsDisabledControlPressed(0, Config.Controls.goForward) then
                yoff = Config.Offsets.y
            end

            if IsDisabledControlPressed(0, Config.Controls.goBackward) then
                yoff = -Config.Offsets.y
            end

            if IsDisabledControlPressed(0, Config.Controls.turnLeft) then
                SetEntityHeading(ufo, GetEntityHeading(ufo) + Config.Offsets.h)
            end

            if IsDisabledControlPressed(0, Config.Controls.turnRight) then
                SetEntityHeading(ufo, GetEntityHeading(ufo) - Config.Offsets.h)
            end

            if IsDisabledControlPressed(0, Config.Controls.goUp) then
                zoff = Config.Offsets.z
            end

            if IsDisabledControlPressed(0, Config.Controls.goDown) then
                zoff = -Config.Offsets.z
            end
            local newPos = GetOffsetFromEntityInWorldCoords(ufo, 0.0, yoff * (CurrentSpeed + 0.3), zoff * (CurrentSpeed + 0.3))
            local heading = GetEntityHeading(ufo)
            SetEntityHeading(ufo, heading)
            SetEntityCoordsNoOffset(ufo, newPos.x, newPos.y, newPos.z, active, active, active)
        else
            t = 500
        end
        Citizen.Wait(t)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
      end
    DestroyAllCams(true)
    SetEntityVisible(PlayerPedId(), true, true)
    FreezeEntityPosition(PlayerPedId(), false)
    DeleteEntity(ufo)
    DisableControlAction(0, 0xB238FE0B, false)
    DisableControlAction(0, 0x3C0A40F2, false)
end)


