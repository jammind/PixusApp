// progressBar class
// Version 2009-03-10
// (cc)2009 codeplay
// By Jam Zhang
// jam@01media.cn

package codeplay.ui.aqua{
	import flash.display.Sprite;
	import flash.events.Event;
	import caurina.transitions.Tweener;

	public class progressBar extends Sprite{

		var TWEENING_TIME:Number;
		var blinkingPhase:Number;
		var blinking:Boolean=false;

		public function progressBar(tweeningTime:Number=.5):void{
			TWEENING_TIME=tweeningTime;
			fg.masked.width=bg.width=width;
			scaleX=1;
			fg.mask.width=0;
			enableBlinking();
		}

		public function setProgress(p:Number){
			p=Math.max(0,Math.min(1,p));
			if(p==1||p==0)
				disableBlinking();
			else
				enableBlinking();
			Tweener.addTween(fg.mask,{width:int((bg.width-2)*p),time:TWEENING_TIME,transition:'easeOutCubic'});
		}

		function handleEnterFrame(e:Event){
			fg.alpha=0.9+0.1*Math.cos(blinkingPhase);
			blinkingPhase+=.15;
		}

		function enableBlinking(){
			if(!blinking){
				blinkingPhase=0;
				blinking=true;
				addEventListener(Event.ENTER_FRAME,handleEnterFrame);
			}
		}

		function disableBlinking(){
			if(blinking){
				blinking=false;
				removeEventListener(Event.ENTER_FRAME,handleEnterFrame);
				fg.alpha=1;
			}
		}

	}
}
