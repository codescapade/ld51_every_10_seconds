package scenes;

import aeons.events.SceneEvent;
import aeons.Aeons;
import aeons.core.Scene;

class LoadScene extends Scene {
  public override function create() {
    Aeons.assets.loadAtlas('sprites');
    Aeons.assets.loadBitmapFont('kenneypixel48');

    SceneEvent.emit(SceneEvent.REPLACE, GameScene);
  }
}
