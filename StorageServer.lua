local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Signal")) -- Your remote event wrapper
local Players = game:GetService("Players")

-- Each player's shelf data stored in memory
local PlayerShelves = {} -- [player.UserId] = { Items = {}, MaxStacks = 8 }

-- Util: Get or create player's shelf
local function getShelf(player)
    local shelf = PlayerShelves[player.UserId]   -
    if not shelf then
        shelf = { Items = {}, MaxStacks = 8 }
        PlayerShelves[player.UserId] = shelf
    end
    return shelf
end

-- Util: Get or create player's inventory
local function getInventory(player)
    player.Inventory = player.Inventory or { Inventory = {} }
    return player.Inventory
end

-- Open shelf for player
Signal.Listen("Storage:Open", function(player)
    local shelf = getShelf(player)
    Signal.FireClient(player, "Storage:Open", shelf.Items, shelf.MaxStacks)
end)

-- Deposit item from inventory to shelf
Signal.Listen("Storage:Deposit", function(player, stackId)
    local shelf = getShelf(player)
    local inv = getInventory(player)
    -- Find item in inventory
    local idx, stack
    for i, s in ipairs(inv.Inventory) do
        if s.StackId == stackId then
            idx, stack = i, s
            break
        end
    end
    if not stack then return end
    if #shelf.Items >= shelf.MaxStacks then return end -- shelf full
    table.insert(shelf.Items, stack)
    table.remove(inv.Inventory, idx)
    Signal.FireClient(player, "Storage:Update", shelf.Items, shelf.MaxStacks)
    Signal.FireClient(player, "InventoryClient:Update", inv)
end)

-- Withdraw item from shelf to inventory
Signal.Listen("Storage:Withdraw", function(player, stackId)
    local shelf = getShelf(player)
    local inv = getInventory(player)
    -- Find item in shelf
    local idx, stack
    for i, s in ipairs(shelf.Items) do
        if s.StackId == stackId then
            idx, stack = i, s
            break
        end
    end
    if not stack then return end
    table.insert(inv.Inventory, stack)
    table.remove(shelf.Items, idx)
    Signal.FireClient(player, "Storage:Update", shelf.Items, shelf.MaxStacks)
    Signal.FireClient(player, "InventoryClient:Update", inv)
end)

Players.PlayerRemoving:Connect(function(player)
    PlayerShelves[player.UserId] = nil -- cleanup
end)
