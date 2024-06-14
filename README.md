**Random_circles_v01.ijm**

The number of circles, their radius and the image size form the name of the final ROI.

The macro calls the RandomJ plugin that requires the imagescience plugin version 3.0.0 or higher, both are found at https://imagescience.org/meijering/software/randomj and the developer should be acknowledged as stated on the webpage.

The macro was first used in https://doi.org/10.21203/rs.3.rs-4238586/v1. Please cite when used.




**Add_dots_v01.ijm**

Adds dots, up to 65535 in random images. In images with clusters a higher number is possible - clusters have their own sequence of localisations. 

Coincident dots are possible - up to four per pixel, line 37, checks start lines 75 & 108.

Makes four images, (i) 2X random dots in and outside Clusters, (ii) 2X random dots.

Each image is 2048,2048, four images in total, approximately 4 million pixels.

The ROI created by the ImageJ macro "Random_circles.ijm" is loaded.

Random numbers from (RandomJ Uniform), 64000,2,1. Use for x and y coordinates.

The dots in the two areas (cluster or outside) are numbered sequentially.

Thresholding then allows any ratio (cluster:outside) to be produced.
For multiple runs - repeat line 34.
 
Each set of four images is numbered with "N-" at start of name. This is used for subsequent automatic processing.

A location for saving the images is requested once, line 135.

The macro was first used in https://doi.org/10.21203/rs.3.rs-4238586/v1. Please cite when used.




**Analyse_numbered_dots_v01.ijm**

Analyzes clustered dots.

Images made from sets with sequentially labelled dots with separate number sequences for dots inside and outside clusters - see macro Add_dots_v01.ijm.

Pick and mix - adjust total numbers and ratios (partitioning cluster:outside).

For images that have a selection the clusters are loaded first.

Calculate difference.

Standardized names i.e. 3-ClusterA.tif where the prefix is the dataset number, A and B for pairs.

The macro was first used in https://doi.org/10.21203/rs.3.rs-4238586/v1. Please cite when used.




**Nearest_neighbour_missing_dots_v01.ijm**

Nearest neighbor analysis - missing fluorophores.

Output all data for box and whisker plot.

600x600 image, uses only central 512x512 for analysis.

Creates a random only set and a set of random & adjacent localisations.

Adjacent localisations positioned at one of the eight neighbors.

Localisations are not permitted to coincide - max one molecule per pixel.

This macro uses the plugin RandomJ that can be found at
https://imagescience.org/meijering/software/randomj/ and the developer should be acknowledged as stated on the webpage.

The macro was first used in https://doi.org/10.21203/rs.3.rs-4238586/v1. Please cite when used.


