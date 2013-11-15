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

package com.google.analytics.core
{
    import com.google.analytics.debug.DebugConfiguration;
    import com.google.analytics.debug.VisualDebugMode;
    import com.google.analytics.v4.Configuration;
    
    import flash.display.DisplayObject;
    import flash.display.Stage;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import flash.utils.getTimer;    

    /**
     * The Idle Timer class.
     */
    public class IdleTimer
    {
        private var _loop:Timer;
        private var _session:Timer;
        private var _debug:DebugConfiguration;
        private var _stage:Stage;
        private var _buffer:Buffer;
        
        private var _lastMove:int;
        private var _inactivity:Number;
        
        /**
        * Create an instance of the IdleTimer
        * 
        * note:
        * the timer will loop every <delay> seconds
        * on each loop
        * we compare the <last mouse move time> to the <current time>
        * and if the result is equal or bigger than the
        * <inativity> seconds we start a sessionTimer
        * -> if the mouse move again we reset the sessionTimer
        * -> if the mouse does not move till we reach the end of the sessionTimeout
        *    we reset the session
        * 
        * @param delay number of seconds to check for idle
        * @param inactivity number of seconds to check for inactivity
        * @param sessionTimeout number of seconds to end the session
        */
        public function IdleTimer( config:Configuration, debug:DebugConfiguration,
                                   display:DisplayObject, buffer:Buffer )
        {
            var delay:Number          = config.idleLoop;
            var inactivity:Number     = config.idleTimeout;
            var sessionTimeout:Number = config.sessionTimeout;
            
            _loop       = new Timer( delay * 1000 ); //milliseconds
            _session    = new Timer( sessionTimeout * 1000, 1 ); //milliseconds
            
            _debug      = debug;
            _stage      = display.stage;
            _buffer     = buffer;
            _lastMove   = getTimer();
            _inactivity = inactivity * 1000; //milliseconds
            
            _loop.addEventListener( TimerEvent.TIMER, checkForIdle );
            _session.addEventListener( TimerEvent.TIMER_COMPLETE, endSession );
            _stage.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
            
            _debug.info( "delay: " + delay + "sec , inactivity: " + inactivity + "sec, sessionTimeout: " + sessionTimeout, VisualDebugMode.geek );
            
            _loop.start();
        }
        
        private function onMouseMove( event:MouseEvent ):void
        {
            _lastMove = getTimer();
            
            if( _session.running )
            {
                _debug.info( "session timer reset", VisualDebugMode.geek );
                _session.reset();
            }
        }
        
        public function checkForIdle( event:TimerEvent ):void
        {
            var current:int = getTimer();
            
            if( (current - _lastMove) >= _inactivity )
            {
                if( !_session.running )
                {
                    _debug.info( "session timer start", VisualDebugMode.geek );
                    _session.start();
                }
            }
            
        }
        
        public function endSession( event:TimerEvent ):void
        {
            _session.removeEventListener( TimerEvent.TIMER_COMPLETE, endSession );
            _debug.info( "session timer end session", VisualDebugMode.geek );
            _session.reset();
            _buffer.resetCurrentSession();
            _debug.info( _buffer.utmb.toString(), VisualDebugMode.geek );
            _debug.info( _buffer.utmc.toString(), VisualDebugMode.geek );
            
            _session.addEventListener( TimerEvent.TIMER_COMPLETE, endSession );
        }
        
    }
}