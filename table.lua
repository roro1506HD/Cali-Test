function table_containsValue(list, value)
    for _, v in pairs(list) do
        if v == value then
            return true
        end
    end

    return false
end

function table_size(list)
    local count = 0

    for _ in pairs(list) do
        count = count + 1
    end

    return count
end

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