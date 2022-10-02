package systems;

import utils.Anims;

import aeons.components.CAnimation;
import aeons.components.CCamera;
import aeons.systems.SSimplePhysics;
import aeons.components.CSprite;
import aeons.components.CTransform;
import aeons.core.Entity;
import aeons.Aeons;
import aeons.math.Vector2;
import aeons.components.CSimpleBody;
import aeons.components.CBitmapText;

import components.CCountdownText;
import components.CPlayer;

import aeons.bundles.Bundle;
import aeons.core.Updatable;
import aeons.core.System;

class SGameTimer extends System implements Updatable {
  @:bundle
  var playerBundles: Bundle<CPlayer, CSimpleBody, CTransform, CSprite, CAnimation>;

  @:bundle
  var timerBundles: Bundle<CCountdownText, CBitmapText>;

  @:bundle
  var cameraBundles: Bundle<CCamera>;

  var time = 10.0;

  var physics: SSimplePhysics;

  public function create(): SGameTimer {
    physics = getSystem(SSimplePhysics);

    return this;
  }

  public function update(dt: Float) {
    if (playerBundles.count == 0) {
      return;
    }

    if (!playerBundles.first.cPlayer.started) {
      return;
    }

    if (time > 0) {
      time -= dt;
      var count = Math.round(time * 100.0) / 100.0;
      timerBundles.first.cBitmapText.text = '${count}';
    } else if (!playerBundles.first.cPlayer.exploded) {
      playerBundles.first.cPlayer.exploded = true;
      physics.gravity.y = 500;
      playerBundles.first.cSimpleBody.drag.x = 2;
      playerBundles.first.cTransform.scaleY = -1;
      playerBundles.first.cSimpleBody.bounds.width = 20;
      playerBundles.first.cSimpleBody.bounds.height = 20;
      playerBundles.first.cAnimation.play(Anims.PlayerDead);

      Aeons.tweens.create(Aeons.timeStep, 2, { timeScale: 0.5 });
      Aeons.tweens.create(cameraBundles.first.cCamera, 1, { zoom: 2 });
      time = 0;
      var count = Math.round(time * 100.0) / 100.0;
      timerBundles.first.cBitmapText.text = '${count}';
    }
  }
}
