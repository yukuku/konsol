package yuku.konsol
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.BitmapAsset;
	
	public class Font
	{
		internal var width: int;
		internal var height: int;
		
		private var bitmap: BitmapData;
		private var palette: Array = [
			0x000000, 0x0000aa, 0x00aa00, 0x00aaaa, 0xaa0000, 0xaa00aa, 0xaa5500, 0xaaaaaa,
			0x555555, 0x5555ff, 0x55ff55, 0x55ffff, 0xff5555, 0xff55ff, 0xffff55, 0xffffff,
		];
		
		private var coloredBitmaps: Array = new Array(palette.length);
		
		[Embed(source='defaultFont.png')]
		private static var defaultBitmapClass: Class;
		
		public function Font(bitmap: BitmapData, width: int, height: int) 
		{
			this.width = width;
			this.height = height;
			this.bitmap = bitmap;
		}

		public static function getDefaultFont(): Font {
			var defaultBitmap: BitmapAsset = new defaultBitmapClass() as BitmapAsset;
			
			return new Font(defaultBitmap.bitmapData, 8, 12);
		}
		
		internal function getColoredBitmap(fgColor: int): BitmapData {
			if (!coloredBitmaps[fgColor]) {
				var bitmap: BitmapData = this.bitmap.clone();
				bitmap.threshold(bitmap, bitmap.rect, new Point(), ">", 0x0, 0xff000000 | palette[fgColor], 0xff000000, false);
				coloredBitmaps[fgColor] = bitmap;
			}
			return coloredBitmaps[fgColor]; 
		}

		internal function isPrintable(char: int): Boolean {
			if (char < 32) return false;
			if (char > 255) return false;
			return true;
		}
		
		internal function getRectForChar(char: int): Rectangle {
			var res: Rectangle = new Rectangle();
			res.x = (char % 32) * width;
			res.y = (int(char / 32) - 1) * height;
			res.width = this.width;
			res.height = this.height;
			
			return res;
		}
		
		internal function getPaletteValue(index: int): uint {
			return palette[index];
		}
	}
}
