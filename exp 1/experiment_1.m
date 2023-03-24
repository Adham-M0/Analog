
[xin ,fs] = audioread('eric.wav');
%sound(xin,fs);

% Extract only one channel if the audio is stereo
x = xin(:,1);

% Create time axis
t = linspace(0,length(x)/fs, length(x));

%plot in time domain
figure(1)
subplot(4,1,1)
plot(t,xin)
title('Original signal in Time domain')

%fft
X = fftshift(fft(x));
X_ABS = abs(X);
W = angle(X);
N = length(x);
F = linspace(-fs/2,fs/2,N);

%plot in frequency domain
subplot(4,1,2)
plot(F,X_ABS)
title('Original signal in Frequency domain')

%--ideal LPF at 4000hz--%
N = length(x);
n = N/fs;
r_limit = round((fs/2-4000)*n);
l_limit = (N-r_limit+1);
X([1:r_limit l_limit:N]) = 0;

X_ABS = abs(X);

%plot in frequency domain
subplot(4,1,3)
plot(F,X_ABS)
title('LPF(4khz) Signal in Frequency domain')

x = real(ifft(ifftshift(X)));
%plot in time domain
subplot(4,1,4)
plot(t,xin)
title('LPF(4khz) Signal in Time domain')

%sound(x,fs);
%audiowrite('C:\Users\Ragai\Desktop\Analog Project\Original audio filtered.wav',x,fs);

%%%%%%%%%%%DSB-SC%%%%%%%%%%%%%%%
fc = 100000;  %Carrier frequency
new_fs = 5*fc;  % new sample rate for message

% resampling message signal
msg_resampled = resample(x,new_fs,fs);

% Creating Time axis for resampled signal
t_end = length(msg_resampled)./new_fs;
t = linspace(0,t_end, length(msg_resampled));

% modulating
carrier = cos(2*pi*fc*t);
carrier = carrier';  % transpose to be a row matrix
% Shifting the signal to fc and -fc
send_signal = msg_resampled.*carrier;  % Multiplication in time domain

% freq domain
SEND_SIGNAL = fftshift(fft(send_signal));
SEND_SIGNAL_ABS = abs(SEND_SIGNAL);
N = length(send_signal);
F = linspace(-new_fs/2,new_fs/2,N);

figure(2)
subplot(5,1,1)
plot(t,msg_resampled)
title('Msg signal in Time domain')

MSG_resampled = fftshift(fft(msg_resampled));
MSG_resampled_MG = abs(X);
MSG_resampled_PHASE = angle(X);
N = length(X);
MSG_F = linspace(-new_fs/2,new_fs/2,N);

subplot(5,1,2)
plot(MSG_F,MSG_resampled_MG)
title('Msg signal in Freq domain')


subplot(5,1,3)
plot(F,SEND_SIGNAL_ABS)
title('DSB-SC TX modulated msg in Freq domain')

subplot(5,1,4)
plot(t,send_signal)
title('DSB-SC TX modulated msg in Time domain')


%%%%%DSB-SC Envelope Receiver%%%%%%

envelop = abs(hilbert(send_signal));

subplot(5,1,5)
plot(t,envelop)
title('DSB-SC RX-Envelop msg in time domain')

% Resample down to play audio
original_audio = resample(envelop,fs,new_fs);
%sound(original_audio,fs);
%audiowrite('C:\Users\Ragai\Desktop\Analog Project\DSB-SC Envelope.wav',original_audio,fs);



%%%%%%%%%%%%%%%%% COHERENT Detector 0 SNR %%%%%%%%%%%%%%%%%%%%
% add noise
send_signal_noisy = awgn(send_signal,0);
figure(3)
subplot(7,1,1)
plot(t,msg_resampled)
title('Msg signal in Time domain')

subplot(7,1,2)
plot(MSG_F,MSG_resampled_MG)
title('Msg signal in Freq domain')


send_signal_noisy_FREQ = fftshift(fft(send_signal_noisy));
N = length(send_signal_noisy_FREQ);
F = linspace(-new_fs/2,new_fs/2,N);

subplot(7,1,3)
plot(F,abs(send_signal_noisy_FREQ))
title('DSB-SC with 0 SNR signal in Freq domain')

subplot(7,1,4)
plot(t,send_signal_noisy)
title('DSB-SC with 0 SNR signal in Time domain')


carrier = cos(2*pi*fc*t);
carrier = carrier';  % transpose to be a row matrix

% coherent (multiply msg with carrier)
coherent_detector_signal = send_signal_noisy.*carrier;

