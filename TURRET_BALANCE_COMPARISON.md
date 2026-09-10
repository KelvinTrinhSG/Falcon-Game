# So sánh hệ thống Turret hiện tại vs bảng thông số mới

Nguồn code đối chiếu:
- `src/ReplicatedStorage/Modules/ItemConfigurations.lua` (`ItemConfigurations` = 9 turret thường, `LimitedItems` = 6 turret Titan)
- `src/ServerScriptService/Controllers/BlocksShopController.lua` (roll `Chance`/`StockAmount` khi restock; `onPurchaseRequest` = đường mua bằng Cash)
- `src/ServerScriptService/Controllers/LimitedTurretController.lua` (`ProcessPurchase` cho đường Robux; hệ kho global DataStore 999 — **bỏ dùng cho 3 turret shop**)
- `src/ServerScriptService/Controllers/WeaponsShopController.lua` (`ProcessReceipt` định tuyến purchase Robux → `LimitedTurretController:ProcessPurchase`)
- `src/StarterGui/GUI/Frames/TurretsShop/TurretsShopHandler.client.lua` (UI Turrets Shop — nơi 3 turret Titan hiện ra)

> **CHỐT MỚI (thay quyết định cũ):** `TitanCameraGuy` / `TitanTVMan` / `TitanSpeakerman` hoạt động **y hệt 9 turret thường** — nằm trong Turrets Shop, **KHÔNG có giới hạn kho global 999**, mỗi lần shop restock roll `Chance`/`StockAmount`, mua được bằng Cash (và Robux) khi `Stock > 0`. Bỏ hoàn toàn "cơ chế 2 lớp stock". 3 turret `Upgraded...` **chưa đụng tới** trong đợt này (vẫn mua Robux qua pad chạm như hiện tại).

DPS = `Damage * FireRate` (khớp với cách `TurretController.lua` tính cooldown bắn: `1 / (FireRate * waveSpeedMultiplier)`).

---

## Bảng đối chiếu chi tiết

