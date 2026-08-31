# QA Playtest Checklist — Falcon (Tower Defense)

> **Hướng dẫn:** Mỗi người test điền tên vào cột **Tester**, tick `[x]` khi pass, ghi `[!]` khi có bug rồi tạo issue với tên bước đó.  
> **Session:** _______________________ | **Build/Commit:** _______________________ | **Ngày:** _______________________

---

## 1. KHỞI TẠO & JOIN GAME

| # | Bước kiểm tra | Tester | Pass | Ghi chú |
|---|---------------|--------|------|---------|
| 1.1 | Join server — player không bị stuck, không lỗi LoadCharacter | | [ ] | |
| 1.2 | Profile load thành công, cash và wave hiện đúng số đã save | | [ ] | |
| 1.3 | Plot được gán cho player, không overlap với plot của người khác | | [ ] | |
| 1.4 | Base Core1 (mặc định) xuất hiện đúng vị trí trên plot | | [ ] | |
| 1.5 | Onboarding/tutorial hiện ra đúng lúc với new player | | [ ] | |
| 1.6 | HUD hiện đủ: Cash, Wave indicator, Speed button, Top buttons | | [ ] | |
| 1.7 | Âm thanh background music chạy (không bị lỗi im lặng) | | [ ] | |

---

## 2. HỆ THỐNG WAVE

| # | Bước kiểm tra | Tester | Pass | Ghi chú |
|---|---------------|--------|------|---------|
| 2.1 | Nhấn Start Wave — wave bắt đầu, enemy spawn đúng loại | | [ ] | |
| 2.2 | Enemy đi đúng theo waypoint path, không bị stuck | | [ ] | |
| 2.3 | Multi-path: enemy chọn ngẫu nhiên giữa các path, không bị cùng một path mãi | | [ ] | |
| 2.4 | Enemy đến "End" waypoint → core mất 10 HP | | [ ] | |
| 2.5 | Wave kết thúc khi hết tất cả enemy, hiện kết quả đúng | | [ ] | |
| 2.6 | Wave number tăng đúng (+1 mỗi round) | | [ ] | |
| 2.7 | Wave 40: Boss Toilet xuất hiện đúng | | [ ] | |
| 2.8 | Wave 80: Boss Toilet 2 xuất hiện đúng | | [ ] | |
| 2.9 | Enemy scaling — wave cao hơn, enemy mạnh hơn rõ rệt | | [ ] | |
| 2.10 | Multiplayer: wave sync giữa các player (không lệch nhau) | | [ ] | |

### Speed Multiplier

| # | Bước kiểm tra | Tester | Pass | Ghi chú |
|---|---------------|--------|------|---------|
| 2.11 | Nhấn x1 — game chạy tốc độ bình thường | | [ ] | |
| 2.12 | Nhấn x3 (yêu cầu gamepass) — game chạy nhanh gấp 3 | | [ ] | |
| 2.13 | Player không có gamepass x3 → hiện prompt mua, không cho dùng | | [ ] | |
| 2.14 | Chuyển tốc độ giữa wave không gây lỗi AI hay targeting | | [ ] | |

---

## 3. ENEMY AI

| # | Bước kiểm tra | Tester | Pass | Ghi chú |
|---|---------------|--------|------|---------|
| 3.1 | Enemy di chuyển đến đúng waypoint tiếp theo (không bỏ qua) | | [ ] | |
| 3.2 | Health bar hiện đúng trên đầu enemy | | [ ] | |
| 3.3 | Khi enemy chết: despawn sạch, không để lại model lơ lửng | | [ ] | |
| 3.4 | Enemy drop cash đúng với CashReward trong config | | [ ] | |
| 3.5 | Enemy không xuyên tường/block (collision hoạt động) | | [ ] | |
| 3.6 | Boss enemy có HP và damage phù hợp với tier | | [ ] | |

---

## 4. TURRET (THÁP PHÒNG THỦ)

