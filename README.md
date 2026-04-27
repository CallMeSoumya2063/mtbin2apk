# mtbin2apk
A user friendly interactive bash script that injects renderdragon shaders directly into the game. Inspired by [matject](https://github.com/faizul726/matject), imagined by [izvekhharuvn](https://www.curseforge.com/members/izvekhharuvn/projects) on discord. It uses [minedraco](https://github.com/CallMeSoumya2063/MineDraco) as a template (modified for this purpose) and [rsapksign](https://github.com/mcbegamerxx954/rsapksign) to sign apk.

## Known issue
Modified apk does not install due to an [issue](https://github.com/mcbegamerxx954/rsapksign/issues/1) with rsapksign. So, the script fails at the last step. I will fix the script once the issue with rsapksign is resolved, or after I find a feasible alternative approach for apk signing.

## Requirements
1. An Android device.
2. Termux from GitHub or F-Droid.
3. A Minecraft apk file.
4. A renderdragon shader mcpack file.
5. Sufficient free storage space (recommended minimum: 2 gb).

## How to Use
1. Put Minecraft apk (make sure it has 'Minecraft' in its name in any way) inside `mcpe` folder in `Download` folder in your internal storage.
> *Minecraft from Play Store is unsupported.*
2. Put renderdragon shader mcpack inside `shaders` folder in `Download` folder in your internal storage.
> *To avoid issues in game, make sure to use supported renderdragon shaders for the correct version and correct OS ('merged' or 'android' for Minecraft on Android).*
3. Download and install Termux from [GitHub](https://github.com/termux/termux-app/releases/latest) or [F-Droid](https://f-droid.org/en/packages/com.termux/). Do NOT use Termux from Play Store as it is known to cause issues.
4. Paste this command in Termux and press ENTER to run the script:
```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/CallMeSoumya2063/mtbin2apk/main/mtbin2apk.sh)"
```
4. Read instructions on screen and follow (pressing ENTER accepts your inputs).

> [!IMPORTANT]
> Make sure you are connected to the internet while running the script.
> Modified APK made by this script only loads the shader you injected into the APK file. You CANNOT disable it in game.
> Activate the renderdragon shader mcpack in game to fix broken visuals.

## More important info on App name and Package name:
- **App Name**: This is what you see on your phone’s home screen and app drawer, like `Minecraft`.
- **Package Name**: This is a unique ID for the app used by Android, like `com.mojang.minecraftpe` for Minecraft.

## Pros and Cons of using this script:
### Pros:
1. Easy to use
2. Fast manual shader injection (subpacks supported)
3. No dependency on shader loaders like [mbl2](https://github.com/mcbegamerxx954/mtbinloader2) or [draco](https://github.com/mcbegamerxx954/mcbe_shader_redirector)
### Cons:
1. No graphical user interface (GUI)
2. Doesn't support switching shaders in game
