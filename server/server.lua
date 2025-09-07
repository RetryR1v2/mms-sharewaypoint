-- Server Side
local VORPcore = exports.vorp_core:GetCore()

RegisterServerEvent('mms-sharewaypoint:server:GetClosePlayers',function(MyCoords,MyWaypoint)
    local src = source
    local ClosestCharacters = {}
    local PlayersNear = 0
    for h,v in ipairs(GetPlayers()) do
        local Ped = GetPlayerPed(v)
        local Coords = GetEntityCoords(Ped)
        local Distance = #(Coords - MyCoords)
        local Character = VORPcore.getUser(v).getUsedCharacter
        local Name = Character.firstname .. ' ' .. Character.lastname
        local ServerID = v
        if Distance <= Config.ShareWaypointRange then
            PlayersNear = PlayersNear + 1
            Data = { Name = Name, ServerID = ServerID }
            table.insert(ClosestCharacters,Data)
            TriggerClientEvent('mms-sharewaypoint:client:OpenMenu',src,ClosestCharacters,MyWaypoint)
        end
    end
    if PlayersNear == 0 then
        VORPcore.NotifyRightTip(src,_U('NoOneNear'),5000)
    end
end)

RegisterServerEvent('mms-sharewaypoint:server:ShareWaypointWithUser',function(ServerID,MyWaypoint)
    TriggerClientEvent('mms-sharewaypoint:client:SetWaypoint',ServerID,MyWaypoint)
end)