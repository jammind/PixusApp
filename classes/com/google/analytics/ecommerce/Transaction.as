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
 */
 
package com.google.analytics.ecommerce
{
	import com.google.analytics.utils.Variables;
	
	public class Transaction
	{
		private var _items:Array;
		
		private var _id:String;
		private var _affiliation:String;
		private var _total:String;
		private var _tax:String;
		private var _shipping:String;
		private var _city:String;
		private var _state:String;
		private var _country:String;
		
		//holds all the data of this
		private var _vars:Variables;
		
	    /**
		 * @class Transaction object for e-commerce module.  This encapsulates all the
		 *     necessary logic for manipulating a transaction.
		 *
		 * @private
		 * @param {String} orderId Internal unique order id number for this transaction.
		 * @param {String} affiliation Optional partner or store affiliation (undefined if absent)
		 * @param {String} total Total dollar amount of the transaction.
		 * @param {String} tax Tax amount of the transaction.
		 * @param {String} shipping Shipping charge for the transaction.
		 * @param {String} city City to associate with transaction.
		 * @param {String} state State to associate with transaction.
		 * @param {String} country Country to associate with transaction.
		 *
		 * @constructor
		 */					
		public function Transaction(id:String,
									affiliation:String,
									total:String,
									tax:String,
									shipping:String,
									city:String,
									state:String,
									country:String)
		{
			this._id = id;
			this._affiliation = affiliation;
			this._total = total;
			this._tax = tax;
			this._shipping = shipping;
			this._city = city;
			this._state = state;
			this._country = country;
		
			_items = new Array();
			
		}		
		
		/**
	 	* Converts this transactions object to gif parameters.
	 	*
	 	* @private
	 	* @returns {String} GIF request parameters for this transaction.
	 	*/
		public function toGifParams():Variables
		{		
			var vars:Variables = new Variables();
			vars.URIencode = true;
			
			vars.utmt = "tran";  //always present for transactions
			vars.utmtid = id;
			vars.utmtst = affiliation;
			vars.utmtto = total;
			vars.utmttx = tax;
			vars.utmtsp = shipping;
			vars.utmtci = city;
			vars.utmtrg = state;
			vars.utmtco = country;
		
			vars.post = [ "utmtid", "utmtst", "utmtto", "utmttx", "utmtsp", "utmtci", "utmtrg", "utmtco"  ];
		
			return vars;
		};
		
		/**
		 * Adds a transaction item to the parent transaction object. Requires the
		 * trackTrans() method. Use this method to track items purchased by visitors to
		 * your ecommerce site. If the item being added is a duplicate (by SKU) of an
		 * existing item, then the old information is replaced with the new. If no
		 * parent transaction object has been created, an empty transaction object is
		 * created for the item to be added to.
		 *
		 * @private
		 * @param {String} sku Item's SKU code.
		 * @param {String} name Product name.
		 * @param {String} category Product category.
		 * @param {String} price Product price (required).
		 * @param {String} quantity Purchase quantity (required).
		 */		
		public function addItem(sku:String,
								name:String,
								category:String,
								price:String,
								quantity:String):void
		{
			
			var newItem:Item;
			
			newItem = getItem( sku );
			
			if ( newItem == null )
			{
				newItem = new Item( _id, sku, name, category, price, quantity );			
				_items.push( newItem );				
			}
			else
			{
				newItem.name = name;
				newItem.category = category;
				newItem.price = price;
				newItem.quantity = quantity;	
			}	
		}
			
	   /**
	    * Takes a sku, and returns the corresponding item object.  If the item is not found, return undefined.
	    *
	    * @private
	    * @param {String} sku SKU code for item.
	    *
	    * @return {_gat.GA_EComm_.Items_} Item object with the specified sku. 
	    */				
		public function getItem( sku:String ):Item
		{
			var i:Number;
			
			for( i=0; i<_items.length; i++ )
			{
				if ( _items[i].sku == sku )
				{
					return _items[i];
				}
			}
			
			return null;
		}
		
		/**
		 * Return the current number of items for this Transaction object
		 * 
		 */ 
		public function getItemsLength():Number
		{
			return _items.length;
		}
		
		public function getItemFromArray( i:Number ):Item
		{
			return _items[i];
		}


		// getter functions for entire object
		public function get id():String
		{
			return _id;
		}
		public function get affiliation():String
		{
			return _affiliation;
		}
		public function get total():String
		{
			return _total;
		}
		public function get tax():String
		{
			return _tax;
		}
		public function get shipping():String
		{
			return _shipping;
		}
		public function get city():String
		{
			return _city;
		}
		public function get state():String
		{
			return _state;
		}
		public function get country():String
		{
			return _country;
		}
		
		
		// setter functions for entire object	
			
		public function set id( value: String ):void
		{
			_id = value;
		}
		public function set affiliation( value: String ):void
		{
			_affiliation = value;
		}
		public function set total( value: String ):void
		{
			_total = value;
		}
		public function set tax( value: String ):void
		{
			_tax = value;
		}		
		public function set shipping( value: String ):void
		{
			_shipping = value;
		}
		public function set city( value: String ):void
		{
			_city = value;
		}
		public function set state( value: String ):void
		{
			_state = value;
		}
		public function set country( value: String ):void
		{
			_country = value;
		}

	}
}