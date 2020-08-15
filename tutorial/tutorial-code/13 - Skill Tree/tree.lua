function treeToPlayer(player)
    for _, index in ipairs(bought_node_indexes) do
        local stats = tree[index].stats
        for i = 1, #stats, 3 do
            local attribute, value = stats[i+1], stats[i+2]
            player[attribute] = player[attribute] + value
        end
    end
end

tree = {}
tree[1] = {x = 0, y = 0, links = {2}}
tree[2] = {x = 48, y = 0, stats = {'4% Increased HP', 'hp_multiplier', 0.04}, links = {3}}
tree[3] = {x = 96, y = 0, stats = {'6% Increased HP', 'hp_multiplier', 0.06}, links = {4}}
tree[4] = {x = 144, y = 0, stats = {'4% Increased HP', 'hp_multiplier', 0.04}}
