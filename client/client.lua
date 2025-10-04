local VORPcore = exports.vorp_core:GetCore()
local FeatherMenu =  exports['feather-menu'].initiate()
local MenuOpened = false
local DefaultWaypoint = vector3(0.000000, 0.000000, 0.000000)  -- DO NOT TOUCH
local WaypointSet = false

----------------- Register Menu ----------------

Citizen.CreateThread(function ()
    ShareWaypointMenu = FeatherMenu:RegisterMenu('ShareWaypointMenu', {
        top = '20%',
        left = '20%',
        ['720width'] = '500px',
        ['1080width'] = '700px',
        ['2kwidth'] = '700px',
        ['4kwidth'] = '800px',
        style = {
            ['border'] = '5px solid orange',
            -- ['background-image'] = 'none',
            ['background-color'] = '#FF8C00'
        },
        contentslot = {
            style = {
                ['height'] = '550px',
                ['min-height'] = '250px'
            }
        },
        draggable = true,
    --canclose = false
}, {
    opened = function()
        --print("MENU OPENED!")
    end,
    closed = function()
        --print("MENU CLOSED!")
    end,
    topage = function(data)
        --print("PAGE CHANGED ", data.pageid)
    end
})
end)

Citizen.CreateThread(function()
    local LastWaypoint = DefaultWaypoint
    while Config.AutoShareWaypoints do
        Citizen.Wait(1500)
        local MyCoords = GetEntityCoords(PlayerPedId())
        local MyWaypoint = GetWaypointCoords()
        if MyWaypoint ~= DefaultWaypoint and MyWaypoint ~= LastWaypoint then
            LastWaypoint = MyWaypoint
            TriggerServerEvent('mms-sharewaypoint:server:GetClosePlayersToAutoshare',MyCoords,MyWaypoint)
        end
    end
end)

RegisterCommand(Config.ShareWaypoint,function()
    local MyWaypoint = GetWaypointCoords()
    local MyCoords = GetEntityCoords(PlayerPedId())
    if MyWaypoint == DefaultWaypoint then
        VORPcore.NotifyRightTip(_U('NoWaypointSet'),5000)
    else
        TriggerServerEvent('mms-sharewaypoint:server:GetClosePlayers',MyCoords,MyWaypoint)
    end
end)

RegisterNetEvent('mms-sharewaypoint:client:SetWaypoint')
AddEventHandler('mms-sharewaypoint:client:SetWaypoint',function(MyWaypoint)
    WaypointSet = true
    StartGpsMultiRoute(GetHashKey("COLOR_YELLOW"), true, true)
    AddPointToGpsMultiRoute(MyWaypoint)
    SetGpsMultiRouteRender(true)
end)

RegisterCommand(Config.ClearSharedWaypoint,function()
    if WaypointSet then
        ClearGpsMultiRoute()
    end
end)

RegisterNetEvent('mms-sharewaypoint:client:OpenMenu')
AddEventHandler('mms-sharewaypoint:client:OpenMenu',function(ClosestCharacters,MyWaypoint)
    if not MenuOpened then
        MenuOpened = true
    elseif MenuOpened then
        ShareWaypointMenu1:UnRegister()
    end
    ShareWaypointMenu1 = ShareWaypointMenu:RegisterPage('seite1')
    ShareWaypointMenu1:RegisterElement('header', {
        value = _U('ShareWaypointMenuHeader'),
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    ShareWaypointMenu1:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    for h,v in ipairs(ClosestCharacters) do
        ShareWaypointMenu1:RegisterElement('button', {
            label =  v.Name,
            style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
            },
        }, function()
            ShareWaypointMenu:Close({})
            Citizen.Wait(250)
            TriggerServerEvent('mms-sharewaypoint:server:ShareWaypointWithUser',v.ServerID,MyWaypoint)
        end)
    end
    ShareWaypointMenu1:RegisterElement('button', {
        label =  _U('ShareWithAllUsers'),
        style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
            },
        }, function()
        ShareWaypointMenu:Close({})
        Citizen.Wait(250)
        TriggerServerEvent('mms-sharewaypoint:server:ShareWaypointWithAllUsers',ClosestCharacters,MyWaypoint)
    end)
    ShareWaypointMenu1:RegisterElement('button', {
        label =  _U('CloseShareWaypointMenu'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        ShareWaypointMenu:Close({ 
        })
    end)
    ShareWaypointMenu1:RegisterElement('subheader', {
        value = _U('ShareWaypointMenuSubHeader'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    ShareWaypointMenu1:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    ShareWaypointMenu:Open({
        startupPage = ShareWaypointMenu1,
    })
end)