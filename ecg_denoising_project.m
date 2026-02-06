
clc;
clear;
close all;

%.hea file upload
fid = fopen('00001_hr.hea','r');
header = textscan(fid,'%s','Delimiter','\n');
fclose(fid);

line1 = header{1}{1};
parts = strsplit(line1);

num_channels = str2double(parts{2});
Fs = str2double(parts{3});

%read binary data9(.dat )
fid = fopen('00001_hr.dat','r');
raw = fread(fid,'int16');
fclose(fid);

signal = reshape(raw, num_channels, []).';
t = (0:length(signal)-1)/Fs;

%channel selection
signal_noisy = signal(:,1);

% FIR Moving Average Filter

windowSize = 10;
b_ma = ones(1,windowSize)/windowSize;
signal_fir = conv(signal_noisy,b_ma,'same');

%  IIR Exponential Filter

alpha = 0.1;
signal_iir = filter(alpha,[1 -(1-alpha)],signal_noisy);

%  FFT Analysis

N = length(signal_noisy);
f = (0:N-1)*(Fs/N);

fft_noisy = abs(fft(signal_noisy))/N;
fft_fir   = abs(fft(signal_fir))/N;
fft_iir   = abs(fft(signal_iir))/N;


% IMAGE 1: RAW ECG
figure;
plot(t,signal_noisy)
title('Raw ECG Signal from PhysioNet')
xlabel('Time (s)')
ylabel('Amplitude')
grid on
saveas(gcf,'raw_ecg.png');


% IMAGE 2: NOISY + FILTERED + FFT

figure;

subplot(3,1,1)
plot(t,signal_noisy)
title('Original ECG Signal (Noisy)')
xlabel('Time (s)')
ylabel('Amplitude')

subplot(3,1,2)
plot(t,signal_fir,'r')
hold on
plot(t,signal_iir,'g')
title('Filtered ECG Signals')
xlabel('Time (s)')
ylabel('Amplitude')
legend('FIR (Moving Avg)','IIR (Exponential)')

subplot(3,1,3)
plot(f,fft_noisy,'k')
hold on
plot(f,fft_fir,'r')
plot(f,fft_iir,'g')
xlim([0 100])
title('FFT Spectral Analysis')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
legend('Noisy','FIR','IIR')

saveas(gcf,'filtered_fft_results.png');


% IMAGE 3: ZOOMED ECG (1–3 sec)

zoom_start = 1;
zoom_end   = 3;

idx = (t >= zoom_start) & (t <= zoom_end);

figure;
plot(t(idx),signal_noisy(idx))
title('Zoomed ECG Signal (1–3 seconds)')
xlabel('Time (s)')
ylabel('Amplitude')
grid on
saveas(gcf,'zoomed_ecg.png');

disp('All images generated successfully!');