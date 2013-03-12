/* calculate Matern covariance with nu = 3/2 */

#include "mex.h"
#include <math.h>

void mexFunction(int nlhs, mxArray *plhs[],
								 int nrhs, const mxArray *prhs[])
{
	/* number of hyperparameters */
  if(nlhs <= 1 && nrhs == 0) {
		plhs[0] = mxCreateString("2");
		return;
	}

	else if (nlhs == 1 && nrhs == 2) {

		if (mxGetM(prhs[0]) != 2 || mxGetN(prhs[0]) != 1) {
			mexErrMsgTxt("wrong number of hyperparameters!");
			return;
		}

		double *hyperparameters, *in, *out;
		double input_scale, output_scale;
		double sqrt3 = sqrt(3.);

		int num_points, dim, i, j, k;

		hyperparameters = mxGetPr(prhs[0]);
		input_scale = exp(hyperparameters[0]);
		output_scale = exp(2 * hyperparameters[1]);

		num_points = mxGetM(prhs[1]);
		dim = mxGetN(prhs[1]);
		in = mxGetPr(prhs[1]);
		
		plhs[0] = mxCreateDoubleMatrix(num_points, num_points, mxREAL);
		out = mxGetPr(plhs[0]);
		
		for (i = 0; i < num_points; i++) 
			for (j = i; j < num_points; j++) {
				
				double squared_distance = 0, difference, distance, answer;

				for (k = 0; k < dim; k++) {
					difference = (in[i + num_points * k] - 
												in[j + num_points * k]);
					squared_distance += difference * difference;
				}

				distance = sqrt(squared_distance);

				answer = output_scale * (1 + (sqrt3 * distance) / input_scale) * 
					exp(-(sqrt3 * distance) / input_scale);
				
				out[i + num_points * j] = answer;
				out[j + num_points * i] = answer;

			}
	}
	
	else if (nlhs == 2 && nrhs == 3) {

		if (mxGetM(prhs[0]) != 2 || mxGetN(prhs[0]) != 1) {
			mexErrMsgTxt("wrong number of hyperparameters!");
			return;
		}

		double *hyperparameters, *training_points, *testing_points, 
			*self_covariances, *cross_covariances;
		double input_scale, output_scale;
		double sqrt3 = sqrt(3.);

		int num_training_points, num_testing_points, dim, i, j, k;

		hyperparameters = mxGetPr(prhs[0]);
		input_scale = exp(hyperparameters[0]);
		output_scale = exp(2 * hyperparameters[1]);
	
		num_training_points = mxGetM(prhs[1]);
		dim = mxGetN(prhs[1]);
		training_points = mxGetPr(prhs[1]);

		num_testing_points = mxGetM(prhs[2]);
		testing_points = mxGetPr(prhs[2]);
		
		plhs[0] = mxCreateDoubleMatrix(num_testing_points, 1, mxREAL);
		self_covariances = mxGetPr(plhs[0]);

		plhs[1] = 
			mxCreateDoubleMatrix(num_training_points, num_testing_points, mxREAL);
		cross_covariances = mxGetPr(plhs[1]);

		for (i = 0; i < num_testing_points; i++) {
		
			self_covariances[i] = output_scale;
		
			for (j = 0; j < num_training_points; j++) {

				double squared_distance = 0, difference, distance;

				for (k = 0; k < dim; k++) {
					difference = (testing_points[i + num_testing_points * k] - 
												training_points[j + num_training_points * k]);
					squared_distance += difference * difference;
				}
				
				distance = sqrt(squared_distance);
				
				cross_covariances[j + num_training_points * i] = 
					output_scale * (1 + (sqrt3 * distance) / input_scale) * 
					exp(-(sqrt3 * distance) / input_scale);

			}
		}
		
	}

	else if (nlhs == 1 && nrhs == 3) {
		if (mxGetM(prhs[0]) != 2 || mxGetN(prhs[0]) != 1) {
			mexErrMsgTxt("wrong number of hyperparameters!");
			return;
		}

		double *hyperparameter, *hyperparameters, *in, *out;
		double input_scale, output_scale;
		double sqrt3 = sqrt(3.);

		int num_points = mxGetM(prhs[1]), dim, i, j, k;
		
		hyperparameters = mxGetPr(prhs[0]);
		input_scale = exp(hyperparameters[0]);
		output_scale = exp(2 * hyperparameters[1]);

		in = mxGetPr(prhs[1]);
		dim = mxGetN(prhs[1]);

		hyperparameter = mxGetPr(prhs[2]);
		
		plhs[0] = mxCreateDoubleMatrix(num_points, num_points, mxREAL);
		out = mxGetPr(plhs[0]);
		
 		if (hyperparameter[0] == 1) { /* input scale */

			for (i = 0; i < num_points; i++) 
				for (j = i; j < num_points; j++) {
					
					double squared_distance = 0, difference, distance, answer;
					
					for (k = 0; k < dim; k++) {
						difference = (in[i + num_points * k] - 
													in[j + num_points * k]);
						squared_distance += difference * difference;
					}
					
					distance = sqrt(squared_distance);
					
					answer = output_scale * (sqrt3 / input_scale) * squared_distance * exp(-(sqrt3 * distance) / input_scale);
					
					out[i + num_points * j] = answer;
					out[j + num_points * i] = answer;
					
				}
		}

 		else if (hyperparameter[0] == 2) { /* output scale */

			for (i = 0; i < num_points; i++) 
				for (j = i; j < num_points; j++) {
					
					double squared_distance = 0, difference, distance, answer;
					
					for (k = 0; k < dim; k++) {
						difference = (in[i + num_points * k] - 
													in[j + num_points * k]);
						squared_distance += difference * difference;
					}
					
					distance = sqrt(squared_distance);
					
					answer = output_scale * (1 + (sqrt3 * distance) / input_scale) * 
						exp(-(sqrt3 * distance) / input_scale);
					
					out[i + num_points * j] = 2 * answer;
					out[j + num_points * i] = 2 * answer;
					
				}
		}
	}

	else if (nlhs == 1 && nrhs == 4) {
		
		if (mxGetM(prhs[0]) != 2 || mxGetN(prhs[0]) != 1) {
			mexErrMsgTxt("wrong number of hyperparameters!");
			return;
		}
		
		double *hyperparameter, *hyperparameters, *training_points, *testing_points, 
			*gradient;
		double input_scale, output_scale;
		double sqrt3 = sqrt(3.);
		
		int num_training_points, num_testing_points, dim, i, j, k;
		
		hyperparameters = mxGetPr(prhs[0]);
		input_scale = exp(hyperparameters[0]);
		output_scale = exp(2 * hyperparameters[1]);
		
		num_training_points = mxGetM(prhs[1]);
		dim = mxGetN(prhs[1]);
		training_points = mxGetPr(prhs[1]);
		
		num_testing_points = mxGetM(prhs[2]);
		testing_points = mxGetPr(prhs[2]);
		
		hyperparameter = mxGetPr(prhs[3]);
		
		plhs[0] = mxCreateDoubleMatrix(num_training_points, num_testing_points, mxREAL);
		gradient = mxGetPr(plhs[0]);
		
		if (hyperparameter[0] == 1) { /* input scale */
			for (i = 0; i < num_testing_points; i++) {
				for (j = 0; j < num_training_points; j++) {
					
					double squared_distance = 0, difference, distance;
					
					for (k = 0; k < dim; k++) {
						difference = (testing_points[i + num_testing_points * k] - 
													training_points[j + num_training_points * k]);
						squared_distance += difference * difference;
					}
					
					distance = sqrt(squared_distance);
					
					gradient[j + num_training_points * i] =
						output_scale * (sqrt3 / input_scale) * squared_distance * 
						exp(-(sqrt3 * distance) / input_scale);
				}
			}
		}
		else {
			for (i = 0; i < num_testing_points; i++) {
				for (j = 0; j < num_training_points; j++) {
					
					double squared_distance = 0, difference, distance;
					
					for (k = 0; k < dim; k++) {
						difference = (testing_points[i + num_testing_points * k] - 
													training_points[j + num_training_points * k]);
						squared_distance += difference * difference;
					}
					
					distance = sqrt(squared_distance);
					
					gradient[j + num_training_points * i] = 2 *
						output_scale * (1 + (sqrt3 * distance) / input_scale) * 
						exp(-(sqrt3 * distance) / input_scale);
				}
			}
		}
	}
	
	return;
}
