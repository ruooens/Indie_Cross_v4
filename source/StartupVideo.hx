package;

import flixel.FlxG;
import openfl.utils.Assets;

#if VIDEOS_ALLOWED
import FlxVideo;
#end

class StartupVideo extends FlxState {
    public function new() {
        startVideo();
    }

    function startVideo() {
        if(Assets.exists(Paths.video('intro'))) {
            // inCutscene = true;
            var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
            bg.scrollFactor.set();
            // bg.cameras = [camHUD];
            add(bg);

            (new FlxVideo(Paths.video('intro'))).finishCallback = function() {
                remove(bg);
                FlxG.switchState(new TitleState());
            }
            return;
        } else {
            FlxG.log.warn('Couldnt find video file: ' + fileName);
            FlxG.switchState(new TitleState());
        }
    }
}