| STT | Turret | Price (cur → target) | Damage (cur → target) | Range (cur → target) | FireRate (cur → target) | DPS (cur → target) | Stock (cur → target) | Chance (cur → target) | Trạng thái |
|---|---|---|---|---|---|---|---|---|---|
| 1 | CameraGuy | 200 → 200 | 50 → 50 | 10 → 10 | 1 → 1 | 50 → 50 | 1-5 → 1-5 | 100% → 100% | ✅ Khớp hoàn toàn |
| 2 | EngineerCameraGuy | ~~500→500~~ **800** (master) | ~~100~~ **250** (master) | ~~12→14~~ **10** (master) | ~~0.5→0.8~~ **1** (master) | **250** (master) | 1-5 → 1-5 | 90% → 90% | 🔁 Đã lấy chỉ số master khi merge — target cũ bỏ |
| 3 | SpeakerGuy | ~~1,000~~ **6,400** (master) | ~~175~~ **2,500** (master) | ~~18→16~~ **11** (master) | ~~2~~ **1** (master) | **2,500** (master) | 1-5 → 1-5 | 80% → 80% | 🔁 Đã lấy chỉ số master khi merge — target cũ bỏ |
| 4 | TvGuy | 2,500 → 2,500 | 250 → 250 | 20 → 20 | 2 → 2 | 500 → 500 | 1-5 → 1-5 | 70% → 70% | ✅ Khớp hoàn toàn |
| 5 | NinjaCameraGuy | 4,000 → 4,000 | 400 → 400 | **16 → 12** | **2 → 4** | **800 → 1,600** | 1-5 → 1-5 | 60% → 60% | ⚠️ Lệch Range/FireRate/DPS (thiếu gấp đôi) |
| 6 | LargeScientistCameraman | 7,000 → 7,000 | 700 → 700 | 24 → 24 | **1 → 1.5** | **700 → 1,050** | 1-5 → 1-5 | 50% → 50% | ⚠️ Lệch FireRate/DPS |
| 7 | LargeSpeakerGuy | 15,000 → 15,000 | 1,000 → 1,000 | 28 → 28 | 2 → 2 | 2,000 → 2,000 | 1-5 → 1-5 | 40% → 40% | ✅ Khớp hoàn toàn |
| 8 | LargeTvGuy | 30,000 → 30,000 | 1,500 → 1,500 | 30 → 30 | **1 → 1.5** | **1,500 → 2,250** | 1-5 → 1-5 | 30% → 30% | ⚠️ Lệch FireRate/DPS |
| 9 | LaserCameramanCar | 60,000 → 60,000 | 3,000 → 3,000 | **35 → 32** | **10 → 5** | **30,000 → 15,000** | **1-5 → 1-3** | 20% → 20% | ⚠️ Lệch Range/FireRate/DPS (đang gấp đôi)/Stock |
| 10 | TitanCameraGuy | **∅ → 80,000** | 2,500 → 2,500 | 35 (đã sửa) | 2.5 (đã sửa) | 6,250 | **global 999 → roll 1-3 (KHÔNG giới hạn 999)** | **∅ → 18%** | ✅ Vào shop như turret thường (`InShop = true`) |
| 11 | TitanTVMan | **∅ → 150,000** | 3,500 → 3,500 | 38 (đã sửa) | 2.5 (giữ) | 8,750 | **global 999 → roll 1-3 (KHÔNG giới hạn 999)** | **∅ → 14%** | ✅ Vào shop như turret thường (`InShop = true`) |
| 12 | TitanSpeakerman | **∅ → 250,000** | 4,500 → 4,500 | 40 (đã sửa) | 3 (đã sửa) | 13,500 | **global 999 → roll 1-2 (KHÔNG giới hạn 999)** | **∅ → 10%** | ✅ Vào shop như turret thường (`InShop = true`) |
| 13 | UpgradedTitanTVMan | 400,000 (field đã thêm, chưa dùng) | 6,500 | 42 (đã sửa) | 3 | 19,500 | **không giới hạn** (chưa vào shop) | 8% (chưa dùng) | ⏸️ Ngoài phạm vi đợt này — vẫn mua Robux qua pad |
| 14 | UpgradedTitanCameraGuy | 650,000 (field đã thêm, chưa dùng) | 8,500 | 44 (đã sửa) | 3.5 (đã sửa) | 29,750 | **không giới hạn** (chưa vào shop) | 6% (chưa dùng) | ⏸️ Ngoài phạm vi đợt này — vẫn mua Robux qua pad |
| 15 | UpgradedTitanSpeakerman | 1,000,000 (field đã thêm, chưa dùng) | 12,000 | 46 (đã sửa) | 4 (đã sửa) | 48,000 | **không giới hạn** (chưa vào shop) | 4% (chưa dùng) | ⏸️ Ngoài phạm vi đợt này — vẫn mua Robux qua pad |

`∅` = field này **chưa tồn tại** trong code hiện tại.

---

## Nhận xét chính

### 1. Điểm đã khớp sẵn (không cần sửa)
- **Damage** khớp target ở 7/9 turret thường + toàn bộ Titan — không cần đổi damage (trừ EngineerCameraGuy/SpeakerGuy đã theo master).
- **Price / Chance** khớp target ở 7/9 turret thường (EngineerCameraGuy/SpeakerGuy theo master).
- 3 turret khớp hoàn toàn mọi field: **CameraGuy, TvGuy, LargeSpeakerGuy**.

> **EngineerCameraGuy** và **SpeakerGuy** đã bị master rebalance khi merge → **đã lấy chỉ số master**, bỏ target cũ. Các nhận xét dưới đây **không còn áp cho 2 con này**.

### 2. Range: đa số bị lệch, không theo một chiều cố định
- NinjaCameraGuy hiện có Range **thấp hơn** target.
- Toàn bộ tier Titan (10-15) hiện Range **cao hơn** target 4-5 studs.
→ Cần chỉnh Range **theo từng turret**, không thể áp 1 công thức chung.