COHERENT_DETECTOR_SIGNAL = fftshift(fft(coherent_detector_signal));
% freq domain plot (befor Ideal LBF)
N = length(coherent_detector_signal);
F = linspace(-new_fs/2,new_fs/2,N);
subplot(7,1,5)
COHERENT_DETECTOR_SIGNAL_ABS = abs(COHERENT_DETECTOR_SIGNAL);
plot(F,COHERENT_DETECTOR_SIGNAL_ABS)
title('DSB RX-Coherent (SNR=0) msg in frequency domain (befor Ideal LBF)')


%------------- LBF ---------------%
N = length(coherent_detector_signal);
n = N/new_fs;
r_limit = round((new_fs/2-4000)*n);
l_limit = (N-r_limit+1);
COHERENT_DETECTOR_SIGNAL([1:r_limit l_limit:N]) = 0;
coherent_detector_signal_LPF = real(ifft(ifftshift(COHERENT_DETECTOR_SIGNAL)));
%------------- LBF ---------------%

% As a result of multipling the received signal with carrier there will be high freq components
% at 2fc. So, we put the filter to remove them.

% freq domain plot (after Ideal LBF)
subplot(7,1,6)
COHERENT_DETECTOR_SIGNAL_ABS = abs(COHERENT_DETECTOR_SIGNAL);
plot(F,COHERENT_DETECTOR_SIGNAL_ABS)
title('DSB RX-Coherent (SNR=0) msg in frequency domain ')


% time domain plot
subplot(7,1,7)
plot(t,coherent_detector_signal_LPF)
title('DSB RX-Coherent (SNR=0) msg in Time domain')

original_msg = resample(coherent_detector_signal_LPF,fs,new_fs);
%sound(original_msg,fs)
%audiowrite('C:\Users\Ragai\Desktop\Analog Project\DSB-SC Coherent 0 SNR.wav',original_msg,fs);



%%%%%%%%%%%%%%%%% COHERENT Detector 10 SNR %%%%%%%%%%%%%%%%%%%%
% add noise
send_signal_noisy = awgn(send_signal,10);
figure(4)
subplot(7,1,1)
plot(t,msg_resampled)
title('Msg signal in Time domain')

subplot(7,1,2)
plot(MSG_F,MSG_resampled_MG)
title('Msg signal in Freq domain')


send_signal_noisy_FREQ = fftshift(fft(send_signal_noisy));
N = length(send_signal_noisy_FREQ);
F = linspace(-new_fs/2,new_fs/2,N);

subplot(7,1,3)
plot(F,abs(send_signal_noisy_FREQ))
title('DSB-SC with 10 SNR signal in Freq domain')

subplot(7,1,4)
plot(t,send_signal_noisy)
title('DSB-SC with 10 SNR signal in Time domain')


carrier = cos(2*pi*fc*t);
carrier = carrier';  % transpose to be a row matrix

% coherent (multiply msg with carrier)
coherent_detector_signal = send_signal_noisy.*carrier;

COHERENT_DETECTOR_SIGNAL = fftshift(fft(coherent_detector_signal));
% freq domain plot (befor Ideal LBF)
N = length(coherent_detector_signal);
F = linspace(-new_fs/2,new_fs/2,N);
subplot(7,1,5)
COHERENT_DETECTOR_SIGNAL_ABS = abs(COHERENT_DETECTOR_SIGNAL);
plot(F,COHERENT_DETECTOR_SIGNAL_ABS)
title('DSB RX-Coherent (SNR=10) msg in frequency domain (befor Ideal LBF)')


%------------- LBF ---------------%
N = length(coherent_detector_signal);
n = N/new_fs;
r_limit = round((new_fs/2-4000)*n);
l_limit = (N-r_limit+1);
COHERENT_DETECTOR_SIGNAL([1:r_limit l_limit:N]) = 0;
coherent_detector_signal_LPF = real(ifft(ifftshift(COHERENT_DETECTOR_SIGNAL)));
%------------- LBF ---------------%

% As a result of multipling the received signal with carrier there will be high freq components
% at 2fc. So, we put the filter to remove them.

% freq domain plot (after Ideal LBF)
subplot(7,1,6)
COHERENT_DETECTOR_SIGNAL_ABS = abs(COHERENT_DETECTOR_SIGNAL);
plot(F,COHERENT_DETECTOR_SIGNAL_ABS)
title('DSB RX-Coherent (SNR=10) msg in frequency domain ')


% time domain plot
subplot(7,1,7)
plot(t,coherent_detector_signal_LPF)
title('DSB RX-Coherent (SNR=10) msg in Time domain')

original_msg = resample(coherent_detector_signal_LPF,fs,new_fs);
%sound(original_msg,fs)
%audiowrite('C:\Users\Ragai\Desktop\Analog Project\DSB-SC Coherent 10 SNR.wav',original_msg,fs);



