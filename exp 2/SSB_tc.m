clear;
clc;
[xin ,fs] = audioread('eric.wav');
audio_length= length(xin)./fs;
t=linspace(0,audio_length,length(xin));



f_xin=fftshift(fft(xin));
f_xin_mg= abs(f_xin);
N = length(xin);
f_vec = linspace(-fs/2,fs/2,N);


%%%%%%%%%LPF%%%%%%%%%
%filter at 4khz
n = N/fs;
right_band = round((fs/2-4000)*n);
left_band = (N-right_band+1);
f_xin([1:right_band left_band:N]) = 0;

figure(1)
subplot(2,1,2)
plot(f_vec,abs(f_xin))
title('LPF(4khz) Signal in Frequency domain')
xin = real(ifft(ifftshift(f_xin)));

subplot(2,1,1)
plot(t,xin)
title('LPF(4khz) Signal in Time domain')
%% transmitter 
fc = 100000;
fs_new = 5*fc;
msg_resampled = resample(xin,fs_new,fs);
A=max(msg_resampled)*2;
t_end = length(msg_resampled)./fs_new;
t = linspace(0,t_end, length(msg_resampled));

% modulation
carrier = cos(2*pi*fc*t);
carrier = carrier';

transmitted_m = (A+msg_resampled).*carrier;
f_transmitted_m= fftshift(fft(transmitted_m));
f_transmitted_mg= abs(f_transmitted_m);
N=length(transmitted_m);
f_vec = linspace(-fs_new/2,fs_new/2,N);




% get the LSB usin LPF
N = length(transmitted_m);
f_vec = linspace(-fs_new/2,fs_new/2,N);
index = f_vec>=fc+1;
f_transmitted_mg(index) = 0;
% remove frequencies < -fc (remove negative HSB)
index2 = f_vec<=(-fc);
f_transmitted_mg(index2) = 0;
f_transmitted_mg = abs(f_transmitted_mg);

t_end = length(transmitted_m)./fs_new;
t = linspace(0,t_end, length(transmitted_m));



figure (2)
subplot(4,1,1)
plot(t,msg_resampled)
title('Resampled Msg signal in Time domain')

f_resampled=fftshift(fft(msg_resampled));
f_resampled_mg=abs(f_resampled);
N = length(f_transmitted_mg);
f_vec = linspace(-fs_new/2,fs_new/2,N);

subplot(4,1,2)
plot(f_vec,f_resampled_mg)
title('Resampled Msg signal in Freq domain')

subplot(4,1,3)
plot(f_vec,abs(f_transmitted_mg))
title('SSB-SC TX modulated msg in Freq domain')

subplot(4,1,4)
plot(t,transmitted_m)
title('SSB-SC TX modulated msg in Time domain')
%% receiver
transmitted_m = real(ifft(ifftshift(f_transmitted_m)));
t_end = length(transmitted_m)./fs_new;
t = linspace(0,t_end, length(transmitted_m));
envelope = abs(hilbert(transmitted_m));

figure(3)
subplot(2,1,1)
plot(t,envelope)
title('SSB-TC LSB RX msg in Time domain using envelope detector')

f_envelope= fftshift(fft(envelope));
f_envelope_mg= abs(f_envelope);

subplot(2,1,2)
plot(f_vec,f_envelope_mg)
title('SSB-TC LSB RX msg in frequency domain using envelope detector')

original_msg = resample(envelope,fs,fs_new);
sound(original_msg, fs)
