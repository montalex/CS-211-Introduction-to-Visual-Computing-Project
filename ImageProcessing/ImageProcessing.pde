PImage img;
PImage sobelIm;
PImage gaussIm;
HScrollbar thresholdBar;
HScrollbar thresholdBarDown;
HScrollbar thresholdBarUp;

float[][] GaussianKer;


void settings(){
  size(800,600);
}

void setup(){
  
  img = loadImage("board1.jpg");
  thresholdBarDown = new HScrollbar(0, 580, 800, 20);
  thresholdBarUp = new HScrollbar(0, 550, 800, 20);
  
  //noLoop();
}

void draw(){
  float[][] gaussianKer = {{ 9, 12, 9 },{ 12, 15, 12 },{ 9, 12, 9 }};
  float[][] kern1 = {{ 0, 1, 0 },{ 1, 0, 1},{ 0, 1, 0}};
  float[][] hKernel = { { 0, 1, 0 },{ 0, 0, 0 },{ 0, -1, 0 } };
   
  gaussIm = convolute(hueTreshold(img,110,135), gaussianKer, 100);
  sobelIm = sobel(gaussIm);
  //PImage sobelGauss = convolute(sobelIm, gaussianKer,99);

  background(color(0,0,0));
  //image(treshBinary(img,125),0,0);//ok
  //image(treshBinary(img,thresholdBarUp.getPos()*255),0,0);//ok
   //image(hueMode(img,thresholdBarDown.getPos()*255, thresholdBarUp.getPos()*255), 0, 0);//ok
  //image(hueTreshold(img,thresholdBarDown.getPos()*255,thresholdBarUp.getPos()*255),0,0);//ok
  //image(convolute(img,gaussianKer,30),0,0);//Need to be compared to know if good convolution
  //image(sobel(img),0,0);//ok
  //image(sobelIm,0,0);
  //image(gaussIm,0,0);
  //image(hough1(sobelIm), 0, 0);
  hough2(sobelIm, img);
 
  thresholdBarDown.display();
  thresholdBarDown.update();
  thresholdBarUp.display();
  thresholdBarUp.update();
  println("Down bound: "+thresholdBarDown.getPos()*255); 
  println("Up bound: "+thresholdBarUp.getPos()*255); 
 
}

// Treshold binary function 
PImage treshBinary(PImage img,float treshold){
  
  PImage binResult = createImage(width, height, RGB);
  
  
  for(int i = 0; i < img.width * img.height; i++) {
    if(brightness(img.pixels[i])>treshold){
      binResult.pixels[i] = color(255,255,255);
    }else{
      binResult.pixels[i] = color(0,0,0);
    } 
  }
 

  return binResult;
}


// Treshold binary inverted function
PImage treshBinInv(PImage img, float treshold){
  
  PImage binInvReslt = createImage(width, height, RGB);
  
  
  for(int i = 0; i < img.width * img.height; i++) {
    if(brightness(img.pixels[i])>treshold){
      binInvReslt .pixels[i] = color(0,0,0);
    }else{
      binInvReslt.pixels[i] = color(255,255,255);
    } 
  }
  
  return binInvReslt ;
}


// Select only pixels for which color is within the wanted range
PImage hueMode(PImage img, float lowBound, float upBound){
  
  PImage hueResult = createImage(width, height, HSB);
  
  for(int i = 0; i < img.width * img.height; i++) {
      
    if ((lowBound<upBound)&& (hue(img.pixels[i])>lowBound && hue(img.pixels[i])<upBound)){
       hueResult.pixels[i] = img.pixels[i];
    }else{
      hueResult.pixels[i] = 0;
    }
  }
 
  hueResult.updatePixels();
  return hueResult;
}


