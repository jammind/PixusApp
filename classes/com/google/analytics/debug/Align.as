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
    
    /**
     * The enumeration of all Align values.
     */
    public class Align
    {
        private var _value:int;
        private var _name:String;
        
        /**
         * Creates a new Align instance.
         * @param value The value of the enumeration.
         * @param name The name key of the enumeration.
         */
        public function Align( value:int = 0, name:String = "" )
        {
            _value = value;
            _name  = name;
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
         * Returns the primitive value of the object.
         * @return the primitive value of the object.
         */
        public function valueOf():int
        {
            return _value;
        }
        
        /**
         * Defines the "none" value (<code class="prettyprint">0x000</code>).
         */
        public static const none:Align = new Align( 0x000, "none" );
        
        /**
         * Defines the "top" value (<code class="prettyprint">0x001</code>).
         */
        public static const top:Align = new Align( 0x001, "top" );
        
        /**
         * Defines the "bottom" value (<code class="prettyprint">0x002</code>).
         */
        public static const bottom:Align = new Align( 0x002, "bottom" );
        
        /**
         * Defines the "right" value (<code class="prettyprint">0x010</code>).
         */ 
        public static const right:Align = new Align( 0x010, "right" );
        
        /**
         * Defines the "left" value (<code class="prettyprint">0x020</code>).
         */
        public static const left:Align = new Align( 0x020, "left" );
        
        /**
         * Defines the "center" value (<code class="prettyprint">0x100</code>).
         */
        public static const center:Align = new Align( 0x100, "center" );
        
        /**
         * Defines the "topLeft" value (<code class="prettyprint">0x021</code>).
         */        
        public static const topLeft:Align = new Align( 0x021, "topLeft" );
        
        /**
         * Defines the "topRight" value (<code class="prettyprint">0x011</code>).
         */        
        public static const topRight:Align = new Align( 0x011, "topRight" );
        
        /**
         * Defines the "bottomLeft" value (<code class="prettyprint">0x022</code>).
         */        
        public static const bottomLeft:Align = new Align( 0x022, "bottomLeft" );
        
        /**
         * Defines the "bottomRight" value (<code class="prettyprint">0x012</code>).
         */
        public static const bottomRight:Align = new Align( 0x012, "bottomRight" );
        
    }
}

