local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Signal"))
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- GUI refs (make sure to match your hierarchy)
local playerGui = player:WaitForChild("PlayerGui")
local invF = playerGui:WaitForChild("Storage"):WaitForChild("Inventory")
local itemsSF = invF:WaitForChild("ItemsScroll")
local itemSample = itemsSF:WaitForChild("Sample")

local storageGui = playerGui:WaitForChild("Storage"):WaitForChild("Storage")
local storageSF = storageGui:WaitForChild("ItemsScroll")
local storageSample = storageSF:WaitForChild("Sample")
local stackLabel = storageGui:WaitForChild("StackLabel")
local closeButton = storageGui:WaitForChild("Done")

local shelfItems = {}
local shelfMax = 8
local inventoryData = nil

function updateInventoryDisplay(invData)
    for _, child in ipairs(itemsSF:GetChildren()) do
        if child:IsA("TextButton") and child ~= itemSample then
            child:Destroy()
        end
    end
    for _, stackData in ipairs(invData.Inventory) do
        local itemF = itemSample:Clone()
        itemF.Name = "Stack-" .. stackData.StackId
        itemF.Visible = true
        itemF.Parent = itemsSF
        itemF.Image.Image = stackData.Image or "rbxassetid://0"
        itemF.ItemCount.Text = tostring(stackData.Count or 1) .. "x"
        -- Drag start (PC+Mobile)
        itemF.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local dragFrame = itemF:Clone()
                dragFrame.Parent = playerGui
                dragFrame.Visible = true
                dragFrame.Size = UDim2.fromOffset(itemF.AbsoluteSize.X, itemF.AbsoluteSize.Y)
                dragFrame.ZIndex = 10
                dragFrame.BackgroundTransparency = 0.25
                dragFrame.Position = UDim2.fromOffset(UIS:GetMouseLocation().X, UIS:GetMouseLocation().Y)

                local moveConn
                moveConn = RunService.RenderStepped:Connect(function()
                    local pos = UIS:GetMouseLocation()
                    dragFrame.Position = UDim2.fromOffset(pos.X - dragFrame.AbsoluteSize.X/2, pos.Y - dragFrame.AbsoluteSize.Y/2)
                end)

                local upConn
                UIS.InputEnded:Connect(function(endInput)
                    if endInput.UserInputType == input.UserInputType then
                        moveConn:Disconnect()
                        upConn:Disconnect()
                        dragFrame:Destroy()
                        if storageGui.Visible then
                            Signal.FireServer("Storage:Deposit", stackData.StackId)
                        end
                    end
                end)
            end
        end)
    end
end

function updateStorageDisplay()
    for _, child in ipairs(storageSF:GetChildren()) do
        if child:IsA("TextButton") and child ~= storageSample then
            child:Destroy()
        end
    end
    for _, stackData in ipairs(shelfItems) do
        local itemF = storageSample:Clone()
        itemF.Name = "Stack-" .. stackData.StackId
        itemF.Image.Image = stackData.Image or "rbxassetid://0"
        itemF.ItemCount.Text = tostring(stackData.Count or 1) .. "x"
        itemF.Visible = true
        itemF.Parent = storageSF
        -- Drag start (PC+Mobile)
        itemF.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local dragFrame = itemF:Clone()
                dragFrame.Parent = playerGui
                dragFrame.Visible = true
                dragFrame.Size = UDim2.fromOffset(itemF.AbsoluteSize.X, itemF.AbsoluteSize.Y)
                dragFrame.ZIndex = 10
                dragFrame.BackgroundTransparency = 0.25
                dragFrame.Position = UDim2.fromOffset(UIS:GetMouseLocation().X, UIS:GetMouseLocation().Y)

                local moveConn
                moveConn = RunService.RenderStepped:Connect(function()
                    local pos = UIS:GetMouseLocation()
                    dragFrame.Position = UDim2.fromOffset(pos.X - dragFrame.AbsoluteSize.X/2, pos.Y - dragFrame.AbsoluteSize.Y/2)
                end)

                local upConn
                UIS.InputEnded:Connect(function(endInput)
                    if endInput.UserInputType == input.UserInputType then
                        moveConn:Disconnect()
                        upConn:Disconnect()
                        dragFrame:Destroy()
                        if invF.Visible then
                            Signal.FireServer("Storage:Withdraw", stackData.StackId)
                        end
                    end
                end)
            end
        end)
    end
    stackLabel.Text = ("%d/%d stacks"):format(#shelfItems, shelfMax or 8)
end

-- Remote event handlers
Signal.ListenRemote("Storage:Open", function(items, maxStacks)
    shelfItems = items
    shelfMax = maxStacks
    storageGui.Visible = true
    invF.Visible = true
    updateStorageDisplay()
end)

Signal.ListenRemote("Storage:Update", function(items, maxStacks)
    shelfItems = items
    shelfMax = maxStacks
    updateStorageDisplay()
end)

Signal.ListenRemote("InventoryClient:Update", function(newInvData)
    inventoryData = newInvData
    updateInventoryDisplay(inventoryData)
end)

closeButton.MouseButton1Click:Connect(function()
    storageGui.Visible = false
    invF.Visible = false
end)


warn("Not sure how you want to open the shelf, you could do proximity prompt like in my game or a button")
warn("This system probably doesn't work and definetly has bugs")
-- Example: open shelf with a button
local openShelfBtn = playerGui:WaitForChild("Storage"):WaitForChild("OpenShelf")
openShelfBtn.MouseButton1Click:Connect(function()
    Signal.FireServer("Storage:Open")   -- and you might want to add some sort of proximity check to make sure the player can't deposit an item from like 1000 blocks away. 
end)
