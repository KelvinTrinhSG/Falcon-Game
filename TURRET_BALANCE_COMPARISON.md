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
| 13 | UpgradedTitanTVMan | 400,000 | 6,500 | 46 | 0.33 | ~19,700 | 8% | 1–2 | ✅ | **Cash trong Turrets Shop** + Robux (pad hoặc shop) |
| 14 | UpgradedTitanCameraGuy | 650,000 | 8,500 | 48 | 0.33 | ~25,800 | 6% | 1–1 | ✅ | **Cash trong Turrets Shop** + Robux (pad hoặc shop) |
| 15 | UpgradedTitanSpeakerman | 1,000,000 | 12,000 | 50 | 0.29 | ~41,400 | 4% | 1–1 | ✅ | **Cash trong Turrets Shop** + Robux (pad hoặc shop) |

> Titan không có `TargetingMode` → dùng chế độ mặc định (con gần nhất trong `Range`).

---

## Tính năng "Titan vào shop" — ✅ đã code xong cho **cả 6 con** (3 Titan + 3 Upgraded)

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

### Còn lại — chưa làm

- [x] ✅ **Đã ẩn 3 frame HUD cũ trong Studio** (`LimitedTurret`, `LimitedTurretTitanTVMan`, `LimitedTurretTitanSpeakerman`) — tự tay ẩn qua Properties (`Visible`/nút HUD), không phải sửa code. Đây là thay đổi nằm trong file `.rbxl`/place của Studio, **không nằm trong Git** — nhớ Save/Publish trong Studio để không mất.
- [ ] `UpgradedTitanTouchHandler.client.lua` (pad chạm mua 3 con Upgraded) — **GIỮ NGUYÊN**, không đụng.

### Ghi chú: độ trễ "1 lần restock" — hiện KHÔNG phải vấn đề

- Người chơi cũ (đã có `BlockShopStock` lưu sẵn trước khi thêm Titan) phải đợi tới khi `Restock()` chạy lại (≤180s, hoặc restock Robux) thì key Titan mới xuất hiện trong shop của họ — do `PlayerController` chỉ tự restock khi `BlockShopStock` **rỗng hoàn toàn**.
- **Hiện tại không ai bị ảnh hưởng**: `PlayerController.lua` dùng `ProfileService.New("PlayerDataV58", ...)` — key DataStore vừa bị bump từ `V25 → V58` ở commit `073777f` (thói quen chung của team mỗi khi đổi cấu trúc data lớn: V3→V6→V24→V25→V58...). Mọi account test hiện tại đều là **profile mới tinh** dưới `V58` → `BlockShopStock` rỗng → restock ngay lúc join → thấy Titan ngay lập tức, không cần đợi.
- Đây chỉ là **trùng hợp tạm thời** của giai đoạn dev. Sau khi ngừng bump version (đặc biệt là sau khi public), người chơi thật sẽ tích luỹ save dài hạn dưới `V58` → lần tới thêm/sửa item shop sẽ gặp đúng độ trễ này thật sự.

### 🔮 Đề xuất tương lai (chưa làm — làm khi cần)

**`BackfillMissingStock` — vá key thiếu trong `BlockShopStock` khi join, không cần đợi restock 180s.**

Vấn đề: `PlayerController.lua` chỉ gọi `Restock()` khi `BlockShopStock` **rỗng hoàn toàn** (`next(stockSnapshot) == nil`). Người chơi có save cũ (thiếu key item mới thêm) sẽ không được restock ngay, phải đợi hết chu kỳ 180s.

Giải pháp: thêm hàm roll **chỉ những key đang thiếu**, giữ nguyên toàn bộ stock cũ đã roll của người chơi (không reset gì cả, không cho hàng miễn phí ngoài ý muốn):

```lua
-- BlocksShopController.lua
function ShopController:BackfillMissingStock(player: Player)
	local profile = PlayerController:GetProfile(player)
	if not profile then return end
	local stock = profile.Data.BlockShopStock
	local changed = false

	local function rollIfMissing(itemId, config)
		if stock[itemId] == nil then
			if math.random() * 100 <= config.Chance then
				stock[itemId] = math.random(config.StockAmount.Min, config.StockAmount.Max)
			else
				stock[itemId] = 0
			end
			changed = true
		end
	end

	for itemId, config in pairs(LimitedItems) do
		if config.InShop and config.Chance and config.StockAmount then
			rollIfMissing(itemId, config)
		end
	end

	if changed then
		updateStocksEvent:FireClient(player, stock)
	end
end
```

