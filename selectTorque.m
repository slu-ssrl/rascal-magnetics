%% *********************************************************************** 
%  Select Torque
%  Space Systems Research Laboaratory
%  --------------------------------
%  Nicholas Mercadante
%
%  Project: Rascal-1
%
%
% Name          | Date      | Description
% ------------------------------------------------------------------------
% N.Mercadante   03-29-2017  TEMP
% ------------------------------------------------------------------------
%
% COPYRIGHT 2017 Space Systems Research Laboratory, all rights reserved.
%
% ************************************************************************

function torque_output = selectTorque(parameters)
    
    q       = parameters.q;      
    H       = parameters.H;       
    T       = parameters.T;   % Torque Magnitude
    I       = parameters.I;
    q_des   = parameters.q_des;
    dt      = parameters.dt;
    
    % All possible torque combinations. -----------------------------------
    torque_options = [0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1;...
                      0,0,0,1,1,1,-1,-1,-1,0,0,0,1,1,1,-1,-1,-1,0,0,0,1,1,1,-1,-1,-1;...
                      0,1,-1,0,1,-1,0,1,-1,0,1,-1,0,1,-1,0,1,-1,0,1,-1,0,1,-1,0,1,-1];
    % ---------------------------------------------------------------------
    
%    *** GAINS ***                        
     kA = 0.9995;
     kR = 1-kA;
%    *************
     
     error_attitude = 100;
     error_rate     = 100;
     counter = 1;
     
    % parfor -- a lot of overhead...
    for i = 1:27
       % Calculate new quaternion from torque choice
       torque = torque_options(:, i).*T;
       H_new = H + torque.*dt;
       w = I\H_new;
       
       S = quatSkew(w);
       q_dot = 0.5 .* S * q;            % I am assuming that q_dot_des = 0
       
       q_new = normalize( q + q_dot.*dt );
       
       % Calculate error and store in array
       q_error = q_new - q_des;
       
       error_temp_at = norm(q_error);
       error_temp_rt = norm(q_dot);
      
       
       if (kA*error_temp_at + kR*error_temp_rt) < ...
               (kA*error_attitude + kR*error_rate)
           
           error_attitude = error_temp_at;
           error_rate = error_temp_rt;
           counter = i;
       end
        
    end
    
    torque_decision = torque_options(:, counter);
    torque_output = torque_decision.*T;

end