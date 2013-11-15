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
    import com.google.analytics.utils.Environment;
    import com.google.analytics.utils.Protocols;
    import com.google.analytics.utils.Variables;
    import com.google.analytics.v4.Configuration;
    
    import flash.display.Loader;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;    

    /**
     * Google Analytics Tracker Code (GATC)'s GIF request module.
     * This file encapsulates all the necessary components that are required to
     * generate a GIF request to the Google Analytics Back End (GABE).
     */
    public class GIFRequest
    {
        private var _config:Configuration;
        private var _debug:DebugConfiguration;
        private var _buffer:Buffer;
        private var _info:Environment;
        
        private var _utmac:String;
        private var _lastRequest:URLRequest;
        
        private var _count:int;
        private var _alertcount:int;
        
        /**
        * @private
        * contains the list of the different requests
        * in a simple object form
        * { start:Date, request:URLRequest, end:Date }
        * the index of the array as the id (or order) of the request
        */
        private var _requests:Array;
        
        /**
         * Creates a new GIFRequest instance.
         */
        public function GIFRequest( config:Configuration, debug:DebugConfiguration, buffer:Buffer, info:Environment )
        {
            _config = config;
            _debug  = debug;
            _buffer = buffer;
            _info   = info;
            
            _count      = 0;
            _alertcount = 0;
            _requests   = [];
        }
        
        /**
         * Account String. Appears on all requests.
         * <p><b>Example :</b> utmac=UA-2202604-2</p>
         */
        public function get utmac():String
        {
            return _utmac;
        }
        
        /**
         * Tracking code version
         * <p><b>Example :</b> utmwv=1</p>
         */
        public function get utmwv():String
        {
            return _config.version;
        }
        
        /**
         * Unique ID generated for each GIF request to prevent caching of the GIF image.
         * <p><b>Example :</b> utmn=1142651215</p>
         */
        public function get utmn():String
        {
            return Utils.generate32bitRandom() as String;
        }
        
        /**
         * Host Name, which is a URL-encoded string.
         * <p><b>Example :</b> utmhn=x343.gmodules.com</p>
         */
        public function get utmhn():String
        {
            return _info.domainName;
        }
        
        /**
         * Sample rate
         */
        public function get utmsp():String
        {
            return (_config.sampleRate * 100) as String;
        }
        
        /**
         * Cookie values. This request parameter sends all the cookies requested from the page.
         * 
         * ex:
         * utmcc=__utma%3D117243.1695285.22%3B%2B__utmz%3D117945243.1202416366.21.10.utmcsr%3Db%7Cutmccn%3D(referral)%7Cutmcmd%3Dreferral%7Cutmcct%3D%252Fissue%3B%2B
         * 
         * note:
         * you first get each cookie
         * __utma=117243.1695285.22;
         * __utmz=117945243.1202416366.21.10.utmcsr=b|utmccn=(referral)|utmcmd=referral|utmcct=%2Fissue;
         * the rhs can already be URLencoded , see for ex %2Fissue is for /issue
         * you join all the cookie and separate them with +
         * __utma=117243.1695285.22;+__utmz=117945243.1202416366.21.10.utmcsr=b|etc
         * the you URLencode all
         * __utma%3D117243.1695285.22%3B%2B__utmz%3D117945243.1202416366.21.10.utmcsr%3Db%7Cetc
         */
        public function get utmcc():String
        {
            var cookies:Array = [];
            
            if( _buffer.hasUTMA() )
            {
                cookies.push( _buffer.utma.toURLString() + ";" );
            }
            
            if( _buffer.hasUTMZ() )
            {
                cookies.push( _buffer.utmz.toURLString() + ";" );
            }
            
            if( _buffer.hasUTMV() )
            {
                cookies.push( _buffer.utmv.toURLString() + ";" );
            }
            
            //delimit cookies by "+"
            return cookies.join( "+" );
        }
        
        /**
         * Updates the token in the bucket.
         * This method first calculates the token delta since
         * the last time the bucket count is updated.
         * 
         * If there are no change (zero delta), then it does nothing.
         * However, if there is a delta, then the delta is added to the bucket,
         * and a new timestamp is updated for the bucket as well.
         * 
         * To prevent spiking in traffic after a large number of token
         * has accumulated in the bucket (after a long period of time),
         * we have added a maximum capacity to the bucket.
         * In other words, we will not allow the bucket to accumulate
         * token passed a certain threshold.
         */
        public function updateToken():void
        {
            var timestamp:Number = new Date().getTime();
            var tokenDelta:Number;
            
            // calculate the token count increase since last update
            tokenDelta = (timestamp - _buffer.utmb.lastTime) * (_config.tokenRate / 1000);
            
            if( _debug.verbose )
            {
                _debug.info( "tokenDelta: " + tokenDelta, VisualDebugMode.geek );
            }
            
            // only update token when there is a change
            if( tokenDelta >= 1 )
            {
                //Only fill bucket to capacity
                _buffer.utmb.token    = Math.min( Math.floor( _buffer.utmb.token + tokenDelta ) , _config.bucketCapacity );
                _buffer.utmb.lastTime = timestamp;
                
                if( _debug.verbose )
                {
                    _debug.info( _buffer.utmb.toString(), VisualDebugMode.geek );
                }
                
            }
        }
        
        private function _debugSend( request:URLRequest ):void
        {
            var data:String = "";
            
            switch( _debug.mode )
            {
                case VisualDebugMode.geek:
                data = "Gif Request #" + _alertcount + ":\n" + request.url;
                break;
                
                case VisualDebugMode.advanced:
                var url:String = request.url;
                if( url.indexOf( "?" ) > -1 )
                    {
                        url = url.split( "?" )[0];
                    }
                    url = _shortenURL( url );
                
                
                data = "Send Gif Request #" + _alertcount + ":\n" + url + " ?";
                break;
                
                case VisualDebugMode.basic:
                default:
                data = "Send " + _config.serverMode.toString() + " Gif Request #" + _alertcount + " ?";
                
            }
            
            _debug.alertGifRequest( data, request, this );
            _alertcount++;
        }
        
        private function _shortenURL( url:String ):String
        {
            if( url.length > 60 )
            {
                var paths:Array = url.split( "/" );
                while( url.length > 60 )
                {
                    paths.shift();
                    url = "../" + paths.join("/");
                }
            }
            
            return url;
        }
        
        public function onSecurityError( event:SecurityErrorEvent ):void
        {
            if( _debug.GIFRequests )
            {
                _debug.failure( event.text );
            }
        }
        
        public function onIOError( event:IOErrorEvent ):void
        {
            var url:String = _lastRequest.url;
            var id:String = String(_requests.length-1);
//            
//            trace( _requests[ id ].toString() );
//            trace( "\n"+url + "\n" + _requests[ id ].request.url );
            
            var msg:String = "Gif Request #" + id + " failed";
            
            if( _debug.GIFRequests )
            {
                if( !_debug.verbose )
                {
                    if( url.indexOf( "?" ) > -1 )
                    {
                        url = url.split( "?" )[0];
                    }
                    url = _shortenURL( url );
                }
                
                if( int(_debug.mode) > int(VisualDebugMode.basic) )
                {
                    msg += " \"" + url + "\" does not exists or is unreachable";
                }
                
                _debug.failure( msg );
            }
            else
            {
                _debug.warning( msg );
            }
            
            _removeListeners( event.target );
        }
        
        public function onComplete( event:Event ):void
        {
            var id:String = event.target.loader.name;
            _requests[ id ].complete();
            
            var msg:String = "Gif Request #" + id + " sent";
            
            var url:String = _requests[ id ].request.url;
            
            if( _debug.GIFRequests )
            {
                if( !_debug.verbose )
                {
                    if( url.indexOf( "?" ) > -1 )
                    {
                        url = url.split( "?" )[0];
                    }
                    url = _shortenURL( url );
                }
                
                if( int(_debug.mode) > int(VisualDebugMode.basic) )
                {
                    msg += " to \"" + url + "\"";
                }
                
                _debug.success( msg );
            }
            else
            {
                _debug.info( msg );
            }
            
            _removeListeners( event.target );
        }
        
        private function _removeListeners( target:Object ):void
        {
            target.removeEventListener( IOErrorEvent.IO_ERROR, onIOError );
            target.removeEventListener( Event.COMPLETE, onComplete );
        }
        
        public function sendRequest( request:URLRequest ):void
        {
            
            /* note:
               when the gif request is send too fast
               we are probably confusing our listeners order
               
               we should put each request in an ndexed array
               and pass the index value in the loader.name or something
               so when we get the event.target we can fnd back the current index
               
               by commenting the _removeListeners call
               I can see gif requests in Google Chrome
               Firefox still does not shows those request
            */
            var loader:Loader = new Loader();
                loader.name   = String(_count++);
                
            var context:LoaderContext = new LoaderContext( false );
            
            loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onIOError );
            loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onComplete );
            
            _lastRequest = request;
            _requests[ loader.name ] = new RequestObject( request );
            
            try
            {
                loader.load( request, context );
            }
            catch( e:Error )
            {
                _debug.failure( "\"Loader.load()\" could not instanciate Gif Request" );
            }
        }
        
        /**
        * Send the Gif Request to the server(s).
        */
        public function send( account:String, variables:Variables = null,
                              force:Boolean = false, rateLimit:Boolean = false ):void
        {
             _utmac = account;
             
             if( !variables )
             {
                 variables = new Variables();
             }
             
             variables.URIencode = false;
             variables.pre  = [ "utmwv", "utmn", "utmhn", "utmt", "utme",
                                "utmcs", "utmsr", "utmsc", "utmul", "utmje",
                                "utmfl", "utmdt", "utmhid", "utmr", "utmp" ];
             variables.post = [ "utmcc" ];
             
             if( _debug.verbose )
             {
                 _debug.info( "tracking: " + _buffer.utmb.trackCount+"/"+_config.trackingLimitPerSession, VisualDebugMode.geek );
             }
             
             /* Only send request if
                1. We havn't reached the limit yet.
                2. User forced gif hit
             */
            if( (_buffer.utmb.trackCount < _config.trackingLimitPerSession) || force )
            {
                //update token bucket
                if( rateLimit )
                {
                    updateToken();
                }
                
                //if there are token left over in the bucket, send request
                if( force || !rateLimit || (_buffer.utmb.token >= 1) )
                {
                    //Only consume a token for non-forced and rate limited tracking calls.
                    if( !force && rateLimit )
                    {
                        _buffer.utmb.token -= 1;
                    }
                    
                    //increment request count
                    _buffer.utmb.trackCount += 1;
                    
                    if( _debug.verbose )
                    {
                        _debug.info( _buffer.utmb.toString(), VisualDebugMode.geek );
                    }
                    
                    
                    variables.utmwv = utmwv;
                    variables.utmn  = Utils.generate32bitRandom();
                    
                    if( _info.domainName != "" )
                    {
                        variables.utmhn = _info.domainName;
                    }
                    
                    if( _config.sampleRate < 1 )
                    {
                        variables.utmsp = _config.sampleRate * 100;
                    }
                    
                     /* If service mode is send to local (or both),
                        then we'll sent metrics via a local GIF request.
                     */
                     if( (_config.serverMode == ServerOperationMode.local) ||
                         (_config.serverMode == ServerOperationMode.both) )
                         {
                             var localPath:String = _info.locationSWFPath;
                             
                             if( localPath.lastIndexOf( "/" ) > 0 )
                             {
                                 localPath = localPath.substring(0,localPath.lastIndexOf( "/" ));
                             }
                             
                             var localImage:URLRequest = new URLRequest();
                             
                             if( _config.localGIFpath.indexOf( "http" ) == 0 )
                             {
                                 localImage.url  = _config.localGIFpath;
                             }
                             else
                             {
                                 localImage.url  = localPath + _config.localGIFpath;
                             }
                                 
                                 
                                 //localImage.data = variables;
                                 localImage.url +=  "?"+variables.toString();
                             
                             if( _debug.active && _debug.GIFRequests )
                             {
                                 _debugSend( localImage );
                             }
                             else
                             {
                                 sendRequest( localImage );
                             }
                         }
                     
                     /* If service mode is set to remote (or both),
                        then we'll sent metrics via a remote GIF request.
                     */
                     if( (_config.serverMode == ServerOperationMode.remote) ||
                         (_config.serverMode == ServerOperationMode.both) )
                         {
                             var remoteImage:URLRequest = new URLRequest();
                             
                             /* get remote address (depending on protocol),
                                then append rest of metrics / data
                             */
                             if( _info.protocol == Protocols.HTTPS )
                             {
                                 remoteImage.url = _config.secureRemoteGIFpath;
                             }
                             else if( _info.protocol == Protocols.HTTP )
                             {
                                 remoteImage.url = _config.remoteGIFpath;
                             }
                             else
                             {
                                 remoteImage.url = _config.remoteGIFpath;
                             }
                             
                             variables.utmac = utmac;
                             variables.utmcc = encodeURIComponent(utmcc);
                             
                             //remoteImage.data = variables;
                             remoteImage.url +=  "?"+variables.toString();
                             
                             if( _debug.active && _debug.GIFRequests )
                             {
                                 _debugSend( remoteImage );
                             }
                             else
                             {
                                 sendRequest( remoteImage );
                             }
                             
                         }
                    
                }
                
            }
        }
        
        
    }
}