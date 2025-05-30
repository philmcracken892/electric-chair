local RSGCore = exports['rsg-core']:GetCoreObject()

local PromptGroup1 = GetRandomIntInRange(0, 0xffffff) 
local PromptGroup2 = GetRandomIntInRange(0, 0xffffff) 

local PlayerJob
local ShockValue = 10
local Electrocuting = false
local NotPressed = false
local PrisonerSeated = false

local PrisonerPed
local PrisonerSource
local ElectricHelmet = nil

local EntitiesIds = { }

-- New FX variables - Using RDR2 compatible effects
local fx_group = "scr_dm_ftb"
local fx_name = "scr_mp_chest_spawn_smoke"
local fx_scale = 1.0

Citizen.CreateThread(function()
    Citizen.Wait(2000)
    local str = Config.Chair
	arrestprisoner = PromptRegisterBegin()
	PromptSetControlAction(arrestprisoner, 0x5415BE48) -- add to config
	str = CreateVarString(10, 'LITERAL_STRING', str)
	PromptSetText(arrestprisoner, str)
	PromptSetEnabled(arrestprisoner, 1)
	PromptSetVisible(arrestprisoner, 1)
	PromptSetStandardMode(arrestprisoner, 1)
    PromptSetHoldMode(arrestprisoner, 1)
	PromptSetGroup(arrestprisoner, PromptGroup1)
	PromptRegisterEnd(arrestprisoner)

    local str = Config.Shock
	electrocute = PromptRegisterBegin()
	PromptSetControlAction(electrocute, 0x5415BE48) -- add to config
	str = CreateVarString(10, 'LITERAL_STRING', str)
	PromptSetText(electrocute, str)
	PromptSetEnabled(electrocute, 1)
	PromptSetVisible(electrocute, 1)
	PromptSetStandardMode(electrocute, 1)
    PromptSetHoldMode(electrocute, 1)
	PromptSetGroup(electrocute, PromptGroup2)
	PromptRegisterEnd(electrocute)

    local str = Config.Increase
	increasepower = PromptRegisterBegin()
	PromptSetControlAction(increasepower, 0x6319DB71) -- add to config
	str = CreateVarString(10, 'LITERAL_STRING', str)
	PromptSetText(increasepower, str)
	PromptSetEnabled(increasepower, 1)
	PromptSetVisible(increasepower, 1)
	PromptSetStandardMode(increasepower, 1)
    PromptSetHoldMode(increasepower, 1)
	PromptSetGroup(increasepower, PromptGroup2)
	PromptRegisterEnd(increasepower)

    local str = Config.Decrease
	decreasepower = PromptRegisterBegin()
	PromptSetControlAction(decreasepower, 0x05CA7C52) -- add to config
	str = CreateVarString(10, 'LITERAL_STRING', str)
	PromptSetText(decreasepower, str)
	PromptSetEnabled(decreasepower, 1)
	PromptSetVisible(decreasepower, 1)
	PromptSetStandardMode(decreasepower, 1)
    PromptSetHoldMode(decreasepower, 1)
	PromptSetGroup(decreasepower, PromptGroup2)
	PromptRegisterEnd(decreasepower)
end)

