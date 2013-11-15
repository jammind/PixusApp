// menuRowBg class
// (cc)2008 01media jungle
// By Jam Zhang
// jam@01media.cn

package {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.desktop.NativeApplication;
	import flash.net.SharedObject;

	import caurina.transitions.Tweener;

	public class menuRowBg extends Sprite {
		const HIDE_BG:String='menuRowEventHideBg';
		const SHOW_BG:String='menuRowEventShowBg';

		public function menuRowBg():void {
			visible=false;
			addEventListener(Event.ADDED_TO_STAGE, handleInit);
		}

		public function handleInit(event:Event):void {
			dispatchEvent(new Event(HIDE_BG));
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouse);
		}

		// Handles Mouse Move When Not Dragging
		public function handleMouse(event:MouseEvent):void {
			if(menuRow.dragging)
				return;
			switch (event.type) {
				case MouseEvent.MOUSE_MOVE :
					if (visible==false&&hitTestPoint(event.stageX,event.stageY)) {
						visible=true;
					} else if (visible&&!hitTestPoint(event.stageX,event.stageY)) {
						visible=false;
					}
			}
		}

	}
}