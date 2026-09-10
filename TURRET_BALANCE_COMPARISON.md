# Turret Balance — trạng thái hiện tại (sau merge master)

> ⚠️ **Bảng "target" cũ đã bỏ.** Master (`7505765`, `35b5936`, `e2ed2a8`, `6b74f0c`) đã rebalance lại toàn bộ turret theo hệ **`Cooldown`** (giây giữa 2 phát), thêm `TargetingMode` + `SlowEffect`. Nhánh này đã lấy hết chỉ số của master. File này giờ chỉ là **ảnh chụp thông số hiện tại** + trạng thái tính năng "Titan vào shop".

Nguồn code:
- `src/ReplicatedStorage/Modules/ItemConfigurations.lua` — `ItemConfigurations` (9 turret thường) + `LimitedItems` (6 turret Titan)
- `src/ServerScriptService/Controllers/TurretController.lua` — vòng bắn, targeting, slow effect
- `src/ServerScriptService/Controllers/BlocksShopController.lua` — roll `Chance`/`StockAmount` khi restock; `onPurchaseRequest` = mua bằng Cash
- `src/ServerScriptService/Controllers/LimitedTurretController.lua` — `ProcessPurchase` cho đường Robux (`STOCK_KEYS` giờ rỗng)
- `src/StarterGui/GUI/Frames/TurretsShop/TurretsShopHandler.client.lua` — UI Turrets Shop

## Cách tính DPS

`TurretController` bắn khi `now - lastFireTime >= Cooldown / waveSpeedMultiplier`.

- **Fire rate cơ bản** = `1 / Cooldown` (phát/giây)
- **DPS cơ bản** = `Damage / Cooldown`
- `WaveSpeed` người chơi chọn (1x / 2x / 3x) chia nhỏ `Cooldown` → turret bắn nhanh hơn, DPS thực tế = `DPS cơ bản × WaveSpeed`.

---

## Bảng 1 — 9 turret thường (`ItemConfigurations`)

| # | Turret | Price | Damage | Range | Cooldown | DPS cơ bản | Chance | Stock | Targeting / hiệu ứng |
|---|---|---|---|---|---|---|---|---|---|
| 1 | CameraGuy | 200 | 50 | 10 | 1 | 50 | 100% | 1–5 | Closest (mặc định) |
| 2 | EngineerCameraGuy | 600 | 50 | 30 | 2 | 25 | 90% | 1–5 | **ClosestToEnd** (chặn con gần đích nhất) |
| 3 | SpeakerGuy | 800 | 45 | 10 | 0.5 | 90 | 80% | 1–5 | **HighestHP** (đánh con máu cao nhất) |
| 4 | TvGuy | 400 | 50 | 10 | 2 | 25 | 95% | 1–5 | **FastestFarthest** + **Slow 50% / 2s** |
| 5 | NinjaCameraGuy | 4,000 | 400 | 16 | 0.5 | 800 | 60% | 1–5 | Closest |
| 6 | LargeScientistCameraman | 7,000 | 700 | 24 | 1 | 700 | 50% | 1–5 | Closest |
| 7 | LargeSpeakerGuy | 15,000 | 1,000 | 28 | 0.5 | 2,000 | 40% | 1–5 | Closest |
| 8 | LargeTvGuy | 30,000 | 1,500 | 30 | 1 | 1,500 | 30% | 1–5 | Closest |
| 9 | LaserCameramanCar | 60,000 | 3,000 | 35 | 0.1 | 30,000 | 20% | 1–5 | Closest |

## Bảng 2 — 6 turret Titan (`LimitedItems`)

| # | Turret | Price (Cash) | Damage | Range | Cooldown | DPS cơ bản | Chance | Stock | `InShop` | Mua thế nào |
|---|---|---|---|---|---|---|---|---|---|---|
| 10 | TitanCameraGuy | 80,000 | 2,500 | 40 | 0.5 | 5,000 | 18% | 1–3 | ✅ | **Cash trong Turrets Shop** + Robux |
| 11 | TitanTVMan | 150,000 | 3,500 | 42 | 0.4 | 8,750 | 14% | 1–3 | ✅ | **Cash trong Turrets Shop** + Robux |
| 12 | TitanSpeakerman | 250,000 | 4,500 | 44 | 0.4 | 11,250 | 10% | 1–2 | ✅ | **Cash trong Turrets Shop** + Robux |
| 13 | UpgradedTitanTVMan | 400,000¹ | 6,500 | 46 | 0.33 | ~19,700 | 8%¹ | 1–2¹ | ❌ | Robux qua pad chạm |
| 14 | UpgradedTitanCameraGuy | 650,000¹ | 8,500 | 48 | 0.33 | ~25,800 | 6%¹ | 1–1¹ | ❌ | Robux qua pad chạm |
| 15 | UpgradedTitanSpeakerman | 1,000,000¹ | 12,000 | 50 | 0.29 | ~41,400 | 4%¹ | 1–1¹ | ❌ | Robux qua pad chạm |

