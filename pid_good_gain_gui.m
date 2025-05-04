function pid_good_gain_gui
    % Create the Main Figure
    fig = figure('NumberTitle', 'off', ...
                 'Color', [0.95 0.95 0.95], ...
                 'Position', [300 100 800 600]);

    % Define Plant
    s = tf('s');
    G = 1 / (s^2 + 10*s + 20); % Example Plant

    % Axes for Plot
    ax = axes('Parent', fig, 'Position', [0.08 0.45 0.88 0.5]);
    grid on;
    hold on;
    xlabel('Time (s)');
    ylabel('Amplitude');
    set(gca, 'FontSize', 12);
    
    % -------- Sliders and Labels --------

    % Kp Slider and Label
    uicontrol('Style', 'text', 'Position', [100 200 60 20], ...
              'String', 'Kp:', 'FontSize', 12, ...
              'BackgroundColor', [0.95 0.95 0.95]);
    kp_slider = uicontrol('Style', 'slider', ...
        'Min', 0, 'Max', 1000, 'Value', 5, ...
        'Position', [160 200 500 20], ...
        'SliderStep', [0.001 0.05], ...
        'Callback', @update_plot);

    % Kp Value Display
    kp_value_display = uicontrol('Style', 'text', ...
                                  'Position', [680 200 100 20], ...
                                  'String', num2str(kp_slider.Value, 'Kp: %.2f'), ...
                                  'FontSize', 12, ...
                                  'BackgroundColor', [0.95 0.95 0.95]);

    % Ki Slider and Label
    uicontrol('Style', 'text', 'Position', [100 160 60 20], ...
              'String', 'Ki:', 'FontSize', 12, ...
              'BackgroundColor', [0.95 0.95 0.95]);
    ki_slider = uicontrol('Style', 'slider', ...
        'Min', 0, 'Max', 500, 'Value', 0, ...
        'Position', [160 160 500 20], ...
        'SliderStep', [0.001 0.05], ...
        'Callback', @update_plot);

    % Ki Value Display
    ki_value_display = uicontrol('Style', 'text', ...
                                  'Position', [680 160 100 20], ...
                                  'String', num2str(ki_slider.Value, 'Ki: %.2f'), ...
                                  'FontSize', 12, ...
                                  'BackgroundColor', [0.95 0.95 0.95]);

    % Kd Slider and Label
    uicontrol('Style', 'text', 'Position', [100 120 60 20], ...
              'String', 'Kd:', 'FontSize', 12, ...
              'BackgroundColor', [0.95 0.95 0.95]);
    kd_slider = uicontrol('Style', 'slider', ...
        'Min', 0, 'Max', 500, 'Value', 0, ...
        'Position', [160 120 500 20], ...
        'SliderStep', [0.001 0.05], ...
        'Callback', @update_plot);

    % Kd Value Display
    kd_value_display = uicontrol('Style', 'text', ...
                                  'Position', [680 120 100 20], ...
                                  'String', num2str(kd_slider.Value, 'Kd: %.2f'), ...
                                  'FontSize', 12, ...
                                  'BackgroundColor', [0.95 0.95 0.95]);

    % Reset Button
    uicontrol('Style', 'pushbutton', 'String', 'Reset Values', ...
              'FontSize', 12, ...
              'Position', [350 50 100 40], ...
              'Callback', @reset_values);

    % Initial Plot
    update_plot();

    function update_plot(~, ~)
        % Get current Kp, Ki, Kd values
        Kp = kp_slider.Value;
        Ki = ki_slider.Value;
        Kd = kd_slider.Value;

        % Update value displays
        kp_value_display.String = sprintf('Kp: %.2f', Kp);
        ki_value_display.String = sprintf('Ki: %.2f', Ki);
        kd_value_display.String = sprintf('Kd: %.2f', Kd);

        % PID Controller
        C = pid(Kp, Ki, Kd);

        % Closed Loop System
        T = feedback(C*G, 1);

        % Time vector
        t = 0:0.01:5;

        % Step response
        [y, t_out] = step(T, t);

        % Step input
        u = ones(size(t_out));
        
        % Clear axes and plot
        cla(ax);
        plot(ax, t_out, y, 'b-', 'LineWidth', 2); hold on;
        plot(ax, t_out, u, 'r--', 'LineWidth', 2);
        legend(ax, {'System Output', 'Step Input'}, 'Location', 'best');
        grid(ax, 'on');
    end

    function reset_values(~, ~)
        % Reset to initial PID values
        kp_slider.Value = 5;
        ki_slider.Value = 0;
        kd_slider.Value = 0;
        update_plot();
    end
end
