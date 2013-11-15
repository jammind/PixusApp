////////////////////////////////////////////////////////////////
//
// PrintScreener - saves data stored in the buffer (clipboard)
// to a JPG file to a desired place.
//
// @author Jloa | julious.loa@gmail.com
//
////////////////////////////////////////////////////////////////

package 
{
	import fl.controls.Button;
	import flash.display.MovieClip;
	import flash.display.BitmapData;
	import flash.display.NativeWindow;
	import flash.desktop.NativeApplication;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.ClipboardTransferMode;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.filesystem.*;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	import com.adobe.images.JPGEncoder;

	public class PrintScreener extends MovieClip 
	{
		private var jpgEncoder:JPGEncoder = new JPGEncoder(100);
		private var imageBA:ByteArray = new ByteArray();
		private var imageBD:BitmapData
		private var devider:Number = 20;
		private var btn:Button;
		private var bg:Background;
		private var alert:Alert;
		private var lastClipboard:BitmapData=new BitmapData(10,10);

		/**
		 * Constructor
		 */
		public function PrintScreener() 
		{
			super();
			init();
		}

		/**
		 * Initializes the app
		 * @return nothing
		 */
		public function init():void 
		{
			bg = new Background();
			bg.addEventListener(MouseEvent.MOUSE_DOWN, bgMouseDownHandler);
			addChild(bg);
			myTrace('init');
			
			btn = new Button();
			btn.label = "save";
			btn.x = stage.stageWidth - btn.width - devider;
			btn.y = stage.stageHeight - btn.height - devider;
			btn.addEventListener(MouseEvent.CLICK, saveButtonClickHandler);
			addChild(btn);
			
			alert = new Alert();
			addChild(alert);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		function myTrace(s:String){
			bg.tf.appendText(s+'\n');
			bg.tf.scrollV=bg.tf.maxScrollV;
		}
		/**
		 * @private save button click event handler; retrieves data from clipboard, 
		 * encodes bitmapData to a jpg standarted bytearray, calls the save dialog
		 */
		private function saveButtonClickHandler(event:MouseEvent):void 
		{
			imageBD = Clipboard.generalClipboard.getData(ClipboardFormats.BITMAP_FORMAT) as BitmapData;
			if(imageBD)
			{
				imageBA = jpgEncoder.encode(imageBD);
			
				var docsDir:File = File.documentsDirectory;
				try
				{
					docsDir.browseForSave("Save As");
					docsDir.addEventListener(Event.SELECT, saveImage);
				} 
				catch (error:Error)
				{
					throw new Error("Failed: "+error.message, 0);
				}
			}else{
				alert.play();
				throw new Error("ClipBoard seems to be free or not bitmap", 0);
			}
		}
		
		/**
		 * @private just a save management
		 */
		private function saveImage(event:Event):void
		{
    		var newFile:File = event.target as File;
   			if (!newFile.exists)
    		{
        		var stream:FileStream = new FileStream();
        		stream.open(newFile, FileMode.WRITE);
				stream.writeBytes(imageBA);
        		stream.close();
   			}
		}
		
		/**
		 * @private handler
		 */
		private function keyDownHandler(event:KeyboardEvent):void
		{
			myTrace('keyCode='+event.keyCode);
			if(event.keyCode == 27)
				NativeApplication.nativeApplication.exit();
		}

		private function enterFrameHandler(event:Event):void
		{
			monitorClipboard();
		}

		function monitorClipboard(){
			myTrace('Clipboard Updated\n'+Clipboard.generalClipboard.formats);

			// Windows Screencapture Trigger
			if(Clipboard.generalClipboard.formats.length==1&&Clipboard.generalClipboard.formats[0]==ClipboardFormats.BITMAP_FORMAT&&!Clipboard.generalClipboard.hasFormat('Pixus Checked')){
				if(Clipboard.generalClipboard.hasFormat(ClipboardFormats.BITMAP_FORMAT)){
					var bd:BitmapData = Clipboard.generalClipboard.getData(ClipboardFormats.BITMAP_FORMAT,ClipboardTransferMode.CLONE_ONLY) as BitmapData;
					myTrace(bd.width+','+bd.height);
					if(bd.width==Capabilities.screenResolutionX&&bd.height==Capabilities.screenResolutionY){
						myTrace('Screen Captured');
					}
					// Copy clipboard data
					Clipboard.generalClipboard.setData(ClipboardFormats.BITMAP_FORMAT,bd);
				}
				Clipboard.generalClipboard.setData('Pixus Checked',true);
			}
		}

		function bgMouseDownHandler(event:MouseEvent):void
		{
			stage.nativeWindow.activate();
			stage.nativeWindow.startMove();
		}
	}
}