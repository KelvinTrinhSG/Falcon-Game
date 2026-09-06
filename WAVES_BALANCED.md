# Falcon — WAVES BALANCED (Max 15 quái/wave)

> Tổng quái mỗi wave tối đa **15**. Delay spawn giảm dần khi wave tăng (spawn nhanh hơn = khó hơn). Số lượng có biến động nhẹ để tránh pattern quá đều.
>
> **Quy tắc giới thiệu enemy:** Mỗi enemy mới xuất hiện lần đầu phải có **1 wave solo 3 con** trước, rồi wave sau mới kết hợp với các enemy khác.

---

## Chỉ số quái

| Wave | Tên quái | HP | Damage | Tiền/con | Damage Base | WalkSpeed | Ghi chú | Kỹ năng riêng |
|:---:|---|---:|---:|---:|---:|---:|---|---|
| 1 | SmallYellowToilet | 60 | 5 | 1 | 10 | 10 | — | — |
| 5 | SmallRedToilet | 35 | 3 | 2 | 12 | **25** | Nhanh | — |
| 7 | LargeToilet | 250 | 15 | 3 | 20 | 8 | Trâu | — |
| 11 | HelicopterParasiteYellowToilet | 180 | 12 | 19 | 15 | 10 | — | ✈ Bay |
| 14 | HelicopterParasiteRedToilet | 100 | 8 | 20 | 18 | **25** | Nhanh | ✈ Bay |
| 17 | PoliceToilet | 650 | 30 | 6 | 30 | 9 | Trâu | — |
| 20 | DJYellowToiletBuff | 700 | 28 | 8 | 22 | 8 | — | 🛡️ Buff bất tử 5s (cd 10s) |
| 21 | GlassesYellowToilet | 450 | 25 | 7 | 20 | 11 | — | — |
| 24 | GlassesRedToilet | 280 | 18 | 8 | 25 | **25** | Nhanh | — |
| 26 | FlyingBuzzsawToilet | 1,800 | 50 | 15 | 40 | 12 | Trâu | ✈ Bay |
| 31 | DJYellowToilet | 1,200 | 45 | 10 | 25 | 11 | — | — |
| 34 | DJRedToilet | 850 | 35 | 11 | 30 | **25** | Nhanh | — |
| 36 | DualBladeToilet | 8,000 | 120 | 12 | 50 | 10 | Trâu | 💥 Nổ khi chết (r=6) |
| **40** | **BossToilet** | **35,000** | **200** | **50** | **100** | 8 | **Trâu** | — |
| 41 | VacuumYellowToilet | 2,000 | 50 | 13 | 30 | 11 | — | — |
| 44 | VacuumRedToilet | 1,400 | 80 | 14 | 40 | **25** | Nhanh | — |
| 46 | GlitchToilet | 9,000 | 150 | 9 | 60 | 12 | Trâu | 💥 Nổ khi chết (r=6) |
| 51 | DualBladeYellowToilet | 3,500 | 90 | 16 | 35 | 12 | — | — |
| 54 | DualBladeRedToilet | 2,800 | 70 | 17 | 45 | **25** | Nhanh | — |
| 56 | FlyingRocketLauncherToilet | 25,000 | 200 | 18 | 70 | 10 | Trâu | ✈ Bay |
| 61 | AssassinYellowToilet | 6,000 | 120 | 4 | 40 | 12 | — | — |
| 64 | AssassinRedToilet | 4,000 | 250 | 5 | 55 | **25** | Nhanh | — |
| 66 | LargePoliceToilet | 50,000 | 400 | 25 | 80 | 8 | Trâu | 💥 Nổ khi chết (r=10) |
| 71 | LargeFlyingBuzzsawYellowToilet | 12,000 | 150 | 21 | 50 | 9 | Trâu | ✈ Bay |
| 74 | LargeFlyingBuzzsawRedToilet | 8,000 | 250 | 22 | 65 | **25** | Nhanh · Trâu | ✈ Bay |
| 76 | GiantDualBladeToilet | 60,000 | 350 | 23 | 90 | 10 | Trâu | — |
| **80** | **BossToilet2** | **150,000** | **500** | **150** | **150** | 8 | **Trâu** | — |
| 81 | GiantGlassesYellowToilet | 30,000 | 200 | 24 | 60 | 10 | Trâu | — |
| 84 | GiantGlassesRedToilet | 22,000 | 250 | 25 | 75 | **25** | Nhanh · Trâu | — |
| 86 | SpiderToilet | 40,000 | 400 | 26 | 85 | 14 | Trâu | 💥 Nổ khi chết (r=8) |
| 90 | InfectedTitanSpeakerman | 50,000 | 800 | 27 | 100 | 10 | Trâu | — |
| 101 | QuadBladeStriderToilet | 60,000 | 900 | 28 | 70 | 12 | Trâu | — |
| 104 | UFOToilet | 70,000 | 1,000 | 29 | 85 | 14 | Trâu | ✈ Bay |
| 106 | RocketToilet | 800,000 | 1,100 | 30 | 100 | 12 | Trâu | ✈ Bay |
| 111 | StriderRocketToilet | 900,000 | 1,250 | 31 | 120 | 10 | Trâu | — |

