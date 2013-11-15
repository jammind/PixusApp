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

package com.google.analytics.utils
{

    /**
     * Basic URL utility class.
     */
    public class URL
    {
    	
        private var _url:String;
        
        /**
         * Creates a new URL instance.
         * @param url The String expression to defines the URL instance.
         */
        public function URL( url:String = "" )
        {
            _url = url.toLowerCase();
        }
        
        /**
         * Indicates the protocol value of the url.
         */          
        public function get protocol():Protocols
        {
            var proto:String = _url.split( "://" )[0];
            
            switch( proto )
            {
                case "file":
                return Protocols.file;
                
                case "http":
                return Protocols.HTTP;
                
                case "https":
                return Protocols.HTTPS;
                
                default:
                return Protocols.none;
            }
        }
        
        /**
         * Indicates the host name value of the url.
         */        
        public function get hostName():String
        {
            var hostname:String = _url;
            
            if( hostname.indexOf( "://" ) > -1 )
            {
                hostname = hostname.split( "://" )[1];
            }
            
            if( hostname.indexOf( "/" ) > -1 )
            {
                hostname = hostname.split( "/" )[0];
            }
            
            if( hostname.indexOf( "?" ) > -1 )
            {
                hostname = hostname.split( "?" )[0];
            }
            
            if( (protocol == Protocols.file) ||
                (protocol == Protocols.none) )
                {
                    return "";
                }
            
            return hostname;
        }
        
        /**
         * Indicates the domain value of the url.
         */         
        public function get domain():String
        {
            if( (hostName != "") && (hostName.indexOf(".") > -1) )
            {
                var parts:Array = hostName.split( "." );
                
                switch( parts.length )
                {
                    //domain.com
                    case 2 :
                    {
                        return hostName ;
                    }
                    
                    //domain.co.uk
                    //www.domain.com
                    case 3 :
                    {
                        if( parts[1] == "co" )
                        {
                            return hostName ;
                        }
                        parts.shift();
                        return parts.join( "." ) ;
                    }
                    
                    //www.domain.co.uk
                    case 4:
                    {
                        parts.shift();
                        return parts.join( "." ) ;
                    }
                }
                
            }
            
            return "" ;
        }
        
        /**
         * Indicates the subdomain value of the url.
         */
        public function get subDomain():String
        {
            if( (domain != "") && (domain != hostName) )
            {
                return hostName.split( "."+domain ).join( "" );
            }
            
            return "";
        }
        
        /**
         * Indicates the path value of the url.
         */
        public function get path():String
        {
            var _path:String = _url;
            
            if( _path.indexOf( "://" ) > -1 )
            {
                _path = _path.split( "://" )[1];
            }
            
            if( _path.indexOf( hostName ) == 0 )
            {
                _path = _path.substr( hostName.length );
            }
            
            if( _path.indexOf( "?" ) > -1 )
            {
                _path = _path.split( "?" )[0];
            }
            
            /* note:
               we want our path to always start with /
               (even if the path is empty)
            */
            if( _path.charAt(0) != "/" )
            {
                _path = "/"+_path;
            }
            
            return _path;
        }
        
        /**
         * Indicates the search of the url.
         */
        public function get search():String
        {
            var _search:String = _url;
            
            if( _search.indexOf( "://" ) > -1 )
            {
                _search = _search.split( "://" )[1];
            }
            
            if( _search.indexOf( hostName ) == 0 )
            {
                _search = _search.substr( hostName.length );
            }
            
            if( _search.indexOf( "?" ) > -1 )
            {
                _search = _search.split( "?" )[1];
            }
            else
            {
                _search = "";
            }
            
            return _search;
        }
        
        
    }
}