Gọi thêm ở `PlayerController.lua`, nhánh `else` (khi `BlockShopStock` không rỗng) của check restock hiện tại.

- **Không cần làm ngay** — vì lý do ở mục trên (đang dùng `V58` mới, chưa có ai thực sự "người chơi cũ").
- **Nên làm trước khi public**, hoặc trước lần tiếp theo thêm item mới vào Turrets Shop sau khi ngừng bump DataStore version — để người chơi thật không phải đợi 180s mới thấy item mới.
- Tự động áp dụng cho **mọi item mới thêm sau này**, không chỉ riêng Titan.

---

## ✅ Đưa nốt 3 turret Upgraded vào shop — ĐÃ LÀM

Áp dụng cho: `UpgradedTitanTVMan`, `UpgradedTitanCameraGuy`, `UpgradedTitanSpeakerman`.

### Vì sao chỉ cần đúng 1 thay đổi

Khi làm 3 con Titan đầu (Cách A), toàn bộ code đã viết theo kiểu **đọc cờ `config.InShop`**, không hardcode tên turret:

- `BlocksShopController.Restock()` → `for itemId, config in pairs(LimitedItems) do if config.InShop and ... end` — roll **mọi** turret có `InShop`, không quan tâm là Titan hay Upgraded.
- `BlocksShopController.onPurchaseRequest()` → `config = ItemConfigurations[itemId] or LimitedItems[itemId]` — tra chung, không phân biệt.
- `TurretsShopHandler.client.lua` → `for itemId, config in pairs(LimitedItems) do if config.Type == "Turrets" and currentStocks[itemId] ~= nil then ...` — hiện card cho **mọi** turret server có roll.
- `LimitedTurretController.STOCK_KEYS` → đã rỗng **từ trước** (sửa 1 lần cho tất cả `LimitedItems`, không riêng 3 Titan) → đường Robux của Upgraded **vốn đã** không bị giới hạn 999.

→ 3 con Upgraded đã có sẵn `Price` / `Chance` / `StockAmount` (thêm từ mục B, chưa dùng tới giờ). **Chỉ thiếu đúng 1 dòng mỗi con.**

### Checklist

- [x] `ItemConfigurations.lua` — thêm `InShop = true` cho `UpgradedTitanTVMan`, `UpgradedTitanCameraGuy`, `UpgradedTitanSpeakerman` (y hệt cách làm 3 con Titan đầu).
- [x] Không cần sửa gì thêm ở `BlocksShopController.lua`, `LimitedTurretController.lua`, `TurretsShopHandler.client.lua` — đã generic từ đợt trước, `rojo build` pass.

### Ảnh hưởng sau khi bật

- 6/6 turret Titan giờ hiện trong Turrets Shop, mua Cash (khi shop restock trúng `Chance`: 8%/6%/4%, stock 1-2/1-1/1-1) **hoặc** Robux (không giới hạn) — y hệt 3 Titan đầu.
- `UpgradedTitanTouchHandler.client.lua` (pad chạm ngoài map) — **không xung đột**, vẫn hoạt động song song vì nó chỉ gọi thẳng `PromptProductPurchase(player, config.ProductID)`, không đụng tới `BlockShopStock`. Người chơi có 2 cách mua Robux: pad hoặc nút trong shop. Giữ nguyên hay gỡ pad là tuỳ chọn, không bắt buộc.
- Áp dụng đúng cảnh báo ở mục "Ghi chú: độ trễ 1 lần restock" phía trên — không phải vấn đề lúc này (đang `PlayerDataV58` mới), nhưng vẫn nên nhớ khi cân nhắc `BackfillMissingStock` sau này.
- Giá Cash các con này khá cao (400k/650k/1M) — nên cân nhắc lại có hợp lý với tốc độ kiếm tiền trong game không trước khi bật, vì hiện chưa test cảm giác chơi.

### Ngoài phạm vi (không đổi)

- Không đổi số liệu Damage/Range/Cooldown/Price/Chance/StockAmount hiện có của 3 con Upgraded — chỉ bật cờ `InShop`.
