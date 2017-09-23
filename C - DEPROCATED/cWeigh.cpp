#include "mex.h"

using namespace std;


double* subsample(int i, int j, double *currentCrop){
	double feature[10]= {0};
	for(int m=0; m<10; ++m){
		for(int n=0; n<10; ++n){
			feature[0] = currentCrop[0];
		}
	}
	double arraySize = double (sizeof(currentCrop[1]));
	double *returnValue = &arraySize;
	return returnValue;
}

void cWeigh(double *currentCrop, double *outputWeight){
	
	//Fields
	double weight = 0; //Initialize the weight as 0

	// Operating under assumption of 10x10 Squares
	// Also assuming 100x100 crop
	const int cropSize = 100;
	const int subsampleSize = 10;

	double weights[subsampleSize][subsampleSize] = {0};

/*
	//Convolution Layer
	for(int i=0; i<10; ++i){
		for(int j=0; j<10; ++j){
			//Copy Array
			subsample(i, j, currentCrop);
		}
	}
	*/
	array<array<double, 100>, 100> crop;
	double outputTest = *subsample(1, 1, currentCrop);

	outputWeight[0] = outputTest;
	outputWeight[2] = 6.0;
}

void mexFunction(int nlhs, mxArray *plhs[], int nhrs, const mxArray *prhs[]){
	//Fields
	double *currentCrop;
	double *outMatrix;
	//Vars
	currentCrop = mxGetPr(prhs[0]);
	plhs[0] = mxCreateDoubleMatrix(2,2, mxREAL);
	outMatrix = mxGetPr(plhs[0]);
	cWeigh(currentCrop, outMatrix);
}