# Feature: Mở GUI Shop theo Tab dựa trên Touch Part

## Mục tiêu

| Touch Part | Mở GUI | Tab mặc định |
|---|---|---|
| `Workspace/BlocksShop/Touch` | `StarterGui/GUI/Frames/BlocksShop` | **Blocks** |
| `Workspace/TurretsShop/Touch` | `StarterGui/GUI/Frames/BlocksShop` | **Turrets** |

> Hiện tại chỉ có `Workspace/BlocksShop` trong Workspace. Cần thêm `Workspace/TurretsShop` (model riêng có Part tên `Touch`).

---

## Hiện trạng

### Server — ShopController.lua
- `ShopController` loop qua `shops` table, mỗi shop tìm child tên `"Touch"` và lắng nghe `.Touched`.
- Khi touched → fire `OpenShopFrame` RemoteEvent xuống client với `shopName` (e.g. `"BlocksShop"`).

### Client — BlocksShopHandler.client.lua
- Lắng nghe `OpenShopFrame`, nếu `shopName == "BlocksShop"` thì set `shopFrame.Visible = true`.
- `currentFilter` quyết định tab nào được hiển thị (`"Blocks"` hoặc `"Turrets"`), mặc định là `"Turrets"`.
- Hàm `populateShop()` filter `ItemConfigurations` theo `currentFilter`.

---

## Thay đổi cần làm

### 1. Server — ShopController.lua
Thêm `TurretsShop` vào `shops` table:

```lua
local shops = {
    WeaponsShop = Workspace:WaitForChild("WeaponsShop"),
    BlocksShop  = Workspace:WaitForChild("BlocksShop"),
    BasesShop   = Workspace:WaitForChild("BasesShop"),
    TurretsShop = Workspace:WaitForChild("TurretsShop"), -- THÊM
}
```

Server sẽ tự fire `OpenShopFrame` với `shopName = "TurretsShop"` khi player chạm `Workspace/TurretsShop/Touch`.

---

### 2. Client — BlocksShopHandler.client.lua
Sửa phần lắng nghe `OpenShopFrame` để nhận thêm `shopName`, rồi set `currentFilter` trước khi hiện GUI:

```lua
-- Thay vì chỉ check "BlocksShop", handle cả "TurretsShop"
openShopFrameEvent.OnClientEvent:Connect(function(shopName: string)
    if shopName == "BlocksShop" then
        currentFilter = "Blocks"
        shopFrame.Visible = true
    elseif shopName == "TurretsShop" then
        currentFilter = "Turrets"
        shopFrame.Visible = true
    end
end)
```

---

### 3. Roblox Studio — Workspace
Tạo Model tên `TurretsShop` trong Workspace, bên trong có một `BasePart` tên `Touch` đặt đúng vị trí trong map.

---

## Luồng hoàn chỉnh sau khi sửa

```
Player chạm Workspace/BlocksShop/Touch
  → ShopController fires OpenShopFrame("BlocksShop")
  → Client set currentFilter = "Blocks" → shopFrame.Visible = true
  → populateShop() hiển thị items có Type == "Blocks"

Player chạm Workspace/TurretsShop/Touch
  → ShopController fires OpenShopFrame("TurretsShop")
  → Client set currentFilter = "Turrets" → shopFrame.Visible = true
  → populateShop() hiển thị items có Type == "Turrets"
```
