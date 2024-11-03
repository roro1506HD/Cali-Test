-- Utilitaire pour savoir si une table contient la valeur demandée
function table_containsValue(list, value)
    for _, v in pairs(list) do
        if v == value then
            return true
        end
    end

    return false
end

-- Utilitaire pour récupérer de façon sûre la taille de la table
-- Certaines utilisations de #table ne fonctionnant pas comme prévu
function table_size(list)
    local count = 0

    for _ in pairs(list) do
        count = count + 1
    end

    return count
end

-- Utilitaire pour supprimer une valeur d'une table, autant de fois que cette valeur est présente dans la table
-- Cette fonction retourne le nombre de valeurs retirées de la table
function table_removeValue(list, value)
    local index = 1
    local toRemove = {}
    for _, v in pairs(list) do
        if v == value then
            table.insert(toRemove, index)
        end
        index = index + 1
    end

    table.sort(toRemove, function(a, b)
        return b < a
    end)

    for _, v in pairs(toRemove) do
        table.remove(list, v)
    end

    return table_size(toRemove)
end