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
 */
 
package com.google.analytics.debug
{
    import com.google.analytics.core.GIFRequest;
    
    import flash.display.DisplayObject;
    import flash.net.URLRequest;
    
    public interface ILayout
    {
        function init():void;
        function destroy():void;
        function addToStage( visual:DisplayObject ):void;
        function addToPanel( name:String, visual:DisplayObject ):void;
        function bringToFront( visual:DisplayObject ):void;
        function isAvailable():Boolean;
        function createVisualDebug():void;
        function createPanel( name:String, width:uint, height:uint ):void;
        function createInfo( message:String ):void;
        function createWarning( message:String ):void;
        function createAlert( message:String ):void;
        function createFailureAlert( message:String ):void;
        function createSuccessAlert( message:String ):void;
        function createGIFRequestAlert( message:String, request:URLRequest, ref:GIFRequest ):void;
        
    }
}