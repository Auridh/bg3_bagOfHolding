$absPath = Resolve-Path -Path "./"

Move-Item -Path "$absPath/mod/Public/Auridh_BoH/Stats/Generated/TreasureTable.txt" -Destination "$absPath/TreasureTable.txt"
Copy-Item -Path "$absPath/TuTSumTable.txt" -Destination "$absPath/mod/Public/Auridh_BoH/Stats/Generated/TreasureTable.txt" -Force

divine -a convert-loca -g bg3 -s "$absPath/mod/Localization/English/BagOfHolding.xml" -d "$absPath/mod/Localization/English/BagOfHolding.loca";
divine -a convert-resources -g bg3 -s "$absPath/mod/Public/Auridh_BoH/Content/UI/[PAK]_UI" -d "$absPath/mod/Public/Auridh_BoH/Content/UI/[PAK]_UI" -i lsx -o lsf;
divine -a convert-resources -g bg3 -s "$absPath/mod/Public/Auridh_BoH/GUI" -d "$absPath/mod/Public/Auridh_BoH/GUI" -i lsx -o lsf;
divine -a convert-resources -g bg3 -s "$absPath/mod/Public/Auridh_BoH/RootTemplates" -d "$absPath/mod/Public/Auridh_BoH/RootTemplates" -i lsx -o lsf;
#divine -a convert-resources -g bg3 -s "$absPath/mod/Public/Auridh_BoH/Tags" -d "$absPath/mod/Public/Auridh_BoH/Tags" -i lsx -o lsf;
divine -a create-package -g bg3 -s "$absPath/mod" -d "$absPath/BagOfHolding_TuT.pak" -c lz4;
Compress-Archive -Path "$absPath/BagOfHolding_TuT.pak" -DestinationPath "$absPath/BagOfHolding_TuT.zip" -Force

Move-Item -Path "$absPath/TreasureTable.txt" -Destination "$absPath/mod/Public/Auridh_BoH/Stats/Generated/TreasureTable.txt" -Force