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
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;    

    /**
     * The Debug class.
     */
    public class Debug extends Label
    {
        private var _lines:Array;
        private var _linediff:int = 0;
        private var _preferredForcedWidth:uint = 540;
        
        /**
         * The maximum number of lines in the debug label display.
         */
        public var maxLines:uint = 16;
        
        /**
         * The count value of the debug.
         */
        public static var count:uint ;
        
        /**
         * Creates a new Debug instance.
         * @param color The color of the debug label.
         * @param alignement The Align value of the debug label.
         * @param stickToEdge The flag to defines the stickToEdge value.
         */
        public function Debug( color:uint=0, alignement:Align=null, stickToEdge:Boolean=false )
        {
            if( alignement == null )
            {
                alignement = Align.bottom;
            }
            
            super("", "uiLabel", color, alignement, stickToEdge);
            
            this.name = "Debug"+ count++;
            
            _lines = [];
            
            //forcedWidth = 540;
            //forcedWidth = this.parent.width;
            selectable  = true;
            
            addEventListener( KeyboardEvent.KEY_DOWN, onKey );
        }
        
        public override function get forcedWidth():uint
        {
            if( this.parent )
            {
                if( UISprite(this.parent).forcedWidth > _preferredForcedWidth )
                {
                    return _preferredForcedWidth;
                }
                else
                {
                    return UISprite(this.parent).forcedWidth;
                }
            }
            else
            {
                return super.forcedWidth;
            }
        }
        
        /**
         * Dispose the debug display.
         */
        protected override function dispose():void
        {
            removeEventListener( KeyboardEvent.KEY_DOWN, onKey );
            super.dispose();
        }
        
        /**
         * Invoked when a key is down.
         * @private
         */
        private function onKey( event:KeyboardEvent = null ):void
        {
            var lines:Array;
            
            switch( event.keyCode )
            {
                case Keyboard.DOWN:
                lines = _getLinesToDisplay( 1 );
                break;
                
                case Keyboard.UP:
                lines = _getLinesToDisplay( -1 );
                break;
                
                default:
                lines = null;
            }
            
            if( lines == null )
            {
                return;
            }
            
            text = lines.join( "\n" );
            
        }
        
        /**
         * @private
         */
        private function _getLinesToDisplay( direction:int = 0 ):Array
        {
            var lines:Array;
            
            if( _lines.length-1 > maxLines )
            {
                if( (_linediff <= 0) )
                {
                    _linediff += direction;
                }
                else if( (_linediff > 0) && (direction < 0) )
                {
                    _linediff += direction;
                }
                
                var start:uint = _lines.length-maxLines+_linediff;
                var end:uint   = start + maxLines;
                
                lines = _lines.slice( start, end );
            }
            else
            {
                lines = _lines;
            }
            
            return lines;
        }
        
        /**
         * Close the debug.
         */
        public function close():void
        {
            dispose();
        }        
        
        /**
         * Writes a new message in the debug label.
         * @param message The message value to show in the debug label in the application.
         * @param bold this flag indicates if the message format use a bold to display the text.
         */
        public function write( message:String, bold:Boolean = false ):void
        {
            
            var inputLines:Array;
            
            if( message.indexOf( "" ) > -1 )
            {
                inputLines = message.split( "\n" );
            }
            else
            {
                inputLines = [ message ];
            }
            
            var pre:String  = "";
            var post:String = "";
            
            if( bold )
            {
                pre  = "<b>";
                post = "</b>";
            }
            
            for( var i:int = 0; i<inputLines.length; i++ )
            {
                _lines.push( pre + inputLines[i] + post );
            }
            
            var lines:Array = _getLinesToDisplay();
            
            text = lines.join("\n");
        }
        
        /**
         * Writes a new bold message in the debug label.
         * @param message The message value to show in the debug label in the application.
         */
        public function writeBold( message:String ):void
        {
            write( message, true );
        }
        

        
    }
}