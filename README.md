# OneTap

A fast-paced arcade game built with Haxe and OpenFL where you tap to switch lanes and avoid obstacles.

<img width="698" height="1239" alt="image" src="https://github.com/user-attachments/assets/bed6b4c7-3ed0-4a18-9a5d-8a5572cac8d9" />

## Gameplay

- Tap anywhere to move to the next lane
- Avoid the orange obstacles coming down
- Score increases over time
- Game gets progressively faster and more challenging
- Tap after game over to restart

## Building

### Web Version
```bash
lime build html5
```

### Test in Browser
```bash
lime test html5
```

### Other Platforms
```bash
lime build windows
lime build android
lime build linux
lime build mac
```

## Requirements

- Haxe
- Lime
- OpenFL

Install dependencies:
```bash
haxelib install openfl
haxelib run openfl setup
```

## Project Structure

- `src/Main.hx` - Main game logic
- `assets/` - Game assets
- `project.xml` - Project configuration
- `bin/` - Build output

## Controls

- **Mouse/Touch**: Tap to switch lanes
- **After Game Over**: Tap to restart

## Technical Details

- 4-lane gameplay
- Portrait orientation (720x1280)
- 60 FPS
- Dynamic difficulty scaling
- Particle effects on collision
