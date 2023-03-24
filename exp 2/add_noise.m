function add_noise(transmitted_m,t,f_vec, n_snr)

message_noise= awgn(transmitted_m, n_snr);
f_transmitted_m=abs(fftshift(fft(message_noise)));
f_message_noise=fftshift(fft(message_noise));
f_noise_mg=abs(f_message_noise);


figure

subplot(4,1,1)
plot(t,transmitted_m)
title('transmitted message before noise in time domain')

subplot(4,1,2)
plot(f_vec,f_transmitted_m)
title('transmitted message before noise in frequency domain')

subplot(4,1,3)
plot(t,message_noise)
title('transmitted message after noise in time domain')

subplot(4,1,4)
plot(f_vec,f_noise_mg)
title('transmitted message after noise in frequency domain')
