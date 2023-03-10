import 'dart:math';

import 'package:flutter/material.dart';
import 'package:khung_long/auth/auth_service.dart';
import 'package:khung_long/dino/cactus.dart';
import 'package:khung_long/dino/cloud.dart';
import 'package:khung_long/dino/constants.dart';
import 'package:khung_long/dino/dino.dart';
import 'package:khung_long/dino/game_object.dart';
import 'package:khung_long/dino/ground.dart';

class DinoRunWidget extends StatefulWidget {
  const DinoRunWidget({Key? key}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _DinoRunWidgetState createState() => _DinoRunWidgetState();
}

class _DinoRunWidgetState extends State<DinoRunWidget>
    with SingleTickerProviderStateMixin {
  Dino dino = Dino();
  double runVelocity = initialVelocity; // khai bao van toc chay
  double runDistance = 0; // khoang cach chay
  int highScore = 0;
  TextEditingController gravityController =
      TextEditingController(text: gravity.toString()); // trong luc
  TextEditingController accelerationController =
      TextEditingController(text: acceleration.toString()); // tang toc
  TextEditingController jumpVelocityController =
      TextEditingController(text: jumpVelocity.toString()); // van toc nhay
  TextEditingController runVelocityController =
      TextEditingController(text: initialVelocity.toString()); // toc do chay
  TextEditingController dayNightOffestController =
      TextEditingController(text: dayNightOffest.toString()); // ngay dem

  late AnimationController worldController;
  //[AnimationController]: tao tuyen tinh cac gia tri nam trong khoang 0,0 -> 1.0 trong time nhat dinh
  // vong doi : loai bo khi khong can thiet thuong duoc tao trong pphuong thuc initState va xoa trong dispose
  Duration lastUpdateCall = const Duration();

  List<Cactus> cacti = [Cactus(worldLocation: const Offset(200, 0))]; // chuong ngai vat

  List<Ground> ground = [
    Ground(worldLocation: const Offset(1000, 0)),
    Ground(worldLocation: Offset(groundSprite.imageWidth / 10, 0))
  ];

  List<Cloud> clouds = [
    Cloud(worldLocation: const Offset(100, 20)),
    Cloud(worldLocation: const Offset(200, 10)),
    Cloud(worldLocation: const Offset(350, -10)),
  ];

  @override
  void initState() {
    super.initState();
    worldController =
        AnimationController(vsync: this, duration: const Duration(days: 99));
        // dat days la 90 de cho hoat anh nay khong bao gio ket thuc khi nguoi dung van con choi
        // hoat anh nay se kiem soat tat ca cac hoat anh trong 1 lan
    worldController.addListener(_update);
    // goi nguoi nghe moi khi gia tri cua hoat anh thay doi
    // worldController.forward();
    _die();
  }

  void _die() {
    setState(() {
      worldController.stop();
      dino.die();
    });
  }

  void _newGame() {
    setState(() {
      highScore = max(highScore, runDistance.toInt());
      runDistance = 0;
      runVelocity = initialVelocity;
      dino.state = DinoState.running;
      dino.dispY = 0;
      worldController.reset();
      cacti = [
        Cactus(worldLocation: const Offset(200, 0)),
        Cactus(worldLocation: const Offset(300, 0)),
        Cactus(worldLocation: const Offset(450, 0)),
      ];

      ground = [
        Ground(worldLocation: const Offset(0, 0)),
        Ground(worldLocation: Offset(groundSprite.imageWidth / 10, 0))
      ];

      clouds = [
        Cloud(worldLocation: const Offset(100, 20)),
        Cloud(worldLocation: const Offset(200, 10)),
        Cloud(worldLocation: const Offset(350, -15)),
        Cloud(worldLocation: const Offset(500, 10)),
        Cloud(worldLocation: const Offset(550, -10)),
      ];

      worldController.forward();
    });
  }
// y tuong va cham : check xem dino va xuong rong cac phan tu o vuong cua no co chong len nhau hay khong
// tinh toan kich thuoc cua hinh chu nhat bang cach dung getect
  _update() {
    try {
      double elapsedTimeSeconds; // thoi gian da troi qua
      dino.update(lastUpdateCall, worldController.lastElapsedDuration);
      try {
        elapsedTimeSeconds =
            (worldController.lastElapsedDuration! - lastUpdateCall)
                    .inMilliseconds /
                1000;
      } catch (_) {
        elapsedTimeSeconds = 0;
      }

      runDistance += runVelocity * elapsedTimeSeconds; // bien nay de cho khoang cach giua dino va khung long giam dan
      if (runDistance < 0) runDistance = 0;
      runVelocity += acceleration * elapsedTimeSeconds;

      Size screenSize = MediaQuery.of(context).size;
      // lay ra ca 2 doi so chieu rong va chieu dai

      Rect dinoRect = dino.getRect(screenSize, runDistance);
      for (Cactus cactus in cacti) {
        Rect obstacleRect = cactus.getRect(screenSize, runDistance);
        if (dinoRect.overlaps(obstacleRect.deflate(20))) {
          // dieu kien check va cham
          _die();
        }

        if (obstacleRect.right < 0) {
          // hien thi vi tri chuong ngai vat
          // neu vi tri cay suong rong da ra khoi man hinh
          // thi remove cay cu
          // tao cay moi
          setState(() {
            cacti.remove(cactus);
            cacti.add(Cactus(
                worldLocation: Offset(
                    runDistance +
                        Random().nextInt(100) +
                        MediaQuery.of(context).size.width / worlToPixelRatio,
                    0)));
          });
        }
      }
      // lam cho ground khong bao gio bi mat tren han hinh
      for (Ground groundlet in ground) {
        if (groundlet.getRect(screenSize, runDistance).right < 0) {
          setState(() {
            ground.remove(groundlet);
            ground.add(
              Ground(
                worldLocation: Offset(
                  ground.last.worldLocation.dx + groundSprite.imageWidth / 10,
                  0,
                ),
              ),
            );
          });
        }
      }

      for (Cloud cloud in clouds) {
        if (cloud.getRect(screenSize, runDistance).right < 0) {
          setState(() {
            clouds.remove(cloud);
            clouds.add(
              Cloud(
                worldLocation: Offset(
                  clouds.last.worldLocation.dx +
                      Random().nextInt(200) +
                      MediaQuery.of(context).size.width / worlToPixelRatio,
                  Random().nextInt(50) - 25.0,
                ),
              ),
            );
          });
        }
      }

      lastUpdateCall = worldController.lastElapsedDuration!;
    } catch (e) {
      //
    }
  }

  @override
  void dispose() {
    gravityController.dispose();
    accelerationController.dispose();
    jumpVelocityController.dispose();
    runVelocityController.dispose();
    dayNightOffestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    List<Widget> children = [];

    for (GameObject object in [...clouds, ...ground, ...cacti, dino]) {
      children.add(
        AnimatedBuilder(
          animation: worldController,
          builder: (context, _) {
            Rect objectRect = object.getRect(screenSize, runDistance);
            // ????
            return Positioned(
              left: objectRect.left,
              top: objectRect.top + 70,
              width: objectRect.width,
              height: objectRect.height,
              child: object.render(),
            );
          },
        ),
      );
    }

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 5000),
        color: (runDistance ~/ dayNightOffest) % 2 == 0
            ? Colors.white
            : Colors.black,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          // do child co the la null nen dung translucent
          onTap: () {
            if (dino.state != DinoState.dead) {
              dino.jump();
            }
            if (dino.state == DinoState.dead) {
              _newGame();
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              ...children,
              AnimatedBuilder(
                animation: worldController,
                builder: (context, _) {
                  return Positioned(
                    // left: screenSize.width / 2 - 30,
                    top: 50,
                    child: Center(
                      child: Text(
                        'Điểm số của bạn: ${runDistance.toInt()}',
                        style: TextStyle(
                          color: (runDistance ~/ dayNightOffest) % 2 == 0
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: worldController,
                builder: (context, _) {
                  return Positioned(
                    // left: screenSize.width / 2 - 50,
                    top: 80,
                    child: Center(
                      child: Text(
                        'Điểm số cao nhất: $highScore',
                        style: TextStyle(
                          color: (runDistance ~/ dayNightOffest) % 2 == 0
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                right: 60,
                top: 20,
                child: IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    AuthService().signOut();
                  },
                ),
              ),
              Positioned(
                right: 20,
                top: 20,
                child: IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    _die();
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          // title: const Text("Thay đổi thông số"),
                          content: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: SizedBox(
                                  height: 25,
                                  width: 280,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Trọng lực:"),
                                      SizedBox(
                                        height: 25,
                                        width: 75,
                                        child: TextField(
                                          controller: gravityController,
                                          key: UniqueKey(),
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: SizedBox(
                                  height: 25,
                                  width: 280,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Tăng tốc:"),
                                      SizedBox(
                                        child: TextField(
                                          controller: accelerationController,
                                          key: UniqueKey(),
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                        ),
                                        height: 25,
                                        width: 75,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: SizedBox(
                                  height: 25,
                                  width: 280,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Vận tốc ban đầu:"),
                                      SizedBox(
                                        child: TextField(
                                          controller: runVelocityController,
                                          key: UniqueKey(),
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                        ),
                                        height: 25,
                                        width: 75,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: SizedBox(
                                  height: 25,
                                  width: 280,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Vận tốc nhảy:"),
                                      SizedBox(
                                        child: TextField(
                                          controller: jumpVelocityController,
                                          key: UniqueKey(),
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                        ),
                                        height: 25,
                                        width: 75,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: SizedBox(
                                  height: 25,
                                  width: 280,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Độ lệch ngày đêm"),
                                      SizedBox(
                                        height: 25,
                                        width: 75,
                                        child: TextField(
                                          controller: dayNightOffestController,
                                          key: UniqueKey(),
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  gravity = int.parse(gravityController.text);
                                  acceleration =
                                      double.parse(accelerationController.text);
                                  initialVelocity =
                                      double.parse(runVelocityController.text);
                                  jumpVelocity =
                                      double.parse(jumpVelocityController.text);
                                  dayNightOffest =
                                      int.parse(dayNightOffestController.text);
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  "Chấp Nhận",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            ],
                          ),

                          // actions: [],
                        );
                      },
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 10,
                child: TextButton(
                  onPressed: () {
                    _die();
                  },
                  child: const Text(
                    "Giết Khủng Long",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
