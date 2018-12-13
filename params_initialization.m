clc;
clear all;
close all; 
load('params.mat');
jaffa=input('Press (1) to delete TESTING data; (2) to delete TRAINING data:');
display('IF YOU RUN THIS INITIALIZER PLEASE DELETE Respective MAT FILES MANUALLY IN respective FOLDERS');
display('RUN TWICE with (1), (2) options TO DELETE BOTH TRAIN and TEST SETS.');

if jaffa==1
    
NumTest1=0;
NumTest2=0;
NumTest3=0;
save('params.mat','NumTrain1','NumTrain2','NumTrain3','AvgMFCCTrain1','AvgMFCCTrain2','AvgMFCCTrain3','NumTest1','NumTest2','NumTest3');
display('Testing Parameters Initialized.');

elseif jaffa==2

NumTrain1=0;
NumTrain2=0;
NumTrain3=0;



AvgMFCCTrain1=cell(498,1);
AvgMFCCTrain2=cell(498,1);
AvgMFCCTrain3=cell(498,1);

for i=1:498
    AvgMFCCTrain1{i}=zeros(13,1);
    AvgMFCCTrain2{i}=zeros(13,1);
    AvgMFCCTrain3{i}=zeros(13,1);
end

    



save('params.mat','NumTrain1','NumTrain2','NumTrain3','AvgMFCCTrain1','AvgMFCCTrain2','AvgMFCCTrain3','NumTest1','NumTest2','NumTest3');
display('Training Parameters Initialized');
end
