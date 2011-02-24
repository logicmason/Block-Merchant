package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.Sprite;
	
	public class Shop extends MovieClip{
		var salesDisplayed:Boolean = false;
		var deals:Array = [];
		var textList:Array = [];
		var textFormatList:Array = [];
		static var salesFormat = new TextFormat();
		var dealBubble = new Sprite();
		var masterDealList:Array = [[["L","J"], 4], 
									[["S","Z"], 3],
									[["t","r"], 1],
									[["l","Y"], 4],
									[["5","H"], 6],
									[["T","O"], 4],
									[["U","5"], 7]
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
			for (var i in textList) {
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
			s.graphics.drawRect(300,110,155-3,40+50*(numDeals)-3);
			s.graphics.endFill();
			stage.addChild(s);
		}
		public function prepareDeals() {
			deals = [];
			for (var deal in masterDealList) {
				trace("deal: " + deal);
				
				if ((BlockMerchant.playset.indexOf(masterDealList[deal][0][0]) == -1) &&
					(BlockMerchant.playset.indexOf(masterDealList[deal][0][1]) == -1))
					deals.push(masterDealList[deal]);
			}

			//if ((BlockMerchant.playset.indexOf("L") == -1) &&
				//(BlockMerchant.playset.indexOf("J") == -1))
				//deals.push([["L", "J"], 5]);
				trace("Current deals: " + deals);
		}
		function enterFrame(e:Event){
			var numDeals = 2;
			gold.text = Board.money.toString();
			if((this.visible == true) && (salesDisplayed == false)) {
				trace("displaying sale");
				greeting.text = "Oink! Oink!  Welcome to my block shop!";
				greeting.appendText("\nPress a number key to buy or sell.");
				
				prepareDeals();
				drawDealBubble(dealBubble,deals.length);
				var costText = new TextField();
				costText.defaultTextFormat = salesFormat;
				costText.y = 110;
				costText.x = 415;
				costText.text = "Cost";
				textList.push(costText);
				stage.addChild(costText);
				
				trace(deals.length + " deals");
				trace(deals);
				for (var deal in deals) {
					
					new Deal(deals[deal][0], [], deals[deal][1], deal+1, this); // additions, removals, price, position, shop
				}
				

				//new Deal(["T"], ["H", "Y", "t"], 5, 1, this);
				salesDisplayed = true;
			}
		}

	}
	
}
