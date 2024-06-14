/* 
Nearest neighbor analysis   - missing fluorophores.
Output all data for box and whisker plot.
Random distributions
600x600 image, uses only central 512x512 for analysis.
Creates a random only set and a set of random & adjacent localisations.
Adjacent localisations positioned at one of the eight neighbors.
Localisations not permitted to coincide - max one molecule per pixel.

Problems? Contact Jeremy Adler <jeremy.adler@igp.uu.se> or Ingela Parmryd <ingela.parmryd@gu.se>

This macro uses the plugin RandomJ that can be found at
https://imagescience.org/meijering/software/randomj/ and the developer should be acknowledged as stated on the webpage.
*/

// Tidy up
run("Close All");
print("\\Clear");
run("Conversions...", " ");
roiManager("reset");
if(isOpen("Results")) close("Results");// Close any existing Results.
run("Conversions...", " ");

macroVersion="NearestN_missingDots24.ijm";
	setResult("notes", 0,macroVersion );
	print(macroVersion);
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
dayOfMonth=dayOfMonth+1; // Month 1 is returned as zero.
month=month+1; // Numbering of months starts at zero!
today="yr "+year+" Month "+month+" dy "+dayOfMonth;
	setResult("notes", 1,today);
	updateResults();
ndots=4048;
XYsize=600;
AnalXYsz=512; // Analysis area - avoids edge effects.

newImage("BaseImage", "16-bit black", XYsize,XYsize, 1);
newImage("random", "16-bit black", ndots+512,1, 1);// Extra dots - repeat to avoid double hits.

// Add random dots to three images.
namesArray=newArray("RandomImA","RandomImB","AdjacentIm1","AdjacentIm2");
// Offset for paired dataset - localizations cannot coincide.
XoffsetArray=newArray(-1,0,1,-1,1,-1,0,1); // The eight possible offset locations.
YoffsetArray=newArray(1,1,1,0,0,-1,-1,-1);
// Main Loop runs for three images the 4th has nearest neighbours.
for (goes = 0; goes < 3; goes++) {   // Make three images with random dots.
print("GOES",goes);
selectImage("random");
	run("RandomJ Uniform", "min=0.0 max=600 insertion=Additive");
	rename("RandomX_"+goes);	
		UseX=getTitle();
selectImage("random");
	run("RandomJ Uniform", "min=0.0 max=600 insertion=Additive");
	rename("RandomY_"+goes);
		UseY=getTitle();
if (goes==2) { // First paired image, make image to save XY locations.
	newImage("Paired_Ist_XYs", "8-bit black", ndots, 2, 1);		
}
	
selectImage("BaseImage");
run("Duplicate...", " ");
	UseID=getImageID();
setBatchMode(1);
//for= (i = 0; i < ndots; i=i+1) {
Nadded=1;  // Number added.
Ndups=0;
randAvalue=0;
	for (i = 0; i < ndots+200; i=i+1) {
	  selectImage(UseX);
	 	 xat=floor(getPixel(i, 0));
		//print(i,xat);
	  selectImage(UseY);
		  yat=floor(getPixel(i, 0));
		//print(i,yat);
	  selectImage(UseID);
	  currentValue=getPixel(xat,yat); // Avoid double localisations, i.e. two molecules in same pixel.
	  if(goes==1) {
	  	selectImage("RandomImA");
	  	randAvalue=getPixel(xat,yat);// Same location in partner image.
	  }
	  	  selectImage(UseID);
	  if (currentValue==0 && randAvalue==0) {  // Can add new location.
	  	setPixel(xat, yat, Nadded);	
	  	if(goes==2) {  // First paired image, save the locations - reuse when paired pixel is added.
	  		selectImage("Paired_Ist_XYs");		
	  	} // goes==2
	  	if(Nadded==ndots) break; 
	  	Nadded=Nadded+1; // increment
	  }
	  randAvalue=0;
	} // for i
	// Check how many added.
	print(goes,"added",Nadded,"duplicates ",Ndups);
setBatchMode(0);
rename(namesArray[goes]);
getRawStatistics(nPixels, mean, min, max, std, histogram);
setMinAndMax(0,1);
} // for goes loop       adding dots to three images
selectWindow("Log");
// End of goes Loop.

// Three images created.

// Create 4th image with adjacent dots, offset by 1 pixel.-----------------------------------------
// Look around points for empty pixel.
selectImage("AdjacentIm1");
run("Duplicate...", " ");
	Adjacent2_ID=getImageID();
	rename("AdjacentIm2");
