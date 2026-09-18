# Game Design: Turrets & Waves 1–20

---

## Turrets

| STT | Tên | Loại bắn | Giá | Damage | Range | Fire Rate (s) | DPS | Stock | Hiệu ứng đặc biệt | Mở khóa |
|-----|-----|-----------|-----|--------|-------|---------------|-----|-------|--------------------|---------|
| 1 | CameraGuy | Lính thường — single target | 200 | 50 | 10 | 1.0 | 50 | 1–5 | Không | Ngay từ đầu |
| 2 | EngineerCameraGuy | Sniper — tầm xa, sát thương cao, chậm | 800 | 350 | 28 | 0.33 | ~106 | 1–5 | Không | Wave 5 |
| 3 | SpeakerGuy | AoE Nổ — splash bán kính khi trúng mục tiêu | 1200 | 120 | 12 | 0.5 | 60 | 1–5 | Splash bán kính 5 studs | Wave 10 |
| 4 | TvGuy | Freeze/Slow — làm chậm hoặc đóng băng | 1500 | 25 | 15 | 1.5 | 37.5 | 1–5 | Slow 50% trong 3s (boss chỉ bị 25%) | Wave 15 |
| 5 | NinjaCameraGuy | Laser Pierce — tia thẳng xuyên qua hàng địch | 2500 | 100 | 22 | 1.0 | 100 | 1–5 | Xuyên tất cả địch trên đường thẳng | Wave 20 |

> **Ghi chú thiết kế:**
> - CameraGuy: giá rẻ, dạy cơ chế. LargeToilet (200HP) cần 4 phát → buộc player mua thêm hoặc upgrade.
> - EngineerCameraGuy: mở ở wave 5 khi SmallRedToilet chạy nhanh khó bắt kịp bằng CameraGuy.
> - SpeakerGuy: mở ở wave 10 khi địch bắt đầu đi theo cụm nhiều path.
> - TvGuy: hỗ trợ, không phải sát thương chính — đi kèm turret khác.
> - NinjaCameraGuy: thưởng boss wave 20, mạnh nhất early-mid game.

---

## Kẻ địch

| Tên | Walkspeed | HP | Damage | Attack Cooldown | DPS | Tiền/con | Damage Base | Kỹ năng |
|-----|-----------|----|--------|-----------------|-----|----------|-------------|---------|
| SmallYellowToilet | 10 | 100 | 5 | 1.0 | 5 | 1 | 10 | Không |
| SmallRedToilet | 25 | 50 | 3 | 0.5 | 6 | 2 | 12 | Chạy rất nhanh |
| LargeToilet | 6 | 200 | 15 | 1.0 | 15 | 3 | 20 | Máu trâu |
| PoliceToilet | 14 | 450 | 20 | 1.0 | 20 | 5 | 25 | Vừa nhanh vừa trâu, kháng slow 30% |
| BossToilet | 4 | 8000 | 50 | 2.0 | 25 | 50 | 60 | Boss — máu cực cao, kháng slow 50% |

---

## Waves 1–20

### Cycle 1 — Khởi Đầu (Wave 1–10)