%%%%%%%%%%%%%%%%% COHERENT Detector 30 SNR %%%%%%%%%%%%%%%%%%%%
% add noise
send_signal_noisy = awgn(send_signal,30);
figure(5)
subplot(7,1,1)
plot(t,msg_resampled)
title('Msg signal in Time domain')

subplot(7,1,2)
plot(MSG_F,MSG_resampled_MG)
title('Msg signal in Freq domain')


send_signal_noisy_FREQ = fftshift(fft(send_signal_noisy));
N = length(send_signal_noisy_FREQ);
F = linspace(-new_fs/2,new_fs/2,N);

subplot(7,1,3)
plot(F,abs(send_signal_noisy_FREQ))
title('DSB-SC with 30 SNR signal in Freq domain')

subplot(7,1,4)
plot(t,send_signal_noisy)
title('DSB-SC with 30 SNR signal in Time domain')


carrier = cos(2*pi*fc*t);
carrier = carrier';  % transpose to be a row matrix

% coherent (multiply msg with carrier)
coherent_detector_signal = send_signal_noisy.*carrier;

COHERENT_DETECTOR_SIGNAL = fftshift(fft(coherent_detector_signal));
% freq domain plot (befor Ideal LBF)
N = length(coherent_detector_signal);
F = linspace(-new_fs/2,new_fs/2,N);
subplot(7,1,5)
COHERENT_DETECTOR_SIGNAL_ABS = abs(COHERENT_DETECTOR_SIGNAL);
plot(F,COHERENT_DETECTOR_SIGNAL_ABS)
title('DSB RX-Coherent (SNR=30) msg in frequency domain (befor Ideal LBF)')


%------------- LBF ---------------%
N = length(coherent_detector_signal);
n = N/new_fs;
r_limit = round((new_fs/2-4000)*n);
l_limit = (N-r_limit+1);
COHERENT_DETECTOR_SIGNAL([1:r_limit l_limit:N]) = 0;
coherent_detector_signal_LPF = real(ifft(ifftshift(COHERENT_DETECTOR_SIGNAL)));
%------------- LBF ---------------%

% As a result of multipling the received signal with carrier there will be high freq components
% at 2fc. So, we put the filter to remove them.

% freq domain plot (after Ideal LBF)
subplot(7,1,6)
COHERENT_DETECTOR_SIGNAL_ABS = abs(COHERENT_DETECTOR_SIGNAL);
plot(F,COHERENT_DETECTOR_SIGNAL_ABS)
title('DSB RX-Coherent (SNR=30) msg in frequency domain ')


% time domain plot
subplot(7,1,7)
plot(t,coherent_detector_signal_LPF)
title('DSB RX-Coherent (SNR=30) msg in Time domain')

original_msg = resample(coherent_detector_signal_LPF,fs,new_fs);
%sound(original_msg,fs)
%audiowrite('C:\Users\Ragai\Desktop\Analog Project\DSB-SC Coherent 30 SNR.wav',original_msg,fs);


%%%%%%%%COHERENT Detector with frequency 100.1%%%%%%%%%%%%%%5
carrier = cos(2*pi*100100*t);
carrier = carrier';  % transpose to be a row matrix

% coherent (multiply msg with carrier)
coherent_detector_signal = send_signal.*carrier;

COHERENT_DETECTOR_SIGNAL = fftshift(fft(coherent_detector_signal));
% freq domain plot (befor Ideal LBF)
N = length(coherent_detector_signal);
F = linspace(-new_fs/2,new_fs/2,N);

figure(6)
subplot(7,1,1)
plot(t,msg_resampled)
title('Msg signal in Time domain')

subplot(7,1,2)
plot(MSG_F,MSG_resampled_MG)
title('Msg signal in Freq domain')


subplot(7,1,3)
plot(F,SEND_SIGNAL_ABS)
title('DSB-SC TX modulated msg in Freq domain')

subplot(7,1,4)
plot(t,send_signal)
title('DSB-SC TX modulated msg in Time domain')

subplot(7,1,5)
COHERENT_DETECTOR_SIGNAL_ABS = abs(COHERENT_DETECTOR_SIGNAL);
plot(F,COHERENT_DETECTOR_SIGNAL_ABS)
title('DSB RX-Coherent (FREQ=100.1KHz) msg in frequency domain (befor Ideal LBF)')


%------------- LBF ---------------%
N = length(coherent_detector_signal);
n = N/new_fs;
r_limit = round((new_fs/2-4000)*n);
l_limit = (N-r_limit+1);
COHERENT_DETECTOR_SIGNAL([1:r_limit l_limit:N]) = 0;
coherent_detector_signal_LPF = real(ifft(ifftshift(COHERENT_DETECTOR_SIGNAL)));
%------------- LBF ---------------%

