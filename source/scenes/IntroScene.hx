package scenes;

import aeons.events.SceneEvent;
import aeons.events.input.KeyboardEvent;
import aeons.graphics.Color;
import aeons.components.CText;
import aeons.Aeons;
import aeons.components.CSprite;
import aeons.core.Entities;
import aeons.components.CCamera;
import aeons.components.CLdtkTilemap;
import aeons.components.CTransform;
import aeons.core.Entity;
import aeons.tilemap.ldtk.LdtkLayer;
import aeons.tilemap.Tileset;
import aeons.systems.SRender;
import aeons.core.Scene;

class IntroScene extends Scene {
  public override function create() {
    addSystem(SRender).create();

    final world = new LdtkWorld();
    final level = world.getLevel('Intro');

    final atlas = Aeons.assets.getAtlas('sprites');
    final font = Aeons.assets.getFont('kenney_pixel');

    final tileset = Tileset.fromLdtkTileset(level.l_Collision.tileset);
    final tileLayer = LdtkLayer.fromIntAutoLayer(level.l_Collision, tileset);

    final mapEntity = addEntity(Entity);
    mapEntity.addComponent(CTransform).create();

    final tilemap = mapEntity.addComponent(CLdtkTilemap).create();
    tilemap.addLayer(tileLayer);

    final playerData = level.l_Entities.all_Player[0];
    final goalData = level.l_Entities.all_Goal[0];
    final spikesData = level.l_Entities.all_Spike;

    final playerEntity = addEntity(Entity);
    playerEntity.addComponent(CTransform).create({ x: playerData.pixelX, y: playerData.pixelY });
    playerEntity.addComponent(CSprite).create({ atlas: atlas, frameName: 'player_idle_00' });

    final goalEntity = addEntity(Entity);
    goalEntity.addComponent(CTransform).create({ x: goalData.pixelX + 16, y: goalData.pixelY + 16 });
    goalEntity.addComponent(CSprite).create({ atlas: atlas, frameName: 'finish_flag' });

    for (spike in spikesData) {
      final spikeEntity = addEntity(Entity);
      spikeEntity.addComponent(CTransform).create({ x: spike.pixelX + 16, y: spike.pixelY + 16, angle: spike.f_Angle });
      spikeEntity.addComponent(CSprite).create({ atlas: atlas, frameName: 'spikes' });
    }

    final title = addEntity(Entity);
    title.addComponent(CTransform).create({ x: 80, y: 110 });
    title.addComponent(CText).create({
      font: font,
      fontSize: 150,
      text: 'Be Fast!',
      color: Color.Black,
      anchorX: 0
    });

    final name = addEntity(Entity);
    name.addComponent(CTransform).create({ x: 30, y: 512 });
    name.addComponent(CText).create({
      font: font,
      fontSize: 20,
      text: 'By Jurien Meerlo',
      color: Color.Black,
      anchorX: 0
    });

    final name = addEntity(Entity);
    name.addComponent(CTransform).create({ x: 316, y: 440 });
    name.addComponent(CText).create({
      font: font,
      fontSize: 36,
      text: 'Press Space to Play',
      color: Color.Black,
      anchorX: 0
    });
    final camEntity = addEntity(Entity);
    camEntity.addComponent(CTransform).create();
    camEntity.addComponent(CCamera).create({ backgroundColor: Color.fromBytes(80, 140, 200) });

    Aeons.events.on(KeyboardEvent.KEY_DOWN, (event: KeyboardEvent) -> {
      if (event.key == Space) {
        SceneEvent.emit(SceneEvent.REPLACE, GameScene);
      }
    });
  }
}
