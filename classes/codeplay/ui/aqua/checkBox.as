// checkBox class
// Version 2009-03-11
// (cc)2009 codeplay
// By Jam Zhang
// jammind@gmail.com

package codeplay.ui.aqua{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class checkBox extends Sprite{

		public function checkBox(c:Boolean=false):void{
			checked=c;
			checkMark.mouseEnabled=false;
			hotspot.addEventListener(MouseEvent.CLICK,handleClick);
		}

		function handleClick(e:MouseEvent){
			checked=!checked;
			dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}

		public function get checked():Boolean{
			return checkMark.visible;
		}

		public function set checked(c:Boolean){
			checkMark.visible=c;
		}

	}
}
