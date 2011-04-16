package  {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.net.*;
	import mochi.as3.*
	
	public dynamic class BlockMerchant extends MovieClip{
		static var kongregate:*
		//for Mochi
		static var o:Object = { n: [3, 1, 9, 8, 7, 1, 3, 2, 5, 5, 9, 5, 10, 7, 4, 6], f: function (i:Number,s:String):String { if (s.length == 16) return s; return this.f(i+1,s + this.n[i].toString(16));}};
		static var boardID:String = o.f(0,"");
				
		static var masterset:Array = ["T", "Y", "S", "Z", "5", "u", "U", "L", "J", "l", "O", "r", "t", "H"];
		static var startingSet:Array = [];//["S", "Z", "u", "T", "L", "J"];
		static var minPlayset = 4;
		static var playset:Array = new Array;
		static var isKeyPressed:Array = new Array;
		static var current:Block = null;
		static var nextBlock:String; //the name of the type of the next block
		static var nextBlocks:Array = new Array();
		static var nextBlockImage:Block = null; // the display of the next block
		static var nextBlockImages:Array = new Array();
		static var sight:int = 0; //how many next blocks you can see (don't surpass 3)
		static var board:Board;
		static var shop:MovieClip;
		static var pigPic:MovieClip;
		static var introScreen:Intro = new Intro();
		static var instructionScreen:IntroB = new IntroB();
		static var creditsScreen:Credits = new Credits();
		static var gameOverMessage:TextField;
		static var gamePaused:TextField;
		static var messageFormat = new TextFormat();
		static var pausedFormat = new TextFormat();
		static var gameComplete = 0;
		static var gameInitialized:Boolean;
		static var isPaused:Boolean;
		static var boardLink;
		static var bmLink;
		
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
			trace("couldn't connect to Mochi API");
			//if(!gameInitialized) {initializeGame();}
		}
		public function BlockMerchant() {
			bmLink = this;
			
			var _mochiads_game_id:String = "701defcb37bf8dbc";
			mochi.as3.MochiServices.connect("701defcb37bf8dbc", bmLink, onConnectError);  // use mochi.as2.MochiServices.connect for AS2 API
			//MochiAd.showPreGameAd({clip:root, id:"dcbe9b807ff7322e", res:"600x300", ad_finished: initializeGame});
			loadAPI();  // for Kongregate
		}
		public function initializeGame() {
			introScreen.version.text = "1.13"
			board = new Board();
			Board.stageLink = stage;
			boardLink = board;
			shop = new Shop();
			shop.x = 0;
			shop.y = 530-shop.height;
			shop.visible = false;
			stage.addChild(shop);
			pigPic = new PigPic();
			pigPic.x = 8;
			pigPic.y = 88;
			pigPic.visible = false;
			stage.addChild(pigPic);
			introScreen.startButton.addEventListener("mouseDown", startButtonHit);
			stage.addChild(introScreen);
			introScreen.creditsButton.addEventListener("mouseDown", creditsButtonHit);
			creditsScreen.visible = false;
			stage.addChild(creditsScreen);
			
			messageFormat.size = 16;
			messageFormat.align = "center";
			gameOverMessage = new TextField();
			gameOverMessage.x = 58;
			gameOverMessage.y = 105;
			gameOverMessage.width = 170;
			gameOverMessage.defaultTextFormat = messageFormat;
			gameOverMessage.text = "Press ENTER to play again!";
			gameOverMessage.visible = false;
			stage.addChild(gameOverMessage);
			
			pausedFormat.size = 20;
			pausedFormat.align = "center";
			pausedFormat.font = "Copperplate Gothic Bold";
			gamePaused = new TextField();
			gamePaused.x = 35;
			gamePaused.y = 218.6;
			gamePaused.width = 172.95;
			gamePaused.defaultTextFormat = pausedFormat;
			gamePaused.text = "Game Paused\npress \"p\"";
			gamePaused.visible = false;
			stage.addChild(gamePaused);
			
			Key.initialize(stage);
			setKeyListener(stage);
			pauseButton.addEventListener(MouseEvent.CLICK, pauseClicked);

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
		function pauseClicked(e:Event) {
			pause();
		}
		static function loopMusic(music) {
			if (musicChannel) { musicChannel.stop();}
			musicChannel = music.play(0,1000);
		}
		static function gameOver() {
			//nextBlockImage.parent.removeChild(nextBlockImage);
			//nextBlockImage.destroy();
			
			for (var i in nextBlockImages) {
				nextBlockImages[i].parent.removeChild(nextBlockImages[i]);
				nextBlockImages[i].destroy();
			}
			pigPic.visible = true;
			var p = gameOverMessage.parent;
			p.setChildIndex(gameOverMessage, p.numChildren -1);
			gameOverMessage.visible = true;
			//board.traceBoard();
			//trace(Block.list.length + "total blocks");
			musicChannel.stop();
			
			submitStats();
			MochiScores.showLeaderboard({boardID: boardID, score: Board.points, 									
				onDisplay: function () { onLeaderboardDisplay()}, 
				onClose: function () { onLeaderboardClose()} });
		}
		
		static function onLeaderboardDisplay() {
			Block.hideAll();
			pigPic.visible = false;
			gameOverMessage.visible = false;
			trace("Leaderboard Displayed");
		}
		static function onLeaderboardClose() {
			Block.showAll();
			pigPic.visible = true;
			gameOverMessage.visible = true;
			trace("Leaderboard Closed");
		}
		static function onLeaderboardError() {
			trace("Leaderboard Error");
			onLeaderboardClose()
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
			board.initialize();
			Board.money = 50;
			shop.visible = false;
			shop.visits = 0;
			pigPic.visible = false;
			gameOverMessage.visible = false;
			//randomizePlayset();
			playset = startingSet.slice(0);
			sight = 0;
			endLevel();
			if (playset.length > 0) {
				current = new Block(playset[Math.floor(Math.random()*playset.length)]);
				current.addEventListener("enterFrame", current.move);
				stage.addChild(current);
				current.setKeyListener(stage);
				current.gx = 4;
				current.gy = 0;
				displayPlayset();
				//nextBlock = playset[Math.floor(Math.random()*playset.length)];
				
				nextBlocks = [];
				for (var i = 0; i < sight; i++) {
					nextBlocks.push(playset[Math.floor(Math.random()*playset.length)]);
				}
				displayNextBlock();
			}
			
			//loopMusic(music1);
		}
		
		static function displayNextBlock() {
			if (sight==0) bmLink.nextBlockText.text = "You can't see the \nnext block!";
			if (sight==1) bmLink.nextBlockText.text = "Next Block";
			if (sight==2) bmLink.nextBlockText.text = "Next 2 Blocks (spyglass)";
			if (sight==3) bmLink.nextBlockText.text = "Next 3 Blocks (telescope)";
			for (var i=0; i < sight; i++) {
				if (nextBlocks[i]) {
					if (nextBlockImages[i]) {
						if(nextBlockImages[i].parent) nextBlockImages[0].parent.removeChild(nextBlockImages[i]);
						nextBlockImages[i].destroy();
					}
					nextBlockImages[i] = new Block(nextBlocks[i]);
					nextBlockImages[i].makeSpecial();
					Board.stageLink.addChild(nextBlockImages[i]);
					nextBlockImages[i].x = 330 + i*80 - (nextBlocks.length-1)*40;
					nextBlockImages[i].y = 40;
				}
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
			if (current) current.removeEventListener("enterFrame", current.move);
			clearPlayset();
			shop.visible = true;
			shop.visits += 1;
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
					for (var item in shop.textList) {
						trace(item+": "+shop.textList[item].toString);
					}
			if (current) current.addEventListener("enterFrame", current.move);
			else { 
				
				current = new Block(playset[Math.floor(Math.random()*playset.length)]);
				current.addEventListener("enterFrame", current.move);
				stage.addChild(current);
				current.setKeyListener(stage);
				current.gx = 4;
				current.gy = 0;
			}
			
			displayPlayset();
			nextBlocks = [];
			for (var i = 0; i < sight; i++) {
				nextBlocks.push(playset[Math.floor(Math.random()*playset.length)]);
			}
			displayNextBlock();
			loopMusic(music1);
			//pause();
		}
		function pause() {
			if (isPaused == true) {
				if(shop.visible == false) {
					current.addEventListener("enterFrame", current.move);
					current.setKeyListener(stage);
					isPaused = false;
					gamePaused.visible = false;
				}
			} else if(shop.visible == false) {
				current.removeEventListener("enterFrame", current.move);
				current.removeKeyListeners();
				isPaused = true;
				stage.setChildIndex(gamePaused, stage.numChildren-1);
				gamePaused.visible = true;
			}
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
		
		function setKeyListener(stage) {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyReleased);
			//keyListenersSet = true;
		}
		function removeKeyListeners() {
			//if (keyListenersSet) {
				parent.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
				parent.removeEventListener(KeyboardEvent.KEY_UP, keyReleased);
			//}
		}
		function keyPressed(keyEvent:KeyboardEvent) {
			if (isKeyPressed[keyEvent.keyCode] == false) {
				if(keyEvent.keyCode == 80) { //p
					pause();
				}
			}
			isKeyPressed[keyEvent.keyCode] = true;
		}
		function keyReleased(keyEvent:KeyboardEvent) {
			isKeyPressed[keyEvent.keyCode] = false;
		}
		function enterFrame(e:Event){
			if((Key.isDown(Keyboard.ENTER))) {
				if (gameOverMessage.visible == true) {
					board.clean();
					startGame();
				}
								
			}
			
			if(Key.isDown(84)) { //t
				board.traceBoard();
			}
			if((shop.visible == true) && (Key.isDown(76))) { //L
				if (playset.length >= minPlayset) nextLevel();
				else {
					shop.greeting.text = "Oink! Oink!  You can't leave without at least 4 pieces!";
				}
			} 
			if(shop.visible == false) {
				goldDisplay.text = Board.money.toString();
				scoreDisplay.text = Board.points.toString();
				levelDisplay.text = Board.level.toString();
				linesDisplay.text = Board.linesCleared.toString();
				linesRemainingDisplay.text = Board.linesRemaining.toString();
				speedDisplay.text = Block.gravity.toString();
				//displayNextBlock();
			}
		}

	}
	
}
