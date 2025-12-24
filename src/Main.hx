package;

import openfl.display.Sprite;
import openfl.display.Shape;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.Lib;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

class Main extends Sprite {
  static inline var BG_COLOR:Int = 0x0d0f1a;
  static inline var LANE_COUNT:Int = 4;

  var player:Shape;
  var laneIndex:Int = 0;
  var laneX:Array<Float> = [];

  var obstacles:Array<Shape> = [];
  var obstacleSpeed:Float = 5.0;
  var spawnTimer:Int = 0;
  var spawnInterval:Int = 60;
  var spawnsSinceTighten:Int = 0;

  var score:Float = 0;
  var scoreText:TextField;
  var gameOverText:TextField;
  var isGameOver:Bool = false;
  var laneLines:Shape;
  var shards:Array<Shape> = [];
  var shardVel:Array<{x:Float, y:Float}> = [];

  public function new() {
    super();
    addEventListener(Event.ADDED_TO_STAGE, onAdded);
  }

  function onAdded(_):Void {
    removeEventListener(Event.ADDED_TO_STAGE, onAdded);

    stage.color = BG_COLOR;

    initUI();
    initPlayer();

    stage.addEventListener(MouseEvent.MOUSE_DOWN, onTap);
    addEventListener(Event.ENTER_FRAME, onTick);
  }

  function initUI():Void {
    laneLines = new Shape();
    addChild(laneLines);

    scoreText = new TextField();
    scoreText.defaultTextFormat = new TextFormat("_sans", 72, 0xffffff, true, null, null, null, null, TextFormatAlign.CENTER);
    scoreText.width = stage.stageWidth;
    scoreText.height = 100;
    scoreText.x = 0;
    scoreText.y = 20;
    scoreText.selectable = false;
    addChild(scoreText);

    gameOverText = new TextField();
    gameOverText.defaultTextFormat = new TextFormat("_sans", 48, 0xff5566, true, null, null, null, null, TextFormatAlign.CENTER);
    gameOverText.width = stage.stageWidth;
    gameOverText.height = 200;
    gameOverText.x = 0;
    gameOverText.y = stage.stageHeight * 0.4;
    gameOverText.selectable = false;
    gameOverText.visible = false;
    addChild(gameOverText);
  }

  function initPlayer():Void {
    var padding = 80;
    var laneWidth = (stage.stageWidth - padding * 2) / LANE_COUNT;

    laneX = [];
    for (i in 0...LANE_COUNT) {
      laneX.push(padding + laneWidth * (i + 0.5));
    }

    drawLaneLines(padding, laneWidth);

    player = new Shape();
    drawPlayer(0x46d2ff);
    player.y = stage.stageHeight - 160;
    laneIndex = 0;
    player.x = laneX[laneIndex];
    addChild(player);
  }

  function drawPlayer(color:Int):Void {
    player.graphics.clear();
    player.graphics.beginFill(color);
    player.graphics.drawRoundRect(-36, -36, 72, 72, 12, 12);
    player.graphics.endFill();
  }
  
  function drawLaneLines(padding:Float, laneWidth:Float):Void {
    laneLines.graphics.clear();
    laneLines.graphics.lineStyle(2, 0x2a2f45, 1);

    var top = 120;
    var bottom = stage.stageHeight - 80;
    for (i in 1...LANE_COUNT) {
      var x = padding + laneWidth * i;
      laneLines.graphics.moveTo(x, top);
      laneLines.graphics.lineTo(x, bottom);
    }
  }

  function onTap(_):Void {
    if (isGameOver) {
      resetGame();
      return;
    }

    laneIndex = (laneIndex + 1) % LANE_COUNT;
    player.x = laneX[laneIndex];
  }

  function onTick(_):Void {
    if (!isGameOver) {
      score += 1 / stage.frameRate;
      scoreText.text = Std.string(Std.int(score));

      obstacleSpeed = 5.0 + Math.min(6.0, score / 5);

      spawnTimer++;
      if (spawnTimer >= spawnInterval) {
        spawnTimer = 0;
        spawnsSinceTighten++;
        if (spawnsSinceTighten >= 2) {
          spawnsSinceTighten = 0;
          spawnInterval = Std.int(Math.max(32, spawnInterval - 1));
        }
        spawnObstacle();
      }

      var i = obstacles.length - 1;
      while (i >= 0) {
        var obs = obstacles[i];
        obs.y += obstacleSpeed;

        if (obs.y - 40 > stage.stageHeight) {
          removeChild(obs);
          obstacles.splice(i, 1);
        } else if (hitTestPlayer(obs)) {
          endGame();
          return;
        }
        i--;
      }
    }

    updateShards();
  }

  function spawnObstacle():Void {
    var obs = new Shape();
    obs.graphics.beginFill(0xffb347);
    obs.graphics.drawRoundRect(-36, -36, 72, 72, 16, 16);
    obs.graphics.endFill();

    var lane = Std.random(LANE_COUNT);
    obs.x = laneX[lane];
    obs.y = -80;

    obstacles.push(obs);
    addChild(obs);
    setChildIndex(player, numChildren - 1);
  }

  function hitTestPlayer(obs:Shape):Bool {
    var dx = obs.x - player.x;
    var dy = obs.y - player.y;
    return Math.sqrt(dx * dx + dy * dy) < 60;
  }

  function endGame():Void {
    isGameOver = true;
    explodePlayer();
    gameOverText.text = "Game Over";
    gameOverText.visible = true;
  }

  function resetGame():Void {
    for (obs in obstacles) {
      if (obs.parent != null) removeChild(obs);
    }
    obstacles = [];

    score = 0;
    spawnInterval = 60;
    spawnTimer = 0;
    spawnsSinceTighten = 0;
    isGameOver = false;
    laneIndex = 0;
    player.x = laneX[laneIndex];
    drawPlayer(0x46d2ff);
    clearShards();
    gameOverText.visible = false;
  }

  function explodePlayer():Void {
    player.visible = false;
    drawPlayer(0xff4d4d);

    clearShards();
    var size = 28;
    var offsets = [
      {x: -18.0, y: -18.0},
      {x: 18.0, y: -18.0},
      {x: -18.0, y: 18.0},
      {x: 18.0, y: 18.0}
    ];
    var vels = [
      {x: -3.0, y: -6.5},
      {x: 3.0, y: -6.0},
      {x: -3.5, y: -5.5},
      {x: 3.5, y: -6.2}
    ];

    for (i in 0...4) {
      var shard = new Shape();
      shard.graphics.beginFill(0xff4d4d);
      shard.graphics.drawRoundRect(-size / 2, -size / 2, size, size, 8, 8);
      shard.graphics.endFill();
      shard.x = player.x + offsets[i].x;
      shard.y = player.y + offsets[i].y;
      addChild(shard);
      shards.push(shard);
      shardVel.push(vels[i]);
    }

    setChildIndex(gameOverText, numChildren - 1);
  }

  function updateShards():Void {
    if (shards.length == 0) return;

    for (i in 0...shards.length) {
      var shard = shards[i];
      var vel = shardVel[i];
      vel.y += 0.25;
      shard.x += vel.x;
      shard.y += vel.y;
      shard.rotation += vel.x * 2;
    }
  }

  function clearShards():Void {
    for (shard in shards) {
      if (shard.parent != null) removeChild(shard);
    }
    shards = [];
    shardVel = [];
    player.visible = true;
  }
}
