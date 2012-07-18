package  {
	
	import flash.display.MovieClip;
	
	
	public class Spyglass extends MovieClip {
		
		
		public function Spyglass() {
			// constructor code
		}
		
		function destroy () {
			if (this.parent) this.parent.removeChild(this);
		}
	}
	
}
