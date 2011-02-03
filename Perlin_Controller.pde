/** 
* pController
* A simple Perlin Noise front-end sending noise values via OSC
*
* @author Krzysztof Trzewiczek
* @version 1.0
*
* Licensed under the Open Software License (OSL 3.0).
*/

// import Andreas Schlegel oscP5 library
import oscP5.*;
import netP5.*;

// OSC object
OscP5 oscP5;
// remote server
NetAddress remoteServer;
// array of OSC Messages
OscMessage[] msgs;

// array of sliders
int numbOfSliders;
Slider[] sliders;



/////////////////// S E T U P ///////////////////

void setup()
{
	// window size and framerate
	size(1150, 300);
	frameRate(25);

	// enable anti-alissing
	smooth();
	
	// disable strokes
	noStroke();

        // number of sliders corresponding with number of OSC adresses
	numbOfSliders = 55;
	sliders = new Slider[numbOfSliders];

	// init the sliders -> Slider(float initialSeed, float initialDelta, int xPosition, int range)
	for(int i = 0; i < sliders.length; ++i)
			sliders[i] = new Slider(random(0.0, 100.0), 0.02, 50 + 20*i, 300); 

	// init OSC communication
	oscInit();
	
		// set text font to Verdana, 8 pt
	textFont(createFont("Verdana", 8));
}


/////////////////// D R A W ///////////////////

void draw()
{
	// set background to white
	background(255);

	// set color to light grey and draw the grid
	fill(230);
	for(int i = 0; i < 6; ++i)
		rect(0, height-50*i, width, 1);

	for(int i = 0; i < sliders.length; ++i)
		rect(50 + 2 + 20*i, 0, 1, height);

	// set color to grey and draw horizontal axis
	fill(150);
	rect(0, height - 150, width, 1);

	// write the descriptions 
	text("Delta:", 3, 9);
	text("Value:", 3, 20);
	text("Avarange:", 3, 31);
	text("Delta:", 3, height-3);
	text("Value:", 3, height-13);
	text("Avarange:", 3, height-23);
	text("150", 3, 148);
	
	// set color to red and draw the sliders and send OSC Messages
	fill(200, 50, 50);  
	for(int i = 0; i < sliders.length; ++i)
	{
		// draw a slider
		sliders[i].render(i);
		
		//create new OSC Message
		msgs[i] = new OscMessage("/f" + str(i));     
		// set OSC Message value to normalised value (-1.0, 1.0);
		msgs[i].add(map(sliders[i].getValue(), 0, 300, -1.0, 1.0));
		
		// send OSC Message
		oscP5.send(msgs[i], remoteServer);
	}
}


/////////////////// K E Y  P R E S S E D ///////////////////

void keyPressed()
{
	// if 'w' key pressed, increase sliders delta
	if(key == 'w')
		for(int i = 0; i < sliders.length; ++i)
			sliders[i].setDelta(1);

	// if 's' key pressed, descrease sliders delta
	if(key == 's')
		for(int i = 0; i < sliders.length; ++i)
			sliders[i].setDelta(-1);
}    


/////////////////// O S C  I N I T ///////////////////

void oscInit()
{
        // init OSC object
        oscP5 = new OscP5(this, 5600);
	// init the remote server as localhost on port 5601
	remoteServer = new NetAddress("127.0.0.1", 5601);

	// init the array of OSC Messages
	msgs = new OscMessage[sliders.length];

	for(int i = 0; i < msgs.length; ++i)
	{
		msgs[i] = new OscMessage("/f" + str(i));     
		msgs[i].add(map(sliders[i].getValue(), 0, 300, -1.0, 1.0));
	}
}


/////////////////// C L A S S  S L I D E R ///////////////////

class Slider
{
	/**
	* Slider constructor
	* 
	* @param initialSeed float for an initial noise seed
	* @param initialDelta float for an initial noise delta
	* @param xPosition int for an initial y position of a slider
	* @param range int for the range of values of the slider
	*/
	public Slider(float initialSeed, float initialDelta, int xPosition, int range)
	{
		seed = initialSeed;
		delta = initialDelta;
		currentDelta = initialDelta;

		// value of the slider
		x = 0;
		// avarange value
		avarange = 0;
		// sum of the values of the slider in time
		sum = 0.0;

		x = xPosition;
		
		// value range
		vRange = range;
	}

	/**
	* render draw the slider on screen
	*
	* @param i position in array of sliders
	*/
	public void render(int i)
	{
		// count value of the slider
		v = int(map(noise(seed), 0.0, 1.0, 0.0, vRange));

		// draw a slider
		rect(x, height-v, 5, 5);

		// increment noise seed
		seed += currentDelta;

		// count current informations
		float txt = constrain(int(currentDelta * 1000) / 1000.0, 0.003, 0.1);
		sum += v;
		avarange = floor(sum / frameCount);
		
		// write current informations
		if(i % 2 == 0)
		{
			text(str(txt), x-5, height-3);
			text(str(x), x-5, height-13);
			text(str(avarange), x-5, height-23);
		}
		else
		{
			text(str(txt), x-5, 9);
			text(str(x), x-5, 20);
			text(str(avarange), x-5, 31);
		}
	}

	/**
	* setDelta changes the value of delta
	*
	* @param modifier
	*/
	public void setDelta(float modifier)
	{
		// keep delta value in range (0.003, 0.1)
		currentDelta = 	constrain(currentDelta + (delta * modifier), 0.003, 0.1);
	}
	
	/**
	* getValue getter for slider value v
	*/
	public int getValue()
	{
		return v;
	}


	///////// P R I V A T E  F I E L D S /////////
		
	// noise seed and delta
	private float seed;
	private float delta;
	// current delta changed by the user
	private float currentDelta;

	// value, sum of values in time and avarange value in time
	private int v;
	private float sum;
	private int avarange;
	// values range
	private float vRange;

	// x position of slider
	private int x;
}



