import processing.serial.*;

Serial port;

/*
  ###################################################################
 #################### OUTPUT PARAMETERS ############################
 ###################################################################
 */
//    WINDOW PARAMETERS
//Size of window in pixels (Please change the size() also, since Processing 3.0 doesn't support variables in size()
int WIDTH = 500;
int HEIGHT = 500;
color BACKGROUND_COLOR = #000000;  //default : BLACK
color CIRCLE_COLOR = #FFFFFF;  //default : WHITE
color SPHERE_COLOR = #816464;

//Serial parameters
String SERIAL_PORT_NAME = "/dev/cu.usbmodem141111";
int BAUD_RATE = 57600;
String CONTINUOUS_OUTPUT_PARAMETER = "#o1";

/*
 ###################################################################
 #################### PROGRAM PARAMETERS ###########################
 ###################################################################
 (Do not change if you don't know what the variables do)
 */
int CIRCLE_DIAMETER = int(min(WIDTH, HEIGHT) * 0.5);  //The diameter of circle 
float YAW_RAW;  //YAW angle as returned by the sensor
float INITIAL_YAW_ANGLE;     //YAW at the beginning of the program
boolean FIRST_YAW = true;  //Has the first YAW angle been take ?
float YAW;      //Relative YAW angle (in DEGREES)

void setup() {
  println("Welcome to IMU testing unit");
  //Window
  //size(WIDTH,HEIGHT); is not supported
  WIDTH = WIDTH * 1; 
  HEIGHT = HEIGHT * 1;  //Just so that it's easier to find the variables
  size(500, 500);  //Change width and height

  //Serial
  port = new Serial(this, SERIAL_PORT_NAME, BAUD_RATE);
  port.write(CONTINUOUS_OUTPUT_PARAMETER);  //Enable continuous output
  port.bufferUntil('\n');
  port.write("#o0");
  println("PORT STATUS : Ready and ACTIVE");
}

void draw() {
  background(BACKGROUND_COLOR);  //BLACK background (defult)
  //Making the circle
  stroke(CIRCLE_COLOR);
  strokeWeight(10);
  noFill();
  ellipse(width/2, height/2, CIRCLE_DIAMETER, CIRCLE_DIAMETER);
  port.write("#f");  //request an angle
  //YAW now has the angle (in degrees)
  fill(SPHERE_COLOR);
  stroke(color(0,0,0));
  strokeWeight(5);
  ellipse( 
    width/2 + sin(radians(YAW)) * 7.0/8.0 * (CIRCLE_DIAMETER - 20) * 0.5,
    height/2 - cos(radians(YAW)) * 7.0/8.0 * (CIRCLE_DIAMETER - 20) * 0.5,
    CIRCLE_DIAMETER * 0.25,
    CIRCLE_DIAMETER * 0.25
    );
}


//Serial functions : Calibrated for the protocol Razor IMU follows
void serialEvent(Serial port) {
  String YPR = port.readStringUntil('\n');  //Format is "#YPR=$YAW$,$PITCH$,$ROLL$"
  YPR = YPR.substring(5);
  //println(YPR);  
  String[] YPR_Angles = splitTokens(YPR, ",");
  //printArray(YPR_Angles);

  String YAW_STRING_FORMAT = YPR_Angles[0];  //We now have the number in YPR
  //println("YAW = " + YAW_STRING_FORMAT);


  YAW_RAW = float(YAW_STRING_FORMAT);
  if (FIRST_YAW) {
    INITIAL_YAW_ANGLE = YAW_RAW;
    FIRST_YAW = false;
  } else {
    YAW = YAW_RAW - INITIAL_YAW_ANGLE;
    //Tweaks to convert to our convention...
    if (YAW < 0) {
      YAW += 360;  //Convert to 0 to 360 degree scale on our reference
    }
    if (YAW > 180) {
      YAW = -(360 - YAW);   //Convert -180 to +180 scale on our reference
    }
    println("YAW = " + str(YAW));  //YAW found
  }
}

void keyPressed() {
  if (key == 'R') 
    FIRST_YAW = true;
}