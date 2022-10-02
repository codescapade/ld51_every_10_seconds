package systems;

import events.SoundEvent;

import aeons.components.CText;

import events.ResetEvent;

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
  var timerBundles: Bundle<CCountdownText, CText>;

  @:bundle
  var cameraBundles: Bundle<CCamera>;

  var time = 10.0;

  var physics: SSimplePhysics;

  public function create(): SGameTimer {
    physics = getSystem(SSimplePhysics);

    Aeons.events.on(ResetEvent.RESET, reset);
    return this;
  }

  public function update(dt: Float) {
    if (playerBundles.count == 0) {
      return;
    }

    if (!playerBundles.first.cPlayer.started || playerBundles.first.cPlayer.finished) {
      return;
    }

    if (time > 0 && !playerBundles.first.cPlayer.dead) {
      time -= dt;
    } else if (!playerBundles.first.cPlayer.dead) {
      time = 0;
      SoundEvent.emit(SoundEvent.DEAD);
      playerBundles.first.cPlayer.dead = true;
      physics.gravity.y = 500;
      playerBundles.first.cSimpleBody.drag.x = 2;
      playerBundles.first.cTransform.scaleY = -1;
      playerBundles.first.cSimpleBody.bounds.height = 20;
      playerBundles.first.cAnimation.play(Anims.PlayerDead);

      Aeons.tweens.create(Aeons.timeStep, 2, { timeScale: 0.5 });
      Aeons.tweens.create(cameraBundles.first.cCamera, 1, { zoom: 2 });
    }

    final count = Math.round(time * 100.0) / 100.0;
    timerBundles.first.cText.text = '${count}';
  }

  function reset(event: ResetEvent) {
    time = 10.0;
    final count = Math.round(time * 100.0) / 100.0;
    timerBundles.first.cText.text = '${count}';
    Aeons.tweens.clear();
    Aeons.timeStep.timeScale = 1.0;
    Aeons.tweens.create(cameraBundles.first.cCamera, 0.2, { zoom: 1 });
    var player = playerBundles.first;
    physics.gravity.y = 1000;
    player.cPlayer.started = false;
    player.cPlayer.dead = false;
    player.cSimpleBody.drag.x = 8;
    player.cTransform.scaleY = 1;
    player.cTransform.setPosition(player.cPlayer.spawn.x, player.cPlayer.spawn.y);
    player.cSimpleBody.bounds.height = 26;
    player.cSimpleBody.acceleration.x = 0;
    player.cSimpleBody.velocity.set(0, 0);
  }
}
