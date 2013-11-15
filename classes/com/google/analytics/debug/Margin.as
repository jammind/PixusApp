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
     * The Margin class specifies the thickness, in pixels,
     * of the four edge regions around a visual object.
     */
    public class Margin
    {
        public var top:int;
        public var bottom:int;
        public var left:int;
        public var right:int;
        
        /**
         * Creates a new EdgeMetrics instance.
         * @param top The height, in pixels, of the top edge region.
         * @param bottom The height, in pixels, of the bottom edge region.
         * @param left The width, in pixels, of the left edge region.
         * @param right The width, in pixels, of the right edge region.
         */        
        public function Margin( top:int = 0, bottom:int = 0, left:int = 0, right:int = 0 )
        {
            this.top    = top;
            this.bottom = bottom;
            this.left   = left;
            this.right  = right;
        }
        
    }
}