clear all; close all; clc;

y = rand(100, 1);
x = y/2;

fit = glmnet(x, y);
glmnetPrint(fit);
glmnetPredict(fit,[],0.01,'coef')
glmnetPredict(fit,x,[0.01]') %make predictions