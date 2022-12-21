package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxGradient;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.display.FlxBackdrop;
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

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.3'; //This is also used for Discord RPC
	public static var lemoniadoModVersion:String = '1.0';
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	//var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 1, 0xBD60C700);
	private var camGame:FlxCamera;
	var personaje:FlxSprite;
	private var camAchievement:FlxCamera;
	var disc:FlxSprite = new FlxSprite(-600, 100);
	var checker:FlxBackdrop; 
	var side:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('Main_Side'));
	var urom:FlxSprite = new FlxSprite(500, 0);
	
	public var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'credits',
		#if !switch 'donate', #end
		'gallery',
		'options'
	];

	var magenta:FlxSprite;
	var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	override function beatHit():Void
		{
		super.beatHit();
		FlxG.camera.zoom += 0.25;
		}

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		if(ClientPrefs.menubg == 'Secundary')
			{
				bg.loadGraphic(Paths.image('menuBG_secun'));
				side.loadGraphic(Paths.image('Main_Side_secun'));
				//checker.visible = true;
				//gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0xBDC70000], 1, 90, true);
			}
		else if(ClientPrefs.menubg == 'Original')
			{
				bg.loadGraphic(Paths.image('menuBG_og'));
				side.loadGraphic(Paths.image('inv'));
				//checker.visible = false;
				//gradientBar.visible = false;
			}	
		else if(ClientPrefs.menubg == 'Classic')
			{
				bg.loadGraphic(Paths.image('menuBG_classic'));
				side.loadGraphic(Paths.image('inv'));
				//checker.visible = false;
				//gradientBar.visible = false;
			}
		else if(ClientPrefs.menubg == 'Normal')
			{
				bg.loadGraphic(Paths.image('menuBG'));
				side.loadGraphic(Paths.image('Main_Side'));
				//checker.visible = true;
				//gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0xBD60C700], 1, 90, true);
			}

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		//add(checker);
		//checker.scrollFactor.set(0, 0.07);

		FlxG.autoPause = false;

		Application.current.window.title = Main.appTitle + ' - ' + 'Menu';

		/*checker = new FlxBackdrop(Paths.image('CheckerHaha'), true); 
		//checker.velocity.set(112, 110); 
		checker.updateHitbox(); 
		checker.scrollFactor.set(0, 0); 
		checker.alpha = 1; 
		checker.screenCenter(X); 
		add(checker); */

		side.scrollFactor.x = 0;
		side.scrollFactor.y = 0;
		side.height = 3;
		side.antialiasing = true;
		add(side);

		/*var tex = Paths.getSparrowAtlas('FreeplayDiscs');
		disc.frames = tex;
		disc.antialiasing = true;
		add(disc);*/

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(75, 55 + (i * 120));
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.setGraphicSize(Std.int(menuItem.width * 0.8));
			menuItem.ID = i;
			menuItem.angle = -6.5;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 5) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();

			/*gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0xBD60C700], 1, 90, true);
			gradientBar.y = FlxG.height - gradientBar.height;
			gradientBar.scale.y = 3;
			gradientBar.updateHitbox();
			add(gradientBar);*/

			var urom:FlxSprite = new FlxSprite(500, 0);
			urom.frames = Paths.getSparrowAtlas('logoBumpin');
			urom.animation.addByPrefix('idle', 'logo bumpin', 24);
			urom.setGraphicSize(Std.int(urom.width * 0.8));
			urom.animation.play('idle');
			urom.scrollFactor.set(0, 0);
			add(urom);
		}

		var versionShit:FlxText = new FlxText(12, FlxG.height - 62, 0, "Lemoniado mod " + lemoniadoModVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.RED);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine  " + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.RED);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.RED);
		add(versionShit);

		FlxG.camera.follow(camFollowPos, null, 1);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

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

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		FlxG.camera.zoom = FlxMath.lerp(1,FlxG.camera.zoom,1 - elapsed * 9);

		/*checker.x = 0;
		checker.y -= 0.16 / (ClientPrefs.framerate / 60);*/

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
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
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
					{
						CoolUtil.browserLoad('https://www.youtube.com/channel/UCmdcI4Ma8ZWDnG10QWlUv8g');
						MusicBeatState.switchState(new MainMenuState());
					}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									case 'gallery':
										MusicBeatState.switchState(new GalleryState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
										FlxG.sound.playMusic(Paths.music('optionsSong'), 0);

								}
							});
						}
					});
				}
			}
			else if (FlxG.keys.justPressed.SEVEN)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			//checker.x -= 0.45 / (ClientPrefs.framerate / 60);
			//checker.y -= 0.16 / (ClientPrefs.framerate / 60);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}
