package events;

import aeons.events.Event;
import aeons.events.EventType;

class ResetEvent extends Event {
  public static final RESET: EventType<ResetEvent> = 'ld51_reset';
}
