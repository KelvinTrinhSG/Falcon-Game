# Weapon Rename Plan

Có 2 phương án: chỉ đổi tên hiển thị (đơn giản) hoặc đổi cả key nội bộ (phức tạp, rủi ro).

---

## Phương án A — Chỉ đổi DisplayName (khuyến nghị)

Sửa duy nhất `WeaponConfigurations.lua`, không ảnh hưởng DataStore hay folder.

### Các bước
- [ ] 1. Sửa 16 `DisplayName` trong `src/ReplicatedStorage/Modules/WeaponConfigurations.lua`
- [ ] 2. Kiểm tra WeaponsShop và Inventory hiển thị đúng tên
- [ ] 3. Kiểm tra crate loot popup

---

## Phương án B — Đổi key nội bộ lẫn DisplayName

### Files phải sửa

| File | Thay đổi |
|------|----------|
| `src/ReplicatedStorage/Modules/WeaponConfigurations.lua` | Đổi 16 key + DisplayName + Item trong crate loot tables |
| `src/ServerScriptService/Controllers/PlayerController.lua` | `WeaponInventory = {"WoodSword"}` và `LastEquippedWeapon = "WoodSword"` |
| `src/ReplicatedStorage/Weapons/` | Đổi tên 16 folder (VD: `WoodSword/` → `SimplePlunger/`) |

### Rủi ro DataStore
`WeaponController` equip vũ khí bằng cách tìm folder theo key lưu trong DataStore (`profile.Data.WeaponInventory`). Mọi player đang có data cũ sẽ **mất toàn bộ vũ khí** khi login vì key `"WoodSword"` không còn tồn tại.

→ Bắt buộc phải viết **migration script** chạy 1 lần khi player load, convert key cũ sang key mới.

### Các bước
- [ ] 1. Sửa key + DisplayName + crate loot tables trong `WeaponConfigurations.lua`
- [ ] 2. Đổi tên 16 folder trong `src/ReplicatedStorage/Weapons/`
- [ ] 3. Sửa default `WoodSword` → `SimplePlunger` trong `PlayerController.lua`
- [ ] 4. Viết migration script trong `PlayerController.lua` khi load data: map key cũ → key mới
- [ ] 5. Kiểm tra toàn bộ flow: equip, unequip, mua shop, mở crate, load data cũ

---

## Danh sách thay đổi

| Key cũ | Key mới | DisplayName mới |
|--------|---------|-----------------|
| `WoodSword` | `SimplePlunger` | Simple Plunger |
| `StoneSword` | `UpgradedPlunger` | Upgraded Plunger |
| `ClassicSword` | `SpikePlunger` | Spike Plunger |
| `WhiteSword` | `BlueSword2` | Blue Sword |
| `BlueSword` | `WhiteSword2` | White Sword |
| `IceSword` | `RedSword` | Red Sword |
| `AzureSword` | `BlueCrossSword` | Blue Cross Sword |
| `PinkSword` | `PinkCrossSword` | Pink Cross Sword |
| `EasterSword` | `RedCrossSword` | Red Cross Sword |
| `GemSword` | `EvisceratorAxe` | Eviscerator Axe |
| `PotOSword` | `ChainSword` | Chain Sword |
| `EarthSword` | `AgentKatana` | Agent Katana |
| `PrismFang` | `EnergizedArmBlade` | Energized Arm Blade |
| `SovereignSplitter` | `TVManSword` | TV Man Sword |
| `Crownbreaker` | `MechanicalHammer` | Mechanical Hammer |
| `LightSword` | `CrescentRose` | Crescent Rose |

## Lưu ý

- `WhiteSword` ↔ `BlueSword` hoán đổi tên cho nhau — cần đặt key mới khác hoàn toàn để tránh xung đột.
- Phương án B tốn công gấp ~5 lần và có rủi ro mất data người chơi nếu migration thiếu sót.
