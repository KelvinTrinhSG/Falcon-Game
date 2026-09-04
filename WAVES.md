# Falcon — Wave & Enemy Reference

> **120 waves** · WalkSpeed mặc định = **16** · Attack range: **4 studs** · Attack cooldown: **1s** · Chờ giữa wave: **1s** · Speed multiplier x1/x2/x3 nhân vào WalkSpeed và chia vào Delay khi spawn.

---

## Chỉ số quái

| Tên quái | HP | Damage | Tiền/con | Ghi chú |
|---|---:|---:|---:|---|
| SmallYellowToilet | 60 | 5 | 1 | — |
| SmallRedToilet | 35 | 3 | 2 | Chết 1 phát Old Turret |
| LargeToilet | 250 | 15 | 3 | Tank đầu tiên |
| AssassinYellowToilet | 180 | 12 | 4 | — |
| AssassinRedToilet | 100 | 8 | 5 | — |
| PoliceToilet | 650 | 30 | 6 | Tank cycle 2 |
| GlassesYellowToilet | 450 | 25 | 7 | — |
| GlassesRedToilet | 280 | 18 | 8 | — |
| GlitchToilet | 1,800 | 50 | 9 | Phá Cardboard tức thì |
| DJYellowToilet | 1,200 | 45 | 10 | — |
| DJRedToilet | 850 | 35 | 11 | — |
| DualBladeToilet | 8,000 | 120 | 12 | Mini-boss cycle 4 |
| **BossToilet** | **35,000** | **200** | **50** | **Boss Wave 40** |
| VacuumYellowToilet | 2,000 | 50 | 13 | — |
| VacuumRedToilet | 4,500 | 80 | 14 | — |
| FlyingBuzzsawToilet | 9,000 | 150 | 15 | Boss cycle 5 |
| DualBladeYellowToilet | 3,500 | 90 | 16 | — |
| DualBladeRedToilet | 2,800 | 70 | 17 | — |
| FlyingRocketLauncherToilet | 25,000 | 200 | 18 | Boss Vịt Khổng Lồ |
| HelicopterParasiteYellowToilet | 6,000 | 120 | 19 | — |
| HelicopterParasiteRedToilet | 15,000 | 250 | 20 | Phá Netherite 2 phát |
| LargePoliceToilet | 50,000 | 400 | 25 | Boss tối thượng wave 70 |
| LargeFlyingBuzzsawYellowToilet | 12,000 | 150 | 21 | — |
| LargeFlyingBuzzsawRedToilet | 25,000 | 250 | 22 | — |
| GiantDualBladeToilet | 60,000 | 350 | 23 | Mini-boss Dưa Hấu |
| **BossToilet2** | **150,000** | **500** | **150** | **Boss Wave 80** |
| GiantGlassesYellowToilet | 30,000 | 200 | 24 | — |
| GiantGlassesRedToilet | 35,000 | 250 | 25 | — |
| SpiderToilet | 40,000 | 400 | 26 | — |
| InfectedTitanSpeakerman | 50,000 | 800 | 27 | — |
| QuadBladeStriderToilet | 60,000 | 9,000 | 28 | — |
| UFOToilet | 70,000 | 10,000 | 29 | — |
| RocketToilet | 800,000 | 11,000 | 30 | — |
| StriderRocketToilet | 900,000 | 12,500 | 31 | — |

---

## Danh sách Wave (120 Wave)

Wave có nhiều loại quái sẽ chiếm nhiều dòng. Các ô trống ở dòng phụ thuộc về wave phía trên.

