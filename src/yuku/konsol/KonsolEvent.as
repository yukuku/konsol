package yuku.konsol
{
	import flash.events.Event;

	public class KonsolEvent extends Event
	{
		public static const READ_COMPLETE: String = "readComplete"; 
		
		public var line: String;
		
		public function KonsolEvent(type: String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}