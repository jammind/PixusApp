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
    public class VisualDebugMode
    {
        private var _name:String;
        private var _value:int;
        
        public function VisualDebugMode( value:int = 0, name:String = "" )
        {
            _value = value;
            _name  = name;
        }
        
        public function toString():String
        {
            return _name;
        }
        
        public function valueOf():int
        {
            return _value;
        }
        
        public static const basic:VisualDebugMode    = new VisualDebugMode( 0, "basic" );
        public static const advanced:VisualDebugMode = new VisualDebugMode( 1, "advanced" );
        public static const geek:VisualDebugMode     = new VisualDebugMode( 2, "geek" );
        
        
    }
}