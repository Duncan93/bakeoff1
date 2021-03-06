import java.awt.AWTException;
import java.awt.Rectangle;
import java.awt.Robot;
import java.awt.*;
import java.util.ArrayList;
import java.util.Collections;
import processing.core.PApplet;
import java.io.BufferedWriter;
import java.io.FileWriter;

//when in doubt, consult the Processsing reference: https://processing.org/reference/

int margin = 200; //set the margina around the squares
final int padding = 50; // padding between buttons and also their width/height
final int buttonSize = 40; // padding between buttons and also their width/height
ArrayList<Integer> trials = new ArrayList<Integer>(); //contains the order of buttons that activate in the test
int trialNum = 0; //the current trial number (indexes into trials array above)
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
int hits = 0; //number of successful clicks
int misses = 0; //number of missed clicks
Robot robot; //initalized in setup 
float x1, y1, x2, y2; // points for current and next selection
int mouseRow;

int numRepeats = 1; //sets the number of times each button repeats in the test
/*
 * Participant IDs:
 * Duncan: 1
 * Amelia: 2
 * Edward: 3
 * Yoon:   4
 */
int participantID = 1; // EDIT FOR YOURSELF
int previousMouseY = mouseY;
int previousTime;
String filename = "Participant_" + participantID + ".csv";
ArrayList<String> trialInformation = new ArrayList<String>();

void setup()
{
  size(700, 700); // set the size of the window
  noCursor(); //hides the system cursor if you want
  noStroke(); //turn off all strokes, we're just using fills here (can change this if you want)
  textFont(createFont("Arial", 16)); //sets the font to Arial size 16
  textAlign(CENTER);
  frameRate(60);
  ellipseMode(CENTER); //ellipses are drawn from the center (BUT RECTANGLES ARE NOT!)
  //rectMode(CENTER); //enabling will break the scaffold code, but you might find it easier to work with centered rects

  try {
    robot = new Robot(); //create a "Java Robot" class that can move the system cursor
  } 
  catch (AWTException e) {
    e.printStackTrace();
  }

  //===DON'T MODIFY MY RANDOM ORDERING CODE==
  for (int i = 0; i < 16; i++) //generate list of targets and randomize the order
      // number of buttons in 4x4 grid
    for (int k = 0; k < numRepeats; k++)
      // number of times each button repeats
      trials.add(i);

  Collections.shuffle(trials); // randomize the order of the buttons
  //System.out.println("trial order: " + trials);
  
  frame.setLocation(0,0); // put window in top left corner of screen (doesn't always work)
  
  // write a starter line for CSV
  appendTextToFile("trial, id, initial mouseY, target center Y, target height, time taken, success");
}


// Thanks, StackOverflow. u da best.
void appendTextToFile(String text){
  File f = new File(dataPath(filename));
  if(!f.exists()){
    createFile(f);
  }
  try {
    PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(f, true)));
    out.println(text);
    out.close();
  }catch (IOException e){
      e.printStackTrace();
  }
}

/**
 * Creates a new file including all subfolders
 */
void createFile(File f){
  File parentDir = f.getParentFile();
  try{
    parentDir.mkdirs(); 
    f.createNewFile();
  }catch(Exception e){
    e.printStackTrace();
  }
} 


void draw()
{
  background(0); //set background to black

  if (trialNum >= trials.size()) //check to see if test is over
  {
    fill(255); //set fill color to white
    //write to screen (not console)
    text("Finished!", width / 2, height / 2); 
    text("Hits: " + hits, width / 2, height / 2 + 20);
    text("Misses: " + misses, width / 2, height / 2 + 40);
    text("Accuracy: " + (float)hits*100f/(float)(hits+misses) +"%", width / 2, height / 2 + 60);
    text("Total time taken: " + (finishTime-startTime) / 1000f + " sec", width / 2, height / 2 + 80);
    text("Average time for each button: " + ((finishTime-startTime) / 1000f)/(float)(hits+misses) + " sec", width / 2, height / 2 + 100);      
    return; //return, nothing else to do now test is over
  }

  fill(255); //set fill color to white
  text((trialNum + 1) + " of " + trials.size(), 40, 20); //display wha3t trial the user is on

  for (int i = 0; i < 16; i++)// for all button
    drawButton(i); //draw button

  fill(255, 0, 0, 200); // set fill color to translucent red
  ellipse(margin - 20, mouseY, 20, 20); //draw user cursor as a circle with a diameter of 20
  
  // draw arrow connecting squares
  drawArrow(x1, y1, x2, y2);
  
  // draw box around row
  fill(200,200,200,150);
  noStroke();
  mouseRow = constrain((mouseY - margin + padding/2)/(padding + buttonSize), 0, 3);
  int rowWidth = 4 * (padding + buttonSize) - padding;
  rect(margin, mouseRow * (padding + buttonSize) + margin - padding/2, rowWidth, buttonSize + padding);
  
}


void mousePressed() // test to see if hit was in target!
{

}  

