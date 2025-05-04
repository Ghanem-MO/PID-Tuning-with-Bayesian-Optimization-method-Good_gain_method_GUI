%% Define the plant model (symbolic - also used in Simulink)
s = tf('s');
plant = 1 / (s^2 + 3*s + 2);  % Second-order transfer function of the plant

%% Bayesian Optimization Setup

% Define the objective function to minimize: ITAE calculated from Simulink
objective = @(x) pid_objective_simulink(x.Kp, x.Ki, x.Kd);

% Define the PID gain variables with their bounds
vars = [
    optimizableVariable('Kp',[0.1, 10]);   % Proportional gain range
    optimizableVariable('Ki',[0.1, 10]);   % Integral gain range
    optimizableVariable('Kd',[0.01, 5]);   % Derivative gain range
];

% Run Bayesian optimization to minimize the ITAE cost function
results = bayesopt(objective, vars, ...
    'MaxObjectiveEvaluations', 20, ...             % Number of iterations
    'IsObjectiveDeterministic', true, ...          % Same output each run
    'AcquisitionFunctionName', 'expected-improvement-plus', ...  % BO strategy
    'Verbose', 0);                                 % Suppress detailed output

% Extract the best PID gains found
bestParams = results.XAtMinObjective;
Kp = bestParams.Kp;
Ki = bestParams.Ki;
Kd = bestParams.Kd;

% Display the optimized PID parameters
fprintf("Best PID gains:\nKp = %.3f\nKi = %.3f\nKd = %.3f\n", Kp, Ki, Kd);

%% Run Simulink model with best PID gains
simOut = sim('pid_sim_model');  % Simulate model with Kp, Ki, Kd from base workspace

% Extract output data from simulation
y = simOut.yout{1}.Values.Data;   % System response
t = simOut.yout{1}.Values.Time;   % Time vector
u = ones(size(t));                % Step input signal 

%% Plot Step Input and System Response
figure;
plot(t, u, 'r--', 'LineWidth', 1.5); hold on;   % Plot step input in red dashed line
plot(t, y, 'b', 'LineWidth', 2);                % Plot system response in blue
title('PID Response By Bayesian-Optimization');
xlabel('Time (seconds)');
ylabel('Amplitude');
legend('Step Input', 'System Output');
grid on;

%% Objective Function Used by Bayesian Optimization
function cost = pid_objective_simulink(Kp, Ki, Kd)
    % Assign PID gains to base workspace for use in Simulink
    assignin('base', 'Kp', Kp);
    assignin('base', 'Ki', Ki);
    assignin('base', 'Kd', Kd);

    try
        % Run the Simulink model and return outputs to workspace
        simOut = sim('pid_sim_model', 'ReturnWorkspaceOutputs', 'on');

        % Extract system output and time
        y = simOut.yout{1}.Values.Data;
        t = simOut.yout{1}.Values.Time;

        % Unstable detection threshold
        if any(isnan(y)) || any(isinf(y)) || max(abs(y)) > 1e3
            cost = 1e6;  % Assign a large penalty cost
            return;
        end

        % Compute the error (for unit step input)
        error = 1 - y;

        % Calculate ITAE: Integral of Time-weighted Absolute Error
        cost = trapz(t, t .* abs(error));
        
    catch
        % If simulation fails (e.g., divergence or runtime error), assign high cost
        cost = 1e6;
    end
end
