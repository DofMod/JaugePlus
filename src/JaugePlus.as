package
{
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2enums.StrataEnum;
	import d2hooks.GameStart;
	import flash.display.Sprite;
	import ui.JaugeUi;
	
	/**
	 * Main class of the module.
	 * 
	 * @author LeChatLeon
	 */
	public class JaugePlus extends Sprite
	{
		//::///////////////////////////////////////////////////////////
		//::// Variables
		//::///////////////////////////////////////////////////////////
		
		// Include UIs
		private const includeUI:Array = [JaugeUi];
		
		// APIs
		public var sysApi:SystemApi;
		public var uiApi:UiApi;
		
		// Some constants
		private const UI_NAME:String = "jaugeplus";
		private const UI_INSTANCE_NAME:String = "jauneplus";
		
		//::///////////////////////////////////////////////////////////
		//::// Public methods
		//::///////////////////////////////////////////////////////////
		
		public function main():void
		{
			sysApi.addHook(GameStart, onGameStart);
		}
		
		//::///////////////////////////////////////////////////////////
		//::// Events
		//::///////////////////////////////////////////////////////////
		
		/**
		 * Hook reporting the start of the game, after the character selection.
		 */
		private function onGameStart():void
		{
			if (!uiApi.getUi(UI_INSTANCE_NAME))
			{
				uiApi.loadUi(UI_NAME, UI_INSTANCE_NAME, null, StrataEnum.STRATA_HIGH);
			}
		}
	}
}
