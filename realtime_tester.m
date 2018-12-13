
clc;
clear all;
close all;
display('Welcome to 1 2 3 DIGIT RECOGNIZER');
randommessg=input('If you are ready to record your speech for testing, press Enter:');
recObj=audiorecorder; % 8KHz Sampling Rate
fs=8000;

disp('Start speaking one of the digit 1 or 2 or 3 (5 seconds).')
recordblocking(recObj,5); % 5 seconds => 40,000 SAMPLES
disp('Recording Ends');
tic;
%*%play(recObj); % play recorded audio

x=getaudiodata(recObj);

%%
fs=8000;
x=x(1:39960); % ONLY WHEN 5 SECONDS! THESE ARE 40 NEGLECTED VALUES (5ms) SO THAT THE FRAMES FOR MFCCS COME TO AN INTEGER 498

lenofsignal=length(x);

t=(1:lenofsignal)/fs;
t=t';
figure('name','INPUT SPEECH TEST SIGNAL');

subplot(2,1,1);
plot(t,x);
xlabel('Time (s)');
ylabel('Amplitude');
title('Time Domain');
xlim([0 5]);

freqaxis=fs*(0:lenofsignal/2 - 1)/lenofsignal; % Prepare axis to plot onesided fourier transform plot
freqaxis=freqaxis';

fourierx=abs(fft(x));
fourierx=fourierx(1:lenofsignal/2); % discard half of the values (one sided)

subplot(2,1,2);

plot(freqaxis,fourierx);
xlabel('Frequency (Hz)');
ylabel('Amplitude');
title('Frequency Domain');
xlim([0 4000]);
%==============================================================================
% MFCC CALCULATIONS INFORMATION
% fs = 8k
% We divide the time domain signal into Frames of 25 ms == 200 SAMPLES
% We take the next frame at 10ms = 80 samples and so on. (Next at multiples
% of 80)
% We have neglected 40 values (5ms signal) to have integer # of frames
% Then TOTAL NUM OF FRAMES REQUIRED is 498
%================================================================================
s=cell(1,498); % cell data structure to store 498 frames' data
periodogram=cell(1,498);
freqs=cell(1,498); % holds the fourier of s
h=hamming(200); %creates hamming window of length 200 


%*% jaffa=zeros(1,200);
n=(1:200)/fs; % to plot s{i} against
n=n';
w=fs*(0:99)/200; % frequency axis for EACH FRAME to plot against (if needed)
w=w';

