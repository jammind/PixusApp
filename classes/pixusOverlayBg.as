// pixusOverlayBg class
// (cc)2007 01media reactor
// By Jam Zhang
// jam@01media.cn

package {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;

	public class pixusOverlayBg extends Sprite {
		public function pixusOverlayBg():void {
			addEventListener(Event.ENTER_FRAME, handleInit);
		}

		public function handleInit(event:Event):void {
			handleResize(new Event(''));
			stage.addEventListener(Event.RESIZE, handleResize);
			removeEventListener(Event.ENTER_FRAME, handleInit);
		}

		public function handleResize(event:Event):void {
			width=stage.nativeWindow.width;
			height=stage.nativeWindow.height;
		}

	}
}
