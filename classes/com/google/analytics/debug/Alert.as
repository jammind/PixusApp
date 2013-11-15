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
    import flash.events.TextEvent;
    
    /**
     * The Alert class.
     * Display a message and wait for an OK/Cancel action.
     */
    public class Alert extends Label
    {
        private var _actions:Array;
        
        public var autoClose:Boolean = true;
        public var actionOnNextLine:Boolean = true;
        
        public function Alert( text:String, actions:Array,
                               tag:String = "uiAlert", color:uint = 0, alignement:Align = null, stickToEdge:Boolean = false,
                               actionOnNextLine:Boolean = true )
        {
            if( color == 0 )
            {
                color = Style.alertColor;
            }
            
            if( alignement == null )
            {
                alignement = Align.center;
            }
            
            super(text, tag, color, alignement, stickToEdge );
            
            this.selectable = true;
            super.mouseChildren = true;
            this.buttonMode   = true;
            this.mouseEnabled = true;
            this.useHandCursor = true;
            
            this.actionOnNextLine = actionOnNextLine;
            _actions = [];
            
            for( var i:int = 0; i<actions.length; i++ )
            {
                actions[i].container = this;
                _actions.push( actions[i] );
            }
            
        }
        
        private function _defineActions():void
        {
            var str:String = "";
                if( actionOnNextLine )
                {
                    str += "\n";
                }
                else
                {
                    str += " |";
                }
                str += " ";
            
            var actions:Array = [];
            var action:AlertAction;
            for( var i:int = 0; i<_actions.length; i++ )
            {
                action = _actions[i];
                actions.push( "<a href=\"event:"+action.activator+"\">"+action.name+"</a>" );
            }
            
            str += actions.join( " | " );
            
            appendText( str, "uiAlertAction" );
        }
        
        protected function isValidAction( action:String ):Boolean
        {
            for( var i:int = 0; i<_actions.length; i++ )
            {
                if( action == _actions[i].activator )
                {
                    return true;
                }
            }
            
            return false;
        }
        
        protected function getAction( name:String ):AlertAction
        {
            for( var i:int = 0; i<_actions.length; i++ )
            {
                if( name == _actions[i].activator )
                {
                    return _actions[i];
                }
            }
            
            return null;
        }
        
        protected function spaces( num:int ):String
        {
            var str:String = "";
            var spc:String = "          ";
            for( var i:int = 0; i<num+1; i++ )
            {
                str += spc;
            }
            
            return str;
        }
        
        
        protected override function layout():void
        {
            super.layout();
            _defineActions();
        }
        
        /**
         * Close the alert message.
         */
        public function close():void
        {
            if ( parent != null )
            {
                parent.removeChild( this );
            }
        }
        
        /**
         * Invoked when a link is selected in the text.
         */
        public override function onLink( event:TextEvent ):void
        {
            if( isValidAction( event.text ) )
            {
                var action:AlertAction = getAction( event.text );
                if( action )
                {
                    action.execute();
                }
            }
            
            if( autoClose )
            {
                close();
            }
        }
        
    }
}