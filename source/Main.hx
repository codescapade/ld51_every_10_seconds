package;

import aeons.core.Game;

import scenes.GameScene;

class Main {
  static function main() {
    new Game({
      title: 'ld51_every_10_seconds',
      preload: true,
      startScene: GameScene,
      designWidth: 800,
      designHeight: 600
    });
  }
}