Citizen.CreateThread(function()
    while true do Wait(5000)
        local Ped = PlayerPedId()
        local PCoord = GetEntityCoords(Ped)
        for _,__ in pairs(Config.Zones) do
            local Dist = Vdist(PCoord - __.ChairCoord)
            if Dist <= __.SpawnRange then
                if not __.ChairSpawn and not __.GenSpawn then
                    Generator = CreateObject('p_cs_generator01x', __.GeneratorCoord.x, __.GeneratorCoord.y, __.GeneratorCoord.z, false, false, false)
                    Chair = CreateObject('p_cs_electricchair01x', __.ChairCoord.x, __.ChairCoord.y, __.ChairCoord.z, false, false, false)
                    table.insert(EntitiesIds, Generator)
                    table.insert(EntitiesIds, Chair)
                    __.ChairId = Chair
                    __.GeneratorId = Generator
                    __.GenSpawn = true
                    __.ChairSpawn = true
                    SetEntityCollision(Chair, false, true)
                end
            end
            if Dist > __.SpawnRange then
                if __.ChairSpawn and __.GenSpawn then
                    local GenExist = DoesEntityExist(__.ChairId)
                    local ChairExist = DoesEntityExist(__.GeneratorId)
                    if GenExist then
                        DeleteEntity(__.ChairId)
                    end
                    if ChairExist then
                        DeleteEntity(__.GeneratorId)
                    end
                    __.GenSpawn = false
                    __.ChairSpawn = false
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    local Optimizer = 5000
    while true do Wait(Optimizer)
        local Ped = PlayerPedId()
        local PCoord = GetEntityCoords(Ped)
        local Chair = GetClosestObjectOfType(PCoord, 20.0, GetHashKey('p_cs_electricchair01x'), false, false, false)
        local ChairCoord = GetEntityCoords(Chair)
        local Dist = Vdist(PCoord - ChairCoord)
        local Generator = GetClosestObjectOfType(PCoord, 20.0, GetHashKey('p_cs_generator01x'), false, false, false)
        local GeneratorCoord = GetEntityCoords(Generator)
        local Dist2 = Vdist(PCoord - GeneratorCoord)
        if Dist <= 2 then
            if PlayerJob == Config.Job and not NotPressed then
                Optimizer = 5
                local label = CreateVarString(10, 'LITERAL_STRING', Config.ChairName)
                PromptSetActiveGroupThisFrame(PromptGroup1, label)
                if Citizen.InvokeNative(0xE0F65F0640EF0617, arrestprisoner) then
                    NotPressed = true
                    ArrestPrisoner()
                    Wait(5000)
                    NotPressed = false
                end
            end
        end
        if Dist2 <= 2 then
            if PlayerJob == Config.Job and not Electrocuting and PrisonerSeated then
                Optimizer = 5
                local Color = '~COLOR_GREENLIGHT~'
                if ShockValue <= 30 then
                    Color = '~COLOR_GREENLIGHT~'
                elseif ShockValue > 30 and ShockValue <= 60 then
                    Color = '~COLOR_YELLOWSTRONG~'
                elseif ShockValue > 60 then
                    Color = '~COLOR_RED~'
                end
                local str = Config.Shock.. ' ' .. Color .. ShockValue .. '%'
	            str = CreateVarString(10, 'LITERAL_STRING', str)
                PromptSetText(electrocute, str)
                local label = CreateVarString(10, 'LITERAL_STRING', Config.GeneratorName)
                PromptSetActiveGroupThisFrame(PromptGroup2, label)
                if Citizen.InvokeNative(0xE0F65F0640EF0617, electrocute) then
                    if ShockValue >= 70 then
                        ElectrocuteKill()
                        TriggerServerEvent('ElectricChair:Kill', PrisonerSource)
                        PrisonerSeated = false
                    end
                    Electrocute()
                    local ShockVolume = 0
                    if ShockValue <= 30 then
                        ShockVolume = 4.0
                    elseif ShockValue > 30 and ShockValue <= 60 then
                        ShockVolume = 4.0
                    elseif ShockValue > 60 then
                        ShockVolume = 4.0
                    end
                    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 30, 'shock', ShockVolume)
					Wait(1000)
					TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 30, 'scream', ShockVolume)
                    Electrocuting = true
                    Wait(2000)
                    Electrocuting = false
                end
                if Citizen.InvokeNative(0xC92AC953F0A982AE, increasepower) then
                    if ShockValue < 100 then
                        ShockValue = ShockValue + 10
                    end
                end
                if Citizen.InvokeNative(0xC92AC953F0A982AE, decreasepower) then
                    if  ShockValue ~= 10 then
                        ShockValue = ShockValue - 10
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('RSGCore:Client:OnPlayerLoaded', function()
    PlayerJob = RSGCore.Functions.GetPlayerData().job.name
end)

RegisterNetEvent('RSGCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo.name
end)

