import java.util.Collections;
import java.util.Random;
import java.util.Arrays;
PImage img;
float discretizationStepsPhi = 0.005f;
float discretizationStepsR = 2.5f;

void settings(){
  size(1200, 300);
}

void setup(){
  img = loadImage("board1.jpg");
  noLoop();
}

void draw() {
  img.resize(400, 300);
  image(img, 0, 0);
  PImage threshIm = HBSthresholding(img, 81.4, 138.6, 18.3, 191.25, 55.5, 255.0);
  PImage blurrIm = gaussianBlur(gaussianBlur(threshIm));
  PImage cleanIm = brightnessThresholding(blurrIm, 253, 255);
  PImage sobelIm = sobel(cleanIm);
  
  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((sobelIm.width + sobelIm.height) * 2 + 1) / discretizationStepsR);
  // our accumulator (with a 1 pix margin around
  int[] accumulator = getHoughAccumulator(sobelIm, phiDim, rDim);
  ArrayList<PVector> linesIntersection = hough(6, accumulator, phiDim, rDim);
  ArrayList<int[]> quads = getQuad(linesIntersection, sobelIm.width, sobelIm.height);
  ArrayList<PVector> linesToDraw = new ArrayList<PVector>();
  
  //We select only the first quad or drawing...
  if(quads.size() > 0) {
    for(int i : quads.get(0)) {
      linesToDraw.add(linesIntersection.get(i));
    }
    drawBorderLines(linesToDraw, sobelIm.width);
    ArrayList<PVector> intersections = getIntersections(linesToDraw);
    drawIntersections(intersections);
    drawQuads(Collections.singletonList(quads.get(0)), linesIntersection);
  }
  
  PImage houghIm = displayHoughAcc(accumulator, phiDim, rDim);
  

    
  sobelIm.resize(400, 300);
  houghIm.resize(400, 300);
  image(houghIm, 400, 0); 
  image(sobelIm, 800, 0);
}

PImage convolute(PImage img, float[][] kernel, float weight) {
  // create a greyscale image (type: ALPHA) for output
  PImage result = createImage(img.width, img.height, ALPHA);
  
  int kernelSize = kernel.length;
  int radius = kernelSize/2;
  for(int y = 1; y < img.height-1; ++y) {
    for(int x = 1; x < img.width-1; ++x) {
      float val = 0;
      for(int l = 0; l < kernelSize; ++l) {
        for(int c = 0; c < kernelSize; ++c) {
          int dx = x + c-radius;
          int dy = y + l-radius;
          dx = (dx < 0) ? 0 : dx;
          dx = (dx > img.width-1) ? img.width-1 : dx;
          dy = (dy < 0) ? 0 : dy;
          dy = (dy > img.height-1) ? img.height-1 : dy;
          val += brightness(img.pixels[dy * img.width + dx]) * kernel[l][c];
        }
      }
      result.pixels[y * img.width + x] = color(val / weight);
    }
  }
  return result;
}

PImage gaussianBlur(PImage img) {
  float kernel[][] = {{9, 12, 9}, 
                      {12, 15, 12}, 
                      {9, 12, 9}};
  float weight = 99;
  return convolute(img, kernel, weight);
}

PImage HBSthresholding(PImage img, float minHue, float maxHue, float minBr, float maxBr, float minSat, float maxSat) {
  PImage result = createImage(img.width, img.height, RGB);
  for(int i = 0; i < result.width*result.height; ++i)  {
    float s = saturation(img.pixels[i]);
    float b = brightness(img.pixels[i]);
    float h = hue(img.pixels[i]);
    if(s >= minSat && s <= maxSat && h >= minHue && h <= maxHue && b >= minBr && b <= maxBr) {
      result.pixels[i] = color(255);
    }
    else {
      result.pixels[i] = color(0);
    }
  }
  return result;
}

