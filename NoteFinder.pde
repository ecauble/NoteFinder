/**
*    NOTEFINDER driver class for NoteReader
*    ERIC CAUBLE 2011, caublee@email.uscupstate.edu
*
*/
import processing.serial.*;

//instance variables
String portName = null;  
int portSpeed = 19200;
byte blinkmAddr = 0x09;  // the default I2C addr of a BlinkM
String note = "";

Serial port;
NoteReader nr;
PFont fontA, fontB;


void setup() {
  size(300, 300);
  smooth();
  nr = new NoteReader(this);
  fontA = loadFont("Ziggurat-HTF-Black-32.vlw");
  textFont(fontA, 100);
  textAlign(CENTER);
  
  //setup port for serial communication
  if( portName == null ) {
        portName = (Serial.list())[0]; // choose first port if none spec'd
    }
    port = new Serial(this, portName, portSpeed);
    if( port == null ) {
        println("ERROR: Could not open serial port: "+portName);
        exit();
    }
}//ends setup

//addresses on blinkm
public synchronized void sendCommand( byte addr, byte[] cmd ) {
    byte cmdfull[] = new byte[4+cmd.length];
    cmdfull[0] = 0x01;                    // sync byte
    cmdfull[1] = addr;                    // i2c addr
    cmdfull[2] = (byte)cmd.length;        // this many bytes to send
    cmdfull[3] = 0x00;                    // this many bytes to receive
    for( int i=0; i<cmd.length; i++) {    // and actual command
        cmdfull[4+i] = cmd[i];
    }
    port.write(cmdfull);
}

// formats hex to rgb for blinkm
public void toColor( int r, int g, int b ) {
 /*Processing has changed the way serial communication works, 
 / the follwing lines of code are depricated
 / you'll have do a little research to get it working*/
 
  //byte[] cmd = {'n', (byte)r, (byte)g, (byte)b};
  //sendCommand( blinkmAddr, cmd );
}
    
void draw(){
 
  try{//for line unavailable
   nr.findFreq();//frequency analysis
   note = nr.getMyNote();//sets note string 
   background(nr.getBackgroundColor());//changes draw's background color
   
 //sending cmd to microcontroller as hex values
 //I'd rewrite this but it's been 
 //five years since I worked on this project

 if(note.equals("A")){
  toColor( 0x00, 0xff, 0xff );//BLUE
 }
 else if(note.equals("A#") ){
 toColor( 0x00, 0x71, 0xfc );//LIGHT BLUE
 }
 else if(note.equals("B") ){
 toColor( 0x00, 0xc9, 0xfc );//TURQUOISE
 }
 else if(note.equals("C") ){
 toColor( 0x00, 0xfc, 0xc0 );//SEA GREEN
 }
 else if(note.equals("C#") ){
 toColor( 0x00, 0xfc, 0x71 );//LIME 
 }
 else if(note.equals("D") ){
 toColor( 0x00, 0xFF, 0x00 );//GREEN
 }
 else if(note.equals("D#") ){
 toColor( 0x4b, 0xff, 0xff );//YELLOW
 }
 else if(note.equals("E") ){
 toColor( 0xff, 0x00, 0x00 );//RED
 }
 else if(note.equals("F") ){
 toColor( 0xfc, 0x00, 0x6e );//RED VIO
 }
  else if(note.equals("F#") ){
 toColor( 0xfc, 0x00, 0xc9 );//VIOLETT
 }
 else if(note.equals("G") ){
 toColor( 0xe7, 0x00, 0xfc );//PURPLE
 }
 else if(note.equals("G#") ){
 toColor( 0x8a, 0x00, 0xfc );//DARK PURPLE
 }
 else{//no match empty note
   toColor( 0x00, 0x00, 0x00 );//off or "black"
 }
   fill(200);
   text(note,150,175);
   }
        catch(Exception e){
            e.printStackTrace();
        }

}//ends void draw