RegisterNetEvent("ElectricChair:SitInChair")
AddEventHandler("ElectricChair:SitInChair", function()
    local Ped = PlayerPedId()
    local PCoord = GetEntityCoords(Ped)

    local chair = GetClosestObjectOfType(PCoord, 2.0, GetHashKey('p_cs_electricchair01x'), false, false, false)
    local chairHeading = GetEntityHeading(chair)

    local chaircoords = GetOffsetFromEntityInWorldCoords(chair, 0.00, 0.00, 0.45)

    SetEntityCoords(Ped, chaircoords)
    SetEntityHeading(Ped, chairHeading + 180.0)

    Wait(1000)

    -- Create and attach electric helmet
	local pedCoords = GetEntityCoords(Ped)
	ElectricHelmet = CreateObject('p_cs_electrichelmet01x', pedCoords.x, pedCoords.y, pedCoords.z, true, true, false)
	AttachEntityToEntity(ElectricHelmet, Ped, GetPedBoneIndex(Ped, 21030), 0.15, 0.0, 0.0, 0.0, -90.0, -170.0, false, false, false, false, 2, true)
	table.insert(EntitiesIds, ElectricHelmet)
    local animDict2 = "script_rc@rtl@leadout@rc_6"
    local anim2 = "leadout_alive_prisoner"
    while not HasAnimDictLoaded(animDict2) do
        RequestAnimDict(animDict2)
        Wait(50)
    end
    TaskPlayAnim(PlayerPedId(), animDict2, anim2, 1.0, 1.0, -1, 1, 0, 0, 0, 0)
end)

RegisterNetEvent("ElectricChair:SyncChairAnim")
AddEventHandler("ElectricChair:SyncChairAnim", function(PrisonerSource, PrisonerPed)
    local coords = GetEntityCoords(PlayerPedId())
    local chair = GetClosestObjectOfType(coords, 22.0, GetHashKey('p_cs_electricchair01x'), false, false, false)

    local animDict = "script_rc@rtl@leadin@rc_6"
    local anim = "leadin_chair"
    while not HasAnimDictLoaded(animDict) do
        RequestAnimDict(animDict)
        Wait(50)
    end
    PlayEntityAnim(chair, anim, animDict, 8.0, false, true, false, 0.0, 0)
end)

RegisterNetEvent("ElectricChair:SyncedFX")
AddEventHandler("ElectricChair:SyncedFX", function(prisonerSource)
    local PrisonerPed = GetPlayerPed(GetPlayerFromServerId(prisonerSource))
    if not DoesEntityExist(PrisonerPed) then
        return
    end

    -- Original electric arc effects
    local ptfxDict = "cut_rrtl"
    local ptfxName = "cs_rrtl_electric_arcs"

    local boneList = {
        21030, -- Head
        37873, -- Right Hand
        36029, -- Left Hand
        14201, -- Right Foot
        65245, -- Left Foot
        24818  -- Spine (optional)
    }

    local scale = 2.0
    if ShockValue > 30 and ShockValue <= 60 then
        scale = 2.5
    elseif ShockValue > 60 then
        scale = 3.0
    end
	
	-- Flash effect
	local flashHandle = Citizen.InvokeNative(
    0x9C56621462FFE7A6,
    "scr_re_rhf_elec_flash",
    PrisonerPed,
    0.0, 0.0, 0.3,
    0.0, 0.0, 0.0,
    24818, -- Spine
    1.5,
    false, false, false
	)

    -- Load original electric arc dictionary
    local dictHash = GetHashKey(ptfxDict)
    if not Citizen.InvokeNative(0x65BB72F29138F5D6, dictHash) then
        Citizen.InvokeNative(0xF2B2353BBC0D4E8F, dictHash)
        local timeout = 0
        while not Citizen.InvokeNative(0x65BB72F29138F5D6, dictHash) and timeout < 5000 do
            Citizen.Wait(10)
            timeout += 10
        end
    end

    -- Load original electric arc dictionary
    local dictHash = GetHashKey(ptfxDict)
    if not Citizen.InvokeNative(0x65BB72F29138F5D6, dictHash) then
        Citizen.InvokeNative(0xF2B2353BBC0D4E8F, dictHash)
        local timeout = 0
        while not Citizen.InvokeNative(0x65BB72F29138F5D6, dictHash) and timeout < 5000 do
            Citizen.Wait(10)
            timeout += 10
        end
    end

    -- Add smoke effect (independent of electric arc loading)
    local prisonerCoords = GetEntityCoords(PrisonerPed)
    local fxcoords = vector3(prisonerCoords.x, prisonerCoords.y, prisonerCoords.z + 0.5)
    UseParticleFxAsset(fx_group)
    local smoke = StartParticleFxNonLoopedAtCoord(fx_name, fxcoords, 0.0, 0.0, 0.0, fx_scale, false, false, false, true)

    if Citizen.InvokeNative(0x65BB72F29138F5D6, dictHash) then
        Citizen.InvokeNative(0xA10DB07FC234DD12, ptfxDict)

        local activeFx = {}

        for _, bone in ipairs(boneList) do
            local fxHandle = Citizen.InvokeNative(
                0x9C56621462FFE7A6, 
                ptfxName,
                PrisonerPed,
                0.0, 0.0, 0.1,      
                -90.0, 0.0, 0.0,    
                bone,
                scale,
                false, false, false
            )
            if fxHandle then
                table.insert(activeFx, fxHandle)
            end
        end

        Wait(4000)

        -- Clean up electric arc effects
        for _, fxHandle in ipairs(activeFx) do
            if Citizen.InvokeNative(0x9DD5AFF561E88F2A, fxHandle) then 
                Citizen.InvokeNative(0x459598F579C98929, fxHandle, false) 
            end
        end
    end
end)

