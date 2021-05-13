clear all; close all; clc;

%% params
fs = 1000;
dt = 1/fs;
vecLength = 100 * fs;
fr = 5;

%% generate random lick pattern
lickVec = double(rand(1, vecLength) < fr*dt);
tVec = (1:vecLength).*dt;

figure;
plot(tVec, lickVec);

%% define response kernel
kernelLength = 0.4;
kernel = sin(linspace(pi/2, pi, kernelLength*fs));

figure;
plot(kernel);

%% filter signal with kernel
filtResponse = filter(kernel, 1, lickVec) + (randn(1, length(lickVec))*0.05);

figure; hold on;
plot(filtResponse, 'k');
plot(lickVec, 'b');

%% GLM

%% predict trace from lick
d = 0.5 * fs; % window size

y = filtResponse';

% designMatrix
designMatrix = nan(length(y)-d,d);
c = 1;
for i = (d+1):length(y)
    lickWindow = lickVec((i-d+1):i);
    designMatrix(c, :) = [lickWindow];
    
    c = c+1;
end

figure;
imagesc(designMatrix)
fit = glmnet(designMatrix, y(d+1:end));
glmnetPrint(fit);
yHat = glmnetPredict(fit, designMatrix);

figure; hold on;
plot(yHat(:, end), 'r', 'LineWidth', 2);
plot(y(d+1:end), 'k');

figure; hold on;
plot(flipud(fit.beta(:, end)), 'r');
plot(kernel, 'k');