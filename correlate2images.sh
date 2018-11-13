#!/bin/sh

# This script computes the correlation between two images  
# Usage: ./correlate2images.sh image1 image2
# Written by Mara Mather 3/11/2011

image1=$1
image2=$2

# Compute deviation scores, squared deviations and finally z scores for image 1

# get the mean
meanimage1=`fslstats ${image1} -m | awk '{print $1}'`

# convert image to deviation
fslmaths ${image1} -sub ${meanimage1} c_deviationimage1.nii.gz
meandeviation1=`fslstats c_deviationimage1.nii.gz -m | awk '{print $1}'`

# square the deviation image
fslmaths c_deviationimage1.nii.gz -sqr c_squareddeviation1.nii.gz

# get the mean squared deviation
meansquareddeviation1=`fslstats c_squareddeviation1.nii.gz -m | awk '{print $1}'`

# get the square root of the mean squared deviation = SD
SD=`echo "sqrt($meansquareddeviation1)" | bc` 

# compute Z
fslmaths c_deviationimage1.nii.gz -div ${SD} c_Zimage1.nii.gz

# repeat process for other image
meanimage2=`fslstats ${image2} -m | awk '{print $1}'`
fslmaths ${image2} -sub ${meanimage2} c_deviationimage2.nii.gz
meandeviation2=`fslstats c_deviationimage2.nii.gz -m | awk '{print $1}'`
fslmaths c_deviationimage2.nii.gz -sqr c_squareddeviation2.nii.gz
meansquareddeviation2=`fslstats c_squareddeviation2.nii.gz -m | awk '{print $1}'`
SD=`echo "sqrt($meansquareddeviation2)" | bc` 
fslmaths c_deviationimage2.nii.gz -div ${SD} c_Zimage2.nii.gz

# multiply two Z images 
fslmaths c_Zimage1.nii.gz -mul c_Zimage2.nii.gz c_Zcrossproducts.nii.gz

# compute correlation
r=`fslstats c_Zcrossproducts.nii.gz -m | awk '{print $1}'`
echo "$r"

#clean up files
rm c_*.nii.gz
