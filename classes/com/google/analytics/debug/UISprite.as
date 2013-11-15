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
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    
    /**
     * The core UISprite class.
     */
    public class UISprite extends Sprite
    {
        private var _forcedWidth:uint;
        private var _forcedHeight:uint;
        
        /**
         * Indicates the display object align target.
         */
        protected var alignTarget:DisplayObject;
        
        /**
         * Indicates if the resize process is listening. 
         */
        protected var listenResize:Boolean;
        
        /**
         * Indicates the alignement reference of this sprite.
         */
        public var alignement:Align;
        
        /**
         * Indicates the margin reference of this sprite.
         */
        public var margin:Margin;
        
        /**
         * Creates a new UISprite instance.
         */
        public function UISprite( alignTarget:DisplayObject = null )
        {
            super();
            
            listenResize = false;
            
            alignement   = Align.none;
            this.alignTarget  = alignTarget;
            margin       = new Margin();
            
            addEventListener( Event.ADDED_TO_STAGE, _onAddedToStage );
            addEventListener( Event.REMOVED_FROM_STAGE, _onRemovedFromStage );
        }
        
        private function _onAddedToStage( event:Event ):void
        {
            layout();
            resize();
        }
        
        private function _onRemovedFromStage( event:Event ):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, _onAddedToStage );
            removeEventListener( Event.REMOVED_FROM_STAGE, _onRemovedFromStage );
            dispose();
        }
        
        /**
         * Layout the display.
         */
        protected function layout():void
        {
            //to override
        }
        
        /**
        * Dispose (clean up) the display.
        */
        protected function dispose():void
        {
            var d:DisplayObject;
            for( var i:int = 0; i<numChildren; i++ )
            {
                d   = getChildAt(i);
                if( d )
                {
                    removeChild( d );
                }
            }
        }
        
        /**
         * Invoked when the stage is resized.
         */
        protected function onResize( event:Event ):void
        {
            resize();
        }
        
        public function get forcedWidth():uint
        {
            if( _forcedWidth )
            {
                return _forcedWidth;
            }
            
            return width;
        }
        
        public function set forcedWidth( value:uint ):void
        {
            _forcedWidth = value;
        }
        
        public function get forcedHeight():uint
        {
            if( _forcedHeight )
            {
                return _forcedHeight;
            }
            
            return height;
        }
        
        public function set forcedHeight( value:uint ):void
        {
            _forcedHeight = value;
        }
        
        /**
         * Align the specified display with the specified alignement value.
         */
        public function alignTo( alignement:Align, target:DisplayObject = null ):void
        {
            if( target == null )
            {
                if( parent is Stage )
                {
                    target = this.stage;
                }
                else
                {
                    target = parent;
                }
            }
            
            var H:uint;
            var W:uint;
            var X:uint;
            var Y:uint;
            
            if( target == this.stage )
            {
                if( this.stage == null )
                {
                    return;
                }
                
                H = this.stage.stageHeight;
                W = this.stage.stageWidth;
                X = 0;
                Y = 0;
            }
            else
            {
                var t:UISprite = target as UISprite;
                
                if( t.forcedHeight )
                {
                    H = t.forcedHeight;
                }
                else
                {
                    H = t.height;
                }
                
                if( t.forcedWidth )
                {
                    W = t.forcedWidth;
                }
                else
                {
                    W = t.width;
                }
                
                X = 0;
                Y = 0;
            }
            
            switch( alignement )
            {
                case Align.top:
                //x = (W/2)-(width/2);
                x = (W/2)-(forcedWidth/2);
                y = Y + margin.top;
                break;
                
                case Align.bottom:
                //x = (W/2)-(width/2);
                //y = (Y+H)-height - margin.bottom;
                x = (W/2)-(forcedWidth/2);
                y = (Y+H)-forcedHeight - margin.bottom;
                break;
                
                case Align.left:
                x = X + margin.left;
                //y = (H/2)-(height/2);
                y = (H/2)-(forcedHeight/2);
                break;
                
                case Align.right:
                //x = (X+W)-width - margin.right;
                //y = (H/2)-(height/2);
                x = (X+W)-forcedWidth - margin.right;
                y = (H/2)-(forcedHeight/2);
                break;
                
                case Align.center:
                //x = (W/2)-(width/2);
                //y = (H/2)-(height/2);
                x = (W/2)-(forcedWidth/2);
                y = (H/2)-(forcedHeight/2);
                break;
                
                case Align.topLeft:
                x = X + margin.left;
                y = Y + margin.top;
                break;
                
                case Align.topRight:
                //x = (X+W)-width - margin.right;
                x = (X+W)-forcedWidth - margin.right;
                y = Y + margin.top;
                break;
                
                case Align.bottomLeft:
                x = X + margin.left;
                //y = (Y+H)-height - margin.bottom;
                y = (Y+H)-forcedHeight - margin.bottom;
                break;
                
                case Align.bottomRight:
                //x = (X+W)-width - margin.right;
                //y = (Y+H)-height - margin.bottom;
                x = (X+W)-forcedWidth - margin.right;
                y = (Y+H)-forcedHeight - margin.bottom;
                break;
            }
            
            if( !listenResize && (alignement != Align.none) )
            {
                target.addEventListener( Event.RESIZE, onResize, false, 0, true );
                listenResize = true;
            }
            
            this.alignement  = alignement;
            this.alignTarget = target;
        }
        
        /**
         * Resize the display.
         */
        public function resize():void
        {
            if( alignement != Align.none )
            {
                alignTo( alignement, alignTarget );
            }
        }
        
    }
}