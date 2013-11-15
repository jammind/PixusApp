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
    import com.google.analytics.core.GIFRequest;
    
    import flash.net.URLRequest;
    import flash.ui.Keyboard;
    import flash.utils.getTimer;
    
    /**
     * The DebugConfiguration class.
     */
    public class DebugConfiguration
    {
        private var _active:Boolean            = false;
        private var _verbose:Boolean           = false;
        private var _visualInitialized:Boolean = false;
        private var _mode:VisualDebugMode      = VisualDebugMode.basic;
        
        /**
         * Indicates the Layout reference.
         */
        public var layout:ILayout;
        
        /**
         * To trace infos and warning to the output.
         */
        public var traceOutput:Boolean = false;
        
        /**
        * Allow to debug ExternalInterface calls.
        */
        public var javascript:Boolean = false;
        
        /**
         * Allow to debug the GIF Request if true, will show a debug panel
         * and a confirmation message to send or not the request.
         */
        public var GIFRequests:Boolean = false;
        
        /**
         * Indicates if show infos in the debug mode.
         */
        public var showInfos:Boolean = true;
        
        /**
         * Indicates the info timeout value.
         */
        public var infoTimeout:Number = 1000;
        
        /**
         * Indicates if show warnings in the debug mode.
         */
        public var showWarnings:Boolean = true;
        
        /**
         * Indicates the warning timeout value.
         */
        public var warningTimeout:Number = 1500;
        
        /**
        * Show the visuals minimized on start.
        */
        public var minimizedOnStart:Boolean = false;
        
        /**
        * The key code to show/hide the visual debug.
        */
        public var showHideKey:Number = Keyboard.SPACE;
        
        /**
        * The key code to destroy the visual debug.
        */
        public var destroyKey:Number  = Keyboard.BACKSPACE;
        
        /**
         * Creates a new DebugConfiguration instance. 
         */
        public function DebugConfiguration()
        {
            
        }
        
        private function _initializeVisual():void
        {
            if( layout )
            {
                layout.init();
                _visualInitialized = true;
            }
        }
        
        private function _destroyVisual():void
        {
            if( layout && _visualInitialized )
            {
                layout.destroy();
            }
        }
        
        
        [Inspectable(defaultValue="basic", enumeration="basic,advanced,geek", type="String")]
        public function get mode():*
        {
            return _mode;
        }
        
        public function set mode( value:* ):void
        {
            if( value is String )
            {
                switch( value )
                {
                    case "geek":
                    value = VisualDebugMode.geek;
                    break;
                    
                    case "advanced":
                    value = VisualDebugMode.advanced;
                    break;
                    
                    default:
                    case "basic":
                    value = VisualDebugMode.basic;
                }
            }
            
            _mode = value;
        }
        
        /**
         * The protected custom trace method.
         */
        protected function trace( message:String ):void
        {
            var messages:Array = [];
            
            var pre0:String = "";
            var pre1:String = "";
            
            if( this.mode == VisualDebugMode.geek )
            {
                pre0 = getTimer() + " - ";
                pre1 = new Array(pre0.length).join(" ") + " ";
            }
            
            if( message.indexOf("\n") > -1 )
            {
                var msgs:Array = message.split("\n");
                for( var j:int = 0; j<msgs.length; j++ )
                {
                    if( msgs[j] == "" )
                    {
                        continue;
                    }
                    
                    if( j == 0 )
                    {
                        messages.push( pre0 + msgs[j] );
                    }
                    else
                    {
                        messages.push( pre1 + msgs[j] );
                    }
                }
            }
            else
            {
                messages.push( pre0 + message );
            }
            
            var len:int = messages.length ;
            for( var i:int = 0; i<len ; i++ )
            {
                public::trace( messages[i] );
            }
        }
        
        /**
         * Set or unset the activation of the debug session, and if the layout is present, the initialization and destruction of the visual displays.
         */
        public function get active():Boolean
        {
            return _active;
        }
        
        /**
         * @private
         */
        public function set active( value:Boolean ):void
        {
            _active = value;
            
            if( _active )
            {
                _initializeVisual();
            }
            else
            {
                _destroyVisual();
            }
        }
        
        /**
         * To show more debug (used internally).
         */
        public function get verbose():Boolean
        {
            return _verbose;
        }
        
        /**
         * @private
         */
        public function set verbose( value:Boolean ):void
        {
            _verbose = value;
        }
        
//        /**
//         * Writes a message.
//         */
//        public function write( message:String ):void
//        {
//            if( layout )
//            {
//                layout.visualDebug.write( message );
//            }
//            
//            if( traceOutput )
//            {
//                trace( message );
//            }
//        }
        
        private function _filter( mode:VisualDebugMode = null ):Boolean
        {
            return mode && (int(mode) >= int(this.mode));
        }
        
        /**
         * Notify an "info" message.
         */
        public function info( message:String, mode:VisualDebugMode = null ):void
        {
            if( _filter( mode ) )
            {
                return;
            }
            
            if( layout && showInfos )
            {
                layout.createInfo( message );
            }
            
            if( traceOutput )
            {
                trace( message );
            }
        }
        
        /**
         * Notify a "warning" message.
         */
        public function warning( message:String, mode:VisualDebugMode = null ):void
        {
            if( _filter( mode ) )
            {
                return;
            }
            
            if( layout && showWarnings )
            {
                layout.createWarning( message );
            }
            
            if( traceOutput )
            {
                trace( "## " + message + " ##" );
            }
        }
        
        /**
         * Notify an "alert" message.
         */        
        public function alert( message:String ):void
        {
            if( layout )
            {
                layout.createAlert( message );
            }
            
            if( traceOutput )
            {
                trace( "!! " + message + " !!" );
            }
        }
        
        /**
         * Notify an "failure" message.
         */         
        public function failure( message:String ):void
        {
            if( layout )
            {
                layout.createFailureAlert( message );
            }
            
            if( traceOutput )
            {
                trace( "[-] " + message + " !!" );
            }
        }
        
        /**
         * Notify a "success" message.
         */         
        public function success( message:String ):void
        {
            if( layout )
            {
                layout.createSuccessAlert( message );
            }
            
            if( traceOutput )
            {
                trace( "[+] " + message + " !!" );
            }
        }
        
        /**
         * Notify an "alertGifRequest" message.
         */        
        public function alertGifRequest( message:String, request:URLRequest, ref:GIFRequest ):void
        {
            if( layout )
            {
                layout.createGIFRequestAlert( message, request, ref );
            }
            
            if( traceOutput )
            {
                trace( ">> " + message + " <<" );
            }
        }
    }
}