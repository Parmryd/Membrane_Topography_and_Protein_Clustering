/* 
Analyzes clustered dots. 
Images made from sets with sequentially labelled dots with separate number sequences for dots inside and outside clusters - see macro Add_Dots_v01.ijm
Pick and mix - adjust total numbers & ratios (partitioning cluster:outside).
Calculate difference.
For images that have a selection the clusters are loaded first.
Standardized names i.e. 3-ClusterA.tif where the prefix is the dataset number, A and B for pairs.

Problems? Contact Jeremy Adler <jeremy.adler@igp.uu.se> or Ingela Parmryd <ingela.parmryd@gu.se>
*/

// Tidy up
run("Close All");
print("\\Clear");
run("Conversions...", " ");
roiManager("reset");
if(isOpen("Results")) close("Results");// _Close any existing Results.
macroVersion="Anal-numberedDots042b.ijm";

// The number of dataset=repeats, 8 in the settings below.
rpts=8; // Number of repeat analysis.
atRpt=1;// The repeat running.

// Create Results table:......................................................................  
// Notes, Bin (lower range), 8x repeats, Mean, std, for Clus-Clus Clus-Rand & Rand-Rand every ratio.
RtioArray=newArray(1,2,3,4,6,8,10,12,16,20,24);// ratios dots cluster:outside
//RtioArray=newArray(1,8,16,24);// Example of smaller Test ratio set.
//RtioArray=newArray(1,8);// Example of smaller Test ratio set.
//goesN=rpts; // 8 repeats for each.
setResult("Notes", 0, "test"); 
notesNxtFree=1; // Next free row.
setResult("BIN", 0, 8888); // Dummy value needed to create a column in the Results table.
//ExptNamesArray=newArray("Cls-Rn_rt_","Cls-Cls_rt_","Rn-Rn_rt_"); 

NTdots=1024*4  ;// Total number of dots to use - maybe check that sufficient dots are available.
ExptNamesArray=newArray("blank","Cls-Cls_rt_","Cls-Rn_rt_","Rn-Rn_rt_"); 

for(Expt=1;Expt<ExptNamesArray.length;Expt=Expt+1) { // Cls-Cls etc
 ExptName=ExptNamesArray[Expt];	
  for(ratio=0;ratio<RtioArray.length;ratio++) { // Ratios.
   rtio=RtioArray[ratio];
   for(n=1;n<=rpts;n++) { // Repeats of each set e.g. Cls-Rnd ratio=4.
	heading=ExptName+rtio+"_"+n;
	setResult(heading, 0, 0);
	if(n==rpts) { // Repeats of each, adds extra columns headings.
		setResult(Expt+"mean "+rtio, 0, 1);// As a marker.
		setResult(Expt+"std "+rtio, 0, 1);// As a marker.
	} // if	n	repeats==8
  } // for n
 } // for ratio
} // for Experiments - repeats
print("Anal-numberedDots030a.ijm");// Macro name.
setResult("Notes", notesNxtFree, macroVersion); updateResults();
	notesNxtFree=notesNxtFree+1; // Next free row.
Dots_Note="Dots "+NTdots;	
setResult("Notes", notesNxtFree, Dots_Note);	
	notesNxtFree=notesNxtFree+1; // Next free row.
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);	
Date="yr "+year+" mnth"+month+" dy"+dayOfMonth+ ": "+hour+":"+minute;
	setResult("Notes", notesNxtFree, Date);	
	notesNxtFree=notesNxtFree+1; // Next free row.
updateResults();
// Results Table........created........................Done   Results Table........created.....................Done

// Load cluster ROI created by Random_circles_V01.ijm - a specific location is illustrated.
//open("C:/Clustering Article 2024/Macros/clusters whole image.roi");// Original circles- no edge or overlap.
open("C:/Clustering Article 2024_B/Macros/clusters whole image.roi");
//open("E:/2024 march new computer backup/Clustering Article 2024/Macros/clusters whole image.roi");
roiManager("Add"); 
BlobsROIindex=roiManager("count")-1;
print("BlobsROIindex ",BlobsROIindex );// BlobsROIindex, location in ROI manager clusters/circles.