//Pixels whithin the hue range have max value (white) an the other ones min value (black)
PImage hueTreshold(PImage img, float lowBound, float upBound){
   
  PImage hueTreshResult = createImage(img.width, img.height, ALPHA);
 
  for(int i = 0; i < img.width * img.height; i++) {
      
    if ((lowBound<upBound)&& (hue(img.pixels[i])>lowBound && hue(img.pixels[i])<upBound)){
      hueTreshResult.pixels[i] = color(255);
    }else{
      hueTreshResult.pixels[i] = color(0);
    }
  }
  hueTreshResult.updatePixels();
  return hueTreshResult;
}


//convolution function 
PImage convolute(PImage img, float[][] kernel, float weight) {
  
  
  float[] buffer = new float[img.width * img.height];
  // create a greyscale image (type: ALPHA) for output

  PImage convResult = createImage(img.width, img.height, ALPHA);
  
  // kernel size N = 3
  
  // for each (x,y) pixel in the image:
  // - multiply intensities for pixels in the range
  // (x - N/2, y - N/2) to (x + N/2, y + N/2) by the
  // corresponding weights in the kernel matrix
  // - sum all these intensities and divide it by the weight
  // - set result.pixels[y * img.width + x] to this value
  
    for (int l = 0; l<img.height;l++){
      for (int c = 0; c<img.width;c++){
        for (int i = -1; i<2;i++){
          for (int j = -1; j<2;j++){
            //if the pointer is outside the image during the convolution we multiply with a pixel of given intensity (here equal to zero) instead
            if ((l+i >=0 && l+i <img.height)&&(c+j >=0 && c+j <img.width)){
             buffer[l * img.width + c] += (brightness(img.pixels[(l+i)* img.width+(c+j)])*kernel[i+1][j+1])/weight;
             
             
            }else{
             buffer[l * img.width + c] += (0*kernel[i+1][j+1])/weight;
             
            }
        }
       }
       convResult.pixels[l * img.width + c] = color(buffer[l * img.width + c]);
      }
    }
   
    convResult.updatePixels();
    
  return convResult;
}

//Sobel algorithm
PImage sobel(PImage img) {
  
  float[][] hKernel = { { 0, 1, 0 },{ 0, 0, 0 },{ 0, -1, 0 } };
  float[][] vKernel = { { 0, 0, 0 },{ 1, 0, -1 },{ 0, 0, 0 } };
  
  float hSum = 0;
  float vSum = 0;
  
  float weight = 1;
  
  int sum = 0;
  float max=0;
  
  PImage sobelResult = createImage(width, height, ALPHA);
   
  // clear the image
  for (int i = 0; i < img.width * img.height; i++) {
  sobelResult.pixels[i] = color(0);
  }
  
  
  float[] buffer = new float[img.width * img.height];
  
  // *************************************
  //the double convolution
  // *************************************
  
   for (int l = 0; l<img.height;l++){
      for (int c = 0; c<img.width;c++){
       
        hSum =0;
        vSum =0;
        sum=0;
        
        for (int i = -1; i<2;i++){
          for (int j = -1; j<2;j++){
            if ((l+i >=0 && l+i <img.height)&&(c+j >=0 && c+j <img.width)){
             hSum += (brightness(img.pixels[(l+i)* img.width+(c+j)])*hKernel[i+1][j+1])/weight;
             vSum += (brightness(img.pixels[(l+i)* img.width+(c+j)])*vKernel[i+1][j+1])/weight;
             
            }else{
             hSum += (0*hKernel[i+1][j+1])/weight;
             vSum += (0*vKernel[i+1][j+1])/weight;
            }
          }
        }
        
        sum = (int)sqrt(pow(hSum, 2) + pow(vSum, 2));
        if (sum>max) {
        max=sum;
        }
        buffer[l*img.width+c] = sum;
      }
    }
   
  for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
    for (int x = 2; x < img.width - 2; x++) { // Skip left and right
      if (buffer[y * img.width + x] > (int)(max * 0.3f)) { // 30% of the max
        sobelResult.pixels[y * img.width + x] = color(255);
        } else {
          sobelResult.pixels[y * img.width + x] = color(0);
        }
     }
   }
   
  sobelResult.updatePixels();
  return sobelResult;
  
}