¹ Field đã thêm sẵn nhưng **chưa dùng** — 3 con Upgraded không có `InShop` nên shop không roll, giá Cash chưa hiệu lực. Để dành cho sau này.

> Titan không có `TargetingMode` → dùng chế độ mặc định (con gần nhất trong `Range`).

---

## Tính năng "Titan vào shop" — ✅ đã code xong

### Quyết định (đã chốt)

Áp cho **3 turret**: `TitanCameraGuy`, `TitanTVMan`, `TitanSpeakerman`.

1. **Mua song song Cash + Robux.** Cày chay mua bằng `Price` (Cash) khi shop có hàng; ai muốn nhanh dùng Robux (`ProductID`) — Robux mua bất cứ lúc nào, không phụ thuộc stock.
2. **Stock y hệt 9 turret thường. KHÔNG kho global 999, KHÔNG DataStore, KHÔNG "2 lớp stock".**
   - Mỗi restock (180s): roll `Chance` → trúng thì `Stock = random(Min, Max)`, trượt thì `Stock = 0`.
   - Card **luôn hiện** trong Turrets Shop. `Stock > 0` → mua Cash được. `Stock = 0` → xám nút `Buy`, chờ đợt sau.
   - Mua Cash trừ `Stock` 1 đơn vị. Mua Robux **không** đụng `Stock`.
   - Không có "hết vĩnh viễn".
3. **Cách A — dùng chung hạ tầng Turrets Shop hiện có** (`profile.Data.BlockShopStock`, remote `PurchaseBlockItem` / `GetBlockShopStocks` / `UpdateBlockStocks`, timer 180s). Không HUD/frame riêng.

### Thay đổi code đã làm

| File | Thay đổi |
|---|---|
| `ItemConfigurations.lua` | 3 Titan shop: thêm `InShop = true` + `Price` + `Chance` + `StockAmount`. 3 Upgraded: thêm `Price`/`Chance`/`StockAmount` (chưa dùng). |
| `BlocksShopController.lua` — `Restock()` | Vòng roll thêm turret `LimitedItems` **có `config.InShop`**, y hệt turret thường: trúng `Chance` → `random(Min,Max)`, trượt → `0`. Turret không `InShop` → không set (để `nil`) → client ẩn card. |
| `BlocksShopController.lua` — `onPurchaseRequest()` | Gộp `config = ItemConfigurations[id] or LimitedItems[id]`. Bỏ cờ `isLimited`, bỏ khối check kho global + `ConsumeStock` + hoàn tiền. Mua Titan = check `Stock > 0` + đủ Cash → trừ tiền, `Stock -= 1`, cấp turret. |
| `BlocksShopController.lua` — `Init` | Bỏ `local LimitedTurretController` + dòng gán (không còn ai gọi). |
| `LimitedTurretController.lua` | `STOCK_KEYS = {}` (rỗng). Xoá `IsStockTracked` + `ConsumeStock`. `ProcessPurchase` mọi Titan rơi vào nhánh `else` "grant directly" → Robux không giới hạn. `GetStock` giữ nguyên (luôn trả `0`). |
| `TurretsShopHandler.client.lua` — `populateShop()` | Sau vòng `ItemConfigurations`, lặp thêm `LimitedItems` (`Type == "Turrets"` **và** `currentStocks[itemId] ~= nil`) → `table.insert` vào `itemsToDisplay`. Dùng chung card `Templates/TurretsTemplate`. Sort theo `Price` → Titan nằm cuối. |

### Luồng sau khi sửa

- **Đường Cash:** `PurchaseBlockItem` → `BlocksShopController.onPurchaseRequest` (tra `LimitedItems`, xử lý y như turret thường).
- **Đường Robux:** `PromptProductPurchase` → `ProcessReceipt` → `WeaponsShopController` → `LimitedTurretController:ProcessPurchase` nhánh `else` "grant directly".

### Còn lại — chưa làm (cần vào Studio, không bắt buộc)

- [ ] Gỡ / ẩn 3 frame HUD cũ: `LimitedTurret` (TitanCameraGuy), `LimitedTurretTitanTVMan`, `LimitedTurretTitanSpeakerman`. Chúng đọc `GetLimitedTurretStock` (giờ trả `0`) → sẽ hiện "SOLD OUT FOREVER". 3 con này đã có trong Turrets Shop nên frame riêng thừa.
- [ ] `UpgradedTitanTouchHandler.client.lua` (pad chạm mua 3 con Upgraded) — **GIỮ NGUYÊN**.
- [ ] Sau khi sync code: cần **1 lần restock** (hết timer 180s hoặc nút restock Robux) thì `BlockShopStock` mới có key Titan.

### Ngoài phạm vi đợt này

- 3 turret `Upgraded...`: giữ nguyên — mua Robux qua pad chạm, không vào shop, không giới hạn.
- Muốn đưa Upgraded vào shop sau này: chỉ cần thêm `InShop = true` — cùng cơ chế, không code thêm.
