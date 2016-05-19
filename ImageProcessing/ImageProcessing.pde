import java.util.Collections;
import java.util.Random;
PImage img;
PImage sobelIm;
PImage gaussIm;
PImage hueIm;
PImage satIm;
float[][] gaussianKer = {{ 9, 12, 9 },{ 12, 15, 12 },{ 9, 12, 9 }};
ArrayList<Integer> bestCandidates;
ArrayList<PVector> vectIntersect;
QuadGraph quadGraph;

void settings(){
  size(500, 500);
}

void setup(){
  img = loadImage("board2.jpg");
  img.resize(width, height);
  bestCandidates = new ArrayList<Integer>();
  vectIntersect =  new ArrayList<PVector>();
  quadGraph = new QuadGraph();
  noLoop();
}

void draw() {
  background(color(0,0,0));
  hueIm = hueTreshold(treshSat(img, 0, 80), 80, 139);
  gaussIm = convolute(hueIm, gaussianKer, 163);
  sobelIm = sobel(treshBright(gaussIm, 118, 180));
  //image(sobel(img), 0, 0);
  //image(satIm, 0, 0);
  //image(treshBright(img, 30, 110), 0, 0);
  //image(gaussIm, 0, 0);
  /*image(img, 0, 0);
  houghLines(sobelIm, 4);
  image(houghAcc(sobelIm), width/3, 0);
  image(sobelIm, 2*width/3, 0);*/
  image(img, 0, 0);
  houghLines(sobelIm, 4);
}

PImage treshBright(PImage img, float min, float max) {
  PImage brightRes = createImage(img.width, img.height, RGB);
  for (int i = 0; i < img.width * img.height; i++) {
    if (brightness(img.pixels[i]) >= min && brightness(img.pixels[i]) <= max) {
      brightRes.pixels[i] = color(255);
    } else {
      brightRes.pixels[i] = color(0);
    }
  }
  return brightRes;
}

PImage treshSat(PImage img, float min, float max) {
  PImage brightRes = createImage(img.width, img.height, ALPHA);
  for (int i = 0; i < img.width * img.height; ++i) {
    if (saturation(img.pixels[i]) >= min && saturation(img.pixels[i]) <= max) {
      brightRes.pixels[i] = color(255);
    } else {
      brightRes.pixels[i] = img.pixels[i];
    }
  }
  return brightRes;
}

