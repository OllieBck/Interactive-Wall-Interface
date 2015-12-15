//code developed from Dan O'Sullivan's code found here https://itp.nyu.edu/classes/dance-f15/kinect/
//it utilizes the Processing library for the Kinect developed by Daniel Shiffman and Thomas Sanchez
//it utilizes the Syphon library by Andres Colubri

import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import processing.sound.*;
import codeanticode.syphon.*;

SyphonServer server;

Kinect2 kinect2;
//put these in an array
SoundFile [] sound = new SoundFile[10];
int sliderPos = 200;
int numSounds = 10;
int chooseNum = 0;
int picNum = 0;
int numBirds = 10;
int [] soundNumber = new int[10];
String [] songFiles = {"sound1.wav", "sound2.wav", "sound3.wav", "sound4.wav", 
  "sound5.wav", "sound6.wav", "sound7.wav", "sound8.wav", 
  "sound9.wav", "sound10.wav"};
String [] uploadedSounds = new String[10];
String [] uploadedImage = new String[10];
String [] songList = new String[10];
PImage [] picButton = new PImage[10];
PImage img;
float lastTime; //variable to hold time when the trigger is activated
int[] depthX;
float pixelDepth;
float[] bound = new float[10];
int counter = 0;
int[] xPos = new int[10];
int[] yPos = new int [10];
float distBuffer = 50;
boolean backColor = false;
int boxSize = 50;
int timer = 500; //time needed to activate note
float flapTimer;
Button [] target = new Button[10];
String [] text = {"This program also utilizes MadMapper.", 
  "You will need that application open as well.", 
  "Click on the video to set a location for a projected button.", 
  "The button works best when placed on a flat surface.", 
  "Press the 'b' button to go to a solid background.", 
  "Move the sliders below to change the background color.", "Size of buttons can adjusted with up and down arrows.", 
  "A preview is shown below of button and background color.", "Click the image below to select a new image for buttons."
};
PFont arial;
float xSlider1;
float xSlider2;
float xSlider3;
float slider1;
float slider2;
float slider3;

void settings() {
  size(1000, 800, P3D); //screen size to range of sensor and tweak to make it run faster
  PJOGL.profile = 1;
}

void setup() {
  server = new SyphonServer(this, "Processing Syphon");
  kinect2 = new Kinect2(this);
  kinect2.initRegistered();
  kinect2.initDepth();
  kinect2.initDevice();
  for (int i = 0; i< numSounds; i++) {
    sound[i] = new SoundFile(this, songFiles[i]);
  }
  target = new Button[numBirds];
  for (int j = 0; j < target.length; j++) {
    target[j] = new Button();
  }
  picButton[0] = loadImage("hummingbird1.png");
  picButton[1] = loadImage("hummingbird2.png");
  xSlider1 = width-(kinect2.depthWidth)+50;
  xSlider2 = width-(kinect2.depthWidth)+50;
  xSlider3 = width-(kinect2.depthWidth)+50;
}

void draw() {
  instructions();
  slider1 = slider(xSlider1, 200, 20, 255, 0, 0);
  slider2 = slider(xSlider2, 250, 20, 0, 255, 0);
  slider3 = slider(xSlider3, 300, 20, 0, 0, 255);
  imageMode(CORNER);
  rectMode(CORNER);
  fill(slider1, slider2, slider3);
  stroke(slider1, slider2, slider3);
  rect(width-(kinect2.depthWidth)+50, kinect2.depthHeight-5, boxSize, boxSize);
  if (picNum <= 2) {
    image(picButton[0], width-(kinect2.depthWidth)+50, kinect2.depthHeight-5, boxSize, boxSize);
  } else {
    image(picButton[picNum-1], width-(kinect2.depthWidth)+50, kinect2.depthHeight-5, boxSize, boxSize);
  }
  if (backColor == false) {
    img = kinect2.getRegisteredImage();
    imageMode(CORNER);
    image(img, 0, 0, kinect2.depthWidth, kinect2.depthHeight);
  } else {
    img = kinect2.getRegisteredImage();
    imageMode(CORNER);
    image(img, 0, 0, kinect2.depthWidth, kinect2.depthHeight);
    rectMode(CORNER);
    noStroke();
    fill(slider1, slider2, slider3);
    rect(0, 0, kinect2.depthWidth, kinect2.depthHeight);
  }
  for (int i = 0; i < target.length; i++) {
    target[i].display();
    target[i].trigger();
  }
  server.sendScreen();
}

void mouseClicked() {
  if (mouseX < kinect2.depthWidth && mouseX > 0 && mouseY < kinect2.depthHeight && mouseY > 0) {
    ellipse(mouseX, mouseY, 30, 30);
    xPos[counter] = mouseX;
    yPos[counter] = mouseY;
    depthX = kinect2.getRawDepth();
    for (int x = mouseX; x<mouseX+1; x++) {
      for (int y = mouseY; y<mouseY+1; y++) {
        int spot = x+y*kinect2.depthWidth;
        pixelDepth = depthX[spot];
      }
      bound[counter] = pixelDepth;
      soundNumber[counter] = 0+counter;
      target[counter].start(xPos[counter], yPos[counter], boxSize, bound[counter]-distBuffer, bound[counter], soundNumber[counter]);
      println(bound[counter]);
      counter++;
      if (counter > numBirds) {
        counter = 0;
      }
    }
  }
  if (mouseX < 65 && mouseX>15 && mouseY < kinect2.depthHeight+45 && mouseY > kinect2.depthHeight-5) {
    selectInput("Select a file to process:", "fileSelected");
  }
  //rect(width-(kinect2.depthWidth)+50, 400, boxSize, boxSize);
  if (mouseX < width-kinect2.depthWidth+50+boxSize && mouseX > width-kinect2.depthWidth+50 && mouseY > 400 && mouseY < 400+boxSize) {
    selectInput("Select a file to process:", "pictureSelected");
  }
}