PImage brightnessThresholding(PImage img, float minI, float maxI) {
  PImage result = createImage(img.width, img.height, ALPHA);
  for(int i = 0; i < result.width*result.height; ++i) {
    float intensity = brightness(img.pixels[i]);
    if(intensity >= minI && intensity <= maxI) {
      result.pixels[i] = color(255);
    }
    else {
      result.pixels[i] = color(0);
    }
  }
  return result;
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
  float sum = 0;
  float max = 0;
  PImage sobelResult = createImage(img.width, img.height, ALPHA);
  // clear the image
  for (int i = 0; i < img.width * img.height; i++) {
    sobelResult.pixels[i] = color(0);
  }
  
  int kernelSize = hKernel.length;
  int radius = kernelSize/2;
  float[] buffer = new float[img.width * img.height];
  for(int y = 0; y < img.height-1; ++y) {
    for(int x = 0; x < img.width-1; ++x) {
      hSum  = 0;
      vSum = 0;
      sum = 0;
      for(int l = 0; l < kernelSize; ++l) {
        for(int c = 0; c < kernelSize; ++c) {
          int dx = x + c-radius;
          int dy = y + l-radius;
          dx = (dx < 0) ? 0 : dx;
          dx = (dx > img.width-1) ? img.width-1 : dx;
          dy = (dy < 0) ? 0 : dy;
          dy = (dy > img.height-1) ? img.height-1 : dy;
          hSum += img.get(dx, dy)*hKernel[l][c];
          vSum += img.get(dx, dy)*vKernel[l][c];
        }
      }
      sum = sqrt((hSum*hSum) + (vSum*vSum));
      if(sum > max) {
        max = sum;
      }
      buffer[y * sobelResult.width + x] = sum;
    }
  }
  for(int i = 0; i < img.height*img.width; ++i) {
    sobelResult.pixels[i] = (buffer[i] > (int)(max * 0.3f)) ? color(255) : color(0);
  }
  return sobelResult;
}

int[] getHoughAccumulator(PImage edgeImg, int phiDim, int rDim) {
  // pre-compute the sin and cos values
  float[] tabSin = new float[phiDim];
  float[] tabCos = new float[phiDim];
  float ang = 0;
  float inverseR = 1.f / discretizationStepsR;
  for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
    // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
    tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
    tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
  }
  
  int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
  for (int y = 0; y < edgeImg.height; ++y) {
    for (int x = 0; x < edgeImg.width; ++x) {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
        for(int i = 0; i < phiDim; ++i) {
          double r = x*tabCos[i] + y*tabSin[i];
          int radius = (int)Math.round(r + (rDim -1)/2);
          accumulator[(i+1)*(rDim+2) + radius+1] += 1;
        }
      }
    }
  }
  return accumulator;
}

