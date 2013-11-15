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
	
	public class Item
	{
		
		private var _id:String;
		private var _sku:String;
		private var _name:String;
		private var _category:String;
		private var _price:String;
		private var _quantity:String;

		
		/**
 		* @class Item object for e-commerce module.  This encapsulates all the
 		*     necessary logic for manipulating an item.
 		*
 		* @param {String} transId Id of transaction this item belongs to.
 		* @param {String} sku SKU code for item.
 		* @param {String} name Product name.
 		* @param {String} category Product category.
 		* @param {String} price Product price.
 		* @param {String} quantity Purchase quantity.
 		*
 		* @constructor
 		*/
		public function Item(id:String, 
							 sku:String,
							 name:String,
							 category:String,
							 price:String,
							 quantity:String)
		{		
			this._id = id;
			this._sku = sku;
			this._name = name;
			this._category = category;
			this._price = price;
			this._quantity = quantity;
		}	
		
		/**
		 * Converts this items object to gif parameters.
		 *
		 * @private
		 * @param {String} sessionId Session Id for this e-commerce transaction.
		 *
		 * @returns {String} GIF request parameters for this item.
		 */		
		public function toGifParams():Variables
		{
			var vars:Variables = new Variables();
			vars.URIencode = true;
			vars.post = [ "utmt", "utmtid", "utmipc", "utmipn", "utmiva", "utmipr", "utmiqt" ];
			
			vars.utmt = "item";
			vars.utmtid = _id;
			vars.utmipc = _sku;
			vars.utmipn = _name;
			vars.utmiva = _category;
			vars.utmipr = _price;
			vars.utmiqt = _quantity;	 
			 
			return vars; 
			 
	/*		  return "&" + [
		      "utmt=item",
		      "utmtid=" + encodeURIComponent(_id),
		      "utmipc=" + encodeURIComponent(_sku),
		      "utmipn=" + encodeURIComponent(_name),
		      "utmiva=" + encodeURIComponent(_category),
      		  "utmipr=" + encodeURIComponent(_price),
      	      "utmiqt=" + encodeURIComponent(_quantity)
  			  ].join("&");
	*/
		}
		
		//getter methods
		public function get id():String
		{
			return _id;
		}
		public function get sku():String
		{
			return _sku;
		}		
		public function get name():String
		{
			return _name;
		}		
		public function get category():String
		{
			return _category;
		}		
		public function get price():String
		{
			return _price;
		}		
		public function get quantity():String
		{
			return _quantity;
		}
		
		//setter methods
		public function set id( value:String ):void
		{
			_id = value; 
		}
		public function set sku( value:String ):void
		{
			_sku = value; 
		}		
		public function set name( value:String ):void
		{
			_name = value; 
		}
		public function set category( value:String ):void
		{
			_category = value; 
		}
		public function set price( value:String ):void
		{
			_price = value; 
		}
		public function set quantity( value:String ):void
		{
			_quantity = value; 
		}				
	}
}				 