function ynew = boolUpdate(y0,W,I0,Iorn,KOindex)
% update rule for the boolean network
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
while (flag) && count < 100
    count = count + 1;
    input = W'*ynew + I0 + Iorn;   % notice the transpose of W
    if ~isempty(KOindex)
        input(KOindex) = 0;   % knockout neuron has no input
    end
    
    % set the value of neurons based on the total inputs
    posiInx = input >0;   
    ynew = input;         
    ynew(posiInx) = 1;
    ynew(~posiInx) = 0;
    
    % uPN and mPN has three differet sates
    if input(3) >= 2
        ynew(3) = 2;
    end
    
    if input(5) >= 2
        ynew(5) = 2;
    end
    
    % check if the state changes or not
    if all(ynew - yold ==0)
        flag = 0;
    else
        yold = ynew;
    end
end

%disp(count)
end