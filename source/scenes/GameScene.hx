package scenes;

import aeons.systems.SDebugRender;
import aeons.graphics.Color;

import utils.Gbl;

import aeons.Aeons;
import aeons.components.CAnimation;
import aeons.components.CCamera;
import aeons.components.CLdtkTilemap;
import aeons.components.CSimpleBody;
import aeons.components.CSimpleTilemapCollider;
import aeons.components.CSprite;
import aeons.components.CText;
import aeons.components.CTransform;
import aeons.core.Entity;
import aeons.core.Scene;
import aeons.graphics.animation.Animation;
import aeons.graphics.atlas.Atlas;
import aeons.math.Rect;
import aeons.systems.SAnimation;
import aeons.systems.SRender;
import aeons.systems.SSimplePhysics;
import aeons.systems.SUpdate;
import aeons.tilemap.Tileset;
import aeons.tilemap.ldtk.LdtkLayer;

import components.CCountdownText;
import components.CFollow;
import components.CLevelStatus;
import components.CPlayer;

import systems.SAudio;
import systems.SGameTimer;
import systems.SInteractions;
import systems.SPlayerMovement;

import utils.Anims;
import utils.Tag;

class GameScene extends Scene {
  var playerTransform: CTransform;
  var camTransform: CTransform;

  public override function create() {
    final world = new LdtkWorld();
    final level = world.getLevel('Level_${Gbl.instance.level}');
    Aeons.timeStep.timeScale = 1.0;

    addSystem(SSimplePhysics).create({
      worldWidth: level.pxWid,
      worldHeight: level.pxHei,
      gravity: { x: 0, y: 1000 }
    });

    addSystem(SInteractions).create();
    addSystem(SAnimation).create();
    addSystem(SAudio).create();
    addSystem(SUpdate).create();
    addSystem(SPlayerMovement).create();
    addSystem(SGameTimer).create();
    addSystem(SRender).create();

    loadMap(level);

    final atlas = Aeons.assets.getAtlas('sprites');
    addEntities(level.l_Entities, atlas);

    createCamera(level.pxWid, level.pxHei);

    final txt = addEntity(Entity);
    txt.addComponent(CTransform).create({ x: 10, y: 10, parent: camTransform });
    txt.addComponent(CText).create({
      font: Aeons.assets.getFont('kenney_pixel'),
      text: '10.0',
      fontSize: 48,
      anchorX: 0,
      anchorY: 0,
      color: Color.Black,
      backgroundColor: Color.fromBytes(200, 200, 200, 80),
      hasBackground: true
    });
    txt.addComponent(CCountdownText).create();

    final levelStatus = addEntity(Entity);
    levelStatus.addComponent(CTransform)
      .create({ x: Aeons.display.viewCenterX, y: Aeons.display.viewCenterY, parent: camTransform });
    levelStatus.addComponent(CText).create({
      font: Aeons.assets.getFont('kenney_pixel'),
      fontSize: 100,
      text: 'Level Complete',
      color: Color.fromBytes(140, 240, 120)
    });
    levelStatus.addComponent(CLevelStatus).create();
    levelStatus.active = false;
  }

  function createCamera(width: Float, height: Float) {
    final camera = addEntity(Entity);
    camTransform = camera.addComponent(CTransform).create();
    camera.addComponent(CCamera).create({ backgroundColor: Color.fromBytes(80, 140, 200) });
    camera.addComponent(CFollow).create(playerTransform, new Rect(0, 0, width, height));
  }

  function loadMap(level: LdtkWorld.LdtkWorld_Level) {
    final tileset = Tileset.fromLdtkTileset(level.l_Collision.tileset);

    final tileLayer = LdtkLayer.fromIntAutoLayer(level.l_Collision, tileset);

    final entity = addEntity(Entity);
    entity.addComponent(CTransform).create();

    final tilemap = entity.addComponent(CLdtkTilemap).create();
    tilemap.addLayer(tileLayer);

    final collider = entity.addComponent(CSimpleTilemapCollider).create();
    collider.setCollisionsFromLdtkLayer(tileLayer, 0, 0, []);
    collider.addTag(Tag.Solid);
  }

