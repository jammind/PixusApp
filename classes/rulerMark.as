// rulerMark class
// (cc)2007 01media reactor
// By Jam Zhang
// jam@01media.cn

package {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;

	public class rulerMark extends Sprite {

		public function rulerMark(text:String) {
			(getChildByName('tf') as TextField).text=text;
		}
	}
}