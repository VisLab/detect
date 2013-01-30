% This make.m is for MATLAB and OCTAVE under Windows, Mac, and Unix

try
	Type = ver;
	% This part is for OCTAVE
	if(strcmp(Type(1).Name, 'Octave') == 1)
		mex libsvmread_DETECT.c
		mex libsvmwrite_DETECT.c
		mex svmtrain_DETECT.c ../svm.cpp svm_model_matlab.c
		mex svmpredict_DETECT.c ../svm.cpp svm_model_matlab.c
	% This part is for MATLAB
	% Add -largeArrayDims on 64-bit machines of MATLAB
	else
		mex CFLAGS="\$CFLAGS -std=c99" -largeArrayDims libsvmread_DETECT.c
		mex CFLAGS="\$CFLAGS -std=c99" -largeArrayDims libsvmwrite_DETECT.c
		mex CFLAGS="\$CFLAGS -std=c99" -largeArrayDims svmtrain_DETECT.c ../svm.cpp svm_model_matlab.c
		mex CFLAGS="\$CFLAGS -std=c99" -largeArrayDims svmpredict_DETECT.c ../svm.cpp svm_model_matlab.c
	end
catch
	fprintf('If make.m failes, please check README about detailed instructions.\n');
end
