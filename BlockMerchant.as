package  {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class BlockMerchant extends MovieClip{
		static var masterset:Array = ["T", "Y", "S", "Z", "5", "U", "L", "J", "l", "O", "r", "t", "H"];
		static var playset:Array = ["T", "Y", "S", "Z", "5", "U", "L", "J", "l", "O", "r", "t", "H"];
		static var current:Block;
		static var nextBlock:String; //the name of the type of the next block
		static var nextBlockImage:Block = null; // the display of the next block
		static var board:Board;
		static var shop:MovieClip;
		static var pigPic:MovieClip;
		static var gameOverMessage:TextField;
		static var gameOverMessageFormat = new TextFormat();
		
		static var music1 = new ComfortMusic();
		static var musicShopA = new ShoppeA();
		static var musicShopB = new ShoppeB();
		static var musicChannel;
	
		public function BlockMerchant() {
			board = new Board();
			shop = new Shop();
			shop.x = 0;
			shop.y = 530-shop.height;
			stage.addChild(shop);
			pigPic = new PigPic();
			pigPic.x = 20;
			pigPic.y = 55;
			stage.addChild(pigPic);
			gameOverMessage = new TextField();
			gameOverMessage.x = 70;
			gameOverMessage.y = 75;
			gameOverMessage.width = 160;
			gameOverMessageFormat.size = 14;
			gameOverMessage.defaultTextFormat = gameOverMessageFormat;
			gameOverMessage.text = "Press ENTER to play again!";
			addChild(gameOverMessage);
			
			Key.initialize(stage);
			board.traceBoard();
			startGame();
			addEventListener("enterFrame", enterFrame);
		}
		static function loopMusic(music) {
			if (musicChannel) { musicChannel.stop();}
			musicChannel = music.play(0,1000);
		}
		static function gameOver() {
			trace("Game Over, no extra life!");
			pigPic.visible = true;
			gameOverMessage.visible = true;
			board.traceBoard();
			trace(Block.list.length + "total blocks");
			musicChannel.stop();
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
			pigPic.visible = false;
			gameOverMessage.visible = false;
			randomizePlayset();
			current = new Block(playset[Math.floor(Math.random()*playset.length)]);
			current.addEventListener("enterFrame", current.move);
			stage.addChild(current);
			current.gx = 4;
			current.gy = 0;
			displayPlayset();
			nextBlock = playset[Math.floor(Math.random()*playset.length)];
			loopMusic(music1);
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
			
			if (musicChannel) { musicChannel.stop();}
			musicChannel = musicShopA.play();
			if(!musicChannel.hasEventListener(Event.SOUND_COMPLETE)) {
				musicChannel.addEventListener( Event.SOUND_COMPLETE, musicComplete );
			}
			
		}
		static function musicComplete (e : Event) : void {
			loopMusic(musicShopB);
    	}
		function nextLevel()  {  // may only be called from shop after deals have been displayed
			shop.visible = false;
			shop.dealsDisplayed = false;
			shop.clearText();
			stage.removeChild(shop.dealBubble);
			displayPlayset();
			current.addEventListener("enterFrame", current.move);
			loopMusic(music1);
		}
		function enterFrame(e:Event){
			if((Key.isDown(Keyboard.ENTER)) && (gameOverMessage.visible == true)) {
				board.clean();
				nextBlockImage = null;
				startGame();
				
			}
			if((Key.isDown(84))) { //t
				board.traceBoard();
			}
			if((shop.visible == true) && (shop.dealsDisplayed == true) && (Key.isDown(78))) { //n
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
