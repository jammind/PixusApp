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

package com.google.analytics
{
    import com.google.analytics.core.Buffer;
    import com.google.analytics.core.Ecommerce;
    import com.google.analytics.core.EventTracker;
    import com.google.analytics.core.GIFRequest;
    import com.google.analytics.core.IdleTimer;
    import com.google.analytics.core.ServerOperationMode;
    import com.google.analytics.core.TrackerCache;
    import com.google.analytics.core.TrackerMode;
    import com.google.analytics.core.ga_internal;
    import com.google.analytics.debug.DebugConfiguration;
    import com.google.analytics.debug.Layout;
    import com.google.analytics.events.AnalyticsEvent;
    import com.google.analytics.external.AdSenseGlobals;
    import com.google.analytics.external.HTMLDOM;
    import com.google.analytics.external.JavascriptProxy;
    import com.google.analytics.utils.Environment;
    import com.google.analytics.utils.Version;
    import com.google.analytics.v4.Bridge;
    import com.google.analytics.v4.Configuration;
    import com.google.analytics.v4.GoogleAnalyticsAPI;
    import com.google.analytics.v4.Tracker;
    
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.EventDispatcher;    
    
    /* force import for type in the includes */
    EventTracker;
    ServerOperationMode;
    
    /**
     * Dispatched after the factory has built the tracker object.
     * @eventType com.google.analytics.events.AnalyticsEvent.READY
     */
    [Event(name="ready", type="com.google.analytics.events.AnalyticsEvent")]
    
    /**
     * Google Analytic Tracker Code (GATC)'s code-only component.
     */
    public class GATracker implements AnalyticsTracker
    {
        private var _ready:Boolean = false;
        
        private var _display:DisplayObject;
        private var _eventDispatcher:EventDispatcher;
        private var _tracker:GoogleAnalyticsAPI;
        
        //factory
        private var _config:Configuration;
        private var _debug:DebugConfiguration;
        private var _env:Environment;
        private var _buffer:Buffer;
        private var _gifRequest:GIFRequest;
        private var _jsproxy:JavascriptProxy;
        private var _dom:HTMLDOM;
        private var _adSense:AdSenseGlobals;
        private var _idleTimer:IdleTimer;
        private var _ecom:Ecommerce;
        
        //object properties
        private var _account:String;
        private var _mode:String;
        private var _visualDebug:Boolean;

        /**
         * Indicates if the tracker is automatically build.
         */
        public static var autobuild:Boolean = true;
        
        /**
         * The version of the tracker.
         */
        public static var version:Version = API.version;
        
        /**
         * Creates a new GATracker instance.
         * <p><b>Note:</b> the GATracker need to be instancied and added to the Stage or at least
         * being placed in a display list.</p>
         */
        public function GATracker( display:DisplayObject, account:String,
                                   mode:String = "AS3", visualDebug:Boolean = false,
                                   config:Configuration = null, debug:DebugConfiguration = null )
        {
            _display = display;
            _eventDispatcher = new EventDispatcher( this ) ;
            _tracker = new TrackerCache();
            
            this.account     = account;
            this.mode        = mode;
            this.visualDebug = visualDebug;
            
            if( !debug )
            {
                this.debug = new DebugConfiguration();
            }
            
            if( !config )
            {
                this.config = new Configuration( debug );
            }
            else
            {
            	this.config = config;
            }
            
            if( autobuild )
            {
                _factory();
            }
        }
        
        /**
         * @private
         * Factory to build the different trackers
         */
        private function _factory():void
        {
            _jsproxy = new JavascriptProxy( debug );
            
            if( visualDebug )
            {
                debug.layout = new Layout( debug, _display );
                debug.active = visualDebug;
            }
            
            var activeTracker:GoogleAnalyticsAPI;
            var cache:TrackerCache = _tracker as TrackerCache;
            
            switch( mode )
            {
                case TrackerMode.BRIDGE :
                {
                    activeTracker = _bridgeFactory();
                    break;
                }
                
                case TrackerMode.AS3 :
                default:
                {
                    activeTracker = _trackerFactory();
                }
            }
            
            if( !cache.isEmpty() )
            {
                cache.tracker = activeTracker;
                cache.flush();
            }
            
            _tracker = activeTracker;
            
            _ready = true;
            dispatchEvent( new AnalyticsEvent( AnalyticsEvent.READY, this ) );
        }
        
        /**
        * @private
        * Factory method for returning a Tracker object.
        * 
        * @return {GoogleAnalyticsAPI}
        */
        private function _trackerFactory():GoogleAnalyticsAPI
        {
            debug.info( "GATracker (AS3) v" + version +"\naccount: " + account );
            
            /* note:
               for unit testing and to avoid 2 different branches AIR/Flash
               here we will detect if we are in the Flash Player or AIR
               and pass the infos to the LocalInfo
               
               By default we will define "Flash" for our local tests
            */
            
            
            _adSense    = new AdSenseGlobals( debug );
            
            _dom        = new HTMLDOM( debug );
            _dom.cacheProperties();
            
            _env        = new Environment( "", "", "", debug, _dom );
            
            _buffer     = new Buffer( config, debug, false );
            _gifRequest = new GIFRequest( config, debug, _buffer, _env );
            _idleTimer  = new IdleTimer( config, debug, _display, _buffer );
            _ecom       = new Ecommerce ( _debug );
                        
            /* note:
               To be able to obtain the URL of the main SWF containing the GA API
               we need to be able to access the stage property of a DisplayObject,
               here we open the internal namespace to be able to set that reference
               at instanciation-time.
               
               We keep the implementation internal to be able to change it if required later.
            */
            use namespace ga_internal;
            _env.url = _display.stage.loaderInfo.url;
            
            return new Tracker( account, config, debug, _env, _buffer, _gifRequest, _adSense, _ecom );
        }
        
        /**
        * @private
        * Factory method for returning a Bridge object.
        * 
        * @return {GoogleAnalyticsAPI}
        */
        private function _bridgeFactory():GoogleAnalyticsAPI
        {
            debug.info( "GATracker (Bridge) v" + version +"\naccount: " + account );
            return new Bridge( account, _debug, _jsproxy );
        }
        
        
        /**
         * Indicates the account value of the tracking.
         */
        public function get account():String
        {
            return _account;
        }
        
        /**
         * @private
         */
        public function set account( value:String ):void
        {
            _account = value;
        }
        
        /**
         * Determinates the Configuration object of the tracker.
         */        
        public function get config():Configuration
        {
            return _config;
        }
        
        /**
         * @private
         */        
        public function set config( value:Configuration ):void
        {
            _config = value;
        }

        /**
         * Determinates the DebugConfiguration of the tracker. 
         */        
        public function get debug():DebugConfiguration
        {
            return _debug;
        }
        
        /**
         * @private
         */        
        public function set debug( value:DebugConfiguration ):void
        {
            _debug = value;
        }        

        /**
         * Indicates if the tracker is ready to use.
         */
        public function isReady():Boolean
        {
            return _ready;
        }
        
        /**
         * Indicates the mode of the tracking "AS3" or "Bridge".
         */        
        public function get mode():String
        {
            return _mode;
        }
        
        /**
         * @private
         */        
        public function set mode( value:String ):void
        {
            _mode = value ;
        }
        
        /**
         * Indicates if the tracker use a visual debug.
         */        
        public function get visualDebug():Boolean
        {
            return _visualDebug;
        }
        
        /**
         * @private
         */        
        public function set visualDebug( value:Boolean ):void
        {
            _visualDebug = value;
        }
        

        /**
         * Builds the tracker.
         */
        public function build():void
        {
            if( !isReady() )
            {
                _factory();
            }
        }
        
        // IEventDispatcher implementation
        
        /**
         * Allows the registration of event listeners on the event target.
         * @param type A string representing the event type to listen for. If eventName value is "ALL" addEventListener use addGlobalListener
         * @param listener The Function that receives a notification when an event of the specified type occurs.
         * @param useCapture Determinates if the event flow use capture or not.
         * @param priority Determines the priority level of the event listener.
         * @param useWeakReference Indicates if the listener is a weak reference.
         */        
        public function addEventListener( type:String, listener:Function, useCapture:Boolean = false, priority:int = 0,
                                          useWeakReference:Boolean = false):void
        {
            _eventDispatcher.addEventListener( type, listener, useCapture, priority, useWeakReference );
        } 
        
        /**
         * Dispatches an event into the event flow.
         * @param event The Event object that is dispatched into the event flow.
         * @return <code class="prettyprint">true</code> if the Event is dispatched.
         */        
        public function dispatchEvent( event:Event ):Boolean
        {
            return _eventDispatcher.dispatchEvent( event );
        }
        
        /**
         * Checks whether the EventDispatcher object has any listeners registered for a specific type of event.
         * This allows you to determine where altered handling of an event type has been introduced in the event flow heirarchy by an EventDispatcher object.
         */         
        public function hasEventListener( type:String ):Boolean
        {
            return _eventDispatcher.hasEventListener( type );
        }
        
        /** 
         * Removes a listener from the EventDispatcher object.
         * If there is no matching listener registered with the <code class="prettyprint">EventDispatcher</code> object, then calling this method has no effect.
         * @param type Specifies the type of event.
         * @param listener The Function that receives a notification when an event of the specified type occurs.
         * @param useCapture Determinates if the event flow use capture or not.
         */        
        public function removeEventListener( type:String, listener:Function, useCapture:Boolean = false ):void
        {
            _eventDispatcher.removeEventListener( type, listener, useCapture );
        }
        
        /**
         * Checks whether an event listener is registered with this EventDispatcher object or any of its ancestors for the specified event type.
         * This method returns <code class="prettyprint">true</code> if an event listener is triggered during any phase of the event flow when an event of the specified type is dispatched to this EventDispatcher object or any of its descendants.
         * @return A value of <code class="prettyprint">true</code> if a listener of the specified type will be triggered; <code class="prettyprint">false</code> otherwise.
         */        
        public function willTrigger( type:String ):Boolean
        {
            return _eventDispatcher.willTrigger( type );
        }        
        
        include "common.txt"
        
    }
}