  function addEntities(entities: LdtkWorld.Layer_Entities, atlas: Atlas) {
    addSpikes(entities.all_Spike, atlas);
    addCheckpoints(entities.all_Checkpoint, atlas);
    addGoal(entities.all_Goal[0], atlas);
    addPlayer(entities.all_Player[0], atlas);
  }

  function addPlayer(playerData: LdtkWorld.Entity_Player, atlas: Atlas) {
    final entity = addEntity(Entity);
    playerTransform = entity.addComponent(CTransform).create({ x: playerData.pixelX, y: playerData.pixelY });
    entity.addComponent(CSprite).create({ atlas: atlas, frameName: 'player_idle_00' });
    entity.addComponent(CSimpleBody).create({
      width: 20,
      height: 26,
      type: DYNAMIC,
      tags: [Tag.Player]
    });
    entity.addComponent(CPlayer).create(playerData.pixelX, playerData.pixelY);

    final idleAnim = new Animation(Anims.PlayerIdle, atlas, ['player_idle_00'], 0.1);
    final walkAnim = new Animation(Anims.PlayerWalk, atlas, [
      'player_walk_00',
      'player_walk_01',
      'player_walk_02',
      'player_walk_03',
      'player_walk_04'
    ], 0.05, LOOP);
    final jumpAnim = new Animation(Anims.PlayerJump, atlas, ['player_jump_00'], 0.1);
    final fallAnim = new Animation(Anims.PlayerFall, atlas, ['player_fall_00'], 0.1);
    final deadAnim = new Animation(Anims.PlayerDead, atlas, ['player_dead_00'], 0.1);

    entity.addComponent(CAnimation).create([idleAnim, walkAnim, jumpAnim, fallAnim, deadAnim]);
  }

  function addGoal(goalData: LdtkWorld.Entity_Goal, atlas: Atlas) {
    final entity = addEntity(Entity);
    entity.addComponent(CTransform).create({ x: goalData.pixelX + 16, y: goalData.pixelY + 16 });
    entity.addComponent(CSprite).create({ atlas: atlas, frameName: 'finish_flag' });
    entity.addComponent(CSimpleBody).create({
      width: 8,
      height: 32,
      isTrigger: true,
      type: STATIC,
      tags: [Tag.EndGoal]
    });
  }

  function addSpikes(spikesData: Array<LdtkWorld.Entity_Spike>, atlas: Atlas) {
    for (spike in spikesData) {
      final entity = addEntity(Entity);
      final angle = spike.f_Angle;
      entity.addComponent(CTransform).create({ x: spike.pixelX + 16, y: spike.pixelY + 16, angle: angle });
      entity.addComponent(CSprite).create({ atlas: atlas, frameName: 'spikes' });
      var bodyWidth = 0.0;
      var bodyHeight = 0.0;
      var xOffset = 0.0;
      var yOffset = 0.0;
      if (angle == 0) {
        bodyWidth = 26;
        bodyHeight = 8;
        xOffset = 0;
        yOffset = 12;
      } else if (angle == 90) {
        bodyWidth = 8;
        bodyHeight = 26;
        xOffset = -12;
        yOffset = 0;
      } else if (angle == 180) {
        bodyWidth = 26;
        bodyHeight = 8;
        xOffset = 0;
        yOffset = -12;
      } else if (angle == 270) {
        bodyWidth = 8;
        bodyHeight = 26;
        xOffset = 12;
        yOffset = 0;
      }

      entity.addComponent(CSimpleBody).create({
        width: bodyWidth,
        height: bodyHeight,
        offset: { x: xOffset, y: yOffset },
        type: STATIC,
        isTrigger: true,
        tags: [Tag.Death]
      });
    }
  }

  function addCheckpoints(checkPointsData: Array<LdtkWorld.Entity_Checkpoint>, atlas: Atlas) {
    for (checkpoint in checkPointsData) {
      final entity = addEntity(Entity);
      entity.addComponent(CTransform).create({ x: checkpoint.pixelX + 16, y: checkpoint.pixelY + 16 });
      entity.addComponent(CSprite).create({ atlas: atlas, frameName: 'checkpoint' });
      entity.addComponent(CSimpleBody).create({
        width: 8,
        height: 32,
        isTrigger: true,
        type: STATIC,
        tags: [Tag.Checkpoint]
      });
    }
  }
}
