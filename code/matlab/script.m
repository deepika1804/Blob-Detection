% Script 
%loading the image..
I = imread('../data/sunflowers.jpg');
%setting the threshold
threshold = 0.03;
%scale for sigma
scale = 1;
%Levels of Scale pyramid
numOfItr = 5;
%The kernel size factor to determine sigma
k=2;
%blob generator function
detectBlobs (I,threshold,scale,numOfItr,k);