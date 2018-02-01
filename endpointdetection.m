% Algorithm implemented in [1].
% [1] Saha, G., Sandipan Chakroborty, and Suman Senapati. "A new silence removal and endpoint detection algorithm 
% for speech and speaker recognition applications." Proceedings of the 11th national conference on communications (NCC). 2005.
%

clear all
clc
close all
[y,Fs] = audioread('speechFile.wav'); 

%audio file info
info = audioinfo('speechFile.wav');
display(info);

averagedSound = mean(y,2); %get the average of channels 
N = length(averagedSound);


% step 1: Calculate the mean and standard deviation of the
% first 9600 samples of the given utterance. 200ms of the speech
% (200/1000)*Fs

mu = mean(averagedSound(1:((200/1000)*Fs)));
sigma = std(averagedSound(1:((200/1000)*Fs)));

% step 2: check whether Mahalanobis distance is >3 or not
s=1;
ns=1;
speech=zeros(N,1);
nonspeech=zeros(N,1);
copySpeech=averagedSound;
for i=1:N
    if( (abs(averagedSound(i)-mu)/sigma)>3) %
        speech(s)=averagedSound(i);
        copySpeech(i)=1; % step 3: Mark the voiced sample as 1 and unvoiced sample as 0.
        s=s+1;
    else
        nonspeech(ns)=averagedSound(i);
        copySpeech(i)=0;
        ns=ns+1;
    end
end

% step 3: Divide the whole speech signal into 10 ms non-overlapping windows.
% (10/1000)*Fs
% step 4: Label each window 0s or 1s based on their majority in the window
w=(10/1000)*Fs;
Zu=floor(N/w); %number of windows
k=1;
t_prev=1;
for i=1:Zu
    t=k*w;
    temp=copySpeech(t_prev:t);
    if(sum(temp(:)==0)>sum(temp(:)==1))
        copySpeech(t_prev:t)=zeros(length(temp),1);
    else
        copySpeech(t_prev:t)=ones(length(temp),1);
    end
    t_prev=t;
    k=k+1;
end

%step 5: Retrieve the voiced part of the original speech signal from labeled 1 samples.
voicedPart = averagedSound(find(copySpeech));
Nu=length(voicedPart);

t = (0:Nu-1)/Fs; %time vector

%plot in time domain
figure(1)
plot(t, voicedPart, 'k')
grid on
set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)
xlabel('Time, s')
ylabel('Amplitude')
title('Signal in the time domain')


%sound(voicedPart, Fs)