### 3. FireRate/DPS: turret thường thiếu FireRate ở nhiều bậc giữa
- NinjaCameraGuy, LargeScientistCameraman, LargeTvGuy đều đang có FireRate **thấp hơn** target → DPS thực tế thấp hơn thiết kế (NinjaCameraGuy thấp hơn **một nửa**: 800 vs 1,600).
- Ngược lại, **LaserCameramanCar đang FireRate gấp đôi target** (10 vs 5) → DPS đang **gấp đôi** thiết kế (30,000 vs 15,000) — đây là turret duy nhất OP hơn thiết kế thay vì yếu hơn.
- Toàn bộ tier Titan (10-15) đều FireRate thấp hơn target một chút (trừ TitanTVMan và UpgradedTitanTVMan đã khớp).

### 4. Turret Titan (Limited) — 3 con đầu chuyển sang hoạt động như turret thường

**Mục tiêu (chốt mới):** `TitanCameraGuy` / `TitanTVMan` / `TitanSpeakerman` = **giống hệt 9 turret thường**:
- Nằm trong Turrets Shop.
- Mỗi lần shop restock → roll `Chance` / `StockAmount` (18% / 14% / 10%, roll 1-3 / 1-3 / 1-2). Trúng → có hàng đợt đó; trượt → `Stock: 0` đợi đợt sau.
- Mua bằng **Cash** (`Price`) khi `Stock > 0`. Vẫn giữ nút **Robux** song song.
- **KHÔNG** có kho global 999, **KHÔNG** DataStore, **KHÔNG** "2 lớp stock". Bỏ hoàn toàn.

Việc phải làm — ✅ tất cả đã code xong:
- `LimitedItems` có `Price` / `Chance` / `StockAmount` + `InShop = true` cho 3 con shop (mục A/B).
- `BlocksShopController.Restock` roll 3 con này y như turret thường, không kẹp gì (mục C).
- `BlocksShopController.onPurchaseRequest` xử lý 3 con này y như turret thường (mục D2).
- `LimitedTurretController`: `STOCK_KEYS` rỗng, đường Robux grant thẳng không đụng 999 (mục D1).
- Client: mục E (đã đúng từ trước, không cần sửa).
- Còn lại (không bắt buộc): dọn 3 frame `LimitedTurret*` cũ trong Studio.

**3 turret `Upgraded...`:** ngoài phạm vi đợt này. Vẫn mua Robux qua pad chạm (`UpgradedTitanTouchHandler`), không vào shop. Field `Price`/`Chance`/`StockAmount` đã thêm ở mục B nhưng **chưa dùng** (không sao, để dành).

---

## Checklist việc cần làm (chỉ thực hiện khi được yêu cầu)

> Quyết định thiết kế (chi tiết ở mục cuối):
> 1. **Giữ song song Cash + Robux** cho mua 3 turret Titan shop.
> 2. **KHÔNG có kho global 999 / KHÔNG 2 lớp stock.** 3 turret Titan shop chỉ dùng cơ chế roll `Chance`/`StockAmount` mỗi restock, y hệt 9 turret thường.
> 3. **Cách A — đưa 3 turret Titan vào chung Turrets Shop hiện có** (dùng chung `profile.Data.BlockShopStock`, remote `PurchaseBlockItem` / `GetBlockShopStocks`, timer restock 180s). Không làm HUD / frame riêng.
>
> ✅ **A, B, C, D1, D2, E đã code xong theo bản mới (không kho global 999).** Còn lại: dọn 3 frame `LimitedTurret*` cũ trong Studio (không bắt buộc).

### A. `src/ReplicatedStorage/Modules/ItemConfigurations.lua` — bảng `ItemConfigurations` (9 turret thường) — ✅ ĐÃ LÀM

> ⚠️ **`EngineerCameraGuy` và `SpeakerGuy` đã bị master rebalance** (commit `89efc50` / `74426e9`) với chỉ số khác hẳn (Damage/Price ×10–25). Khi merge master vào nhánh này, **đã lấy chỉ số của master** cho 2 con này, bỏ sửa đổi Range/FireRate ở đây. Bảng target cũ cho 2 con này không còn hiệu lực.

