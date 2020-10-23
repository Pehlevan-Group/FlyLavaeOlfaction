% This is a Boolean network model for the larvae olfaction model
% The model is based on the epxerimental reusults for the WT
% We assume
% (1) Synpases can be divided into "strong" and "weak" category, depending
% on the connectomics data. We set "strong" synapse as 1 and "weak" synapse
% as tuning parameter
% (2) uPN and CSD have three states: silence, weak and strong activites
% (3) Assume no interation between CSD and mPN
% (4) when mPN is ON, while uPN is silent or weakly active, behaviroal
% output is avoidance; when mPN is OFF, attraction;

% PI        gives all the behavior output of the model can be directly compared
%           with experiment
% PI_pred   store the output of model predictions

% This is the second version of the booolean model
% last revised on 1/29/2020

clear
clc

%% load the data
% laod the connectome data, the entries have three values: 0, -0.5 and -1
dFolder = './';
weightFile = 'weights';
[rawW,TXT,RAW] = xlsread(fullfile(dFolder,weightFile),1);
w = 0.25;                   % value of "weak" interactions
rawW(rawW ==-0.5)= -w;      % set the weak inhibition
r0 = zeros(5,1);            % defaults states, all neurons are silient
% rawW(5,4) = 0;            % set the inhibitory interaction between CSD and mPN 0

% load the behavioral data
behavData = 'piExp.xlsx';
[piData,~,~] = xlsread(fullfile(dFolder,behavData),1);  % depending how to simpify the model

PI = zeros(size(piData,1),2);           % store the PI value for different "genotype" of the model
fixedPs = cell(size(piData,1),1);       % store the steady state activity
fedFixed = nan(5,size(piData,1));       % fixed point at fed states 
starvedFixed = nan(5,size(piData,1));   % fixed points at starved states

% loop through different manipulations
for i0 = 1:size(piData,1)
    I0 = [0,0,0,0.5,0]';    % external input, only mPN has, 1.1 default
    Iorn = [1,1,1,w,w]';    % inpur from ORNs, we assume CSD receives ORN input
    
    adjW = rawW;
    adjW(1,3) = -w;      % pLN0 --| uPN weak, default -w, 09/09/2020
    adjW(5,1) = -0.5;    % set the value of CSD --| pLN0
    adjW(1,2) = -1;      % inhibition of pLN1/4 by pLN0, default 0.8
    adjW(5,3) = 0;       % set CSD to uPN to be 0 
    adjW(5,4) = 0;       % set CSD --|mPN to 0
    
    KOindex = [];        % indicate if an experiment involves knockout
    if piData(i0,3)==1   % indicates perturbation
        if i0 ~= 3      
           adjW(piData(i0,4),piData(i0,5)) = 0;  % mutation, usually block interaction
        elseif i0 ==3    % mutate 5-HT1A involves both pLN0 and pLN1/4
           adjW(5,[1,4]) = 0;  % 5-HT1A knockout
        end 
    elseif piData(i0,6) ~= 0   %index of KO neuron
        KOindex = piData(i0,6);
    end
        
    % for the fed state, run the boolean dynamics until converge, here you
    % can choose synchronous update or asynchronous update
    ys = boolUpdate(r0,adjW,I0,Iorn,KOindex);
%     ys = boolUpdate(r0,adjW,zeros(5,1),zeros(5,1),KOindex);
%     ys = asyncBoolUpdate(r0,adjW,I0,Iorn,KOindex);
    fixedPs{i0}(:,1) = ys;              % fixed point, steady state of all neurons
    fedFixed(:,i0) = ys;                % store the fixed point
    PI(i0,1) = sign(ys(3) - 3*ys(4));   %  calculate the preference index
    
    % starved state
    if i0 ~= 4   % the 4th manipulation is the blocking of CSD --> uPN
        adjW(5,3) = 2;      % increased interaction between CSD --> uPN in the starved state
    end
%     ys = boolUpdate(r0,adjW,zeros(5,1),zeros(5,1),KOindex);
    ys = boolUpdate(r0,adjW,I0,Iorn,KOindex);
%     ys = asyncBoolUpdate(r0,adjW,I0,Iorn,KOindex);
    fixedPs{i0}(:,2) = ys;
    starvedFixed(:,i0) = ys; 
    PI(i0,2) = sign(ys(3) - 3*ys(4));  
end


%% Make predictions
% pLN0 KO, pLN1/4 --> pLN0 block, and CSD --| pLN0 block, mPN GABA receptor
% block
fixedPred = cell(size(piData,1),1); % store the prediction of fixed points
fedFixed_pred = nan(5,2);   
starvedFixed_pred = nan(5,2);
PI_pred = zeros(4,2);
for i0 = 1:4
    I0 = [0,0,0,0.5,0]';    % external input, only mPN has, 1.1 default
    Iorn = [1,1,1,w,w]';    % inpur from ORNs, we assume CSD receives ORN input
    
    adjW = rawW;
    adjW(1,3) = -w;      % pLN0 --| uPN weak
    adjW(5,1) = -0.5;    % set the value of CSD --| pLN0
    adjW(1,2) = -1;      % inhibition of pLN1/4 by pLN0, default 0.8
    adjW(5,4) = 0;       % set CSD --|mPN to 0
    
    KOindex = [];        % indicate if an experiment involves knockout
    % pLN0 KO
    if i0==1
       KOindex = 1; 
    % pLN1/4--> pLN0 blocks
    elseif i0==2
        adjW(2,1) = 0;
    % CSD --|pLN0 block   
    elseif i0==3
        adjW(5,1) = 0 ;
    elseif i0==4
        adjW(1,4) = 0; %pLN0 --| mPN
        adjW(2,4) = 0; % pLN1/4 --|mPN
    end
         
    % for the fed state, run the boolean dynamics until converge
    ys = boolUpdate(r0,adjW,I0,Iorn,KOindex);
%     ys = asyncBoolUpdate(r0,adjW,I0,Iorn,KOindex);
    fixedPred{i0}(:,1) = ys;  % fixed point, steady state of all neurons
    fedFixed_pred(:,i0) = ys;     % store the fixed point
    PI_pred(i0,1) = sign(ys(3) - 3*ys(4));  %  calculate the preference index
    
    % for starved state
    adjW(5,3) = 2;
    ys = boolUpdate(r0,adjW,I0,Iorn,KOindex);
%     ys = asyncBoolUpdate(r0,adjW,I0,Iorn,KOindex);
    fixedPred{i0}(:,2) = ys;
    starvedFixed_pred(:,i0) = ys; 
    PI_pred(i0,2) = sign(ys(3) - 3*ys(4));  
end

