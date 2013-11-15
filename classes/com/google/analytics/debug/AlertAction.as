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
    * The AlertAction allow to define the different action
    * for a button contained in an Alert window.
    */
    public class AlertAction
    {
        private var _callback:*;
        
        /**
         * The activator value.
         */
        public var activator:String;
        
        /**
         * The container value.
         */
        public var container:Alert;
        
        /**
         * The name value.
         */
        public var name:String;
        
        /**
         * Creates a new AlertAction instance.
         */
        public function AlertAction( name:String, activator:String, callback:* )
        {
            this.name      = name;
            this.activator = activator;
            
            _callback = callback;
        }
        
        /**
         * Run the command.
         */
        public function execute():void
        {
            if( _callback )
            {
                if( _callback is Function )
                {
                    (_callback as Function)();
                }
                else if( _callback is String )
                {
                    container[_callback]();
                }
            }
        }
        
    }
}