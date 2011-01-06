package  {
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.ui.Keyboard;
	
	public class Block extends Sprite {
		static const size:int = Board.gridSize;
		static var list:Array = [];
		var edge_color:int;
		var inner_color:int;
		var shape:Array;
		var type:String;
		var _gy:int; // the y position in grid squares rather than pixels
		var _gx:int; // the x position in grid squares rather than pixels
		var _gwidth;
		var _gheight;
		var gravity:Number = 3;
		var dropspeed:Number = 20;
		var mvspd:Number;
		var dropspd:Number;
		var lastx:int; //x magnitude of previous movement
		var xspd:int = 5;
		var movingto:int = -1;  //carful, 0 is a grid destination, -1 means nowhere
		
		public function Block(... rest) { // rest[0] is block type
			// constructor code
			type = rest[0];
			switch (rest[0]){
				case "single": 
					shape = [[0,0]];
					make_shape(0x3333ff, 0x0000ff, shape);
					break;
				case "r":	
					shape = [[0,0], [0,1], [1,1]];
					make_shape(0x666666, 0x333333, shape);
					break;
				case "T":	
					shape = [[0,0], [1,0], [2,0], [1,1]];
					make_shape(0x999999, 0x666666, shape);
					break;
				case "Z":	
					shape = [[0,0], [0,1], [1,1], [1,2]];
					make_shape(0x33ff33, 0x00ff00, shape);
					break;
				case "S":	
					shape = [[0,1], [1,0], [1,1], [0,2]];
					make_shape(0x3333ff, 0x0000ff, shape);
					break;
				case "L":	
					shape = [[0,0], [0,1], [0,2], [1,2]];
					make_shape(0xcc9933, 0x996600, shape);
					break;
				case "J":
					shape = [[1,0], [1,1], [0,2], [1,2]];
					make_shape(0x999933, 0x666600, shape);
					break;
				case "l":
					shape = [[0,0], [0,1], [0,2], [0,3]];
					make_shape(0xff3333, 0xff0000, shape);
					break;
				case "O":
					shape = [[0,0], [0,1], [1,0], [1,1]];
					make_shape(0x993399, 0x660066, shape);
					break;
				case "U":
					shape = [[0,0], [2,0], [0,1], [2,1], [0,2], [1,2], [2,2]];
					make_shape(0x339999, 0x006666, shape);
					break;
				case "I":
					shape = [[0,0], [2,0], [0,1], [1,1], [2,1], [0,2], [2,2]];
					make_shape(0xcc3399, 0x990066, shape);
					break;
				case "t":
					shape = [[1,0], [0,1], [1,1], [2,1], [1,2]];
					make_shape(0x99cc33, 0x669900, shape);
					break;
				case "Y":
					shape = [[0,0], [2,0], [0,1], [1,1], [2,1], [1,2]];
					make_shape(0xff0000, 0x800000, shape);
					break;
				case "5":
					shape = [[0,0], [0,1], [0,2], [0,3], [0,4]];
					make_shape(0xfee088, 0xFDD017, shape);
					break;
			}//switch
			addEventListener("enterFrame", move);
			list.push(this);
		} // constructor
		
		function get gy():int {
			return ((this.y-Board.top+size/2)/ size);
		}
		function set gy(gy:int):void {
			this.y = gy * size + Board.top;
		}
		function get gx():int {
			return ((this.x+size/2)/ size);
		}
		function set gx(gx:int):void {
			this.x = gx * size;
		}
		function get gwidth():int { //witdh of a piece in grid squares
			var biggestx = 0;
			for (var coord in shape) {
				if (shape[coord][0] > biggestx) biggestx = shape[coord][0];
			}
			return biggestx + 1; //since the shape array starts at zero
		}
		function get gheight():int { //witdh of a piece in grid squares
			var biggesty = 0;
			for (var coord in shape) {
				if (shape[coord][1] > biggesty) biggesty = shape[coord][1];
			}
			return biggesty + 1; //since the shape array starts at zero
		}
		
		function square(edge_color:int, inner_color:int, xoff:int, yoff:int) {
			this.graphics.lineStyle(2,edge_color);
			this.graphics.beginFill(inner_color);
			this.graphics.drawRect(size*xoff,size*yoff,size-2,size-2);
			this.graphics.endFill();
		}
		
		function make_shape(edge_color:int, inner_color:int, shape:Array) {
			for (var coord in shape) {
				square(edge_color, inner_color, shape[coord][0], shape[coord][1]);
			}
		}
		
		function move(e:Event){
			if (this != BlockMerchant.current) trace ("Oh noes, you forgot to remove a listener!");
			
			//keyboard input
			if((Key.isDown(Keyboard.DOWN) || Key.isDown(83))){
				this.y += dropspeed;
			} else {
				this.y = this.y + gravity;
			}
			//check for completed left-right moves
			if(movingto >= 0) {// it's moving
				
				// it's there within an acceptable margin
			    if ((Math.abs(x - movingto*size) <= xspd/2)){ 
					trace("x: " + x + "   movingto: " + movingto + "   size: "+size+"   xspd/2: "+xspd/2);
					trace("x - movingto*size: " + (x- movingto*size));
					gx = movingto;
					movingto = -1
				}
				else { //keep moving
					this.x += lastx;
				}
			}
			
			if(this.gx+this.gwidth < Board.width && Key.isDown(Keyboard.RIGHT) || Key.isDown(68)) {
				if(gridhit(this,1,0)) {
					movingto = -1;
					this.gx = this.gx;
				} else {
					if (movingto >= 0) this.x -= lastx; //undo auto move since user is entering another
					this.x += xspd
					lastx = xspd;
					movingto = gx+1;
				 }
			}
			if(this.x > 0 && Key.isDown(Keyboard.LEFT) || Key.isDown(65)) {
				if(gridhit(this,-1,0)) {
					movingto = -1;
					this.gx = this.gx;
				} else {
					this.x -= xspd;
					lastx = xspd * -1;
					movingto = gx-1;
				}
			}
			
			
			
			
			// see if movement caused a hit, if so undo it
			if (gridhit(this,0,0)) {
				this.gx -= xspd / ((xspd*xspd)/xspd);
			}
			
			
			//do gravity and dropping
			if (this.gy+this.gheight >= Board.height) {
				this.y = Board.bottom-this.height;
				trace("hit bottom")
				solidify();
				newBlock();
				return;
			}
			if(gridhit(this,0,1)) {
				trace("calling solidify at gy = "+gy);
				solidify();
				if (gy > 0) {
					newBlock();
					trace("completed newBlock " + Block.list.length);
				}
				else {
					BlockMerchant.gameOver();
				}
			}
		}
		
		public function newBlock() {
			if (BlockMerchant.current == null) {
				var p = BlockMerchant.playset;
				var b = new Block(p[Math.floor(Math.random()*p.length)]);
				stage.addChild(b);
				b.gx = 7;
				b.gy = 0;
				BlockMerchant.current = b;
				if(gridhit(b,0,0)) {
					b.kill();
				} 
				} else {
					trace("ERROR: already have a current block");
					trace("Current Block trace: " + BlockMerchant.current);
			}

		}
		
		public function kill() { // only for game ending block
			solidify();
			//removeEventListener("enterFrame", move); //is in solidify
			BlockMerchant.gameOver();
			trace("block killed");
		}
		
		function destroy() {
			removeEventListener("enterFrame", move);
			for(var i in list){
				if(list[i] == this){
					delete list[i];
				}
			}
			stage.removeChild(this);
		}
		
		public function gridhit(block, dx, dy):Boolean { // grid-based collision detection
			for each (var coord in block.shape) {
				trace("check cooord: " + (block.gy+coord[1]+dy));
				if (Board.slots[block.gy+coord[1]+dy][block.gx+coord[0]+dx] == 1) {
					//trace("gridhit at " + (block.gx+coord[0])+", "+(block.gy+coord[1]));
					//trace("type: " + type+ "    coords: " + coord);
					return true;
				}
				else {
					//trace("no hit at " + (block.gx+coord[0])+", "+(block.gy+coord[1]));
					//trace("coords: " + coord);
				}
			}
			//trace("no grid hit");
			return false;
		}
		public function solidify() {
			removeEventListener("enterFrame", move);
			if ((movingto >= 0) && !gridhit(this,movingto-gx,0)) gx = movingto;
			else gx = gx; //make sure the block is aligned nicely into its grid
			gy = gy;
			BlockMerchant.current = null;
			for each (var coord in shape) {
				if (gy+coord[1] >= 0) Board.slots[gy+coord[1]][gx+coord[0]] = 1; //if it's not off the top of the board, mark it
			}
		}
	}
	
}