- [x] ~~`EngineerCameraGuy` → `Range` 12 → 14~~ → **theo master: Price 800, Damage 250, Range 10, FireRate 1**
- [x] ~~`EngineerCameraGuy` → `FireRate` 0.5 → 0.8~~ → (như trên)
- [x] ~~`SpeakerGuy` → `Range` 18 → 16~~ → **theo master: Price 6400, Damage 2500, Range 11, FireRate 1**
- [x] `NinjaCameraGuy` → `Range` 16 → **12**
- [x] `NinjaCameraGuy` → `FireRate` 2 → **4**
- [x] `LargeScientistCameraman` → `FireRate` 1 → **1.5**
- [x] `LargeTvGuy` → `FireRate` 1 → **1.5**
- [x] `LaserCameramanCar` → `Range` 35 → **32**
- [x] `LaserCameramanCar` → `FireRate` 10 → **5**
- [x] `LaserCameramanCar` → `StockAmount.Max` 5 → **3**
- [x] Không đụng `Damage` / `Price` / `Chance` của nhóm này (đã khớp).
- [x] Giữ nguyên `CameraGuy`, `TvGuy`, `LargeSpeakerGuy` (khớp hoàn toàn mọi field).

### B. `src/ReplicatedStorage/Modules/ItemConfigurations.lua` — bảng `LimitedItems` (6 turret Titan) — ✅ ĐÃ LÀM

Sửa số `Range` / `FireRate`:

- [x] `TitanCameraGuy` → `Range` 40 → **35** ; `FireRate` 2 → **2.5**
- [x] `TitanTVMan` → `Range` 42 → **38** (FireRate 2.5 giữ nguyên)
- [x] `TitanSpeakerman` → `Range` 44 → **40** ; `FireRate` 2.5 → **3**
- [x] `UpgradedTitanTVMan` → `Range` 46 → **42** (FireRate 3 giữ nguyên)
- [x] `UpgradedTitanCameraGuy` → `Range` 48 → **44** ; `FireRate` 3 → **3.5**
- [x] `UpgradedTitanSpeakerman` → `Range` 50 → **46** ; `FireRate` 3.5 → **4**

Thêm field mới cho **cả 6 turret** (thứ tự: TitanCameraGuy · TitanTVMan · TitanSpeakerman · UpgradedTitanTVMan · UpgradedTitanCameraGuy · UpgradedTitanSpeakerman):

- [x] Thêm `Price` (Cash): **80,000 · 150,000 · 250,000 · 400,000 · 650,000 · 1,000,000**
- [x] Thêm `Chance`: **18% · 14% · 10% · 8% · 6% · 4%**
- [x] Thêm `StockAmount = {Min = ..., Max = ...}`: **1-3 · 1-3 · 1-2 · 1-2 · 1-1 · 1-1**
- [x] **Thêm `InShop = true`** cho **3 con đầu** (`TitanCameraGuy`, `TitanTVMan`, `TitanSpeakerman`) — cờ để mục C biết turret nào vào Turrets Shop. 3 con `Upgraded...` **không** có cờ này.

> `Chance` / `StockAmount` của 3 con `Upgraded...` (8%/6%/4%, 1-2/1-1/1-1) hiện **chưa dùng** (chưa `InShop`). Để dành, không sao.

### C. `src/ServerScriptService/Controllers/BlocksShopController.lua` — ✅ ĐÃ LÀM (bản mới)

- [x] Thêm `local LimitedItems`.
- [x] `Restock()` roll thêm turret `LimitedItems` **có `config.InShop`** vào chung `profile.Data.BlockShopStock`, y hệt turret thường — không kho global, không kẹp gì:
  ```lua
  for itemId, config in pairs(LimitedItems) do
      if config.InShop and config.Chance and config.StockAmount then
          if math.random() * 100 <= config.Chance then
              newStock[itemId] = math.random(config.StockAmount.Min, config.StockAmount.Max)
          else
              newStock[itemId] = 0
          end
      end
  end
  ```
- [x] Turret không có `InShop` (3 con `Upgraded...`) → không set `newStock[itemId]` (để `nil`) → client ẩn card.
- [x] Bỏ `local LimitedTurretController` + dòng gán ở `Init` (không còn ai gọi).

