# Plan: Thêm 5 Titan Turret mới (Robux Only)

## Bối cảnh

Turret giới hạn hiện tại (`LimitedItems` trong `ItemConfigurations.lua`):

| Turret | Damage | Range | FireRate | Health |
|---|---|---|---|---|
| Titan Camera Guy *(hiện có)* | 2500 | 40 | 2.0 | 5,000,000,000 |

5 turret mới cần thêm, mạnh dần theo thứ tự:

---

## Bảng thiết kế Stats

| # | Tên | Damage | Range | FireRate | Health | Giá Robux (đề xuất) |
|---|---|---|---|---|---|---|
| 1 | Titan TV Man | 3,500 | 42 | 2.5 | 5,000,000,000 | 299 |
| 2 | Titan Speakerman | 4,500 | 44 | 2.5 | 5,000,000,000 | 399 |
| 3 | Upgraded Titan TV Man | 6,500 | 46 | 3.0 | 5,000,000,000 | 599 |
| 4 | Upgraded Titan Camera Guy | 8,500 | 48 | 3.0 | 5,000,000,000 | 799 |
| 5 | Upgraded Titan Speakerman | 12,000 | 50 | 3.5 | 5,000,000,000 | 1,199 |

---

## Các bước thực hiện

### Bước 1 — Tạo DevProduct trên Roblox Developer Portal
Vào **Creator Hub → Monetization → Developer Products**, tạo 5 product mới, mỗi cái đặt giá theo bảng trên. Lấy ProductID về điền vào Bước 2.

### Bước 2 — Thêm vào `LimitedItems` trong `ItemConfigurations.lua`

**File:** `src/ReplicatedStorage/Modules/ItemConfigurations.lua`

Thêm vào cuối block `LimitedItems` (sau `TitanCameraGuy`):

```lua
TitanTvMan = {
    DisplayName = "Titan TV Man",
    Type = "Turrets",
    ImageId = "rbxassetid://???",  -- điền asset ID
    ProductID = ???,               -- điền DevProduct ID
    Damage = 3500,
    Range = 42,
    FireRate = 2.5,
    Health = 5000000000,
},
TitanSpeakerman = {
    DisplayName = "Titan Speakerman",
    Type = "Turrets",
    ImageId = "rbxassetid://???",
    ProductID = ???,
    Damage = 4500,
    Range = 44,
    FireRate = 2.5,
    Health = 5000000000,
},
UpgradedTitanTvMan = {
    DisplayName = "Upgraded Titan TV Man",
    Type = "Turrets",
    ImageId = "rbxassetid://???",
    ProductID = ???,
    Damage = 6500,
    Range = 46,
    FireRate = 3.0,
    Health = 5000000000,
},
UpgradedTitanCameraGuy = {
    DisplayName = "Upgraded Titan Camera Guy",
    Type = "Turrets",
    ImageId = "rbxassetid://???",
    ProductID = ???,
    Damage = 8500,
    Range = 48,
    FireRate = 3.0,
    Health = 5000000000,
},
UpgradedTitanSpeakerman = {
    DisplayName = "Upgraded Titan Speakerman",
    Type = "Turrets",
    ImageId = "rbxassetid://???",
    ProductID = ???,
    Damage = 12000,
    Range = 50,
    FireRate = 3.5,
    Health = 5000000000,
},
```

### Bước 3 — Upload ảnh icon lên Roblox
Upload 5 ảnh thumbnail lên Roblox, lấy asset ID điền vào `ImageId`.

### Bước 4 — Không cần sửa thêm gì khác
`LimitedTurretController` và `WeaponsShopController` đã tự động xử lý tất cả item trong `LimitedItems`:
- Server: `getProductConfig()` quét toàn bộ `LimitedItems` → tự nhận ra ProductID mới
- Client: TurretsShopHandler tự render item mới từ `LimitedItems`

---

## Checklist

- [ ] Tạo 5 DevProduct trên Creator Hub
- [ ] Upload 5 ảnh icon
- [ ] Điền ProductID và ImageId vào `ItemConfigurations.lua`
- [ ] Test mua trong game (Studio)
- [ ] Deploy
