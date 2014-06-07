<module>

    <!-- Information sur le module -->
    <header>
        <!-- Nom affiché dans la liste des modules -->
        <name>JaugePlus</name>        
        <!-- Version du module -->
        <version>1.0</version>
        <!-- Dernière version de dofus pour laquelle ce module fonctionne -->
        <dofusVersion>2.3.5</dofusVersion>
        <!-- Auteur du module -->
        <author>Le Chat Léon</author>
        <!-- Courte description -->
        <shortDescription>Ce module ajoute une deuxième jauge personnalisable au cadran central.</shortDescription>
        <!-- Description détaillée -->
        <description>Ce module ajoute une deuxième jauge personnalisable au cadran central.<br />Les préférences sont gardées et l'infobulle est personnalisable.<br />Sur une idée originale de Dachictor.</description>
	</header>

    <!-- Liste des interfaces du module, avec nom de l'interface, nom du fichier squelette .xml et nom de la classe script d'interface -->
    <uis>
        <ui name="jaugeplus" file="xml/jauge.xml" class="ui::JaugeUi" />
    </uis>
    
    <script>JaugePlus.swf</script>
    
</module>
