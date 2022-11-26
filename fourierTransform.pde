
import ddf.minim.*;

Minim minim;
AudioPlayer groove;
float bufferSize;
float[] fftlerp;
float fmax = 300;
float maxI = 0;
float maxVal = 0;
void setup()
{
  size(1024, 500);

  minim = new Minim(this);
  
  groove = minim.loadFile("ghostchoir.mp3", 512);
  groove.loop();
  bufferSize = groove.bufferSize();
  fftlerp = new float[(int) fmax];
  textFont(createFont("Bradley Hand", 24));
  text(" " , 0, 0);
  groove.pause();
}

void keyPressed() {
  if (key == 'a') {
    groove.play();
  }
}
void draw()
{
  maxI = 0;
  maxVal = 0;
  background(0);
  
  stroke( 255 , 255, 0 );
  strokeWeight( 1);
  noFill();

  beginShape();
  for(int i = 0; i < bufferSize; i += 1)
  {
    float x1 = map( i, 0,bufferSize, 0, width );
    if (groove.left.get(i) > maxVal) {
      maxI = i;
      maxVal = groove.left.get(i);
    }
    vertex(x1, 50 + groove.left.get(i)* 50);
  }
  endShape();
  
  beginShape();
  for(int i = 0; i < bufferSize; i += 5)
  {
    float x1 = map( i, 0,bufferSize, 0, width );
    vertex(x1, 150 + groove.left.get( (int) ((i + maxI)%bufferSize) )* 50);
  }
  endShape();
  
  noStroke();
  fill( 255, 128 );
  rect( 0, 0, groove.left.level()*width, 100 );
  
  stroke(255,0,0);
  noFill();
  strokeWeight(1);
  float x1 = map( maxI, 0,bufferSize, 0, width );
  line(x1, 0, x1, 100);
  
  stroke(255);
  strokeWeight(1);
  noFill();
  line(50, 350, 250, 350);
  line(150, 250, 150, 450);
  
  beginShape();
  noFill();
  stroke( 255, 255, 0 );
  strokeWeight(1);
  
  //float level = groove.left.level();
  for (int i = 0; i < bufferSize; i+= 5) {
    float angle = map(i, 0, bufferSize, 0, 2*PI);
    float v = groove.left.get( (int) ((i + maxI)%bufferSize) ) + maxVal;
    v *= 3;
    vertex(150 + 100 * v * cos(angle), height - 150 + 100 * v * sin(angle));
  }
  endShape();
  

  
  stroke( 255, 110, 110 );
  
  float freqLogarithmic = 0.2;
  beginShape();
  for (float freq = 0; freq < fmax; freq += 1) {
    float x = map(freq, 0, fmax, 300, width-50);
    float ft = abs(FT(freq * 0.1));
    float y = height-150 + -ft * 5;
    vertex(x, y);
    fftlerp[(int) freq] += (ft - fftlerp[(int) freq]) * 0.05;
    freqLogarithmic *= 1.03;
  }
  endShape();
  
  //fill( 255, 110, 110 ); noStroke();
  beginShape();
  for (int freq = 0; freq < fmax; freq += 1) {

    float y = fftlerp[freq] * 5;
    vertex(map(freq, 0, fmax, 300, width-50), height-150 + y);
    //rect(map(freq, 0, fmax, 300, width-50), height-150, 1, y);
  }
  endShape();  
  
  stroke( 255 );
  line(300, 350, width-50, 350);  
  
  fill(255);
  noStroke();
  textAlign(RIGHT);
  textSize(20);
  text("Raw audio wave", width - 10, 100);
  text("Stabilized audio wave", width - 10, 200);
  text("Polar graph", 250, height-35);
  text("Raw fourier transform output", width-50, height-200);
  text("Smoothed FT output", width-50, height-100);
}

float FT(float f) {
  float xTotal = 0;
  // loat yTotal = 0;

  for (int i = 0; i < bufferSize; i += 1) {
    
    // float v = groove.left.get( (int) ((i + maxI)%bufferSize) );
    float v = groove.left.get( i );
    float x = v * cos( -2 * PI * f * i / bufferSize);
    //float y = v * sin( -2 * PI * f * i / groove.bufferSize());
    xTotal += x;
    // yTotal += y;
  }
  return xTotal;
}
