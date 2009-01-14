package yuku.konsol
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mx.core.BitmapAsset;
	
	public class Font
	{
		internal var width: int;
		internal var height: int;
		
		private var bitmap: BitmapData;
		private var map: Object;
		
		private var coloredBitmapCache: Dictionary = new Dictionary(); // Dictionary<color: uint, BitmapData>
		
		[Embed(source='defaultFont.png')]
		private static var defaultBitmapClass: Class;
		
		[Embed(source='defaultFont.map', mimeType='application/octet-stream')] // codepage 437
		private static var defaultMapClass: Class;
		
		public function Font(bitmap: BitmapData, width: int, height: int, map: Object = null) 
		{
			this.width = width;
			this.height = height;
			this.bitmap = bitmap;
			this.map = map;
		}

		public static function getDefaultFont(): Font {
			var defaultBitmap: BitmapAsset = new defaultBitmapClass() as BitmapAsset;
			var defaultMapBytes: ByteArray = new defaultMapClass() as ByteArray;
			
			var defaultMap: Object = defaultMapBytes.readObject();
			
			return new Font(defaultBitmap.bitmapData, 8, 12, defaultMap);
		}
		
		internal function getColoredBitmap(color: uint): BitmapData {
			if (!coloredBitmapCache[color]) {
				var bitmap: BitmapData = this.bitmap.clone();
				bitmap.threshold(bitmap, bitmap.rect, new Point(), ">", 0x0, color, 0xff000000, false);
				coloredBitmapCache[color] = bitmap;
			}
			return coloredBitmapCache[color]; 
		}

		internal function isPrintable(char: int): Boolean {
			if (map) {
				if (char in map) {
					return true;
				}
			}
			
			if (char < 32) return false;
			if (char > 255) return false;
			return true;
		}
		
		internal function getRectForChar(char: int): Rectangle {
			if (map && (char in map)) {
				char = map[char];
			}
			
			var res: Rectangle = new Rectangle();
			res.x = (char % 32) * width;
			res.y = (int(char / 32) - 1) * height;
			res.width = this.width;
			res.height = this.height;
			
			return res;
		}
	}
}
