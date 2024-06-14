/* Add random circles

Problems? Contact Jeremy Adler <jeremy.adler@igp.uu.se> or Ingela Parmryd <ingela.parmryd@gu.se>

NOTE  calls randomJ plugin that requires the imagescience plugin version 3.0.0 or higher,
both are found at https://imagescience.org/meijering/software/randomj and the developer should be acknowledged as stated on the webpage.
The  number of circles, their radius and the image size form the final ROIs name.
*/

roiManager("reset");
run("Close All");
print("\\Clear");
setForegroundColor(255,255,255);

NcirclesWanted=52; // Number of circles.
ImageSz=2048;// Size of image.
CircRad=24;//Radius of circle.
Diam=CircRad*2;
// Area of circle
newImage("Temp", "38-bit black", CircRad*3, CircRad*3,1);
centre=round(CircRad*3/2);
run("Specify...", "width=Diam height=Diam x=centre y=centre oval centered");
getRawStatistics(CircArea);

// Default: circles do not overlap and are fully within image.
EdgeOverlap=0; // Set to 1 to permit edge touching. Not possible in this version see lines 54-57.
CircOverlap=0; // Set to 1 to permit circles overlapping. Not possible in this version see lines 54-57.


newImage("Circles", "8-bit black",ImageSz,ImageSz, 1);// for circles
// Random numbers for X and Y location of circles.
largest=ImageSz-1; // Max value for random numbers.
print(largest);
newImage("RandomX", "32-bit black", 1024,1,1);
	run("RandomJ Uniform", "min=0 max=largest insertion=Additive");
	rename("Random-Xs");
newImage("RandomY", "32-bit black", 1024,1,1);
	run("RandomJ Uniform", "min=0 max=largest insertion=Additive");
	rename("Random-Ys");

selectImage("Circles");
NcircAdded=0; // Number added.
setBatchMode(1);
for(i=0;i<1024;i=i+1) {
	selectImage("Random-Xs");
		xTest=getPixel(i, 0);
	selectImage("Random-Ys");
		yTest=getPixel(i, 0);
	//makeSelection(1, xpoints, ypoints);
	
	selectImage("Circles");
	run("Specify...", "width=Diam height=Diam x=xTest y=yTest oval centered");// Randomly positioned circular areas.
	run("Add Selection...");// Show potential circles as overlay.
	// Avoid overlap.
	getRawStatistics(nPixels, mean, min, max);// Read values within potential circle.
		//print("area",nPixels); // Check and reactivate line if needed.
		//print(max);
		//print(i,max);
	// TEST if circle meets specifications.
	// max==0 no overlap with another circle.
	// nPixels>=CircArea   If a circle extends beyond image, its area will be smaller.
	if(max==0 && nPixels>=CircArea) { // Checks if a circle is empty and completely inside the image. Could be modified to allow overlap.
		run("Fill", "slice");
		print("           ",i,"Add");
		drawString(i, xTest, yTest);
		NcircAdded=NcircAdded+1;// Update circles count.
	
	run("Select None");
	}
	if(NcircAdded==NcirclesWanted) break; // Reached target N of circles.
	//run("Fill", "slice");
	//run("Select None");
}
setBatchMode(0);
print("out of loop");
run("Overlay Options...", "stroke=green width=0 fill=none set apply");// All tested circle shown in green.
selectImage("Circles");
run("Create Selection");
ROIname="N"+NcircAdded+" R"+CircRad+" Im"+ImageSz; //The name includes information.
setSelectionName(ROIname);
roiManager("Add");
waitForUser("Finished   - ROI in ROI Manager");




