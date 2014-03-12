pongBar Player1, Player2;
bouncyBall PongBall;
float randDeg;

void setup()
{
  size(640,480);
  PFont font;
  font = loadFont("PressStart2P-32.vlw");
  textFont(font, 15);
  //size(displayWidth, displayHeight);
  background(255);
  Player1 = new pongBar(1);
  Player2 = new pongBar(2);
  PongBall = new bouncyBall();
  frameRate(60);
  randomSeed(0);
  randDeg = random(0.0,360.0);
  smooth();
}

class pongBar
{
  PGraphics pBarGfx;  // using graphics to avoid vertexes used in PShape
  color pColor;

  int score;
  boolean beenToScoreArea;
  
  int pBarHeight;
  int pBarWidth;
  int pBarStartPosY;
  int pBarStartPosX;
  int currPosX;
  int currPosY;

  int vertPos;                                // -2 <= vertPos <= 2; 0 = CENTER

  pongBar(int playerNum)
  {
    score = 0;
    beenToScoreArea = false;
    
    pBarHeight = height/5;                    // We want 5 possible positions
    pBarWidth = pBarHeight/8;                 // We want it to actually look like a bar
    pBarStartPosY = height/2 - pBarHeight/2;  // We want the center of the bar to be at the center of the screen
    currPosY = pBarStartPosY;

    if (playerNum == 1)
    {
      pColor = color(255,0,0);                // Player 1 is always RED
      pBarStartPosX = 0;                      // Player 1 is always on the LEFT
      currPosX = pBarStartPosX;
      createBar(pColor);
      image(pBarGfx, pBarStartPosX, pBarStartPosY);
      vertPos = 0;
    }
    else if (playerNum == 2)
    {
      pColor = color(0,0,255);                // Player 2 is always BLUE
      pBarStartPosX = width-pBarWidth;        // Player 2 is always on the RIGHT
      currPosX = pBarStartPosX;
      createBar(pColor);
      image(pBarGfx, pBarStartPosX, pBarStartPosY);
      vertPos = 0;
    }
  }

  void createBar(color playerColor)
  {
    pBarGfx = createGraphics(pBarWidth, pBarHeight);
    pBarGfx.beginDraw();
    pBarGfx.background(playerColor);
    pBarGfx.noStroke();
    pBarGfx.rect(0, pBarStartPosY, pBarWidth, pBarHeight);
    pBarGfx.endDraw();
  }

  int getPos() {  
    return vertPos;
  }

  int setCurrPos(int newPos)
  {
    int currPos = getPos() + newPos;
    if (currPos <= 2 && currPos >= -2)
    {
      vertPos = currPos;
      return 1;
    }
    else
      return 0;
  }
  
  int calcNewBarPosY(int offset)  {  return (pBarStartPosY - ((vertPos-offset) * pBarHeight));  }
  
  int calcNewBarPosY()  {  return (pBarStartPosY - (vertPos * pBarHeight));  }

  void update(int dir)
  {
    // can only move up or down by 1
    if (dir == -1 || dir == 1)
    {
      if (setCurrPos(dir) == 1)
      {
        createBar(pColor);
        currPosY = calcNewBarPosY();
        image(pBarGfx, currPosX, currPosY);     // makes new bar @ new position
      }
    }
  }
  
  void reDraw() 
  {
    image(pBarGfx, currPosX, currPosY);
  }
}

class bouncyBall
{
  PGraphics ball;
  float xPos, yPos, xSpeed, ySpeed;
  int diameter;
  float xDir, yDir;
  
  bouncyBall()
  {
    diameter = height/20;
    createBall();
    
    xPos = width/2;
    yPos = height/2;
    
    xSpeed = 2*2.8;
    ySpeed = 2*2.2;
    
    xDir = random(-1, 1);
    yDir = random(-1, 1);
    
    image(ball,xPos,yPos);
  }
  
  void createBall()
  {
    ball = createGraphics(2*diameter, 2*diameter);
    ball.beginDraw();
    ball.ellipseMode(RADIUS);
    ball.fill(0);
    ball.noStroke();
    ball.ellipse(diameter, diameter,diameter/2,diameter/2);
    ball.endDraw();
  }
  
  void play()
  {    
    // Update the position of the shape
    xPos = xPos + ( xSpeed * xDir );
    yPos = yPos + ( ySpeed * yDir );
    
    
    // Test to see if the shape exceeds the boundaries of the screen
    // If it does, reverse its direction by multiplying by -1
    if (xPos >= width-1.5*diameter || xPos <= -diameter/2) {
      xDir *= -1;
    }
    if (yPos >= height-1.5*diameter || yPos <= -diameter/2) {
      yDir *= -1;
    }
    
    // Draw new ball
    image(ball, xPos, yPos);
  }
}

// TODO: this adds an extra score sometimes because for certain angles
//       the center is able to in and out of the score area twice
void trackScore(bouncyBall ball, pongBar player1, pongBar player2)
{
  if (ball.xPos < player1.currPosX+player1.pBarWidth-ball.diameter && 
      ball.xPos > player1.currPosX-ball.diameter &&
      !(ball.yPos < player1.currPosY+player1.pBarHeight-ball.diameter/2 &&
      ball.yPos > player1.currPosY-ball.diameter/2))
  {
    player1.beenToScoreArea=true;
  }
  else
  {
    if(player1.beenToScoreArea) {
      player1.score++;
      player1.beenToScoreArea = false;
      //println(player1.score);
    }
  }
  if (ball.xPos > player2.currPosX-ball.diameter &&
      ball.xPos < player2.currPosX &&
      !(ball.yPos < player2.currPosY+player2.pBarHeight-ball.diameter/2 &&
      ball.yPos > player2.currPosY-ball.diameter/2))
      
  {
    player2.beenToScoreArea=true;
  }
  else
  {
    if(player2.beenToScoreArea) {
      player2.score++;
      player2.beenToScoreArea = false;
      println(player2.score);
    }
  }
}

void draw()
{
  background(255);
  
  // Draw the ball
  PongBall.play();
  
  //
  Player1.reDraw();
  Player2.reDraw();
  
  // 
  trackScore(PongBall, Player1, Player2);
  
  fill(255, 0, 0);
  text("Player 1: " + Player1.score, width/2 - 80, 30);
  fill(0, 0, 255);
  text("Player 2: " + Player2.score, width/2 - 80, 60);
}

void keyPressed() 
{
  if (key == CODED)
  {
    if (keyCode == UP)
    {
      Player1.update(1);
    }
    else if (keyCode == DOWN)
    {
      Player1.update(-1);
    }
  }
  else if (key == 's') 
  {
    Player2.update(1);
  }
  else if (key == 'd')
  {
    Player2.update(-1);
  }
}
      
