// rulerButtons class
// 2009-03-18
// (cc)2007-2009 codeplay
// By Jam Zhang
// jammind@gmail.com

package {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.desktop.NativeApplication;
	import com.google.analytics.GATracker;
	import codeplay.event.customEvent;

	public class rulerButtons extends Sprite {
		var shell:pixusShell;
		private var tracker:GATracker=pixusShell.tracker;

		public function rulerButtons():void {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		function init(e:Event){
			shell=(parent as pixusRulerDragger).shell;
			buttonMove.addEventListener(MouseEvent.MOUSE_DOWN, handleButtons);
			buttonOverlay.addEventListener(MouseEvent.CLICK, handleButtons);
			buttonClose.addEventListener(MouseEvent.CLICK, handleButtons);
		}

		public function handleButtons(event:MouseEvent):void {
			switch(event.target){
				case buttonMove:
					if(shell.freeDragging)
						shell.stopFreeDrag();
					else{
						tracker.trackPageview('Pixus/FreeDrag');
						NativeApplication.nativeApplication.dispatchEvent(new customEvent(pixusShell.EVENT_START_FREE_DRAG));
					}
					break;
				case buttonOverlay:
					tracker.trackPageview('Pixus/Overlay/'+(pixusShell.options.pixusWindow.overlayMode?'On':'Off'));
					shell.stopFreeDrag();
					(parent.parent.parent as pixus).toggleOverlay();
					break;
				case buttonClose:
					tracker.trackPageview('Pixus/Hide');
					shell.stopFreeDrag();
					NativeApplication.nativeApplication.dispatchEvent(new customEvent(pixusShell.HIDE_PIXUS));
					break;
			}
		}

	}
}
