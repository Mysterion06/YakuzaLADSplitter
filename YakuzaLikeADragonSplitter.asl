// Autosplitter by Mysterion_06_
// Commissioned by thegoodprofessor
// LRT Pointers by Vojtas131
// Thanks to TheDementedSalad for mental support and a few Pointers <3

state("YakuzaLikeADragon", "1.9.3"){
    byte isLoad :   0x2FD4910, 0x48, 0x8, 0xC0, 0x10, 0x104;                    // 1 = Loadingscreen
    byte chapter:   0x02CE4FD0, 0xB0;                                           // 1-15 Chapters, 0 when starting a new game/tutorial?
    byte QTE    :   0x3FEF368;                                                  // 1 = QTE prompt; 0 = no QTE prompt
    short hp    :   0x03FD7350, 0x8, 0x250, 0x8, 0x4180, 0x950, 0x4A0, 0x3750;  // Ichibans Current HP
    short maxHp :   0x03FD7350, 0x8, 0x250, 0x8, 0x4180, 0x950, 0x4A0, 0x3758;  // Ichibans Max HP
    int money   :   0x03FD7350, 0x8, 0x250, 0x8, 0x3C8, 0x8;                    // Current money
    int enemyHP :   0x03FD8720, 0xB10, 0x660, 0x0, 0x188;                       // First Enemy HP in the iteration
    int enemyMax:   0x03FD8720, 0xB10, 0x660, 0x0, 0x198;                       // First Enemy Max HP in the iteration
    float X     :   0x02FE9780, 0x470, 0x10;                                    // Ichibans X position
    float Y     :   0x02FE9780, 0x470, 0x14;                                    // Ichibans Y position
    float Z     :   0x02FE9780, 0x470, 0x18;                                    // Ichibans Z position
}

state("YakuzaLikeADragon", "windowsStore")
{
    byte isLoad :   0x21AC370, 0x48, 0x8, 0xC0, 0x10, 0x104;
    byte chapter:   0x0;
    byte QTE    :   0x0;
    short hp    :   0x0;
    short maxHp :   0x0;
    int money   :   0x0;
    int enemyHP :   0x0;
    int enemyMax:   0x0;
    float X     :   0x0;
    float Y     :   0x0;
    float Z     :   0x0;
}

startup{
    // Variables for our settings
    vars.itemSplits = new List<int>()
    {4908, 4950, 4934, 4597};
    vars.itemSplitsSettings = new List<String>()
    {"End of Substory 4", "End of Substory 24", "End of Substory 25", "Dragon Knuckles pick up"};

    // Available settings when booting up the game
    settings.Add("Any%");
    settings.CurrentDefaultParent = "Any%";
        settings.Add("Chapter Splits");
        settings.CurrentDefaultParent = "Chapter Splits";
            for(int i = 1; i <= 15; i++){
                settings.Add("chapter" + i, false, "Chapter " + i );
            }
            //settings.Add("final", true,"Final Split");

    settings.CurrentDefaultParent = "Any%";
        settings.Add("item", false, "Item Splits");
        settings.CurrentDefaultParent = "item";
            for(int i = 0; i < 4; i++){
                settings.Add("" + vars.itemSplits[i].ToString(), false, "" + vars.itemSplitsSettings[i].ToString());
            }
}

init{
    // Variable initializing 
    vars.completedSplits = new List<int>();
    current.ItemIDs = new int[250];
    vars.finalSplit = 0;

    // Switch versions in case another one is recognized
    switch(modules.First().ModuleMemorySize){
        case 373248000:
            version = "windowsStore";
            break;
        default:
            version = "1.9.3";
            break;
    }
}

update
{
    // Reset the variables if the timer resets
    if (timer.CurrentPhase == TimerPhase.NotRunning)
    {
        vars.completedSplits.Clear();
        vars.finalSplit = 0;
    }

    //Creating all the current ItemIDs in our inventory and iterating through the pointers and returning those IDs
    for(int i = 0; i < current.ItemIDs.Length; i++){
        current.ItemIDs[i] = new DeepPointer(0x2FD48A8, 0x18, 0x50, 0x58, 0x10, 0x2A0, 0x8, 0x4080, 0x2000, 0x2330 + (i * 0x10)).Deref<int>(game);
    }
}

start{
    // Timer will start right after clicking E on the last prompt screen
    if(current.hp == 130 && current.isLoad == 1 && old.isLoad == 0){
        return true;
    }
}

split{
    // Chapter Splits. Adding them to a list to prevent double splits
    for(int i = 1; i < 15; i++){
        if(current.chapter > old.chapter && old.chapter != 0 && !vars.completedSplits.Contains(current.chapter) && settings["chapter" + current.chapter]){
            vars.completedSplits.Add(current.chapter);
            return true;
        }
    }

    /* Exception for final split
    if(current.enemyMax == 5248 && current.QTE == 0 && old.QTE == 1 && current.enemyHP == 524 && vars.finalSplit <= 3 && current.chapter == 15){
        vars.finalSplit++;
    }

    // Final Split
    if(current.X >= 7f && current.X <= 8f && current.Y >= 412f && current.Y <= 415f && current.Z >= -1f && current.Z <= 0f && current.chapter == 15 && current.enemyMax == 5248 && current.enemyHP == 524 && vars.finalSplit == 4 && settings["final"]){
        return true;
    }*/

    // Item splits
    int[] currentItemID = (current.ItemIDs as int[]);
    if(settings["item"]){
        for(int i = 0; i < currentItemID.Length; i++){
            //Split on the itemID we are looking for and check if the split already happened and if the setting for that item is checked
            if(vars.itemSplits.Contains(currentItemID[i]) && !vars.completedSplits.Contains(currentItemID[i]) && settings[currentItemID[i].ToString()]){
                vars.completedSplits.Add(currentItemID[i]);
                return true;
            }
        }
    }
}

reset{
    // Resets when returning to the main menu
    if(current.chapter == 0 && old.chapter > 0 && current.money == 1000 && current.hp == 130 && current.maxHp == 130){
        return true;
    }
}

isLoading{
    // Timer stops during loading screens
    return current.isLoad == 1;
}

exit {
    // Timer pauses up until the game is restarted
    timer.IsGameTimePaused = true;
}
