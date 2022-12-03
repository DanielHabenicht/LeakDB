% LScFlows: vector of all measurements
% 365 * 24 * 2 (2 measurements per hour)
%LScFlows = zeros(17520, 1);
%LScFlows = randn(17520,1);
%gamma = 0.1;
%t1 = datetime(2013,1,1,8,0,0);
%t2 = t1 + days(365) - minutes(30);
%timeStamps = t1:minutes(30):t2;

function [Labels_Sc, Labels_Sc_Final1] = algorithmMNF(LScFlows, gamma, timeStamps)

    %% MNF code
    w=10; % window size  
    k = 1:w; % window: day indices
    Labels_Sc=[];

    reshaped = reshape(LScFlows,48,365);
    % Shape into day sized vectors

    MNF = min(reshape(LScFlows,48,365));
    %get minimum flows per day

    % start the search for leaks at time window + first day
    for j=(w+1):365
        % get MNF of the 10 day window
        minMNFW = min(MNF(k));
        % get residual of current day MNF and minmum MNF of the window
        e = MNF(j)-minMNFW;

        % compare residual against minmum night flow threshold
        if e>minMNFW*gamma
            % set label of current day
            Labels_Sc(j) = 1;
        else
            % set label of current day
            Labels_Sc(j) = 0;
            % move window one day forward, e.g. [1:10] to [2:11]
            k(w+1) = j;
            k(1) = [];
        end
    end
    
    Labels_Sc_Final1 = [];
    j=48; % j=number of measurements per day
    % for each day
    for d=1:size(Labels_Sc,2)
        % Scale Labels to measurements vector by applying the daily label
        % to each measurement
        Labels_Sc_Final1(j-47:j,1)=Labels_Sc(d);
        j = j+48;
    end
    
    clear Labels_Sc
    % Combine labels and timestamps?
    Labels_Sc = [datestr(timeStamps, 'yyyy-mm-dd HH:MM') repmat(', ',length(timeStamps),1) num2str(repmat(Labels_Sc_Final1, 1))];
    Labels_Sc = cellstr(Labels_Sc);

    
end
