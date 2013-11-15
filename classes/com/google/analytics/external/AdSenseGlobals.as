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

package com.google.analytics.external
{
    import com.google.analytics.debug.DebugConfiguration;    

    /**
    * Globals used by AdSense for revenue per page tracking.
    */
    public class AdSenseGlobals extends JavascriptProxy
    {
        
        /**
         * @private
         */
        private var _gaGlobalVerified:Boolean = false;
        
        /**
         * The gaGlobal_js Javascript injection.
         */
        public static var gaGlobal_js:XML =
        <script>
            <![CDATA[
                function()
                {
                    try
                    {
                        gaGlobal
                    }
                    catch(e)
                    {
                        gaGlobal = {} ;
                    }
                }
            ]]>
        </script>;
        
        /**
         * Creates a new AdSenseGlobals instance.
         * @param debug The DebugConfiguration reference of this instance.
         */
        public function AdSenseGlobals( debug:DebugConfiguration )
        {
            super( debug );
        }
        
        /**
         * @private
         */
        private function _verify():void
        {
            if( !_gaGlobalVerified )
            {
                executeBlock( gaGlobal_js );
                _gaGlobalVerified = true ;
            }
        }
        
        /**
         * Returns the "gaGlobal" object.
         * @return the "gaGlobal" object.
         */
        public function get gaGlobal():Object
        {
            if( !isAvailable() )
            {
                return null;
            }
            _verify();
            return getProperty( "gaGlobal" );
        }
        
        /**
         * Domain hash.
         */
        public function get dh():String
        {
            if( !isAvailable() )
            {
                return null;
            }
            
            _verify();
            return getProperty( "gaGlobal.dh" );
        }
        
        /**
         * Determinates the Hit id.
         */
        public function get hid():String
        {
            if( !isAvailable() )
            {
                return null;
            }
            
            _verify();
            return getProperty( "gaGlobal.hid" );
        }
        
        /**
         * @private
         */
        public function set hid( value:String ):void
        {
            if( !isAvailable() )
            {
                return;
            }
            
            _verify();
            setProperty( "gaGlobal.hid", value );
        }
        
        /**
         * Determinates the session id.
         */
        public function get sid():String
        {
            if( !isAvailable() )
            {
                return null;
            }
            
            _verify();
            return getProperty( "gaGlobal.sid" );
        }
        
        /**
         * @private
         */
        public function set sid( value:String ):void
        {
            if( !isAvailable() )
            {
                return;
            }
            
            _verify();
            setProperty( "gaGlobal.sid", value );
        }
        
        /**
         * Determinates the visitor id.
         * <p><b>Note:</b> vid format is <b>&lt;sessionid&gt;.&lt;firsttime&gt;</b></p>
         */
        public function get vid():String
        {
            if( !isAvailable() )
            {
                return null;
            }
            
            _verify();
            return getProperty( "gaGlobal.vid" );
        }
        
        /**
         * @private
         */
        public function set vid( value:String ):void
        {
            if( !isAvailable() )
            {
                return;
            }
            
            _verify();
            setProperty( "gaGlobal.vid", value );
        }
        
    }
}