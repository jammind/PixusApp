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
 
package com.google.analytics.core
{
    /**
     * Core utilities.
     */
    public class Utils
    {
  
        /**
         * Generates a 32bit random number.
         * @return 32bit random number.
         */
        public static function generate32bitRandom():int
        {
            return Math.round( Math.random() * 0x7fffffff ) ;
        }
        
        /**
         * Generate hash for input string. This is a global method, since it does not need 
         * to access any instance variables, and it is being used everywhere in the GATC module.
         * @param input Input string to generate hash value on.
         * @return Hash value of input string. If input string is undefined, or empty, return hash value of 1.
         */
        public static function generateHash(input:String):int
        {
            var hash:int      = 1; // hash buffer
            var leftMost7:int = 0; // left-most 7 bits
            var pos:int;           // character position in string
            var current:int;       // current character in string
            
            // if input is undef or empty, hash value is 1
            if(input != null && input != "")
            {
                hash = 0;
                
                // hash function
                for( pos = input.length - 1 ; pos >= 0 ; pos-- )
                {
                    current   = input.charCodeAt(pos);
                    hash      = ((hash << 6) & 0xfffffff) + current + (current << 14);
                    leftMost7 = hash & 0xfe00000;
                    //hash      = (leftMost7 != 0) ? (hash ^ (leftMost7 >> 21)) : hash;
                    if(leftMost7 != 0)
                    {
                        hash ^= leftMost7 >> 21;
                    }
                }
            }
            
            return hash ;
        }
        
        /**
         * This function takes a raw string, and removes all leading and trailing whitespaces (space, new line, CR, tab).
         * If the inner option is <code class="prettyprint">true</code>, trim also whitespaces within the string.
         */
        public static function trim( raw:String, everything:Boolean = false ):String
        {
            if( raw == "" )
            {
                return "";
            }
            
            var whitespaces:Array = [" ","\n","\r","\t"];
            var str:String = raw;
            
            if( everything )
            {
                var i:int;
                for( i=0; i<whitespaces.length && (str.indexOf( whitespaces[i] ) > -1); i++)
                {
                    str = str.split( whitespaces[i] ).join( "" );
                }
            }
            else
            {
                var iLeft:int;
                var iRight:int;
                
                for( iLeft = 0; (iLeft < str.length) && (whitespaces.indexOf( str.charAt( iLeft ) ) > -1) ; iLeft++ )
                    {
                    }
                str = str.substr( iLeft );
                
                for( iRight = str.length - 1; (iRight >= 0) && (whitespaces.indexOf( str.charAt( iRight ) ) > -1) ; iRight-- )
                    {
                    }
                str = str.substring( 0, iRight + 1 );
            }
            
            return str;
        }
        
        /**
         * Checks if the paramater is a GA account ID.
         */
        public static function validateAccount( account:String ):Boolean
        {
            var rel:RegExp = /^UA-[0-9]*-[0-9]*$/;
            return rel.test(account);
        }
        
    }
}