for i=1:498
    s{i}=x(80*(i-1)+1:200+80*(i-1));
    s{i}=s{i}.*h;  % Multiplying Hamming window so that the frame is Hamming like smooth
    
    % take fourier transform
    freqs{i}=fft(s{i});
    freqs{i}=freqs{i}(1:100);
    % Now calculate Periodogram based Power Estimate
    periodogram{i}=((abs(freqs{i}).^2)/100);
    
    
   %*% jaffa=[jaffa s{i}']; %For concatenating frames
end

%*%figure;
%*%plot((1:length(jaffa))/fs,jaffa);
%*%soundsc(jaffa);

% s{i} are the frames calculated Hamming approximated!

%=========COMPUTING MEL BANK========================================

% CHoose lower freq as 300Hz and max as 4000Hz
melMin=1125*log(1+300/700);
melMax=1125*log(1+4000/700);

m=linspace(melMin,melMax,15);
%Convert these back to normal scale freq in h(i)
h=zeros(1,15);

for i=1:15
    h(i)=700*(exp(m(i)/1125)-1);
end



w=fs*(0:99)/200; % frequency axis for EACH FRAME to plot against (if needed)
w=w';
N=100; %size of fourier transform of each frame
FilterBank=cell(13,1);


figure('name','13 COMPONENT MEL-FILTER BANK GENERATED FOR THE INPUT SIGNAL DATA');
for j=2:14
    filterTemp=zeros(100,1);
    fofj=h(j);
    fofjp1=h(j+1);
    for i=1:100
         %Shen et al.EURASIP Journal on Audio, Speech, and Music Processing 2012, 2012:28
       % fofjm1=((N/fs)*700*(exp((melMin+((j-1)*(melMax-melMin)/14))/1125)-1));
       % fofj= ((N/fs)*700*(exp((melMin+((j)*(melMax-melMin)/14))/1125)-1));
       % fofjp1=((N/fs)*700*(exp((melMin+((j+1)*(melMax-melMin)/14))/1125)-1));
        
      
       
      if j~=1 
          fofjm1=h(j-1);
          if w(i)< fofjm1
              filterTemp(i)=0;
          elseif w(i)<= fofj
              filterTemp(i)= (w(i)-fofjm1)/(fofj-fofjm1);
          elseif w(i)<= fofjp1
              filterTemp(i)=(fofjp1-w(i))/(fofjp1-fofj);
          elseif w(i)>fofjp1
              filterTemp(i)=0;
          end
      end 
      
      if j==1
        
        if w(i)<= fofjp1
            filterTemp(i)=(fofjp1-w(i))/(fofjp1-fofj);
        elseif w(i)>fofjp1
            filterTemp(i)=0;
      
        end
      end  
       
    end
    
   
    
           
           
       
    
    
    FilterBank{j-1}=filterTemp;
    hold on;
    plot(w,filterTemp);
end
xlabel('Frequency (Hz)');
ylabel('Amplitude');
title('Mel-Filter Bank for INPUT DATA in frequency: 300 Hz to 4 kHz');
xlim([0 4000]);
% NOW WE HAVE CALCULATED THE 13 filtered MEL BANK STARTING AT 300 Hz ENDING at 4kHz

%=== NOW CALCULATE FILTERBANK ENERGIES ====

filterbankEnergies=cell(498,1);
temp=zeros(100,1);
for j=1:498
    filterbankTemp=zeros(13,1);
    for i=1:13
        temp=periodogram{j}.*FilterBank{i};
        
        filterbankTemp(i)=sum(temp);
    end
    
    filterbankEnergies{j}=filterbankTemp;
end

%==AWESOME!! Now we have filterbank energies calculated in
%filterbankEnergies cell data structure

%Now calculate log filterbank energies

logFilterEnergies=cell(498,1);

for i=1:498
    logFilterEnergies{i}=log(abs(filterbankEnergies{i}));
end
% BUT INCASE log(0)=-inf WE WILL **** UP! SO If -inf found, replace by
% large negative munber
tempvector=zeros(13,1);
for tempi=1:498
    tempvector=logFilterEnergies{tempi};
    
    for tempj=1:13
        if tempvector(tempj,1)==-inf
            tempvector(tempj,1)=-10000;  % SET THIS VALUE APPROPRIATELY
        end
    end
    logFilterEnergies{tempi}=tempvector;
    tempvector=zeros(13,1);
end
% done
    
    
        
        
        


%!!!!!!  NOW FOR THE FINAL CALCULATION OF CEPSTRAL MFCC COEFFICIENTS

TestMFCCoeffs=cell(498,1);
for i=1:498
    TestMFCCoeffs{i}=zeros(13,1);
   
end

append=zeros(1,1);
for i=1:498
    TestMFCCoeffs{i}=dct(logFilterEnergies{i});
    append=[append TestMFCCoeffs{i}']; % appended MFCC coefficients
end





%=========ALL MFCC DONE!!!=========

% Implementing Dynamic Time Warping to compare these MFCCoeffs (Test) with
% the average Coeffs of the training set (which was calculated by trainer.m


% IMPLEMENTING DYNAMIC TIME WARPING USING RECURSION

load('params.mat');

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

d1
d2
d3
toc % print time elapsed

if d1>=d3 && d2>=d3
    display('YOU SAID: DIGIT THREE');
elseif d1>=d2 && d3>=d2
    display('YOU SAID: DIGIT TWO');
elseif d2>=d1 && d3>=d1
    display('YOU SAID: DIGIT ONE');
end

%ENDS
    
    





    



        
    
            
        
        
        