//probably shouldn't have to edit this method
Rectangle getButtonLocation(int i) //for a given button ID, what is its location and size
{
   int x = (i % 4) * (padding + buttonSize) + margin;
   int y = (i / 4) * (padding + buttonSize) + margin;
   return new Rectangle(x, y, buttonSize, buttonSize);
}

//you can edit this method to change how buttons appear
void drawButton(int i)
{
  Rectangle bounds = getButtonLocation(i);
  //noStroke(); // override drawArrow
  // number size
  textSize(32);
  if (trials.get(trialNum) == i) { // see if current button is the target
    fill(0, 255, 255); // if so, fill cyan
    rect(bounds.x, bounds.y, bounds.width, bounds.height); //draw button
    x1 = bounds.x; // set x and y of arrow start
    y1 = bounds.y;
    fill(255);
    text(trials.get(trialNum) % 4 + 1, bounds.x+bounds.width/2, bounds.y+bounds.height/2 + 16); 
  }
  else if (trialNum < trials.size() - 1 && trials.get(trialNum + 1) == i) { // upcoming target
    fill(200);
    rect(bounds.x, bounds.y, bounds.width, bounds.height); //draw button
    //fill(0, 255, 255);
    x2 = bounds.x; // set x and y of arrow end
    y2 = bounds.y;
    fill(255);
    text(trials.get(trialNum + 1) % 4 + 1, bounds.x+bounds.width/2, bounds.y+bounds.height/2 + 16); 
  }
  else {
    fill(200); // if not, fill gray
    rect(bounds.x, bounds.y, bounds.width, bounds.height); //draw button
  }

  textSize(14);
  
}

/*
 * Draw an arrow stretching from the center of the current square to the next square
 */
void drawArrow(float x1, float y1, float x2, float y2) {
  //float len = sqrt(pow((x2-x1),2) + pow((y2-y1),2)) - buttonSize;
  //float angle = atan2(y2 - y1, x2 - x1);
  float radius = buttonSize / 2;
  //float cx1 = x1 + radius * sin(angle);
  //float cy1 = y1 + radius * cos(angle);
  //float triangleSize = 5;

  strokeWeight(2);
  stroke(255,0,0);
  line(x1+radius, y1+radius, x2+radius, y2+radius);
  // draw an ellipse at end of line
  ellipse(x2+radius, y2+radius, 8, 8);
  
}
  

void mouseMoved()
{
   //can do stuff everytime the mouse is moved (i.e., not clicked)
   //https://processing.org/reference/mouseMoved_.html
  Point mouseLocation = MouseInfo.getPointerInfo().getLocation();
  int deltaX = mouseLocation.x - mouseX;
  int deltaY = mouseLocation.y - mouseY;
  if (mouseX < padding || mouseX > width - padding) {
    robot.mouseMove(width/2 + deltaX, mouseY + deltaY);    
  }
}

void mouseDragged()
{
  //can do stuff everytime the mouse is dragged
  //https://processing.org/reference/mouseDragged_.html
}

void keyPressed() 
{
  int success; // 1 == true; 0 == false
  //can use the keyboard if you wish
  //https://processing.org/reference/keyTyped_.html
  //https://processing.org/reference/keyCode.html
  if (trialNum >= trials.size()) //if task is over, just return
    return;

  if (trialNum == 0) {//check if first click, if so, start timer
    startTime = millis();
    previousTime = millis();
  }
  if (trialNum == trials.size() - 1) //check if final click
  {
    finishTime = millis();
    //write to terminal some output:
    //println("Hits: " + hits);
    //println("Misses: " + misses);
    //println("Accuracy: " + (float)hits*100f/(float)(hits+misses) +"%");
    //println("Total time taken: " + (finishTime-startTime) / 1000f + " sec");
    //println("Average time for each button: " + ((finishTime-startTime) / 1000f)/(float)(hits+misses) + " sec");
  }

  int target = (trials.get(trialNum));
  //System.out.println(mouseRow * 4 + (key - '1'));
  //System.out.println(target);
 //check to see if mouse cursor is inside button 
  if (mouseRow * 4 + (key - '1') == target) // test to see if hit was within bounds
  {
    //System.out.println("HIT! " + trialNum + " " + (millis() - startTime)); // success
    hits++; 
    success = 1;
  } 
  else
  {
    //System.out.println("MISSED! " + trialNum + " " + (millis() - startTime)); // fail
    misses++;
    success = 0;
  }
  
  int targetCenterY = getButtonLocation(target).y + buttonSize / 2;
  int time = millis() - previousTime;
  //System.out.println(previousTime+","+millis());
  // print current data (trial number, participant id, initial mouseY, Y position of center of target, target height, time taken, success)
  //System.out.println("Target: "+target);
  String trialInfo = trialNum+","+participantID+","+previousMouseY+","+targetCenterY+","+buttonSize+","+time+","+success;
  //addInfoToFile(trialInfo);
  appendTextToFile(trialInfo);

  trialNum++; //Increment trial number
  
  // update variables for next trial
  previousMouseY = mouseY;
  previousTime = millis();


}