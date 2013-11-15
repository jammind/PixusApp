// utils Package
// (cc)2009 codeplay
// By Jam Zhang
// jam@01media.cn

package codeplay.utils{

	import flash.utils.ByteArray;

		public function copyObjectDeep(src:Object):Object{
			var ba:ByteArray = new ByteArray();
			ba.writeObject(src);
			ba.position = 0;
			return ba.readObject();
		}

}