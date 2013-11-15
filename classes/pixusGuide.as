// pixusGuide class
// (cc)2009 JPEG Interactive
// By Jam Zhang
// jammind@gmail.com

package {
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.events.Event;

	public class pixusGuide extends Sprite {
		
		private var type:String;
		private var _host:pixusMain;

		public function pixusGuide(pm:pixusMain, t:String, pos:int=20):void {
			_host=pm;
			type=t.charAt(0);
			if(type=='H') {
				y=pos;
				_host.addEventListener(pixusMain.RESIZE_WIDTH,handleResize);
			} else {
				x=pos;
				_host.addEventListener(pixusMain.RESIZE_HEIGHT,handleResize);
			}
			_host.addEventListener(pixusMain.RESIZE,handleResize);
			redraw();
		}
		
		function redraw():void {
			graphics.clear();
			graphics.lineStyle(1,0,1,true);
			graphics.moveTo(0,0);
			if(type=='H'){
				graphics.lineTo(_host.rulerWidth,0);
			} else {
				graphics.lineTo(0,_host.rulerHeight);
			}
		}

		function handleResize(e:Event){
			redraw();
		}
		
	}
}