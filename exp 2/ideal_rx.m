function ideal_rx(transmitted_m,t,f_vec,fs_new,fs)
received_message = transmitted_m.*(cos(2*pi*100000*t)');
f_received_message = fftshift(fft(received_message));
received_message_mg = abs(f_received_message);


figure
subplot(3,1,1)
plot(f_vec,received_message_mg)
title('SSB-SC RX-Coherent no noise, msg in frequency domain (before LPF))')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Ideal LPF%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LPF to remove signal @ 2fc

N = length(received_message);
n = N/fs_new;
right_band = round((fs_new/2-4000)*n);
left_band = (N-right_band+1);
f_received_message([1:right_band left_band:N]) = 0;
received_message_mg = abs(f_received_message);
received_message = real(ifft(ifftshift(f_received_message)));

subplot(3,1,2)
plot(t,received_message)
title('SSB LSB RX msg in time domain(after Ideal LPF)')

subplot(3,1,3)
plot(f_vec,received_message_mg)
title('SSB LSB RX msg in freq domain(after Ideal LPF)')
original_msg = resample(received_message,fs,fs_new);
%sound(original_msg, fs)
