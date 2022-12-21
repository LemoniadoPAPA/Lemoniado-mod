package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.addons.text.FlxTypeText;
import flixel.util.FlxTimer;
import flixel.text.FlxText;

using StringTools;

class GalleryState extends MusicBeatState
{
	var curSelected:Int = 0;
	
	var imagenes:Array<String> = [];

	var bg:FlxSprite;
    var imagen:FlxSprite;
	var descripcion:FlxTypeText;
	var descBox:FlxSprite;
	var text:FlxText;
	var texNum:FlxText;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var space:Bool = FlxG.keys.justPressed.ENTER;

	override function create()
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		bgColor = 0xFF79019E;

		var bg:FlxSprite = new FlxSprite();
		/*bg.loadGraphic(Paths.image('menuBG'));*/
		bg.makeGraphic(FlxG.width, FlxG.height,FlxColor.BLACK);
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		imagenes = CoolUtil.coolTextFile(Paths.getLibraryPath('images/GalleryImages/Desc.txt'));

		imagen = new FlxSprite();
		imagen.loadGraphic(Paths.image('GalleryImages/' + curSelected));
		imagen.x= FlxG.width/2 - imagen.width/2;
		imagen.y= FlxG.height/2 - imagen.height/2;
		imagen.antialiasing = ClientPrefs.globalAntialiasing;
		add(imagen);
		
		texNum = new FlxText(0,5);
		texNum.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER,FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(texNum);

		text = new FlxText(0, FlxG.height - 26,FlxG.width,'Presiona CTRL para ver la descripción');
		text.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER,FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(text);

		descripcion = new FlxTypeText(0, 620, Std.int(FlxG.width * 1), "");
		descripcion.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER,FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descripcion.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(descripcion);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');

		leftArrow = new FlxSprite(5);
		leftArrow.y = FlxG.height/2 - 50;
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		add(leftArrow);

		rightArrow = new FlxSprite(FlxG.width - leftArrow.width-5, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		add(rightArrow);

		changeItem();
		
		super.create();
	}

	override function update(elapsed:Float)
	{

		if (controls.UI_RIGHT)
			rightArrow.animation.play('press')
		else
			rightArrow.animation.play('idle');

		if (controls.UI_LEFT)
			leftArrow.animation.play('press');
		else
			leftArrow.animation.play('idle');

        if (controls.UI_LEFT_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeItem(-1);
			constante();
		}
			
		if (controls.UI_RIGHT_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeItem(1);
			constante();
		}
		
		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if(FlxG.keys.justPressed.CONTROL){
			text.visible = false;
			descripcion.revive();
			descripcion.resetText(imagenes[curSelected]);
			descripcion.start(0.04, true);
		}

		texNum.text = curSelected +'/'+ imagenes.length;
		texNum.x=FlxG.width -10- texNum.width;

		imagen.x= FlxG.width/2 - imagen.width/2;
		imagen.y= FlxG.height/2 - imagen.height/2;

		super.update(elapsed);
	}
    
    function constante() {

		FlxTween.tween(imagen,{"scale.x":0,"scale.y":0},0.2,{type: ONESHOT,
			onComplete: function(twn:FlxTween)
			{
				imagen.loadGraphic(Paths.image('GalleryImages/' + curSelected));
				FlxTween.tween(imagen,{"scale.x":1,"scale.y":1},0.2,{type: ONESHOT});
			}
		});	
	}
	
	function changeItem(huh:Int = 0)
	{
		curSelected += huh;
		if (curSelected >= imagenes.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = imagenes.length - 1;

		descripcion.kill();
		text.visible = true;
	}
	
}
