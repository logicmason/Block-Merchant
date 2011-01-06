package  {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	//import flash.utils.Timer;
	
	
	public class BlockMerchant extends MovieClip{
		static var playset:Array = ["r" , "T", "J"];
		static var current:Block;
		static var board:Board;
	
		public function BlockMerchant() {
			board = new Board();
			Key.initialize(stage);

			current = new Block(playset[Math.floor(Math.random()*playset.length)]);
			stage.addChild(current);
			current.gx = 4;
			current.gy = 0;
			addEventListener("enterFrame", enterFrame);
		}
		static function gameOver() {
			trace("Game Over, no extra life!");
			board.traceBoard();
			trace(Block.list.length + "total blocks");
		}
		function clearBoard() {
			for each(var b in Block.list) {
				b.destroy();
			}
			board.initialize();
			current = new Block(playset[Math.floor(Math.random()*playset.length)]);
			stage.addChild(current);
			current.gx = 4;
			current.gy = 0;
			addEventListener("enterFrame", enterFrame);
		}
		function enterFrame(e:Event){
			if((Key.isDown(Keyboard.ENTER))) {
				clearBoard();
			}
		}

	}
	
}
