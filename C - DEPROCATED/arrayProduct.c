#include "mex.h"

void arrayProduct(double x, double *y, double *z, mwSize n){
    z[0] = 2 * 5;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
    //Fields
    
    //Define Vars
    double multiplier;
    double *inMatrix;
    size_t nCols;
    double *outMatrix;
    
    multiplier = mxGetScalar(prhs[0]);
    inMatrix = mxGetPr(prhs[0]);
    nCols = mxGetN(prhs[1]);
    plhs[0] = mxCreateDoubleMatrix(1, (mwSize)nCols, mxREAL);
    outMatrix = mxGetPr(plhs[0]);
    arrayProduct(multiplier, inMatrix, outMatrix, nCols);
}