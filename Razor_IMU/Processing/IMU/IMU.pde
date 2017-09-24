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
boolean FIRST_YAW = false;  //Has the first YAW angle been take ?
float YAW;      //Relative YAW angle

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
  for (int i = 1; i <= 3; i++)  //Wait for serial to become stable
    port.bufferUntil('\n');  
}

void draw() {
  background(BACKGROUND_COLOR);  //BLACK
}

void serialEvent(Serial port) {
  String YPR = port.readString();
  String YAW_STRING_FORMAT = YPR.substring(YPR.indexOf('=') + 1, YPR.indexOf(','));  //We now have the number in YPR
  YAW_RAW = float(YAW_STRING_FORMAT);
  if (FIRST_YAW) {
    INITIAL_YAW_ANGLE = YAW_RAW;
  } else {
    YAW = YAW_RAW - INITIAL_YAW_ANGLE;
  }
}