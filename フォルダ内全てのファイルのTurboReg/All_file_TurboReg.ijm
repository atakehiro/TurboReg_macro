
inputdir = getDirectory("input_folder"); //レジスト前のファイルがある
outputdir = getDirectory("output_folder"); //レジスト後のファイルを入れる

setBatchMode(true); 
print("TurboReg was Started");
list1=getFileList(inputdir);
for (i=0; i<list1.length; i++) {
	file = list1[i];
	print("Present file is " + file);
	time_stack_TurboReg(inputdir, outputdir, file);
	close("*");
}
print("TurboReg was Finished");
setBatchMode(false); 

function time_stack_TurboReg(inputdir, outputdir, file) {
	regstack = "reged_"  + file;
	open(inputdir + "/" + file);
	selectWindow(file);
	Stack.getDimensions(width, height, channels, nan ,slice);
	bit = bitDepth();
	run("Z Project...", "projection=[Average Intensity]");
	rename("Target");
	for (k=1; k<=slice; k++) {
		selectWindow(file);
		setSlice(k);
		run("Duplicate...", "title=currentFrame");
		
		run("TurboReg ",
		"-align " // Register the two images that we have just prepared.
		+ "-window " + "currentFrame" + " "// Source (window reference).
		+ "0 0 " + (width - 1) + " " + (height - 1) + " " // No cropping.
		+ "-window " + "Target" + " "// Target (file reference).
		+ "0 0 " + (width - 1) + " " + (height - 1) + " " // No cropping.
		+ "-rigidBody "
		+ (width / 2) + " " + (height / 2) + " " // Source translation landmark.
		+ (width / 2) + " " + (height / 2) + " " // Target translation landmark.
		+ "0 " + (height / 2) + " " // Source first rotation landmark.
		+ "0 " + (height / 2) + " " // Target first rotation landmark.
		+ (width - 1) + " " + (height / 2) + " " // Source second rotation landmark.
		+ (width - 1) + " " + (height / 2) + " " // Target second rotation landmark.
		+ "-showOutput");
		selectWindow("currentFrame");
		close();
		selectWindow("Output");
		run("Duplicate...", "title=registered");
		selectWindow("Output");
		close();
		if (k==1) {
			run("Duplicate...", "title=" + regstack);
			selectWindow("registered");
			close();
		}else{
		    run("Concatenate...", "  title=" + regstack + 
			" image1=" + regstack + " image2=registered image3=[-- None --] image4=[-- None --]");
		}
	}
	selectWindow(regstack);
	run(bit + "-bit");
	saveAs("Tiff", outputdir + "/" + regstack);
	close();
}