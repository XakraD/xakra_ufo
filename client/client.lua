local active = false
local ufo
local cam

function loadAnimDict(dict)
	while (not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Wait(5)
	end
end


RegisterNetEvent('xakra_ufo:UFO')
AddEventHandler('xakra_ufo:UFO', function(item)
    if not active then
        local spawn_ufo = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, 10.0)
        if Config.TypeUFO == 'big' then
            ufo = CreateObject(GetHashKey("s_ufo01x"), spawn_ufo, true, true, true)
        elseif Config.TypeUFO == 'small' then
            ufo = CreateObject(GetHashKey("s_ufo02x"), spawn_ufo, true, true, true)
        end

        SetEntityCollision(ufo, false, false)

        local animDict = "script_story@gng2@ig@ig12_bullard_controls"
        local animName = "calm_looking_up"
        local speed = 8.0 
        local speedX = 3.0 
        local duration = 3000
        local flags = 2
        loadAnimDict(animDict)
        TaskPlayAnim(PlayerPedId(), animDict, animName, speed, speedX, duration, flags, 0, 0, 0, 0 )
        Wait(3000)
    
        local pcoords = GetEntityCoords(PlayerPedId())
        local pheading = GetEntityHeading(PlayerPedId())

        while pcoords.z < spawn_ufo.z do
            pcoords = GetEntityCoords(PlayerPedId())
            SetEntityCoordsNoOffset(PlayerPedId(), pcoords.x, pcoords.y, pcoords.z + 0.03, pheading, 0.0, 0.0)
            Wait(0)
        end

        local bone = GetEntityBoneIndexByName(PlayerPedId(), "OH_TorsoDir")
        AttachEntityToEntity(PlayerPedId(), ufo, bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

        if Config.TypeUFO == 'small' then
            SetEntityVisible(PlayerPedId(), false, false)
        end

        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

        if Config.TypeUFO == 'big' then
            AttachCamToEntity(cam , ufo, 0.0, -18.0, 8.0, true)
        elseif Config.TypeUFO == 'small' then
            AttachCamToEntity(cam , ufo, 0.0, -8.0, 3.0, true)   
        end

        RenderScriptCams(true, true, 0, 1, 0)

        active = true

    elseif active then
        if DoesCamExist(cam) then
            DestroyCam(cam)
        end

        SetEntityVisible(PlayerPedId(), true, true)
        DetachEntity(PlayerPedId(), true, false)

        local ufo_coords = GetEntityCoords(ufo)
        
        local _, ground = GetGroundZAndNormalFor_3dCoord(ufo_coords.x, ufo_coords.y, ufo_coords.z + 100)

        local ufo_heading = GetEntityHeading(ufo)
        local pcoords = GetEntityCoords(PlayerPedId())

        while pcoords.z > ground + 1.5 do
            pcoords = GetEntityCoords(PlayerPedId())
            SetEntityCoordsNoOffset(PlayerPedId(), pcoords.x, pcoords.y, pcoords.z - 0.03, ufo_heading, 0.0, 0.0)
            Wait(0)
        end

        TriggerServerEvent('xakra_ufo:SubItem', item)
        active = false

        Wait(5000)
        DeleteEntity(ufo)
    end
end)

local UpPrompt, DownPrompt, SpeedPrompt, MovePrompts
local Prompts = GetRandomIntInRange(0, 0xffffff)

Citizen.CreateThread(function()
    local str = 'Up'
    UpPrompt = PromptRegisterBegin()
    PromptSetControlAction(UpPrompt, Config.Controls.goUp)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(UpPrompt, str)
    PromptSetEnabled(UpPrompt, true)
    PromptSetVisible(UpPrompt, true)
	PromptSetStandardMode(UpPrompt, true)
	PromptSetGroup(UpPrompt, Prompts)
	PromptRegisterEnd(UpPrompt)

    local str = 'Down'
    DownPrompt = PromptRegisterBegin()
    PromptSetControlAction(DownPrompt, Config.Controls.goDown)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(DownPrompt, str)
    PromptSetEnabled(DownPrompt, true)
    PromptSetVisible(DownPrompt, true)
	PromptSetStandardMode(DownPrompt, true)
	PromptSetGroup(DownPrompt, Prompts)
	PromptRegisterEnd(DownPrompt)

    local str = 'Speed'
    SpeedPrompt = PromptRegisterBegin()
    PromptSetControlAction(SpeedPrompt, Config.Controls.changeSpeed)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(SpeedPrompt, str)
    PromptSetEnabled(SpeedPrompt, true)
    PromptSetVisible(SpeedPrompt, true)
	PromptSetStandardMode(SpeedPrompt, true)
	PromptSetGroup(SpeedPrompt, Prompts)
	PromptRegisterEnd(SpeedPrompt)

    local str = 'Move'
    MovePrompts = PromptRegisterBegin()
    PromptSetControlAction(MovePrompts, Config.Controls.turnLeft)
    PromptSetControlAction(MovePrompts, Config.Controls.turnRight)
    PromptSetControlAction(MovePrompts, Config.Controls.goForward)
    PromptSetControlAction(MovePrompts, Config.Controls.goBackward)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(MovePrompts, str)
    PromptSetEnabled(MovePrompts, true)
    PromptSetVisible(MovePrompts, true)
	PromptSetStandardMode(MovePrompts, true)
	PromptSetGroup(MovePrompts, Prompts)
	PromptRegisterEnd(MovePrompts)
end)

Citizen.CreateThread(function()
    local index = 1
    local CurrentSpeed = Config.Speeds[index].speed

    while true do
        local t = 500
        if active then
            t = 0

            local label  = CreateVarString(10, 'LITERAL_STRING', 'UFO')
            PromptSetActiveGroupThisFrame(Prompts, label)

            local yoff = 0.0
            local zoff = 0.0

            if Config.TypeUFO == 'big' then
                SetCamRot(cam, -5.0, 0.0, GetEntityHeading(ufo))
            elseif Config.TypeUFO == 'small' then
                SetCamRot(cam, -1.0, 0.0, GetEntityHeading(ufo))   
            end

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

            local ufo_coords = GetEntityCoords(ufo)
            local _, ground = GetGroundZAndNormalFor_3dCoord(ufo_coords.x, ufo_coords.y, ufo_coords.z + 100)

            local newPos = GetOffsetFromEntityInWorldCoords(ufo, 0.0, yoff * (CurrentSpeed + 0.3), zoff * (CurrentSpeed + 0.3))

            if ufo_coords.z < ground + 1.0 then
                SetEntityCoordsNoOffset(ufo, newPos.x, newPos.y, ground + 1.0, 0.0, 0.0, 0.0)
            else
                SetEntityCoordsNoOffset(ufo, newPos, 0.0, 0.0, 0.0)
            end
        end

        Wait(t)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    if DoesCamExist(cam) then
        DestroyCam(cam)
    end

    SetEntityVisible(PlayerPedId(), true, true)
    DeleteEntity(ufo)
end)


