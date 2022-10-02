package utils;

import scenes.IntroScene;
import scenes.GameScene;

import aeons.events.SceneEvent;

class Gbl {
  public static var instance(default, never) = new Gbl();

  public var level(default, null): Int;

  public final lastLevel = 9;

  public function reset() {
    level = 1;
  }

  public function nextLevel() {
    if (level < lastLevel) {
      level++;
      SceneEvent.emit(SceneEvent.REPLACE, GameScene);
    } else {
      reset();
      SceneEvent.emit(SceneEvent.REPLACE, IntroScene);
    }
  }

  function new() {
    reset();
  }
}
