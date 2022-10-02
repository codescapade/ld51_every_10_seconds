package components;

import aeons.math.Vector2;
import aeons.core.Component;

class CPlayer extends Component {
  public var spawn: Vector2;

  public var started = false;

  public var exploded = false;

  public function create(spawnX: Float, spawnY: Float): CPlayer {
    spawn = new Vector2(spawnX, spawnY);

    return this;
  }
}
