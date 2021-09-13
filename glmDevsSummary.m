clear all; close all; clc;

%% params
% fname = 'AH1024_datastruct';
% fname = 'AH1100_datastruct';
% fname = 'AH1107_datastruct';
% fname = 'AH1147_datastruct';
fname = 'AH1149_datastruct';

% % fname = 'AH1110_datastruct';
% % fname = 'AH1148_datastruct';
% % fname = 'AH1151_datastruct';


fs = 15.44;
trialSkip = 30;
fnames = {'AH1024_datastruct', 'AH1100_datastruct', 'AH1107_datastruct', 'AH1147_datastruct', 'AH1149_datastruct'};

devs = [];
cr = [];
lickRate = [];
sessionLength = [];
sessionVariance = [];
alignVarianceX = [];
alignVarianceY = [];

for i = 1:length(fnames)
    data = load([fnames{i}, '.mat']);

    inputNames = {'lickTimesVec', 'poleOnsetVec', 'poleDownVec', 'alignInfoX', 'alignInfoY', 'waterTimesVec'};
    windowSizes = [floor(5 * fs);...
                   floor(1 * fs);...
                   floor(1 * fs);...
                   floor(1 * fs);...
                   floor(1 * fs);...
                   floor(5 * fs);]; % window sizes for design matrix

    allSessions = mouseGLMAnalysis(data, fs, trialSkip, inputNames, windowSizes);

    %% plot summary
    % deviance explained
    devs = [devs, cellfun(@(x) x.fit.dev(end), allSessions)];
    cr = [cr cellfun(@(x) x.sessionStruct.correctRate, allSessions)];
    lickRate = [lickRate cellfun(@(x) sum(x.lickVec) / length(x.lickVec), allSessions)];
    sessionLength = [sessionLength cellfun(@(x) length(x.lickVec), allSessions)];
    sessionVariance = [sessionVariance cellfun(@(x) var(x.trueY), allSessions)];
    alignVarianceX = [alignVarianceX cellfun(@(x) var(x.sessionStruct.alignInfoX), allSessions)];
    alignVarianceY = [alignVarianceY cellfun(@(x) var(x.sessionStruct.alignInfoY), allSessions)];
end

figure('Renderer', 'painters', 'Position', [100 100 1200 200]); 
subplot(1,6,1); scatter(cr, devs, 'k'); [r, p] = corrcoef(cr, devs); title([num2str(r(1, 2)), ',', num2str(p(1, 2))]); xlabel('Correct Rate')
subplot(1,6,2); scatter(lickRate, devs, 'k'); [r, p] = corrcoef(lickRate, devs); title([num2str(r(1, 2)), ',', num2str(p(1, 2))]); xlabel('Lick Rate')
subplot(1,6,3); scatter(sessionLength, devs, 'k'); [r, p] = corrcoef(sessionLength, devs); title([num2str(r(1, 2)), ',', num2str(p(1, 2))]); xlabel('Session Length')
subplot(1,6,4); scatter(sessionVariance, devs, 'k'); [r, p] = corrcoef(sessionVariance, devs); title([num2str(r(1, 2)), ',', num2str(p(1, 2))]); xlabel('Session Var')
subplot(1,6,5); scatter(alignVarianceX, devs, 'k'); [r, p] = corrcoef(alignVarianceX, devs); title([num2str(r(1, 2)), ',', num2str(p(1, 2))]); xlabel('alignX Var')
subplot(1,6,6); scatter(alignVarianceY, devs, 'k'); [r, p] = corrcoef(alignVarianceY, devs); title([num2str(r(1, 2)), ',', num2str(p(1, 2))]); xlabel('alignY Var')


