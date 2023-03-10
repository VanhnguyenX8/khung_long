import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'constants.dart';
import 'game_object.dart';
import 'sprite.dart';

List<Sprite> dino = [
  Sprite()
    ..imagePath = "assets/game/dino/dino_1.png"
    ..imageWidth = 88
    ..imageHeight = 94,
  Sprite()
    ..imagePath = "assets/game/dino/dino_2.png"
    ..imageWidth = 88
    ..imageHeight = 94,
  Sprite()
    ..imagePath = "assets/game/dino/dino_3.png"
    ..imageWidth = 88
    ..imageHeight = 94,
  Sprite()
    ..imagePath = "assets/game/dino/dino_4.png"
    ..imageWidth = 88
    ..imageHeight = 94,
  Sprite()
    ..imagePath = "assets/game/dino/dino_5.png"
    ..imageWidth = 88
    ..imageHeight = 94,
  Sprite()
    ..imagePath = "assets/game/dino/dino_5.png"
    ..imageWidth = 88
    ..imageHeight = 94,
];

enum DinoState {
  jumping,
  running,
  dead,
}
// gioi han trang thai nhay cua khung long
class Dino extends GameObject {
  Sprite currentSprite = dino[0];
  double dispY = 0; // do dich chuyen cua Dino
  double velY = 0; // van toc cua Dino
  DinoState state = DinoState.running;

  @override
  Widget render() {
    return Image.asset(currentSprite.imagePath);
  }

  @override
  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
      screenSize.width / 10,
      screenSize.height / 1.75 - currentSprite.imageHeight - dispY,
      currentSprite.imageWidth.toDouble(),
      currentSprite.imageHeight.toDouble(),
    );
  }

  @override
  void update(Duration lastUpdate, Duration? elapsedTime) {
    double elapsedTimeSeconds;
    try {
      currentSprite = dino[(elapsedTime!.inMilliseconds / 100).floor() % 2 + 2];
      // mili(s) cu 100 mili(s) no se chuyen anh nay sang anh khac lam hoat anh chuyen dong
    } catch (_) {
      currentSprite = dino[0];
    }
    try{
      elapsedTimeSeconds = (elapsedTime! - lastUpdate).inMilliseconds / 1000;
    }
    catch(_){
      elapsedTimeSeconds = 0;
    }
    

    dispY += velY * elapsedTimeSeconds;
    if (dispY <= 0) {
      dispY = 0;
      velY = 0;
      state = DinoState.running;
    } // cau lenh nay de khi con khung long cham xuong mat day
      // no se khong di sau vao trong mat dat
    
     else {
      velY -= gravity * elapsedTimeSeconds;
    }
  }

  void jump() {
    // can chac chan ranc chua nhay lan nao thi moi duoc nhay lan dau
    // dieu nay han che viec bam qua nhieu lan vao man hinh
    // con khung long se khong con tren man hinh
    if (state != DinoState.jumping) {
      state = DinoState.jumping;
      velY = jumpVelocity;
    }
  }

  void die() {
    currentSprite = dino[5];
    state = DinoState.dead;
  }
}
