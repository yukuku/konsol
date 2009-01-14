package yuku.konsol
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Konsol extends Sprite
	{
		public static const BLACK: int = 0;
		public static const BLUE: int = 1;
		public static const GREEN: int = 2;
		public static const CYAN: int =  3;
		public static const RED: int = 4;
		public static const MAGENTA: int = 5;
		public static const BROWN: int = 6;
		public static const WHITE: int = 7;
		public static const GRAY: int = 8;
		public static const BRIGHT_BLUE: int = 9;
		public static const BRIGHT_GREEN: int = 10;
		public static const BRIGHT_CYAN: int = 11;
		public static const BRIGHT_RED: int = 12;
		public static const BRIGHT_MAGENTA: int = 13;
		public static const YELLOW: int = 14;
		public static const BRIGHT_WHITE: int = 15;
				
		private var data_: Array; // Array<Array<Cell>>;
		private var font_: Font;
		private var screen_: BitmapData;
		private var nrow_: int;
		private var ncol_: int;
		private var crow_: int;
		private var ccol_: int;
		private var bitmap_: Bitmap;
		private var bgColor_: int = 0x0;
		private var fgColor_: int = 0x7;
		
		public function Konsol(nrow: int = 25, ncol: int = 80, font: Font = null) {
			this.nrow_ = nrow;
			this.ncol_ = ncol;
			
			data_ = newData();
			
			if (font == null) {
				this.font_ = Font.getDefaultFont();
			} else {
				this.font_ = font;
			}
			
			screen_ = new BitmapData(ncol * this.font_.width, nrow * this.font_.height, false, 0x0);
			bitmap_ = new Bitmap(screen_);
			
			addChild(bitmap_);
			
			crow_ = 0;
			ccol_ = 0;
		}
		
		private function newRow(): Array {
			var res: Array = new Array(ncol_);
			
			for (var i: int = 0; i < ncol_; i++) {
				res[i] = new Cell(bgColor_, fgColor_);
			}
			
			return res;
		}
		
		private function newData(): Array {
			var res: Array = new Array(nrow_);
			for (var i: int = 0; i < nrow_; i++) {
				res[i] = new Array(ncol_);
				for (var j: int = 0; j < ncol_; j++) {
					res[i][j] = new Cell(bgColor_, fgColor_);
				}
			}
			
			return res;
		}
		
		private function shiftUp(): void {
			data_ = data_.slice(1).concat([newRow()]);
			
			// kopi data layar ke atas
			screen_.copyPixels(screen_, new Rectangle(0, 1 * font_.height, screen_.width, nrow_ * font_.height), new Point(0, 0));
			
			// dan hapus baris terbawah
			screen_.fillRect(new Rectangle(0, (nrow_-1) * font_.height, screen_.width, font_.height), bgColor_);
		}
		
		public function clearScreen(): void {
			data_ = newData();
			
			screen_.fillRect(screen_.rect, font_.getPaletteValue(bgColor_));
		}
		
		public function position(row: int = -1, col: int = -1): void {
			if (row != -1) {
				crow_ = row;
			}
			
			if (col != -1) {
				ccol_ = col;
			}
			
			if (crow_ < 0) crow_ = 0;
			if (crow_ >= nrow_) crow_ = nrow_ - 1;
			if (ccol_ < 0) ccol_ = 0;
			if (ccol_ >= ncol_) ccol_ = ncol_ - 1;
		}
		
		private function updateScreen(row: int, col: int): void {
			var cell: Cell = data_[row][col];
			
			// hapus
			screen_.fillRect(new Rectangle(col * font_.width, row * font_.height, font_.width, font_.height), bgColor_);
			
			if (font_.isPrintable(cell.char)) {
				// kopi dari font, TODO fgColor
				screen_.copyPixels(font_.getColoredBitmap(fgColor_), font_.getRectForChar(cell.char), new Point(col * font_.width, row * font_.height));
			}
		}
		
		private function printChar(char: int): void {
			var cell: Cell = data_[crow_][ccol_];
			cell.char = char;
			cell.bgColor = bgColor_;
			cell.fgColor = fgColor_;
			
			updateScreen(crow_, ccol_);
			
			ccol_++;
			
			// wrap?
			if (ccol_ >= ncol_) {
				crow_++;
				if (crow_ >= nrow_) {
					shiftUp();
					crow_ = nrow_ - 1;
				}
				ccol_ = 0;
			}
		}
		
		private function printNewLine(): void {
			ccol_ = 0;
			crow_++;
			
			// shift?
			if (crow_ >= nrow_) {
				shiftUp();
				crow_ = nrow_ - 1;
			}
		}
		
		public function print(s: String): void {
			screen_.lock();
			
			for (var i: int = 0; i < s.length; i++) {
				var char: int = s.charCodeAt(i);
				if (char == 0x0a) {
					printNewLine();
				} else {
					printChar(char);
				}
			}
			
			screen_.unlock();
		}
		
		public function println(s: String): void {
			screen_.lock();
			
			print(s);
			printNewLine();
			
			screen_.unlock();
		}
		
		public function set bgColor(value: int): void {
			if (value >= 0 && value < 16) {
				bgColor_ = value;
			}
		}
		
		public function get bgColor(): int {
			return bgColor_;
		}
		
		public function set fgColor(value: int): void {
			if (value >= 0 && value < 16) {
				fgColor_ = value;
			}
		}
		
		public function get fgColor(): int {
			return fgColor_;
		}
	}
}
