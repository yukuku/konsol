package yuku.konsol
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;

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
		private var palette_: Array = [
			0xff000000, 0xff0000aa, 0xff00aa00, 0xff00aaaa, 0xffaa0000, 0xffaa00aa, 0xffaa5500, 0xffaaaaaa,
			0xff555555, 0xff5555ff, 0xff55ff55, 0xff55ffff, 0xffff5555, 0xffff55ff, 0xffffff55, 0xffffffff,
		];
		
		//# for read* methods
		private var readInitCol_: int = 0;
		private var readBuffer_: String = '';
		
		//# for (save|restore)Position
		private var savedPosition_: Point = null;
		
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
			//# geser data, juga savedPosition_
			data_ = data_.slice(1).concat([newRow()]);
			if (savedPosition_) {
				savedPosition_.y--;
				if (savedPosition_.y < 0) savedPosition_.y = 0;
			}
			
			// kopi data layar ke atas, satu per satu untuk mencegah ngaco
			for (var row: int = 0; row < nrow_ - 1; row++) {
				screen_.copyPixels(screen_, new Rectangle(0, (row+1) * font_.height, screen_.width, font_.height), new Point(0, row * font_.height));
			}
			
			// dan hapus baris terbawah
			screen_.fillRect(new Rectangle(0, (nrow_-1) * font_.height, screen_.width, font_.height), bgColor_);
		}
		
		public function clearScreen(): void {
			data_ = newData();
			
			screen_.fillRect(screen_.rect, palette_[bgColor_]);
			crow_ = 0;
			ccol_ = 0;
		}
		
		public function get crow(): int {
			return crow_;
		}
		
		public function set crow(value: int): void {
			if (value < 0) value = 0;
			if (value >= nrow_) value = nrow_ - 1;
			crow_ = value;
		}
		
		public function get ccol(): int {
			return ccol_;
		}
		
		public function set ccol(value: int): void {
			if (value < 0) value = 0;
			if (value >= ncol_) value = ncol_ - 1;
			ccol_ = value;
		}
		
		public function savePosition(): void {
			savedPosition_ = new Point(ccol_, crow_);
		}
		
		public function restorePosition(): void {
			if (savedPosition_) {
				ccol_ = savedPosition_.x;
				crow_ = savedPosition_.y;
			}
		}
		
		private function drawCell(row: int, col: int): void {
			var cell: Cell = data_[row][col];
			
			// hapus
			screen_.fillRect(new Rectangle(col * font_.width, row * font_.height, font_.width, font_.height), cell.bgColor);
			
			if (font_.isPrintable(cell.char)) {
				screen_.copyPixels(font_.getColoredBitmap(palette_[cell.fgColor]), font_.getRectForChar(cell.char), new Point(col * font_.width, row * font_.height));
			}
		}
		
		private function printChar(char: int): void {
			var cell: Cell = data_[crow_][ccol_];
			cell.char = char;
			cell.bgColor = bgColor_;
			cell.fgColor = fgColor_;
			
			drawCell(crow_, ccol_);
			
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
		
		public function println(s: String = null): void {
			screen_.lock();
			
			if (s) {
				print(s);
			}
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
		
		public function read(): void {
			readBuffer_ = '';
			readInitCol_ = ccol_;
			
			// add stage focuser
			if (stage) {
				stage.focus = this;
				stage.addEventListener(FocusEvent.FOCUS_OUT, read_focusRestorer);
			}
			addEventListener(KeyboardEvent.KEY_DOWN, read_keyDown);
		}
		
		private function read_keyDown(event: KeyboardEvent): void {
			if (event.keyCode == Keyboard.ENTER) {
				//# finish
				printNewLine();
				var konsolEvent: KonsolEvent = new KonsolEvent(KonsolEvent.READ_COMPLETE);
				konsolEvent.line = readBuffer_;
				
				//# clean up
				removeEventListener(KeyboardEvent.KEY_DOWN, read_keyDown);
				stage.removeEventListener(FocusEvent.FOCUS_OUT, read_focusRestorer);
				
				// dispatch (must be last)
				dispatchEvent(konsolEvent);
			} else if (event.keyCode == Keyboard.BACKSPACE) {
				if (ccol_ > readInitCol_) {
					// put back cursor
					ccol_--;
					
					//# clear cur char
					data_[crow_][ccol_].char = 0x0;
					drawCell(crow_, ccol_);
					
					// remove one char from buffer
					readBuffer_ = readBuffer_.substr(0, readBuffer_.length - 1);
				}
			} else if (font_.isPrintable(event.charCode)) {
				if (ccol_ < ncol_ - 1) {
					var s: String = String.fromCharCode(event.charCode);
					readBuffer_ += s;
					print(s);
				}
			}
		}

		private function read_focusRestorer(event: FocusEvent): void {
			stage.focus = this;
		}
	}
}