% As a result of multipling the received signal with carrier there will be high freq components
% at 2fc. So, we put the filter to remove them.

% freq domain plot (after Ideal LBF)
subplot(7,1,6)
COHERENT_DETECTOR_SIGNAL_ABS = abs(COHERENT_DETECTOR_SIGNAL);
plot(F,COHERENT_DETECTOR_SIGNAL_ABS)
title('DSB RX-Coherent  (FREQ=100.1KHz) msg in frequency domain ')


% time domain plot
subplot(7,1,7)
plot(t,coherent_detector_signal_LPF)
title('DSB RX-Coherent  (FREQ=100.1KHz) msg in Time domain')

original_msg = resample(coherent_detector_signal_LPF,fs,new_fs);
%sound(original_msg,fs)
%audiowrite('C:\Users\Ragai\Desktop\Analog Project\DSB-SC Coherent  (FREQ=100.1KHz).wav',original_msg,fs);

%%%%%%%%COHERENT Detector with phase shift 20 degrees %%%%%%%%%%%%%%5
carrier = cos(2*pi*fc*t+20/180*pi);
carrier = carrier';  % transpose to be a row matrix

% coherent (multiply msg with carrier)
coherent_detector_signal = send_signal.*carrier;

COHERENT_DETECTOR_SIGNAL = fftshift(fft(coherent_detector_signal));
% freq domain plot (befor Ideal LBF)
N = length(coherent_detector_signal);
F = linspace(-new_fs/2,new_fs/2,N);

figure(7)
subplot(7,1,1)
plot(t,msg_resampled)
title('Msg signal in Time domain')

subplot(7,1,2)
plot(MSG_F,MSG_resampled_MG)
title('Msg signal in Freq domain')


subplot(7,1,3)
plot(F,SEND_SIGNAL_ABS)
title('DSB-SC TX modulated msg in Freq domain')

subplot(7,1,4)
plot(t,send_signal)
title('DSB-SC TX modulated msg in Time domain')

subplot(7,1,5)
COHERENT_DETECTOR_SIGNAL_ABS = abs(COHERENT_DETECTOR_SIGNAL);
plot(F,COHERENT_DETECTOR_SIGNAL_ABS)
title('DSB RX-Coherent (PHASE=20 degrees) msg in frequency domain (befor Ideal LBF)')


%------------- LBF ---------------%
N = length(coherent_detector_signal);
n = N/new_fs;
r_limit = round((new_fs/2-4000)*n);
l_limit = (N-r_limit+1);
COHERENT_DETECTOR_SIGNAL([1:r_limit l_limit:N]) = 0;
coherent_detector_signal_LPF = real(ifft(ifftshift(COHERENT_DETECTOR_SIGNAL)));
%------------- LBF ---------------%

% As a result of multipling the received signal with carrier there will be high freq components
% at 2fc. So, we put the filter to remove them.

% freq domain plot (after Ideal LBF)
subplot(7,1,6)
COHERENT_DETECTOR_SIGNAL_ABS = abs(COHERENT_DETECTOR_SIGNAL);
plot(F,COHERENT_DETECTOR_SIGNAL_ABS)
title('DSB RX-Coherent  (PHASE=20 degrees) msg in frequency domain ')


% time domain plot
subplot(7,1,7)
plot(t,coherent_detector_signal_LPF)
title('DSB RX-Coherent  (PHASE=20 degrees) msg in Time domain')

original_msg = resample(coherent_detector_signal_LPF,fs,new_fs);
%sound(original_msg,fs)
%audiowrite('C:\Users\Ragai\Desktop\Analog Project\DSB-SC Coherent(PHASE=20 degrees).wav',original_msg,fs);


%%%%%%%%% DSP TC %%%%%%
A = max(msg_resampled)*2 ; % Amplitude of carier is double max value m=0.5

% modulating
carrier = cos(2*pi*fc*t);
carrier = carrier';
send_signal = (A + msg_resampled).*carrier;


% freq domain
SEND_SIGNAL = fftshift(fft(send_signal));
SEND_SIGNAL_ABS = abs(SEND_SIGNAL);
N = length(send_signal);
F = linspace(-new_fs/2,new_fs/2,N);

figure(7)
subplot(2,1,1)
plot(F,SEND_SIGNAL_ABS)
title('DSB-TC TX modulated msg in freq domain')

%------------------------- RX --------------------------%
%------------- Envelop--------------%
envelop = abs(hilbert(send_signal));

subplot(2,1,2)
plot(t,envelop)
title('DSB-TC RX-Envelop msg in time domain')


original_msg = resample(envelop,fs,new_fs);
%sound(original_msg,fs)
%audiowrite('C:\Users\Ragai\Desktop\Analog Project\DSB-TC.wav',original_msg,fs);