| # | Bước kiểm tra | Tester | Pass | Ghi chú |
|---|---------------|--------|------|---------|
| 4.1 | Mở shop Turrets — 10 turret thường + 1 limited hiện đúng tên/giá | | [ ] | |
| 4.2 | Mua turret đủ tiền → trừ cash, cho vào tay | | [ ] | |
| 4.3 | Mua turret không đủ tiền → hiện thông báo lỗi, không trừ cash | | [ ] | |
| 4.4 | Placement: turret đặt được trên đất hợp lệ | | [ ] | |
| 4.5 | Placement: turret KHÔNG đặt được trên enemy path / off-plot | | [ ] | |
| 4.6 | Turret tự động target enemy trong range | | [ ] | |
| 4.7 | Turret fire rate và damage khớp với ItemConfigurations | | [ ] | |
| 4.8 | Turret dừng bắn khi không có enemy trong range | | [ ] | |
| 4.9 | Sell/remove turret hoạt động (nếu có tính năng này) | | [ ] | |
| 4.10 | Stock giới hạn turret hiện đúng, hết stock không mua được | | [ ] | |
| 4.11 | Limited turret: chỉ hiện khi đang trong thời gian limited | | [ ] | |
| 4.12 | Animation turret tấn công chạy đúng (không freeze) | | [ ] | |

---

## 5. VŨ KHÍ (WEAPONS)

| # | Bước kiểm tra | Tester | Pass | Ghi chú |
|---|---------------|--------|------|---------|
| 5.1 | Mở Weapons Shop — 16 vũ khí hiện đúng tên/giá | | [ ] | |
| 5.2 | Mua vũ khí bằng cash — trừ đúng tiền, vào inventory | | [ ] | |
| 5.3 | Equip vũ khí từ inventory — hiện lên tay nhân vật | | [ ] | |
| 5.4 | LastEquippedWeapon lưu đúng khi re-join | | [ ] | |
| 5.5 | Vũ khí nhận từ crate — vào inventory đúng | | [ ] | |
| 5.6 | Vũ khí nhận từ spin wheel — vào inventory đúng | | [ ] | |
| 5.7 | Không bị duplicate weapon trong inventory | | [ ] | |
| 5.8 | Debug command give-all-weapons: tất cả 16 vũ khí vào inventory | | [ ] | |

---

## 6. CRATE SYSTEM

| # | Bước kiểm tra | Tester | Pass | Ghi chú |
|---|---------------|--------|------|---------|
| 6.1 | Mở 4 loại crate: Basic / Camera / Speaker / Titan đều hiện đúng | | [ ] | |
| 6.2 | Mua Basic Crate (600 cash) — bắt đầu đếm ngược 60 giây | | [ ] | |
| 6.3 | Countdown timer hiện trên crate model, đếm đúng | | [ ] | |
| 6.4 | Crate tự mở sau khi hết timer, phần thưởng vào inventory | | [ ] | |
| 6.5 | Skip timer bằng Robux hoạt động đúng | | [ ] | |
| 6.6 | Titan Crate (Robux only) — mở ngay lập tức | | [ ] | |
| 6.7 | Giới hạn 3 crate active: không cho mở crate thứ 4 | | [ ] | |
| 6.8 | Re-join: crate đang đếm ngược tiếp tục đúng | | [ ] | |
| 6.9 | Loot table có trọng số hợp lý (không phải mãi nhận item rác) | | [ ] | |

---

## 7. BASES (CORE)

| # | Bước kiểm tra | Tester | Pass | Ghi chú |
|---|---------------|--------|------|---------|
| 7.1 | Core1 (mặc định) xuất hiện và có HP đúng | | [ ] | |
| 7.2 | Mua Core2-5 từ Bases Shop — trừ đúng tiền | | [ ] | |
| 7.3 | Equip base mới — core trên plot thay đổi đúng model | | [ ] | |
| 7.4 | Core HP hiện đúng trên HUD | | [ ] | |
| 7.5 | Core mất HP khi enemy đến End waypoint | | [ ] | |
| 7.6 | Core HP về 0 → Game Over screen hiện ra | | [ ] | |
| 7.7 | OwnedBases lưu đúng sau khi mua (không mất sau re-join) | | [ ] | |
| 7.8 | EquippedBase lưu và tự apply khi join lại | | [ ] | |

