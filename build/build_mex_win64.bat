
copy /y mexopencv_setup.m mexopencv
copy /y mexopencv_win64.prj mexopencv
xcopy /s /q /y dist ..\opencv\

"C:\Program Files\MATLAB\R2020b\bin\matlab" -nodesktop -wait -sd . -r "mex_compile; quit"
"C:\Program Files\MATLAB\R2020b\bin\matlab" -nodesktop -wait -sd . -r "publish_samples; quit"

