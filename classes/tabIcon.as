// tabIcon class
// Version 0.8.0 2008-06-25
// (cc)2007-2008 01media jungle
// By Jam Zhang
// jam@01media.cn

package{
	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.filters.BitmapFilterQuality;
	import codeplay.event.customEvent;

	public class tabIcon extends Sprite{

		function tabIcon():void{
			deactivate();
			mouseEnabled=false;
			addEventListener(Event.ADDED_TO_STAGE,init);
		}

		function init(event:Event):void{
			parent.addEventListener(pixusShell.EVENT_TAB_ACTIVATED,handleActivate);
		}

		function handleActivate(event:customEvent):void{
			if(event.data.object!=this)
				deactivate();
		}

		public function activate():void{
			var f:GlowFilter=new GlowFilter(0xFFFFFF,.5,15,15,2,BitmapFilterQuality.MEDIUM);
			filters=[f];
			alpha=1;
			parent.dispatchEvent(new customEvent(pixusShell.EVENT_TAB_ACTIVATED, {object:this}));
		}

		public function deactivate():void{
			alpha=.5;
			filters=[];
		}

	}
}
