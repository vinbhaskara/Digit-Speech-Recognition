clc;
close all;
clear all;
tic;
display('Welcome to 1 2 3 DIGIT SYSTEM PERFORMANCE EVALUATER');
display('Performance is being evaluated on Test data in Test folder using Train data in Train folder ...');

load('params.mat');

errormatrix=zeros(3,1);
pers=0;
display('Computing...');
for classnum=1:3
    
    if classnum==1
        num=NumTest1;
    elseif classnum==2
        num=NumTest2;
    elseif classnum==3
        num=NumTest3;
    end
    if num~=0
    for junknum=1:num
        path=strcat(pwd,'\test\',num2str(classnum),'\test',num2str(junknum),'.mat');
        load(path);
        TestMFCCoeffs=MFCCoeffs;
        windowSize=inf; %window size in DTW 
%AvgMFCCMatrix1=zeros(498,13);

% change the cell struct to a matrix type for dtw processing
AvgMFCCMatrix1=AvgMFCCTrain1{1}';
AvgMFCCMatrix2=AvgMFCCTrain2{1}';
AvgMFCCMatrix3=AvgMFCCTrain3{1}';
TestMFCCMatrix=TestMFCCoeffs{1}';

for i=2:498
    AvgMFCCMatrix1=[AvgMFCCMatrix1;AvgMFCCTrain1{i}'];
    AvgMFCCMatrix2=[AvgMFCCMatrix2;AvgMFCCTrain2{i}'];
    AvgMFCCMatrix3=[AvgMFCCMatrix3;AvgMFCCTrain3{i}'];
    TestMFCCMatrix=[TestMFCCMatrix;TestMFCCoeffs{i}'];
end

%-- DTW ALGORITHM STARTS:

%REMOVE THE FIRST MFCC COEFFICIENT SO THAT OUR RECOGNITION IS ROBUST AGAIST
%INTENSITY VARIATIONS
TestMFCCMatrix=TestMFCCMatrix(1:end,2:end); %Remove first column of energies
AvgMFCCMatrix1=AvgMFCCMatrix1(1:end,2:end);
AvgMFCCMatrix2=AvgMFCCMatrix2(1:end,2:end);
AvgMFCCMatrix3=AvgMFCCMatrix3(1:end,2:end);

%------------- Computing distance from class 1: Sample is out training
%average and Test is the testing values

nsample=size(AvgMFCCMatrix1,1);
ntest=size(TestMFCCMatrix,1);

windowSize=max(windowSize, abs(nsample-ntest)); % adapting window size for better dtw

D=zeros(nsample+1,ntest+1)+Inf; % D is the  matrix in the DTW algorithm and gives the least distance up to i,j
D(1,1)=0;

%recursion
for i=1:nsample
    for j=max(i-windowSize,1):min(i+windowSize,ntest)
        tempDist=norm(AvgMFCCMatrix1(i,:)-TestMFCCMatrix(j,:));
        D(i+1,j+1)=tempDist+min( [D(i,j+1), D(i+1,j), D(i,j)] );
        
    end
end
d1=D(nsample+1,ntest+1); % This is the shortest distance in DTW of the test from class 1 samples

%----------------------------


%------------- Computing distance from class 2: Sample is out training
%average and Test is the testing values

nsample=size(AvgMFCCMatrix2,1);
ntest=size(TestMFCCMatrix,1);

windowSize=max(windowSize, abs(nsample-ntest)); % adapting window size for better dtw

D=zeros(nsample+1,ntest+1)+Inf; % D is the  matrix in the DTW algorithm and gives the least distance up to i,j
D(1,1)=0;

%recursion
for i=1:nsample
    for j=max(i-windowSize,1):min(i+windowSize,ntest)
        tempDist=norm(AvgMFCCMatrix2(i,:)-TestMFCCMatrix(j,:));
        D(i+1,j+1)=tempDist+min( [D(i,j+1), D(i+1,j), D(i,j)] );
        
    end
end
d2=D(nsample+1,ntest+1); % This is the shortest distance in DTW of the test from class 1 samples

%----------------------------




%------------- Computing distance from class 3: Sample is out training
%average and Test is the testing values

nsample=size(AvgMFCCMatrix3,1);
ntest=size(TestMFCCMatrix,1);

windowSize=max(windowSize, abs(nsample-ntest)); % adapting window size for better dtw

D=zeros(nsample+1,ntest+1)+Inf; % D is the  matrix in the DTW algorithm and gives the least distance up to i,j
D(1,1)=0;

%recursion
for i=1:nsample
    for j=max(i-windowSize,1):min(i+windowSize,ntest)
        tempDist=norm(AvgMFCCMatrix3(i,:)-TestMFCCMatrix(j,:));
        D(i+1,j+1)=tempDist+min( [D(i,j+1), D(i+1,j), D(i,j)] );
        
    end
end
d3=D(nsample+1,ntest+1); % This is the shortest distance in DTW of the test from class 1 samples

%----------------------------




if d1>d3 && d2>d3
    %display('YOU SAID: DIGIT THREE');
    if classnum==1
        errormatrix(1)=errormatrix(1)+1;
        
        
    elseif classnum==2
        errormatrix(2)=errormatrix(2)+1;
        
    end
    
elseif d1>d2 && d3>d2
    %display('YOU SAID: DIGIT TWO');
    if classnum==1
        errormatrix(1)=errormatrix(1)+1;
        
    elseif classnum==3
        errormatrix(3)=errormatrix(3)+1;
    end
elseif d2>d1 && d3>d1
    %display('YOU SAID: DIGIT ONE');
    if classnum==3
        errormatrix(3)=errormatrix(3)+1;
    elseif classnum==2
        errormatrix(2)=errormatrix(2)+1;
    end
end
pers=pers+(99/(NumTest1+NumTest2+NumTest3));
str=sprintf('Processing... (%0.1f %%). Please wait.',pers);
disp(str);

    end
    
    end
    %steerng=strcat('Processing... (',num2str(classnum*33),'%)');
    %disp(steerng);
    
end

totalerror=errormatrix(1)+errormatrix(2)+errormatrix(3);
totaltest=NumTest1+NumTest2+NumTest3;
toc % print time elapsed

display('CLASS WISE PERFORMANCE:');
display('Digit 1 Performance (%):');
d1p=(1-(errormatrix(1)/NumTest1))*100;
d2p=(1-(errormatrix(2)/NumTest2))*100;
d3p=(1-(errormatrix(3)/NumTest3))*100;
disp(d1p);
display('Digit 2 Performance (%):');
disp(d2p);
display('Digit 3 Performance (%):');
disp(d3p);
display('TOTAL OVERALL PERFORMANCE (%):');
dtotp=(1-(totalerror/totaltest))*100;
disp(dtotp);
toc
% bye bye VINEETH :)

    
        
        
        
        
        
        
        