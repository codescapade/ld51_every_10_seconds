package components;

import aeons.components.CCamera;
import aeons.math.Rect;
import aeons.components.CTransform;
import aeons.core.Updatable;
import aeons.core.Component;

using aeons.math.AeMath;

class CFollow extends Component implements Updatable {
  public var speed = 5.0;

  var target: CTransform;

  var bounds: Rect;

  var camera: CCamera;

  var transform: CTransform;

  public function create(target: CTransform, bounds: Rect): CFollow {
    this.target = target;
    this.bounds = bounds;

    transform = getComponent(CTransform);
    camera = getComponent(CCamera);

    return this;
  }

  public function update(dt: Float) {
    var x = Math.lerp(transform.x, target.x, speed * dt);
    var y = Math.lerp(transform.y, target.y, speed * dt);

    x = Math.clamp(x, bounds.x + camera.viewWidth * 0.5 / camera.zoom,
      bounds.width - camera.viewWidth * 0.5 / camera.zoom);
    y = Math.clamp(y, bounds.y + camera.viewHeight * 0.5 / camera.zoom,
      bounds.height - camera.viewHeight * 0.5 / camera.zoom);
    transform.x = x;
    transform.y = y;
  }

  override function get_requiredComponents(): Array<Class<Component>> {
    return [CCamera, CTransform];
  }
}
