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
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.events.TextEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFieldType;    

    /**
     * The label sprite.
     */
    public class Label extends UISprite
    {
        private var _background:Shape;
        private var _textField:TextField;
        private var _text:String;
        
        private var _tag:String;
        private var _color:uint;
        
        /**
         * Indicates if the text is selectabled in the Label display.
         */
        protected var selectable:Boolean;
        
        /**
        * Indicates if the border of the label
        * stick to the edge.
        * 
        * note:
        * in case of rounded corner, the corner(s)
        * sticked to an edge would not be rounded
        */
        public var stickToEdge:Boolean;
        
        public static var count:uint = 0;
        
        /**
         * Creates a new Label instance.
         * @param text The text of the label.
         * @param tag The of the class used to render the text (default "uiLabel"). See <code>Style</code>.
         * @param color The color of the label.
         * @param stickToEdge The flag to defines the stickToEdge value.
         */
        public function Label( text:String = "", tag:String = "uiLabel",
                               color:uint = 0, alignement:Align = null, stickToEdge:Boolean = false )
        {
            super();
            
            this.name = "Label"+ count++;
            
            selectable = false;
            
            _background  = new Shape();
            _textField   = new TextField();
            _text        = text;
            _tag         = tag;
            
            if( alignement == null )
            {
                alignement = Align.none;
            }
            
            this.alignement   = alignement;
            this.stickToEdge  = stickToEdge;
            
            if( color == 0 )
            {
                color = Style.backgroundColor;
            }
            
            _color = color;
            
            _textField.addEventListener( TextEvent.LINK, onLink );
        }
        
        /**
         * Initialize the layout of all elements in the Label object.
         */
        protected override function layout():void
        {
            _textField.type       = TextFieldType.DYNAMIC;
            _textField.autoSize   = TextFieldAutoSize.LEFT;
            _textField.background = false;
            _textField.selectable = selectable;
            _textField.multiline  = true;
            
            _textField.styleSheet = Style.sheet;
            this.text = _text;
            
            addChild( _background );
            addChild( _textField );
        }
        
        /**
         * Dispose the current Label instance.
         */
        protected override function dispose():void
        {
            _textField.removeEventListener( TextEvent.LINK, onLink );
            super.dispose();
        }
        
        /**
         * @private
         */
        private function _draw():void
        {
            var g:Graphics = _background.graphics;
            g.clear();
            g.beginFill( _color );
            
            var W:uint = _textField.width;
            var H:uint = _textField.height;
            
            if( forcedWidth > 0 )
            {
                W = forcedWidth;
            }
            
            Background.drawRounded( this, g, W, H );
            
            g.endFill();
        }
        

        
        /**
        * the CSS tag used for the label.
        */
        public function get tag():String
        {
            return _tag;
        }
        
        /**
        * @private
        */
        public function set tag( value:String ):void
        {
            _tag = value;
            text = "";
        }
        
        /**
         * The text of the label.
         */
        public function get text():String
        {
            return _textField.text;
        }
        
        /**
         * @private
         */
        public function set text( value:String ):void
        {
            if( value == "" )
            {
                value = _text;
            }
            
            _textField.htmlText = "<span class=\""+tag+"\">"+value+"</span>";
            _text = value;
            _draw();
            resize();
        }
        
        /**
         * Appends more text to the label,
         * with the option to change the CSS tag.
         */
        public function appendText( value:String, newtag:String = "" ):void
        {
            if( value == "" )
            {
                return;
            }
            
            if( newtag == "" )
            {
                newtag = tag;
            }
            
            _textField.htmlText += "<span class=\""+newtag+"\">"+value+"</span>";
            _text += value;
            _draw();
            resize();
        }
        
        /**
         * Invoked when a AS link in the text is clicked. 
         */
        public function onLink( event:TextEvent ):void
        {
            //trace( "onLink()" );
        }        
        
    }
}
