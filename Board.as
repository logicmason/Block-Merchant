package  {
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	
	public class Board {
		static const width:int = 13;
		static const height:int = 22;
		static const gridSize:int = 19;
		static const top:int = 112;
		static const bottom:int = top+height*gridSize;
		static var slots:Array = new Array();
		static var cleared:Array = new Array(); // how many singles, doubles, etc.. cleared
		static var linesCleared:int; //total lines cleared
		static var level:int;
		static var money:int;
		static var points:int;
		

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
			for (var i = 0;i<5;i++) cleared[i] = 0;
			money = 0;
			points = 0;
			linesCleared = 0;
			level = 1;
		}
		public static function checkRows() {
			var rowsCleared:int = 0;
			for (var row in slots) {
				if (checkRow(row) == true) {
					clearRow(row);
					rowsCleared += 1;
				}
			}
			if (rowsCleared > 0) {
				trace(rowsCleared+ " rows cleared");
				cleared[rowsCleared] += 1;
				rewardCleared(rowsCleared);
			}
			return rowsCleared;
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
				slots[0][i] = 0; //make a fresh top row
			}
		}
		
		function traceBoard() {
			for (var r in slots) {
				trace("Row "+r+": " + slots[r]);
			}
			trace(cleared[1] + " singles cleared");
			trace(cleared[2] + " doubles cleared");
			trace(cleared[3] + " triples cleared");
			trace(cleared[4] + " quads cleared");
			trace("points: " + points+"  money: "+money);
		}
		
		public static function rewardCleared(rowsCleared:int) {
			linesCleared += rowsCleared; //global counter for lines cleared
			points += rowsCleared * rowsCleared * 100;
			money += Math.pow(2, (rowsCleared-1)) - 1;
			if (linesCleared > level *5) endLevel();
		}
		
		public static function endLevel(){
			level += 1;
			Block.gravity += 1;
		}
	}
	
}
