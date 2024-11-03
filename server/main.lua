local categories = MySQL.query.await("SELECT * FROM boat_vehicles_categories")
local vehicles = MySQL.query.await("SELECT * FROM boat_vehicles")

local data = {}
local vehicleByModel = {}
local spawningVehicles = {}

for _, category in pairs(categories) do
    data[category.id] = {
        Name = category.name,
        Vehicles = {}
    }
end

for _, vehicle in pairs(vehicles) do
    local category = data[vehicle.category]
    if category ~= nil then
        local vehicleData = {
            Name = vehicle.name,
            Model = vehicle.model,
            Price = vehicle.price,
            Stock = vehicle.stock
        }

        table.insert(category.Vehicles, vehicleData)

        vehicleByModel[vehicle.model] = vehicleData
    end
end

-- Répond aux requêtes des zones pour que les clients soient au courant des zones
RegisterNetEvent('cali-test-bateau:request_boat_list', function()
    ---@diagnostic disable-next-line: param-type-mismatch
    TriggerClientEvent('cali-test-bateau:boat_list', source, data)
end)

-- Event qui gère l'achat et le spawn du véhicule acheté
RegisterNetEvent('cali-test-bateau:buy_boat', function(vehicleModel)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local vehicleData = vehicleByModel[vehicleModel]

    if xPlayer == nil or vehicleData == nil then
        return
    end

    -- Petite confirmation de si le joueur a l'argent pour acheter le véhicule
    if xPlayer.getMoney() < vehicleData.Price then
        xPlayer.showNotification("Vous n'avez pas assez d'argent pour acheter ce véhicule", "error")
        return
    end

    CreateThread(function ()
        local plate

        -- Création d'une plaque qui n'existe pas
        while true do
            plate = "CRP" .. math.random(0, 9) .. math.random(0, 9) .. math.random(0, 9) .. math.random(0, 9) .. math.random(0, 9)

            if MySQL.prepare.await("SELECT plate FROM owned_vehicles WHERE plate = ?", {plate}) == nil and not table_containsValue(spawningVehicles, plate) then
                break
            end
        end

        -- On retire l'argent
        xPlayer.removeMoney(vehicleData.Price, "Achat bateau : " .. vehicleData.Name)

        -- On fait spawn le véhicule chez tous les joueurs
        ESX.OneSync.SpawnVehicle(vehicleData.Model, Config.SpawnPosition.xyz, Config.SpawnPosition.w, {}, function (networkId)
            if networkId then
                local vehicle = NetworkGetEntityFromNetworkId(networkId)
                local playerPed = GetPlayerPed(source)

                SetVehicleDoorsLocked(vehicle, 1) -- Portes ouvertes
                SetVehicleNumberPlateText(vehicle, plate) -- Plaque !

                -- On tente plusieurs fois de mettre le joueur dans le véhicule; repris de la commande /car
                for _ = 1, 20 do
                    Wait(0)
                    SetPedIntoVehicle(playerPed, vehicle, -1)

                    if GetVehiclePedIsIn(playerPed, false) == vehicle then
                        break
                    end
                end

                -- Impossible de le mettre dans le véhicule
                if GetVehiclePedIsIn(playerPed, false) ~= vehicle then
                    xPlayer.showNotification("Votre véhicule vous attend !")
                end

                -- On ajoute la plaque dans les véhicules en cours de spawn et on requête les données du véhicule au client
                -- parce qu'il n'y a que le client qui a ces données
                table.insert(spawningVehicles, plate)
                TriggerClientEvent("cali-test-bateau:request_vehicle_data", source, plate, networkId)
            end
        end)
    end)
end)

-- Event récupérant les données du véhicule qui vient juste de spawn
RegisterNetEvent('cali-test-bateau:vehicle_data', function(plate, vehicleData)
    -- Check de si la plaque était bien dans la liste des véhicules en train de spawn
    if table_containsValue(spawningVehicles, plate) then
        local xPlayer = ESX.GetPlayerFromId(source)

        if xPlayer == nil or vehicleData == nil then
            return
        end

        -- On set la plaque dans les données
        vehicleData.plate = plate

        -- On rajoute tout ça en bdd (enfin)
        MySQL.prepare.await("INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (?, ?, ?)", {
            xPlayer.identifier,
            plate,
            json.encode(vehicleData)
        })

        -- Et enfin on retire de la liste de véhicules qui sont en train de spawn
        table_removeValue(spawningVehicles, plate)
    end
end)