//Pixels whithin the hue range have max value (white) an the other ones min value (black)
PImage hueTreshold(PImage img, float lowBound, float upBound){
  PImage hueTreshResult = createImage(img.width, img.height, RGB);
  for(int i = 0; i < img.width * img.height; ++i) {
    if ((lowBound < upBound) && (hue(img.pixels[i]) >= lowBound && hue(img.pixels[i]) <= upBound)){
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
  for (int l = 0; l<img.height;l++){
    for (int c = 0; c<img.width;c++){
      for (int i = -1; i<2;i++){
        for (int j = -1; j<2;j++){
          //if the pointer is outside the image during the convolution we multiply with a pixel of given intensity (here equal to zero) instead
          if ((l+i >=0 && l+i <img.height)&&(c+j >=0 && c+j <img.width)){
            buffer[l * img.width + c] += (brightness(img.pixels[(l+i)* img.width+(c+j)])*kernel[i+1][j+1])/weight;
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
  float[][] hKernel = {{ 0, 1, 0 },
                       { 0, 0, 0 },
                       { 0, -1, 0 }};
  float[][] vKernel = {{ 0, 0, 0 },
                       { 1, 0, -1},
                       { 0, 0, 0 }};
  float hSum = 0;
  float vSum = 0;
  int sum = 0;
  float max = 0;
  PImage sobelResult = createImage(img.width, img.height, ALPHA);
  // clear the image
  for (int i = 0; i < img.width * img.height; i++) {
    sobelResult.pixels[i] = color(0);
  }
  
  // *************************************
  // the double convolution
  // *************************************
  float[] buffer = new float[img.width * img.height];
  for (int l = 0; l < img.width - 1; l++){
    for (int c = 0; c < img.height - 1; c++){
      hSum = 0;
      vSum = 0;
      sum = 0;
      for (int i = 0; i < 3; i++){
        for (int j = 0; j < 3; j++){
            hSum += img.get(l + i - 1, c + j - 1) * hKernel[i][j];
            vSum += img.get(l + i - 1, c + j - 1) * vKernel[i][j];
         }
       }
       sum = (int)sqrt(pow(hSum, 2) + pow(vSum, 2));
       if (sum > max) {
         max = sum;
       }
       buffer[c*img.width + l] = sum;
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
  return sobelResult;
}

//return the image of the accumlator
PImage houghAcc(PImage edgeImg){
  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 2.5f;
  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1)/ discretizationStepsR); // almost the same as taking the value of the image diagonal
  
  int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
  int r = 0; 
  // Fill the accumulator: on edge points (ie, white pixels of the edge
  // image), store all possible (r, phi) pairs describing lines going
  // through the point.
  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
        for (int i = 0; i<phiDim; i++){
          r = (int)(x*Math.cos(i*discretizationStepsPhi)+y*Math.sin(i*discretizationStepsPhi));
          r = (int)(r/discretizationStepsR);
          r += (int)((rDim - 1))/2;
          accumulator[(i+1) * (rDim+2) + r+1] += 1; // pas sûr !
        } 
      }
    }
  }
  
  PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
  for (int i = 0; i < accumulator.length; i++) {
    houghImg.pixels[i] = color(min(255, accumulator[i]));
  }
  // Resize the accumulator to make it easier to see:
  houghImg.resize(width/3, 400);
  houghImg.updatePixels();
  return houghImg; 
}

ArrayList<PVector> houghLines(PImage edgeImg, int nLines){
  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 2.5f;
  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
  int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
  float r = 0;
  edgeImg.loadPixels();
  
  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
        for (int i = 0; i<phiDim; i++){
          r = (x * cos(i * discretizationStepsPhi) + y * sin(i * discretizationStepsPhi));
          r = Math.round(r/discretizationStepsR);
          r += (rDim - 1)/2;
          int rayon = (int) r;
          accumulator[i *(rDim+2) + rayon + 1 + rDim + 2] += 1;
        }
      }
    }
  }
  
  // size of the region we search for a local maximum
  int neighbourhood = 10;
  // only search around lines with more that this amount of votes 
  // (to be adapted to your image)
  int minVotes = 180;
  for (int accR = 0; accR < rDim; accR++) {
    for (int accPhi = 0; accPhi < phiDim; accPhi++) {
    // compute current index in the accumulator
    int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
    if (accumulator[idx] > minVotes) {
      boolean bestCandidate=true;
      // iterate over the neighbourhood
      for(int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) {
        // check we are not outside the image
        if( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) continue;
        for(int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {
          // check we are not outside the image
          if(accR+dR < 0 || accR+dR >= rDim) continue;
          int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
          if(accumulator[idx] < accumulator[neighbourIdx]) { 
          // the current idx is not a local maximum! 
          bestCandidate=false;
          break;
          } 
        }
        if(!bestCandidate) break;
       }
    
      if(bestCandidate) {
        // the current idx *is* a local maximum 
        bestCandidates.add(idx);
      }
     }
   }
  } 
  Collections.sort(bestCandidates, new HoughComparator(accumulator));
  
  for (int idx = 0; idx < min(nLines, bestCandidates.size()); ++idx) {
      int index = bestCandidates.get(idx);
      // first, compute back the (r, phi) polar coordinates:
      int accPhi = (int) (index / (rDim + 2)) - 1;
      int accR = index - (accPhi + 1) * (rDim + 2) - 1;
      float r2 = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;
      
      PVector v = new PVector(r2, phi);
      vectIntersect.add(v);
      // Cartesian equation of a line: y = ax + b
      // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
      // => y = 0 : x = r / cos(phi)
      // => x = 0 : y = r / sin(phi)
      // compute the intersection of this line with the 4 borders of
      // the image
      float sin = sin(phi);
      float cos = cos(phi);
      int x0 = 0;
      int y0 = (int) (r2 / sin);
      int x1 = (int) (r2 / cos);
      int y1 = 0;
      int x2 = edgeImg.width;
      int y2 = (int) (-cos / sin * x2 + r2 / sin);
      int y3 = edgeImg.width;
      int x3 = (int) (-(y3 - r2 / sin) * (sin / cos));
      // Finally, plot the lines
      stroke(204,102,0);
      if (y0 > 0) {
          if (x1 > 0)
          line(x0, y0, x1, y1);
          else if (y2 > 0)
          line(x0, y0, x2, y2);
          else
          line(x0, y0, x3, y3);
      } else {
        if (x1 > 0) {
          if (y2 > 0) {
            line(x1, y1, x2, y2);
          } else {
            line(x1, y1, x3, y3);
          } 
        }else {
          line(x2, y2, x3, y3);
        }
     }
  }
  drawQuad(vectIntersect);
  return getIntersections(vectIntersect);
}

ArrayList<PVector> getIntersections(ArrayList<PVector> lines) {
  ArrayList<PVector> intersections = new ArrayList<PVector>();
  for (int i = 0; i < lines.size() - 1; i++) {
    PVector line1 = lines.get(i);
    for (int j = i + 1; j < lines.size(); j++) {
      PVector line2 = lines.get(j);
      float d = cos(line2.y) * sin(line1.y) - cos(line1.y) * sin(line2.y);
      int x = (int)((line2.x * sin(line1.y) - line1.x * sin(line2.y)) / d);
      int y = (int)((-line2.x * cos(line1.y) + line1.x * cos(line2.y)) / d);
      // draw the intersection
      fill(255, 128, 0);
      ellipse(x, y, 10, 10);
    }
  }
  return intersections;
}

void drawQuad (ArrayList<PVector> lines){ 
 quadGraph.build(lines,img.width, img.height);
 ArrayList<int[]> quads = new ArrayList<int[]>();
 quads = (ArrayList)quadGraph.findCycles(); //indCycles() use the method findNewCycles()
 for (int[] quad : quads) {
    PVector l1 = lines.get(quad[0]);
    PVector l2 = lines.get(quad[1]);
    PVector l3 = lines.get(quad[2]);
    PVector l4 = lines.get(quad[3]);
    // (intersection() is a simplified version of the
    // intersections() method you wrote last week, that simply
    // return the coordinates of the intersection between 2 lines)
    PVector c12 = intersection(l1, l2);
    PVector c23 = intersection(l2, l3);
    PVector c34 = intersection(l3, l4);
    PVector c41 = intersection(l4, l1);
    // Choose a random, semi-transparent colour
    Random random = new Random();
    if (quadGraph.isConvex(c12,c23,c34,c41) && quadGraph.validArea(c12,c23,c34,c41,img.width*img.height*100,20) && quadGraph.nonFlatQuad(c12,c23,c34,c41)){
      fill(color(min(255, random.nextInt(300)),
      min(255, random.nextInt(300)),
      min(255, random.nextInt(300)), 50));
      quad(c12.x,c12.y,c23.x,c23.y,c34.x,c34.y,c41.x,c41.y);
    }
 }
}



PVector intersection(PVector line1, PVector line2) {
  float d = cos(line2.y) * sin(line1.y) - cos(line1.y) * sin(line2.y);
  int x = (int)((line2.x * sin(line1.y) - line1.x * sin(line2.y)) / d);
  int y = (int)((-line2.x * cos(line1.y) + line1.x * cos(line2.y)) / d);
  return new PVector(x,y);
}