// Get coordinates of all initial points.
setThreshold(1,65000);
run("Create Selection");
setSelectionName("Adj_Orig");
roiManager("Add");
Roi.getContainedPoints(Adj_X_Array, Adj_Y_Array); // xys of original points.
run("Select None");
run("Convert to Mask");
run("16-bit");
	changeValues(1,65000, 65000); // Value now 65000.
// Offset for adjacent locations & random offset selection.
XoffsetArray=newArray(-1,0,1,-1,1,-1,0,1); // Eight offset locations.
YoffsetArray=newArray(1,1,1,0,0,-1,-1,-1);
 // Adjacent image and random numbers.
// Random distribution for adjacent2	- random neigbors
selectImage("random");
	run("RandomJ Uniform", "min=0.0 max=8 insertion=Additive");// Select between eight options.
		rename("Adj_Offset_Rnd");				
		Adj_Offset_Rnd_ID=getImageID();
UseID=getImageID();
	setBatchMode(1);	
	// For each location.	
addValue=0; // Value of new pixel.
	// for (i = 0; i < ndots+200; i=i+1) {
setBatchMode(1);
//for (i = 0; i < 64; i=i+1) { // TEST
for (i = 0; i < ndots+200; i=i+1) {	
	  //selectImage(Adj_Offset_ID);
	  // original dot
	  xat=floor(Adj_X_Array[addValue]); // Location - to add end new adjacent pixel, reused if previous offset failed.
	  yat=floor(Adj_Y_Array[addValue]); // Use [addValue] to repeat search when previous go failed to insert point.
		//print(i,yat);
	  selectImage(Adjacent2_ID);
		//setPixel(xat, yat, 1);	// as test
		
	 // Find & add adjacent - offset dots.	
		selectImage(Adj_Offset_Rnd_ID); // Which of the eight neighbors to test.
		whichAdjacent=floor(getPixel(i, 0)); // 0-8 range    Changes each time loop runs.
			xatOff=floor(xat+XoffsetArray[whichAdjacent]);
			yatOff=floor(yat+YoffsetArray[whichAdjacent]);
			// Check current value - must be zero to insert new adjacent dot.
		 selectImage(Adjacent2_ID); // Locations image.	
			doInsert=getPixel(xatOff,yatOff);
				//print(i,"test offset",whichAdjacent,"      value",doInsert,"pos ",xatOff,yatOff);
				
			//if(doInsert==0) { // not occupied - add, or run loop again with same position find another
				//waitForUser(" "+doInsert+" non zero at "+xatOff+" "+yatOff);	
			// Is location in the image or not.	
				if(doInsert==0 && xatOff>-1 && yatOff>-1 && xatOff<600 && yatOff<600) {	// also test within image
					addValue=addValue+1; // Added a location - next value insert at.	
					setPixel(xatOff,yatOff, addValue); // Replace zero with new value.
					selectImage(Adjacent2_ID);  
					setPixel(xatOff, yatOff, addValue); // Different value.	
					//addValue=addValue+1; // Added a location - next value insert at.	
						print("addValue",addValue);
				} // Inserted new pixel.
	 // Find location to add new point, retest if initial is already occupied.
	 if(addValue==ndots) break
 } // For i insert into adjacent offset to image three, first adjacent image.
 setBatchMode(0);
 print("4th image dots added ",addValue);
selectImage(Adjacent2_ID); // Locations image.	
// Remove 65000 values - marked previous (AdjacentIm1) locations.
changeValues(65000, 65000,0);

// Have 4th offset image for paired molecules..........................

// Include a probability - of dots being found.
setBatchMode(0);
// Make ROI of dots to measure from.
selectImage("RandomImB");
run("Specify...", "width=AnalXYsz height=AnalXYsz x=300 y=300 centered");// Only use central 512x512.
setSelectionName("AnalArea");
	roiManager("Add");
	AnalAreaIndex=roiManager("count")-1; // Use index to select ROI later.
run("Select None");	
	
// Measure from dots - limit measurement to dots within analysis area.
// Use binary image of dots, analysis area.
for(rn=1;rn<3;rn=rn+1) {
 print("rn",rn);
  if(rn==1) selectImage("RandomImB");	
  if(rn==2) selectImage("AdjacentIm2");	
run("Duplicate...", "title=FromDots");
getRawStatistics(nPixels, mean, min, max, std, histogram);
setThreshold(1, max);
run("Convert to Mask");
roiManager("select", AnalAreaIndex);
	run("Clear Outside");
		run("Create Selection"); // Area to make measurements from.
		  if(rn==1) setSelectionName("RandB");
		  if(rn==2) setSelectionName("AdjB");
		roiManager("Add");
	      if(rn==1)	RandBIndex=roiManager("count")-1; // Use index to select ROI later.
		  if(rn==2)	AdjBIndex=roiManager("count")-1; // Use index to select ROI later.
		run("Select None");	
		roiManager("select",AnalAreaIndex);
		getRawStatistics(nPixels, mean, min, max, std, histogram);	
		RandomNdots=(mean*AnalXYsz*AnalXYsz)/255;
		print(rn,"RandomNdots",RandomNdots); // number use 
		  if(rn==1)	setResult("notes", 2, RandomNdots);
		  if(rn==2)	setResult("notes", 3, RandomNdots);
		updateResults();
} // loop run    turn binary image with dots into ROI
		