> **Cơ chế sau sửa** (giống hệt 9 turret thường): mỗi restock, 3 con `Titan*` luôn có entry trong `BlockShopStock` — trúng Chance → `1..Max`, trượt → `0`. Không còn giới hạn 999.

### D. Server — luồng mua turret Titan

**D1. `src/ServerScriptService/Controllers/LimitedTurretController.lua` — ✅ ĐÃ LÀM**

- [x] `STOCK_KEYS` giờ **rỗng** (`{}`). `ProcessPurchase` (đường Robux) với mọi limited turret rơi vào nhánh `else` "no stock limit: grant directly" → mua Robux không giới hạn, đúng ý.
- [x] Xoá 2 hàm đã thêm ở đợt trước (không ai gọi): `IsStockTracked`, `ConsumeStock`.
- [x] `GetStock` / remote `GetLimitedTurretStock` / event `LimitedTurretStockUpdated`: **giữ nguyên** — `GetStock` giờ luôn trả `0` (do `STOCK_KEYS` rỗng), chỉ còn phục vụ frame HUD Titan cũ. Chết hẳn khi dọn UI cũ (mục E).
- [x] **KHÔNG** đụng logic cho 3 con `Upgraded...` — chúng vẫn ở nhánh `else` như hiện tại.

> `ProcessPurchase` chỉ đổi ở chỗ mọi turret giờ rơi vào nhánh `else` (grant thẳng). Nhánh `if key` thành code chết nhưng vẫn để lại (không hại).

**D2. `BlocksShopController.onPurchaseRequest` (đường Cash) — ✅ ĐÃ LÀM (bản mới)**

- [x] Gộp `local config = ItemConfigurations[itemId] or LimitedItems[itemId]` — bỏ cờ `isLimited`.
- [x] Bỏ khối check `LimitedTurretController:GetStock(itemId) <= 0` → "sold out".
- [x] Bỏ khối `LimitedTurretController:ConsumeStock(itemId)` + hoàn `Cash` khi fail.
- [x] Kết quả: 3 con `Titan*` shop mua = check `playerStock[itemId] > 0` + đủ `Cash` → trừ tiền, `playerStock -= 1`, cấp turret. **Y hệt turret thường.**

> Sau sửa: đường Cash cho 3 con Titan shop = **giống hệt** đường Cash cho 9 turret thường. Đường Robux đi qua `ProcessPurchase` nhánh `else` = grant thẳng, không trừ `playerStock` (giống mua Robux 1 turret thường — Robux vốn không đụng kho shop).

### E. Client — `src/StarterGui/GUI/Frames/TurretsShop/TurretsShopHandler.client.lua` — ✅ ĐÃ LÀM (không cần sửa)

- [x] Thêm `local LimitedItems = ItemConfigsModule.LimitedItems`.
- [x] Trong `populateShop()`, sau vòng lặp `ItemConfigurations`, lặp thêm `LimitedItems` (`Type == "Turrets"`) và `table.insert` vào `itemsToDisplay` (entry `{Id, Config}` — **giống hệt turret thường**, không cờ riêng). Sort theo `Price` chung → Titan nằm cuối danh sách.
- [x] Điều kiện hiện card: `currentStocks[itemId] ~= nil` (server có roll turret đó ở mục C).
  - `Stock > 0` → nút `Buy` bật, mua được. `Stock = 0` → nút xám, **card vẫn hiện**, chờ restock sau — giống hệt 9 turret thường.
  - 3 con `Upgraded...` không có `InShop` → mục C không roll → `currentStocks[itemId] == nil` → **không hiện card**. Đúng ý.
- [x] Dùng **chung card** `Templates/TurretsTemplate` với turret thường. Phần dựng thẻ sẵn có đọc `config.ImageId / DisplayName / Price / ProductID`; `LimitedItems` đã có đủ (Price thêm ở mục B).
  - `BuyButton` (Cash) → `purchaseItemEvent:FireServer(itemId)` (đường D2) — code cũ.
  - `RobuxButton` → `PromptProductPurchase(player, config.ProductID)` — code cũ.
  - `ItemStock` hiện `Stock: N`, disable `BuyButton` khi `= 0` — code cũ.

