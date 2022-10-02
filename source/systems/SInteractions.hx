package systems;

import utils.Gbl;

import events.SoundEvent;

import aeons.components.CText;

import components.CLevelStatus;

import aeons.components.CCamera;
import aeons.Aeons;

import utils.Anims;

import aeons.components.CAnimation;
import aeons.components.CSprite;
import aeons.components.CTransform;
import aeons.components.CSimpleBody;

import components.CPlayer;

import aeons.bundles.Bundle;
import aeons.physics.simple.Body;

import utils.Tag;

import aeons.systems.SSimplePhysics;
import aeons.core.System;

class SInteractions extends System {
  var physics: SSimplePhysics;

  @:bundle
  var playerBundles: Bundle<CPlayer, CSimpleBody, CTransform, CSprite, CAnimation>;

  @:bundle
  var cameraBundles: Bundle<CCamera>;

  @:bundle
  var statusTextBundles: Bundle<CLevelStatus, CText>;

  public function create(): SInteractions {
    physics = getSystem(SSimplePhysics);

    physics.addInteractionListener(TRIGGER_START, Tag.Player, Tag.EndGoal, hitGoal);
    physics.addInteractionListener(TRIGGER_START, Tag.Player, Tag.Checkpoint, hitCheckpoint);
    physics.addInteractionListener(TRIGGER_START, Tag.Player, Tag.Death, hitDeath);

    return this;
  }

  function hitGoal(player: Body, goal: Body) {
    SoundEvent.emit(SoundEvent.GOAL);
    playerBundles.first.cPlayer.finished = true;
    playerBundles.first.cSimpleBody.velocity.set(0, 0);
    playerBundles.first.cSimpleBody.acceleration.x = 0;
    statusTextBundles.first.cText.text = 'Level Complete';
    statusTextBundles.first.entity.active = true;
    if (!playerBundles.first.cPlayer.dead) {
      playerBundles.first.cAnimation.play(Anims.PlayerFall);
    }

    Aeons.timers.create(1.5, () -> {
      Gbl.instance.nextLevel();
    }, 0, true);
  }

  function hitCheckpoint(player: Body, checkpoint: Body) {
    final sprite = checkpoint.component.getComponent(CSprite);
    if (sprite.frameName != 'checkpoint_active') {
      SoundEvent.emit(SoundEvent.CHECKPOINT);
      sprite.setFrame('checkpoint_active');

      final transform = checkpoint.component.getComponent(CTransform);
      playerBundles.first.cPlayer.spawn.set(transform.x, transform.y);
    }
  }

  function hitDeath(player: Body, death: Body) {
    if (!playerBundles.first.cPlayer.dead) {
      SoundEvent.emit(SoundEvent.DEAD);
      playerBundles.first.cPlayer.dead = true;
      physics.gravity.y = 500;
      playerBundles.first.cSimpleBody.drag.x = 2;
      playerBundles.first.cTransform.scaleY = -1;
      playerBundles.first.cSimpleBody.bounds.width = 20;
      playerBundles.first.cSimpleBody.bounds.height = 20;
      playerBundles.first.cAnimation.play(Anims.PlayerDead);

      Aeons.tweens.create(Aeons.timeStep, 2, { timeScale: 0.5 });
      Aeons.tweens.create(cameraBundles.first.cCamera, 1, { zoom: 2 });
    }
  }
}
