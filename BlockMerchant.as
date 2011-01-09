package  {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	
	public class BlockMerchant extends MovieClip{
		static var playset:Array = ["U" , "O", "T", "l"];
		static var current:Block;
		static var board:Board;
	
		public function BlockMerchant() {
			board = new Board();
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
		}
		function enterFrame(e:Event){
			if((Key.isDown(Keyboard.ENTER))) {
				board.clean();
				startGame();
			}
			if((Key.isDown(84))) {
				board.traceBoard();
			}
		}

	}
	
}