| STT | Cycle | Tiền Wave | Mở Wave | Boss | Tên quái | Số lượng | Delay spawn | Walkspeed | HP | Damage | Cooldown | DPS | Tiền/con | Damage Base | Kỹ năng | Path |
|-----|-------|-----------|---------|------|----------|----------|-------------|-----------|-----|--------|----------|-----|----------|-------------|---------|------|
| 1 | Khởi Đầu | 10 | — | — | SmallYellowToilet | 3 | 3s | 10 | 100 | 5 | 1 | 5 | 1 | 10 | Không | Path1 |
| 2 | Khởi Đầu | 15 | — | — | SmallYellowToilet | 5 | 3s | 10 | 100 | 5 | 1 | 5 | 1 | 10 | Không | Path2→Path3 xen kẽ |
| 3 | Khởi Đầu | 20 | — | — | SmallYellowToilet | 7 | 3s | 10 | 100 | 5 | 1 | 5 | 1 | 10 | Không | Path1,2,3 xen kẽ |
| 4 | Khởi Đầu | 30 | — | — | SmallYellowToilet | 9 | 3s | 10 | 100 | 5 | 1 | 5 | 1 | 10 | Không | Path1–6 xen kẽ |
| 5 | Khởi Đầu | 40 | — | — | SmallRedToilet | 3 | 1.5s | 25 | 50 | 3 | 0.5 | 6 | 2 | 12 | Chạy nhanh | Path1,2,3 xen kẽ |
| 6 | Khởi Đầu | 50 | — | — | SmallYellowToilet | 6 | 3s | 10 | 100 | 5 | 1 | 5 | 1 | 10 | Không | Path1–6 xen kẽ |
| 6 | Khởi Đầu | 50 | — | — | SmallRedToilet | 3 | 1.5s | 25 | 50 | 3 | 0.5 | 6 | 2 | 12 | Chạy nhanh | Path2,3 xen kẽ |
| 7 | Khởi Đầu | 65 | — | — | LargeToilet | 2 | 4s | 6 | 200 | 15 | 1 | 15 | 3 | 20 | Máu trâu | Path1,2 xen kẽ |
| 8 | Khởi Đầu | 80 | — | — | SmallYellowToilet | 3 | 3s | 10 | 100 | 5 | 1 | 5 | 1 | 10 | Không | Path1–6 xen kẽ |
| 8 | Khởi Đầu | 80 | — | — | SmallRedToilet | 2 | 1.5s | 25 | 50 | 3 | 0.5 | 6 | 2 | 12 | Chạy nhanh | Path2,3 xen kẽ |
| 8 | Khởi Đầu | 80 | — | — | LargeToilet | 1 | 4s | 6 | 200 | 15 | 1 | 15 | 3 | 20 | Máu trâu | Path1 |
| 9 | Khởi Đầu | 100 | — | — | SmallYellowToilet | 4 | 3s | 10 | 100 | 5 | 1 | 5 | 1 | 10 | Không | Path1–6 xen kẽ |
| 9 | Khởi Đầu | 100 | — | — | SmallRedToilet | 3 | 1.5s | 25 | 50 | 3 | 0.5 | 6 | 2 | 12 | Chạy nhanh | Path2,3 xen kẽ |
| 9 | Khởi Đầu | 100 | — | — | LargeToilet | 1 | 4s | 6 | 200 | 15 | 1 | 15 | 3 | 20 | Máu trâu | Path1 |
| 10 | Khởi Đầu | 150 | Wave 5 (EngineerCameraGuy) | — | SmallYellowToilet | 4 | 3s | 10 | 100 | 5 | 1 | 5 | 1 | 10 | Không | Path1–6 xen kẽ |
| 10 | Khởi Đầu | 150 | Wave 5 (EngineerCameraGuy) | — | SmallRedToilet | 4 | 1.5s | 25 | 50 | 3 | 0.5 | 6 | 2 | 12 | Chạy nhanh | Path1–6 xen kẽ |
| 10 | Khởi Đầu | 150 | Wave 5 (EngineerCameraGuy) | — | LargeToilet | 2 | 4s | 6 | 200 | 15 | 1 | 15 | 3 | 20 | Máu trâu | Path2,3 xen kẽ |

---

### Cycle 2 — Leo Thang (Wave 11–20)

> **Thiết kế cycle này:**
> - Wave 11–13: tăng số lượng, mix 3 loại cũ, áp lực tích lũy
> - Wave 14: giới thiệu PoliceToilet — vừa nhanh vừa trâu
> - Wave 15: mở SpeakerGuy — milestone quan trọng
> - Wave 16–19: PoliceToilet làm chủ đạo, địch đi nhiều path cùng lúc
> - Wave 20: Boss BossToilet — mở NinjaCameraGuy

