-- Fonction pour ouvrir un menu contenant toutes les catégories de bateaux
function OpenBoatBuyMenuCategories(categories)
    local elements = {}

    for _, category in pairs(categories) do
        table.insert(elements, {
            label = category.Name,
            vehicles = category.Vehicles
        })
    end

    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'boat_buy_menu__categories', {
        title    = 'Catalogue des bateaux',
        align    = 'top-left',
        elements = elements
    }, function(data, _)
        OpenBoatBuyMenuVehicles(categories, data.current.vehicles)
    end, function(_, menu)
        menu.close()
    end)
end

-- Fonction pour ouvrir un menu contenant tous les bateaux disponibles dans une catégorie
function OpenBoatBuyMenuVehicles(categories, vehicles)
    local elements = {}

    for _, vehicle in pairs(vehicles) do
        table.insert(elements, {
            label = vehicle.Name .. " ($" .. vehicle.Price .. ")",
            vehicle = vehicle
        })
    end

    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'boat_buy_menu__vehicles', {
        title    = 'Catalogue des bateaux',
        align    = 'top-left',
        elements = elements
    }, function(data, _)
        OpenBoatBuyMenuConfirmation(categories, vehicles, data.current.vehicle)
    end, function(_, _)
        OpenBoatBuyMenuCategories(categories)
    end)
end

-- Fonction pour ouvrir un menu de confirmation d'achat d'un bateau
function OpenBoatBuyMenuConfirmation(categories, vehicles, vehicle)
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'boat_buy_menu__confirmation', {
        title    = 'Catalogue des bateaux',
        align    = 'top-left',
        elements = {
            {
                label = "Confirmer l'achat (" .. vehicle.Name .. " : $" .. vehicle.Price .. ")",
                confirm = true
            },
            {
                label = "Annuler l'achat",
                confirm = false
            }
        }
    }, function(data, menu)
        if not data.current.confirm then
            OpenBoatBuyMenuVehicles(categories, vehicles)
            return
        end

        menu.close()
        TriggerServerEvent("cali-test-bateau:buy_boat", vehicle.Model)
    end, function(_, _)
        OpenBoatBuyMenuVehicles(categories, vehicles)
    end)
end