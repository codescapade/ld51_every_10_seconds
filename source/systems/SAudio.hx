package systems;

import events.SoundEvent;

import aeons.Aeons;
import aeons.audio.SoundChannel;
import aeons.core.System;

class SAudio extends System {
  var deadChannel: SoundChannel;

  var checkpointChannel: SoundChannel;

  var jumpChannel: SoundChannel;

  var goalChannel: SoundChannel;

  public function create(): SAudio {
    final deadSound = Aeons.assets.getSound('dead');
    deadChannel = Aeons.audio.addChannel(deadSound);

    final checkpointSound = Aeons.assets.getSound('checkpoint');
    checkpointChannel = Aeons.audio.addChannel(checkpointSound);

    final jumpSound = Aeons.assets.getSound('jump');
    jumpChannel = Aeons.audio.addChannel(jumpSound);

    final goalSound = Aeons.assets.getSound('goal');
    goalChannel = Aeons.audio.addChannel(goalSound);

    Aeons.events.on(SoundEvent.CHECKPOINT, playCheckpoint);
    Aeons.events.on(SoundEvent.DEAD, playDead);
    Aeons.events.on(SoundEvent.GOAL, playGoal);
    Aeons.events.on(SoundEvent.JUMP, playJump);

    return this;
  }

  public override function cleanup() {
    Aeons.audio.removeChannel(deadChannel);
    Aeons.audio.removeChannel(checkpointChannel);
    Aeons.audio.removeChannel(jumpChannel);
    Aeons.audio.removeChannel(goalChannel);

    Aeons.events.off(SoundEvent.CHECKPOINT, playCheckpoint);
    Aeons.events.off(SoundEvent.DEAD, playDead);
    Aeons.events.off(SoundEvent.GOAL, playGoal);
    Aeons.events.off(SoundEvent.JUMP, playJump);
  }

  function playDead(event: SoundEvent) {
    deadChannel.play();
  }

  function playJump(event: SoundEvent) {
    jumpChannel.play();
  }

  function playCheckpoint(event: SoundEvent) {
    checkpointChannel.play();
  }

  function playGoal(event: SoundEvent) {
    goalChannel.play();
  }
}