RtioArray=newArray(24,20,16,12,10,8,6,4,3,2,1);// Ratios analysis sequence for cluster:outside COULD DELETE check
//RtioArray=newArray(24,16,8,1);// Smaller Test ratio set.
//RtioArray=newArray(8,1);// Smaller Test ratio set.

// Create Normalization Area
guard=40;// Exclude an area affected by the asbsence of information outside the image.
wdth=2050;// 2048x2048 image plus grown by 1 pixel-for Gaussian.
ht=2050;
Xcen=wdth/2;
Ycen=ht/2;
Area=wdth-2-guard*2;// 1 pixel added around images before smoothing.
// ImageJ convolves using a pixel immediately outside an image - replicate of the edge pixel,
// which is problematic for images with a low density of dots.
// Adding a 1 pixelwide border of zero value pixels mitigates this distortion.
	run("Specify...", "width=Area height=Area x=Xcen y=Ycen centered");
	setSelectionName("Normalize");
	roiManager("Add");
	NormalizeRoiIndex=roiManager("count")-1;
		print("NormalizeRoiIndex",NormalizeRoiIndex);

// Auto load images    sets of 4 preceeded by the Number and dash    e.g.  5-RandA
//FromDir=getDir("where are images");// Activate to ask for folder.
	//print("FromDir",FromDir);
//FromDir="C:\Clustering Article 2024\NewDots"; // NOTE FAILS
FromDir="C:/Clustering Article 2024_B/NewDots/"; // works,  change "\" to "/" and add to end.
  //FromDir="E:/2024 march new computer backup/Clustering Article 2024/NewDots/";
DotImagesNamesArray=getFileList(FromDir);
//print(DotImagesNamesArray.length,DotImagesNamesArray[1]);

print("\\Clear");

