# So sánh hệ thống Turret hiện tại vs bảng thông số mới

Nguồn code đối chiếu:
- `src/ReplicatedStorage/Modules/ItemConfigurations.lua` (`ItemConfigurations` = 9 turret thường, `LimitedItems` = 6 turret Titan)
- `src/ServerScriptService/Controllers/BlocksShopController.lua` (roll `Chance`/`StockAmount` khi restock; `onPurchaseRequest` = đường mua bằng Cash)
- `src/ServerScriptService/Controllers/LimitedTurretController.lua` (kho global DataStore + `ProcessPurchase` cho đường Robux)
- `src/ServerScriptService/Controllers/WeaponsShopController.lua` (`ProcessReceipt` định tuyến purchase Robux → `LimitedTurretController:ProcessPurchase`)
- `src/StarterGui/GUI/Frames/TurretsShop/TurretsShopHandler.client.lua` (UI Turrets Shop — nơi turret Titan sẽ hiện theo Cách A)

DPS = `Damage * FireRate` (khớp với cách `TurretController.lua` tính cooldown bắn: `1 / (FireRate * waveSpeedMultiplier)`).

---

## Bảng đối chiếu chi tiết

| STT | Turret | Price (cur → target) | Damage (cur → target) | Range (cur → target) | FireRate (cur → target) | DPS (cur → target) | Stock (cur → target) | Chance (cur → target) | Trạng thái |
|---|---|---|---|---|---|---|---|---|---|
| 1 | CameraGuy | 200 → 200 | 50 → 50 | 10 → 10 | 1 → 1 | 50 → 50 | 1-5 → 1-5 | 100% → 100% | ✅ Khớp hoàn toàn |
| 2 | EngineerCameraGuy | 500 → 500 | 100 → 100 | **12 → 14** | **0.5 → 0.8** | **50 → 80** | 1-5 → 1-5 | 90% → 90% | ⚠️ Lệch Range/FireRate/DPS |
| 3 | SpeakerGuy | 1,000 → 1,000 | 175 → 175 | **18 → 16** | 2 → 2 | 350 → 350 | 1-5 → 1-5 | 80% → 80% | ⚠️ Lệch Range |
| 4 | TvGuy | 2,500 → 2,500 | 250 → 250 | 20 → 20 | 2 → 2 | 500 → 500 | 1-5 → 1-5 | 70% → 70% | ✅ Khớp hoàn toàn |
| 5 | NinjaCameraGuy | 4,000 → 4,000 | 400 → 400 | **16 → 12** | **2 → 4** | **800 → 1,600** | 1-5 → 1-5 | 60% → 60% | ⚠️ Lệch Range/FireRate/DPS (thiếu gấp đôi) |
| 6 | LargeScientistCameraman | 7,000 → 7,000 | 700 → 700 | 24 → 24 | **1 → 1.5** | **700 → 1,050** | 1-5 → 1-5 | 50% → 50% | ⚠️ Lệch FireRate/DPS |
| 7 | LargeSpeakerGuy | 15,000 → 15,000 | 1,000 → 1,000 | 28 → 28 | 2 → 2 | 2,000 → 2,000 | 1-5 → 1-5 | 40% → 40% | ✅ Khớp hoàn toàn |
| 8 | LargeTvGuy | 30,000 → 30,000 | 1,500 → 1,500 | 30 → 30 | **1 → 1.5** | **1,500 → 2,250** | 1-5 → 1-5 | 30% → 30% | ⚠️ Lệch FireRate/DPS |
| 9 | LaserCameramanCar | 60,000 → 60,000 | 3,000 → 3,000 | **35 → 32** | **10 → 5** | **30,000 → 15,000** | **1-5 → 1-3** | 20% → 20% | ⚠️ Lệch Range/FireRate/DPS (đang gấp đôi)/Stock |
| 10 | TitanCameraGuy | **∅ → 80,000** | 2,500 → 2,500 | **40 → 35** | **2 → 2.5** | **5,000 → 6,250** | **global 999 → 1-3** | **∅ → 18%** | ❌ Thiếu Price/Chance, sai cơ chế Stock, lệch Range/FireRate |
| 11 | TitanTVMan | **∅ → 150,000** | 3,500 → 3,500 | **42 → 38** | 2.5 → 2.5 | 8,750 → 8,750 | **global 999 → 1-3** | **∅ → 14%** | ❌ Thiếu Price/Chance, sai cơ chế Stock, lệch Range |
| 12 | TitanSpeakerman | **∅ → 250,000** | 4,500 → 4,500 | **44 → 40** | **2.5 → 3** | **11,250 → 13,500** | **global 999 → 1-2** | **∅ → 10%** | ❌ Thiếu Price/Chance, sai cơ chế Stock, lệch Range/FireRate |
| 13 | UpgradedTitanTVMan | **∅ → 400,000** | 6,500 → 6,500 | **46 → 42** | 3 → 3 | 19,500 → 19,500 | **không giới hạn → 1-2** | **∅ → 8%** | ❌ Thiếu Price/Chance/Stock, lệch Range |
| 14 | UpgradedTitanCameraGuy | **∅ → 650,000** | 8,500 → 8,500 | **48 → 44** | **3 → 3.5** | **25,500 → 29,750** | **không giới hạn → 1-1** | **∅ → 6%** | ❌ Thiếu Price/Chance/Stock, lệch Range/FireRate |
| 15 | UpgradedTitanSpeakerman | **∅ → 1,000,000** | 12,000 → 12,000 | **50 → 46** | **3.5 → 4** | **42,000 → 48,000** | **không giới hạn → 1-1** | **∅ → 4%** | ❌ Thiếu Price/Chance/Stock, lệch Range/FireRate |

