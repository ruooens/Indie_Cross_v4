package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
// import Shaders.WhiteOverlayShader;
import flixel.util.FlxTimer;
import openfl.Lib;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = ' 0.5'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	var disableInput:Bool = false;

	public static final daScaling:Float = 0.675;
	var menuPosTweens:Array<FlxTween>;
	static final buttonRevealRange:Float = 50;
	static final menuItemTweenOptions:TweenOptions = {ease: FlxEase.circOut};

	// both from project.xml
	final name:String = Lib.application.meta["name"];
	final version:String = Lib.application.meta["version"];
	
	var menuStrings:Array<String> = [
		'storymode',
		'freeplay',
		#if MODS_ALLOWED 'mods', #end
		#if ACHIEVEMENTS_ALLOWED 'achievements', #end
		'credits',
		'options'
	];
	var debugKeys:Array<FlxKey>;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		WeekData.setDirectoryFromWeek();
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/BG', 'preload'));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/LOGO', 'preload'));
		logo.origin.set();
		logo.scale.set(daScaling, daScaling);
		logo.updateHitbox();
		logo.antialiasing = ClientPrefs.globalAntialiasing;
		add(logo);

		var sketch:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menu/sketch", "preload"), true, 1144, 940);
		sketch.animation.add("default", [0, 1, 2], 5, true);
		sketch.animation.play("default");
		sketch.origin.set();
		sketch.scale.set(daScaling, daScaling);
		sketch.updateHitbox();
		sketch.setPosition(1280 - sketch.width, 720 - sketch.height);
		sketch.antialiasing = ClientPrefs.globalAntialiasing;
		add(sketch);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;

		for (i in 0...menuStrings.length)
		{
			var offset:Float = 108 - (Math.max(menuStrings.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + menuStrings[i]);
			menuItem.animation.addByPrefix('idle', menuStrings[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', menuStrings[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (menuStrings.length - 4) * 0.135;
			if(menuStrings.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}

		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, name + version, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		changeItem();
		generateButtons(270, 100);

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!disableInput)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				disableInput = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				enterSelection();
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				disableInput = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		if (huh != curSelected)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		if (huh < 0)
			huh = menuStrings.length - 1;
		if (huh >= menuStrings.length)
			huh = 0;

		for (i in 0...menuStrings.length)
		{
			var str:String = menuStrings[i];
			var menuItem:FlxSprite = menuItems.members[i];
			if (i == huh)
			{
				menuItem.alpha = 1.0;
				for (j in menuPosTweens){
					if (j != null)
					{
						j.cancel();
						// j = [];
						j = null;
					}
				}
				if (str == "achievements")
					menuPosTweens[i] = FlxTween.tween(menuItem, {x: 1280 - menuItem.width}, 0.2, menuItemTweenOptions);
				else
					menuPosTweens[i] = FlxTween.tween(menuItem, {x: 0}, 0.2, menuItemTweenOptions);
			}
			else
			{
				if (menuItem.alpha == 1.0)
				{
					for (j in menuPosTweens){
						if (j != null)
						{
							j.cancel();
							// j = [];
							j = null;
						}
					}
				}
				
				if (str == "achievements")
					menuPosTweens[i] = FlxTween.tween(menuItem, {x: 1280 - menuItem.width + buttonRevealRange}, 0.35, menuItemTweenOptions);
				else
					menuPosTweens[i] = FlxTween.tween(menuItem, {x: -buttonRevealRange}, 0.35, menuItemTweenOptions);
				
				menuItem.alpha = 0.5;
			}
		}

		curSelected = huh;
	}

	function generateButtons(yPos:Float, sep:Float)
	{
		if (menuItems == null)
			return;

		if (menuItems.members != null && menuItems.members.length > 0)
			menuItems.forEach(function(_:FlxSprite) {menuItems.remove(_); _.destroy(); } );

		menuPosTweens = new Array<FlxTween>();
		
		for (i in 0...menuStrings.length)
		{
			menuPosTweens.push(null);
			
			var str:String = menuStrings[i];

			var menuItem:FlxSprite = new FlxSprite()
				.loadGraphic(Paths.image("menu/buttons/" + str, "preload"));
			menuItem.origin.set();
			menuItem.scale.set(daScaling, daScaling);
			menuItem.updateHitbox();
			menuItem.alpha = 0.5;

			// menuItem.shader = new WhiteOverlayShader();

			if (str == "achievements")
			{
				menuItem.setPosition(1280 - menuItem.width + buttonRevealRange, 630);
			}
			else
			{
				menuItem.setPosition(-buttonRevealRange, yPos + (i * sep));
			}
			
			menuItems.add(menuItem);
		}
	}

	function enterSelection()
	{
		disableInput = true;
		
		var str:String = menuStrings[curSelected];
		var menuItem:FlxSprite = menuItems.members[curSelected];

		if (menuPosTweens[curSelected] != null)
			menuPosTweens[curSelected].cancel();
		if (str == "achievements")
		{
			menuItem.x = 1280 - menuItem.width + buttonRevealRange;
			menuPosTweens[curSelected] = FlxTween.tween(menuItem, {x: 1280 - menuItem.width}, 0.4, menuItemTweenOptions);
		}
		else
		{
			menuItem.x = -buttonRevealRange;
			menuPosTweens[curSelected] = FlxTween.tween(menuItem, {x: 0}, 0.4, menuItemTweenOptions);
		}

		// menuItem.shader.data.progress.value = [1.0];
		// FlxTween.num(1.0, 0.0, 1.0, {ease: FlxEase.cubeOut}, function(num:Float)
		// {
		// 	menuItem.shader.data.progress.value = [num];
		// });

		for (i in 0...menuItems.members.length)
		{
			if (i != curSelected)
			{
				FlxTween.tween(menuItems.members[i], {alpha: 0}, 1, {ease: FlxEase.cubeOut});
			}
		}

		if (str == 'options')
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.fadeOut(1, 0);
			}
		}
		
		FlxG.sound.play(Paths.sound('confirmMenu'));

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			switch (str)
			{
				case "storymode":
					MusicBeatState.switchState(new StoryMenuState());
				case "freeplay":
					MusicBeatState.switchState(new FreeplayState());
				case "options":
					// FlxG.sound.music.stop();
					MusicBeatState.switchState(new options.OptionsState());
				case "credits":
					MusicBeatState.switchState(new CreditsState());
				case "achievements":
					MusicBeatState.switchState(new AchievementsMenuState());
			}
		});
	}
}
