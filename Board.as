package  {
	
	public class Board {
		static const width:int = 15;
		static const height:int = 15;
		static const gridSize:int = 20;
		static const top:int = 100;
		static const bottom:int = top+height*gridSize;
		static var slots:Array = new Array();

		public function Board() {
			// constructor code
			initialize();
			traceBoard();
		}
		
		public function initialize(){
			for (var i=0; i<height; i++) {
				slots[i] = new Array();
				for (var j=0; j<width; j++) {
					slots[i][j] = 0;
				}
			}
		}
		
		function traceBoard() {
			for (var r in slots) {
				trace("Row "+r+": " + slots[r]);
			}
		}

	}
	
}