class Button {
  int xPoint;
  int yPoint;
  int boxDim;
  float frontBound;
  float backBound;
  int playSoundNumber;
  int compareDepth = 0;
  boolean flapper = true;

  void start(int oneX, int oneY, int hotSpotSize, float frontDepth, float backDepth, int soundPlay) {
    xPoint = oneX;
    yPoint = oneY;
    boxDim = hotSpotSize;
    frontBound = frontDepth;
    backBound = backDepth;
    playSoundNumber = soundPlay;
  }

  void display() {
    imageMode(CENTER);
    rectMode(CENTER);
    strokeWeight(1);
    stroke(slider1, slider2, slider3);
    noFill();
    rect(xPoint, yPoint, boxDim, boxDim);
    //image(bird[0], xPoint, yPoint, boxDim, boxDim);
    if (flapper == true) {
      image(picButton[0], xPoint, yPoint, boxDim, boxDim);
      //flapTimer = millis();
    } else {
      image(picButton[1], xPoint, yPoint, boxDim, boxDim);
    }
  }

  void trigger() {
    float sumDepth = 0; 
    float count = 0;
    int[] depth = kinect2.getRawDepth();
    for (int y = yPoint; y < yPoint+boxDim; y++) {
      for (int x = xPoint; x < xPoint+boxDim; x++) {
        int index = x+y*kinect2.depthWidth;
        int rawDepth = depth[index];
        if (rawDepth >= frontBound && rawDepth <= backBound) { // -5 and +5
          sumDepth = sumDepth + rawDepth;
          count++;
        }
      }
    }
    float averageDepth = 0.0; //value to hold the average depth
    if (count > 3) {//if we get enough pixels in the field, let's average the suckers
      averageDepth = sumDepth/count; //getting an average depth for them
      averageDepth = constrain(averageDepth, frontBound, backBound);
      averageDepth = map(averageDepth, frontBound, backBound, 0, 255);
    }
    if (averageDepth < 200 && averageDepth > 100) { 
      if (millis()-lastTime > timer) {
        sound[playSoundNumber].play(); // plays the file
        flapper = !flapper;
        lastTime = millis(); //remember to set lastTime to millis
      }
    }
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      boxSize++;
    } else if (keyCode == DOWN) {
      boxSize--;
    }
  } else if (key == 'B' || key == 'b') {
    backColor = !backColor;
  }
}

void instructions() {
  arial = createFont("Arial", 18);
  background(200, 200, 200);
  textFont(arial, 18);
  fill(0, 0, 0);
  rectMode(CENTER);
  rect(40, kinect2.depthHeight+20, 50, 50);
  text("click box to upload audio files (up to 10)", 75, kinect2.depthHeight+25);
  for (int t = 0; t < text.length; t++) {
    if (t < text.length-3) {
      text(text[t], kinect2.depthWidth+10, 50+20*t);
    } else {
      text(text[t], kinect2.depthWidth+10, 220+20*t);
    }
  }
  if (chooseNum > 0) {
    for (int q = 0; q < chooseNum; q++) {
      textSize(12);
      text(songList[q], 15, kinect2.depthHeight+65+(20*q));
    }
  }
}

float slider(float sliderX, int sliderY, int sliderDim, int fillRed, int fillGreen, int fillBlue) {
  rectMode(CENTER);
  stroke(fillRed, fillGreen, fillBlue);
  fill(fillRed, fillGreen, fillBlue);
  rect(sliderX, sliderY, sliderDim, sliderDim);
  line(width-(kinect2.depthWidth)+50, sliderY, width - 100, sliderY);
  float value = map(sliderX, width-(kinect2.depthWidth)+50, width-100, 0, 255);
  return value;
}

void mouseDragged() {
  if (mouseX > width-(kinect2.depthWidth)+50 && mouseX < width-100 && mouseY > 180 && mouseY< 220) {
    xSlider1 = mouseX;
  }
  if (mouseX > width-(kinect2.depthWidth)+50 && mouseX < width-100 && mouseY > 230 && mouseY< 270) {
    xSlider2 = mouseX;
  }
  if (mouseX > width-(kinect2.depthWidth)+50 && mouseX < width-100 && mouseY > 280 && mouseY< 320) {
    xSlider3 = mouseX;
  }
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    uploadedSounds[chooseNum] = selection.getAbsolutePath();
    sound[chooseNum] = new SoundFile(this, uploadedSounds[chooseNum]);
    songList[chooseNum] = "Song File: " + selection.getAbsolutePath();
    chooseNum++;
  }
}

void pictureSelected(File choice) {
  if (choice == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    uploadedImage[picNum] = choice.getAbsolutePath();
    picButton[picNum] = loadImage(uploadedImage[picNum]);
    picNum++;
  }
}