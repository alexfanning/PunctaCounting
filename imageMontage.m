
file = imread(uigetfile('*.tif'));
file2 = imread(uigetfile('*.tif'));
file3 = imread(uigetfile('*.tif'));

newMontage = montage({file,file2,file3});