| STT | Cycle | Tiền Wave | Mở Wave | Boss | Tên quái | Số lượng | Delay spawn | Walkspeed | HP | Damage | Cooldown | DPS | Tiền/con | Damage Base | Kỹ năng | Path |
|-----|-------|-----------|---------|------|----------|----------|-------------|-----------|-----|--------|----------|-----|----------|-------------|---------|------|
| 11 | Leo Thang | 180 | — | — | SmallYellowToilet | 5 | 2.5s | 10 | 100 | 5 | 1 | 5 | 1 | 10 | Không | Path1–6 xen kẽ |
| 11 | Leo Thang | 180 | — | — | SmallRedToilet | 5 | 1.5s | 25 | 50 | 3 | 0.5 | 6 | 2 | 12 | Chạy nhanh | Path1–6 xen kẽ |
| 11 | Leo Thang | 180 | — | — | LargeToilet | 2 | 4s | 6 | 200 | 15 | 1 | 15 | 3 | 20 | Máu trâu | Path1,2 xen kẽ |
| 12 | Leo Thang | 200 | — | — | SmallYellowToilet | 6 | 2.5s | 10 | 100 | 5 | 1 | 5 | 1 | 10 | Không | Path1–6 xen kẽ |
| 12 | Leo Thang | 200 | — | — | SmallRedToilet | 5 | 1.5s | 25 | 50 | 3 | 0.5 | 6 | 2 | 12 | Chạy nhanh | Path1–6 xen kẽ |
| 12 | Leo Thang | 200 | — | — | LargeToilet | 3 | 4s | 6 | 200 | 15 | 1 | 15 | 3 | 20 | Máu trâu | Path1,2,3 xen kẽ |
| 13 | Leo Thang | 230 | — | — | SmallYellowToilet | 5 | 2.5s | 10 | 100 | 5 | 1 | 5 | 1 | 10 | Không | Path1–6 xen kẽ |
| 13 | Leo Thang | 230 | — | — | SmallRedToilet | 6 | 1.5s | 25 | 50 | 3 | 0.5 | 6 | 2 | 12 | Chạy nhanh | Path1–6 xen kẽ |
| 13 | Leo Thang | 230 | — | — | LargeToilet | 3 | 4s | 6 | 200 | 15 | 1 | 15 | 3 | 20 | Máu trâu | Path2,3,4 xen kẽ |
| 14 | Leo Thang | 260 | — | — | SmallRedToilet | 4 | 1.5s | 25 | 50 | 3 | 0.5 | 6 | 2 | 12 | Chạy nhanh | Path1–6 xen kẽ |
| 14 | Leo Thang | 260 | — | — | LargeToilet | 2 | 4s | 6 | 200 | 15 | 1 | 15 | 3 | 20 | Máu trâu | Path1,2 xen kẽ |
| 14 | Leo Thang | 260 | — | — | PoliceToilet | 2 | 3s | 14 | 450 | 20 | 1 | 20 | 5 | 25 | Kháng slow 30% | Path1,2 xen kẽ |
| 15 | Leo Thang | 300 | Wave 10 (SpeakerGuy) | — | SmallRedToilet | 5 | 1.5s | 25 | 50 | 3 | 0.5 | 6 | 2 | 12 | Chạy nhanh | Path1–6 xen kẽ |
| 15 | Leo Thang | 300 | Wave 10 (SpeakerGuy) | — | LargeToilet | 3 | 4s | 6 | 200 | 15 | 1 | 15 | 3 | 20 | Máu trâu | Path1,2,3 xen kẽ |
| 15 | Leo Thang | 300 | Wave 10 (SpeakerGuy) | — | PoliceToilet | 3 | 3s | 14 | 450 | 20 | 1 | 20 | 5 | 25 | Kháng slow 30% | Path3,4,5 xen kẽ |
| 16 | Leo Thang | 340 | — | — | SmallRedToilet | 4 | 1.5s | 25 | 50 | 3 | 0.5 | 6 | 2 | 12 | Chạy nhanh | Path1–6 xen kẽ |
| 16 | Leo Thang | 340 | — | — | LargeToilet | 3 | 4s | 6 | 200 | 15 | 1 | 15 | 3 | 20 | Máu trâu | Path2,3,4 xen kẽ |
| 16 | Leo Thang | 340 | — | — | PoliceToilet | 4 | 3s | 14 | 450 | 20 | 1 | 20 | 5 | 25 | Kháng slow 30% | Path1–6 xen kẽ |
| 17 | Leo Thang | 380 | — | — | SmallYellowToilet | 4 | 2.5s | 10 | 100 | 5 | 1 | 5 | 1 | 10 | Không | Path1–6 xen kẽ |
| 17 | Leo Thang | 380 | — | — | LargeToilet | 4 | 4s | 6 | 200 | 15 | 1 | 15 | 3 | 20 | Máu trâu | Path1,2,3 xen kẽ |
| 17 | Leo Thang | 380 | — | — | PoliceToilet | 5 | 3s | 14 | 450 | 20 | 1 | 20 | 5 | 25 | Kháng slow 30% | Path3,4,5,6 xen kẽ |
| 18 | Leo Thang | 420 | — | — | SmallRedToilet | 6 | 1.5s | 25 | 50 | 3 | 0.5 | 6 | 2 | 12 | Chạy nhanh | Path1–6 xen kẽ |
| 18 | Leo Thang | 420 | — | — | LargeToilet | 3 | 4s | 6 | 200 | 15 | 1 | 15 | 3 | 20 | Máu trâu | Path2,4,6 xen kẽ |
| 18 | Leo Thang | 420 | — | — | PoliceToilet | 6 | 3s | 14 | 450 | 20 | 1 | 20 | 5 | 25 | Kháng slow 30% | Path1,3,5 xen kẽ |
| 19 | Leo Thang | 480 | Wave 15 (TvGuy) | — | SmallRedToilet | 5 | 1.5s | 25 | 50 | 3 | 0.5 | 6 | 2 | 12 | Chạy nhanh | Path1–6 xen kẽ |
| 19 | Leo Thang | 480 | Wave 15 (TvGuy) | — | LargeToilet | 4 | 4s | 6 | 200 | 15 | 1 | 15 | 3 | 20 | Máu trâu | Path1,2,3,4 xen kẽ |
| 19 | Leo Thang | 480 | Wave 15 (TvGuy) | — | PoliceToilet | 6 | 3s | 14 | 450 | 20 | 1 | 20 | 5 | 25 | Kháng slow 30% | Path3,4,5,6 xen kẽ |
| 20 | Leo Thang | 600 | Wave 20 (NinjaCameraGuy) | **BOSS** | BossToilet | 1 | — | 4 | 8000 | 50 | 2 | 25 | 50 | 60 | Boss — kháng slow 50% | Path1 |
| 20 | Leo Thang | 600 | Wave 20 (NinjaCameraGuy) | **BOSS** | PoliceToilet | 4 | 3s | 14 | 450 | 20 | 1 | 20 | 5 | 25 | Kháng slow 30% | Path2,3,4,5 xen kẽ |
| 20 | Leo Thang | 600 | Wave 20 (NinjaCameraGuy) | **BOSS** | SmallRedToilet | 6 | 1.5s | 25 | 50 | 3 | 0.5 | 6 | 2 | 12 | Chạy nhanh | Path2–6 xen kẽ |

