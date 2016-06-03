

/**
 *   Class : NoteReader
 *   Purpose : Detect frequency and relative note by sampiling line in
 *   Programmed By : Eric Cauble
 *   
 *   Credit and thanks to John Montgomery @ 
 *   http://www.psychicorigami.com/2009/01/17/a-5k-java-guitar-tuner/ 
 *   for his 5ktuner methods which I've modified for this class
 */

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.DataLine;
import javax.sound.sampled.LineUnavailableException;
import javax.sound.sampled.TargetDataLine;


public class NoteReader extends PApplet {
	
	// myParent is a reference to the parent sketch
	
	private final double[] FREQUENCIES = { 174.61, 164.81, 155.56, 146.83, 138.59, 130.81, 123.47, 116.54, 110.00, 103.83, 98.00, 92.50, 87.31, 82.41, 77.78};
	private final String[] NAME   = { "F",    "E",     "D#",    "D",   "C#",     "C",    "B",     "A#",    "A",      "G#",    "G",   "F#",  "F",   "E",   "D#"};
	private final int [] BG = { #FC006E, #FF0000, #4BFFFF, #00FF00, #00FC71, #00FCC0, #00C9FC, #0071FC, #0000FF, #8A00FC, #E700FC, #FC00C9, #FC006E, #FF0000, #4BFFFF};
  private int backgroundColor = 0;
  private String myNote = "";
	private int FREQ_RANGE = 128;
	private float sampleRate = 44100;
	private int sampleSizeInBits = 16;
	private int channels = 1;
	private boolean signed = true;
	private boolean bigEndian = false;
	private int value = 0;
	private boolean noteDiff;
	
	private final static String VERSION = "1.0";
	
        //default constructor
        public NoteReader(){
        }
	
	//constructor with processing inheritance
	public NoteReader(PApplet parent) {

	}
	
	//finds the frequency by sampiling line in, sets a string to note name
	public void findFreq() throws LineUnavailableException{
	AudioFormat format = new AudioFormat(sampleRate, sampleSizeInBits, channels, signed, bigEndian);
	DataLine.Info dataLineInfo = new DataLine.Info(TargetDataLine.class, format);
	TargetDataLine targetDataLine = (TargetDataLine)AudioSystem.getLine(dataLineInfo);
	// read about a second at a time
	targetDataLine.open(format, (int)sampleRate);
	targetDataLine.start();

	byte[] buffer = new byte[2*1200];
	int[] a = new int[buffer.length/2];

	int n = -1;
	if ( (n = targetDataLine.read(buffer, 0, buffer.length)) > 0 ) {
          for ( int i = 0; i < n; i+=2 ) {
          // convert two bytes into single value
	  int value = (short)((buffer[i]&0xFF) | ((buffer[i+1]&0xFF) << 8));
	  a[i >> 1] = value;
			}
	     double prevDiff = 0;
	     double prevDx = 0;
	     double maxDiff = 0;
	     int sampleLen = 0;
	     int len = a.length/2;
		for ( int i = 0; i < len; i++ ) {
		  double diff = 0;
			for ( int j = 0; j < len; j++ ) {
				diff += Math.abs(a[j]-a[i+j]);
				}

			double dx = prevDiff-diff;

				// change of sign in dx
				if ( dx < 0 && prevDx > 0 ) {
				// only look for troughs that drop to less than 10% of peak
				if ( diff < (0.1*maxDiff) ) {

				   if ( sampleLen == 0 ) {
						sampleLen=i-1;
						}
					}
				}

				prevDx = dx;
				prevDiff=diff;
				maxDiff=Math.max(diff,maxDiff);
			}

			if ( sampleLen > 0 ) {
				double frequency = (format.getSampleRate()/sampleLen);	                
				frequency = normaliseFreq(frequency);
				int note = closestNote(frequency);
				double matchFreq = FREQUENCIES[note];
				if ( frequency < matchFreq ) {
					double prevFreq = FREQUENCIES[note+1];
					setValue((int)(-FREQ_RANGE*(frequency-matchFreq)/(prevFreq-matchFreq)));
				}
				else {
					double nextFreq = FREQUENCIES[note-1];
					setValue((int)(FREQ_RANGE*(frequency-matchFreq)/(nextFreq-matchFreq)));
				}
				setMyNote(NAME[note]);
        setBackgroundColor(BG[note]);
			}
			try { Thread.sleep(250); }catch( Exception e ){}
		}
	}
	
	
	public  double normaliseFreq(double hz) {
		// get hz into a standard range to make things easier to deal with
		while ( hz < 82.41 ) {
			hz = 2*hz;
		}
		while ( hz > 164.81 ) {
			hz = 0.5*hz;
		}
		return hz;
	}

	public  int closestNote(double hz) {
		double minDist = Double.MAX_VALUE;
		int minFreq = -1;
		for ( int i = 0; i < FREQUENCIES.length; i++ ) {
			double dist = Math.abs(FREQUENCIES[i]-hz);
			if ( dist < minDist ) {
				minDist=dist;
				minFreq=i;
			}
		}

		return minFreq;
	}
	
	public void setValue(int value) {
		this.value = value;
	}

	/**
	 * @return the value
	 */
	public int getValue() {
		return value;
	}
	
	
	

	/**
	 * @param myNote the myNote to set
	 */
	public void setMyNote(String myNote) {
		this.myNote = myNote;
	}


	/**
	 * @return the myNote
	 */
	public String getMyNote() {
		return myNote;
	}

   public void setBackgroundColor(int backgroundColor){
   this.backgroundColor = backgroundColor;
   }

    public int getBackgroundColor(){
    return backgroundColor;
    }

	
}//ends class