//return the image of the accumlator
PImage hough1(PImage edgeImg){
  
  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 2.5;
  
  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1)/ discretizationStepsR); // almost the same as taking the value of the image diagonal
  
  PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);

  int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];

   int r = 0;
   
  // Fill the accumulator: on edge points (ie, white pixels of the edge
  // image), store all possible (r, phi) pairs describing lines going
  // through the point.
  
  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
        
      // ...determine here all the lines (r, phi) passing through
      // pixel (x,y), convert (r,phi) to coordinates in the
      // accumulator, and increment accordingly the accumulator.
      // Be careful: r may be negative, so you may want to center onto
      // the accumulator with something like: r += (rDim - 1) / 2
      
        for (int i = 0; i<phiDim; i++){
         
            r = (int)(x*Math.cos(i*0.06)+y*Math.sin(i*0.06));
            r = (int)(r/discretizationStepsR);
            r += (int)((rDim - 1))/2;
            
            
          accumulator[(i+1) * (rDim+2) + r+1] += 1; // pas sûr !
        }
       
      }
    }
  }
  
 
    for (int i = 0; i < accumulator.length; i++) {
      houghImg.pixels[i] = color(min(255, accumulator[i]));
    }
    // You may want to resize the accumulator to make it easier to see:
    // houghImg.resize(400, 400);
   
    houghImg.resize(400, 400);
    
    houghImg.updatePixels();

  return houghImg;
  
}

//return the image with the lines corresponding to the hough algorithm displayed on it
void hough2(PImage edgeImg, PImage img){
 
  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 2.5f;
  
  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR); // same as..
  
  PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);

  int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];

   int r = 0;
 
   edgeImg.loadPixels();
 
  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
        
        for (int i = 0; i<phiDim; i++){
          
            r = (int)(x*cos(i*0.06)+y*sin(i*0.06));
            r = (int)(r/discretizationStepsR);
            r += (int)((rDim - 1))/2;
         
          accumulator[(i+1) *(rDim+2) + r+1] += 1;
        }
      }
    }
  }
  
  
    for (int i = 0; i < accumulator.length; i++) {
      houghImg.pixels[i] = color(min(255, accumulator[i]));
    }    
    houghImg.updatePixels();
    
    image(img,0,0);
  
    for (int idx = 0; idx < accumulator.length; idx++) {
      if (accumulator[idx] > 200) {
      // first, compute back the (r, phi) polar coordinates:
    
      int accPhi = (int) (idx / (rDim + 2)) - 1;
      int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
      float r2 = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;
      
      // Cartesian equation of a line: y = ax + b
      // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
      // => y = 0 : x = r / cos(phi)
      // => x = 0 : y = r / sin(phi)
      // compute the intersection of this line with the 4 borders of
      // the image
      
      int x0 = 0;
      int y0 = (int) (r2 / sin(phi));
      int x1 = (int) (r2 / cos(phi));
      int y1 = 0;
      int x2 = edgeImg.width;
      int y2 = (int) (-cos(phi) / sin(phi) * x2 + r2 / sin(phi));
      int y3 = edgeImg.width;
      int x3 = (int) (-(y3 - r2 / sin(phi)) * (sin(phi) / cos(phi)));
      
      // Finally, plot the lines
      
      
      stroke(204,102,0);
      
      if (y0 > 0) {
          if (x1 > 0)
          line(x0, y0, x1, y1);
          else if (y2 > 0)
          line(x0, y0, x2, y2);
          else
          line(x0, y0, x3, y3);
      }
      else {
          if (x1 > 0) {
            if (y2 > 0)
                line(x1, y1, x2, y2);
            else
              line(x1, y1, x3, y3);
          }
          else
              line(x2, y2, x3, y3);
     }
     }
   }
  
  
}

 
 