> Kết quả: `TitanCameraGuy / TitanTVMan / TitanSpeakerman` **luôn nằm trong shop**, hiện số stock như mọi turret khác — hết stock thì xám nút, có stock thì mua được.
>
> ⚠️ Cần **1 lần restock** sau khi sync code mới thì `currentStocks` mới có key Titan (data `BlockShopStock` cũ chưa có). Đợi hết timer 180s hoặc bấm nút restock Robux.

**Dọn dẹp UI cũ (không bắt buộc, nhưng nên):**

- [ ] 3 frame HUD/shop riêng cho 3 con shop giờ thừa: `LimitedTurret` (TitanCameraGuy), `LimitedTurretTitanTVMan`, `LimitedTurretTitanSpeakerman`. Chúng vẫn gọi Robux + đọc `GetLimitedTurretStock` (giờ trả 0 sau khi bỏ khỏi `STOCK_KEYS`) → sẽ hiện "SOLD OUT FOREVER". **Nên gỡ 3 frame này** (hoặc ít nhất ẩn đi) vì 3 con đã có trong Turrets Shop.
- [ ] `UpgradedTitanTouchHandler.client.lua` (pad chạm mua 3 con `Upgraded...`) — **GIỮ NGUYÊN**, đây vẫn là cách mua chính cho nhóm Upgraded ở đợt này.

### Không cần sửa

- [ ] `TurretController.lua` — chỉ dùng để đối chiếu công thức DPS, không thay đổi.
- [ ] `Damage` của toàn bộ 15 turret.

### ✅ Quyết định thiết kế (đã chốt — bản mới)

Áp cho **3 turret**: `TitanCameraGuy`, `TitanTVMan`, `TitanSpeakerman`.

1. **Mua song song Cash + Robux.**
   Cày chay mua bằng `Price` (Cash) khi shop có hàng; ai muốn nhanh dùng Robux (`ProductID`). Robux mua được bất cứ lúc nào, không phụ thuộc stock shop.

2. **Stock = y hệt 9 turret thường. KHÔNG kho global 999, KHÔNG DataStore, KHÔNG 2 lớp.**
   - Mỗi lần shop restock (180s): roll `Chance` → trúng thì `Stock = random(StockAmount.Min, Max)`, trượt thì `Stock = 0`.
   - Card **luôn hiển thị** trong Turrets Shop. `Stock > 0` → mua được bằng Cash. `Stock = 0` → xám nút `Buy`, chờ đợt sau.
   - Mua bằng Cash trừ `Stock` đợt đó 1 đơn vị (như turret thường). Mua bằng Robux **không** đụng `Stock` (như turret thường mua Robux).
   - Không có khái niệm "hết vĩnh viễn".

3. **Cách A — dùng chung hạ tầng Turrets Shop hiện có.**
   - 3 turret là entry trong `LimitedItems` (đánh dấu `InShop = true`), nhưng dùng chung: `profile.Data.BlockShopStock`, remote `PurchaseBlockItem` / `GetBlockShopStocks` / `UpdateBlockStocks`, timer restock 180s.
   - Đường Cash: `PurchaseBlockItem` → `BlocksShopController.onPurchaseRequest` (tra `LimitedItems`, xử lý y như turret thường).
   - Đường Robux: `PromptProductPurchase` → `ProcessReceipt` → `WeaponsShopController` → `LimitedTurretController:ProcessPurchase` nhánh `else` "grant directly".
   - Không HUD/frame riêng. Gỡ 3 frame `LimitedTurret*` cũ (mục E — dọn dẹp).

### ⏸️ Ngoài phạm vi đợt này

- 3 turret `Upgraded...` (`UpgradedTitanTVMan`, `UpgradedTitanCameraGuy`, `UpgradedTitanSpeakerman`): giữ nguyên — mua Robux qua pad chạm (`UpgradedTitanTouchHandler`), không vào shop, không giới hạn. Field `Price`/`Chance`/`StockAmount` đã thêm ở mục B nhưng chưa dùng.
- Nếu sau này muốn đưa 3 con Upgraded vào shop: chỉ cần thêm `InShop = true` cho chúng — cùng cơ chế, không cần code thêm.
