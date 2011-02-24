package  {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	
	public class BlockMerchant extends MovieClip{
		static var masterset:Array = ["T", "Y", "S", "Z", "5", "U", "L", "J", "l", "O", "r", "t", "H"];
		static var playset:Array = ["T", "Y", "S", "Z", "5", "U", "L", "J", "l", "O", "r", "t", "H"];
		static var current:Block;
		static var nextBlock:String; //the name of the type of the next block
		static var nextBlockImage:Block = null; // the display of the next block
		static var board:Board;
		static var shop:MovieClip;
	
		public function BlockMerchant() {
			board = new Board();
			shop = new Shop();
			shop.x = 0;
			shop.y = 530-shop.height;
			stage.addChild(shop);
			trace(stage);
			Key.initialize(stage);
			board.traceBoard();
			startGame();
			addEventListener("enterFrame", enterFrame);
		}
		static function gameOver() {
			trace("Game Over, no extra life!");
			board.traceBoard();
			trace(Block.list.length + "total blocks");
		}
		
		function randomizePlayset() {
			playset = [];
			var master = masterset.concat();
			for (var i = 0; i<6; i++) {
				var r = Math.floor(Math.random()*master.length);
				var piece = master[r];
				master.splice(r,1);
				playset.push(piece);
			}
		}
		function startGame() {
			shop.visible = false;
			randomizePlayset();
			current = new Block(playset[Math.floor(Math.random()*playset.length)]);
			current.addEventListener("enterFrame", current.move);
			stage.addChild(current);
			current.gx = 4;
			current.gy = 0;
			displayPlayset();
			nextBlock = playset[Math.floor(Math.random()*playset.length)];
			//displayNextBlock();
		}
		
		function displayNextBlock() {
			if (nextBlock) {
				//trace("nextBlock is... " + nextBlock);
				if (nextBlockImage) {
					nextBlockImage.destroy();
				}
				nextBlockImage = new Block(nextBlock);
				nextBlockImage.makeSpecial();
				addChild(nextBlockImage);
				nextBlockImage.height *= 1;
				nextBlockImage.width *= 1;
				nextBlockImage.x = 330;
				nextBlockImage.y = 40;
			}
		}
		function displayPlayset() {
			clearPlayset();
			for (var i in playset) {
				var b = new Block(playset[i]);
				b.makeSpecial();
				stage.addChild(b);
				b.height *= .7;
				b.width *= .7;
				b.x = 300+100*(i%2);
				b.y = Math.floor(i/2)*70+160;
			}
		}
		static function clearPlayset(){
			var destroyList:Array = new Array;
			for each(var b in Block.specialList) {
				destroyList.push(b);
				//b.parent.removeChild(b);
				//b.destroy();
			}
			for each (b in destroyList) {
				b.destroy();
			}
		}
		static function endLevel(){
			Board.level += 1;
			Block.gravity += 1;
			Board.linesRemaining = Board.levelCurve()-Board.linesCleared;
			current.removeEventListener("enterFrame", current.move);
			clearPlayset();
			shop.visible = true;
			shop.parent.setChildIndex(shop, shop.parent.numChildren-1);
		}
		function nextLevel()  {
			shop.visible = false;
			shop.salesDisplayed = false;
			shop.clearText();
			stage.removeChild(shop.dealBubble);
			displayPlayset();
			current.addEventListener("enterFrame", current.move);
		}
		function enterFrame(e:Event){
			if((Key.isDown(Keyboard.ENTER))) {
				board.clean();
				nextBlockImage = null;
				startGame();
				
			}
			if((Key.isDown(84))) { //t
				board.traceBoard();
			}
			if((shop.visible == true) && (Key.isDown(78))) { //
				nextLevel();
			}
			goldDisplay.text = Board.money.toString();
			scoreDisplay.text = Board.points.toString();
			levelDisplay.text = Board.level.toString();
			linesDisplay.text = Board.linesCleared.toString();
			linesRemainingDisplay.text = Board.linesRemaining.toString();
			displayNextBlock();
		}

	}
	
}
