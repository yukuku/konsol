package yuku.konsol
{
	internal class Cell
	{
		public var char: int = 0;
		public var fgColor: int;
		public var bgColor: int;
		
		public function Cell(bgColor: int = 0x7, fgColor: int = 0x0) {
			this.bgColor = bgColor;
			this.fgColor = fgColor;
		}
	}
}
