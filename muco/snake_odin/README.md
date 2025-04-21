Things you can try to improve the game:

- Make snake wrap around instead of crash into wall [medium]
- Add highscore counter: A separate score counter that doesn't reset when you get 'game over' [easy]
- Currently you can crash into yourself by trying to go 'the other way', i.e. if you press left while going right you'll crash. Try to fix this! [easy]
- Make the snake move smoothly: You can still be on grid but move each part smoothly to the next cell. Might be tricky to make 'feel good'. [hard]
- Add controller support: see rl.IsGamepadButtonPressed [easy]
- Add music: see rl.PlayMusicStream and rl.UpdateMusicStream [medium]
- Add screen shake when you crash and eat food: you can use target on rl.Camera2D. You'll probably need a timer to track for how long the shake should happen [medium]

