/*
 * Copyright 2008 Adobe Systems Inc., 2008 Google Inc.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * Contributor(s):
 *   Zwetan Kjukov <zwetan@gmail.com>.
 *   Marc Alcaraz <ekameleon@gmail.com>.
 */

package com.google.analytics.debug
{
    import flash.events.TextEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    /**
     * The Warning class.
     */
    public class Warning extends Label
    {
    	
    	/**
    	 * @private
    	 */
        private var _timer:Timer;
        
        /**
         * Creates a new Warning instance.
         */
        public function Warning( text:String="", timeout:uint = 3000 )
        {
            super(text, "uiWarning", Style.warningColor, Align.top, false ) ;
            margin.top = 32 ;
            if( timeout > 0 )
            {
                _timer = new Timer( timeout, 1 );
                _timer.start();
                _timer.addEventListener( TimerEvent.TIMER_COMPLETE, onComplete, false, 0, true );
            }
        }
        
        /**
         * Close the warning message.
         */
        public function close():void
        {
            if ( parent != null )
            {
                parent.removeChild( this );
            }
        }
        
        /**
         * Invoked when a link is selected in the text.
         */
        public override function onLink( event:TextEvent ):void
        {
            switch( event.text )
            {
                case "hide":
                close();
                break;
            }
        }
        
        /**
         * Invoked when the process is complete.
         */
        public function onComplete( event:TimerEvent ):void
        {
            close();
        }
        
    }
}