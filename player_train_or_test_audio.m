clc;
close all;
clear all;

%--------------------------
timegap=1; %time in seconds gap between playing two sounds. Best is 5 so that they dont overlap
%----------------------------


load('params.mat');
display('TRAIN/TEST SPEECH DATA PLAYER');
trainortest=input('Which samples you want to play- Training (1) or Testing (2)?:');

if trainortest==1
    class=input('Which Digit Class out 1,2,3 do you want to play from Train set?:');
    if class==1
        num=NumTrain1;
    elseif class==2
        num=NumTrain2;
    elseif class==3
        num=NumTrain3;
    end
    
    if num~=0
    for i=1:num
        path=strcat(pwd,'\train\',num2str(class),'\train',num2str(i),'.mat');
        load(path);
        status=strcat('Playing-',num2str(i),'-of-',num2str(num),'.');
        disp(status);
        soundsc(x);
        pause(timegap);
    end
    end
    
elseif trainortest==2
    class=input('Which Digit Class out 1,2,3 do you want to play from Test set?:');
    if class==1
        num=NumTest1;
    elseif class==2
        num=NumTest2;
    elseif class==3
        num=NumTest3;
    end
    
    if num~=0
    for i=1:num
        path=strcat(pwd,'\test\',num2str(class),'\test',num2str(i),'.mat');
        load(path);
        status=strcat('Playing-',num2str(i),'-of-',num2str(num),'.');
        disp(status);
        soundsc(x);
        pause(timegap);
    end
    end
end

    
        
        
        
        
        