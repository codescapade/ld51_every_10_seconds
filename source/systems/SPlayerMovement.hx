package systems;

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
  var playerBundles: Bundle<CTransform, CSimpleBody, CPlayer>;

  var player: Bundle<CTransform, CSimpleBody, CPlayer>;

  final drag = 8.0;

  final xVelocity = 350.0;

  final acceleration = 20.0;

  final jumpSpeed = 480.0;

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

    final body = player.cSimpleBody;
    final transform = player.cTransform;
    grounded = false;
    onLeftWall = false;
    onRightWall = false;

    if (body.isTouching(BOTTOM)) {
      grounded = true;
      jumping = false;
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

    transform.getWorldPosition(rayStart);
    onLeftWall = onWall(true);
    onRightWall = onWall(false);

    if (!grounded && (onLeftWall || onRightWall)) {
      body.maxVelocity.y = wallYVelocity;
    } else {
      body.maxVelocity.y = airYVelocity;
    }
  }

  function onPlayerAdded(bundle: Bundle<CTransform, CSimpleBody, CPlayer>) {
    player = bundle;

    final body = player.cSimpleBody;
    body.maxVelocity.set(xVelocity, airYVelocity);
    body.drag.x = drag;
  }

  function keyDown(event: KeyboardEvent) {
    if (player == null) {
      return;
    }

    if (leftKeys.contains(event.key)) {
      goingLeft = true;
    } else if (rightKeys.contains(event.key)) {
      goingRight = true;
    } else if (jumpKeys.contains(event.key)) {
      final body = player.cSimpleBody;
      final transform = player.cTransform;
      if (grounded) {
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
    if (player == null) {
      return;
    }

    if (leftKeys.contains(event.key)) {
      goingLeft = false;
    } else if (rightKeys.contains(event.key)) {
      goingRight = false;
    }
  }

  function onWall(left: Bool): Bool {
    rayStart.y += 8;
    if (left) {
      rayEnd.set(rayStart.x - 14, rayStart.y);
    } else {
      rayEnd.set(rayStart.x + 14, rayStart.y);
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
