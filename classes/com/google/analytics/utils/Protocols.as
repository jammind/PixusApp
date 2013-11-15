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
     * Protocols Enumeration
     */
    public class Protocols
    {
        /**
         * @private
         */
        private var _value:int;
        
        /**
         * @private
         */        
        private var _name:String;
        
        /**
         * Creates a new Protocols instance.
         * @param value The primitive value of the object.
         * @param name The name value of the object.
         */
        public function Protocols( value:int = 0, name:String = "" )
        {
            _value = value;
            _name  = name;
        }
        
        /**
         * Returns the primitive value of the object.
         * @return the primitive value of the object.
         */
        public function valueOf():int
        {
            return _value;
        }
        
        /**
         * Returns the String representation of the object.
         * @return the String representation of the object.
         */
        public function toString():String
        {
            return _name;
        }
        
        /**
         * The "none" Protocols object.
         */
        public static const none:Protocols  = new Protocols( 0, "none" );
        
        /**
         * The "file" Protocols object.
         */
        public static const file:Protocols  = new Protocols( 1, "file" );
        
        /**
         * The "HTTP" Protocols object.
         */
        public static const HTTP:Protocols  = new Protocols( 2, "HTTP" );
        
        /**
         * The "HTTPS" Protocols object.
         */
        public static const HTTPS:Protocols = new Protocols( 3, "HTTPS" );

    }
}