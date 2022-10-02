package systems;

import utils.Anims;

import aeons.components.CAnimation;

import utils.Tag;

import aeons.math.Vector2;
import aeons.Aeons;
import aeons.physics.simple.Body;
import aeons.input.KeyCode;
import aeons.systems.SSimplePhysics;
import aeons.events.input.KeyboardEvent;

import components.CPlayer;

import aeons.components.CSimpleBody;
import aeons.components.CTransform;
import aeons.bundles.Bundle;
import aeons.core.Updatable;
import aeons.core.System;

class SPlayerMovement extends System implements Updatable {
  @:bundle
  var playerBundles: Bundle<CTransform, CSimpleBody, CPlayer, CAnimation>;

  var player: Bundle<CTransform, CSimpleBody, CPlayer, CAnimation>;

  final drag = 8.0;

  final xVelocity = 350.0;

  final acceleration = 20.0;

  final jumpSpeed = 480.0;

  final jumpCancelSpeed = 300;

  final airYVelocity = 600;

  final wallYVelocity = 30;

  var wallJumpSpeed = new Vector2(300, -400);

  final leftKeys: Array<KeyCode> = [Left, A];
  final rightKeys: Array<KeyCode> = [Right, D];
  final jumpKeys: Array<KeyCode> = [Space, W, Up];

  var physics: SSimplePhysics;

  var grounded = false;
  var jumping = false;

  var goingLeft = false;
  var goingRight = false;

  var onLeftWall = false;

  var onRightWall = false;

  var rayStart = new Vector2();

  var rayEnd = new Vector2();

  var rayTags = [Tag.Solid];

  var airTime = 0.0;

  var coyoteTime = 0.1;

  final moveThreshold = 10;

  public function create(): SPlayerMovement {
    physics = getSystem(SSimplePhysics);
    playerBundles.onAdded(onPlayerAdded);

    Aeons.events.on(KeyboardEvent.KEY_DOWN, keyDown);
    Aeons.events.on(KeyboardEvent.KEY_UP, keyUp);
    return this;
  }

  public override function cleanup() {
    Aeons.events.off(KeyboardEvent.KEY_DOWN, keyDown);
    Aeons.events.off(KeyboardEvent.KEY_UP, keyUp);
  }

  public function update(dt: Float) {
    if (player == null) {
      return;
    }

    if (player.cPlayer.exploded) {
      player.cSimpleBody.maxVelocity.y = airYVelocity;
      player.cSimpleBody.acceleration.x = 0;
      return;
    }

    final body = player.cSimpleBody;
    final transform = player.cTransform;
    final anim = player.cAnimation;
    grounded = false;
    onLeftWall = false;
    onRightWall = false;

    if (body.isTouching(BOTTOM)) {
      grounded = true;
      jumping = false;
      airTime = 0;
    } else {
      airTime += dt;
    }

    if (goingLeft) {
      transform.scaleX = -1;
      body.acceleration.x = -acceleration;
    } else if (goingRight) {
      transform.scaleX = 1;
      body.acceleration.x = acceleration;
    } else {
      body.acceleration.x = 0;
    }
    if ((body.velocity.x > 0 && body.velocity.x < 10) || (body.velocity.x < 0 && body.velocity.x > -10)) {
      body.velocity.x = 0;
    }

    if (grounded) {
      if (Math.abs(body.velocity.x) > moveThreshold) {
        if (anim.current != Anims.PlayerWalk) {
          anim.play(Anims.PlayerWalk);
        }
      } else {
        anim.play(Anims.PlayerIdle);
      }
    } else if (onLeftWall || onRightWall || body.velocity.y > 0) {
      anim.play(Anims.PlayerFall);
    } else {
      anim.play(Anims.PlayerJump);
    }

    transform.getWorldPosition(rayStart);
    onLeftWall = onWall(true);
    onRightWall = onWall(false);

    if (!grounded && (onLeftWall || onRightWall) && body.velocity.y > 0) {
      body.maxVelocity.y = wallYVelocity;
    } else {
      body.maxVelocity.y = airYVelocity;
    }
  }

  function onPlayerAdded(bundle: Bundle<CTransform, CSimpleBody, CPlayer, CAnimation>) {
    player = bundle;

    final body = player.cSimpleBody;
    body.maxVelocity.set(xVelocity, airYVelocity);
    body.drag.x = drag;
  }

  function keyDown(event: KeyboardEvent) {
    if (player == null || player.cPlayer.exploded) {
      return;
    }

    if (leftKeys.contains(event.key)) {
      if (!player.cPlayer.started) {
        player.cPlayer.started = true;
      }
      goingLeft = true;
    } else if (rightKeys.contains(event.key)) {
      goingRight = true;
      if (!player.cPlayer.started) {
        player.cPlayer.started = true;
      }
    } else if (jumpKeys.contains(event.key)) {
      if (!player.cPlayer.started) {
        player.cPlayer.started = true;
      }
      final body = player.cSimpleBody;
      final transform = player.cTransform;
      if (grounded || airTime < coyoteTime) {
        grounded = false;
        body.velocity.y = -jumpSpeed;
        jumping = true;
      } else if (onLeftWall) {
        body.velocity.set(wallJumpSpeed.x, wallJumpSpeed.y);
        body.maxVelocity.y = airYVelocity;
        jumping = true;
        transform.scaleX = 1;
      } else if (onRightWall) {
        body.velocity.set(-wallJumpSpeed.x, wallJumpSpeed.y);
        body.maxVelocity.y = airYVelocity;
        jumping = true;
        transform.scaleX = -1;
      }
    }
  }

  function keyUp(event: KeyboardEvent) {
    if (player == null || player.cPlayer.exploded) {
      return;
    }

    if (leftKeys.contains(event.key)) {
      goingLeft = false;
    } else if (rightKeys.contains(event.key)) {
      goingRight = false;
    } else if (jumpKeys.contains(event.key)) {
      final body = player.cSimpleBody;
      if (body.velocity.y < -jumpCancelSpeed) {
        body.velocity.y = -jumpCancelSpeed;
      }
    }
  }

  function onWall(left: Bool): Bool {
    rayStart.y += 8;
    if (left) {
      rayEnd.set(rayStart.x - 13, rayStart.y);
    } else {
      rayEnd.set(rayStart.x + 13, rayStart.y);
    }

    var hits = physics.raycast(rayStart, rayEnd, rayTags);
    if (hits.count == 0) {
      rayStart.y -= 16;
      rayEnd.y = rayStart.y;
      physics.raycast(rayStart, rayEnd, rayTags, hits);
      rayStart.y += 8;
    } else {
      rayStart.y -= 8;
    }

    return hits.count > 0;
  }
}