`∅` = field này **chưa tồn tại** trong code hiện tại.

---

## Nhận xét chính

### 1. Điểm đã khớp sẵn (không cần sửa)
- **Damage khớp 100% ở cả 15 turret** — không cần đổi damage bất kỳ turret nào.
- **Price khớp 100% ở 9 turret thường** (CameraGuy → LaserCameramanCar).
- **Chance khớp 100% ở 9 turret thường.**
- 3 turret khớp hoàn toàn mọi field: **CameraGuy, TvGuy, LargeSpeakerGuy**.

### 2. Range: đa số bị lệch, không theo một chiều cố định
- Tier thấp (EngineerCameraGuy, NinjaCameraGuy) hiện có Range **thấp hơn** target.
- SpeakerGuy hiện Range **cao hơn** target.
- Toàn bộ tier Titan (10-15) hiện Range **cao hơn** target 4-5 studs.
→ Cần chỉnh Range **theo từng turret**, không thể áp 1 công thức chung.

### 3. FireRate/DPS: turret thường thiếu FireRate ở nhiều bậc giữa
- EngineerCameraGuy, NinjaCameraGuy, LargeScientistCameraman, LargeTvGuy đều đang có FireRate **thấp hơn** target → DPS thực tế thấp hơn thiết kế (NinjaCameraGuy thấp hơn **một nửa**: 800 vs 1,600).
- Ngược lại, **LaserCameramanCar đang FireRate gấp đôi target** (10 vs 5) → DPS đang **gấp đôi** thiết kế (30,000 vs 15,000) — đây là turret duy nhất OP hơn thiết kế thay vì yếu hơn.
- Toàn bộ tier Titan (10-15) đều FireRate thấp hơn target một chút (trừ TitanTVMan và UpgradedTitanTVMan đã khớp).

### 4. Turret Titan (Limited) — thiếu cả field lẫn sai cơ chế, không chỉ sai số
Đây là phần lệch nghiêm trọng nhất, không chỉ là chỉnh số:

- **Không có field `Price` (Cash) nào trong `LimitedItems`** — hiện tại cả 6 turret Titan chỉ mua được qua Robux (`ProductID` + `LimitedTurretController:ProcessPurchase`), hoàn toàn không có đường mua bằng Cash. Bảng thông số mới lại yêu cầu giá Cash cụ thể (80,000 → 1,000,000) cho tất cả 6 turret này.
  → **Đã chốt:** giữ **song song cả 2 đường mua** — người cày chay mua bằng Cash (`Price`), người có kinh phí mua bằng Robux (`ProductID`) để lên turret mạnh nhanh hơn. Cả 2 đường đều trừ chung một kho stock.
