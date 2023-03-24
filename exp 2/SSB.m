%% 
clear;
clc;
% orignal sound 
[xin ,fs] = audioread('eric.wav');
audio_length= length(xin)./fs;
t=linspace(0,audio_length,length(xin));

figure (1)
subplot(2,1,1)
plot(t,xin)
title('signal in Time domain')

f_xin=fftshift(fft(xin));
f_xin_mg= abs(f_xin);
N = length(xin);
f_vec = linspace(-fs/2,fs/2,N);

subplot(2,1,2)
plot(f_vec,f_xin_mg)
title(' signal in Frequency domain')

%%%%%%%%%LPF%%%%%%%%%
%filter at 4khz
n = N/fs;
right_band = round((fs/2-4000)*n);
left_band = (N-right_band+1);
f_xin([1:right_band left_band:N]) = 0;

figure(2)
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
t_end = length(msg_resampled)./fs_new;
t = linspace(0,t_end, length(msg_resampled));

% modulation
carrier = cos(2*pi*fc*t);
carrier = carrier';

transmitted_m = msg_resampled.*carrier;
f_transmitted_m= fftshift(fft(transmitted_m));

f_t_magnitude= abs(f_transmitted_m);
N=length(transmitted_m);
f_vec = linspace(-fs_new/2,fs_new/2,N);

% get the LSB usin LPF
N = length(msg_resampled);
n = N/fs_new;
right_band = round((fs_new/2-100000)*n);
left_band = (N-right_band+1);
f_transmitted_m([1:right_band left_band:N]) = 0;
f_t_magnitude = abs(f_transmitted_m);
transmitted_m = real(ifft(ifftshift(f_transmitted_m)));

t_end = length(transmitted_m)./fs_new;
t = linspace(0,t_end, length(transmitted_m));



figure (3)
subplot(4,1,1)
plot(t,msg_resampled)
title('Resampled Msg signal in Time domain')

f_resampled=fftshift(fft(msg_resampled));
f_resampled_mg=abs(f_resampled);
N = length(f_transmitted_m);
f_vec = linspace(-fs_new/2,fs_new/2,N);

subplot(4,1,2)
plot(f_vec,f_resampled_mg)
title('Resampled Msg signal in Freq domain')

subplot(4,1,3)
plot(f_vec,abs(f_transmitted_m))
title('SSB-SC TX modulated msg in Freq domain')

subplot(4,1,4)
plot(t,transmitted_m)
title('SSB-SC TX modulated msg in Time domain')

%% receiver
%%%%%% Ideal LPF receiver %%%%%%%%%%%%%
ideal_rx(transmitted_m,t,f_vec,fs_new,fs);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Butterworth filter%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
transmitted_m = msg_resampled.*carrier;

f_transmitted_m = fftshift(fft(transmitted_m));
f_transmitted_mg = abs(f_transmitted_m);
N = length(transmitted_m);
f_vec = linspace(-fs_new/2,fs_new/2,N);

%plot in freq
figure(5)
subplot(2,1,1)
plot(f_vec,f_transmitted_mg)
title('SSB TX modulated msg in freq domain')

% butterworth bandpass filter to filterout the USB
[b, a]= butter(4, [(fc-4000)/(fs_new/2) fc/(fs_new/2)], 'bandpass');
tx_msg_LSB = filter(b,a,transmitted_m);

TX_msg_LSB_F = fftshift(fft(tx_msg_LSB));
TX_msg_LSB_F_mg = abs(TX_msg_LSB_F);


%plot in freq
figure(5)
subplot(2,1,2)
plot(f_vec,TX_msg_LSB_F_mg)
title('SSB LSB TX modulated msg in freq domain (Butterworth)')


tr_msg_coh = tx_msg_LSB.*carrier;

tr_msg_coh_F = fftshift(fft(tr_msg_coh));
tr_msg_coh_F_mg = abs(tr_msg_coh_F);

%plot in freq
figure(6)
subplot(3,1,1)
plot(f_vec,tr_msg_coh_F_mg)
title('SSB LSB RX msg in freq domain(before LPF)')
%------------- LBF ---------------%
N = length(tr_msg_coh);
n = N/fs_new;
right_band = round((fs_new/2-4000)*n);
left_band = (N-right_band+1);
tr_msg_coh_F([1:right_band left_band:N]) = 0;
tr_msg_coh_F_mg = abs(tr_msg_coh_F);
tr_msg_coh_LPF = real(ifft(ifftshift(tr_msg_coh_F)));
%------------- LBF ---------------%
subplot(3,1,2)
plot(f_vec,tr_msg_coh_F_mg)
title('SSB LSB RX msg in freq domain(after LPF)')

subplot(3,1,3)
plot(t,tr_msg_coh_LPF)
title('SSB LSB RX msg in time domain(after LPF)')

%original_msg = resample(tr_msg_coh_LPF,fs,fs_new);
%sound(original_msg, fs)
%pause(10);

%% noise

n_snr=0;
add_noise(transmitted_m,t,f_vec,n_snr);
message_noise= awgn(transmitted_m, n_snr);
ideal_rx(message_noise,t,f_vec,fs_new,fs);

n_snr=10;
add_noise(transmitted_m,t,f_vec,n_snr);
message_noise= awgn(transmitted_m, n_snr);
ideal_rx(message_noise,t,f_vec,fs_new,fs);


n_snr=30;
add_noise(transmitted_m,t,f_vec,n_snr);
message_noise= awgn(transmitted_m, n_snr);
ideal_rx(message_noise,t,f_vec,fs_new,fs);






