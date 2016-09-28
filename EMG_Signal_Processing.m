%% Load the Data Files
clear

con1 = csvread('Control1-Table 1.csv');
con2 = csvread('Control2-Table 1.csv');
con3 = csvread('Control3-Table 1.csv');
heat1 = csvread('Heat1-Table 1.csv');
heat2 = csvread('Heat2-Table 1.csv');
heat3 = csvread('Heat3-Table 1.csv');
cold1 = csvread('Cold1-Table 1.csv');
cold2 = csvread('Cold2-Table 1.csv');
cold3 = csvread('Cold3-Table 1.csv');

%% Average the Data

coldavg = zeros(length(cold2),2);
conavg = zeros(length(con1),2);
heatavg = zeros(length(heat1),2);

%these for loops average the voltage data together for the first N samples
%of each trial. This is not ideal, but we can only average data based on
%the shortest trial.
for i = 1:length(con1)
    conavg(i,1) = con1(i,1);
    conavg(i,2) = mean([con1(i,2);con2(i,2);con3(i,2)]);
end
conavg(:,2) = conavg(:,2)-1.45; % -1.45V to remove the DC offset
for i = 1:length(heat1)
    heatavg(i,1) = heat1(i,1);
    heatavg(i,2) = mean([heat1(i,2);heat2(i,2);heat3(i,2)]);
end
heatavg(:,2) = heatavg(:,2)-1.45; % -1.45V to remove the DC offset
for i = 1:length(cold1)
    coldavg(i,1) = cold1(i,1);
    coldavg(i,2) = mean([cold1(i,2);cold1(i,2);cold3(i,2)]);
end
coldavg(:,2) = coldavg(:,2)-1.45; % -1.45V to remove the DC offset

%% Plot Data
fs = 1000; % Sampling Frequency, Hz

figure(1)
subplot(3,1,1) 
plot(conavg(:,1)/fs,conavg(:,2),'Linewidth',3) %Plots the control data
title('Control')
xlabel('Time (s)')
ylabel('Amplitude (V)')
axis([-.5 18 -2.6 2.9]);

subplot(3,1,2)
plot(heatavg(:,1)/fs,heatavg(:,2),'Linewidth',3) %Plots the heat data
title('Heat')
xlabel('Time (s)')
ylabel('Amplitude (V)')
axis([-.5 18 -2.6 2.9]);

subplot(3,1,3)
plot(coldavg(:,1)/fs,coldavg(:,2),'Linewidth',3) %Plots the cold data
title('Cold')
xlabel('Time (s)')
ylabel('Amplitude (V)')
axis([-.5 18 -2.6 2.9]);

%% RMS Values

conrms = zeros(length(conavg),2);
heatrms = zeros(length(heatavg),2);
coldrms = zeros(length(coldavg),2);

%this for-loop takes the rms of the voltage data to smooth the signal and
%remove noise 

for i = 1:length(conavg)
    conrms(i,1) = conavg(i,1);
    conrms(i,2) = rms(conavg(i,2));
    heatrms(i,1) = heatavg(i,1);
    heatrms(i,2) = rms(heatavg(i,2));
    coldrms(i,1) = coldavg(i,1);
    coldrms(i,2) = rms(coldavg(i,2));
end

%% Plot RMS
figure(2)
subplot(3,1,1) 
plot(conrms(:,1)/fs,conrms(:,2),'Linewidth',3) %Plots the control rms
title('Control RMS')
xlabel('Time (s)')
ylabel('Amplitude (V)')
axis([-.5 18 0 3]);

subplot(3,1,2)
plot(heatrms(:,1)/fs,heatrms(:,2),'Linewidth',3) %Plots the heat RMS
title('Heat RMS')
xlabel('Time (s)')
ylabel('Amplitude (V)')
axis([-.5 18 0 3]);

