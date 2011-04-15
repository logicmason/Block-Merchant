package  {
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	
	public class Board {  // just the playing board part of the game
		static const width:int = 13; // in grid sqaures
		static const height:int = 22;
		static const gridSize:int = 19;
		static const top:int = 112;
		static const bottom:int = top+height*gridSize;
		static var slots:Array = new Array();
		static var cleared:Array = new Array(); // how many singles, doubles, etc.. cleared
		static var linesCleared:int; //total lines cleared
		static var linesRemaining:int; //lines to be cleared before the next level
		static var level:int;
		static var money:int;
		static var points:int;
		static var stageLink;
		

		public function Board() {
			// constructor code
			initialize();			
			//addEventListener("enterFrame", enterFrame);
		}
		
		public function initialize(){
			clean(); //clears blocks from the board
			for (var i = 0;i<=5;i++) cleared[i] = 0;
			money = 5;
			points = 0;
			linesCleared = 0;
			level = 0;
			Block.gravity = 0;
			linesRemaining = levelCurve();
		}
		public static function checkRows() {
			var rowsCleared:int = 0;
			var bottomRowCleared:int;
			for (var row in slots) {
				if (checkRow(row) == true) {
					clearRow(row);
					rowsCleared += 1;
					if (row > bottomRowCleared) bottomRowCleared = row;
				}
			}
			if (rowsCleared > 0) {
				trace(rowsCleared+ " rows cleared");
				cleared[rowsCleared] += 1;
				rewardCleared(rowsCleared, bottomRowCleared);
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
			var destroyList:Array = new Array;
			for each(var b in Block.list) {
				destroyList.push(b);
				//b.destroy();
			}
			for each(b in Block.specialList) {
				destroyList.push(b);
				//b.destroy();
			}
			for each (b in destroyList) {
				b.destroy();
			}
			for (var y=0; y<height; y++) {
				slots[y] = new Array();
				for (var x=0; x<width; x++) {
					slots[y][x] = 0;
				}
			}
		}
		
		public static function clearRow(row:int) {
			var destroyList:Array = new Array;
			for (var b in Block.list) {
				if (Block.list[b].gy == row) {
					destroyList.push(Block.list[b]);
					//Block.list[b].destroy(); // clear row
				}
				else if (Block.list[b].gy < row) {
					Block.list[b].gy += 1; //move higher sprites down by one
				}
			}
			for each (b in destroyList) {
				b.destroy();
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
			trace(cleared[5] + " fivers cleared");
			trace("points: " + points+"  money: "+money);
		}
		
		public static function rewardCleared(rowsCleared:int, bottomRow:int) {
			new LineClearSound().play();
			linesCleared += rowsCleared; //global counter for lines cleared
			linesRemaining -= rowsCleared;
			points += rowsCleared * rowsCleared * 100;
			var moneyReward = Math.pow(2, (rowsCleared-1)) - 1;
			money += moneyReward;
			if (moneyReward > 0) {
				var mrd = new TempText();
				mrd.displayText.text = "";
				for (var i=0; i<moneyReward; i++) mrd.displayText.text += "$";
				mrd.x = width*gridSize/2;
				mrd.y = top+gridSize*bottomRow;
				stageLink.addChild(mrd);
			}
			if (linesCleared >= levelCurve()) BlockMerchant.endLevel();
		}
		
		public static function levelCurve(...rest) {
			var lvl:int;
			if(rest[0]) lvl = rest[0];
			else lvl = level;
			if (lvl < 3) return lvl*3;
			if (lvl == 3) return 10;
			else return 5*Math.floor(lvl/4) + levelCurve(lvl-1);
		}
	}
	
}
