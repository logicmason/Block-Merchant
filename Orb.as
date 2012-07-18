package  {
	
	import flash.display.MovieClip;
	
	
	public class Orb extends MovieClip {
		
		
		public function Orb() {
			// constructor code
		}
		
		function destroy () {
			if (this.parent) this.parent.removeChild(this);
		}
	}
	
}