subplot(3,1,3)
plot(coldrms(:,1)/fs,coldrms(:,2),'Linewidth',3) %Plots the cold RMS
title('Cold RMS')
xlabel('Time (s)')
ylabel('Amplitude (V)')
axis([-.5 18 0 3]);


%% Periodogram

[pcon, fcon] = periodogram(conavg(:,2),[],[],fs);
[pheat, fheat] = periodogram(heatavg(:,2),[],[],fs);
[pcold, fcold] = periodogram(coldavg(:,2),[],[],fs);

% Plot the periodogram for each trial
figure(3)
subplot(3,1,1)
plot(fcon(650:end),pcon(650:end));
title('Periodogram of Control Data')
xlabel('Frequency (Hz)')
ylabel('Power Spectral Density (V^2/Hz)')
axis([10 510 -.001 .012]);

subplot(3,1,2)
plot(fheat(650:end),pheat(650:end));
title('Periodogram of Heat Data')
xlabel('Frequency (Hz)')
ylabel('Power Spectral Density (V^2/Hz)')
axis([10 510 -.001 .012]);

subplot(3,1,3)
plot(fcold(650:end),pcold(650:end));
title('Periodogram of Cold Data')
xlabel('Frequency (Hz)')
ylabel('Power Spectral Density (V^2/Hz)')
axis([10 510 -.001 .012]);


%% Overall Frequency Mean and Median

mpfcon = meanfreq(conavg(1:8950,2),fs);
mpfheat = meanfreq(heatavg(1:12222,2),fs);
mpfcold = meanfreq(coldavg(1:5786,2),fs);

medpfcon = medfreq(conavg(1:8950,2),fs);
medpfheat = medfreq(heatavg(1:12222,2),fs);
medpfcold = medfreq(coldavg(1:5786,2),fs);

%% Find Median Frequencies

%Plot median frequencies for each trial
figure(4)
subplot(3,1,1)
medfreq(pcon,fcon);
grid off

subplot(3,1,2)
medfreq(pheat,fheat);
grid off

subplot(3,1,3)
medfreq(pcold,fcold);
grid off

%% Plot Median Frequencies Vs Time for Linear Regression

dr = 50; % division rate
conmdf = zeros(floor(length(conavg)/dr),1);
heatmdf = zeros(floor(length(conavg)/dr),1);
coldmdf = zeros(floor(length(conavg)/dr),1);

for i = 0:floor(length(conavg)/dr)-1
    conmdf(i+1) = median(abs(fft(conavg((1+dr*i):(dr+dr*i),2),...
        length(conavg)).^2));
    heatmdf(i+1) = median(abs(fft(heatavg((1+dr*i):(dr+dr*i),2),...
        length(conavg)).^2));
    coldmdf(i+1) = median(abs(fft(coldavg((1+dr*i):(dr+dr*i),2),...
        length(conavg)).^2));
end

% fit lines (this information was taken using the basic fitting capability
% of MATLAB and then hard-coded in to plot them onto each graph

xdim = linspace(0,length(conmdf)*dr/1000,length(conmdf));
confit = [-.0306,.4609];
cony = confit(1)*xdim+confit(2);
heatfit = [-.0211,0.5724];
heaty = heatfit(1)*xdim+heatfit(2);
coldfit = [-.0412,.6396];
coldy = coldfit(1)*xdim+coldfit(2);

% Plot median frequencies with best fit lines
figure(5)

subplot(3,1,1)
plot(xdim,conmdf)
hold on
plot(xdim,cony)
hold off

subplot(3,1,2)
plot(xdim,heatmdf)
hold on
plot(xdim,heaty)
hold off

subplot(3,1,3)
plot(xdim,coldmdf)
hold on
plot(xdim,coldy)
hold off

% Plot spectrograms of the data for control, heat, and cold trials
figure(6)

subplot(3,1,1)
spectrogram(conavg(:,2),'yaxis')

subplot(3,1,2)
spectrogram(heatavg(:,2),'yaxis')

subplot(3,1,3)
spectrogram(coldavg(:,2),'yaxis')
