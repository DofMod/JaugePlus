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
		private static const SELECTED_GAUGE_ID:String = "selectedGaugeId";
		
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
		private var _affichageCourant:int;
		private var _affichageTooltip:Array = new Array();
		
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
					uiApi.showTooltip(composeTooltip(_affichageCourant), tx_jauge, false);
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
			
			if (sysApi.getData("JaugePlusTT") == null)
			{
				var defaultTT:Array = new Array();
				
				defaultTT[ID_XP_CHARACTER]	= [true, true, false, false];
				defaultTT[ID_XP_GUILD]		= [true, true, false, false];
				defaultTT[ID_XP_MOUNT]		= [true, true, false, false];
				
				defaultTT[ID_HONOUR]	= [true, true, false, false];
				defaultTT[ID_PODS]		= [false, true, false, true];
				defaultTT[ID_ENERGY]	= [false, true, false, true];
				
				defaultTT[ID_JOB1] = [true, true, false, false];
				defaultTT[ID_JOB2] = [true, true, false, false];
				defaultTT[ID_JOB3] = [true, true, false, false];
				defaultTT[ID_JOB4] = [true, true, false, false];
				defaultTT[ID_JOB5] = [true, true, false, false];
				defaultTT[ID_JOB6] = [true, true, false, false];
				
				sysApi.setData("JaugePlusTT", defaultTT);
			}
			
			var selectedGaugeId:int = sysApi.getData(SELECTED_GAUGE_ID);
			var selectedGaugeDatas:Array = recupDonnees(selectedGaugeId);
			if (!selectedGaugeDatas["disabled"] && selectedGaugeDatas["visible"])
			{
				_affichageCourant = selectedGaugeId;
			}
			else
			{
				_affichageCourant = 0;
			}
			_affichageTooltip = sysApi.getData("JaugePlusTT");
			
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
			var coche:Boolean = new Boolean();
			var i:int = 0;
			
			paramMenu.push(modContextMenu.createContextMenuItemObject("Tooltip courante :", null, null, true, null, false, false));
			paramMenu.push(modContextMenu.createContextMenuSeparatorObject());
			paramMenu.push(modContextMenu.createContextMenuItemObject('Afficher pourcentage', contextMenuCallback, new Array(2, 0), false, null, _affichageTooltip[_affichageCourant][0], true));
			paramMenu.push(modContextMenu.createContextMenuItemObject('Afficher restant', contextMenuCallback, new Array(2, 1), false, null, _affichageTooltip[_affichageCourant][1], true));
			paramMenu.push(modContextMenu.createContextMenuItemObject('Afficher effectué', contextMenuCallback, new Array(2, 2), false, null, _affichageTooltip[_affichageCourant][2], true));
			paramMenu.push(modContextMenu.createContextMenuItemObject('Afficher maximum', contextMenuCallback, new Array(2, 3), false, null, _affichageTooltip[_affichageCourant][3], true));
			mainMenu.push(modContextMenu.createContextMenuItemObject("Paramètres", null, null, false, paramMenu, false, true));
			mainMenu.push(modContextMenu.createContextMenuSeparatorObject());
			
			while (i != 13)
			{
				if (i == _affichageCourant)
				{
					coche = true;
				}
				
				var donnees:Array = recupDonnees(i);
				
				if (donnees["visible"])
				{
					mainMenu.push(modContextMenu.createContextMenuItemObject(donnees["titre"], contextMenuCallback, new Array(1, i), donnees["disabled"], null, coche, true, composeTooltip(i)));
				}
				donnees = null;
				coche = false;
				i++;
			}
			
			return mainMenu;
		
		}
		
		private function contextMenuCallback(menu:int, item:int):void
		{
			//Callback du menu contextuel
			if (menu == 1)
			{
				
				sysApi.setData(SELECTED_GAUGE_ID, item);
				_affichageCourant = item;
				onHook();
			}
			//Si un item de param a été cliqué :
			else if (menu == 2)
			{
				_affichageTooltip[_affichageCourant][item] = !_affichageTooltip[_affichageCourant][item];
				sysApi.setData("JaugePlusTT", _affichageTooltip);
			}
		}
		
		private function composeTooltip(idDonnee:int):String
		{
			//Génération du tooltip en fonction des préférences
			var donnees:Array = recupDonnees(idDonnee);
			var donneesAff:Array = _affichageTooltip[idDonnee];
			
			var pourcentage:String;
			var restant:String;
			var fait:String;
			var max:String;
			
			var retour:String = "";
			
			pourcentage = Math.floor((donnees['courant'] - donnees["plancher"]) / (donnees["plafond"] - donnees["plancher"]) * 100).toString();
			restant = outilApi.kamasToString((donnees['plafond'] - donnees["plancher"]) - (donnees['courant'] - donnees['plancher']), "");
			fait = outilApi.kamasToString(donnees['courant'] - donnees["plancher"], "");
			max = outilApi.kamasToString(donnees["plafond"] - donnees['plancher'], "");
			
			if (donneesAff[0])
			{
				retour += pourcentage + "%";
				if (donneesAff[3] || donneesAff[1] || donneesAff[2])
				{
					retour += ", ";
				}
			}
			if (donneesAff[1])
			{
				retour += restant + " restant";
				if (donneesAff[2])
				{
					retour += ", ";
				}
				else
				{
					retour += " ";
				}
			}
			if (donneesAff[2])
			{
				var suffix:String = "";
				if (idDonnee == 4)
				{
					suffix = " utilisés";
				}
				else if (idDonnee == 5)
				{
					suffix = " dispo";
				}
				if (idDonnee == 5 || idDonnee == 4)
				{
					fait += suffix;
				}
				else if (donneesAff[1])
				{
					fait += " effectués";
				}
				retour += fait + " ";
			}
			if (donneesAff[3])
			{
				if (donneesAff[0] || donneesAff[1] || donneesAff[2])
				{
					max = "sur " + max;
				}
				else
				{
					max += " max";
				}
				retour += max + " ";
			}
			
			return retour;
		
		}
		
		private function onHook(... arguments:Array):void
		{
			
			//Lorsqu'un changement intervient, on récupére les données correspondantes et on les affiches
			var donnees:Array = recupDonnees(_affichageCourant);
			majJauge(donnees["plancher"], donnees["courant"], donnees["plafond"], donnees["couleur"]);
		
		}
		
		private function recupDonnees(idDonnees:int):Array
		{
			
			//On récupére les données demandées
			var disabled:Boolean = new Boolean(true);
			var visible:Boolean = new Boolean(false);
			var titre:String = new String("");
			var couleur:int = new int(0);
			var plancher:Number = new int(0);
			var courant:Number = new int(0);
			var plafond:Number = new int(0);
			
			var caract:Object = persoApi.characteristics();
			
			switch (idDonnees)
			{
				case ID_XP_CHARACTER:
					
					disabled = false;
					visible = true;
					titre = "Xp personnage";
					couleur = 0;
					
					courant = caract.experience;
					plancher = caract.experienceLevelFloor;
					plafond = caract.experienceNextLevelFloor;
					
					break;
				case ID_XP_GUILD:
					
					disabled = !socApi.hasGuild();
					visible = true;
					titre = "Xp guilde";
					couleur = 1
					
					if (!disabled)
					{
						
						var guilde:Object = socApi.getGuild();
						
						courant = guilde.experience;
						plancher = guilde.expLevelFloor;
						plafond = guilde.expNextLevelFloor;
					}
					
					break;
				case ID_XP_MOUNT:
					
					disabled = persoApi.getMount() == null;
					visible = true;
					titre = "Xp monture";
					couleur = 2;
					
					if (!disabled)
					{
						
						var monture:Object = persoApi.getMount();
						
						courant = monture.experience;
						plancher = monture.experienceForLevel;
						plafond = monture.experienceForNextLevel;
					}
					
					break;
				case ID_HONOUR:
					
					disabled = persoApi.getAlignmentSide() == 0;
					visible = true;
					titre = "Points d'honneur";
					couleur = 3
					
					if (!disabled)
					{
						
						var caractInfos:CharacterCharacteristicsInformations = fightApi.getCurrentPlayedCharacteristicsInformations();
						var alignement:ActorExtendedAlignmentInformations = caractInfos.alignmentInfos;
						
						courant = alignement.honor;
						plancher = alignement.honorGradeFloor;
						plafond = alignement.honorNextGradeFloor;
					}
					
					break;
				case ID_PODS:
					
					disabled = false;
					visible = true;
					titre = "Pods";
					couleur = 4
					
					courant = persoApi.inventoryWeight();
					plancher = 0;
					plafond = persoApi.inventoryWeightMax();
					
					break;
				case ID_ENERGY:
					
					disabled = false;
					visible = true;
					titre = "Energie";
					couleur = 5;
					
					courant = caract.energyPoints;
					plancher = 0;
					plafond = caract.maxEnergyPoints;
					
					break;
				default: 
					//Récupération des infos pour les métiers
					var listMetier:Object = persoApi.getJobs();
					var i:int = 0;
					var nbMetier:int = 0;
					
					for each (var metier:KnownJob in listMetier)
					{
						if (i + 6 == idDonnees)
						{
							
							disabled = false;
							visible = true;
							titre = "Xp " + metierApi.getJobName(metier.jobDescription.jobId);
							couleur = 5;
							
							var xpMetier:JobExperience = metier.jobExperience;
							courant = xpMetier.jobXP;
							plancher = xpMetier.jobXpLevelFloor;
							plafond = xpMetier.jobXpNextLevelFloor;
							nbMetier++;
						}
						i++;
					}
					
					break;
			}
			//On balance tout ça dans un Array
			var retour:Array = new Array();
			
			retour["disabled"] = disabled;
			retour["visible"] = visible;
			retour["titre"] = titre;
			retour["couleur"] = couleur;
			retour["courant"] = courant;
			retour["plancher"] = plancher;
			retour["plafond"] = plafond;
			
			return retour;
		
		}
		
		private function majJauge(plancher:Number, courant:Number, plafond:Number, couleur:int):void
		{
			//On met à jour la jauge avec les données fournies
			var taux:int = 0;
			var correctifCouleur:int = 0;
			
			taux = Math.floor(Math.min(((courant - plancher) / (plafond - plancher)) * 100, 100));
			
			if (taux == 0)
			{
				correctifCouleur = 0;
			}
			else
			{
				correctifCouleur = Math.min(couleur * 100, 500);
			}
			tx_jauge.gotoAndStop = (taux + correctifCouleur).toString();
		}
	}
}