- **Không có field `Chance`** trong `LimitedItems` — bảng `BlocksShopController.lua` chỉ roll `Chance`/`StockAmount` cho các item nằm trong `ItemConfigurations`, không đụng tới `LimitedItems` → Titan turret nằm ngoài hoàn toàn cơ chế roll shop hiện tại.
- **Cơ chế Stock đang là 2 hệ thống khác nhau, và không đồng nhất giữa 6 turret:**
  - `TitanCameraGuy`, `TitanTVMan`, `TitanSpeakerman` → có trong `STOCK_KEYS` của `LimitedTurretController` → dùng **1 kho hàng dùng chung toàn server** lưu DataStore (mặc định 999, trừ dần mỗi lần bất kỳ ai mua, không bao giờ hồi lại).
  - `UpgradedTitanTVMan`, `UpgradedTitanCameraGuy`, `UpgradedTitanSpeakerman` → **không nằm trong `STOCK_KEYS`** → theo code hiện tại, các turret này **mua được không giới hạn số lần** (`ProcessPurchase` rơi vào nhánh `else` "No stock limit: grant directly").
  - Bảng thông số mới muốn cả 6 turret có thêm cơ chế **Stock roll theo Min-Max mỗi lần shop restock** (1-3 / 1-2 / 1-1), giống turret thường.
  - → **Đã chốt:** giữ **song song cả 2 lớp stock** — (a) kho global toàn server (`STOCK_KEYS` / DataStore) làm giới hạn cứng tổng số bản từng tồn tại, áp cho **cả 6 turret** (hiện mới có 3); (b) `StockAmount` roll Min-Max mỗi đợt restock quyết định số lượng hiện lên shop đợt đó. Mua bằng Cash hay Robux đều trừ cả 2. Khi kho global về 0 thì turret không xuất hiện dù roll ra bao nhiêu.

---

## Checklist việc cần làm (chỉ thực hiện khi được yêu cầu)

> Quyết định thiết kế (chi tiết ở mục cuối):
> 1. **Giữ song song Cash + Robux** cho mua turret Titan.
> 2. **Giữ song song 2 lớp stock** (kho global toàn server + roll Min-Max mỗi restock).
> 3. **Cách A — đưa turret Titan vào chung Turrets Shop hiện có** (dùng chung `profile.Data.BlockShopStock`, remote `PurchaseBlockItem` / `GetBlockShopStocks`, timer restock 180s). Không làm HUD / frame riêng.

### A. `src/ReplicatedStorage/Modules/ItemConfigurations.lua` — bảng `ItemConfigurations` (9 turret thường) — ✅ ĐÃ LÀM

- [x] `EngineerCameraGuy` → `Range` 12 → **14**
- [x] `EngineerCameraGuy` → `FireRate` 0.5 → **0.8**
- [x] `SpeakerGuy` → `Range` 18 → **16**
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

### C. `src/ServerScriptService/Controllers/BlocksShopController.lua` — ✅ ĐÃ LÀM

- [x] `Restock()` roll thêm `Chance` / `StockAmount` cho turret `LimitedItems`, ghi vào chung `profile.Data.BlockShopStock` (cùng chu kỳ 180s).
- [x] Kẹp số roll bằng kho global: `finalStock = max(0, min(rollMinMax, LimitedTurretController:GetStock(itemId)))`. Chỉ gọi `GetStock` khi roll Chance trúng.
- [x] Thêm `local LimitedItems` + `local LimitedTurretController` + gán ở `Init`.
- [x] Vòng lặp roll chỉ chạy cho turret **đang được track kho global** (`LimitedTurretController:IsStockTracked(itemId)` — hàm mới ở `LimitedTurretController.lua`, `STOCK_KEYS[itemId] ~= nil`). Turret chưa track → **không set** `newStock[itemId]` (để `nil`).

> **Cơ chế** (giống hệt 9 turret thường):
> - `TitanCameraGuy / TitanTVMan / TitanSpeakerman` (đã có `STOCK_KEYS`): **mỗi restock luôn có 1 entry** trong `BlockShopStock` — roll Chance trúng → `1..Max`, trượt → `0`.
> - 3 turret `Upgraded...` (chưa có key): không có entry (`nil`) → client ẩn hẳn card cho tới khi D1 thêm key.

