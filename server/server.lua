
local RSGCore = exports['rsg-core']:GetCoreObject()

RegisterServerEvent("ElectricChair:MakePrisonerSit")
AddEventHandler("ElectricChair:MakePrisonerSit", function(closestPlayer, ClosestPlayers, PrisonerSource, PrisonerPed)
    local PlayersSource = ClosestPlayers
    for _,__ in pairs(PlayersSource) do
        TriggerClientEvent('ElectricChair:SyncChairAnim', __, PrisonerPed)
    end
    TriggerClientEvent('ElectricChair:SitInChair', closestPlayer)
end)

RegisterNetEvent('ElectricChair:SyncFX')
AddEventHandler('ElectricChair:SyncFX', function(players, prisonerSource)
    for _, id in pairs(players) do
        TriggerClientEvent('ElectricChair:SyncedFX', id, prisonerSource)
    end
end)


RegisterServerEvent("ElectricChair:Kill")
AddEventHandler("ElectricChair:Kill", function(ClosestPlayer)
    TriggerClientEvent('ElectricChair:KillMe', ClosestPlayer)
end)