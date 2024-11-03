local categories = {}

-- Fonction pour créer le blip (icône bateau + nom "Concessionnaire Bateau") sur les coordonnées en config
local function createBlip()
    local blipId = AddBlipForCoord(Config.Position.x, Config.Position.y, Config.Position.z)

    SetBlipFlashes(blipId, false)
    SetBlipSprite(blipId, 356)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName("Concessionnaire Bateau")
    EndTextCommandSetBlipName(blipId)

    return blipId
end

-- Fonction pour créer le thread qui gère le marker ainsi que le popup d'aide et l'ouverture du menu
local function createZone()
    CreateThread(function()
        while true do
            Wait(0)

            -- Créer le marker
            DrawMarker(23, Config.Position.x, Config.Position.y, Config.Position.z - 0.95, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 22, 253, 115, 128, false, true, 2, false, nil, nil, false)


            -- Popup d'aide si le joueur est proche
            local currentPos = GetEntityCoords(PlayerPedId())
            local distance = #(currentPos - Config.Position)

            if distance < 1 and table_size(ESX.UI.Menu.GetOpenedMenus()) == 0 then
                ESX.ShowHelpNotification("~INPUT_CONTEXT~ Accéder au concessionnaire", true, true, -1)

                if IsControlJustReleased(0, 51) then
                    OpenBoatBuyMenuCategories(categories)
                end
            end
        end
    end)
end

-- On appelle les fonctions pour créer les visuels
local blipId = createBlip()
createZone()

-- En cas de shutdown du script, on supprime le blip
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    RemoveBlip(blipId)
end)

-- On demande la liste des bateaux quelques secondes après que le client se soit connecté
AddEventHandler('onClientResourceStart', function(resource)
    if resource == GetCurrentResourceName() then

        Wait(2000)

        TriggerServerEvent('cali-test-bateau:request_boat_list')
    end
end)

-- On reçoit la liste des zones, on peut enfin créer les peds
RegisterNetEvent('cali-test-bateau:boat_list', function(data)
    categories = data
end)

-- Event utilitaire pour que le serveur puisse récupérer les données du véhicule en train de spawn
-- Seul le client a cette information donc on est obligé de passer par le client pour la récupérer
RegisterNetEvent('cali-test-bateau:request_vehicle_data', function(plate, vehicleNetworkId)
    TriggerServerEvent('cali-test-bateau:vehicle_data', plate, ESX.Game.GetVehicleProperties(NetworkGetEntityFromNetworkId(vehicleNetworkId)))
end)