### D. Server — luồng mua turret Titan (Cách A)

**D1. `src/ServerScriptService/Controllers/LimitedTurretController.lua` — CHƯA LÀM (đụng luồng tiền thật, để sau)**

- [ ] Thêm cả 6 turret Titan vào `STOCK_KEYS` (hiện chỉ có `TitanCameraGuy`, `TitanTVMan`, `TitanSpeakerman`) → cả 6 đều có kho global toàn server lưu DataStore.
- [ ] `ProcessPurchase` (đường **Robux**, gọi từ `WeaponsShopController.processReceipt`): sau khi trừ kho global thành công, **trừ thêm** `profile.Data.BlockShopStock[itemId]` 1 đơn vị (nếu > 0) và `updateStocksEvent:FireClient` để shop client đồng bộ.
- [ ] Bỏ nhánh `else` "No stock limit: grant directly" — giờ cả 6 đều có key, không còn turret nào mua không giới hạn.
- [ ] (Tùy chọn) tách phần "cấp turret vào `BlockInventory` + thông báo + trừ 2 lớp stock" ra 1 hàm `GrantTurret(player, itemId)` để đường Cash (D2) và đường Robux dùng chung.

> ⚠️ D1 đổi hành vi hiện có: 3 turret `Upgraded...` từ "mua Robux vô hạn" → "giới hạn 999", và `ProcessPurchase` (xử lý giao dịch Robux thật) phải test kỹ trên nhánh trước khi merge.

**D2. `BlocksShopController.onPurchaseRequest` (đường Cash) — ✅ ĐÃ LÀM**

- [x] Khi `ItemConfigurations[itemId]` nil → tra tiếp `LimitedItems[itemId]`, đặt cờ `isLimited`.
- [x] Giữ nguyên check tồn kho đợt `playerStock[itemId] > 0` (áp cho cả item thường lẫn Titan vì `config.Unlimited` nil).
- [x] Thêm check kho global (chỉ khi `isLimited`): `LimitedTurretController:GetStock(itemId) > 0`.
- [x] Trong nhánh mua thành công, sau khi trừ `Cash`: nếu `isLimited` → gọi `LimitedTurretController:ConsumeStock(itemId)`; fail (vừa hết sạch) → **hoàn `Cash`**, báo "sold out", return.
- [x] Phần còn lại (trừ `playerStock`, cấp `BlockInventory`, thông báo, onboarding) tái dùng nguyên code sẵn có.
- [x] `LimitedTurretController:ConsumeStock(itemId)` — hàm public **mới** trong `LimitedTurretController.lua`: `IncrementAsync(key, -1)` có pcall, trả `true/false`, tự hoàn kho nếu < 0, `FireAllClients` cập nhật. Thuần cộng thêm, không đụng `ProcessPurchase`.

> Với item thường: `isLimited = false` → toàn bộ code D2 bị bỏ qua → hành vi cũ **không đổi**.
> Đường Robux (`ProcessPurchase`) **chưa** đụng — mua bằng Robux tạm thời chưa trừ tồn kho đợt (lớp 2). Đó là việc của D1.

### E. Client — `src/StarterGui/GUI/Frames/TurretsShop/TurretsShopHandler.client.lua` (Cách A) — ✅ ĐÃ LÀM

- [x] Thêm `local LimitedItems = ItemConfigsModule.LimitedItems`.
- [x] Trong `populateShop()`, sau vòng lặp `ItemConfigurations`, lặp thêm `LimitedItems` (`Type == "Turrets"`) và `table.insert` vào `itemsToDisplay` (entry `{Id, Config}` — **giống hệt turret thường**, không cờ riêng). Sort theo `Price` chung → Titan (80k–1M) nằm cuối danh sách.
- [x] Điều kiện hiện card: `currentStocks[itemId] ~= nil` (server có track turret đó ở mục C).
  - `Stock > 0` → nút `Buy` bật, mua được. `Stock = 0` → nút xám, **card vẫn hiện**, chờ restock sau — giống hệt 9 turret thường.
  - Turret chưa track (`currentStocks[itemId] == nil`, tức 3 con `Upgraded...`) → không hiện, tới khi D1 thêm key vào `STOCK_KEYS`.
