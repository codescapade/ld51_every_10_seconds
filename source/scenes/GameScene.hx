package scenes;

import utils.Tag;

import systems.SPlayerMovement;

import components.CPlayer;

import aeons.components.CSimpleBody;
import aeons.components.CSprite;
import aeons.systems.SDebugRender;
import aeons.components.CSimpleTilemapCollider;
import aeons.components.CLdtkTilemap;
import aeons.tilemap.ldtk.LdtkLayer;
import aeons.tilemap.Tileset;
import aeons.systems.SSimplePhysics;
import aeons.Aeons;
import aeons.components.CBoxShape;
import aeons.components.CCamera;
import aeons.components.CTransform;
import aeons.core.Entity;
import aeons.core.Scene;
import aeons.graphics.Color;
import aeons.systems.SRender;
import aeons.systems.SUpdate;

class GameScene extends Scene {
  public override function create() {
    final world = new LdtkWorld();
    final level = world.getLevel('Level_1');

    addSystem(SSimplePhysics).create({
      worldWidth: level.pxWid,
      worldHeight: level.pxHei,
      gravity: { x: 0, y: 1000 }
    });

    addSystem(SUpdate).create();
    addSystem(SPlayerMovement).create();
    addSystem(SRender).create();
    addSystem(SDebugRender).create();

    createCamera();

    loadMap(level);

    final levelEntities = level.l_Entities;
    final playerData = levelEntities.all_Player[0];

    final atlas = Aeons.assets.getAtlas('sprites');

    final e = addEntity(Entity);
    e.addComponent(CTransform).create({ x: playerData.pixelX, y: playerData.pixelY });
    e.addComponent(CSprite).create({ atlas: atlas, frameName: 'player_idle_00' });
    e.addComponent(CSimpleBody).create({ width: 20, height: 26, type: DYNAMIC });
    e.addComponent(CPlayer).create();
  }

  function createCamera() {
    final camera = addEntity(Entity);
    camera.addComponent(CTransform).create();
    camera.addComponent(CCamera).create({ backgroundColor: Color.fromBytes(80, 140, 200) });
  }

  function loadMap(level: LdtkWorld.LdtkWorld_Level) {
    final tileset = Tileset.fromLdtkTileset(level.l_Tiles.tileset);

    final tileLayer = LdtkLayer.fromTilesLayer(level.l_Tiles, tileset);

    final entity = addEntity(Entity);
    entity.addComponent(CTransform).create();

    final tilemap = entity.addComponent(CLdtkTilemap).create();
    tilemap.addLayer(tileLayer);

    final collider = entity.addComponent(CSimpleTilemapCollider).create();
    collider.setCollisionsFromLdtkLayer(tileLayer, 0, 0, []);
    collider.addTag(Tag.Solid);
  }
}
