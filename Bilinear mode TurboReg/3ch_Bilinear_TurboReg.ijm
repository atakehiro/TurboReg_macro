
inputdir = getDirectory("input_folder"); //レジスト前のファイルがある
outputdir = getDirectory("output_folder"); //レジスト後のファイルを入れる

run("Set Measurements...", "area mean min redirect=None decimal=9");
setBatchMode(true); 
print("TurboReg was Started");
list1=getFileList(inputdir);
for (i=0; i<list1.length; i++) {
	file = list1[i];
	print("Present file is " + file);
	bilinear_3ch_TurboReg(inputdir, outputdir, file);
	close("*");
}
print("TurboReg was Finished");
setBatchMode(false); 

function bilinear_3ch_TurboReg(inputdir, outputdir, file) {
	regstack = "reged_"  + file;
	open(inputdir + "/" + file);
	selectWindow(file);
	Stack.getDimensions(width, height, channels, nan ,slice);
	bit = bitDepth();
	run("Split Channels");
	selectWindow("C1-" + file);
	setSlice(1);
	run("Duplicate...", "title=Target");
	rename("Target");
	
	for (k=1; k<=slice; k++) {
		selectWindow("C1-" + file);
		setSlice(k);
		run("Duplicate...", "title=currentFrame_C1");
		selectWindow("C2-" + file);
		setSlice(k);
		run("Duplicate...", "title=currentFrame_C2");

		run("TurboReg ",
		"-align " // Register the two images that we have just prepared.
		+ "-window " + "currentFrame_C1" + " "// Source (window reference).
		+ "0 0 " + (width - 1) + " " + (height - 1) + " " // No cropping.
		+ "-window " + "Target" + " "// Target (file reference).
		+ "0 0 " + (width - 1) + " " + (height - 1) + " " // No cropping.
		+ "-bilinear "
		+ (width / 4) + " " + (height / 4) + " " // Source translation landmark.
		+ (width / 4) + " " + (height / 4) + " " // Target translation landmark.
		+ (width / 4) + " " + (height / 4 * 3) + " " // Source translation landmark.
		+ (width / 4) + " " + (height / 4 * 3) + " " // Target translation landmark.
		+ (width / 4 * 3) + " " + (height / 4) + " " // Source second rotation landmark.
		+ (width / 4 * 3) + " " + (height / 4) + " " // Target second rotation landmark.
		+ (width / 4 * 3) + " " + (height / 4 * 3) + " " // Source second rotation landmark.
		+ (width / 4 * 3) + " " + (height / 4 * 3) + " " // Target second rotation landmark.
		+ "-hideOutput");
		
		sourceX1 = getResult("sourceX",0);
		sourceX2 = getResult("sourceX",1);
		sourceX3 = getResult("sourceX",2);
		sourceX4 = getResult("sourceX",3);
		sourceY1 = getResult("sourceY",0);
		sourceY2 = getResult("sourceY",1);
		sourceY3 = getResult("sourceY",2);
		sourceY4 = getResult("sourceY",3);
		targetX1 = getResult("targetX",0);
		targetX2 = getResult("targetX",1);
		targetX3 = getResult("targetX",2);
		targetX4 = getResult("targetX",3);
		targetY1 = getResult("targetY",0);
		targetY2 = getResult("targetY",1);
		targetY3 = getResult("targetY",2);
		targetY4 = getResult("targetY",3);
		
		run("TurboReg ",
		"-transform "// Register the two images that we have just prepared.
		+ "-window " + "currentFrame_C1" + " "// Source (window reference).
		+ width + " " + height + " "
		+ "-bilinear "
		+ sourceX1 + " " + sourceY1 + " "// Source translation landmark.
		+ targetX1 + " " + targetY1 + " "// Target translation landmark.
		+ sourceX2 + " " + sourceY2 + " "// Source first rotation landmark.
		+ targetX2 + " " + targetY2 + " "// Target first rotation landmark.
		+ sourceX3 + " " + sourceY3 + " "// Source second rotation landmark.
		+ targetX3 + " " + targetY3 + " "// Target second rotation landmark.
		+ sourceX4 + " " + sourceY4 + " "// Source second rotation landmark.
		+ targetX4 + " " + targetY4 + " "// Target second rotation landmark.
		+ "-showOutput");
		selectWindow("currentFrame_C1");
		run("Close");
		selectWindow("Output");
		run("Duplicate...", "title=registered_C1");
		selectWindow("Output");
		run("Close");
		
		run("TurboReg ",
		"-transform "// Register the two images that we have just prepared.
		+ "-window " + "currentFrame_C2" + " "// Source (window reference).
		+ width + " " + height + " "
		+ "-bilinear "
		+ sourceX1 + " " + sourceY1 + " "// Source translation landmark.
		+ targetX1 + " " + targetY1 + " "// Target translation landmark.
		+ sourceX2 + " " + sourceY2 + " "// Source first rotation landmark.
		+ targetX2 + " " + targetY2 + " "// Target first rotation landmark.
		+ sourceX3 + " " + sourceY3 + " "// Source second rotation landmark.
		+ targetX3 + " " + targetY3 + " "// Target second rotation landmark.
		+ sourceX4 + " " + sourceY4 + " "// Source second rotation landmark.
		+ targetX4 + " " + targetY4 + " "// Target second rotation landmark.
		+ "-showOutput");
		selectWindow("currentFrame_C2");
		run("Close");
		selectWindow("Output");
		run("Duplicate...", "title=registered_C2");
		selectWindow("Output");
		run("Close");
		
		run("Merge Channels...", "c1=registered_C1 c2=registered_C2 create");
		rename("registered");
		
		if (k==1) {
			rename(regstack);
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