---

## 8. BLOCKS (CÔNG TRÌNH PHÒNG THỦ)

| # | Bước kiểm tra | Tester | Pass | Ghi chú |
|---|---------------|--------|------|---------|
| 8.1 | Mở Blocks Shop — các loại block hiện đúng | | [ ] | |
| 8.2 | Đặt block trong plot — không overlap với turret/base | | [ ] | |
| 8.3 | Health bar block hiện đúng | | [ ] | |
| 8.4 | Block bị damage khi enemy tấn công (nếu có) | | [ ] | |
| 8.5 | Block bị phá hủy khi hết HP — despawn sạch | | [ ] | |

---

## 9. KINH TẾ & SHOP

| # | Bước kiểm tra | Tester | Pass | Ghi chú |
|---|---------------|--------|------|---------|
| 9.1 | Cash nhận từ kill enemy hiện ngay trên HUD | | [ ] | |
| 9.2 | Cash display format đúng (1K, 1M, ...) | | [ ] | |
| 9.3 | Tất cả shop mở được bằng proximity prompt / button | | [ ] | |
| 9.4 | Shop restock đúng giờ, số lượng hàng khớp config | | [ ] | |
| 9.5 | Mua Robux pack — nhận đúng số cash | | [ ] | |
| 9.6 | Starter pack — nhận đúng nội dung | | [ ] | |
| 9.7 | Cash multiplier display hiện đúng (nếu đang active) | | [ ] | |
| 9.8 | Promo code nhập đúng → nhận thưởng, không dùng lại được | | [ ] | |

---

## 10. LEADERBOARD

| # | Bước kiểm tra | Tester | Pass | Ghi chú |
|---|---------------|--------|------|---------|
| 10.1 | Wave leaderboard cập nhật sau khi vượt wave cao nhất | | [ ] | |
| 10.2 | Cash leaderboard cập nhật đúng | | [ ] | |
| 10.3 | Tên player hiện đúng trên leaderboard | | [ ] | |
| 10.4 | Leaderboard load khi join (không hiện blank) | | [ ] | |

---

## 11. SPIN WHEEL

| # | Bước kiểm tra | Tester | Pass | Ghi chú |
|---|---------------|--------|------|---------|
| 11.1 | Spin wheel mở được | | [ ] | |
| 11.2 | Quay wheel — animation chạy mượt | | [ ] | |
| 11.3 | Kết quả khớp với ô wheel dừng lại | | [ ] | |
| 11.4 | Phần thưởng vào inventory/cash đúng | | [ ] | |
| 11.5 | Cooldown / giới hạn spin hoạt động | | [ ] | |

---

## 12. SETTINGS & ÂM THANH

| # | Bước kiểm tra | Tester | Pass | Ghi chú |
|---|---------------|--------|------|---------|
| 12.1 | Mở Settings panel — các option hiện ra đầy đủ | | [ ] | |
| 12.2 | Chỉnh volume âm nhạc — thay đổi ngay | | [ ] | |
| 12.3 | Chỉnh volume SFX — thay đổi ngay | | [ ] | |
| 12.4 | Settings lưu đúng sau re-join | | [ ] | |
| 12.5 | Tắt âm thanh hoàn toàn — im lặng, không bug | | [ ] | |

---

## 13. NOTIFICATION & UI POLISH

| # | Bước kiểm tra | Tester | Pass | Ghi chú |
|---|---------------|--------|------|---------|
| 13.1 | Toast notification hiện khi mua item, nhận thưởng | | [ ] | |
| 13.2 | Notification tự biến mất sau vài giây | | [ ] | |
| 13.3 | HUD ẩn đúng trong lúc wave chạy (nếu có HideDuringWave) | | [ ] | |
| 13.4 | Game Over screen hiện đúng nội dung, có nút Retry/Leave | | [ ] | |
| 13.5 | Không có GUI bị chồng lên nhau không tắt được | | [ ] | |
| 13.6 | UI responsive đúng trên các màn hình khác nhau (PC, tablet, mobile) | | [ ] | |