| STT | Cycle | Tiền Wave | Mở Wave | Boss | Tên quái | Số lượng | Delay spawn |
|:---:|---|---:|:---:|:---:|---|---:|---:|
| 1 | Khởi Đầu | 10 | — | — | SmallYellowToilet | 3 | 1.5s |
| 2 | Khởi Đầu | 15 | — | — | SmallYellowToilet | 5 | 1.2s |
| 3 | Khởi Đầu | 20 | — | — | SmallYellowToilet | 8 | 1.0s |
| 4 | Khởi Đầu | 25 | — | — | SmallYellowToilet | 12 | 0.8s |
| 5 | Khởi Đầu | 35 | — | — | SmallYellowToilet | 8 | 1.0s |
| | | | | | SmallRedToilet | 3 | 1.5s |
| 6 | Khởi Đầu | 45 | — | — | SmallYellowToilet | 10 | 1.0s |
| | | | | | SmallRedToilet | 5 | 1.2s |
| 7 | Khởi Đầu | 60 | — | — | SmallYellowToilet | 15 | 0.8s |
| | | | | | SmallRedToilet | 8 | 1.0s |
| 8 | Khởi Đầu | 80 | — | — | SmallYellowToilet | 10 | 1.0s |
| | | | | | SmallRedToilet | 5 | 1.0s |
| | | | | | LargeToilet | 1 | 3.0s |
| 9 | Khởi Đầu | 100 | — | — | SmallYellowToilet | 15 | 0.8s |
| | | | | | SmallRedToilet | 10 | 1.0s |
| | | | | | LargeToilet | 2 | 4.0s |
| 10 | Khởi Đầu | 150 | Wave 5 | — | LargeToilet | 1 | 2.0s |
| | | | | | SmallRedToilet | 15 | 0.5s |
| | | | | | SmallYellowToilet | 20 | 0.8s |
| | | | | | LargeToilet | 2 | 3.0s |
| | | | | | AssassinYellowToilet | 1 | 2.5s |
| 11 | Transition | 55 | — | — | AssassinYellowToilet | 5 | 1.2s |
| 12 | Transition | 60 | — | — | AssassinYellowToilet | 8 | 1.0s |
| 13 | Transition | 65 | — | — | AssassinYellowToilet | 12 | 0.8s |
| 14 | Transition | 70 | — | — | AssassinYellowToilet | 10 | 1.0s |
| | | | | | AssassinRedToilet | 3 | 1.5s |
| 15 | Transition | 75 | Wave 10 | — | AssassinYellowToilet | 12 | 1.0s |
| | | | | | AssassinRedToilet | 5 | 1.2s |
| 16 | Transition | 80 | — | — | AssassinYellowToilet | 15 | 0.8s |
| | | | | | AssassinRedToilet | 8 | 1.0s |
| 17 | Transition | 85 | — | — | AssassinYellowToilet | 12 | 1.0s |
| | | | | | AssassinRedToilet | 5 | 1.0s |
| | | | | | PoliceToilet | 2 | 3.0s |
| 18 | Transition | 90 | — | — | AssassinYellowToilet | 15 | 0.8s |
| | | | | | AssassinRedToilet | 8 | 1.0s |
| | | | | | PoliceToilet | 3 | 3.0s |
| 19 | Transition | 95 | — | — | AssassinYellowToilet | 20 | 0.8s |
| | | | | | AssassinRedToilet | 10 | 1.0s |
| | | | | | PoliceToilet | 4 | 3.0s |
| 20 | Transition | 150 | Wave 15 | — | PoliceToilet | 2 | 2.0s |
| | | | | | AssassinRedToilet | 15 | 0.5s |
| | | | | | AssassinYellowToilet | 25 | 0.8s |
| | | | | | PoliceToilet | 3 | 3.0s |
| | | | | | GlassesYellowToilet | 1 | 2.5s |
| 21 | Mid Game | 105 | — | — | GlassesYellowToilet | 5 | 1.2s |
| 22 | Mid Game | 110 | — | — | GlassesYellowToilet | 8 | 1.0s |
| 23 | Mid Game | 115 | — | — | GlassesYellowToilet | 12 | 0.8s |
| 24 | Mid Game | 120 | — | — | GlassesYellowToilet | 10 | 1.0s |
| | | | | | GlassesRedToilet | 3 | 1.5s |
| 25 | Mid Game | 125 | Wave 20 | — | GlassesYellowToilet | 12 | 1.0s |
| | | | | | GlassesRedToilet | 5 | 1.2s |
| 26 | Mid Game | 130 | — | — | GlassesYellowToilet | 15 | 0.8s |
| | | | | | GlassesRedToilet | 8 | 1.0s |
| 27 | Mid Game | 135 | — | — | GlassesYellowToilet | 12 | 1.0s |
| | | | | | GlassesRedToilet | 5 | 1.0s |
| | | | | | GlitchToilet | 2 | 3.0s |
| 28 | Mid Game | 140 | — | — | GlassesYellowToilet | 15 | 0.8s |
| | | | | | GlassesRedToilet | 8 | 1.0s |
| | | | | | GlitchToilet | 3 | 3.0s |
| 29 | Mid Game | 145 | — | — | GlassesYellowToilet | 20 | 0.8s |
| | | | | | GlassesRedToilet | 10 | 1.0s |
| | | | | | GlitchToilet | 4 | 3.0s |
| 30 | Mid Game | 200 | Wave 25 | — | GlitchToilet | 2 | 2.0s |
| | | | | | GlassesRedToilet | 15 | 0.5s |
| | | | | | GlassesYellowToilet | 25 | 0.8s |
| | | | | | GlitchToilet | 3 | 3.0s |
| | | | | | DJYellowToilet | 1 | 2.5s |
| 31 | Late Game | 155 | — | — | DJYellowToilet | 5 | 1.2s |
| 32 | Late Game | 160 | — | — | DJYellowToilet | 8 | 1.0s |
| 33 | Late Game | 165 | — | — | DJYellowToilet | 12 | 0.8s |
| 34 | Late Game | 170 | — | — | DJYellowToilet | 10 | 1.0s |
| | | | | | DJRedToilet | 3 | 1.5s |
| 35 | Late Game | 175 | Wave 30 | — | DJYellowToilet | 12 | 1.0s |
| | | | | | DJRedToilet | 5 | 1.2s |
| 36 | Late Game | 180 | — | — | DJYellowToilet | 15 | 0.8s |
| | | | | | DJRedToilet | 8 | 1.0s |
| 37 | Late Game | 185 | — | — | DJYellowToilet | 12 | 1.0s |
| | | | | | DJRedToilet | 5 | 1.0s |
| | | | | | DualBladeToilet | 2 | 3.0s |
| 38 | Late Game | 190 | — | — | DJYellowToilet | 15 | 0.8s |
| | | | | | DJRedToilet | 8 | 1.0s |
| | | | | | DualBladeToilet | 3 | 3.0s |
| 39 | Late Game | 195 | — | — | DJYellowToilet | 20 | 0.8s |
| | | | | | DJRedToilet | 10 | 1.0s |
| | | | | | DualBladeToilet | 4 | 3.0s |
| **40** | **Late Game** | **300** | Wave 35 | ✅ BossToilet | DJRedToilet | 10 | 0.5s |
| | | | | | DJYellowToilet | 20 | 0.8s |
| | | | | | **BossToilet** | **1** | **3.0s** |
| | | | | | VacuumYellowToilet | 1 | 1.5s |
| 41 | Nature | 205 | — | — | VacuumYellowToilet | 5 | 1.2s |
| 42 | Nature | 210 | — | — | VacuumYellowToilet | 8 | 1.0s |
| 43 | Nature | 215 | — | — | VacuumYellowToilet | 12 | 0.8s |
| 44 | Nature | 220 | — | — | VacuumYellowToilet | 10 | 1.0s |
| | | | | | VacuumRedToilet | 3 | 1.5s |
| 45 | Nature | 225 | Wave 40 | — | VacuumYellowToilet | 12 | 1.0s |
| | | | | | VacuumRedToilet | 5 | 1.2s |
| 46 | Nature | 230 | — | — | VacuumYellowToilet | 15 | 0.8s |
| | | | | | VacuumRedToilet | 8 | 1.0s |
| 47 | Nature | 235 | — | — | VacuumYellowToilet | 10 | 1.0s |
| | | | | | VacuumRedToilet | 5 | 1.0s |
| | | | | | FlyingBuzzsawToilet | 2 | 3.0s |
| 48 | Nature | 240 | — | — | VacuumYellowToilet | 10 | 0.8s |
| | | | | | VacuumRedToilet | 8 | 1.0s |
| | | | | | FlyingBuzzsawToilet | 3 | 3.0s |
| 49 | Nature | 245 | — | — | VacuumYellowToilet | 15 | 0.8s |
| | | | | | VacuumRedToilet | 10 | 1.0s |
| | | | | | FlyingBuzzsawToilet | 2 | 3.0s |
| 50 | Nature | 350 | Wave 45 | — | FlyingBuzzsawToilet | 2 | 2.0s |
| | | | | | VacuumYellowToilet | 15 | 0.5s |
| | | | | | VacuumRedToilet | 10 | 0.8s |
| | | | | | FlyingBuzzsawToilet | 3 | 3.0s |
| | | | | | DualBladeYellowToilet | 1 | 2.5s |
| 51 | Animals | 255 | — | — | DualBladeYellowToilet | 5 | 1.2s |
| 52 | Animals | 260 | — | — | DualBladeYellowToilet | 8 | 1.0s |
| 53 | Animals | 265 | — | — | DualBladeYellowToilet | 12 | 0.8s |
| 54 | Animals | 270 | — | — | DualBladeYellowToilet | 10 | 1.0s |
| | | | | | DualBladeRedToilet | 3 | 1.5s |
| 55 | Animals | 275 | Wave 50 | — | DualBladeYellowToilet | 12 | 1.0s |
| | | | | | DualBladeRedToilet | 5 | 1.2s |
| 56 | Animals | 280 | — | — | DualBladeYellowToilet | 15 | 0.8s |
| | | | | | DualBladeRedToilet | 8 | 1.0s |
| 57 | Animals | 285 | — | — | DualBladeYellowToilet | 12 | 1.0s |
| | | | | | DualBladeRedToilet | 5 | 1.0s |
| | | | | | FlyingRocketLauncherToilet | 2 | 3.0s |
| 58 | Animals | 290 | — | — | DualBladeYellowToilet | 15 | 0.8s |
| | | | | | DualBladeRedToilet | 8 | 1.0s |
| | | | | | FlyingRocketLauncherToilet | 3 | 3.0s |
| 59 | Animals | 295 | — | — | DualBladeYellowToilet | 20 | 0.8s |
| | | | | | DualBladeRedToilet | 10 | 1.0s |
| | | | | | FlyingRocketLauncherToilet | 4 | 3.0s |
| 60 | Animals | 400 | Wave 55 | — | FlyingRocketLauncherToilet | 2 | 2.0s |
| | | | | | DualBladeRedToilet | 15 | 0.5s |
| | | | | | DualBladeYellowToilet | 25 | 0.8s |
| | | | | | FlyingRocketLauncherToilet | 3 | 3.0s |
| | | | | | HelicopterParasiteYellowToilet | 1 | 2.5s |
| 61 | Ocean | 305 | — | — | HelicopterParasiteYellowToilet | 5 | 1.2s |
| 62 | Ocean | 310 | — | — | HelicopterParasiteYellowToilet | 8 | 1.0s |
| 63 | Ocean | 315 | — | — | HelicopterParasiteYellowToilet | 12 | 0.8s |
| 64 | Ocean | 320 | — | — | HelicopterParasiteYellowToilet | 10 | 1.0s |
| | | | | | HelicopterParasiteRedToilet | 3 | 1.5s |
| 65 | Ocean | 325 | Wave 60 | — | HelicopterParasiteYellowToilet | 12 | 1.0s |
| | | | | | HelicopterParasiteRedToilet | 5 | 1.2s |
| 66 | Ocean | 330 | — | — | HelicopterParasiteYellowToilet | 15 | 0.8s |
| | | | | | HelicopterParasiteRedToilet | 8 | 1.0s |
| 67 | Ocean | 335 | — | — | HelicopterParasiteYellowToilet | 12 | 1.0s |
| | | | | | HelicopterParasiteRedToilet | 5 | 1.0s |
| | | | | | LargePoliceToilet | 1 | 3.0s |
| 68 | Ocean | 340 | — | — | HelicopterParasiteYellowToilet | 15 | 0.8s |
| | | | | | HelicopterParasiteRedToilet | 8 | 1.0s |
| | | | | | LargePoliceToilet | 2 | 3.0s |
| 69 | Ocean | 345 | — | — | HelicopterParasiteYellowToilet | 20 | 0.8s |
| | | | | | HelicopterParasiteRedToilet | 10 | 1.0s |
| | | | | | LargePoliceToilet | 3 | 3.0s |
| 70 | Ocean | 400 | Wave 65 | — | HelicopterParasiteRedToilet | 10 | 0.5s |
| | | | | | HelicopterParasiteYellowToilet | 20 | 0.8s |
| | | | | | LargePoliceToilet | 1 | 0.0s |
| | | | | | LargeFlyingBuzzsawYellowToilet | 1 | 3.0s |
| 71 | Fruits | 355 | — | — | LargeFlyingBuzzsawYellowToilet | 5 | 1.2s |
| 72 | Fruits | 360 | — | — | LargeFlyingBuzzsawYellowToilet | 8 | 1.0s |
| 73 | Fruits | 365 | — | — | LargeFlyingBuzzsawYellowToilet | 12 | 0.8s |
| 74 | Fruits | 370 | — | — | LargeFlyingBuzzsawYellowToilet | 10 | 1.0s |
| | | | | | LargeFlyingBuzzsawRedToilet | 3 | 1.5s |
| 75 | Fruits | 375 | Wave 70 | — | LargeFlyingBuzzsawYellowToilet | 12 | 1.0s |
| | | | | | LargeFlyingBuzzsawRedToilet | 5 | 1.2s |
| 76 | Fruits | 380 | — | — | LargeFlyingBuzzsawYellowToilet | 15 | 0.8s |
| | | | | | LargeFlyingBuzzsawRedToilet | 8 | 1.0s |
| 77 | Fruits | 385 | — | — | LargeFlyingBuzzsawYellowToilet | 12 | 1.0s |
| | | | | | LargeFlyingBuzzsawRedToilet | 5 | 1.0s |
| | | | | | GiantDualBladeToilet | 2 | 3.0s |
| 78 | Fruits | 390 | — | — | LargeFlyingBuzzsawYellowToilet | 15 | 0.8s |
| | | | | | LargeFlyingBuzzsawRedToilet | 8 | 1.0s |
| | | | | | GiantDualBladeToilet | 3 | 3.0s |
| 79 | Fruits | 395 | — | — | LargeFlyingBuzzsawYellowToilet | 20 | 0.8s |
| | | | | | LargeFlyingBuzzsawRedToilet | 10 | 1.0s |
| | | | | | GiantDualBladeToilet | 4 | 3.0s |
| **80** | **Fruits** | **400** | Wave 70 | ✅ BossToilet2 | LargeFlyingBuzzsawRedToilet | 10 | 0.5s |
| | | | | | GiantDualBladeToilet | 5 | 1.0s |
| | | | | | **BossToilet2** | **1** | **1.5s** |
| 81 | Veggie Hell | 405 | — | — | GiantGlassesYellowToilet | 8 | 1.0s |
| 82 | Veggie Hell | 410 | — | — | GiantGlassesYellowToilet | 12 | 0.8s |
| 83 | Veggie Hell | 415 | — | — | GiantGlassesYellowToilet | 15 | 0.8s |
| 84 | Veggie Hell | 420 | — | — | GiantGlassesYellowToilet | 12 | 1.0s |
| | | | | | GiantGlassesRedToilet | 3 | 1.5s |
| 85 | Veggie Hell | 425 | Wave 80 | — | GiantGlassesYellowToilet | 15 | 0.8s |
| | | | | | GiantGlassesRedToilet | 6 | 1.2s |
| 86 | Veggie Hell | 430 | — | — | GiantGlassesYellowToilet | 18 | 0.8s |
| | | | | | GiantGlassesRedToilet | 10 | 1.0s |
| 87 | Veggie Hell | 435 | — | — | GiantGlassesYellowToilet | 15 | 0.8s |
| | | | | | GiantGlassesRedToilet | 12 | 1.0s |
| | | | | | SpiderToilet | 2 | 2.5s |
| 88 | Veggie Hell | 440 | — | — | GiantGlassesYellowToilet | 20 | 0.6s |
| | | | | | GiantGlassesRedToilet | 15 | 0.8s |
| | | | | | SpiderToilet | 4 | 2.0s |
| 89 | Veggie Hell | 445 | — | — | GiantGlassesYellowToilet | 20 | 0.5s |
| | | | | | GiantGlassesRedToilet | 18 | 0.8s |
| | | | | | SpiderToilet | 7 | 1.5s |
| 90 | Veggie Hell | 450 | Wave 85 | — | GiantGlassesYellowToilet | 20 | 0.4s |
| | | | | | GiantGlassesRedToilet | 20 | 0.6s |
| | | | | | SpiderToilet | 10 | 1.0s |
| | | | | | InfectedTitanSpeakerman | 1 | 3.0s |
| 91 | Veggie Hell | 455 | — | — | GiantGlassesRedToilet | 25 | 0.6s |
| | | | | | SpiderToilet | 12 | 1.0s |
| 92 | Veggie Hell | 460 | — | — | GiantGlassesYellowToilet | 35 | 0.3s |
| | | | | | GiantGlassesRedToilet | 25 | 0.6s |
| | | | | | SpiderToilet | 15 | 1.0s |
| 93 | Veggie Hell | 465 | — | — | GiantGlassesRedToilet | 30 | 0.5s |
| | | | | | SpiderToilet | 18 | 0.8s |
| | | | | | InfectedTitanSpeakerman | 2 | 4.0s |
| 94 | Veggie Hell | 470 | — | — | GiantGlassesYellowToilet | 40 | 0.3s |
| | | | | | GiantGlassesRedToilet | 30 | 0.5s |
| | | | | | SpiderToilet | 20 | 0.8s |
| 95 | Veggie Hell | 475 | Wave 90 | — | GiantGlassesRedToilet | 35 | 0.5s |
| | | | | | SpiderToilet | 25 | 0.8s |
| | | | | | InfectedTitanSpeakerman | 3 | 3.0s |
| 96 | Veggie Hell | 480 | — | — | GiantGlassesYellowToilet | 40 | 0.2s |
| | | | | | SpiderToilet | 30 | 0.6s |
| 97 | Veggie Hell | 485 | — | — | GiantGlassesRedToilet | 40 | 0.4s |
| | | | | | SpiderToilet | 35 | 0.6s |
| | | | | | InfectedTitanSpeakerman | 5 | 2.5s |
| 98 | Veggie Hell | 490 | — | — | GiantGlassesYellowToilet | 50 | 0.2s |
| | | | | | GiantGlassesRedToilet | 40 | 0.4s |
| | | | | | SpiderToilet | 35 | 0.5s |
| 99 | Veggie Hell | 495 | — | — | GiantGlassesRedToilet | 50 | 0.3s |
| | | | | | SpiderToilet | 45 | 0.4s |
| | | | | | InfectedTitanSpeakerman | 4 | 2.0s |
| 100 | Veggie Hell | 500 | Wave 96 | — | GiantGlassesYellowToilet | 50 | 0.15s |
| | | | | | GiantGlassesRedToilet | 45 | 0.2s |
| | | | | | SpiderToilet | 35 | 0.3s |
| | | | | | InfectedTitanSpeakerman | 10 | 1.5s |
| 101 | Planetary | 510 | — | — | QuadBladeStriderToilet | 8 | 1.2s |
| 102 | Planetary | 520 | — | — | QuadBladeStriderToilet | 12 | 1.0s |
| 103 | Planetary | 530 | — | — | QuadBladeStriderToilet | 15 | 0.8s |
| 104 | Planetary | 540 | — | — | QuadBladeStriderToilet | 12 | 1.0s |
| | | | | | UFOToilet | 4 | 1.5s |
| 105 | Planetary | 550 | Wave 100 | — | QuadBladeStriderToilet | 15 | 0.8s |
| | | | | | UFOToilet | 8 | 1.2s |
| 106 | Planetary | 560 | — | — | QuadBladeStriderToilet | 20 | 0.8s |
| | | | | | UFOToilet | 12 | 1.0s |
| 107 | Planetary | 570 | — | — | QuadBladeStriderToilet | 18 | 0.8s |
| | | | | | UFOToilet | 15 | 1.0s |
| | | | | | RocketToilet | 3 | 2.0s |
| 108 | Planetary | 580 | — | — | QuadBladeStriderToilet | 25 | 0.6s |
| | | | | | UFOToilet | 18 | 0.8s |
| | | | | | RocketToilet | 6 | 1.5s |
| 109 | Planetary | 590 | — | — | QuadBladeStriderToilet | 30 | 0.5s |
| | | | | | UFOToilet | 22 | 0.8s |
| | | | | | RocketToilet | 10 | 1.2s |
| 110 | Planetary | 600 | Wave 105 | — | QuadBladeStriderToilet | 35 | 0.5s |
| | | | | | UFOToilet | 25 | 0.6s |
| | | | | | RocketToilet | 15 | 1.0s |
| | | | | | StriderRocketToilet | 2 | 3.0s |
| 111 | Galactic | 610 | — | — | UFOToilet | 20 | 0.8s |
| | | | | | RocketToilet | 12 | 1.0s |
| 112 | Galactic | 620 | — | — | QuadBladeStriderToilet | 30 | 0.5s |
| | | | | | UFOToilet | 25 | 0.6s |
| | | | | | RocketToilet | 15 | 1.0s |
| 113 | Galactic | 630 | — | — | UFOToilet | 30 | 0.6s |
| | | | | | RocketToilet | 20 | 0.8s |
| | | | | | StriderRocketToilet | 4 | 2.5s |
| 114 | Galactic | 640 | — | — | QuadBladeStriderToilet | 40 | 0.4s |
| | | | | | UFOToilet | 35 | 0.5s |
| | | | | | RocketToilet | 25 | 0.8s |
| 115 | Galactic | 650 | Wave 110 | — | UFOToilet | 40 | 0.5s |
| | | | | | RocketToilet | 30 | 0.8s |
| | | | | | StriderRocketToilet | 6 | 2.0s |
| 116 | Galactic | 660 | — | — | QuadBladeStriderToilet | 50 | 0.3s |
| | | | | | RocketToilet | 35 | 0.6s |
| 117 | Galactic | 670 | — | — | UFOToilet | 45 | 0.4s |
| | | | | | RocketToilet | 40 | 0.6s |
| | | | | | StriderRocketToilet | 8 | 1.5s |
| 118 | Galactic | 680 | — | — | QuadBladeStriderToilet | 60 | 0.2s |
| | | | | | UFOToilet | 50 | 0.3s |
| | | | | | RocketToilet | 45 | 0.5s |
| 119 | Galactic | 690 | — | — | UFOToilet | 60 | 0.3s |
| | | | | | RocketToilet | 55 | 0.4s |
| | | | | | StriderRocketToilet | 12 | 1.2s |
| **120** | **Galactic** | **700** | Wave 115 | — | QuadBladeStriderToilet | 75 | 0.2s |
| | | | | | UFOToilet | 65 | 0.3s |
| | | | | | RocketToilet | 60 | 0.4s |
| | | | | | StriderRocketToilet | 25 | 1.0s |
