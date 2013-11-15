// hidingWindow class
// An NativeWindow that hide itself instead of closing the window
// 2009-3-2
// (cc)2009 codeplay
// By Jam Zhang
// jam@01media.cn

package {
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.events.Event;
	import flash.system.Capabilities;

	public class hidingWindow extends NativeWindow {

		function hidingWindow(initOptions:NativeWindowInitOptions):void {
			super(initOptions);
			// Ignore for Mac OS.
			// Canceling Event.CLOSING will prevent app from quiting under Mac OS.
			if(Capabilities.os.indexOf('Mac OS')==-1)
				addEventListener(Event.CLOSING, handleWindowClose);
		}

		function handleWindowClose(event:Event):void {
			event.preventDefault();
			visible=false;
		}

	}
}