- [x] Dùng **chung card** `Templates/TurretsTemplate` với turret thường — không cần card/template riêng. Phần dựng thẻ sẵn có đọc `config.ImageId / DisplayName / Price / ProductID`; `LimitedItems` đã có đủ (Price thêm ở mục B). `config.Unlimited` không có nhưng client không dùng field này.
  - `BuyButton` (Cash) → `purchaseItemEvent:FireServer(itemId)` (đường D2) — code cũ.
  - `RobuxButton` → `PromptProductPurchase(player, config.ProductID)` — code cũ.
  - `ItemStock` hiện `Stock: N`, disable `BuyButton` khi `= 0` — code cũ.

> Kết quả: `TitanCameraGuy / TitanTVMan / TitanSpeakerman` **luôn nằm trong shop**, hiện số stock như mọi turret khác — hết stock thì xám nút, có stock thì mua được. Không còn "roll trúng mới hiện".
>
> ⚠️ Cần **1 lần restock** sau khi sync code mới thì `currentStocks` mới có key Titan (data `BlockShopStock` cũ chưa có). Đợi hết timer 180s hoặc bấm nút restock Robux.

**Dọn dẹp UI cũ (không bắt buộc, nhưng nên):**

- [ ] Các frame HUD/shop riêng lẻ giờ thừa: `LimitedTurret`, `LimitedTurretTitanTVMan`, `LimitedTurretTitanSpeakerman` và `UpgradedTitanTouchHandler.client.lua` (pad chạm để mua). Để lại thì thành **điểm mua song song** (vẫn trừ chung stock nên không vỡ kinh tế, chỉ trùng lặp). Gỡ thì gọn hơn — quyết định sau.

### Không cần sửa

- [ ] `TurretController.lua` — chỉ dùng để đối chiếu công thức DPS, không thay đổi.
- [ ] `Damage` của toàn bộ 15 turret.

### ✅ 3 quyết định thiết kế (đã chốt)

1. **Cơ chế mua Titan — giữ song song Cash + Robux.**
   Người chơi cày chay mua bằng tiền game (`Price`); người có kinh phí, không muốn cày, có thể dùng Robux (`ProductID`) để lên turret mạnh nhanh hơn. Hai đường mua tồn tại song song, cùng trừ chung một kho stock.

2. **Cơ chế Stock Titan — giữ song song 2 lớp.**
   - **Lớp 1 — kho global toàn server** (`STOCK_KEYS` / DataStore trong `LimitedTurretController`): giới hạn cứng tổng số bản từng được tạo ra trên server, áp cho cả 6 turret Titan. Không hồi lại.
   - **Lớp 2 — roll `StockAmount` Min-Max mỗi lần shop restock** (như 9 turret thường): quyết định số lượng mua được trong đợt đó.
   - Số mua được mỗi đợt = `min(roll Min-Max, kho global còn lại)`. Kho global về 0 → `Stock: 0` vĩnh viễn.
   - **Card turret luôn hiển thị trong shop** (miễn là turret đó đang được track — có key `STOCK_KEYS`), hết stock chỉ làm xám nút mua, không ẩn card. Giống hệt 9 turret thường. Mua bằng Cash hay Robux đều trừ cả 2 lớp.

3. **Cách A — đưa turret Titan vào chung Turrets Shop hiện có.**
   - Turret Titan là entry trong `LimitedItems`, nhưng dùng chung hạ tầng của Turrets Shop: `profile.Data.BlockShopStock`, remote `PurchaseBlockItem` / `GetBlockShopStocks` / `UpdateBlockStocks`, timer restock 180s (`BlockShopNextRestock`).
   - Đường Cash: `PurchaseBlockItem` → `BlocksShopController.onPurchaseRequest` (mở rộng để tra `LimitedItems`).
   - Đường Robux: giữ nguyên `PromptProductPurchase` → `ProcessReceipt` → `WeaponsShopController` → `LimitedTurretController:ProcessPurchase` (mở rộng để trừ thêm lớp 2).
   - **Không** làm HUD riêng / frame riêng cho từng turret Titan. Các frame `LimitedTurret*` cũ + `UpgradedTitanTouchHandler` trở thành dư thừa (xem mục E — dọn dẹp).