---

## Turret Unlock Timeline

| Wave | Mở khóa | Lý do |
|------|---------|-------|
| 1 | CameraGuy | Turret tutorial — dạy cơ chế đặt và tầm bắn |
| 5 | EngineerCameraGuy | SmallRedToilet chạy nhanh, cần sniper bắt kịp |
| 10 | SpeakerGuy | Địch đi nhiều path → cần AoE để xử lý cụm |
| 15 | TvGuy | PoliceToilet trâu → cần slow để DPS bắt kịp |
| 20 | NinjaCameraGuy | Thưởng boss wave 20 — mạnh nhất early game |

---

## Ghi chú cân bằng

| Điểm thiết kế | Chi tiết |
|--------------|---------|
| Wave 7 là "checkpoint" đầu tiên | LargeToilet 200HP cần EngineerCameraGuy (350 dmg/phát) để kill 1 shot, tạo áp lực mua sớm |
| Wave 14 giới thiệu PoliceToilet | HP 450 — CameraGuy cần 9 phát, Sniper cần 2 phát → gap rõ ràng |
| Wave 20 Boss HP 8000 | Cần combo SpeakerGuy + EngineerCameraGuy, TvGuy slow → phải dùng đủ 4 loại turret |
| NinjaCameraGuy mở wave 20 | Tránh pierce quá sớm làm game mất cân bằng trong 10 wave đầu |
| TvGuy DPS thấp (37.5) | Chủ đích — là turret support, không thay thế DPS chính |