// MEASURE nearest neighbours, median, interquartile, max and min. ----------------------------------------------------------
// Alter number of remaining dots and make Distance map.
ndots=4048;

// Nearest first dataset.
selectImage("RandomImA");
ndots=4048;
run("Duplicate...", "title=DTbaseIm");
print("\\Clear");
print("RandomImA & B");
Rsltindex=0;
for(frac=100;frac>4;frac=frac-10) {   // % dots detected.
	Nselected=ndots*frac/100;
		setResult("frac", Rsltindex, frac); // Insert column title with default value.
	selectImage("RandomImA");
	run("Duplicate...", "title=DTbaseIm");
	setThreshold(1,Nselected);
	run("Convert to Mask");
		//wait(1111);
	run("Invert");
	run("Options...", "iterations=1 count=1 black edm=32-bit");
	run("Distance Map");
	rename("Dmap-"+Nselected);
		UseDmpID=getImageID();
				setBatchMode(1);
		// INSERT xy read values INTO AN ARRAY, THEN SORT THE ARRAY
		dataArray=newArray(ndots); // Max possible values.
		Array.fill(dataArray, 999);
		//Array.print(dataArray);
		print("insert data");
		addDataIndex=0;
		// use ROI
		roiManager("select", RandBIndex);
			Roi.getContainedPoints(xpointsArray, ypointsArray);
		for (xy = 0; xy <xpointsArray.length; xy=xy+1) { // Check each localization and insert into an array.
				xat=xpointsArray[xy];
				yat=ypointsArray[xy];
			selectImage(UseDmpID);
				Lxy=getPixel(xat, yat); // Distance to nearest.
				//	setResult(frac, Rsltindex, Lxy);
					//print(xy,"L",Lxy);
					//drawRect(xat, yat, 1,1);
					dataArray[addDataIndex]=Lxy;// Save in an array.
				//Rsltindex=Rsltindex+1;
				addDataIndex=addDataIndex+1;			
		} // For xy.
		// Extract measurements from the data Array.
		if (frac==100) waitForUser("measurements",addDataIndex); // Show number of points.
		print("now trim");
		trimmedArray=Array.trim(dataArray,	addDataIndex);
		print("trimmed");
		//Array.print(trimmedArray);
		print("now sort");
		// sort array
		sortedArray=Array.sort(trimmedArray);
		print("trimmed");
		//Array.print(trimmedArray);
		print("trimmed & sorted");
		//Array.print(sortedArray);
		print("sorted");
		//   print out
		print("look at arrays");
		print("data  trimmed sorted");
		print("orig  trim sortd" );
		Nres=sortedArray.length;
		//for(d=0;d<Nres;d=d+1) {
		//	print(d,dataArray[d],trimmedArray[d],sortedArray[d]);
		// }
		//Values from sorted data, difference of Q2 and Q3 from median
		Array.getStatistics(sortedArray, min, max, meanL, stdDev); // Mean is more relevant than the median.
		minL=sortedArray[0];
			setResult("MinL", Rsltindex, minL);
		medianL=sortedArray[Nres/2];
			setResult("medianL", Rsltindex, medianL);
		Q2Ldiff=abs(medianL-sortedArray[Nres*0.25]); // Difference from median.
		Q2L=sortedArray[Nres*0.25];
			setResult("Q2L", Rsltindex, Q2Ldiff);	
			setResult("medianL", Rsltindex, medianL);
		Q3Ldiff=abs(medianL-sortedArray[Nres*0.75]); // Difference from median.
		Q3L=sortedArray[Nres*0.75];	
			setResult("Q3L", Rsltindex, Q3Ldiff);
		maxL=sortedArray[Nres-1];	
			setResult("maxL", Rsltindex, maxL);
			setResult("meanL", Rsltindex, meanL);
		maxL95=sortedArray[Nres*0.95];
		minL05=sortedArray[Nres*0.05];
			setResult("minL05", Rsltindex, minL05);
			setResult("maxL95", Rsltindex, maxL95);
		
		//print(" res",minL,"Q2L",Q2L,"median",medianL,"Q3L",Q3L,maxL);
		selectWindow("Log");
		//sgfghs
		//print("  ");"
		//wait(1000);
	Rsltindex=Rsltindex+1;
	setBatchMode(1);
	updateResults();
} // frac loop
updateResults();
selectWindow("Log");

