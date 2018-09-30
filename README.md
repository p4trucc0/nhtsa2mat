# nhtsa2mat
Parse NHTSA-downloadable zip files into a Matlab struct
# Usage
The nhtsa2mat.m function basically is a stand-alone parser for the NHTSA EV5 ASCII X-Y format.
It can be used to import crash test data downloaded from the NHTSA database in EV5 .zip format to a Matlab struct, or file.
The function requires 1 argument and accepts a second, optional one:
 1. zip file (string): the EV5 file downloaded from NHTSA
 2. (optional): out file name (string): an output file you may want to save the parsed struct onto.
The function has only one output:
 1. Parsed struct

# Tested with:
Matlab 2016a, Matlab 2018b, Octave 4.2.1 (nhtsa2oct)
