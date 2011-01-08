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
		var _gwidth:int;
		var _gheight:int;
		var _id:int; // the block's position in Block.list
		var gravity:Number = 2;
		var gravityCounter:Number = 0;
		var dropSpeed:Number = 40;
		var moveSpeed:Number = 15;
		var moveLimiter:Number = 0;
		var lastx:int; //x magnitude of previous movement
		var xspd:int = 5;
		
		public function Block(... rest) { // rest[0] is block type
			// constructor code
			type = rest[0];
			switch (rest[0]){
				case "single": 
					shape = [[0,0]];
					make_shape(0x3333ff, 0x0000ff, shape);
					break;
				case "r":	
					shape = [[2,1], [2,2], [3,2]];
					make_shape(0x666666, 0x333333, shape);
					break;
				case "T":	
					edge_color = 0x999999;
					inner_color = 0x666666;
					shape = [[1,2], [2,2], [3,2], [2,3]];
					make_shape(edge_color, inner_color, shape);
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
					edge_color = 0xcc9933;
					inner_color = 0x996600;
					shape = [[2,1], [2,2], [2,3], [3,3]];
					make_shape(edge_color, inner_color, shape);
					break;
				case "J":
					edge_color = 0x999933;
					inner_color = 0x666600;
					shape = [[2,1], [2,2], [1,3], [2,3]];
					make_shape(edge_color, inner_color, shape);
					break;
				case "l":
					edge_color = 0xff3333;
					inner_color = 0xff0000;
					shape = [[2,0], [2,1], [2,2], [2,3]];
					make_shape(edge_color, inner_color, shape);
					break;
				case "O":
					edge_color = 0x993399;
					inner_color = 0x660066;
					shape = [[1,1], [1,2], [2,1], [2,2]];
					make_shape(edge_color, inner_color, shape);
					break;
				case "U":
					edge_color = 0x339999;
					inner_color = 0x006666;
					shape = [[1,1], [3,1], [1,2], [3,2], [1,3], [2,3], [3,3]];
					make_shape(edge_color, inner_color, shape);
					break;
				case "H":
					edge_color = 0xcc3399;
					inner_color = 0x990066;
					shape = [[1,1], [3,1], [1,2], [2,2], [3,2], [1,3], [3,3]];
					make_shape(edge_color, inner_color, shape);
					break;
				case "t":
					edge_color = 0x99cc33;
					inner_color = 0x669900;
					shape = [[2,1], [1,2], [2,2], [3,2], [2,3]];
					make_shape(edge_color, inner_color, shape);
					break;
				case "Y":
					edge_color = 0xff0000;
					inner_color = 0x800000;
					shape = [[0,0], [2,0], [0,1], [1,1], [2,1], [1,2]];
					make_shape(edge_color, inner_color, shape);
					break;
				case "5":
					edge_color = 0xfee088;
					inner_color = 0xFDD017;
					shape = [[2,0], [2,1], [2,2], [2,3], [2,4]];
					make_shape(edge_color, inner_color, shape);
					break;
			}//switch
			//addEventListener("enterFrame", move);
			list.push(this);
		} // constructor
		
		function get id():int {
			for (var i in Block.list) {
				if (this == Block.list[i]) return i;
			}
			return -1;
		}
		function get gy():int {
			return ((this.y-Board.top)/ size);
		}
		function set gy(gy:int):void {
			this.y = gy * size + Board.top;
		}
		function get gx():int {
			return ((this.x)/ size);
		}
		function set gx(gx:int):void {
			this.x = gx * size;
		}
		
		function get gminx():int { //witdh of a piece in grid squares
			var minx = 9;
			for (var coord in shape) {
				if (shape[coord][0] < minx) minx = shape[coord][0];
			}
			return minx; //since the shape array starts at zero
		}
		function get gmaxx():int { //witdh of a piece in grid squares
			var maxx = 0;
			for (var coord in shape) {
				if (shape[coord][0] > maxx) maxx = shape[coord][0];
			}
			return maxx; //since the shape array starts at zero
		}
		function get gminy():int { //witdh of a piece in grid squares
			var miny = 9;
			for (var coord in shape) {
				if (shape[coord][1] < miny) miny = shape[coord][1];
			}
			return miny; //since the shape array starts at zero
		}
		function get gmaxy():int { //witdh of a piece in grid squares
			var maxy = 0;
			for (var coord in shape) {
				if (shape[coord][1] > maxy) maxy = shape[coord][1];
			}
			return maxy; //since the shape array starts at zero
		}
		function get gwidth():int { //witdh of a piece in grid squares
			return gmaxx + 1; //since the shape array starts at zero
		}
		function get gheight():int {
			return gmaxy+1;
		}
		
		
		function square(edge_color:int, inner_color:int, xoff:int, yoff:int) {
			this.graphics.lineStyle(2,edge_color);
			this.graphics.beginFill(inner_color);
			this.graphics.drawRect(size*xoff,size*yoff,size-2,size-2);
			this.graphics.endFill();
		}
		
		function make_shape(edge_color:int, inner_color:int, shape:Array) {
			this.graphics.clear();
			for (var coord in shape) {
				square(edge_color, inner_color, shape[coord][0], shape[coord][1]);
			}
		}
		
		function decompose() { // splits a block into a new block for each square
			for (var coord in shape) {
				var s = new Block("single");
				s.gx = gx+shape[coord][0];
				s.gy = gy+shape[coord][1];
				stage.addChild(s);
				s.solidify();
				trace((gx+shape[coord][0])+", "+(gy+shape[coord][1]));
			}
			
			newBlock(); // can NOT be called after this.destroy (won't be a reference to the stage)
			this.destroy(); //destroys original block
		}
		function rotate():Array {
			var xoff:int = 2; // every block will rotate around 2,2
			var yoff:int = 2;
			if (type == "O") return shape; //rotation doesn't change this shape
			
			var newshape:Array = new Array;
			
			
			for (var coord in shape) { //use 90 matrix rotation [0 -1]
														//		[1  0]
				newshape[coord] = new Array;
				newshape[coord][0] = (shape[coord][1] - xoff) * -1 + xoff;
				newshape[coord][1] = shape[coord][0];
			}
			return newshape;
		}
		
		function move(e:Event){
			if (this != BlockMerchant.current) {
				trace ("Oh noes, you forgot to remove a listener on block " + this.id);
				if (BlockMerchant.current) trace ("Current block is " + BlockMerchant.current.id);
				else trace("There is no current block!!!111! 8:o");
			}
			//keyboard input
			if((Key.isDown(Keyboard.DOWN) || Key.isDown(83))){
				gravityCounter += dropSpeed;
			} else {
				gravityCounter += gravity;
			}
			if (gravityCounter > dropSpeed) {
				gravityCounter -= dropSpeed;
				this.gy = this.gy + 1;
			}
			
			moveLimiter += moveSpeed;
			if(moveLimiter > 40 && this.gx+this.gwidth < Board.width && Key.isDown(Keyboard.RIGHT) || Key.isDown(68)) {
				if(gridhit(shape,1,0)) {
					
				} else {
					gx = gx+1;
					moveLimiter = 0;
				 }
			}
			if(moveLimiter > 40 && this.gx+this.gminx > 0 && Key.isDown(Keyboard.LEFT) || Key.isDown(65)) {
				if(gridhit(shape,-1,0)) {
					
				} else {
					gx = gx-1;
					moveLimiter = 0;
				}
			}
			if(moveLimiter > 40 && Key.isDown(Keyboard.UP) || Key.isDown(87)) {
				if(gridhit(rotate(),0,0)) {
					trace("OMG!  Rotational grid hit!!!111!!");
					//don't rotate the piece!
				} else {
					shape = rotate();
					trace("rotated: ");
					for (var x in shape) {
						trace(shape[x]);
					}
					make_shape(edge_color, inner_color, shape);
					moveLimiter = 0;
				}
			}
						
			
			//do gravity and dropping
			if (this.gy+this.gheight >= Board.height) {
				this.gy = Board.height-this.gheight;
				trace("hit bottom, calling solidify at gy = "+gy);
				transition();
				return;
			}
			if(gridhit(shape,0,1)) {
				trace("calling solidify at gy = "+gy);		
				if (gy > 0) {
					transition();
				}
				else {
					removeEventListener("enterFrame", move);
					BlockMerchant.gameOver();
				}
			}
			if((moveLimiter > 40 && Key.isDown(Keyboard.SPACE))){
				transition();
				moveLimiter = 0;
			}
		}
		
		public function newBlock() {  //creates a new block of a random type at the top
			
			if (BlockMerchant.current == null) {
				var p = BlockMerchant.playset;
				var b = new Block(p[Math.floor(Math.random()*p.length)]); //random type
				stage.addChild(b);
				b.gx = 7;
				b.gy = 0;
				BlockMerchant.current = b;
				b.addEventListener("enterFrame", b.move);
				
				if(gridhit(b,0,0)) {
					b.kill();
				} 
				} else {
					trace("ERROR: already have a current block");
					trace("Current Block trace: " + BlockMerchant.current);
			}
			trace("completed newBlock " + Block.list.length);

		}
		
		public function kill() { // only for game ending block
			solidify();
			//removeEventListener("enterFrame", move); //is in solidify
			BlockMerchant.gameOver();
			trace("block killed");
		}
		
		function destroy() {
			if (this ==BlockMerchant.current) BlockMerchant.current = null;
			removeEventListener("enterFrame", move);
			for(var i in list){
				if(list[i] == this){
					delete list[i];
				}
			}
			stage.removeChild(this);
		}
		
		public function gridhit(testshape, dx, dy):Boolean { // grid-based collision detection
			for each (var coord in testshape) {
				
				// check to see if part of the piece is off the grid
				if ((gy+coord[1]+dy >= Board.height) || 
					(gy+coord[1]+dy < 0) ||
					(gx+coord[0]+dx >= Board.width) ||
					(gx+coord[0]+dx < 0)) {
					trace("rotational grid hit and stuff");
					return true;
				}
					
				if (Board.slots[gy+coord[1]+dy][gx+coord[0]+dx] == 1) {
					trace("gridhit at " + (gx+coord[0])+", "+(gy+coord[1]));
					trace("type: " + type+ "    coords: " + coord);
					return true;
				}
				else {
					//trace("no hit at " + (block.gx+coord[0])+", "+(block.gy+coord[1]));
				}
			}
			//trace("no grid hit");
			return false;
		}
		public function solidify() {
			removeEventListener("enterFrame", move);
			BlockMerchant.current = null;
			for each (var coord in shape) {
				if (gy+coord[1] >= 0 && (gy+coord[1] < Board.height)) Board.slots[gy+coord[1]][gx+coord[0]] = 1; //if it's not off the top of the board, mark it
			}
			trace("block "+this.id + " solidified");
		}
		public function transition() { 
		//breaks this block into its constituent pieces, updates the board and drops the next block
			for (var coord in shape) {
				var s = new Block("single");
				s.gx = gx+shape[coord][0];
				s.gy = gy+shape[coord][1];
				stage.addChild(s);
				s.removeEventListener("enterFrame", s.move);
				if (s.gy >= 0 && (s.gy < Board.height)) Board.slots[s.gy][s.gx] = 1;
				trace((gx+shape[coord][0])+", "+(gy+shape[coord][1]));
			}
			BlockMerchant.current = null;
			newBlock(); // can NOT be called after this.destroy (won't be a reference to the stage)
			this.destroy(); //destroys original block
		}
	}
	
}
