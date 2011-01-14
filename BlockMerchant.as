package  {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	
	public class BlockMerchant extends MovieClip{
		static var playset:Array = ["T", "Y", "S", "Z", "5", "U", "L", "J", "l", "O"];
		static var current:Block;
		static var nextBlock:String; //the name of the type of the next block
		static var nextBlockImage:Block = null; // the display of the next block
		static var board:Board;
	
		public function BlockMerchant() {
			board = new Board();
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

		function startGame() {
			current = new Block(playset[Math.floor(Math.random()*playset.length)]);
			current.addEventListener("enterFrame", current.move);
			stage.addChild(current);
			current.gx = 4;
			current.gy = 0;
			displayPlayset();
			nextBlock = playset[Math.floor(Math.random()*playset.length)];
			displayNextBlock();
		}
		
		function displayNextBlock() {
			if (nextBlock) {
				//trace("nextBlock is... " + nextBlock);
				if (nextBlockImage && nextBlockImage.type != nextBlock) {
					trace("but, nextBlockImage is of type: "+nextBlockImage.type);
					nextBlockImage.destroy();
				
					nextBlockImage = new Block(nextBlock);
					nextBlockImage.makeSpecial();
					stage.addChild(nextBlockImage);
					nextBlockImage.height *= 1;
					nextBlockImage.width *= 1;
					nextBlockImage.x = 330;
					nextBlockImage.y = 40;
				}
				if (!nextBlockImage) {
					nextBlockImage = new Block(nextBlock);
					nextBlockImage.makeSpecial();
					stage.addChild(nextBlockImage);
					//trace("nextBlock image is... " + nextBlockImage);
					nextBlockImage.height *= 1;
					nextBlockImage.width *= 1;
					nextBlockImage.x = 330;
					nextBlockImage.y = 40;
				}
			}
		}
		function displayPlayset() {
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
		function enterFrame(e:Event){
			if((Key.isDown(Keyboard.ENTER))) {
				board.clean();
				nextBlockImage = null;
				startGame();
				
			}
			if((Key.isDown(84))) {
				board.traceBoard();
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
