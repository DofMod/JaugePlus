package ui
{
	import d2api.ContextMenuApi;
	import d2api.FightApi;
	import d2api.JobsApi;
	import d2api.PlayedCharacterApi;
	import d2api.SocialApi;
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2api.UtilApi;
	import d2components.Texture;
	import d2data.KnownJob;
	import d2enums.ComponentHookList;
	import d2hooks.CharacterLevelUp;
	import d2hooks.ContextChanged;
	import d2hooks.GameFightEnd;
	import d2hooks.GuildLeft;
	import d2hooks.InventoryWeight;
	import d2hooks.JobsExpUpdated;
	import d2hooks.JobsListUpdated;
	import d2hooks.MountSet;
	import d2hooks.MountUnSet;
	import d2hooks.PlayerIsDead;
	import d2hooks.QuestStepValidated;
	import d2network.ActorExtendedAlignmentInformations;
	import d2network.CharacterCharacteristicsInformations;
	import d2network.JobExperience;
	import flash.utils.setTimeout;
	
	/**
	 * @author Le Chat Léon
	 *
	 * La suite de ce code est soumis à la licence Creative Commons Paternité - Pas d'utilisation commerciale - 3.0
	 * http://creativecommons.org/licenses/by-nc/3.0/
	 *
	 * Merci :)
	 **/
	public class JaugeUi
	{
		//::///////////////////////////////////////////////////////////
		//::// Variables
		//::///////////////////////////////////////////////////////////
		
		// Some constants
		private static const ID_XP_CHARACTER:int = 0;
		private static const ID_XP_GUILD:int = 1;
		private static const ID_XP_MOUNT:int = 2;
		private static const ID_HONOUR:int = 3;
		private static const ID_PODS:int = 4;
		private static const ID_ENERGY:int = 5;
		private static const ID_JOB1:int = 6;
		private static const ID_JOB2:int = 7;
		private static const ID_JOB3:int = 8;
		private static const ID_JOB4:int = 9;
		private static const ID_JOB5:int = 10;
		private static const ID_JOB6:int = 11;
		private static const NB_ITEM:int = 11;
		
		private static const ID_PERCENT:int = 0;
		private static const ID_REMAINING:int = 1;
		private static const ID_DONE:int = 2;
		private static const ID_MAXIMUM:int = 3;
		private static const NB_OPTION:int = 3;
		
		private static const SELECTED_GAUGE_ID:String = "selectedGaugeId";
		private static const INFOS_DISPLAYED:String = "infosDisplayed";
		
		private static const XP_GAUGE:uint = 0;
		private static const GUILD_GAUGE:uint = 1;
		private static const MOUNT_GAUGE:uint = 2;
		private static const INCARNATION_GAUGE:uint = 3;
		private static const HONOUR_GAUGE:uint = 4;
		private static const POD_GAUGE:uint = 5;
		private static const JOB_GAUGE:uint = 6;
		private static const NB_GAUGE:uint = 6;
		
		private static const ID_MENU:int = 0;
		private static const ID_SUBMENU:int = 1;
		
		// APIs
		public var sysApi:SystemApi;
		public var uiApi:UiApi;
		public var fightApi:FightApi;
		public var socApi:SocialApi;
		public var metierApi:JobsApi;
		public var outilApi:UtilApi;
		public var persoApi:PlayedCharacterApi;
		public var menuContApi:ContextMenuApi;
		
		// Modules
		[Module(name="Ankama_ContextMenu")]
		public var modContextMenu:Object;
		
		// Components
		public var tx_jauge:Texture;
		
		// Some globals
		private var _selectedGauge:int;
		private var _infosDisplayed:Array = new Array();
		
		//::///////////////////////////////////////////////////////////
		//::// Public methods
		//::///////////////////////////////////////////////////////////
		
		public function main(params:Object):void
		{
			sysApi.log(8, "ui loaded");
			//Délai pour s'assurer du chargement de toutes les API
			setTimeout(init, 500);
		}
		
		//::///////////////////////////////////////////////////////////
		//::// Events
		//::///////////////////////////////////////////////////////////
		
		/**
		 * Hook reporting a right click.
		 * 
		 * @param	target	The target of the right click.
		 */
		public function onRightClick(target:Object):void
		{
			switch(target)
			{
				case tx_jauge:
					modContextMenu.createContextMenu(composeContextMenu());
					
					break;
			}
		}
		
		/**
		 * Hook reporting a roll over.
		 * 
		 * @param	target	The target of the roll over.
		 */
		public function onRollOver(target:Object):void
		{
			switch(target)
			{
				case tx_jauge:
					uiApi.showTooltip(composeTooltip(_selectedGauge), tx_jauge, false);
			}
		}
		
		/**
		 * Hook reporting a roll out.
		 * 
		 * @param	target	The target of the roll out.
		 */
		public function onRollOut(target:Object):void
		{
			uiApi.hideTooltip();
		}
		
		//::///////////////////////////////////////////////////////////
		//::// Private methods
		//::///////////////////////////////////////////////////////////
		
		private function init():void
		{
			//Récupération des préférences : si elles n'existent pas, on en établies par défaut.
			if (sysApi.getData(SELECTED_GAUGE_ID) == null)
			{
				sysApi.setData(SELECTED_GAUGE_ID, 0);
			}
			
			if (sysApi.getData(INFOS_DISPLAYED) == null)
			{
				// [ID_PERCENT, ID_REMAINING, ID_DONE, ID_MAXIMUM]
				_infosDisplayed[ID_XP_CHARACTER]	= [true, true, false, false];
				_infosDisplayed[ID_XP_GUILD]		= [true, true, false, false];
				_infosDisplayed[ID_XP_MOUNT]		= [true, true, false, false];
				
				_infosDisplayed[ID_HONOUR]	= [true, true, false, false];
				_infosDisplayed[ID_PODS]	= [false, true, false, true];
				_infosDisplayed[ID_ENERGY]	= [false, true, false, true];
				
				_infosDisplayed[ID_JOB1] = [true, true, false, false];
				_infosDisplayed[ID_JOB2] = [true, true, false, false];
				_infosDisplayed[ID_JOB3] = [true, true, false, false];
				_infosDisplayed[ID_JOB4] = [true, true, false, false];
				_infosDisplayed[ID_JOB5] = [true, true, false, false];
				_infosDisplayed[ID_JOB6] = [true, true, false, false];
				
				sysApi.setData(INFOS_DISPLAYED, _infosDisplayed);
			}
			else
			{
				_infosDisplayed = sysApi.getData(INFOS_DISPLAYED);
			}
			
			var selectedGaugeId:int = sysApi.getData(SELECTED_GAUGE_ID);
			var selectedGaugeDatas:GaugeData = getGaugeData(selectedGaugeId);
			if (!selectedGaugeDatas.disabled && selectedGaugeDatas.visible)
			{
				_selectedGauge = selectedGaugeId;
			}
			else
			{
				_selectedGauge = 0;
			}
			
			//Hooks résultants d'un changement d'une des information que l'on veut afficher
			sysApi.addHook(GameFightEnd, onHook);
			sysApi.addHook(QuestStepValidated, onHook);
			sysApi.addHook(InventoryWeight, onHook);
			sysApi.addHook(MountSet, onHook);
			sysApi.addHook(CharacterLevelUp, onHook);
			sysApi.addHook(JobsExpUpdated, onHook);
			sysApi.addHook(JobsListUpdated, onHook);
			sysApi.addHook(MountUnSet, onHook);
			sysApi.addHook(PlayerIsDead, onHook);
			sysApi.addHook(GuildLeft, onHook);
			sysApi.addHook(ContextChanged, onHook);
			
			uiApi.addComponentHook(tx_jauge, ComponentHookList.ON_ROLL_OVER);
			uiApi.addComponentHook(tx_jauge, ComponentHookList.ON_ROLL_OUT);
			uiApi.addComponentHook(tx_jauge, "onRightClick");
			
			onHook();
		}
		
		private function composeContextMenu():Array
		{
			//Génération du menu contextuel
			var mainMenu:Array = new Array();
			var paramMenu:Array = new Array();
			
			paramMenu.push(modContextMenu.createContextMenuItemObject("Tooltip courante :", null, null, true, null, false, false));
			paramMenu.push(modContextMenu.createContextMenuSeparatorObject());
			paramMenu.push(modContextMenu.createContextMenuItemObject('Afficher pourcentage',	contextMenuCallback, new Array(ID_SUBMENU, ID_PERCENT),		false, null, _infosDisplayed[_selectedGauge][ID_PERCENT]));
			paramMenu.push(modContextMenu.createContextMenuItemObject('Afficher restant',		contextMenuCallback, new Array(ID_SUBMENU, ID_REMAINING),	false, null, _infosDisplayed[_selectedGauge][ID_REMAINING]));
			paramMenu.push(modContextMenu.createContextMenuItemObject('Afficher effectué',		contextMenuCallback, new Array(ID_SUBMENU, ID_DONE),		false, null, _infosDisplayed[_selectedGauge][ID_DONE]));
			paramMenu.push(modContextMenu.createContextMenuItemObject('Afficher maximum',		contextMenuCallback, new Array(ID_SUBMENU, ID_MAXIMUM),		false, null, _infosDisplayed[_selectedGauge][ID_MAXIMUM]));
			
			mainMenu.push(modContextMenu.createContextMenuItemObject("Paramètres", null, null, false, paramMenu, false));
			mainMenu.push(modContextMenu.createContextMenuSeparatorObject());
			
			var gaugeData:GaugeData;
			for (var gaugeId:int = 0; gaugeId <= NB_ITEM; gaugeId++)
			{
				gaugeData = getGaugeData(gaugeId);
				
				if (gaugeData.visible)
				{
					mainMenu.push(modContextMenu.createContextMenuItemObject(gaugeData.title, contextMenuCallback, new Array(ID_MENU, gaugeId), gaugeData.disabled, null, (gaugeId == _selectedGauge), true, composeTooltip(gaugeId)));
				}
			}
			
			return mainMenu;
		}
		
		private function contextMenuCallback(menuId:int, item:int):void
		{
			if (menuId == ID_MENU)
			{
				sysApi.setData(SELECTED_GAUGE_ID, item);
				
				_selectedGauge = item;
				
				onHook();
			}
			else if (menuId == ID_SUBMENU)
			{
				_infosDisplayed[_selectedGauge][item] = !_infosDisplayed[_selectedGauge][item];
				
				sysApi.setData(INFOS_DISPLAYED, _infosDisplayed);
			}
		}
		
		private function composeTooltip(gaugeId:int):String
		{
			//Génération du tooltip en fonction des préférences
			var gaugeData:GaugeData = getGaugeData(gaugeId);
			var infosDisplayed:Array = _infosDisplayed[gaugeId];
			
			var percentage:String	= Math.floor((gaugeData.current - gaugeData.floor) / (gaugeData.ceil - gaugeData.floor) * 100).toString();
			var remaining:String	= outilApi.kamasToString((gaugeData.ceil - gaugeData.floor) - (gaugeData.current - gaugeData.floor), "");
			var done:String			= outilApi.kamasToString(gaugeData.current - gaugeData.floor, "");
			var maximum:String		= outilApi.kamasToString(gaugeData.ceil - gaugeData.floor, "");
			
			var tooltipText:String = "";
			if (infosDisplayed[ID_PERCENT])
			{
				tooltipText += percentage + "%";
				
				if (infosDisplayed[ID_MAXIMUM] || infosDisplayed[ID_REMAINING] || infosDisplayed[ID_DONE])
				{
					tooltipText += ", ";
				}
			}
			
			if (infosDisplayed[ID_REMAINING])
			{
				tooltipText += remaining + " restant";
				
				if (infosDisplayed[ID_DONE])
				{
					tooltipText += ", ";
				}
				else
				{
					tooltipText += " ";
				}
			}
			
			if (infosDisplayed[ID_DONE])
			{
				if (gaugeId == ID_ENERGY)
				{
					tooltipText = done + " dispo";
				}
				else if (gaugeId == ID_PODS)
				{
					tooltipText += done + " utilisés";
				}
				else if (infosDisplayed[ID_REMAINING])
				{
					tooltipText += done + " effectués";
				}
				
				tooltipText += " ";
			}
			
			if (infosDisplayed[ID_MAXIMUM])
			{
				if (infosDisplayed[ID_PERCENT] || infosDisplayed[ID_REMAINING] || infosDisplayed[ID_DONE])
				{
					tooltipText += "sur " + maximum;
				}
				else
				{
					tooltipText += maximum + " max";
				}
			}
			
			return tooltipText;
		
		}
		
		private function onHook(... arguments:Array):void
		{
			var gaugeData:GaugeData = getGaugeData(_selectedGauge);
			
			displayGauge(gaugeData.floor, gaugeData.current, gaugeData.ceil, gaugeData.gaugeID);
		}
		
		private function getGaugeData(gaugeId:int):GaugeData
		{
			var gaugeData:GaugeData = new GaugeData();
			
			var characteristics:CharacterCharacteristicsInformations = persoApi.characteristics();
			
			switch (gaugeId)
			{
				case ID_XP_CHARACTER:
					
					gaugeData.disabled = false;
					gaugeData.visible = true;
					gaugeData.title= "Xp personnage";
					gaugeData.gaugeID = XP_GAUGE;
					
					gaugeData.current = characteristics.experience;
					gaugeData.floor = characteristics.experienceLevelFloor;
					gaugeData.ceil = characteristics.experienceNextLevelFloor;
					
					break;
				case ID_XP_GUILD:
					
					gaugeData.disabled = !socApi.hasGuild();
					gaugeData.visible = true;
					gaugeData.title = "Xp guilde";
					gaugeData.gaugeID = GUILD_GAUGE;
					
					if (!gaugeData.disabled)
					{
						var guildInfos:Object = socApi.getGuild();
						
						gaugeData.current = guildInfos.experience;
						gaugeData.floor = guildInfos.expLevelFloor;
						gaugeData.ceil = guildInfos.expNextLevelFloor;
					}
					
					break;
				case ID_XP_MOUNT:
					
					gaugeData.disabled = persoApi.getMount() == null;
					gaugeData.visible = true;
					gaugeData.title = "Xp monture";
					gaugeData.gaugeID = MOUNT_GAUGE;
					
					if (!gaugeData.disabled)
					{
						var mountInfos:Object = persoApi.getMount();
						
						gaugeData.current = mountInfos.experience;
						gaugeData.floor = mountInfos.experienceForLevel;
						gaugeData.ceil = mountInfos.experienceForNextLevel;
					}
					
					break;
				case ID_HONOUR:
					
					gaugeData.disabled = persoApi.getAlignmentSide() == 0;
					gaugeData.visible = true;
					gaugeData.title = "Points d'honneur";
					gaugeData.gaugeID = HONOUR_GAUGE;
					
					if (!gaugeData.disabled)
					{
						gaugeData.current = characteristics.alignmentInfos.honor;
						gaugeData.floor = characteristics.alignmentInfos.honorGradeFloor;
						gaugeData.ceil = characteristics.alignmentInfos.honorNextGradeFloor;
					}
					
					break;
				case ID_PODS:
					
					gaugeData.disabled = false;
					gaugeData.visible = true;
					gaugeData.title = "Pods";
					gaugeData.gaugeID = POD_GAUGE;
					
					gaugeData.current = persoApi.inventoryWeight();
					gaugeData.floor = 0;
					gaugeData.ceil = persoApi.inventoryWeightMax();
					
					break;
				case ID_ENERGY:
					
					gaugeData.disabled = false;
					gaugeData.visible = true;
					gaugeData.title = "Energie";
					gaugeData.gaugeID = XP_GAUGE;
					
					gaugeData.current = characteristics.energyPoints;
					gaugeData.floor = 0;
					gaugeData.ceil = characteristics.maxEnergyPoints;
					
					break;
				default: 
					var jobList:Object = persoApi.getJobs();
					var jobIndex:int = 0;
					
					for each (var job:KnownJob in jobList)
					{
						if (jobIndex + 6 == gaugeId)
						{
							gaugeData.disabled = false;
							gaugeData.visible = true;
							gaugeData.title = "Xp " + metierApi.getJobName(job.jobDescription.jobId);
							gaugeData.gaugeID = JOB_GAUGE;
							
							var jobExperience:JobExperience = job.jobExperience;
							
							gaugeData.current = jobExperience.jobXP;
							gaugeData.floor = jobExperience.jobXpLevelFloor;
							gaugeData.ceil = jobExperience.jobXpNextLevelFloor;
						}
						
						jobIndex++;
					}
					
					break;
			}
			
			return gaugeData;
		}
		
		private function displayGauge(floor:int, current:int, ceil:int, gaugeID:int):void
		{
			var frameIndex:int = 0;
			
			if (current <= floor)
			{
				frameIndex = 0;
			}
			else if (current >= ceil || ceil == floor)
			{
				frameIndex = 100;
			}
			else
			{
				frameIndex = Math.floor(Math.min(((current - floor) / (ceil - floor)) * 100, 100));
			}
			
			if (gaugeID < 0 || gaugeID > NB_GAUGE)
			{
				gaugeID = XP_GAUGE;
			}
			
			tx_jauge.gotoAndStop = (gaugeID * 100 + frameIndex);
		}
	}
}

class GaugeData
{
	public var disabled:Boolean = true;
	public var visible:Boolean = false;
	public var title:String = "";
	public var gaugeID:int = 0;
	public var floor:int = 0;
	public var current:int = 0;
	public var ceil:int = 0;
}
