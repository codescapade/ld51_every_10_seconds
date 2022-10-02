package scenes;

import utils.Anims;

import aeons.components.CAnimation;
import aeons.graphics.animation.Animation;
import aeons.systems.SAnimation;

import systems.SGameTimer;

import components.CCountdownText;

import aeons.components.CBitmapText;
import aeons.components.CText;
import aeons.math.Rect;

import components.CFollow;

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

    addSystem(SAnimation).create();
    addSystem(SUpdate).create();
    addSystem(SPlayerMovement).create();
    addSystem(SGameTimer).create();
    addSystem(SRender).create();
    // addSystem(SDebugRender).create();

    createCamera();

    loadMap(level);

    final levelEntities = level.l_Entities;
    final playerData = levelEntities.all_Player[0];

    final atlas = Aeons.assets.getAtlas('sprites');

    final e = addEntity(Entity);
    final playerTransform = e.addComponent(CTransform).create({ x: playerData.pixelX, y: playerData.pixelY });
    e.addComponent(CSprite).create({ atlas: atlas, frameName: 'player_idle_00' });
    e.addComponent(CSimpleBody).create({ width: 20, height: 26, type: DYNAMIC });
    e.addComponent(CPlayer).create(playerData.pixelX, playerData.pixelY);

    var idleAnim = new Animation(Anims.PlayerIdle, atlas, ['player_idle_00'], 0.1);
    var walkAnim = new Animation(Anims.PlayerWalk, atlas, [
      'player_walk_00',
      'player_walk_01',
      'player_walk_02',
      'player_walk_03',
      'player_walk_04'
    ], 0.1, LOOP);
    var jumpAnim = new Animation(Anims.PlayerJump, atlas, ['player_jump_00'], 0.1);
    var fallAnim = new Animation(Anims.PlayerFall, atlas, ['player_fall_00'], 0.1);
    var deadAnim = new Animation(Anims.PlayerDead, atlas, ['player_dead_00'], 0.1);

    e.addComponent(CAnimation).create([idleAnim, walkAnim, jumpAnim, fallAnim, deadAnim]);

    final camera = addEntity(Entity);
    final camTransform = camera.addComponent(CTransform).create();
    camera.addComponent(CCamera).create({ backgroundColor: Color.fromBytes(80, 140, 200) });
    camera.addComponent(CFollow).create(playerTransform, new Rect(0, 0, level.pxWid, level.pxHei));

    final txt = addEntity(Entity);
    txt.addComponent(CTransform).create({ x: 10, y: 10, parent: camTransform });
    txt.addComponent(CBitmapText).create({
      font: Aeons.assets.getBitmapFont('kenneypixel48'),
      text: '10.00',
      anchorX: 0,
      anchorY: 0
    });
    txt.addComponent(CCountdownText).create();
  }

  function createCamera() {}

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