// Sequentially select sets of 4 images......................ImSet.....................
NimageSets=rpts; // Number of image sets to use.
for (ImSet=1; ImSet<=NimageSets; ImSet++) {
 whichImageSet=ImSet; // Which of the 8 data sets to process.
 //whichImageSet=1; // Which of the 8 data sets to process.
 // Delete existing images.
 print(nImages);
  for(zap=nImages;zap>1;zap=zap-1) { //FAILS WHY, niImages changes, so start with last image
 	//print("      zapped",zap);
 	selectImage(zap);
 		//waitForUser("selected");
 	close();
  } // for zap
  for (chk=0; chk < DotImagesNamesArray.length; chk++) { // test all file names, open chosen set
	chkName=DotImagesNamesArray[chk];
	// Look for first occurrence of "-", read preceding number.
	dashIndex=lastIndexOf(chkName, "-");// Names include a dash  e.g. 3-ClusterA.tif.
	preFix=substring(chkName, 0, dashIndex);
		//print(preFix);
	tifIndex=lastIndexOf(chkName, ".tif"); // is .tif file
		//print(chkName,dashIndex);
		if (dashIndex>-1 && tifIndex>-1 && preFix==whichImageSet) { // Assign imageIDs.
			print("    chkName    ",chkName);
			openThisImage=FromDir+chkName;
			open(openThisImage);
			ID=getImageID();
			dataType=substring(chkName, dashIndex+1,tifIndex);
				//print("   dataType",dataType);
				if(dataType=="ClusA") ClusterID1=ID;
				if(dataType=="ClusB") ClusterID2=ID;
				if(dataType=="RandA") RandomID1=ID;
				if(dataType=="RandB") RandomID2=ID;		
		} // if
  } // chk loop
 			// waitForUser("ImageSet",ImSet); // check
  print("initial IDs",ClusterID1,ClusterID2,RandomID1,RandomID1);
  // Check if images are different.
	//run("Specify...", "width=100 height=100 x=1025 y=1025 slice=1 centered");
	//getRawStatistics(nPixels, mean, min, max, std, histogram);
	//print("image set ",ImSet,"stats mean ",mean,"std ", std);
	//run("Select None");
//} // ImSet - which image set to use.

// SET-Alter ratio   SET-Alter ratio     SET-Alter ratio 
// NB ratio 1 - random
for(varyRt=0;varyRt<RtioArray.length;varyRt=varyRt+1) { // Alter ratio cluster:outside.
rtio1=RtioArray[varyRt]; // Ratio clustered to non clustered density.
rtio2=rtio1 ; // Ratio 2nd image where ratio 1 is random.

	// waitForUser("ratio ",rtio1);// check on what is going on
	info="dots "+NTdots+" rt "+rtio1; print("info",info);

// Calculate area of selection & therefore N of dots needed: Random & Clustered.
selectImage(ClusterID1);
roiManager("select", BlobsROIindex); // clusters	
	getRawStatistics(nPixels);
	Asel=nPixels;	
run("Make Inverse");
	getRawStatistics(nPixels);
	Anonsel=nPixels;
	//print(Anonsel,nPixels);
	
print("areaSel ",Asel," areaNonSel ",Anonsel,"total",2048*2048,"%",100*Asel/(2048*2048));

run("Make Inverse"); // Invert selection  ---  area outside clusters IS THIS Needed...line 140
// Number of dots in clustered image & random image.
NwantInSel=round(NTdots*(Asel*rtio1)/(Asel*rtio1+Anonsel));// Clustered.
NwantOutSel=NTdots-NwantInSel;// Clustered
NwantInRanSel=round(NTdots*(Asel*rtio2)/(Asel*rtio2+Anonsel));// Ratio2  maybe random
NwantOutRanSel=NTdots-NwantInRanSel;// Random
print("ratio ",rtio1," dotsInside ",NwantInSel,NwantInRanSel," outside ",NwantOutSel,NwantOutRanSel," of  ",NTdots);

// Cluster1 dots with chosen ratio 1st
//     cluster dots
selectImage(ClusterID1);
run("Select None");
run("Duplicate...", "duplicate"); 
	DotsInID=getImageID();
run("Restore Selection");
	run("Clear Outside", "stack");// Remove non-clustered dots.
setThreshold(1,NwantInSel); // Dots in clusters.
run("Convert to Mask", "method=Default background=Dark black");
for (slc=1;slc<=4;slc++) {
	setSlice(slc);
	changeValues(1,255,1); 
}
run("Z Project...", "projection=[Sum Slices]");// Summmed dots, the value is N.
rename("Inside dots");
//     Outside dots
selectImage(ClusterID1);run("Duplicate...", "duplicate"); DotsOutID=getImageID();
run("Restore Selection");run("Clear", "stack");
setThreshold(1,NwantOutSel); run("Convert to Mask", "method=Default background=Dark black");
for (slc=1;slc<=4;slc++) {
	setSlice(slc);
	changeValues(1,255,1); 
}
run("Z Project...", "projection=[Sum Slices]");// Summmed dots, value is N.
rename("Outside dots");
// Combine in and outside dots.
imageCalculator("Add create 32-bit", "Inside dots","Outside dots"); 
setMinAndMax(0,2);
rename("Cluster1 ratio "+rtio1+" "+NTdots);
ClusterRtID1=getImageID();
		//print("ClusterID3 line 179",ClusterID3,ClusterID3);
		
run("Restore Selection");run("Add Selection...");run("Select None");
// Delete images.
selectImage("Inside dots"); close;
selectImage("Outside dots"); close; //DotsInID
selectImage(DotsInID); close;
selectImage(DotsOutID); close;


// Cluster2 dots with chosen ratio 2nd
// Cluster dots
selectImage(ClusterID2);
run("Select None");run("Duplicate...", "duplicate"); DotsInRID=getImageID();
run("Restore Selection");run("Clear Outside", "stack");
setThreshold(1,NwantInSel); run("Convert to Mask", "method=Default background=Dark black");
for (slc=1;slc<=3;slc++) { // Allows for coincident dots, i.e. more than one per pixel.
	setSlice(slc);
	changeValues(1,255,1); 
}
run("Z Project...", "projection=[Sum Slices]");// Summmed dots, value is N.
rename("Inside Randots");
// Outside dots
selectImage(ClusterID2);run("Duplicate...", "duplicate"); DotsOutRID=getImageID();
run("Restore Selection");run("Clear", "stack");
setThreshold(1,NwantOutSel); run("Convert to Mask", "method=Default background=Dark black");
for (slc=1;slc<=3;slc++) { // Allows for coincident dots, i.e. more than one per pixel.
	setSlice(slc);
	changeValues(1,255,1); 
}
run("Z Project...", "projection=[Sum Slices]");// Summmed dots, value is N.
rename("OutsideRan dots");setMinAndMax(0,2);

// Combine in and outside dots
imageCalculator("Add create 32-bit", "Inside Randots","OutsideRan dots"); 
//if (rtio2==1)rename("RandomDots "+NTdots);
//if (rtio2!=1)rename("RandomDots ratio "+rtio2+NTdots);
rename("Cluster2 ratio "+rtio2+" "+NTdots);
ClusterRtID2=getImageID();
run("Restore Selection");run("Add Selection...");run("Select None");

selectImage("Inside Randots"); close;
selectImage("OutsideRan dots"); close;
selectImage(DotsInRID); close;
selectImage(DotsOutRID); close;

// Random dots 1 - just select the number of dots 3rd
selectImage(RandomID1);
run("Select None");
run("Duplicate...", "duplicate"); DotsRID1=getImageID();
setThreshold(1,NTdots); run("Convert to Mask", "method=Default background=Dark black");
for (slc=1;slc<=3;slc++) { // Allows for coincident dots -more than one per pixel.
	setSlice(slc);
	changeValues(1,255,1); 
}
run("Z Project...", "projection=[Sum Slices]");// Summmed dots, value is N.
rename("Randots01 "+NTdots);
RandomUsID1=getImageID();
selectImage(DotsRID1); close;

// Random dots 2 - just select the number of dots  4th
selectImage(RandomID2);
run("Select None");
run("Duplicate...", "duplicate"); DotsRID1=getImageID();
setThreshold(1,NTdots); run("Convert to Mask", "method=Default background=Dark black");
for (slc=1;slc<=3;slc++) { // Allows for coincident dots -more than one per pixel.
	setSlice(slc);
	changeValues(1,255,1); 
}
run("Z Project...", "projection=[Sum Slices]");// Summmed dots, value is N.
rename("Randots02 "+NTdots);
RandomUsID2=getImageID();
selectImage(DotsRID1); close;

print("Before Process IDs",ClusterID1,ClusterID2,RandomID1,RandomID1);// Check
 print("new Before Process IDs",ClusterRtID1,ClusterRtID2,RandomUsID1,RandomUsID2);// Check 
//   Have two cluster images ClusterID & two RandomID with required N dots.----------------------------------------

//PROCESS   (i) Remove edge artefact, (ii) Smoothen (iii) Substract
for (whchtoDo=1;whchtoDo<=3;whchtoDo++) { // 4 options
//ExptNamesArray=newArray("blank","Cls-Cls_rt_","Cls-Rn_rt_","Rn-Rn_rt_"); 
print("           start of whchtoDo_",whchtoDo,"  ratio_",rtio1);
  if (whchtoDo==1)  {	// cluster1-cluster2
	selectImage(ClusterRtID1); run("Duplicate...", " ");grnOrigID=getImageID();rename("GrnOrig");
	selectImage(ClusterRtID2); run("Duplicate...", " ");redOrigID=getImageID();rename("RedOrig");
	addtoName1="Clus1_";print(addtoName1);
	addtoName2="Clus2_";print(addtoName2);
  }

  if (whchtoDo==2)  {	// cluster1-random1
	selectImage(ClusterRtID1); run("Duplicate...", " ");grnOrigID=getImageID();
	selectImage(RandomUsID1); run("Duplicate...", " "); redOrigID=getImageID();
	addtoName1="Clus1_";print(addtoName1);
	addtoName2="Rand1_";print(addtoName2);
  }

  if (whchtoDo==3)  {	// random1-random2
	selectImage(RandomUsID1); run("Duplicate...", " "); grnOrigID=getImageID();
	selectImage(RandomUsID2); run("Duplicate...", " "); redOrigID=getImageID();
	addtoName1="Rand1_";print(addtoName2);
	addtoName2="Rand2_";print(addtoName2);
  }
  // Naming Red and Green image
  selectImage(grnOrigID);
  	rename("Grn_"+addtoName1+"_"+rtio1);
  selectImage(redOrigID);
  	rename("Red_"+addtoName2+"_"+rtio1);
  
  print("after whchtoDo ",whchtoDo);
 print("after whchtoDo Process IDs",ClusterID1,ClusterID2,RandomID1,RandomID1);// check 
 print("after whchtoDo IDs",ClusterRtID1,ClusterRtID2,RandomUsID1,RandomUsID2);// check 
  print("after whchtoDo IDs",ClusterRtID1,ClusterRtID2,RandomUsID1,RandomUsID2);// check 
 print("after whchtoDo IDs",grnOrigID,redOrigID);
 
 


//grnOrigID=ClusterID;print('grn image ID ',grnOrigID);
//redOrigID=RandomID; print('red image ID ',redOrigID);

// Enlarge  image size by a single pixel - reduce problems with edge pixels.
nwd=getWidth()+2;
nhgt=getHeight()+2;
selectImage(redOrigID);
run("Canvas Size...", "width=nwd height=nhgt position=Center zero");// add layer of empty pixel-reduce edge effects
selectImage(grnOrigID);
run("Canvas Size...", "width=nwd height=nhgt position=Center zero");// add layer of empty pixel-reduce edge effects

// Gaussian smoothing - example radius 20
//rd=4;// first
//rdinc=8;// Increment     USE 8
gau=1;// 1- Gaussian,   0- linear
//for (rad=rd;rad<=rd*24;rad=rad+rdinc) {     //SMOOTHING LOOP OFF
selectImage(grnOrigID);
rad=20;
	selectImage(grnOrigID);
	run("Duplicate...", " ");
	if (gau==1) run("Gaussian Blur...", "sigma=rad");
	if (gau==0) run("Mean...", "radius=rad");
	if (gau==1) newgnam='Green Gau-rad '+rad;
	if (gau==0) newgnam='Green linear rad '+rad;
	rename(newgnam);
	grnGauID=getImageID();
//		run("24 step intensity3"); // LUT
		run("Enhance Contrast", "saturated=0.35");

	selectImage(redOrigID);
	run("Duplicate...", " ");
	if (gau==1) run("Gaussian Blur...", "sigma=rad");
	if (gau==0) run("Mean...", "radius=rad");
	if (gau==1) newrnam='Red Gau rad-'+rad;
	if (gau==0) newrnam='Red lin rad-'+rad;
	rename(newrnam);
	redGauID=getImageID();
//		run("24 step intensity3"); // LUT
		run("Enhance Contrast", "saturated=0.35");

	//imageCalculator("Divide create 32-bit", grnGauID,redGauID);
	//naname="Grn/Red gau "+gau;
	//	rename(naname);

	// Difference &  GP calculation   difference/sum
	//imageCalculator("Add create", grnGauID,redGauID);
	//rename("SUM");
	//SumID=getImageID();
	
	// NORMALISE - using ROI with guard area.
	// One image is rescaled - then each in the pair has an identical mean.
	// Alternatively, rescale to a standard value for all images i.g. 1000 (arbitrary).
	targetMean=100; // Adjust mean to this value.
	selectImage(grnGauID);
		roiManager("select", NormalizeRoiIndex);
		getRawStatistics(nPixels, meanNORMgrn);
			scaleGrn=targetMean/meanNORMgrn;
			run("Select None");
			run("Multiply...", "value=scaleGrn"); // No new image.
			// check
			roiManager("select", NormalizeRoiIndex);
			getRawStatistics(nPixels, meanNORMgrnAfter,min,max);
			setMinAndMax(min, max);
				print("grn afternormalization",meanNORMgrnAfter);
	selectImage(redGauID);
		roiManager("select", NormalizeRoiIndex);
		getRawStatistics(nPixels, meanNORMred);
		scaleRd=targetMean/meanNORMred;
			run("Select None");
			run("Multiply...", "value=scaleRd"); // No new image.
			// check
			roiManager("select", NormalizeRoiIndex);
			getRawStatistics(nPixels, meanNORMrdAfter,min,max);
			setMinAndMax(min, max);
				print("red afternormalization",meanNORMrdAfter);
	
	// Make DIFFERENCE image
	imageCalculator("Subtract create 32-bit", grnGauID,redGauID);
		rename("Diff ");
	run("Cent grey-8colramp 08b");// false colour for +ve and greyscale for -ve
	

	
// Output data from current image.
roiManager("select", NormalizeRoiIndex);
getRawStatistics(np,dfMean,dfmin,dfmax);
	//dfminFloor=floor(dfmin); // Calculated from the image.
		dfminFloor=-800; // Lowest bin, override to ensure data range is kept aligned.	
	//dfmaxUp=floor(dfmax)+1;
		//print(dfmin,dfminFloor);
		//print(dfmax,dfmaxUp);
		dfmaxUp=1600;// Max bin, overrride- see above.
		print(dfmax,dfmaxUp);
	selectWindow("Log");
	nBins=dfmaxUp-dfminFloor; // Number of bins in histogram.
		print("nBins",nBins);
		        // waitForUser("Before data output");
	// Column heading for data
	//ExptNamesArray=newArray("blank","Cls-Cls_rt_","Cls-Rn_rt_","Rn-Rn_rt_"); 
	//Heading=ExptNamesArray[whchtoDo]+rtio1+"_"+atRpt;
	Heading=ExptNamesArray[whchtoDo]+rtio1+"_"+ImSet;	
	
		// waitForUser("Check Results heading", Heading);	
		
	getHistogram(valuesArray, countsArray, nBins, dfminFloor,dfmaxUp);// Reads and bins data.
		Eentries=0; // Count the number of entries.
		DataN=valuesArray.length;// Number bins-datapoints.
		for(g=0;g<DataN;g=g+1)  { // Data output to Results.
			//print(g,valuesArray[g],countsArray[g]);
			setResult("BIN", g, valuesArray[g]);// Value range of Bin (lower limit) RUN ONCE
			//setResult("Cls-Rn_rt_1_3", g, countsArray[g]);// Data output.	
			setResult(Heading, g, countsArray[g]);// Data output.	
			
			Eentries=Eentries+countsArray[g];
		} // For g	
		print("Number of pixels",Eentries);
	
		selectWindow("Log");
		updateResults();
// DATA output complete.    	   		
		    
	// Delete unwanted images, example with keeping the first nine.
	ImageListArray=getList("image.titles");	
	Array.print(ImageListArray);
	print("  before deletion N images",	ImageListArray.length);
		//selectImage(ImageArray[9]); test
	for(dl=9;dl<ImageListArray.length;dl=dl+1) {
		print("dl loop ",dl);
		delthisName=ImageListArray[dl];
		print(dl,"delete image ",delthisName);
		selectImage(delthisName);
		close();
		print("      deleted image ",delthisName);
	}
		//waitForUser("END of WhchtoDo "+whchtoDo);
//EndWchtoDo
 } //WhchtoDo   Three runs with the same ratio.
 
 // Delete unwanted images, example with keeping the first five.
	ImageListArray=getList("image.titles");	
	Array.print(ImageListArray);
	print("  before deletion N images",	ImageListArray.length);
		//selectImage(ImageArray[9]); test
	for(dl=5;dl<ImageListArray.length;dl=dl+1) {
		print("dl loop ",dl);
		delthisName=ImageListArray[dl];
		print(dl,"delete image ",delthisName);
		selectImage(delthisName);
		close();
		print("      deleted image ",delthisName);
	}
	//waitForUser("end of ratio_",rtio1);
// afterWhchtoDo
 
 //print("final IDs",ClusterID1,ClusterID2,RandomID1,RandomID1);// check
 //selectImage(Cluster1ID);
 //waitForUser(Cluster1ID,Cluster3ID);
 
 print("final IDs",ClusterID1,ClusterID2,RandomID1,RandomID1);// check
 //
 } // for(varyRt
} // ImSet    - which image set to use   MAIN LOOP	

waitForUser("Macro", "finished    SAVE RESULTS");	

