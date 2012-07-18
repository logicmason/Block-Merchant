package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	public class TempText extends MovieClip {

		public function TempText() {
			addEventListener("enterFrame", enterFrame);
		}
		function enterFrame(e:Event){
			this.alpha -= 0.02;
			if(this.alpha < 0){
				removeEventListener("enterFrame", enterFrame);
				parent.removeChild(this);
			}
		}
	}
	
}
