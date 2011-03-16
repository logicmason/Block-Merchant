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
		var dealBubble = new Sprite();
		var masterDealList:Array = [[["L","J"], 3], 
									[["S","Z"], 2],
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
			trace("textList after clearText(): " + textList);
			textList = [];
		}
		public function drawDealBubble(s:Sprite, numDeals:int) {
			var inner_color = 0x000000;
			var edge_color = 0xFFFFFF;
			s.graphics.clear();
			s.graphics.lineStyle(3,edge_color);
			s.graphics.beginFill(inner_color);
			s.graphics.drawRect(300,110,155-3,40+50*(numDeals)-3);
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

			if(deals.length < 1) {
				greeting.text = "Oink! Oink!  I don't have any sets to offer you!";
				greeting.appendText("\nPress n for n)ext level or s to s)ell.");
			}
				trace("Current deals: " + deals);
		}
		public function prepareSales() {
			deals = [];
			for (var sale in masterSaleList) {
				if ((BlockMerchant.playset.indexOf(masterSaleList[sale][0][0]) != -1)) {
					deals.push([[], masterSaleList[sale][0], masterSaleList[sale][1]]);
				}
				
				
			}
			trace("Current sales: " + deals);
		}
		function enterFrame(e:Event){
			gold.text = Board.money.toString();
			if(Key.isDown(82)) { //r
				if(dealBubble.parent) {
					dealBubble.parent.removeChild(dealBubble);
					for (var d = 0; d < dealList.length; d++) {
						if (dealList[d]) dealList[d].destroy();
					}
					deals = [];
					dealList = [];
					dealsDisplayed = false;
					clearText();
				}
			}
			if((this.visible == true) && (dealsDisplayed == false)) {
				deals = [];
				dealList = [];
				greeting.text = "Oink! Oink!  Welcome to my block shop!";
				greeting.appendText("\nWould you like to b)uy or s)ell?");
				//greeting.appendText("\nPress a number key to buy or sell.");
				
				if((Key.isDown(66))) { //b
					greeting.text = "Press a number key to buy a pack of blocks.";
					greeting.appendText("\nPress n for n)ext level or r to r)eturn.");
					prepareDeals();
				}
				if((Key.isDown(83))) { //s
					greeting.text = "Press a number key to sell one of your blocks.";
					greeting.appendText("\nPress n for n)ext level or r to r)eturn.");
					prepareSales();
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
	
					//new Deal(["T"], ["H", "Y", "t"], 5, 1, this);
					dealsDisplayed = true;
				}
			}
		}

	}
	
}
