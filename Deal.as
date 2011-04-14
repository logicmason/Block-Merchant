package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class Deal extends MovieClip{
		var textList:Array = [];
		static var list:Array = [];
		static var orbCost:int = 20;
		var shop:Shop;
		var placement:int;
		var additions:Array;
		var removals:Array;
		var price:int;
		var special:String;
		var saleText:TextField;
		var costText:TextField;
		var description:TextField;
		var components:Array = [];
		var pressTimer:int = 0;
		
		
		public function Deal(_additions:Array, _removals:Array, _price:int, _special:String, _placement:int, _shop:Shop) {
			// constructor code
			additions = _additions;
			removals = _removals;
			price = _price;
			special = _special;
			shop = _shop;
			placement = _placement;
			shop.parent.addChild(this); //shop.parent is stage
			saleText = new TextField();
			saleText.defaultTextFormat = Shop.salesFormat;
			saleText.x = 310;
			saleText.y = placement*50+87;
			saleText.text = String(placement+")");
			shop.textList.push(saleText);
			stage.addChild(saleText); 
			costText = new TextField();
			costText.defaultTextFormat = Shop.salesFormat;
			costText.x = 425;
			costText.y = saleText.y;
			costText.text = price.toString();
			shop.textList.push(costText);
			stage.addChild(costText);
			
			for (var a in additions) {
				var b = new Block(additions[a]);
				b.makeSpecial(); //so these blocks will be destroyed by clearPlayset() upon leaving shop
				stage.addChild(b);
				b.height *= .5;
				b.width *= .5;
				b.x = 325+ 50*a;
				b.y = 75+placement*50;
				components.push(b);
			}
			
			for (var r in removals) {
				b = new Block(removals[r]);
				b.makeSpecial(); //so these blocks will be destroyed by clearPlayset()
				stage.addChild(b);
				b.height *= .5;
				b.width *= .5;
				b.x = 325+ 50* additions.length+50*r;
				b.y = 75+placement*50;
				components.push(b);
			}
			if ((additions.length == 0) && (removals.length == 0)) { // special purchase
				if (special == "orb") { // orb of time
					//description = new TextField();
					//description.defaultTextFormat = Shop.salesFormat;
					//description.x = 325;
					//description.y = placement*50*87;
					//description.text = String("Orb of Time");
					//shop.textList.push(description);
					//stage.addChild(description);
					
					var o = new Orb();
					stage.addChild(o);
					o.x = 355;
					o.y = 75+placement*50;
					components.push(o);
				}
			}
				
			addEventListener("enterFrame", enterFrame);
		}
		
		function destroy() {
			for (var i = 0; i < components.length; i++){
				components[i].destroy();
				delete components[i];
			}
			removeEventListener("enterFrame", enterFrame);
			//if (this.parent && this.parent == stage) stage.removeChild(this);
			for (i = 0; i < shop.dealList.length; i++) {
				if (this == shop.dealList[i]) {
					delete shop.dealList[i];
				}
			}
		}
		function enterFrame(e:Event) {
			if(shop.visible == false) destroy();
			if (pressTimer > 0) pressTimer -= 1;
			
			if((saleText.visible == true) && pressTimer == 0 && 
			   ((Key.isDown(48+placement)) || (Key.isDown(96+placement)))) { //the number key for this deal
				pressTimer = 30;
				//trace("Doing deal: " + additions + "," + removals+ "," + price +"," + placement);
				if(Board.money < price) {
					shop.greeting.text = "Oink! Oink!  You don't have enough gold for that!";
				}
				else {
					if (BlockMerchant.playset.length + additions.length > 10) {
						shop.greeting.text = "Oink! Oink!  You have too many pieces!";
						return;
					}
					for each (var p in additions) {
						shop.addPiece(p);
					}
					if ((BlockMerchant.playset.length - removals.length <= BlockMerchant.minPlayset) 
						 && removals.length > 0) {
						shop.greeting.text = "Oink! Oink!  You need at least 4 pieces!";
						return;
					}
					for each (p in removals) {
						shop.removePiece(p);
					}
					destroy();
					
					shop.greeting.text = "Oink! Oink!  Thank you for shopping!";
					if (special == "orb") { 
						shop.greeting.text = "Oink!  Oink!  An orb of time!";
						orbCost *= 2;
						if (Block.gravity >3) Block.gravity -= 3;
						else Block.gravity = 1;
					}
					Board.money -= price;
					new KachingSound().play();
					saleText.visible= false;
					costText.visible= false;
					return;
				}
			}
		}
	}
	
}
