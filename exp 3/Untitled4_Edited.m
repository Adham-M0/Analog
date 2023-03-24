%--------------------initializing-----------------------%
clc;
clear all;
close all;

%-----------------Uploading message----------------------%
[message,Fs]=audioread('eric.wav');  

%-------------------Plotting message---------------------%

t    = linspace(0,(length(message)/Fs),length(message));
freq = linspace(-Fs/2,Fs/2,length(message));
 
MESSAGE=fftshift(fft(message));
figure;
plot(t,message);title 'Message';
xlabel 'time';ylabel 'amplitude';

figure;
plot(freq,abs(MESSAGE));title 'Message Spectrum';
xlabel 'frequency';ylabel 'amplitude';

%-----------------Filtering and Plotting----------------%

%constructing the filtered message
LPF  = [zeros(1,171354) ones(1,68541) zeros(1,171353)];
MESSAGE_filtered = LPF'.*MESSAGE;
message_filtered = ifft(ifftshift(MESSAGE_filtered)); 

%Ploting the filtered signal in time and frequency domain
figure;
plot(t,message_filtered);title 'Filtered message in time domain';
xlabel 'time';ylabel 'amplitude';
figure;
plot(freq,abs(MESSAGE_filtered));title 'Filtered message in frequency domain';
xlabel 'frequency';ylabel 'amplitude';
sound(message_filtered,Fs)
pause(8)
%---------------------Modulation-----------------------%

%initialzing constants
fc=100000;
new_fs=5*fc;
kf=.2*pi;
A=10;


new_message=resample(message_filtered,new_fs,Fs);
durationofmessage=length(message_filtered)./Fs;
t=linspace(0,durationofmessage,length(new_message));

%integration of the message
integrate_me=cumsum(new_message);
integral_transpose=integrate_me.';

%modulation equation
modulated_signal=A*cos(2*pi.*fc*t)-kf.*integral_transpose.*sin(2*pi*fc.*t);

spectrum=fftshift(fft(modulated_signal));
f=linspace(-(new_fs)/2,(new_fs)/2,length(modulated_signal));

%plotting
figure;
plot(t,modulated_signal); grid on;title 'modulated message in time domain';
xlabel 'time';ylabel 'amplitude';

figure;
plot(f,abs(spectrum)); grid on;title 'modulated message in frequency domain';
xlabel 'frequency';ylabel 'amplitude';

%--------------------Demodulation---------------------%

%envelope detection and dc blocking
envelope=abs(hilbert(modulated_signal));
mm=diff(envelope);
receiver=resample(mm,Fs,new_fs);
receiver=receiver(2:end);
receiver_F=fftshift(fft(receiver));
receiver_F_mg=abs(receiver_F);
time=linspace(0,durationofmessage,length(receiver));

%plotting
figure;
plot(time,receiver); grid on;title 'demodulated message in time domain';
xlabel 'time';ylabel 'amplitude';


fx=linspace((-Fs/2),(Fs/2),length(receiver));
figure;
plot(fx,receiver_F_mg); grid on;title 'demodulated message in frequency domain';
xlabel 'frequency';ylabel 'amplitude';

%------------- LPF ---------------%
N = length(receiver);
n = N/Fs;
right_band = round((Fs/2-4000)*n);
left_band = (N-right_band+1);
receiver_F([1:right_band left_band:N]) = 0;
receiver_LPF = real(ifft(ifftshift(receiver_F)));
%------------- LPF plotting ---------------%
figure;
plot(fx,abs(receiver_F)); grid on;title 'demodulated message in frequency domain after LPF';
xlabel 'frequency';ylabel 'amplitude';
%-------------------End result------------------------%
sound(receiver_LPF,Fs);


