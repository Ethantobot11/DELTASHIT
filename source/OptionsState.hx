package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxSave;

class OptionsState extends FlxState
{
	// define our screen elements
	var titleText:FlxText;
	var volumeBar:FlxBar;
	var volumeText:FlxText;
	var volumeAmountText:FlxText;
	var volumeDownButton:FlxButton;
	var DiscordRPCButton:FlxButton;
	var volumeUpButton:FlxButton;
	var clearDataButton:FlxButton;
	var backButton:FlxButton;
	#if android
	public var storageTypes:Array<String> = ["EXTERNAL_DATA", "EXTERNAL", "EXTERNAL_OBB", "EXTERNAL_MEDIA"];
	public var externalPaths:Array<String> = StorageUtil.checkExternalPaths(true);
	final lastStorageType:String = OptionsState.storageType;
	#end

	public static var discordRPC:Bool = true;
	
	#if desktop
	var fullscreenButton:FlxButton;
	#end
	public function new()
	{
		#if android
		storageTypes = storageTypes.concat(externalPaths); //SD Card
		#end
		super();
	}

	override public function create():Void
	{

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("CURRENTLY CHANGING THE FUKING OPTIONS AHHHHHHHHHHHHHHHHHHHHHHHHHHH\nHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH", null);
		#end

		#if android
		loadPrefs();
		#end

		// setup and add our objects to the screen
		titleText = new FlxText(0, 20, 0, "Options", 22);
		titleText.alignment = CENTER;
		titleText.screenCenter(FlxAxes.X);
		add(titleText);

		volumeText = new FlxText(0, titleText.y + titleText.height + 10, 0, "Volume", 8);
		volumeText.alignment = CENTER;
		volumeText.screenCenter(FlxAxes.X);
		add(volumeText);

		// the volume buttons will be smaller than 'default' buttons
		volumeDownButton = new FlxButton(8, volumeText.y + volumeText.height + 2, "-",
			clickVolumeDown);
		volumeDownButton.loadGraphic(AssetPaths.button__png, true, 20, 20);
		volumeDownButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(volumeDownButton);

		volumeUpButton = new FlxButton(FlxG.width - 28, volumeDownButton.y, "+", clickVolumeUp);
		volumeUpButton.loadGraphic(AssetPaths.button__png, true, 20, 20);
		volumeUpButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(volumeUpButton);

		volumeBar = new FlxBar(volumeDownButton.x + volumeDownButton.width + 4,
			volumeDownButton.y, LEFT_TO_RIGHT, Std.int(FlxG.width - 64),
			Std.int(volumeUpButton.height));
		volumeBar.createFilledBar(0xff464646, FlxColor.WHITE, true, FlxColor.WHITE);
		add(volumeBar);

		volumeAmountText = new FlxText(0, 0, 200, (FlxG.sound.volume * 100) + "%", 8);
		volumeAmountText.alignment = CENTER;
		volumeAmountText.borderStyle = FlxTextBorderStyle.OUTLINE;
		volumeAmountText.borderColor = 0xff464646;
		volumeAmountText.y = volumeBar.y + (volumeBar.height / 2) - (volumeAmountText.height / 2);
		volumeAmountText.screenCenter(FlxAxes.X);
		add(volumeAmountText);

		#if desktop
		fullscreenButton = new FlxButton(0, volumeBar.y + volumeBar.height + 8,
			FlxG.fullscreen ? "FULLSCREEN" : "WINDOWED", clickFullscreen);
		fullscreenButton.screenCenter(FlxAxes.X);
		add(fullscreenButton);
		#end

		DiscordRPCButton = new FlxButton(0, volumeBar.y + volumeBar.height + 24,
			discordRPC ? "TRUE" : "FALSE", ClickDiscordRPCButton);
		DiscordRPCButton.screenCenter(FlxAxes.X);
		add(DiscordRPCButton);

		#if android
		androidButton = new FlxButton(0, volumeBar.y + volumeBar.height + 32,
			lastStorageType ? "STORAGE" : (storageTypes) , androidButtonClick);
		androidButton.screenCenter(FlxAxes.X);
		add(androidButton);
		#end

		clearDataButton = new FlxButton((FlxG.width / 2) - 90, FlxG.height - 28, "Clear Data",
			clickClearData);
		clearDataButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(clearDataButton);

		backButton = new FlxButton((FlxG.width / 2) + 10, FlxG.height - 28, "Back", clickBack);
		backButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(backButton);

		// update our bar to show the current volume level
		updateVolume();

		FlxG.camera.fade(FlxColor.BLACK, 0.33, true);

		super.create();
	}

	public static function saveSettings() {
	#if android
	FlxG.save.data.storageType = lastStorageType;
	#end
	FlxG.save.data.discordRPC = discordRPC;
	}

	public static function loadPrefs() {
	#if android
	if(FlxG.save.data.storageType != null)
        lastStorageType = FlxG.save.data.storageType;
	#end
	if(FlxG.save.data.discordRPC != null)
        discordRPC = FlxG.save.data.discordRPC;
	var save = new FlxSave();
	save.bind("Android Storage","TurnBasedRPG");
	}

	#if android
	function onStorageChange():Void
	{
		File.saveContent(lime.system.System.applicationStorageDirectory + 'storagetype.txt', ClientPrefs.storageType);
	}
	#end

	#if desktop
	function clickFullscreen()
	{
		FlxG.fullscreen = !FlxG.fullscreen;
		fullscreenButton.text = FlxG.fullscreen ? "FULLSCREEN" : "WINDOWED";
		FlxG.save.data.fullscreen = FlxG.fullscreen;
	}
	#end

	function ClickDiscordRPCButton()
	{
		discordRPC = !discordRPC;
		DiscordRPCButton.text = discordRPC ? "TRUE" : "FALSE";
		FlxG.save.data.discordRPC = discordRPC;
	}

	#if android
	function androidButtonClick()
	{
		androidButton.text = lastStorageType ? "STORAGE" : (storageTypes);
		lastStorageType = storageTypes;
		FlxG.save.data.lastStorageType = lastStorageType;
	}
	#end

	/**
	 * The user wants to clear the saved data - we just call erase on our save object and then reset the volume to .5
	 */
	function clickClearData()
	{
		FlxG.save.erase();
		FlxG.sound.volume = 0.5;
		updateVolume();
	}

	/**
	 * The user clicked the back button - close our save object, and go back to the MenuState
	 */
	function clickBack()
	{
		FlxG.save.flush();
		FlxG.camera.fade(FlxColor.BLACK, .33, false, function()
		{
			FlxG.switchState(MenuState.new);
		});
		#if android
		saveSettings();
		#end
	}

	/**
	 * The user clicked the down button for volume - we reduce the volume by 10% and update the bar
	 */
	function clickVolumeDown()
	{
		FlxG.sound.volume -= 0.1;
		FlxG.save.data.volume = FlxG.sound.volume;
		updateVolume();
	}

	/**
	 * The user clicked the up button for volume - we increase the volume by 10% and update the bar
	 */
	function clickVolumeUp()
	{
		FlxG.sound.volume += 0.1;
		FlxG.save.data.volume = FlxG.sound.volume;
		updateVolume();
	}

	/**
	 * Whenever we want to show the value of volume, we call this to change the bar and the amount text
	 */
	function updateVolume()
	{
		var volume:Int = Math.round(FlxG.sound.volume * 100);
		volumeBar.value = volume;
		volumeAmountText.text = volume + "%";
	}
}
