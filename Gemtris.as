
package
{
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class Gemtris extends Sprite
	{
		/***************************
		// Define vars
		***************************/
		private var isEndGame:Boolean;
		private var gameTimer:Timer;
		private var gameBitmapData:BitmapData;
		private var gamePieceCurrentBitmapData:BitmapData;
		private var gamePieceNextBitmapData:BitmapData;
		private var gameShape:Shape;
		private var gameShapeCurrentPiece:Shape;
		private var gameShapeNextPiece:Shape;
		private var gameSpeed:Number = 1000;
		private var gameScore:Number;
		private var gameLinesCleared:Number;
		private var gameLevel:Number;
		private var gamePointsToNextLevel:Number;
		private var gameArray:Array = [[0,0,0,0,0,0,0,0,0,0,0,0],
									   [9,0,0,0,0,0,0,0,0,0,0,9],
									   [9,0,0,0,0,0,0,0,0,0,0,9],
									   [9,0,0,0,0,0,0,0,0,0,0,9],
									   [9,0,0,0,0,0,0,0,0,0,0,9],
									   [9,0,0,0,0,0,0,0,0,0,0,9],
									   [9,0,0,0,0,0,0,0,0,0,0,9],
									   [9,0,0,0,0,0,0,0,0,0,0,9],
									   [9,0,0,0,0,0,0,0,0,0,0,9],
									   [9,0,0,0,0,0,0,0,0,0,0,9],
									   [9,0,0,0,0,0,0,0,0,0,0,9],
									   [9,0,0,0,0,0,0,0,0,0,0,9],
									   [9,0,0,0,0,0,0,0,0,0,0,9],
									   [9,0,0,0,0,0,0,0,0,0,0,9],
									   [9,0,0,0,0,0,0,0,0,0,0,9],
									   [9,0,0,0,0,0,0,0,0,0,0,9],
									   [9,0,0,0,0,0,0,0,0,0,0,9],
									   [9,0,0,0,0,0,0,0,0,0,0,9],
									   [9,0,0,0,0,0,0,0,0,0,0,9],
									   [9,0,0,0,0,0,0,0,0,0,0,9],
									   [9,9,9,9,9,9,9,9,9,9,9,9]];

		//creates multidimensional array to hold all the different pieces and their rotations
		private const PIECE_S:Array = [[[0, 1, 0], [0, 1, 1], [0, 0, 1]], [[0, 0, 0], [0, 1, 1], [1, 1, 0]], [[0, 1, 0], [0, 1, 1], [0, 0, 1]], [[0, 0, 0], [0, 1, 1], [1, 1, 0]]];
		private const PIECE_Z:Array = [[[0, 1, 0], [1, 1, 0], [1, 0, 0]], [[0, 0, 0], [1, 1, 0], [0, 1, 1]], [[0, 1, 0], [1, 1, 0], [1, 0, 0]], [[0, 0, 0], [1, 1, 0], [0, 1, 1]]];
		private const PIECE_T:Array = [[[1, 1, 1], [0, 1, 0], [0, 0, 0]], [[1, 0], [1, 1], [1, 0]], [[0, 0, 0], [0, 1, 0], [1, 1, 1]], [[0, 0, 1], [0, 1, 1], [0, 0, 1]]];
		private const PIECE_O:Array = [[[1, 1], [1, 1]]];
		private const PIECE_I:Array = [[[0, 1], [0, 1], [0, 1], [0, 1]], [[0, 0, 0, 0], [1, 1, 1, 1]]];
		private const PIECE_L:Array = [[[0, 1, 0], [0, 1, 0], [0, 1, 1]], [[0, 0, 1], [1, 1, 1], [0, 0, 0]], [[1, 1, 0], [0, 1, 0], [0, 1, 0]], [[0, 0, 0], [1, 1, 1], [1, 0, 0]]];
		private const PIECE_J:Array = [[[0, 1, 1], [0, 1, 0], [0, 1, 0]], [[1, 0, 0], [1, 1, 1], [0, 0, 0]], [[0, 1, 0], [0, 1, 0], [1, 1, 0]], [[0, 0, 0], [1, 1, 1], [0, 0, 1]]];
		private const PIECES:Array = [PIECE_S, PIECE_Z, PIECE_T, PIECE_O, PIECE_I, PIECE_L, PIECE_J];

		//private var gamePieceCurrent:Array = createRandomPiece();
		private var gamePieceNext:Array;
		private var gamePieceCurrent:Array;
		private const PIECE_DIMENSION:Number = 4;
		private const SCALE:Number = 20;
		private const GAME_VERSION:String = "0.1.1";
		
		private var currentPieceX:Number;
		private var currentPieceY:Number;
		private var currentPiece:Number;
		private var currentRotation:Number;
		private var previousPiece:Number;
		private var previousRotation:Number;
		
		private var gameLevelText:TextField;
		private var gameScoreText:TextField;
		private var gameLinesText:TextField;
		private var gameVersionText:TextField;
		
		private const textFormat:TextFormat = new TextFormat("Arial", 26);
		private const textFormatVersion:TextFormat = new TextFormat("Arial", 10);

		public function Gemtris():void {
			init();
			startGame();
    	}
	
		private function init():void
		{
			var gameSprite:Sprite = addChild(new Sprite) as Sprite;
			var gameNextPieceSprite:Sprite = addChild(new Sprite) as Sprite;
			
			gamePieceNext = createRandomPiece();
			
			gameSprite.x = 20;
			gameSprite.y = 20;
			gameSprite.scaleX = SCALE;
			gameSprite.scaleY = SCALE;
			
			gameNextPieceSprite.x = 340;
			gameNextPieceSprite.y = 230;
			gameNextPieceSprite.scaleX = SCALE;
			gameNextPieceSprite.scaleY = SCALE;
			
			gameScore = 0;
			gameLevel = 1;
			gameLinesCleared = 0;
			gamePointsToNextLevel = 100;

			//creates text for gameScore
			gameScoreText = addChild(new TextField) as TextField;
			gameScoreText.width = stage.stageWidth;
			gameScoreText.defaultTextFormat = textFormat;
			gameScoreText.htmlText = "SCORE " + gameScore.toString();
			gameScoreText.textColor = 0xFF0000;
			gameScoreText.x = 300;
			gameScoreText.y = 100;
			
			//creates text for gameLevel
			gameLevelText = addChild(new TextField) as TextField;
			gameLevelText.width = stage.stageWidth;
			gameLevelText.defaultTextFormat = textFormat;
			gameLevelText.htmlText = "LEVEL " + gameLevel.toString();
			gameLevelText.textColor = 0xFF0000;
			gameLevelText.x = 300;
			gameLevelText.y = 120;
			
			//creates text for gameLinesCleared
			gameLinesText = addChild(new TextField) as TextField;
			gameLinesText.width = stage.stageWidth;
			gameLinesText.defaultTextFormat = textFormat;
			gameLinesText.htmlText = "LINES " + gameLinesCleared.toString();
			gameLinesText.textColor = 0xFF0000;
			gameLinesText.x = 300;
			gameLinesText.y = 140;
			
			//creates text for gameLinesCleared
			gameVersionText = addChild(new TextField) as TextField;
			gameVersionText.width = stage.stageWidth;
			gameVersionText.defaultTextFormat = textFormatVersion;
			gameVersionText.htmlText = "VERSION " + GAME_VERSION;
			gameVersionText.textColor = 0xFF0000;
			gameVersionText.x = 430;
			gameVersionText.y = 80;

			gameShape = new Shape();
			gameShapeCurrentPiece = new Shape();
			gameShapeNextPiece = new Shape();
			
			gameShape = gameSprite.addChild(new Shape) as Shape;
			gameShapeCurrentPiece = gameSprite.addChild(new Shape) as Shape;
			gameShapeNextPiece = gameNextPieceSprite.addChild(new Shape) as Shape;
			
			gameBitmapData = new BitmapData(gameArray[0].length, gameArray.length);
			gamePieceCurrentBitmapData = new BitmapData(PIECE_DIMENSION, PIECE_DIMENSION);
			gamePieceNextBitmapData = new BitmapData(PIECE_DIMENSION, PIECE_DIMENSION);

			gameTimer = new Timer(gameSpeed);
			gameTimer.addEventListener(TimerEvent.TIMER, timerHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			
			isEndGame = false;
		}
		
		private function startGame():void
		{
			createNextPiece();
			drawScreen();
			gameTimer.start();
		}
		
		private function createRandomPiece():Array{
			
			//creates random piece
			var randomPiece:Number = Math.random() * (PIECES.length - 1);
			currentPiece = Math.round(randomPiece);
			var randomRotation:Number = Math.random() * (PIECES[currentPiece].length - 1);
			currentRotation = Math.round(randomRotation);
			return PIECES[currentPiece][currentRotation];
		}
		
		private function keyHandler(e:KeyboardEvent):void
		{
			switch (e.keyCode) {
                    case Keyboard.LEFT: 
						movePiece(0); 
						//trace("keyLEFT");
						break;
                    case Keyboard.UP: 
						movePiece(1); 
						//trace("keyUP");
						break;
                    case Keyboard.RIGHT: 
						movePiece(2); 
						//trace("keyRIGHT");
						break;
                    case Keyboard.DOWN:
						movePiece(3);
						//trace("keyDOWN");
                    	break;
              }
		}

		private function movePiece(direction):void
		{
			switch (direction) {
                    case 0: 
						currentPieceX--;
						detectCollision(direction);
						drawScreen();
						//trace("movePieceLeft");
						break;
                    case 1: 
						rotatePiece();
						detectCollision(direction);
						drawScreen();
						//trace("movePieceUp");
						break;
                    case 2: 
						currentPieceX++;
						detectCollision(direction);
						drawScreen();
						//trace("movePieceRight");
						break;
                    case 3:
						currentPieceY++;
						detectCollision(direction);
						gameTimer.reset();
						gameTimer.start();
						drawScreen();
						//trace("movePieceDown");
                    	break;
                }
		}

		private function rotatePiece():void
		{
			if(PIECES[previousPiece].length - 1 > previousRotation)
			{
				previousRotation++;
			}else{
				previousRotation = 0;
			}
			gamePieceCurrent = PIECES[previousPiece][previousRotation];
		}
		
		private function unrotatePiece():void
		{
			if(previousRotation == 0)
			{
				previousRotation = PIECES[previousPiece].length - 1;
			}else{
				previousRotation--;
			}
			gamePieceCurrent = PIECES[previousPiece][previousRotation];
		}
		
		private function detectCollision(direction):Boolean
		{
			for(var i:int = 0; i < gamePieceCurrent[0].length; i++){
				for(var j:int = 0; j < gamePieceCurrent.length; j++){
					if(gamePieceCurrent[j][i] > 0 && gameArray[j + currentPieceY][i + currentPieceX] > 0)
					{
						//trace("collision detected");
						//undoes the move if collision detected
						switch(direction){
							case 0:
								//left
								currentPieceX++;
								break;
							case 1:
								//up
								unrotatePiece();
								break;
							case 2:
								//right
								currentPieceX--;
								break;
							case 3:
								//down
								currentPieceY--;
								//set the piece if collision detected on down direction
								setPiece();
								break;
							case 4:
								//new piece created
								endGame();
								break;
						}
						return true;
					}
				}
			}
			return false;
		}
		private function endGame():void
		{
			trace("endGame called");
			
			//stop the timer
			gameTimer.stop();
			
			//set isEndGame flag
			isEndGame = true;
		}
		private function setPiece():void
		{
			for(var i:int = 0; i < gamePieceCurrent[0].length; i++){
				for(var j:int = 0; j < gamePieceCurrent.length; j++){
					if(gamePieceCurrent[j][i] > 0)
					{
						gameArray[j + currentPieceY][i + currentPieceX] = 1;
					}
				}
			}
			
			if(!isEndGame){
				//check for cleared rows
				clearCompletedRows();
				createNextPiece();
			}
		}
		
		private function clearCompletedRows():void
		{
			var numberLinesCleared:Number = 0;
			for(var i:int = 0; i < gameArray.length; i++){
				var j:int = 1;
				while(j < gameArray[0].length){
					if(gameArray[i][j] == 1){
						j++;
					}else{
						break;
					}
				}
				if(j == 11){
					deleteLine(i);
					numberLinesCleared++;
				}
			}
			//scoring mechanic
			switch(numberLinesCleared)
			{
				case 1:
					gameScore += 100;
					gameLinesCleared += 1;
					break;
				case 2:
					gameScore += 300;
					gameLinesCleared += 2;
					break;
				case 3:
					gameScore += 500;
					gameLinesCleared += 3;
					break;
				case 4:
					gameScore += 800;
					gameLinesCleared += 4;
					break;
			}
					
			//increment level if number of lines cleared is modulus of 10
			incrementLevel();

			// game level is dependent on the number of lines you clear
			gameScoreText.htmlText = "SCORE " + gameScore.toString();
			gameLinesText.htmlText = "LINES " + gameLinesCleared.toString();
			gameLevelText.htmlText = "LEVEL " + gameLevel.toString();
		}
		
		private function incrementLevel():void
		{
			if(gameScore >= gamePointsToNextLevel)
			{
				//increase the level
				gameLevel++;
				//increase the speed
				if(gameSpeed>200)gameSpeed -= 200;
				//increase the score to next level
				gamePointsToNextLevel += gameScore * 2;
			}
		}
		
		private function deleteLine(lineNumber):void
		{
			for(var j:int = lineNumber; j > 0; j--){
				for(var i:int = 1; i < gameArray[0].length - 1; i++){
					//copies all lines above cleared line down one on y-axis
					gameArray[j][i] = gameArray[j-1][i];
				}
			}
		}
		
		private function createNextPiece():void
		{
			//resets gamePieceCurrent
			
			gamePieceCurrent = gamePieceNext;
			previousPiece = currentPiece;
			previousRotation = currentRotation;
			gamePieceNext = createRandomPiece();
			
			//positions random piece
			currentPieceX = 4;
			currentPieceY = 0;
			
			//checks to see if new piece placement causes collision
			detectCollision(4);
		}
				
		private function timerHandler(e:TimerEvent):void
		{
			movePiece(3); //move piece down
			drawScreen();
		}
		
		private function drawScreen():void
		{
			if(gameArray.length == 0) {
				throw new Error("gameArray is empty");
			}
			
			//fills background with color
			gameBitmapData.fillRect(gameBitmapData.rect, 0xfffffff0);
			gamePieceNextBitmapData.fillRect(gamePieceNextBitmapData.rect, 0xffffffff);
			
			//render game bounds from gameBitmapData
			for(var i:int = 0; i < gameArray[0].length; i++) { // horizontal
				for(var j:int = 0; j < gameArray.length; j++) { // vertical
					if(gameArray[j][i] == 9){
						gameBitmapData.setPixel32(i, j, 0xff000000);
					}
				}
			}
			
			//render static pieces from gameBitmapData
			for(var k:int = 0; k < gameArray[0].length; k++) { // horizontal
				for(var l:int = 0; l < gameArray.length; l++) { // vertical
					if(gameArray[l][k] == 8){
						gameBitmapData.setPixel32(k, l, 0xffff0000);
					}
				}
			}
			
			//render set pieces from gameBitmapData
			for(var a:int = 0; a < gameArray[0].length; a++) { // horizontal
				for(var b:int = 0; b < gameArray.length; b++) { // vertical
					if(gameArray[b][a] == 1){
						gameBitmapData.setPixel32(a, b, 0xffff0000);
					}
				}
			}
			
			//determines position of currentPiece on gameBoard
			for(var c:int = 0; c < gamePieceCurrent[0].length; c++) { // horizontal
				for(var d:int = 0; d < gamePieceCurrent.length; d++) { // vertical
					if(gamePieceCurrent[d][c] == 1){
						gameBitmapData.setPixel32(c+currentPieceX, d+currentPieceY, 0xffff0000);
					}
				}
			}
			

			//draws gamePieceNext
			for(var e:int = 0; e < gamePieceNext[0].length; e++) { // horizontal
				for(var f:int = 0; f < gamePieceNext.length; f++) { // vertical
					if(gamePieceNext[f][e] == 1){
						gamePieceNextBitmapData.setPixel32(e, f, 0xffff0000);
					}
				}
			}
			
			//gamePieceNextBitmapData.setPixel32(1, 1, 0xffff0000);
			
			//draws gameBackground and gameBitmapData to gameShape
			gameShape.graphics.clear();
			gameShape.graphics.beginBitmapFill(gameBitmapData, null, false);
			gameShape.graphics.drawRect(0,0,gameBitmapData.width, gameBitmapData.height);
			gameShape.graphics.endFill();
			
			//draws gamePieceNext
			gameShapeNextPiece.graphics.clear();
			gameShapeNextPiece.graphics.beginBitmapFill(gamePieceNextBitmapData, null, false);
			gameShapeNextPiece.graphics.drawRect(0,0,gamePieceNextBitmapData.width, gamePieceNextBitmapData.height);
			gameShapeNextPiece.graphics.endFill();
		}
	}
}