ArrayList<Integer> getBestCandidates(int rDim, int phiDim, int[] accumulator) {
  ArrayList<Integer> bestCandidates = new ArrayList<Integer>();
  
  // size of the region we search for a local maximum
  int neighbourhood = 10;

  // only search around lines with more that this amount of votes
  int minVotes = 150;
  for (int accR = 0; accR < rDim; accR++) {
    for (int accPhi = 0; accPhi < phiDim; accPhi++) {
      // compute current index in the accumulator
      int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
      if (accumulator[idx] > minVotes) {
        boolean bestCandidate = true;
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
  
  return bestCandidates;
}

ArrayList<PVector> getLines(ArrayList<Integer> bestCandidates, int rDim, int nLines) {
  ArrayList<PVector> lines = new ArrayList<PVector>();
  for(int idx : bestCandidates.subList(0, min(nLines, bestCandidates.size()))) {
    // first, compute back the (r, phi) polar coordinates:
    int accPhi = (int) (idx / (rDim + 2)) - 1;
    int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
    float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
    float phi = accPhi * discretizationStepsPhi;
    PVector line = new PVector(r, phi);
    lines.add(line);
  }
  return lines;
}

void drawBorderLines(ArrayList<PVector> lines, int imgWidth) {
  for(PVector l : lines) {
    float r = l.x;
    float phi = l.y;
    // Cartesian equation of a line: y = ax + b
    // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
    // => y = 0 : x = r / cos(phi)
    // => x = 0 : y = r / sin(phi)
    // compute the intersection of this line with the 4 borders of
    // the image
    int x0 = 0;
    int y0 = (int) (r / sin(phi));
    int x1 = (int) (r / cos(phi));
    int y1 = 0;
    int x2 = imgWidth;
    int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
    int y3 = imgWidth;
    int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
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

ArrayList<PVector> hough(int nLines, int[] accumulator, int phiDim, int rDim) {  
  ArrayList<Integer> bestCandidates = getBestCandidates(rDim, phiDim, accumulator);
  
  ArrayList<PVector> linesAsVectorArray = getLines(bestCandidates, rDim, nLines);
  return linesAsVectorArray;
}

PImage displayHoughAcc(int[] accumulator, int phiDim,  int rDim) {
  PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
  for (int i = 0; i < accumulator.length; i++) {
    houghImg.pixels[i] = color(min(255, accumulator[i]));
  }
  // You may want to resize the accumulator to make it easier to see:
  houghImg.resize(400, 400);
  houghImg.updatePixels();
  return houghImg;
}

PVector intersection(PVector line1, PVector line2) {
  double sin1 = Math.sin(line1.y);
  double sin2 = Math.sin(line2.y);
  double cos1 = Math.cos(line1.y);
  double cos2 = Math.cos(line2.y);
  float r1 = line1.x;
  float r2 = line2.x;
  
  double d = cos2 * sin1 - cos1 * sin2;
  
  int x = (int) ((r2 * sin1 - r1 * sin2) / d);
  int y = (int) ((-r2 * cos1 + r1 * cos2) / d);
  return new PVector(x, y);
}

ArrayList<PVector> getIntersections(List<PVector> lines) {
  ArrayList<PVector> intersections = new ArrayList<PVector>();
  for (int i = 0; i < lines.size() - 1; i++) {
    PVector line1 = lines.get(i);
    for (int j = i + 1; j < lines.size(); j++) {
      PVector line2 = lines.get(j);
      // compute the intersection and add it to 'intersections'
      PVector intersection = intersection(line1, line2);
      intersections.add(intersection);
    }
  }
  return intersections;
}

void drawIntersections(ArrayList<PVector> intersections) {
  for(PVector i : intersections) {
    fill(255, 128, 0);
    ellipse(i.x, i.y, 10, 10);
  }
}

ArrayList<int[]> getQuad(ArrayList<PVector> lines, int imgWidth, int imgHeight) {
  QuadGraph graph = new QuadGraph();
  graph.build(lines, imgWidth, imgHeight);
  ArrayList<int[]> quads = new ArrayList<int[]>(graph.findCycles());
  ArrayList<int[]> validQuads = new ArrayList<int[]>();
  for (int[] quad : quads) {
    PVector l1 = lines.get(quad[0]);
    PVector l2 = lines.get(quad[1]);
    PVector l3 = lines.get(quad[2]);
    PVector l4 = lines.get(quad[3]);
    PVector c12 = intersection(l1, l2);
    PVector c23 = intersection(l2, l3);
    PVector c34 = intersection(l3, l4);
    PVector c41 = intersection(l4, l1);
    if(graph.isConvex(c12, c23, c34, c41) && graph.validArea(c12, c23, c34, c41, imgWidth*imgHeight, (imgWidth*imgHeight)/100) && graph.nonFlatQuad(c12, c23, c34, c41)) {
      validQuads.add(quad);
    }
  }
  return validQuads;
}

void drawQuads(List<int[]> quads, ArrayList<PVector> lines) {
  for (int[] quad : quads) {
      PVector l1 = lines.get(quad[0]);
      PVector l2 = lines.get(quad[1]);
      PVector l3 = lines.get(quad[2]);
      PVector l4 = lines.get(quad[3]);
      PVector c12 = intersection(l1, l2);
      PVector c23 = intersection(l2, l3);
      PVector c34 = intersection(l3, l4);
      PVector c41 = intersection(l4, l1);
      // Choose a random, semi-transparent colour
      Random random = new Random();
      fill(color(min(255, random.nextInt(300)),
      min(255, random.nextInt(300)),
      min(255, random.nextInt(300)), 50));
      quad(c12.x,c12.y,c23.x,c23.y,c34.x,c34.y,c41.x,c41.y);
  }
}