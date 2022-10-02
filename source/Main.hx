package;

import aeons.core.Game;

import scenes.LoadScene;

class Main {
  static function main() {
    new Game({
      title: 'Explosive Platforming',
      preload: true,
      startScene: LoadScene,
      designWidth: 960,
      designHeight: 540,
      pixelArt: true
    });
  }
}
