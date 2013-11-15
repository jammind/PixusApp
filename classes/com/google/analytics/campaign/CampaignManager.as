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

package com.google.analytics.campaign
{
    import com.google.analytics.core.Buffer;
    import com.google.analytics.core.OrganicReferrer;
    import com.google.analytics.debug.DebugConfiguration;
    import com.google.analytics.debug.VisualDebugMode;
    import com.google.analytics.utils.Protocols;
    import com.google.analytics.utils.URL;
    import com.google.analytics.utils.Variables;
    import com.google.analytics.v4.Configuration;
    
    /**
     * The CampaignManager class.
     */
    public class CampaignManager
    {
        private var _config:Configuration;
        private var _debug:DebugConfiguration;
        private var _buffer:Buffer;
        
        private var _domainHash:Number;
        private var _referrer:String;
        private var _timeStamp:Number;
        
        /**
         * Delimiter for campaign tracker.
         */
        public static const trackingDelimiter:String = "|";
        
        /**
         * Creates a new CampaignManager instance.
         */
        public function CampaignManager( config:Configuration, debug:DebugConfiguration, buffer:Buffer,
                                         domainHash:Number, referrer:String, timeStamp:Number )
        {
            _config     = config;
            _debug      = debug;
            _buffer     = buffer;
            
            _domainHash = domainHash;
            _referrer   = referrer;
            _timeStamp  = timeStamp;
        }
        
        /**
         * This method will return true if and only document referrer is invalid.
         * Document referrer is considered to be invalid when it's empty (undefined,
         * empty string, "-", or "0"), or it's not a valid URL (doesn't have protocol)
         *
         * @private
         * @param {String} docRef Document referrer to be evaluated for validity.
         *
         * @return {Boolean} True if and only if document referrer is invalid.
         */
        public static function isInvalidReferrer( referrer:String ):Boolean
        {
            if( (referrer == "") ||
                (referrer == "-") ||
                (referrer == "0") )
            {
                return true;
            }
            
            if( referrer.indexOf("://") > -1 )
            {
                var url:URL = new URL( referrer );
                
                if( (url.protocol == Protocols.file) ||
                    (url.protocol == Protocols.none) )
                    {
                    return true;
                    }
            }
            
            return false;
        }
        
        /**
         * Checks if the document referrer is from the google custom search engine.
         * @private
         * @return <code class="prettyprint">true</code> if the referrer is from google custom search engine.
         */
        public static function isFromGoogleCSE( referrer:String, config:Configuration ):Boolean
        {
            var url:URL = new URL( referrer );
            
            // verify that the referrer is google cse search query.
            if( url.hostName.indexOf( config.google ) > -1 )
            {
                if( url.search.indexOf( config.googleSearchParam+"=" ) > -1 )
                {
                    // check if this is google custom search engine.
                    if( url.path == "/"+config.googleCsePath )
                    {
                        return true;
                    }
                }
            }
            
            return false;
        }
        
        /**
         * Retrieves campaign information.  If linker functionality is allowed, and
         * the cookie parsed from search string is valid (hash matches), then load the
         * __utmz value form search string, and write the value to cookie, then return
         * "".  Otherwise, attempt to retrieve __utmz value from cookie.  Then
         * retrieve campaign information from search string.  If that fails, try
         * organic campaigns next.  If that fails, try referral campaigns next.  If
         * that fails, try direct campaigns next.  If it still fails, return nothing.
         * Finally, determine whether the campaign is duplicated.  If the campaign is
         * not duplicated, then write campaign information to cookie, and indicate
         * there is a new campaign for gif hit.  Else, just indicate this is a
         * repeated click for campaign.
         *
         * @private
         * @param {_gat.GA_Cookie_} inCookie GA_Cookie instance containing cookie
         *     values parsed in from URL (linker).  This value should never be
         *     undefined.
         * @param {Boolean} noSession Indicating whether a session has been
         *     initialized. If __utmb and/or __utmc cookies are not set, then session
         *     has either timed-out or havn't been initialized yet.
         *
         * @return {String} Gif hit key-value pair indicating wether this is a repeated
         *     click, or a brand new campaign for the visitor.
         */
        public function getCampaignInformation( search:String, noSessionInformation:Boolean ):CampaignInfo
        {
            var campInfo:CampaignInfo = new CampaignInfo();
            var campaignTracker:CampaignTracker;
            var duplicateCampaign:Boolean = false;
            var campNoOverride:Boolean = false;
            var responseCount:int = 0;
            
            /* Allow linker functionality, and cookie is parsed from URL, and the cookie
              hash matches.
            */
            if( _config.allowLinker && _buffer.isGenuine() )
            {
                if( !_buffer.hasUTMZ() )
                {
                    return campInfo;
                }
            }
            
            // retrieves tracker from search string
            campaignTracker = getTrackerFromSearchString( search );
            
            if( isValid( campaignTracker ) )
            {
                // check for no override flag in search string
                campNoOverride = hasNoOverride( search );
                
                // if no override is true, and there is a utmz value, then do nothing now
                if( campNoOverride && !_buffer.hasUTMZ() )
                {
                    return campInfo;
                }
            }
            
            // Get organic campaign if there is no campaign tracker from search string.
            if( !isValid( campaignTracker ) )
            {
                campaignTracker = getOrganicCampaign();
                
                //If there is utmz cookie value, and organic keyword is being ignored, do nothing.
                if( !_buffer.hasUTMZ() && isIgnoredKeyword( campaignTracker ) )
                {
                    return campInfo;
                }
            }
            
            /* Get referral campaign if there is no campaign tracker from search string
               and organic campaign, and either utmb or utmc is missing (no session).
            */
            if( !isValid( campaignTracker ) && noSessionInformation )
            {
                campaignTracker = getReferrerCampaign();
                
                //If there is utmz cookie value, and referral domain is being ignored, do nothing
                if( !_buffer.hasUTMZ() && isIgnoredReferral( campaignTracker ) )
                {
                    return campInfo;
                }
            }
            
            /* Get direct campaign if there is no campaign tracker from search string,
              organic campaign, or referral campaign.
            */
            if( !isValid( campaignTracker ) )
            {
                /* Only get direct campaign when there is no utmz cookie value, and there is
                   no session. (utmb or utmc is missing value)
                */
                if( !_buffer.hasUTMZ() && noSessionInformation )
                {
                    campaignTracker = getDirectCampaign();
                }
                
            }
            
            //Give up (do nothing) if still cannot get campaign tracker.
            if( !isValid( campaignTracker ) )
            {
                return campInfo;
            }
            
            //utmz cookie have value, check whether campaign is duplicated.
            if( _buffer.hasUTMZ() && !_buffer.utmz.isEmpty() )
            {
                var oldTracker:CampaignTracker = new CampaignTracker();
                    oldTracker.fromTrackerString( _buffer.utmz.campaignTracking );
                
                duplicateCampaign = ( oldTracker.toTrackerString() == campaignTracker.toTrackerString() );
                
                responseCount = _buffer.utmz.responseCount;
            }
            
            /* Record as new campaign if and only if campaign is not duplicated, or there
              is no session information.
            */
            if( !duplicateCampaign || noSessionInformation )
            {
                var sessionCount:int = _buffer.utma.sessionCount;
                responseCount++;
                
                // if there is no session number, increment
                if( sessionCount == 0 )
                {
                    sessionCount = 1;
                }
                
                // construct utmz cookie
                _buffer.utmz.domainHash       = _domainHash;
                _buffer.utmz.campaignCreation = _timeStamp;
                _buffer.utmz.campaignSessions = sessionCount;
                _buffer.utmz.responseCount    = responseCount;
                _buffer.utmz.campaignTracking = campaignTracker.toTrackerString();
                
                _debug.info( _buffer.utmz.toString(), VisualDebugMode.geek );
                
                // indicate new campaign
                campInfo = new CampaignInfo( false, true );
            }
            else
            {
                // indicate repeated campaign
                campInfo = new CampaignInfo( false, false );
            }
            
            return campInfo;
        }
        
        /**
         * This method returns the organic campaign information.
         * @private
         * @return {_gat.GA_Campaign_.Tracker_} Returns undefined if referrer is not
         * a matching organic campaign source. Otherwise, returns the campaign tracker object.
         */
        public function getOrganicCampaign():CampaignTracker
        {
            var camp:CampaignTracker;
            
            // if there is no referrer, or referrer is not a valid URL, or the referrer
            // is google custom search engine, return an empty tracker
            if( isInvalidReferrer( _referrer ) || isFromGoogleCSE( _referrer, _config ) )
            {
                return camp;
            }
            
            var ref:URL = new URL( _referrer );
            var name:String = "";
            
            if( ref.hostName != "" )
            {
                if( ref.hostName.indexOf( "." ) > -1 )
                {
                    var tmp:Array = ref.hostName.split( "." );
                    
                    switch( tmp.length)
                    {
                        case 2:
                        // case: http://domain.com
                        name = tmp[0];
                        break;
                        
                        case 3:
                        //case: http://www.domain.com
                        name = tmp[1];
                        break;
                    }
                }
            }
            
            // organic source match
            if( _config.organic.match( name ) )
            {
                var currentOrganicSource:OrganicReferrer = _config.organic.getReferrerByName( name );
                
                // extract keyword value from query string
                var keyword:String = _config.organic.getKeywordValue( currentOrganicSource, ref.search );
                
                camp = new CampaignTracker();
                camp.source = currentOrganicSource.engine;
                camp.name   = "(organic)";
                camp.medium = "organic";
                camp.term   = keyword;
            }
            
            return camp;
        }
        
        /**
         * This method returns the referral campaign information.
         *
         * @private
         * @return {_gat.GA_Campaign_.Tracker_} Returns nothing if there is no
         *     referrer. Otherwise, return referrer campaign tracker.
         */
        public function getReferrerCampaign():CampaignTracker
        {
            var camp:CampaignTracker;
            
            // if there is no referrer, or referrer is not a valid URL, or the referrer
            // is google custom search engine, return an empty tracker
            if( isInvalidReferrer( _referrer ) || isFromGoogleCSE( _referrer, _config ) )
            {
                return camp;
            }
            
            // get host name from referrer
            var ref:URL = new URL( _referrer );
            var hostname:String = ref.hostName;
            var content:String  = ref.path;
            
            if( hostname.indexOf( "www." ) == 0 )
            {
                hostname = hostname.substr( 4 );
            }
            
            camp = new CampaignTracker();
            camp.source  = hostname;
            camp.name    = "(referral)";
            camp.medium  = "referral";
            camp.content = content;
            
            return camp;
        }
        
        /**
         * Returns the direct campaign tracker string.
         * @private
         * @return {_gat.GA_Campaign_.Tracker_} Direct campaign tracker object.
         */
        public function getDirectCampaign():CampaignTracker
        {
            var camp:CampaignTracker = new CampaignTracker();
                camp.source = "(direct)";
                camp.name   = "(direct)";
                camp.medium = "(none)";
            
            return camp;
        }
        
        /**
         * Indicates if the manager has no override with the search value.
         */
        public function hasNoOverride( search:String ):Boolean
        {
            var key:CampaignKey = _config.campaignKey;
            
            if( search == "" )
            {
                return false;
            }
            
            var variables:Variables = new Variables( search );
            var value:String           = "";
            
            if( variables.hasOwnProperty( key.UCNO ) )
            {
                value = variables[ key.UCNO ];
                
                switch( value )
                {
                    case "1":
                    return true;
                    
                    case "":
                    case "0":
                    default:
                    return false;
                }
            }
            
            return false;
        }
        
        /**
         * This method returns true if and only if campaignTracker is a valid organic
         * campaign tracker (utmcmd=organic), and the keyword (utmctr) is contained in
         * the ignore watch list (ORGANIC_IGNORE).
         *
         * @private
         * @param {_gat.GA_Campaign_.Tracker_} campaignTracker Campaign tracker
         *     reference.
         *
         * @return {Boolean} Return true if and only if the campaign tracker is a valid
         *     organic campaign tracker, and the keyword is contained in the ignored
         *     watch list.
         */
        public function isIgnoredKeyword( tracker:CampaignTracker ):Boolean
        {
            // organic campaign, try to match ignored keywords
            if( tracker && (tracker.medium == "organic") )
            {
                return _config.organic.isIgnoredKeyword( tracker.term );
            }
            
            return false;
        }
        
        /**
         * This method returns true if and only if campaignTracker is a valid
         * referreal campaign tracker (utmcmd=referral), and the domain (utmcsr) is
         * contained in the ignore watch list (REFERRAL_IGNORE).
         *
         * @private
         * @param {String} campaignTracker String representation of the campaign
         *     tracker.
         *
         * @return {Boolean} Return true if and only if the campaign tracker is a
         *     valid referral campaign tracker, and the domain is contained in the
         *     ignored watch list.
         */
        public function isIgnoredReferral( tracker:CampaignTracker ):Boolean
        {
            // referral campaign, try to match ignored domains
            if( tracker && (tracker.medium == "referral") )
            {
                return _config.organic.isIgnoredReferral( tracker.source );
            }
            
            return false;
        }
        
        public function isValid( tracker:CampaignTracker ):Boolean
        {
            if( tracker && tracker.isValid() )
            {
                return true;
            }
            
            return false;
        }
        
        
        /**
        * Retrieves campaign tracker from search string.
        * 
        * @param {String} searchString Search string to retrieve campaign tracker from.
        * @return {String} Return campaign tracker retrieved from search string.
        */
        public function getTrackerFromSearchString( search:String ):CampaignTracker
        {
            var organicCampaign:CampaignTracker = getOrganicCampaign();
            var camp:CampaignTracker            = new CampaignTracker();
            var key:CampaignKey                 = _config.campaignKey;
            
            if( search == "" )
            {
                return camp;
            }
            
            var variables:Variables = new Variables( search );
            
            //id
            if( variables.hasOwnProperty( key.UCID ) )
            {
                camp.id = variables[ key.UCID ];
            }
            
            //source
            if( variables.hasOwnProperty( key.UCSR ) )
            {
                camp.source = variables[ key.UCSR ];
            }
            
            //click id
            if( variables.hasOwnProperty( key.UGCLID ) )
            {
                camp.clickId = variables[ key.UGCLID ];
            }
            
            //name
            if( variables.hasOwnProperty( key.UCCN ) )
            {
                camp.name = variables[ key.UCCN ];
            }
            else
            {
                camp.name = "(not set)";
            }
            
            //medium
            if( variables.hasOwnProperty( key.UCMD ) )
            {
                camp.medium = variables[ key.UCMD ];
            }
            else
            {
                camp.medium = "(not set)";
            }
            
            //term
            if( variables.hasOwnProperty( key.UCTR ) )
            {
                camp.term = variables[ key.UCTR ];
            }
            else if( organicCampaign && organicCampaign.term != "" )
            {
                camp.term = organicCampaign.term;
            }
            
            //content
            if( variables.hasOwnProperty( key.UCCT ) )
            {
                camp.content = variables[ key.UCCT ];
            }
            
            return camp;
        }
        
    }
}