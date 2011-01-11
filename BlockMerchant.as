package  {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	
	public class BlockMerchant extends MovieClip{
		static var playset:Array = ["T", "Y", "S", "Z"];
		static var current:Block;
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
		}
		
		function displayPlayset() {
			for (var i in playset) {
				var b = new Block(playset[i]);
				stage.addChild(b);
				b.height *= .7;
				b.width *= .7;
				b.x = 300+100*Math.floor(i/6);
				b.y = (i%6)*70+70;
			}
		}
		function enterFrame(e:Event){
			if((Key.isDown(Keyboard.ENTER))) {
				board.clean();
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
		}

	}
	
}