---

## Danh sách Wave

| STT | Cycle | Tiền Wave | Mở Wave | Boss | Tên quái | Số lượng | Delay spawn | Walkspeed |
|:---:|---|---:|:---:|:---:|---|---:|---:|---:|
| 1 | Khởi Đầu | 10 | — | — | SmallYellowToilet | 3 | 1.5s | 10 |
| 2 | Khởi Đầu | 15 | — | — | SmallYellowToilet | 5 | 1.3s | 10 |
| 3 | Khởi Đầu | 20 | — | — | SmallYellowToilet | 7 | 1.1s | 10 |
| 4 | Khởi Đầu | 30 | — | — | SmallYellowToilet | 9 | 1.0s | 10 |
| 5 | Khởi Đầu | 40 | — | — | **SmallRedToilet** | **3** | **1.5s** | **25** |
| | | | | | *(Giới thiệu solo)* | | | |
| 6 | Khởi Đầu | 50 | — | — | SmallYellowToilet | 8 | 0.9s | 10 |
| | | | | | SmallRedToilet | 4 | 1.3s | 25 |
| 7 | Khởi Đầu | 65 | — | — | **LargeToilet** | **3** | **3.0s** | **8** |
| | | | | | *(Giới thiệu solo)* | | | |
| 8 | Khởi Đầu | 80 | — | — | SmallYellowToilet | 7 | 0.8s | 10 |
| | | | | | SmallRedToilet | 4 | 1.1s | 25 |
| | | | | | LargeToilet | 1 | 2.8s | 8 |
| 9 | Khởi Đầu | 100 | — | — | SmallYellowToilet | 6 | 0.8s | 10 |
| | | | | | SmallRedToilet | 5 | 1.0s | 25 |
| | | | | | LargeToilet | 2 | 2.5s | 8 |
| 10 | Khởi Đầu | 150 | Wave 5 | — | SmallYellowToilet | 5 | 0.8s | 10 |
| | | | | | SmallRedToilet | 5 | 0.9s | 25 |
| | | | | | LargeToilet | 2 | 2.5s | 8 |
| 11 | Transition | 60 | — | — | **HelicopterParasiteYellowToilet** | **3** | **1.3s** | **10** |
| | | | | | *(Giới thiệu solo)* | | | |
| 12 | Transition | 65 | — | — | HelicopterParasiteYellowToilet | 6 | 1.1s | 10 |
| 13 | Transition | 70 | — | — | HelicopterParasiteYellowToilet | 8 | 1.0s | 10 |
| 14 | Transition | 75 | — | — | **HelicopterParasiteRedToilet** | **3** | **1.5s** | **25** |
| | | | | | *(Giới thiệu solo)* | | | |
| 15 | Transition | 80 | Wave 10 | — | HelicopterParasiteYellowToilet | 8 | 0.9s | 10 |
| | | | | | HelicopterParasiteRedToilet | 3 | 1.4s | 25 |
| 16 | Transition | 85 | — | — | HelicopterParasiteYellowToilet | 7 | 0.9s | 10 |
| | | | | | HelicopterParasiteRedToilet | 4 | 1.2s | 25 |
| 17 | Transition | 90 | — | — | **PoliceToilet** | **3** | **3.0s** | **9** |
| | | | | | *(Giới thiệu solo)* | | | |
| 18 | Transition | 95 | — | — | HelicopterParasiteYellowToilet | 6 | 0.8s | 10 |
| | | | | | HelicopterParasiteRedToilet | 4 | 1.1s | 25 |
| | | | | | PoliceToilet | 1 | 2.8s | 9 |
| 19 | Transition | 100 | — | — | HelicopterParasiteYellowToilet | 5 | 0.8s | 10 |
| | | | | | HelicopterParasiteRedToilet | 5 | 1.0s | 25 |
| | | | | | PoliceToilet | 2 | 2.5s | 9 |
| 20 | Transition | 160 | Wave 15 | — | HelicopterParasiteYellowToilet | 4 | 0.8s | 10 |
| | | | | | HelicopterParasiteRedToilet | 5 | 0.9s | 25 |
| | | | | | PoliceToilet | 2 | 2.5s | 9 |
| | | | | | GlassesYellowToilet | 1 | 2.5s | 11 |
| | | | | | DJYellowToiletBuff | 1 | 2.5s | 8 |
| 21 | Mid Game | 110 | — | — | GlassesYellowToilet | 2 | 1.3s | 11 |
| | | | | | DJYellowToiletBuff | 1 | 2.5s | 8 |
| 22 | Mid Game | 115 | — | — | GlassesYellowToilet | 3 | 1.1s | 11 |
| | | | | | DJYellowToiletBuff | 1 | 2.5s | 8 |
| 23 | Mid Game | 120 | — | — | GlassesYellowToilet | 4 | 1.0s | 11 |
| | | | | | DJYellowToiletBuff | 1 | 2.5s | 8 |
| 24 | Mid Game | 125 | — | — | **GlassesRedToilet** | **1** | **1.5s** | **25** |
| | | | | | *(Giới thiệu solo)* | | | |
| 25 | Mid Game | 130 | Wave 20 | — | GlassesYellowToilet | 4 | 0.9s | 11 |
| | | | | | GlassesRedToilet | 1 | 1.3s | 25 |
| | | | | | DJYellowToiletBuff | 1 | 2.5s | 8 |
| 26 | Mid Game | 140 | — | — | **FlyingBuzzsawToilet** | **1** | **3.0s** | **12** |
| | | | | | *(Giới thiệu solo)* | | | |
| 27 | Mid Game | 150 | — | — | GlassesYellowToilet | 3 | 0.9s | 11 |
| | | | | | GlassesRedToilet | 2 | 1.1s | 25 |
| | | | | | FlyingBuzzsawToilet | 1 | 2.8s | 12 |
| | | | | | DJYellowToiletBuff | 1 | 2.5s | 8 |
| 28 | Mid Game | 160 | — | — | GlassesYellowToilet | 3 | 0.8s | 11 |
| | | | | | GlassesRedToilet | 2 | 1.0s | 25 |
| | | | | | FlyingBuzzsawToilet | 1 | 2.5s | 12 |
| | | | | | DJYellowToiletBuff | 1 | 2.5s | 8 |
| 29 | Mid Game | 170 | — | — | GlassesYellowToilet | 2 | 0.8s | 11 |
| | | | | | GlassesRedToilet | 2 | 1.0s | 25 |
| | | | | | FlyingBuzzsawToilet | 1 | 2.5s | 12 |
| | | | | | DJYellowToiletBuff | 1 | 2.5s | 8 |
| 30 | Mid Game | 215 | Wave 25 | — | GlassesYellowToilet | 2 | 0.8s | 11 |
| | | | | | GlassesRedToilet | 2 | 0.9s | 25 |
| | | | | | FlyingBuzzsawToilet | 1 | 2.3s | 12 |
| | | | | | DJYellowToiletBuff | 1 | 2.5s | 8 |
| | | | | | DJYellowToilet | 1 | 2.5s | 11 |
| 31 | Late Game | 165 | — | — | DJYellowToilet | 4 | 1.3s | 11 |
| 32 | Late Game | 170 | — | — | DJYellowToilet | 6 | 1.1s | 11 |
| 33 | Late Game | 175 | — | — | DJYellowToilet | 8 | 1.0s | 11 |
| 34 | Late Game | 180 | — | — | **DJRedToilet** | **3** | **1.5s** | **25** |
| | | | | | *(Giới thiệu solo)* | | | |
| 35 | Late Game | 185 | Wave 30 | — | DJYellowToilet | 8 | 0.9s | 11 |
| | | | | | DJRedToilet | 3 | 1.3s | 25 |
| 36 | Late Game | 195 | — | — | **DualBladeToilet** | **3** | **3.0s** | **10** |
| | | | | | *(Giới thiệu solo)* | | | |
| 37 | Late Game | 205 | — | — | DJYellowToilet | 6 | 0.9s | 11 |
| | | | | | DJRedToilet | 5 | 1.1s | 25 |
| | | | | | DualBladeToilet | 1 | 2.8s | 10 |
| 38 | Late Game | 215 | — | — | DJYellowToilet | 6 | 0.8s | 11 |
| | | | | | DJRedToilet | 4 | 1.1s | 25 |
| | | | | | DualBladeToilet | 2 | 2.5s | 10 |
| 39 | Late Game | 225 | — | — | DJYellowToilet | 5 | 0.8s | 11 |
| | | | | | DJRedToilet | 5 | 1.0s | 25 |
| | | | | | DualBladeToilet | 3 | 2.3s | 10 |
| **40** | **Late Game** | **320** | Wave 35 | ✅ BossToilet | DJRedToilet | 5 | 0.8s | 25 |
| | | | | | DJYellowToilet | 4 | 0.8s | 11 |
| | | | | | **BossToilet** | **1** | **3.0s** | **8** |
| | | | | | VacuumYellowToilet | 1 | 2.5s | 11 |
| 41 | Nature | 220 | — | — | VacuumYellowToilet | 4 | 1.3s | 11 |
| 42 | Nature | 225 | — | — | VacuumYellowToilet | 6 | 1.1s | 11 |
| 43 | Nature | 230 | — | — | VacuumYellowToilet | 8 | 1.0s | 11 |
| 44 | Nature | 235 | — | — | **VacuumRedToilet** | **3** | **1.5s** | **25** |
| | | | | | *(Giới thiệu solo)* | | | |
| 45 | Nature | 240 | Wave 40 | — | VacuumYellowToilet | 8 | 0.9s | 11 |
| | | | | | VacuumRedToilet | 3 | 1.3s | 25 |
| 46 | Nature | 250 | — | — | **GlitchToilet** | **3** | **3.0s** | **12** |
| | | | | | *(Giới thiệu solo)* | | | |
| 47 | Nature | 260 | — | — | VacuumYellowToilet | 6 | 0.9s | 11 |
| | | | | | VacuumRedToilet | 5 | 1.1s | 25 |
| | | | | | GlitchToilet | 1 | 2.8s | 12 |
| 48 | Nature | 270 | — | — | VacuumYellowToilet | 6 | 0.8s | 11 |
| | | | | | VacuumRedToilet | 5 | 1.0s | 25 |
| | | | | | GlitchToilet | 2 | 2.5s | 12 |
| 49 | Nature | 280 | — | — | VacuumYellowToilet | 5 | 0.8s | 11 |
| | | | | | VacuumRedToilet | 5 | 1.0s | 25 |
| | | | | | GlitchToilet | 3 | 2.3s | 12 |
| 50 | Nature | 370 | Wave 45 | — | VacuumYellowToilet | 4 | 0.8s | 11 |
| | | | | | VacuumRedToilet | 5 | 0.9s | 25 |
| | | | | | GlitchToilet | 3 | 2.3s | 12 |
| | | | | | DualBladeYellowToilet | 1 | 2.5s | 12 |
| 51 | Animals | 270 | — | — | DualBladeYellowToilet | 4 | 1.3s | 12 |
| 52 | Animals | 275 | — | — | DualBladeYellowToilet | 6 | 1.1s | 12 |
| 53 | Animals | 280 | — | — | DualBladeYellowToilet | 8 | 1.0s | 12 |
| 54 | Animals | 285 | — | — | **DualBladeRedToilet** | **3** | **1.5s** | **25** |
| | | | | | *(Giới thiệu solo)* | | | |
| 55 | Animals | 290 | Wave 50 | — | DualBladeYellowToilet | 8 | 0.9s | 12 |
| | | | | | DualBladeRedToilet | 3 | 1.3s | 25 |
| 56 | Animals | 300 | — | — | **FlyingRocketLauncherToilet** | **3** | **3.0s** | **10** |
| | | | | | *(Giới thiệu solo)* | | | |
| 57 | Animals | 310 | — | — | DualBladeYellowToilet | 6 | 0.9s | 12 |
| | | | | | DualBladeRedToilet | 5 | 1.1s | 25 |
| | | | | | FlyingRocketLauncherToilet | 1 | 2.8s | 10 |
| 58 | Animals | 320 | — | — | DualBladeYellowToilet | 6 | 0.8s | 12 |
| | | | | | DualBladeRedToilet | 5 | 1.0s | 25 |
| | | | | | FlyingRocketLauncherToilet | 2 | 2.5s | 10 |
| 59 | Animals | 330 | — | — | DualBladeYellowToilet | 5 | 0.8s | 12 |
| | | | | | DualBladeRedToilet | 5 | 1.0s | 25 |
| | | | | | FlyingRocketLauncherToilet | 3 | 2.3s | 10 |
| 60 | Animals | 420 | Wave 55 | — | DualBladeYellowToilet | 4 | 0.8s | 12 |
| | | | | | DualBladeRedToilet | 5 | 0.9s | 25 |
| | | | | | FlyingRocketLauncherToilet | 3 | 2.3s | 10 |
| | | | | | AssassinYellowToilet | 1 | 2.5s | 12 |
| 61 | Ocean | 320 | — | — | AssassinYellowToilet | 4 | 1.3s | 12 |
| 62 | Ocean | 325 | — | — | AssassinYellowToilet | 6 | 1.1s | 12 |
| 63 | Ocean | 330 | — | — | AssassinYellowToilet | 8 | 1.0s | 12 |
| 64 | Ocean | 335 | — | — | **AssassinRedToilet** | **3** | **1.5s** | **25** |
| | | | | | *(Giới thiệu solo)* | | | |
| 65 | Ocean | 340 | Wave 60 | — | AssassinYellowToilet | 8 | 0.9s | 12 |
| | | | | | AssassinRedToilet | 3 | 1.3s | 25 |
| 66 | Ocean | 350 | — | — | **LargePoliceToilet** | **3** | **3.0s** | **8** |
| | | | | | *(Giới thiệu solo)* | | | |
| 67 | Ocean | 360 | — | — | AssassinYellowToilet | 6 | 0.9s | 12 |
| | | | | | AssassinRedToilet | 5 | 1.1s | 25 |
| | | | | | LargePoliceToilet | 1 | 2.8s | 8 |
| 68 | Ocean | 370 | — | — | AssassinYellowToilet | 6 | 0.8s | 12 |
| | | | | | AssassinRedToilet | 5 | 1.0s | 25 |
| | | | | | LargePoliceToilet | 2 | 2.5s | 8 |
| 69 | Ocean | 380 | — | — | AssassinYellowToilet | 5 | 0.8s | 12 |
| | | | | | AssassinRedToilet | 5 | 1.0s | 25 |
| | | | | | LargePoliceToilet | 2 | 2.3s | 9 |
| 70 | Ocean | 420 | Wave 65 | — | AssassinYellowToilet | 4 | 0.8s | 12 |
| | | | | | AssassinRedToilet | 5 | 0.9s | 25 |
| | | | | | LargePoliceToilet | 3 | 2.3s | 9 |
| | | | | | LargeFlyingBuzzsawYellowToilet | 1 | 2.5s | 9 |
| 71 | Fruits | 370 | — | — | LargeFlyingBuzzsawYellowToilet | 4 | 1.3s | 9 |
| 72 | Fruits | 375 | — | — | LargeFlyingBuzzsawYellowToilet | 6 | 1.1s | 9 |
| 73 | Fruits | 380 | — | — | LargeFlyingBuzzsawYellowToilet | 8 | 1.0s | 9 |
| 74 | Fruits | 385 | — | — | **LargeFlyingBuzzsawRedToilet** | **3** | **1.5s** | **25** |
| | | | | | *(Giới thiệu solo)* | | | |
| 75 | Fruits | 390 | Wave 70 | — | LargeFlyingBuzzsawYellowToilet | 8 | 0.9s | 9 |
| | | | | | LargeFlyingBuzzsawRedToilet | 3 | 1.3s | 25 |
| 76 | Fruits | 400 | — | — | **GiantDualBladeToilet** | **3** | **3.0s** | **10** |
| | | | | | *(Giới thiệu solo)* | | | |
| 77 | Fruits | 410 | — | — | LargeFlyingBuzzsawYellowToilet | 6 | 0.9s | 9 |
| | | | | | LargeFlyingBuzzsawRedToilet | 5 | 1.1s | 25 |
| | | | | | GiantDualBladeToilet | 1 | 2.8s | 10 |
| 78 | Fruits | 420 | — | — | LargeFlyingBuzzsawYellowToilet | 6 | 0.8s | 9 |
| | | | | | LargeFlyingBuzzsawRedToilet | 5 | 1.0s | 25 |
| | | | | | GiantDualBladeToilet | 2 | 2.5s | 10 |
| 79 | Fruits | 430 | — | — | LargeFlyingBuzzsawYellowToilet | 5 | 0.8s | 9 |
| | | | | | LargeFlyingBuzzsawRedToilet | 5 | 1.0s | 25 |
| | | | | | GiantDualBladeToilet | 3 | 2.3s | 10 |
| **80** | **Fruits** | **420** | Wave 70 | ✅ BossToilet2 | LargeFlyingBuzzsawRedToilet | 5 | 0.8s | 25 |
| | | | | | GiantDualBladeToilet | 3 | 1.5s | 10 |
| | | | | | **BossToilet2** | **1** | **2.0s** | **8** |
| 81 | Veggie Hell | 430 | — | — | GiantGlassesYellowToilet | 4 | 1.2s | 10 |
| 82 | Veggie Hell | 440 | — | — | GiantGlassesYellowToilet | 6 | 1.1s | 10 |
| 83 | Veggie Hell | 450 | — | — | GiantGlassesYellowToilet | 8 | 1.0s | 10 |
| 84 | Veggie Hell | 460 | — | — | **GiantGlassesRedToilet** | **3** | **1.5s** | **25** |
| | | | | | *(Giới thiệu solo)* | | | |
| 85 | Veggie Hell | 470 | Wave 80 | — | GiantGlassesYellowToilet | 8 | 0.9s | 10 |
| | | | | | GiantGlassesRedToilet | 3 | 1.3s | 25 |
| 86 | Veggie Hell | 480 | — | — | **SpiderToilet** | **3** | **2.5s** | **14** |
| | | | | | *(Giới thiệu solo)* | | | |
| 87 | Veggie Hell | 490 | — | — | GiantGlassesYellowToilet | 6 | 0.9s | 10 |
| | | | | | GiantGlassesRedToilet | 5 | 1.1s | 25 |
| | | | | | SpiderToilet | 1 | 2.3s | 14 |
| 88 | Veggie Hell | 500 | — | — | GiantGlassesYellowToilet | 5 | 0.8s | 10 |
| | | | | | GiantGlassesRedToilet | 5 | 1.0s | 25 |
| | | | | | SpiderToilet | 3 | 2.0s | 14 |
| 89 | Veggie Hell | 510 | — | — | GiantGlassesYellowToilet | 5 | 0.8s | 10 |
| | | | | | GiantGlassesRedToilet | 5 | 1.0s | 25 |
| | | | | | SpiderToilet | 3 | 2.0s | 14 |
| 90 | Veggie Hell | 520 | Wave 85 | — | **InfectedTitanSpeakerman** | **3** | **3.0s** | **10** |
| | | | | | *(Giới thiệu solo)* | | | |
| 91 | Veggie Hell | 460 | — | — | GiantGlassesYellowToilet | 3 | 0.8s | 10 |
| | | | | | GiantGlassesRedToilet | 6 | 0.9s | 25 |
| | | | | | SpiderToilet | 4 | 1.8s | 15 |
| | | | | | InfectedTitanSpeakerman | 1 | 2.8s | 10 |
| 92 | Veggie Hell | 470 | — | — | GiantGlassesYellowToilet | 4 | 0.7s | 10 |
| | | | | | GiantGlassesRedToilet | 5 | 0.9s | 25 |
| | | | | | SpiderToilet | 4 | 1.5s | 15 |
| | | | | | InfectedTitanSpeakerman | 2 | 2.5s | 10 |
| 93 | Veggie Hell | 480 | — | — | GiantGlassesRedToilet | 6 | 0.8s | 25 |
| | | | | | SpiderToilet | 5 | 1.5s | 15 |
| | | | | | InfectedTitanSpeakerman | 2 | 2.5s | 10 |
| 94 | Veggie Hell | 490 | — | — | GiantGlassesYellowToilet | 3 | 0.7s | 10 |
| | | | | | GiantGlassesRedToilet | 5 | 0.8s | 25 |
| | | | | | SpiderToilet | 5 | 1.5s | 16 |
| | | | | | InfectedTitanSpeakerman | 2 | 2.3s | 10 |
| 95 | Veggie Hell | 500 | Wave 90 | — | GiantGlassesRedToilet | 5 | 0.8s | 25 |
| | | | | | SpiderToilet | 6 | 1.3s | 16 |
| | | | | | InfectedTitanSpeakerman | 3 | 2.0s | 10 |
| 96 | Veggie Hell | 510 | — | — | GiantGlassesYellowToilet | 2 | 0.7s | 10 |
| | | | | | GiantGlassesRedToilet | 5 | 0.8s | 25 |
| | | | | | SpiderToilet | 5 | 1.3s | 16 |
| | | | | | InfectedTitanSpeakerman | 3 | 2.0s | 11 |
| 97 | Veggie Hell | 520 | — | — | GiantGlassesRedToilet | 4 | 0.7s | 25 |
| | | | | | SpiderToilet | 7 | 1.2s | 16 |
| | | | | | InfectedTitanSpeakerman | 3 | 1.8s | 11 |
| 98 | Veggie Hell | 530 | — | — | GiantGlassesYellowToilet | 2 | 0.6s | 10 |
| | | | | | GiantGlassesRedToilet | 4 | 0.7s | 25 |
| | | | | | SpiderToilet | 6 | 1.2s | 16 |
| | | | | | InfectedTitanSpeakerman | 3 | 1.8s | 11 |
| 99 | Veggie Hell | 540 | — | — | GiantGlassesRedToilet | 3 | 0.7s | 25 |
| | | | | | SpiderToilet | 7 | 1.1s | 16 |
| | | | | | InfectedTitanSpeakerman | 4 | 1.5s | 11 |
| 100 | Veggie Hell | 550 | Wave 96 | — | GiantGlassesRedToilet | 2 | 0.6s | 25 |
| | | | | | SpiderToilet | 6 | 1.1s | 16 |
| | | | | | InfectedTitanSpeakerman | 5 | 1.5s | 12 |
| 101 | Planetary | 545 | — | — | QuadBladeStriderToilet | 4 | 1.3s | 12 |
| 102 | Planetary | 555 | — | — | QuadBladeStriderToilet | 6 | 1.1s | 12 |
| 103 | Planetary | 565 | — | — | QuadBladeStriderToilet | 8 | 1.0s | 12 |
| 104 | Planetary | 575 | — | — | **UFOToilet** | **3** | **1.5s** | **14** |
| | | | | | *(Giới thiệu solo)* | | | |
| 105 | Planetary | 585 | Wave 100 | — | QuadBladeStriderToilet | 6 | 0.9s | 12 |
| | | | | | UFOToilet | 5 | 1.3s | 14 |
| 106 | Planetary | 595 | — | — | **RocketToilet** | **3** | **2.5s** | **12** |
| | | | | | *(Giới thiệu solo)* | | | |
| 107 | Planetary | 605 | — | — | QuadBladeStriderToilet | 5 | 0.9s | 12 |
| | | | | | UFOToilet | 6 | 1.1s | 14 |
| | | | | | RocketToilet | 1 | 2.3s | 12 |
| 108 | Planetary | 615 | — | — | QuadBladeStriderToilet | 5 | 0.8s | 12 |
| | | | | | UFOToilet | 5 | 1.1s | 14 |
| | | | | | RocketToilet | 3 | 2.0s | 13 |
| 109 | Planetary | 625 | — | — | QuadBladeStriderToilet | 4 | 0.8s | 13 |
| | | | | | UFOToilet | 6 | 1.0s | 15 |
| | | | | | RocketToilet | 3 | 2.0s | 13 |
| 110 | Planetary | 640 | Wave 105 | — | QuadBladeStriderToilet | 4 | 0.8s | 13 |
| | | | | | UFOToilet | 5 | 1.0s | 15 |
| | | | | | RocketToilet | 4 | 1.8s | 13 |
| 111 | Galactic | 650 | — | — | **StriderRocketToilet** | **3** | **2.5s** | **10** |
| | | | | | *(Giới thiệu solo)* | | | |
| 112 | Galactic | 660 | — | — | QuadBladeStriderToilet | 3 | 0.7s | 13 |
| | | | | | UFOToilet | 5 | 0.9s | 15 |
| | | | | | RocketToilet | 5 | 1.5s | 14 |
| | | | | | StriderRocketToilet | 2 | 2.3s | 10 |
| 113 | Galactic | 670 | — | — | UFOToilet | 6 | 0.9s | 15 |
| | | | | | RocketToilet | 5 | 1.5s | 14 |
| | | | | | StriderRocketToilet | 2 | 2.3s | 11 |
| 114 | Galactic | 680 | — | — | QuadBladeStriderToilet | 3 | 0.7s | 14 |
| | | | | | UFOToilet | 5 | 0.8s | 16 |
| | | | | | RocketToilet | 5 | 1.3s | 14 |
| | | | | | StriderRocketToilet | 2 | 2.0s | 11 |
| 115 | Galactic | 690 | Wave 110 | — | UFOToilet | 5 | 0.8s | 16 |
| | | | | | RocketToilet | 6 | 1.3s | 14 |
| | | | | | StriderRocketToilet | 3 | 2.0s | 11 |
| 116 | Galactic | 700 | — | — | QuadBladeStriderToilet | 2 | 0.7s | 14 |
| | | | | | UFOToilet | 5 | 0.8s | 16 |
| | | | | | RocketToilet | 5 | 1.2s | 15 |
| | | | | | StriderRocketToilet | 3 | 1.8s | 12 |
| 117 | Galactic | 710 | — | — | UFOToilet | 4 | 0.7s | 16 |
| | | | | | RocketToilet | 7 | 1.1s | 15 |
| | | | | | StriderRocketToilet | 3 | 1.8s | 12 |
| 118 | Galactic | 720 | — | — | QuadBladeStriderToilet | 2 | 0.6s | 14 |
| | | | | | UFOToilet | 4 | 0.7s | 16 |
| | | | | | RocketToilet | 5 | 1.1s | 15 |
| | | | | | StriderRocketToilet | 4 | 1.5s | 12 |
| 119 | Galactic | 730 | — | — | UFOToilet | 3 | 0.7s | 16 |
| | | | | | RocketToilet | 7 | 1.0s | 15 |
| | | | | | StriderRocketToilet | 4 | 1.5s | 13 |
| **120** | **Galactic** | **750** | Wave 115 | — | QuadBladeStriderToilet | 1 | 0.6s | 14 |
| | | | | | UFOToilet | 3 | 0.6s | 16 |
| | | | | | RocketToilet | 5 | 1.0s | 15 |
| | | | | | StriderRocketToilet | 6 | 1.2s | 13 |