RegisterNetEvent("ElectricChair:KillMe")
AddEventHandler("ElectricChair:KillMe", function()
    -- Remove helmet before death
    if ElectricHelmet and DoesEntityExist(ElectricHelmet) then
        DeleteEntity(ElectricHelmet)
        ElectricHelmet = nil
    end
    ApplyDamageToPed(PlayerPedId(), 10000, true, 54890, PlayerPedId())
end)

RegisterNetEvent("ElectricChair:RemoveHelmet")
AddEventHandler("ElectricChair:RemoveHelmet", function()
    if ElectricHelmet and DoesEntityExist(ElectricHelmet) then
        DeleteEntity(ElectricHelmet)
        ElectricHelmet = nil
    end
end)

_IsAnimSceneLoaded = function(animscene)
	return Citizen.InvokeNative(0x477122B8D05E7968, animscene, 1, 0)
end

function ArrestPrisoner()
    local Ped = PlayerPedId()
    local PCoord = GetEntityCoords(Ped)
    local closestPlayer, closestDistance = GetClosestPlayer()
    local ClosestPlayers = GetClosestPlayers()
    if closestPlayer ~= -1 and closestDistance <= 2 then
        PrisonerPed = GetPlayerPed(closestPlayer)
        PrisonerSource = GetPlayerServerId(closestPlayer)
        TriggerServerEvent('ElectricChair:MakePrisonerSit', GetPlayerServerId(closestPlayer), ClosestPlayers, PrisonerSource, PrisonerPed)
        PrisonerSeated = true
    else
        
    end
end

function Electrocute()
    local ClosestPlayers = GetClosestPlayers()
    if PrisonerSource then
        TriggerServerEvent('ElectricChair:SyncFX', ClosestPlayers, PrisonerSource)
        lib.notify({
            title = 'Electric Chair',
            description = 'Shock administered!',
            type = 'inform'
        })
    end
end

function ElectrocuteKill()
    local ClosestPlayers = GetClosestPlayers()
    if PrisonerSource then
        TriggerServerEvent('ElectricChair:SyncFX', ClosestPlayers, PrisonerSource)
        lib.notify({
            title = ' Fatal Shock',
            description = 'Prisoner has been executed!',
            type = 'error',
            duration = 5000
        })
    end
end

function GetClosestPlayers()
    local Ped = PlayerPedId()
    local PCoord = GetEntityCoords(Ped)
    local players = GetActivePlayers()
    local PCPlayers = { }
    for _,__ in pairs(players) do
        local PCCoord = GetEntityCoords(GetPlayerPed(__))
        local Dist = Vdist(PCoord - PCCoord)
        if Dist <= 40 then
            table.insert(PCPlayers, GetPlayerServerId(__))
        end
    end
    return PCPlayers
end

function GetClosestPlayer()
	local players, closestDistance, closestPlayer = GetActivePlayers(), -1, -1
	local playerPed, playerId = PlayerPedId(), PlayerId()
	local coords, usePlayerPed = coords, false

	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		usePlayerPed = true
		coords = GetEntityCoords(playerPed)
	end

	for i = 1, #players, 1 do
		local tgt = GetPlayerPed(players[i])

		if not usePlayerPed or (usePlayerPed and players[i] ~= playerId) then

			local targetCoords = GetEntityCoords(tgt)
			local distance = #(coords - targetCoords)

			if closestDistance == -1 or closestDistance > distance then
				closestPlayer = players[i]
				closestDistance = distance
			end
		end
	end
	return closestPlayer, closestDistance
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    print('The resource ' .. resourceName .. ' was stopped.')
    for k, v in pairs(EntitiesIds) do
        local Exist = DoesEntityExist(v)
        if Exist then
            DeleteEntity(v)
        end
    end
end)
