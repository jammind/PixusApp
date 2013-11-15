// slidingPanels class
// (cc)2009 codeplay
// By Jam Zhang
// jam@01media.cn

package codeplay.ui.aqua{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import caurina.transitions.Tweener;

	public class slidingPanels extends Sprite{

		const blur:BlurFilter=new BlurFilter(10,0);

		var panelWidth:int;
		var tweeningTime:Number;
		var currentPanel:int=0;
		var x0:int;

		public function slidingPanels(w:int=300, t:Number=.3):void{
			cacheAsBitmap=true;
			panelWidth=w;
			tweeningTime=t;
			x0=x;
		}

		public function slideToPanel(id:int) {
			if (currentPanel!=id) {
				filters=[blur];
				currentPanel=id;
				Tweener.addTween(this,{x:x0-id*panelWidth,_blur_blurX:0,time:tweeningTime,transition:'easeOutCubic'});
			}
		}

	}
}
