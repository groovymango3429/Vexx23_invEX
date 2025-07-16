# Storage System (Not viable and definetly has bugs)
## NOT TESTED

---

## How It Works

- **Player Inventory & Storage Shelf**  
  Each player has two main data stores:
  - **Inventory:** Items the player carries.
  - **Storage Shelf:** Items in the player's bank (with a max stack limit).

- **Unified GUI**  
  Players open the storage GUI from a button.  
  Both inventory and shelf are displayed side-by-side.  
  Items can be dragged and dropped between them.

- **Drag & Drop (PC & Mobile)**  
  - Dragging works for both mouse and touch input. (I think)
  - When an item is dropped, a remote event sends the action to the server, which updates player data and refreshes the GUI.

- **Server Communication & Persistence**  
  - Server receives deposit/withdraw requests and updates player data.
  - All inventory and shelf data can be saved/loaded per player

---

## System Requirements

| Component        | Purpose                                    | Example File                   |
|------------------|--------------------------------------------|-------------------------------|
| **Server Script**| Handles storage/inventory logic, saving    | `StorageServer.lua`           |
| **Client Script**| GUI, drag & drop, event firing             | `StorageClient.lua`           |
| **GUI**          | Inventory/shelf display, drag & drop       | Frames, buttons, sample items |
| **Remote Events**| Client-server communication                 | RemoteEvents or Signal module |
| **DataStore**    | Save/load player shelf & inventory         | Optional      |

---

## Example Code Snippet

### Server Side (`StorageServer.lua`)
```lua
Signal.Listen("Storage:Deposit", function(player, stackId)
    local shelf = getShelf(player)
    local inv = getInventory(player)
    -- move item from inventory to shelf
    -- send updated data to client
end)
```

### Client Side (`StorageClient.lua`)
```lua
itemF.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        -- start drag
        -- on drop, fire event to server to move item
    end
end)
```


## Setup Guide

1. **Add `StorageServer.lua` to ServerScriptService**
2. **Add `StorageClient.lua` to StarterPlayerScripts**
3. **Design your GUI with Inventory, Shelf, and drag/drop item buttons**
4. **Set up RemoteEvents or use a Signal module for communication**
5. **(Optional) Implement DataStore saving/loading for persistence**

---

## Example Flow

1. Player clicks "Open Storage" button.
2. Storage GUI shows inventory and shelf side-by-side.
3. Player drags item from inventory to shelf.
4. Server updates data and GUI.
5. Player closes GUI when done.

---

## Customization

- Change maximum shelf stacks (`MaxStacks`) per player.
- Add item images, stack counts, or rarity.

---
