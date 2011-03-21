package  {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.net.*;
	
	public dynamic class BlockMerchant extends MovieClip{
		static var kongregate:*
				
		static var masterset:Array = ["T", "Y", "S", "Z", "5", "u", "U", "L", "J", "l", "O", "r", "t", "H"];
		static var startingSet:Array = ["S", "Z", "u", "T", "L", "J"];
		static var playset:Array = new Array;
		static var current:Block;
		static var nextBlock:String; //the name of the type of the next block
		static var nextBlockImage:Block = null; // the display of the next block
		static var board:Board;
		static var shop:MovieClip;
		static var pigPic:MovieClip;
		static var introScreen:Intro = new Intro();
		static var instructionScreen:IntroB = new IntroB();
		static var creditsScreen:Credits = new Credits();
		static var gameOverMessage:TextField;
		static var messageFormat = new TextFormat();
		static var gameComplete = 0;
		static var gameInitialized:Boolean;
		
		static var music1 = new ComfortMusic();
		//static var music2 = new LostCauseMusic();
		//static var music3 = new TruthMusic();
		//static var music3 = new TheNetherMusic();
		static var musicShopA = new ShoppeA();
		static var musicShopB = new ShoppeB();
		static var musicChannel;
	
		public function loadAPI(){
		  var paramObj:Object = LoaderInfo(root.loaderInfo).parameters;
		  var api_url:String = paramObj.api_path ||  "http://www.kongregate.com/flash/API_AS3_Local.swf";
		  var request:URLRequest = new URLRequest ( api_url );
		  var loader:Loader = new Loader();
		  loader.contentLoaderInfo.addEventListener ( Event.COMPLETE, apiLoadComplete );
		  loader.load ( request );
		  this.addChild ( loader );
		}
		public function apiLoadComplete( event:Event ):void {
			kongregate = event.target.content;
			kongregate.services.connect();
			
			kongregate.stats.submit("score", Board.points);
			kongregate.stats.submit("gold", Board.money);
			kongregate.stats.submit("gameComplete", gameComplete);
			initializeGame();
		}
				
		public function onConnectError(status:String):void {
		// handle error here...
			if(!gameInitialized) {initializeGame();}
		}
		public function BlockMerchant() {
			var _mochiads_game_id:String = "701defcb37bf8dbc";
			//mochi.as3.MochiServices.connect("dcbe9b807ff7322e", root, onConnectError);  // use mochi.as2.MochiServices.connect for AS2 API
			//MochiAd.showPreGameAd({clip:root, id:"dcbe9b807ff7322e", res:"600x300", ad_finished: initializeGame});
			loadAPI();  // for Kongregate
		}
		public function initializeGame() {
			introScreen.version.text = "1.03"
			board = new Board();
			shop = new Shop();
			shop.x = 0;
			shop.y = 530-shop.height;
			shop.visible = false;
			stage.addChild(shop);
			pigPic = new PigPic();
			pigPic.x = 20;
			pigPic.y = 55;
			pigPic.visible = false;
			stage.addChild(pigPic);
			introScreen.startButton.addEventListener("mouseDown", startButtonHit);
			stage.addChild(introScreen);
			introScreen.creditsButton.addEventListener("mouseDown", creditsButtonHit);
			creditsScreen.visible = false;
			stage.addChild(creditsScreen);
			
			messageFormat.size = 14;
			messageFormat.align = "center";
			gameOverMessage = new TextField();
			gameOverMessage.x = 70;
			gameOverMessage.y = 75;
			gameOverMessage.width = 160;
			gameOverMessage.defaultTextFormat = messageFormat;
			gameOverMessage.text = "Press ENTER to play again!";
			gameOverMessage.visible = false;
			addChild(gameOverMessage);
			
			Key.initialize(stage);
			board.traceBoard();
			//startGame();
			addEventListener("enterFrame", enterFrame);
		}
		function creditsButtonHit(e:Event) {
			creditsScreen.closeButton.addEventListener("mouseDown", closeCreditsHit);
			creditsScreen.visible = true;
		}
		function closeCreditsHit(e:Event) {
			creditsScreen.visible = false;
			creditsScreen.removeEventListener("mouseDown", closeCreditsHit);
		}
		function startButtonHit(e:Event) {
			introScreen.startButton.removeEventListener("mouseDown", startButtonHit);
			stage.removeChild(introScreen);
			instructionScreen.playButton.addEventListener("mouseDown", playButtonHit);
			stage.addChild(instructionScreen);
		}
		function playButtonHit(e:Event) {
			instructionScreen.removeEventListener("mouseDown", playButtonHit);
			stage.removeChild(instructionScreen);
			startGame();
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
			submitStats();
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
			//randomizePlayset();
			playset = startingSet.slice(0);
			current = new Block(playset[Math.floor(Math.random()*playset.length)]);
			current.addEventListener("enterFrame", current.move);
			stage.addChild(current);
			current.setKeyListener(stage);
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
			submitStats();
			
		}
		static function musicComplete (e : Event) : void {
			loopMusic(musicShopB);
    	}
		function nextLevel()  {  // may only be called from shop after deals have been displayed
			shop.visible = false;
			shop.clearDeals();
			shop.clearText();
			trace(shop.textList.length);
					for (var item in shop.textList) {
						trace(item+": "+shop.textList[item].toString);
					}
			displayPlayset();
			current.addEventListener("enterFrame", current.move);
			loopMusic(music1);
		}
		
		static function submitStats() {
			kongregate.stats.submit("score", Board.points);
			kongregate.stats.submit("gold", Board.money);
			kongregate.stats.submit("linesCleared", Board.linesCleared);
			
			kongregate.stats.submit("singlesCleared", Board.cleared[1]);
			kongregate.stats.submit("doublesCleared", Board.cleared[2]);
			kongregate.stats.submit("triplesCleared", Board.cleared[3]);
			kongregate.stats.submit("quadsCleared", Board.cleared[4]);
			kongregate.stats.submit("fiversCleared", Board.cleared[5]);
			
			kongregate.stats.submit("level", Board.level);
			kongregate.stats.submit("speed", Block.gravity);
			//kongregate.stats.submit("playset", playset.toString()); // sends NAN for some reason
			kongregate.stats.submit("gameComplete", gameComplete);
		}
		
		function enterFrame(e:Event){
			if((Key.isDown(Keyboard.ENTER))) {
				if (gameOverMessage.visible == true) {
					board.clean();
					nextBlockImage = null;
					startGame();
				}
								
			}
			if((Key.isDown(84))) { //t
				board.traceBoard();
			}
			if((shop.visible == true) && (Key.isDown(76))) { //L
				nextLevel();
			}
			goldDisplay.text = Board.money.toString();
			scoreDisplay.text = Board.points.toString();
			levelDisplay.text = Board.level.toString();
			linesDisplay.text = Board.linesCleared.toString();
			linesRemainingDisplay.text = Board.linesRemaining.toString();
			speedDisplay.text = Block.gravity.toString();
			displayNextBlock();
		}

	}
	
}
