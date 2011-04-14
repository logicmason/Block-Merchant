package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.Sprite;
	
	public class Shop extends MovieClip{
		var dealsDisplayed:Boolean = false;
		var deals:Array = []; // this is where data for generating the deals is kept
		var dealList:Array = []; // an array of deal objects
		var textList:Array = [];
		var textFormatList:Array = [];
		static var salesFormat = new TextFormat();
		static var inventoryFormat = new TextFormat();
		var visits:int = 0; // incremented in BlockMerchant.as endLevel()
		var dealBubble = new Sprite();
		var masterDealList:Array = [[["U","Y"], 0],
									[["u","H"], 0],
									[["L","J"], 4], 
									[["S","Z"], 3],
									[["T","u"], 2],
									[["t","r"], 1],
									[["l","Y"], 4],
									[["l","O"], 6],
									[["5","H"], 7],
									[["U","T"], 2],
									[["T","O"], 4],
									[["t","5"], 4]
									];
		var masterSaleList:Array = [[["r"], 1],
									[["T"], 2],
									[["Z"], 3],
									[["S"], 3],
									[["L"], 2],
									[["J"], 2],
									[["l"], 1],
									[["O"], 2],
									[["u"], 3],
									[["U"], 4],
									[["H"], 5],
									[["t"], 6],
									[["Y"], 4],
									[["5"], 3]
									];
		public function Shop() {
			// constructor code
			salesFormat.size = 15;
			salesFormat.color = 0xFFFFFF;
			inventoryFormat.size = 18;
			inventoryFormat.color = 0xFFFFFF;
			inventoryFormat.align = "center";
			addEventListener("enterFrame", enterFrame);
		}
		
		public function addPiece(piece:String) {
			if ((BlockMerchant.masterset.indexOf(piece) != -1) &&
				(BlockMerchant.playset.indexOf(piece) == -1)) {
				BlockMerchant.playset.push(piece);
			}
			else trace (piece +" is not a valid piece");
		}
		public function removePiece(piece:String) {
			var index = BlockMerchant.playset.indexOf(piece);
			if (index != -1) {
				BlockMerchant.playset.splice(index,1);
			}
			else trace (piece +" cannot be removed");
		}
		public function clearText(){
			for (var i = 0; i < textList.length; i++) {
				stage.removeChild(textList[i]);
				delete(textList[i]);
			}
			textList = [];
		}
		public function drawDealBubble(s:Sprite, numDeals:int) {
			var inner_color = 0x000000;
			var edge_color = 0xFFFFFF;
			s.graphics.clear();
			s.graphics.lineStyle(3,edge_color);
			s.graphics.beginFill(inner_color);
			s.graphics.drawRect(300,100,155-3,28+50*(numDeals)-3);
			s.graphics.endFill();
			stage.addChild(s);
		}
		public function prepareDeals() {
			deals = [];
			for (var deal in masterDealList) {
				if ((BlockMerchant.playset.indexOf(masterDealList[deal][0][0]) == -1) &&
					(BlockMerchant.playset.indexOf(masterDealList[deal][0][1]) == -1))
					deals.push([masterDealList[deal][0],[],masterDealList[deal][1], ""]);
			}
			if (Board.money > 10) {
				deals.push([[],[],Deal.orbCost, "orb"]); //orb of time
			}
			if(deals.length > 8) deals = deals.slice(0,8);
			if(deals.length < 1) {
				greeting.text = "Oink! Oink!  I don't have any sets to offer you!";
			}
				//trace("Current deals: " + deals);
		}
		public function prepareSales() {
			deals = [];
			for (var sale in masterSaleList) {
				if ((BlockMerchant.playset.indexOf(masterSaleList[sale][0][0]) != -1)) {
					deals.push([[], masterSaleList[sale][0], masterSaleList[sale][1]]);
				}
				
				
			}
			if (deals.length > 8) deals = deals.slice(0,8);
			trace("Current sales: " + deals);
		}
		function clearDeals() {
			if(dealBubble.parent) {
				dealBubble.parent.removeChild(dealBubble);
			}
			for (var d = 0; d < dealList.length; d++) {
				if (dealList[d]) dealList[d].destroy();
			}
			deals = [];
			dealList = [];
			dealsDisplayed = false;
			clearText();
			BlockMerchant.clearPlayset();
		}
		function enterFrame(e:Event){
			if (this.visible == true) {
				gold.text = Board.money.toString();
				if((dealsDisplayed == false)) {
					if (visits == 1) {
						greeting.text = "Greetings piglet!  First you'll need to buy some blocks!";
						greeting.appendText("\nI only sell them in sets of two.");
					} else if (visits ==2) {
						greeting.text = "Some of those blocks are hard to use, aren't they?";
						greeting.appendText("\nJust this once I'll clean the board for you, oink!");
						BlockMerchant.boardLink.clean();
						
					} else {
						greeting.text = "Oink! Oink!  Welcome to my block shop!";
					}
				}
				// L leaves (function in BlockMerchant.as)
				if(Key.isDown(82)) { //r
					clearDeals();
				}
				if((Key.isDown(66))) { //b
						clearDeals();
						greeting.text = "Press a number key to buy a pack of blocks.";
						prepareDeals();
				}
				if((Key.isDown(68))) { //d
					clearDeals();
					greeting.text = "Press a number key to destroy one of your blocks.";
					prepareSales();
				}
				if((Key.isDown(73))) { //i
					//Board.money += 1;
					trace("dealList.length: " + dealList.length);
					clearDeals();
					greeting.text = "Your current inventory: ";
					drawDealBubble(dealBubble,2+BlockMerchant.playset.length/1.5);  // not really a deal, but it makes the logic simpler
					var inventoryText = new TextField();
					inventoryText.defaultTextFormat = inventoryFormat;
					inventoryText.y = 125;
					inventoryText.x = 325;
					inventoryText.text = "Your Blocks";
					textList.push(inventoryText);
					stage.addChild(inventoryText);
					displayPlayset();
					dealsDisplayed = true;
				}
				if (deals.length > 0) {
					drawDealBubble(dealBubble,deals.length);
					var costText = new TextField();
					costText.defaultTextFormat = salesFormat;
					costText.y = 110;
					costText.x = 415;
					costText.text = "Cost";
					textList.push(costText);
					stage.addChild(costText);
					
					for (var deal in deals) {
						//new Deal(deals[deal][0], [], deals[deal][1], deal+1, this); // additions, removals, price, position, shop
						var nd =new Deal(deals[deal][0], deals[deal][1], deals[deal][2], deals[deal][3], deal+1, this); // additions, removals, price, special, position, shop
						dealList.push(nd);
					}
					deals = [];
					//new Deal(["T"], ["H", "Y", "t"], 5, 1, this);
					dealsDisplayed = true;
					
				}
			}
		}
		function displayPlayset() {
			BlockMerchant.clearPlayset();
			for (var i in BlockMerchant.playset) {
				var b = new Block(BlockMerchant.playset[i]);
				b.makeSpecial();
				stage.addChild(b);
				b.height *= .7;
				b.width *= .7;
				b.x = 310+70*(i%2);
				b.y = Math.floor(i/2)*70+150;
			}
		}

	}
	
}
