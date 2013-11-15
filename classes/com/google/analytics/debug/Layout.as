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
    import com.google.analytics.GATracker;
    import com.google.analytics.core.GIFRequest;
    
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.net.URLRequest;    

    /**
     * The Layout class is a helper who manages
     * as a factory all visual display in the application.
     */
    public class Layout implements ILayout
    {
        private var _display:DisplayObject;
        private var _debug:DebugConfiguration;
        private var _mainPanel:Panel;
        
        private var _hasWarning:Boolean;
        private var _hasInfo:Boolean;
        private var _hasDebug:Boolean;
        private var _hasGRAlert:Boolean;
        private var _infoQueue:Array;
        private var _maxCharPerLine:int = 85;
        private var _warningQueue:Array;
        private var _GRAlertQueue:Array;
        
        /**
         * The Debug reference of this Layout.
         */
        public var visualDebug:Debug;
        
        /**
         * Creates a new Layout instance.
         */
        public function Layout( debug:DebugConfiguration, display:DisplayObject )
        {
            super();
            _display      = display;
            _debug        = debug;
            _hasWarning   = false;
            _hasInfo      = false;
            _hasDebug     = false;
            _hasGRAlert   = false;
            _warningQueue = [];
            _infoQueue    = [];
            _GRAlertQueue = [];
        }
        
        public function init():void
        {
            var spaces:int = 10;
            var W:uint = _display.stage.stageWidth - (spaces*2);
            var H:uint = _display.stage.stageHeight - (spaces*2);
            //var W:uint = 400;
            //var H:uint = 300;
            var mp:Panel = new Panel( "analytics", W, H );
                mp.alignement = Align.top;
                mp.stickToEdge = false;
                mp.title = "Google Analytics v" + GATracker.version;
            
            _mainPanel = mp;
            addToStage( mp );
            bringToFront( mp );
            
            if( _debug.minimizedOnStart )
            {
                _mainPanel.onToggle();
            }
            
            createVisualDebug();
            
            _display.stage.addEventListener( KeyboardEvent.KEY_DOWN, onKey, false, 0, true );
        }
        
        public function destroy():void
        {
            _mainPanel.close();
            _debug.layout = null;
        }
        
        private function onKey( event:KeyboardEvent = null ):void
        {
            switch( event.keyCode )
            {
                case _debug.showHideKey:
                _mainPanel.visible = !_mainPanel.visible;
                break;
                
                case _debug.destroyKey:
                destroy();
                break;
            }
        }
        
        private function _clearInfo( event:Event ):void
        {
            _hasInfo = false;
            
            if( _infoQueue.length > 0 )
            {
                createInfo( _infoQueue.shift() );
            }
        }
        
        private function _clearWarning( event:Event ):void
        {
            _hasWarning = false;
            if( _warningQueue.length > 0 )
            {
                createWarning( _warningQueue.shift() );
            }
        }
        
        private function _clearGRAlert( event:Event ):void
        {
            _hasGRAlert = false;
            if( _GRAlertQueue.length > 0 )
            {
                createGIFRequestAlert.apply( this, _GRAlertQueue.shift() );
            }
        }
        
        private function _filterMaxChars( message:String, maxCharPerLine:int = 0 ):String
        {
            var CRLF:String = "\n";
            var output:Array = [];
            var lines:Array = message.split(CRLF);
            var line:String;
            
            if( maxCharPerLine == 0 )
            {
                maxCharPerLine = _maxCharPerLine;
            }
            
            for( var i:int = 0; i<lines.length; i++ )
            {
                line = lines[i];
                while( line.length > maxCharPerLine )
                {
                    output.push( line.substr(0,maxCharPerLine) );
                    line = line.substring(maxCharPerLine);
                }
                output.push( line );
            }
            
            return output.join(CRLF);
        }
        
        /**
         * Adds to stage the specified visual display.
         */
        public function addToStage( visual:DisplayObject ):void
        {
            _display.stage.addChild( visual );
        }
        
        public function addToPanel( name:String, visual:DisplayObject ):void
        {
            var d:DisplayObject = _display.stage.getChildByName( name );
            
            if( d )
            {
                var panel:Panel = d as Panel;
                panel.addData( visual );
            }
            else
            {
                trace( "panel \""+name+"\" not found" );
            }
        }
        
        /**
         * Brings to front the specified visual display.
         */
        public function bringToFront( visual:DisplayObject ):void
        {
            _display.stage.setChildIndex( visual, _display.stage.numChildren - 1 );
        }
        
        public function isAvailable():Boolean
        {
            return _display.stage != null;
        }
        
        /**
         * Creates a debug message in the debug display.
         */
        public function createVisualDebug():void
        {
            if( !visualDebug )
            {
                visualDebug = new Debug();
                visualDebug.alignement = Align.bottom;
                visualDebug.stickToEdge = true;
                addToPanel( "analytics", visualDebug );
                _hasDebug = true;
            }
        }
        
        public function createPanel( name:String, width:uint, height:uint ):void
        {
            var p:Panel = new Panel( name, width, height );
                p.alignement = Align.center;
                p.stickToEdge = false;
            
            addToStage( p );
            bringToFront( p );
        }
        
        /**
         * Creates an info message in the debug display.
         */        
        public function createInfo( message:String ):void
        {
            if( _hasInfo || !isAvailable() )
            {
                _infoQueue.push( message );
                return;
            }
            
            message = _filterMaxChars( message );
            _hasInfo = true;
            var i:Info = new Info( message, _debug.infoTimeout );
            addToPanel( "analytics", i );
            i.addEventListener( Event.REMOVED_FROM_STAGE, _clearInfo, false, 0, true );
            
            if( _hasDebug )
            {
                visualDebug.write( message );
            }
        }
        
        /**
         * Creates a warning message in the debug display.
         */
        public function createWarning( message:String ):void
        {
            if( _hasWarning || !isAvailable() )
            {
                _warningQueue.push( message );
                return;
            }
            
            message = _filterMaxChars( message );
            _hasWarning = true;
            var w:Warning = new Warning( message, _debug.warningTimeout );
            addToPanel( "analytics", w );
            w.addEventListener( Event.REMOVED_FROM_STAGE, _clearWarning, false, 0, true );
            
            if( _hasDebug )
            {
                visualDebug.writeBold( message );
            }
        }
        
        /**
         * Creates an alert message in the debug display.
         */
        public function createAlert( message:String ):void
        {
            message = _filterMaxChars( message );
            var a:Alert = new Alert( message, [ new AlertAction("Close","close","close") ] );
            addToPanel( "analytics", a );
            
            if( _hasDebug )
            {
                visualDebug.writeBold( message );
            }
        }
        
        /**
         * Creates a failure alert message in the debug display.
         */
        public function createFailureAlert( message:String ):void
        {
            var actionClose:AlertAction;
            
            if( _debug.verbose )
            {
                message = _filterMaxChars( message );
                actionClose = new AlertAction("Close","close","close");
            }
            else
            {
                actionClose = new AlertAction("X","close","close");
            }
            
            var fa:Alert = new FailureAlert( _debug, message, [ actionClose ] );
            addToPanel( "analytics", fa );
            
            if( _hasDebug )
            {
                if( _debug.verbose )
                {
                    message = message.split("\n").join("");
                    message = _filterMaxChars( message, 66 );
                }
                visualDebug.writeBold( message );
            }
        }
        
        /**
         * Creates a success alert message in the debug display.
         */
        public function createSuccessAlert( message:String ):void
        {
            var actionClose:AlertAction;
            
            if( _debug.verbose )
            {
                message = _filterMaxChars( message );
                actionClose = new AlertAction("Close","close","close");
            }
            else
            {
                actionClose = new AlertAction("X","close","close");
            }
            var sa:Alert = new SuccessAlert( _debug, message, [ actionClose ] );
            addToPanel( "analytics", sa );
            
            if( _hasDebug )
            {
                if( _debug.verbose )
                {
                    message = message.split("\n").join("");
                    message = _filterMaxChars( message, 66 );
                }
                visualDebug.writeBold( message );
            }
        }
        
        /**
         * Creates a GIFRequest alert message in the debug display.
         */
        public function createGIFRequestAlert( message:String, request:URLRequest, ref:GIFRequest ):void
        {
            if( _hasGRAlert )
            {
                _GRAlertQueue.push( [message,request,ref] );
                return;
            }
            
            _hasGRAlert = true;
            
            var f:Function = function():void
            {
                ref.sendRequest( request );
            };
            
            message = _filterMaxChars( message );
            var gra:GIFRequestAlert = new GIFRequestAlert( message, [ new AlertAction("OK","ok",f),
                                                                      new AlertAction("Cancel","cancel","close") ] );
            addToPanel( "analytics", gra );
            gra.addEventListener( Event.REMOVED_FROM_STAGE, _clearGRAlert, false, 0, true );
            
            if( _hasDebug )
            {
                if( _debug.verbose )
                {
                    message = message.split("\n").join("");
                    message = _filterMaxChars( message, 66 );
                }
                visualDebug.write( message );
            }
        }
        
    }
}

