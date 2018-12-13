% TRAINER MATLAB PROGRAM FOR DIGITS 1, 2 and 3
%NumTrain1 variable has current number of train data for digit 1. Similarly for 2
%and 3. The number of such training sets are dynamically maintained in the
%params.mat data file. paraminit.m initialises them to zero -- VINEETH
%BHASKARA Indian Institute of Technology

%This also calculates the latest average of MFCC coefficients in each class
%1 2 and 3 and stores them in AvgTrainMFCC1 variables in params.mat and so on...


clc;
clear all;
close all;
trainortest=0;
trainortest=input('* To add more training samples ENTER 1; or to add more testing samples ENTER 2:');

if trainortest==1
    trainerClass=input('Please Enter for which Class (1 or 2 or 3) you are training:');
elseif trainortest==2
    testerClass=input('Please Enter for which Class (1 or 2 or 3) you want to add to Test database:');
end


recObj=audiorecorder; % 8KHz Sampling Rate
fs=8000;

disp('Start speaking.')
recordblocking(recObj,5); % 5 seconds => 40,000 SAMPLES
disp('Recording Ends');
tic;
%*%play(recObj); % play recorded audio

x=getaudiodata(recObj);
x=x(1:39960); % ONLY WHEN 5 SECONDS! THESE ARE 40 NEGLECTED VALUES (5ms) SO THAT THE FRAMES FOR MFCCS COME TO AN INTEGER 498

lenofsignal=length(x);

t=(1:lenofsignal)/fs;
t=t';
figure('name','INPUT SPEECH SIGNAL');

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


figure('name','13 COMPONENT MEL-FILTER BANK GENERATED');
for j=2:14
    filterTemp=zeros(100,1);
    fofj=h(j);
    fofjp1=h(j+1);
    for i=1:100
         
        
      
       
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
title('13 component Mel-Filter Bank in frequency: 300 Hz to 4 kHz');
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
% large neg number
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

MFCCoeffs=cell(498,1);
for i=1:498
    MFCCoeffs{i}=zeros(13,1);
   
end

append=zeros(1,1);
for i=1:498
    MFCCoeffs{i}=dct(logFilterEnergies{i});
    append=[append MFCCoeffs{i}']; % appended MFCC coefficients
end

%=========ALL MFCC DONE!!!=========

display('MFC Coefficients generated. Saving them to respective database (train or test) and incrementing @params');
load('params.mat');

if trainortest==1
if trainerClass==1
    stringpath=strcat(pwd,'\train\1\train',num2str(NumTrain1+1),'.mat');
    save(stringpath, 'MFCCoeffs','x');
    NumTrain1=NumTrain1+1;
    
elseif trainerClass==2
    stringpath=strcat(pwd,'\train\2\train',num2str(NumTrain2+1),'.mat');
    save(stringpath, 'MFCCoeffs','x');
    NumTrain2=NumTrain2+1;
    
elseif trainerClass==3
    stringpath=strcat(pwd,'\train\3\train',num2str(NumTrain3+1),'.mat');
    save(stringpath, 'MFCCoeffs','x');
    NumTrain3=NumTrain3+1;
   
end

% Find the new averages....
AvgMFCCTrain1=cell(498,1);
AvgMFCCTrain2=cell(498,1);
AvgMFCCTrain3=cell(498,1);

for i=1:498
    AvgMFCCTrain1{i}=zeros(13,1);
    AvgMFCCTrain2{i}=zeros(13,1);
    AvgMFCCTrain3{i}=zeros(13,1);
end

if NumTrain1~=0
for i=1:NumTrain1
    stringpath=strcat(pwd,'\train\1\train',num2str(i),'.mat');
    load(stringpath);
    for j=1:498
        AvgMFCCTrain1{j}=(AvgMFCCTrain1{j})+MFCCoeffs{j};
    end
    
        
    %AvgMFCCTrain1=AvgMFCCTrain1 + MFCCoeffs;
end


for j=1:498
    AvgMFCCTrain1{j}=AvgMFCCTrain1{j}./NumTrain1;
end

end


if NumTrain2~=0
for i=1:NumTrain2
    stringpath=strcat(pwd,'\train\2\train',num2str(i),'.mat');
    load(stringpath);
    for j=1:498
        AvgMFCCTrain2{j}=AvgMFCCTrain2{j}+MFCCoeffs{j};
    end
end
for j=1:498
    AvgMFCCTrain2{j}=AvgMFCCTrain2{j}./NumTrain2;
end
end

if NumTrain3~=0
for i=1:NumTrain3
    stringpath=strcat(pwd,'\train\3\train',num2str(i),'.mat');
    load(stringpath);
    for j=1:498
        AvgMFCCTrain3{j}=AvgMFCCTrain3{j}+MFCCoeffs{j};
    end
end
for j=1:498
    AvgMFCCTrain3{j}=AvgMFCCTrain3{j}./NumTrain3;
end
end

%Final Saving...

save('params.mat','NumTrain1','NumTrain2','NumTrain3','AvgMFCCTrain1','AvgMFCCTrain2','AvgMFCCTrain3','NumTest1','NumTest2','NumTest3');

elseif trainortest==2
    if testerClass==1
    stringpath=strcat(pwd,'\test\1\test',num2str(NumTest1+1),'.mat');
    save(stringpath, 'MFCCoeffs','x');
    NumTest1=NumTest1+1;
    
    elseif testerClass==2
    stringpath=strcat(pwd,'\test\2\test',num2str(NumTest2+1),'.mat');
    save(stringpath, 'MFCCoeffs','x');
    NumTest2=NumTest2+1;
    
    elseif testerClass==3
    stringpath=strcat(pwd,'\test\3\test',num2str(NumTest3+1),'.mat');
    save(stringpath, 'MFCCoeffs','x');
    NumTest3=NumTest3+1;
   
end


save('params.mat','NumTrain1','NumTrain2','NumTrain3','AvgMFCCTrain1','AvgMFCCTrain2','AvgMFCCTrain3','NumTest1','NumTest2','NumTest3');   
    
    
end
toc  % to get the total execution time
    




        
    
            
        
        
        





