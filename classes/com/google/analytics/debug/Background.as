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
    
    /**
     * The background class.
     */
    public class Background
    {
        
        /**
         * Draw the rounded background in the specified target.
         */
        public static function drawRounded( target:*, g:Graphics, width:uint = 0, height:uint = 0 ):void
        {
            //var g:Graphics = _background.graphics;
            var W:uint;
            var H:uint;
            var R:uint = Style.roundedCorner;
            
            if( width > 0 && height > 0 )
            {
                W = width;
                H = height;
            }
            else
            {
                W = target.width;
                H = target.height;
            }
            
            if( target.stickToEdge && target.alignement != Align.none )
            {
                switch( target.alignement )
                {
                    case Align.top:
                    {
                        g.drawRoundRectComplex(0,0,W,H,0,0,R,R) ;
                        break ;
                    }
                    
                    case Align.topLeft :
                    {
                        g.drawRoundRectComplex(0,0,W,H,0,0,0,R) ;
                        break ;
                    }
                    
                    case Align.topRight:
                    {
                        g.drawRoundRectComplex(0,0,W,H,0,0,R,0) ;
                        break ;
                    }
                    
                    case Align.bottom :
                    {
                        g.drawRoundRectComplex(0,0,W,H,R,R,0,0);
                        break;
                    }
                    
                    case Align.bottomLeft :
                    {
                        g.drawRoundRectComplex(0,0,W,H,0,R,0,0) ;
                        break ;
                    }
                    
                    case Align.bottomRight :
                    {
                        g.drawRoundRectComplex(0,0,W,H,R,0,0,0) ;
                        break ;
                    }
                    
                    case Align.left :
                    {
                        g.drawRoundRectComplex(0,0,W,H,0,R,0,R) ;
                        break ;
                    }
                    
                    case Align.right :
                    {
                        g.drawRoundRectComplex(0,0,W,H,R,0,R,0) ;
                        break ;
                    }
                    
                    case Align.center :
                    {
                        g.drawRoundRect(0,0,W,H,R,R) ;
                        break ;
                    }
                    
                }
            }
            else
            {
                g.drawRoundRect(0,0,W,H,R,R);
            }
            
        }
        
    }
}

