clc
close all
[file,path] = uigetfile('./Databases/*.m4a', 'Select the speech
files', 'MultiSelect', 'on');
[ipsignal, Fs] = audioread([path,file]);
ipsignal = ipsignal(1:length(ipsignal)/2);
amp = 100;
ipsignal = amp*ipsignal;
N = length(ipsignal);
sn = 10;
ipsignalN = awgn(ipsignal,sn);
sound(ipsignalN,Fs); %giving out the noisy speech
through speaker
level = 3;
fprintf('\tchoose Wavelet:\n\t1: daubechies-13\n\t2:
Daubechies-40\n\t3: Symlet-13\n\t4: Symlet-21\n\t');
wname = input('Enter you choice: ');
if wname == 1 %if daubechies-13 wavelet
type chosen
wt = 'db13';
elseif wname == 2 %if daubechies-40 wavelet
type chosen
wt = 'db40';
elseif wname == 3 %if symlet-13 wavelet type
chosen
wt = 'sym13';
elseif wname == 4 %if symlet-21 wavelet type
chosen
wt = 'sym21';
end
[LoD,HiD,LoR,HiR] = wfilters(wt);
[C,L] = wavedec(ipsignalN,level,LoD,HiD);
cA3 = appcoef(C,L,wt,level);
[cD1,cD2,cD3] = detcoef(C,L,[1,2,3]);
A3 = wrcoef('a',C,L,LoR,HiR,level);
D1 = wrcoef('d',C,L,LoR,HiR,1);
D2 = wrcoef('D',C,L,LoR,HiR,2);
D3 = wrcoef('D',C,L,LoR,HiR,3);
%step 2 - Thresholding
fprintf('\n\tChoose Threshold Rule:\n\t1: Universal\n\t2:
Minimax\n\t3: Level dependent threshold\n\t');
tr = input('Enter your choice: ');
if tr == 1 %if Universal thresholding
rule chosen
D = [D1 D2 D3];
th = zeros(1,length(D));
Dth = zeros(1,length(D));
fprintf('\n\t choose threshold type:\n\t1: Soft\n\t2: Hard\n\t');
sh = input('Enter you choice: ');
if sh == 1 %if user wants to do soft
thresholding while following the Universal thresholding rule
sorh = 's';
elseif sh == 2 %if user wants to do hard
thresholding while following the Universal thresholding rule
sorh = 'h';
end
for g =1:length(D)
th(g) = sqrt(2*log(numel(D(g))));
Dth(g) = wthresh(D(g),sorh,th(g));
end
denoised = A3;
for i=1:length(Dth)
denoised = denoised+Dth(i);
end
customplot(ipsignal,ipsignalN,denoised);
sound(denoised,Fs);
elseif tr == 2 %if Minmax thresholding
rule chosen
tptr = 'minimaxi';
thr_D1 = thselect(D1,tptr);
thr_D2 = thselect(D2,tptr);
thr_D3 = thselect(D3,tptr);
fprintf('\n\t choose threshold type:\n\t1: Soft\n\t2: Hard\n\t');
sh = input('Enter you choice: ');
if sh == 1 %if user wants to do soft
thresholding while following the Minmax thresholding rule
sorh = 's';
elseif sh == 2 %if user wants to do hard
thresholding while following the Minmax thresholding rule
sorh = 'h';
end
elseif tr==3 %if Level dependant
thresholding rule chosen
D = [D1 D2 D3];
th = zeros(1,length(D));
Dth = zeros(1,length(D));
fprintf('\n\t choose threshold type:\n\t1: Soft\n\t2: Hard\n\t');
sh = input('Enter you choice: ');
if sh == 1 %if user wants to do soft
thresholding while following the level dependent thresholding
rule
sorh = 's';
elseif sh == 2 %if user wants to do hard
thresholding while following the level dependent thresholding
rule
sorh = 'h';
end
for g =1:length(D)
th(g) = sqrt(2*log(numel(D(g)))/pow2(i)); Dth(g) =
wthresh(D(g),sorh,th(g));
end
denoised = A3;
for i=1:length(Dth)
denoised = denoised+Dth(i);
end
%customplot(ipsignal,ipsignalN,denoised);
sound(denoised,Fs);
end
%Threshold coefficient of details
tD1 = wthresh(D1,sorh,thr_D1);
tD2 = wthresh(D2,sorh,thr_D2);
tD3 = wthresh(D3,sorh,thr_D3);
%step 3: Compute Inverse DWT
denoised = A3 + tD1 + tD2 + tD3;
customplot(ipsignal,ipsignalN,denoised)
sound(denoised,Fs); %giving out the
denoised speech through speaker
%Signal-to-Noise(SNR) Comparison
NoisySNR = snr(ipsignal,ipsignalN);
DenoisedSNR = snr(ipsignal,denoised);
disp('SNR of Noisy signal:')
disp(NoisySNR)
disp('SNR of Denoised signal:')
disp(DenoisedSNR)
function customplot(ipsignal,ipsignalN,denoised)
figure
subplot(3,1,1);
plot(ipsignal);
title('Original Speech Signal');
xlabel('samples');
ylabel('Amplitude');
subplot(3,1,2);
plot(ipsignalN);
title('Noisy Speech Signal');
xlabel('Samples');
ylabel('Amplitude');
subplot(3,1,3);
plot(denoised);
ylim([-100 100]);
title('Denoised Speech Signal');
xlabel('Samples');
ylabel('Amplitude');
end
