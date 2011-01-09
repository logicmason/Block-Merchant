package  {
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class Board {
		static const width:int = 12;
		static const height:int = 22;
		static const gridSize:int = 19;
		static const top:int = 100;
		static const bottom:int = top+height*gridSize;
		static var slots:Array = new Array();
		

		public function Board() {
			// constructor code
			initialize();
			traceBoard();
			//addEventListener("enterFrame", enterFrame);
		}
		
		public function initialize(){
			for (var y=0; y<height; y++) {
				slots[y] = new Array();
				for (var x=0; x<width; x++) {
					slots[y][x] = 0;
				}
			}
		}
		public static function checkRows() {
			for (var row in slots) {
				if (checkRow(row) == true) clearRow(row);
			}
		}
		public static function checkRow(row:int):Boolean {
			for each (var point in slots[row]) {
				if (point == 0) return false;
			}
			return true;
		}
		
		public function clean() {
			for each(var b in Block.list) {
				b.destroy();
			}
			initialize();
		}
		
		public static function clearRow(row:int) {
			trace("Line "+ row + " is SO cleared... once this function gets written");
			for (var b in Block.list) {
				if (Block.list[b].gy == row) {
					Block.list[b].destroy(); // clear row
				}
				else if (Block.list[b].gy < row) {
					Block.list[b].gy += 1; //move higher sprites down by one
				}
			}
			
			//shift existing block data down by one
			for (var y=row;y>0;y--){
				for (var x in slots[row]){
					slots[y][x] = slots[y-1][x];
				}
			}
			for (var i in slots[row]){
				//slots[row][i] = 0; //clear completed line 
				slots[row][0] = 0; //make a fresh top row
			}
		}
		
		function traceBoard() {
			for (var r in slots) {
				trace("Row "+r+": " + slots[r]);
			}
		}
		

	}
	
}
