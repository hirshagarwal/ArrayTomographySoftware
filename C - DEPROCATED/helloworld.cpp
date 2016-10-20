#include <math.h>
#include <matrix.h>
#include <mex.h>
#include <sstream>

using namespace std;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
    mxArray *a_in;
    a_in = mxDuplicateArray(prhs[0]);
    double *a = mxGetPr(a_in);
    printf("%i", *a);
}





