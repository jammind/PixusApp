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
    import flash.net.URLLoader;
    import flash.text.StyleSheet;
    
    /**
     * The _Style internal class.
     */
    public class _Style
    {
        private var _defaultSheet:String;
        private var _sheet:StyleSheet;
        private var _loader:URLLoader;
        
        private function _init():void
        {
            /* note:
               to avoid an external loading of a .css that could
               delay the UI initialization we pack directly the CSS
               into the code.
            */
            _defaultSheet  = "";
            _defaultSheet += "a{text-decoration: underline;}\n";
            _defaultSheet += ".uiLabel{color: #000000;font-family: Arial;font-size: 12;margin-left: 2;margin-right: 2;}\n";
            _defaultSheet += ".uiWarning{color: #ffffff;font-family: Arial;font-size: 14;font-weight: bold;margin-left: 6;margin-right: 6;}\n";
            _defaultSheet += ".uiAlert{color: #ffffff;font-family: Arial;font-size: 14;font-weight: bold;margin-left: 6;margin-right: 6;}\n";
            _defaultSheet += ".uiInfo{color: #000000;font-family: Arial;font-size: 14;font-weight: bold;margin-left: 6;margin-right: 6;}\n";
            _defaultSheet += ".uiSuccess{color: #ffffff;font-family: Arial;font-size: 12;font-weight: bold;margin-left: 6;margin-right: 6;}\n";
            _defaultSheet += ".uiFailure{color: #ffffff;font-family: Arial;font-size: 12;font-weight: bold;margin-left: 6;margin-right: 6;}\n";
            _defaultSheet += ".uiAlertAction{color: #ffffff;text-align: center;font-family: Arial;font-size: 12;font-weight: bold;margin-left: 6;margin-right: 6;}\n";
            _defaultSheet += ".uiAlertTitle{color: #ffffff;font-family: Arial;font-size: 16;font-weight: bold;margin-left: 6;margin-right: 6;}\n";
            _defaultSheet += "\n";
            
            roundedCorner   = 6;
            backgroundColor = 0xcccccc;
            borderColor     = 0x555555;
            
            infoColor       = 0xffff99;
            alertColor      = 0xffcc00;
            warningColor    = 0xcc0000;
            successColor    = 0x00ff00;
            failureColor    = 0xff0000;
            
            _parseSheet( _defaultSheet );
        }        
        
        /**
         * @private
         */
        private function _parseSheet( data:String ):void
        {
            _sheet.parseCSS( data );
        }        
        
        /**
         * The background color.
         */
        public var backgroundColor:uint;
        
        /**
         * The border color.
         */
        public var borderColor:uint;
        
        /**
         * The info color value.
         */
        public var infoColor:uint;
        
        /**
         * The rounded corner value.
         */
        public var roundedCorner:uint;
        
        /**
         * The warning color value.
         */
        public var warningColor:uint;
        
        /**
         * The alert color value.
         */
        public var alertColor:uint;
        
        /**
        * The success color value.
        */
        public var successColor:uint;
        
        /**
        * The failue color value.
        */
        public var failureColor:uint;
        
        /**
         * Creates a new _Style class.
         */
        public function _Style()
        {
            _sheet  = new StyleSheet();
            _loader = new URLLoader();
            _init();
        }
        
        /**
         * Returns the current style sheet.
         */
        public function get sheet():StyleSheet
        {
            return _sheet;
        }
        
    }
}