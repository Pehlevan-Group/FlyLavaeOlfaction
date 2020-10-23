function ynew = asyncBoolUpdate(y0,W,I0,Iorn,KOindex)
% update rule for the boolean network asynchronously
% y0      inintial sates, a vector
% W       the interaction matrix, Wij means the interaction of i-th neuon
%         j-th neuron
% I0      external input, a vector, only mPN has nonzero input
% Iorn    input from ORNs, a vector
% KOindex an integer or empty, indicates if the manipulation is knowckout

yold = y0;
flag = 1;   % indicates the convergence of boolean  dynamics
ynew = y0;  % store the updated neural states

% for knockout manipulatoins, set the state of that neuron to be 0
if ~isempty(KOindex)
   ynew(KOindex) = 0;
   I0(KOindex) = 0;
   Iorn(KOindex) = 0;
   W(:,KOindex) = zeros(1,5);
end

count = 0; % some times a limit cycle
cumCount = 0;  % track the update of neuron activity
while cumCount < 50 && count < 1e3
    count = count + 1;
    
    % each time select one neuron to update
    nInx = randperm(5,1);
    input = W'*ynew + I0 + Iorn;   % notice the transpose of W
    if ~isempty(KOindex)
        input(KOindex) = 0;   % knockout neuron has no input
    end
    
    % set the value of neurons based on the total inputs
    if input(nInx) >0
       ynew(nInx) = 1;
    else
       ynew(nInx) = 0;
    end
        
    if nInx == 3 || nInx ==5
        if input(nInx) >= 2
            ynew(nInx) = 2;
        end
    end

    
    % check if the state changes or not
    if all(ynew - yold ==0)
        cumCount = cumCount + 1;
    else
        cumCount = 0;  % start over 
    end
    yold = ynew;

end

% disp(count)
end