---

## 14. DATA PERSISTENCE

| # | Bước kiểm tra | Tester | Pass | Ghi chú |
|---|---------------|--------|------|---------|
| 14.1 | Re-join: Cash giữ nguyên | | [ ] | |
| 14.2 | Re-join: Weapon inventory giữ nguyên | | [ ] | |
| 14.3 | Re-join: Owned bases giữ nguyên | | [ ] | |
| 14.4 | Re-join: Crate timers tiếp tục chính xác | | [ ] | |
| 14.5 | Re-join: Wave đã đạt giữ nguyên trên leaderboard | | [ ] | |
| 14.6 | Server crash / force close: không mất data (ProfileService auto-save) | | [ ] | |

---

## 15. MULTIPLAYER & PERFORMANCE

| # | Bước kiểm tra | Tester | Pass | Ghi chú |
|---|---------------|--------|------|---------|
| 15.1 | 2+ player cùng server: plot không overlap | | [ ] | |
| 15.2 | 2+ player: cash và wave của mỗi người độc lập | | [ ] | |
| 15.3 | 2+ player: wave sync đúng (tất cả thấy cùng wave) | | [ ] | |
| 15.4 | FPS không drop dưới 30 khi nhiều enemy trên sân | | [ ] | |
| 15.5 | FPS không drop khi nhiều turret bắn cùng lúc | | [ ] | |
| 15.6 | Không có memory leak (server chạy lâu vẫn ổn định) | | [ ] | |
| 15.7 | Player leave mid-wave: không gây lỗi cho người còn lại | | [ ] | |

---

## 16. DEBUG & ADMIN (chỉ dành cho team nội bộ)

| # | Bước kiểm tra | Tester | Pass | Ghi chú |
|---|---------------|--------|------|---------|
| 16.1 | Debug command: give-all-weapons hoạt động | | [ ] | |
| 16.2 | Debug command: skip wave hoạt động | | [ ] | |
| 16.3 | Debug command: set cash hoạt động | | [ ] | |
| 16.4 | Debug commands KHÔNG dùng được bởi player thường | | [ ] | |
| 16.5 | Connection logs hiện đúng khi player join/leave | | [ ] | |

---

## 17. EDGE CASES & REGRESSION

| # | Bước kiểm tra | Tester | Pass | Ghi chú |
|---|---------------|--------|------|---------|
| 17.1 | Mua item trong lúc wave đang chạy — không gây lỗi | | [ ] | |
| 17.2 | Đặt turret khi không có tiền — không trừ cash | | [ ] | |
| 17.3 | Core bị phá đúng lúc wave kết thúc — không bị softlock | | [ ] | |
| 17.4 | Spam click nút mua — không duplicate item / trừ tiền hai lần | | [ ] | |
| 17.5 | Đổi base khi đang có wave — base mới apply đúng | | [ ] | |
| 17.6 | Đăng nhập với data cũ (schema cũ) — không bị crash | | [ ] | |

---

## BUG LOG

> Ghi bug tìm được vào đây để tổng hợp trước khi tạo issue.

| # | Mô tả bug | Tester | Bước tái hiện | Mức độ (Critical/High/Low) |
|---|-----------|--------|--------------|--------------------------|
| | | | | |
| | | | | |
| | | | | |

---

## GHI CHÚ CHUNG

- **Critical** — Game crash, mất data, không chơi được: fix ngay trong ngày
- **High** — Tính năng chính bị sai, ảnh hưởng trải nghiệm nhiều
- **Low** — Visual, text sai nhỏ, edge case hiếm gặp

**Mức wave nên test tối thiểu:** Wave 1-10 (early), Wave 35-45 (quanh Boss 1), Wave 75-85 (quanh Boss 2)
