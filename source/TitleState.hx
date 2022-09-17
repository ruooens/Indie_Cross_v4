package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.utils.Assets;
import flash.display.BlendMode;

using StringTools;

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	var bg:FlxSprite;
	var logoBl:FlxSprite;
	var playBttn:FlxSprite;
	var bfSpr:FlxSprite;

	var blackOverlay:FlxSprite;

	var resizeConstant:Float = 1.196;

	var seenVideo = false;

	override public function create():Void
	{
		#if MODS_ALLOWED
		// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		if (FileSystem.exists("modsList.txt")){
			
			var list:Array<String> = CoolUtil.listFromString(File.getContent("modsList.txt"));
			var foundTheTop = false;
			for (i in list){
				var dat = i.split("|");
				if (dat[1] == "1" && !foundTheTop){
					foundTheTop = true;
					Paths.currentModDirectory = dat[0];
				}
				
			}
		}
		#end

        // indie cross
		bg = new FlxSprite();
		bg.frames = Paths.getSparrowAtlas('title/Bg');
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.animation.addByPrefix('idle', 'ddddd instance 1', 24, false);
		bg.animation.play('idle', true);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		var cupCircle:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('title/CupCircle', 'preload'));
		cupCircle.setGraphicSize(Std.int(cupCircle.width / resizeConstant));
		cupCircle.antialiasing = ClientPrefs.globalAntialiasing;
		cupCircle.blend = BlendMode.ADD;
		cupCircle.updateHitbox();
		cupCircle.screenCenter();
		cupCircle.x -= 300;
		add(cupCircle);

		FlxTween.angle(cupCircle, 0, 360, 10, {type: LOOPING});

		var sansCircle:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('title/SansCircle', 'preload'));
		sansCircle.setGraphicSize(Std.int(sansCircle.width / resizeConstant));
		sansCircle.antialiasing = ClientPrefs.globalAntialiasing;
		sansCircle.blend = BlendMode.ADD;
		sansCircle.updateHitbox();
		sansCircle.screenCenter();
		sansCircle.y -= 170;
		add(sansCircle);

		FlxTween.angle(sansCircle, 0, -360, 6, {type: LOOPING});

		var bendyCircle:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('title/BendyCircle', 'preload'));
		bendyCircle.setGraphicSize(Std.int(bendyCircle.width / resizeConstant));
		bendyCircle.antialiasing = ClientPrefs.globalAntialiasing;
		bendyCircle.blend = BlendMode.ADD;
		bendyCircle.updateHitbox();
		bendyCircle.screenCenter();
		bendyCircle.x += 300;
		add(bendyCircle);

		FlxTween.angle(bendyCircle, 0, 360, 8, {type: LOOPING});

		logoBl = new FlxSprite();
		logoBl.frames = Paths.getSparrowAtlas('title/Logo');
		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.animation.addByPrefix('bump', 'Tween 11 instance 1', 24, false);
		logoBl.animation.play('bump');
		logoBl.setGraphicSize(Std.int(logoBl.width / resizeConstant));
		logoBl.updateHitbox();
		logoBl.screenCenter();
		logoBl.x -= 285;
		logoBl.y -= 25;
		logoBl.blend = BlendMode.ADD;
		add(logoBl);

		playBttn = new FlxSprite(660, 570);
		playBttn.frames = Paths.getSparrowAtlas('title/Playbutton');
		playBttn.animation.addByPrefix('idle', 'Button instance 1', 24, true);
		playBttn.animation.play('idle', true);
		playBttn.setGraphicSize(Std.int(playBttn.width / 1.1));
		playBttn.antialiasing = ClientPrefs.globalAntialiasing;
		playBttn.blend = BlendMode.ADD;
		add(playBttn);

		var playText:FlxSprite = new FlxSprite(playBttn.x + 50, playBttn.y + 10).loadGraphic(Paths.image('title/PlayText'));
		playText.setGraphicSize(Std.int(playText.width / 1.1));
		playText.antialiasing = ClientPrefs.globalAntialiasing;
		add(playText);

		bfSpr = new FlxSprite(690, 180);
		bfSpr.frames = Paths.getSparrowAtlas('title/BF');
		bfSpr.animation.addByPrefix('idle', 'BF idle dance instance 1', 24, false);
		bfSpr.animation.play('idle', true);
		bfSpr.antialiasing = ClientPrefs.globalAntialiasing;
		bfSpr.blend = BlendMode.ADD;
		add(bfSpr);

		blackOverlay = new FlxSprite().makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		blackOverlay.updateHitbox();
		blackOverlay.screenCenter();
		blackOverlay.scrollFactor.set();
		add(blackOverlay);

		// end of indie cross shit				

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();

		// DEBUG BULLSHIT

		swagShader = new ColorSwap();
		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');
		ClientPrefs.loadPrefs();

		Highscore.load();

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
			#if desktop
			DiscordClient.initialize();
			Application.current.onExit.add (function (exitCode) {
				DiscordClient.shutdown();
			});
			#end
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				if (!seenVideo){
					FlxG.switchState(new StartupVideo());
				}
				else startIntro();
			});
		}
	}

	var swagShader:ColorSwap = null;

	function startIntro()
	{
		if(FlxG.sound.music == null) {
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}
		FlxG.camera.flash(FlxColor.BLACK, 2);

		Conductor.changeBPM(117);
		persistentUpdate = true;
		remove(blackOverlay);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		if (controls.ACCEPT || (FlxG.mouse.justPressed && Main.focused))
		{
			accept();
		}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function accept()
	{
		flash(FlxColor.WHITE, 1);
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			MusicBeatState.switchState(new MainMenuState());
		});
	}

	function flash(color:FlxColor, duration:Float)
	{
		FlxG.camera.stopFX();
		FlxG.camera.flash(color, duration);
	}

	override function beatHit()
	{
		super.beatHit();

		if (bg != null)
		{
			bg.animation.play('idle', true);
		}
		if (logoBl != null)
		{
			logoBl.animation.play('bump', true);
		}
		if (bfSpr != null)
		{
			bfSpr.animation.play('idle', true);
		}
	}
}