---

## Tóm tắt checkpoint & boss

| Wave | Sự kiện | Tổng quái |
|:---:|---|:---:|
| 10 | Mở Starting Wave 5 | 13 |
| 20 | Mở Starting Wave 15 | 12 |
| 30 | Mở Starting Wave 25 | 13 |
| **40** | **BOSS — BossToilet · Mở Wave 35** | **11** |
| 50 | Mở Starting Wave 45 | 13 |
| 60 | Mở Starting Wave 55 | 13 |
| 70 | Mở Starting Wave 65 | 13 |
| **80** | **BOSS — BossToilet2 · Mở Wave 70** | **9** |
| 90 | Mở Wave 85 · Giới thiệu InfectedTitan solo | 3 |
| 100 | Mở Starting Wave 96 | 13 |
| 110 | Mở Starting Wave 105 | 13 |
| 120 | **FINAL** · Mở Starting Wave 115 | 15 |

---

## Quy tắc thiết kế wave

| Wave loại | Mô tả |
|---|---|
| **Solo intro** | Enemy mới xuất hiện **3 con duy nhất**, không kết hợp. Người chơi học hành vi enemy thuần túy. |
| **Combo** | Sau wave solo intro, enemy mới được trộn dần với các enemy đã biết, số lượng tăng theo từng wave. |
| **Milestone** | Wave chia 10 (10, 20, 30…): mở shop trước, tặng tiền thưởng, preview enemy cycle tiếp theo. |
| **Boss** | Wave 40 và 80: tiền thưởng lớn, spawn boss + combo enemy mạnh nhất của cycle. |