// Before second dataset.
selectImage("AdjacentIm1");
ndots=4048;
run("Duplicate...", "title=DTbaseIm");
print("\\Clear");
print("RandomImA & B");
Rsltindex=0;
for(frac=100;frac>4;frac=frac-10) {   // % dots detected.
	Nselected=ndots*frac/100;
		setResult("frac", Rsltindex, frac); // Insert column title with default value.
	selectImage("AdjacentIm1");
	run("Duplicate...", "title=DTbaseIm");
	setThreshold(1,Nselected);
	run("Convert to Mask");
		//wait(1111);
	run("Invert");
	run("Options...", "iterations=1 count=1 black edm=32-bit");
	run("Distance Map");
	rename("DmapAdj-"+Nselected);
		UseDmpID=getImageID();
				setBatchMode(1);
		// Insert xy read values into and array, then sort the array.
		dataArray=newArray(ndots); // Max possible values.
		Array.fill(dataArray, 999);
		//Array.print(dataArray);
		print("insert data");
		addDataIndex=0;
		// use ROI
		roiManager("select", AdjBIndex);
			Roi.getContainedPoints(xpointsArray, ypointsArray);
		for (xy = 0; xy <xpointsArray.length; xy=xy+1) { // Check each localization and insert into an array.
				xat=xpointsArray[xy];
				yat=ypointsArray[xy];
			selectImage(UseDmpID);
				Lxy=getPixel(xat, yat); // Distance to nearest.
				//	setResult(frac, Rsltindex, Lxy);
					//print(xy,"L",Lxy);
					//drawRect(xat, yat, 1,1);
					dataArray[addDataIndex]=Lxy;// Save in an array.
				//Rsltindex=Rsltindex+1;
				addDataIndex=addDataIndex+1;			
		} // For xy.
	//Stop.	
		// Extract measurements from the data Array.
		if (frac==100) waitForUser("measurements",addDataIndex); // Show number of points.
		print("now trim");
		trimmedArray=Array.trim(dataArray,	addDataIndex);
		print("trimmed");
		//Array.print(trimmedArray);
		print("now sort");
		// Sort array.
		sortedArray=Array.sort(trimmedArray);
		print("trimmed");
		//Array.print(trimmedArray);
		print("trimmed & sorted");
		//Array.print(sortedArray);
		print("sorted");
		//   print out
		print("look at arrays");
		print("data  trimmed sorted");
		print("orig  trim sortd" );
		Nres=sortedArray.length;
		//for(d=0;d<Nres;d=d+1) {
		//	print(d,dataArray[d],trimmedArray[d],sortedArray[d]);
		// }
		//Vvalues from sorted data   diff, difference of Q2 and Q3 from median.
		Array.getStatistics(sortedArray, min, max, meanL, stdDev); // mean is more relevant than the median
		minL=sortedArray[0];
			setResult("MinLAdj", Rsltindex, minL);
		medianL=sortedArray[Nres/2];
			setResult("medianLAdj", Rsltindex, medianL);
		Q2Ldiff=abs(medianL-sortedArray[Nres*0.25]); // difference from median
		Q2L=sortedArray[Nres*0.25];
			setResult("Q2LAdj", Rsltindex, Q2Ldiff);	
			setResult("medianLAdj", Rsltindex, medianL);
		Q3Ldiff=abs(medianL-sortedArray[Nres*0.75]); // difference from median
		Q3L=sortedArray[Nres*0.75];	
			setResult("Q3LAdj", Rsltindex, Q3Ldiff);
		maxL=sortedArray[Nres-1];	
			setResult("maxLAdj", Rsltindex, maxL);
			setResult("meanLAdj", Rsltindex, meanL);
		maxL95=sortedArray[Nres*0.95];
		minL05=sortedArray[Nres*0.05];
			setResult("minL05Adj", Rsltindex, minL05);
			setResult("maxL95Adj", Rsltindex, maxL95);
		//print(" res",minL,"Q2L",Q2L,"median",medianL,"Q3L",Q3L,maxL);
		selectWindow("Log");
		//sgfghs
		//print("  ");"
		//wait(1000);
	Rsltindex=Rsltindex+1;
	updateResults();
	setBatchMode(0);
} // frac loop
updateResults();
selectWindow("Log");





