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

package com.google.analytics.components
{
    import com.google.analytics.API;
    import com.google.analytics.AnalyticsTracker;
    import com.google.analytics.core.Buffer;
    import com.google.analytics.core.Ecommerce;
    import com.google.analytics.core.EventTracker;
    import com.google.analytics.core.GIFRequest;
    import com.google.analytics.core.IdleTimer;
    import com.google.analytics.core.ServerOperationMode;
    import com.google.analytics.core.TrackerCache;
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
    import flash.utils.getDefinitionByName;
    
    /* force import for type in the includes */
    EventTracker;
    ServerOperationMode;
    
    /**
     * Dispatched after the factory has built the tracker object.
     * @eventType com.google.analytics.events.AnalyticsEvent.READY
     */
    [Event(name="ready", type="com.google.analytics.events.AnalyticsEvent")]
    
    /**
     * The Flex visual component.
     * This component is not a true component, you could call it a faceless component,
     * meaning it will not ba added in your display list.
     * Alternatively if you need a code-only component use the GATracker class.
     */
    [IconFile("analytics.png")]
    public class FlexTracker extends EventDispatcher implements AnalyticsTracker
    {
        private var _ready:Boolean = false;
        
        private var _app:Object;
        private var _display:DisplayObject;
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
        
        //component properties
        private var _account:String      = "";
        private var _mode:String         = "AS3";
        private var _visualDebug:Boolean = false;
        
        [IconFile("analytics.png")]
        public function FlexTracker()
        {
            super();
            
            _tracker = new TrackerCache();
            
            /* note:
               to avoid to create a hard reference to Application.application
               we get the class by reflection
            */
            var appclass:Object = getDefinitionByName( "mx.core::Application" );
            _app = appclass.application;
            
            _app.addEventListener( Event.ADDED_TO_STAGE, _factory );
        }
        
        public static var version:Version = API.version;
        
        /**
        * @private
        * Factory to build the different trackers
        */
        private function _factory( event:Event ):void
        {
            _app.removeEventListener( Event.ADDED_TO_STAGE, _factory );
            
            _display = _app.stage;
            
            if( !debug )
            {
                this.debug = new DebugConfiguration();
            }
            
            if( !config )
            {
                this.config = new Configuration( debug );
            }
            
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
                case "Bridge":
                activeTracker = _bridgeFactory();
                break;
                
                case "AS3":
                default:
                activeTracker = _trackerFactory();
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
         * Factory method for returning a Tracker object.
         * @return {GoogleAnalyticsAPI}
         * @private
         */
        private function _trackerFactory():GoogleAnalyticsAPI
        {
            debug.info( "GATracker (AS3) v" + version +"\naccount: " + account );
            
            _adSense   = new AdSenseGlobals( debug );
            
            _dom        = new HTMLDOM( debug );
            _dom.cacheProperties();
            
            _env        = new Environment( "", "", "", debug, _dom );
            
            _buffer     = new Buffer( config, debug, false );
            
            _gifRequest = new GIFRequest( config, debug, _buffer, _env );
            
            _idleTimer  = new IdleTimer( config, debug, _display, _buffer );
            _ecom       = new Ecommerce( _debug );
            
            use namespace ga_internal;
            _env.url = _display.stage.loaderInfo.url;
            
            return new Tracker( account, config, debug, _env, _buffer, _gifRequest, _adSense, _ecom );
        }
        
        /**
         * Factory method for returning a Bridge object.
         * @private
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
        [Inspectable]
        public function get account():String
        {
            return _account;
        }
        
        public function set account(value:String):void
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
        public function set config(value:Configuration):void
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
        public function set debug(value:DebugConfiguration):void
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
        [Inspectable(defaultValue="AS3", enumeration="AS3,Bridge", type="String")]
        public function get mode():String
        {
            return _mode;
        }
        
        /**
         * @private
         */
        public function set mode( value:String ):void
        {
            _mode = value;
        }
        
        /**
         * Indicates if the tracker use a visual debug.
         */        
        [Inspectable(defaultValue="false", type="Boolean")]
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
                
        include "../common.txt"
        
    }
}