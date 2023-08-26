param ($n)
$absPath = Resolve-Path -Path "./"
divine -a convert-loca -g bg3 -s "$absPath/mod/Localization/English/BagOfHolding.xml" -d "$absPath/mod/Localization/English/BagOfHolding.loca";
divine -a convert-loca -g bg3 -s "$absPath/mod/Localization/French/BagOfHolding.xml" -d "$absPath/mod/Localization/French/BagOfHolding.loca";
divine -a convert-loca -g bg3 -s "$absPath/mod/Localization/German/BagOfHolding.xml" -d "$absPath/mod/Localization/German/BagOfHolding.loca";
divine -a convert-resources -g bg3 -s "$absPath/mod/Public/Auridh_BoH/Content/UI/[PAK]_UI" -d "$absPath/mod/Public/Auridh_BoH/Content/UI/[PAK]_UI" -i lsx -o lsf;
divine -a convert-resources -g bg3 -s "$absPath/mod/Public/Auridh_BoH/GUI" -d "$absPath/mod/Public/Auridh_BoH/GUI" -i lsx -o lsf;
divine -a convert-resources -g bg3 -s "$absPath/mod/Public/Auridh_BoH/RootTemplates" -d "$absPath/mod/Public/Auridh_BoH/RootTemplates" -i lsx -o lsf;
#divine -a convert-resources -g bg3 -s "$absPath/mod/Public/Auridh_BoH/Tags" -d "$absPath/mod/Public/Auridh_BoH/Tags" -i lsx -o lsf;
divine -a create-package -g bg3 -s "$absPath/mod" -d "$absPath/compile/files/$n.pak" -c lz4;
Compress-Archive -Path "$absPath/compile/files/$n.pak" -DestinationPath "$absPath/compile/files/$n.zip" -Force