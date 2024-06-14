/* 
Adds dots, up to 65535 in random images. In images with clusters a higher number is possible - 
clusters have their own sequence of localisations. 
Coincident dots are possible - up to four per pixel, line 37, checks start lines 75 & 108.
Make four images, (i) 2X random dots in and outside Clusters,(ii) 2X random dots. 
Each image is 2048,2048, four images in total, approx 4 million pixels.
The ROI created by the ImageJ macro "Random_circles.ijm" is loaded.
Random numbers from (RandomJ Uniform), 64000,2,1. Use for x and y coordinates. 
The dots in the two areas (cluster or outside) are numbered sequentially. 
Thresholding then allows any ratio (cluster:outside) to be produced.
For multiple runs - repeat line 34.
Each set of four images is numbered with "N-" at start of name. This is used for subsequent automatic processing.
A location for saving the images is requested once, line 135.

Problems? Contact Jeremy Adler <jeremy.adler@igp.uu.se> or Ingela Parmryd <ingela.parmryd@gu.se>
*/

MacroVersion="AddDots -USe08a.ijm";
run("Close All");
print("\\Clear");
roiManager("reset");

// Load ROI created by Random_Circles.ijm  - a specific location is illustrated below.
open("C:/Clustering Article 2024/Macros/clusters whole image.roi");// Change to the desired ROI.
roiManager("Add"); 
BlobsROI=roiManager("count")-1;print("BlobsROI ",BlobsROI );// BlobsROI is the ROI manager index for clusters/circles and opens the last entry.
// Four images to hold the dots.
namesArray=newArray("blank","ClusA","ClusB","RandA","RandB");
IDarray=newArray(5); // hold id numbers

newImage("XYpos Blank", "16-bit black",64000 ,2, 1);// Base image for XY-positions.
setBatchMode(1);

for(repeat=1;repeat<9;repeat++) { // Set to run 8 times - creates four images in each run.
  for (mkIm=1;mkIm<=4;mkIm=mkIm+1) { // Four images created 2x Clustered & 2x Random.
	print("mkIm",mkIm);
	//waitForUser("MainLoop "+mkIm);
	newName="Blank"+mkIm;
	newImage(newName, "16-bit black", 2048,2048,4);// Four layers-enable up to four coincident dots.
	//roiManager("select", BlobsROI);// Add ROI to blank image.
	//waitForUser("OK");
	
	if (mkIm==1) ClusA_ID=getImageID();
	if (mkIm==2) ClusB_ID=getImageID();
	if (mkIm==3) RandomA_ID=getImageID();
	if (mkIm==4) RandomB_ID=getImageID();
	IDarray[mkIm]=getImageID();
	nameIt=namesArray[mkIm];
	rename(nameIt);
	run("Select None");	
	AddToImID=getImageID; 
	//waitForUser("MainLoop "+mkIm+nameIt+" ID "+AddToImID);

// Random XYpositions
	selectImage("XYpos Blank");
	run("RandomJ Uniform", "min=0.0 max=2047 insertion=Additive");
	// Note RandomJ generates a new image.
		XYposID1=getImageID();// First set of random numbers.
		//selectImage("XYpos Blank");
		//close();
		//selectImage(XYposID1);
		
// Add dots to two Cluster images.
if(mkIm<3) {
selectImage(AddToImID);
run("Restore Selection");
//waitForUser("Cluster "+mkIm+" "+AddToImID);
NClusadded=0; // Number in cluster.
NnonClusadded=0; // Number outside clusters.
 for (nMol=1;nMol<64000;nMol++) {
	//print("nMol ",nMol," locals ",Nadded);
	selectImage(XYposID1);
	xpos=round(getPixel(nMol,0));
	ypos=round(getPixel(nMol,1));//print(xpos,ypos);
	
	selectImage(AddToImID); // 
	// Find unoccupied layer for new dot.
	for (w=1;w<=4;w++) {
		setSlice(w);
		if (getPixel(xpos,ypos)==0) break; // Use slice with an empty pixel.
		//print("duplicate at ",w,xpos,ypos);	
	}
	
	// Add dots to CLUSTER image.
	if (selectionContains(xpos,ypos)==1) { // Determines if the xy is in the designated clusters or not.
		NClusadded=NClusadded+1; //Add those mols nominally in cluster (ROI).
		//print("in cluster",xpos,ypos,"add",NClusadded);
		setPixel(xpos,ypos,NClusadded); // Each dot in the clusters is sequentially numbered.
	}
	// Outside Clusters
	if (selectionContains(xpos,ypos)==0) { // Not in the cluster.
		NnonClusadded=NnonClusadded+1; //Add those mols nominally outside clusters.
		setPixel(xpos,ypos,NnonClusadded); // Each dot outside the clusters is sequentially numbered.
	}
	
  } // nMol
print(mkIm,"added Cluster ",NClusadded," nonclus ",NnonClusadded  );
} // if mkIm<3   clustered


// Add dots to RANDOM image.
if(mkIm>2) {
selectImage(AddToImID); //
run("Select None");
//waitForUser("Random "+mkIm);
Nadded=0;
  for (nMol=1;nMol<64000;nMol++) {
	//print("nMol ",nMol," locals ",Nadded);
	selectImage(XYposID1);
	xpos=round(getPixel(nMol,0));// Slice with empty location.
	ypos=round(getPixel(nMol,1));//print(xpos,ypos);
	
	selectImage(AddToImID);
	// Find unoccupied layer.
	for (w=1;w<=4;w++) {
		setSlice(w);
		if (getPixel(xpos,ypos)==0) break; // 
		print("duplicate at ",w,xpos,ypos);	
	}
	// Add to image.	
		Nadded=Nadded+1; //Add those dots nominally in BlobsROI.
		setPixel(xpos,ypos,Nadded);
  } // nMol loop
print(mkIm,"added Random ",Nadded);

} // if mkIm>2 non clustered

setBatchMode("exit and display");
selectImage(XYposID1);

//waitForUser("is XYposID1 the current image?");
	close(); // Close XYpositions.
//waitForUser("is XYposID1 deleted");
setBatchMode(1);	
} // main loop   mkIm

setBatchMode("exit and display");
print("MacroVersion",MacroVersion);

// SAVE 4 images
waitForUser("FINISHED     save images");
if(repeat==1) SaveHere=getDir("Save Images to");
print("SaveHere",SaveHere);
for (i = 1; i < 5; i++) { // Each of the four images.
	selectImage(IDarray[i]);	
	nme=namesArray[i];
		// print("name",nme);
		nameUse=getTitle();
		// print("nameUse",nameUse);
	SaveTo=SaveHere+repeat+"-"+nme+".tif";// Name preceeded by number.
		//print(SaveTo);
		save(SaveTo);
		close();// Close selected image.
} // End of i-loop.
//waitForUser("after save");

} // Repeat loop starting in line 32.
// Tidy up.
selectImage("XYpos Blank"); // Blank image used as base for XYpos & RandomJ.
close();
waitForUser("All DONE");
