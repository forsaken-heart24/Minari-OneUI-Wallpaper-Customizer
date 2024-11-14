# ⭐ FLOSSPaperOneUI

![flosspaper-banner](https://github.com/forsaken-heart24/i_dont_want_to_be_an_weirdo/blob/main/banner_images/FLOSSPaper_rounded_final.png?raw=true)

**Customize Your Samsung OneUI ROM'S Wallpapers**

⭐️ An open-source tool to help you personalize your modified samsung stock ROM'S wallpapers using an 
bash script to make a json file that is used in the samsung's wallpaper-res application
for the wallpaper(s) and it's informations.

❣ i hope it would be an useful tool for you, thank me later if it is!

# 🔆 How to use this bash script? (requires terminal or termux to be installed.)
```
pkg install git || sudo apt install git; git clone https://github.com/forsaken-heart24/FLOSSPaperOneUI/; cd FLOSSPaperOneUI; chmod +x FLOSSPaper.sh && ./FLOSSPaper.sh
```

# ⭕ What to do after executing the script?
* The shell script will tell you where did the resources_info.json file is located after the job is being done.

* If you have the file on that folder, copy and disassemble the "wallpaper-res.apk" application, which is located in the "system/priv-app/wallpaper-res" folder, from your legally purchased Samsung device(s).

* After disassembling, copy the "resources_info.json" file into the decompiled application's data folder, named "res/raw". Add the wallpaper images into the "res/drawable-nodpi" folder with their appropriate names.

* Recompile the application, sign the new APK, and place it in the "system/priv-app/wallpaper-res/" folder. Finally, reboot your device. You're now set up with custom wallpapers in the system.

## ❌ Wanna improve it, or want to give any ideas? Join our support chat for more!
* [Telegram Chat](https://t.me/equinoxfromlunaandetclore)
 
## 🛑 Supported OneUI Versions (for now)
-------------------

* OneUI 3.1
* OneUI 4.1