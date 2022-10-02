package events;

import aeons.events.Event;
import aeons.events.EventType;

class SoundEvent extends Event {
  public static final JUMP: EventType<SoundEvent> = 'ld51_jump_sound';

  public static final DEAD: EventType<SoundEvent> = 'ld51_dead_sound';

  public static final CHECKPOINT: EventType<SoundEvent> = 'ld51_checkpoint_sound';

  public static final GOAL: EventType<SoundEvent> = 'ld51_goal_sound';
}
