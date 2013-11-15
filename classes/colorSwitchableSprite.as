// colorSwitchableSprite class
// 2009-08-10
// (cc)2009 JPEG Interactive
// By Jam Zhang
// jammind@gmail.com

package{
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.desktop.NativeApplication;
	import flash.events.Event;

	public class colorSwitchableSprite extends Sprite{
		
		public static const TOGGLE_WIREFRAME_COLOR:String='PixusEventToggleWireframeColor';// Toggle colors of guides and inner ruler borders
		
		private var colors:Array;
		private var currentColor:int=0;

		public function colorSwitchableSprite(c:Array=null):void{
			if(c==null)
				c=[0x000000,0xFFFFFF];
			colors=c;
			setColor(0);
			NativeApplication.nativeApplication.addEventListener(TOGGLE_WIREFRAME_COLOR,handleColor);
		}
		
		function setColor(n:int):void{
			currentColor=n;
			var ct:ColorTransform=new ColorTransform();
			ct.color=colors[n];
			transform.colorTransform=ct;
		}
		
		public function nextColor():void{
			if(currentColor+1>=colors.length)
				setColor(0);
			else
				setColor(currentColor+1);
		}

		function handleColor(e:Event):void{
			nextColor();
		}
		
	}
}
