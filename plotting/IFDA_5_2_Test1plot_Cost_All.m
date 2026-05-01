%% plot_totalcost_cost_optimality.m
% Total system generation cost figure with:
% 1) simulated total cost from totalcost_scope
% 2) theoretical minimum cost from KKT optimal Pg*
% 3) operating phase markers at t = 300 s and 500 s
% 4) automatic cost error calculation for each phase

clearvars -except totalcost_scope
close all; clc;

%% 1. Read total cost data from Simulink scope
t = totalcost_scope.time;
C = squeeze(totalcost_scope.signals.values);

% Force time and cost to column vectors
t = t(:);
C = C(:);

%% 2. Define phase switching instants
t_outage = 300;     % Unit 1 disconnection
t_rec = 500;        % Unit 1 reconnection
t_tr_end = 502;     % end of reference-tracking transition

%% 3. Cost coefficients and theoretical optimal Pg* values

% -------------------------
% Phase 1: normal operation
% active generators: 1-6
% -------------------------
a1 = [0.010, 0.025, 0.020, 0.009, 0.018, 0.034];
b1 = [10.5,  12.0,  15.0,  11.5,  13.0,  9.5];
c1 = [20,    25,    30,    22,    28,    18];

Pg_star_1 = [168.20, 37.28, 15.00, 131.34, 24.00, 64.18];

% -------------------------
% Phase 2: Unit 1 offline
% active generators: 2-6
% Unit 1 is excluded from cost calculation
% -------------------------
a2 = [0.025, 0.020, 0.009, 0.018, 0.034];
b2 = [12.0,  15.0,  11.5,  13.0,  9.5];
c2 = [25,    30,    22,    28,    18];

Pg_star_2 = [50.53, 15.00, 168.14, 42.40, 73.92];

% -------------------------
% Phase 3: after reconnection
% modified generator 1
% active generators: 1-6
% -------------------------
a3 = [0.010, 0.025, 0.020, 0.009, 0.018, 0.034];
b3 = [10.5,  12.0,  15.0,  11.5,  13.0,  9.5];
c3 = [20,    25,    30,    22,    28,    18];

Pg_star_3 = [60.00, 45.11, 15.00, 153.08, 34.87, 69.93];

%% 4. Calculate theoretical minimum costs
C_th_1 = sum(a1 .* Pg_star_1.^2 + b1 .* Pg_star_1 + c1);
C_th_2 = sum(a2 .* Pg_star_2.^2 + b2 .* Pg_star_2 + c2);
C_th_3 = sum(a3 .* Pg_star_3.^2 + b3 .* Pg_star_3 + c3);

C_th = [C_th_1, C_th_2, C_th_3];

%% 5. Choose display range
t_start = 0;
t_end = 650;

idx = (t >= t_start) & (t <= t_end);
t_plot = t(idx);
C_plot = C(idx);

%% 6. Define steady-state windows for simulated cost comparison
% You can adjust these windows according to your actual settling behaviour.
phase1_window = [290, 300];
phase2_window = [490, 500];
phase3_window = [540, 550];

idx_p1_ss = (t >= phase1_window(1)) & (t <= phase1_window(2));
idx_p2_ss = (t >= phase2_window(1)) & (t <= phase2_window(2));
idx_p3_ss = (t >= phase3_window(1)) & (t <= phase3_window(2));

C_sim_ss_1 = mean(C(idx_p1_ss));
C_sim_ss_2 = mean(C(idx_p2_ss));
C_sim_ss_3 = mean(C(idx_p3_ss));

C_sim_ss = [C_sim_ss_1, C_sim_ss_2, C_sim_ss_3];

abs_error = abs(C_sim_ss - C_th);
rel_error = abs_error ./ C_th * 100;

%% 7. Plot
figure('Color','w','Position',[100 100 1150 620]);
hold on;

%% 8. Set y-limit
y_data_min = min(C_plot);
y_data_max = max(C_plot);

y_ref_min = min(C_th);
y_ref_max = max(C_th);

y_min = min(y_data_min, y_ref_min) - 0.08 * abs(y_ref_max - y_ref_min);
y_max = max(y_data_max, y_ref_max) + 0.12 * abs(y_ref_max - y_ref_min);

ylim([y_min y_max]);

%% 10. Plot simulated total cost
h_sim = plot(t_plot, C_plot, ...
    'LineWidth', 1.6, ...
    'DisplayName', 'Simulated total cost');

%% 11. Plot theoretical minimum cost levels by phase
h_th = plot([t_start t_outage], [C_th_1 C_th_1], ...
    '--', 'LineWidth', 1.4, ...
    'DisplayName', 'Theoretical minimum cost');

plot([t_outage t_rec], [C_th_2 C_th_2], ...
    '--', 'LineWidth', 1.4, ...
    'Color', h_th.Color, ...
    'HandleVisibility','off');

plot([t_tr_end t_end], [C_th_3 C_th_3], ...
    '--', 'LineWidth', 1.4, ...
    'Color', h_th.Color, ...
    'HandleVisibility','off');

%% 12. Add phase switching markers
xline(t_outage, '--k', 'Unit 1 outage', ...
    'LineWidth', 1.1, ...
    'LabelOrientation', 'horizontal', ...
    'LabelVerticalAlignment', 'bottom', ...
    'LabelHorizontalAlignment', 'center', ...
    'HandleVisibility','off');

xline(t_rec, '--k', 'Unit 1 reconnection', ...
    'LineWidth', 1.1, ...
    'LabelOrientation', 'horizontal', ...
    'LabelVerticalAlignment', 'bottom', ...
    'LabelHorizontalAlignment', 'center', ...
    'HandleVisibility','off');

%% 13. Add theoretical cost labels
% Move labels slightly to the right and a little above the dashed lines

text(210, C_th_1 + 180, sprintf('C^*_{th,1}=%.2f', C_th_1), ...
    'FontSize', 10, ...
    'FontName', 'Times New Roman', ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'bottom', ...
    'BackgroundColor', 'w', ...
    'Margin', 1);

text(400, C_th_2 + 180, sprintf('C^*_{th,2}=%.2f', C_th_2), ...
    'FontSize', 10, ...
    'FontName', 'Times New Roman', ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'bottom', ...
    'BackgroundColor', 'w', ...
    'Margin', 1);

text(550, C_th_3 + 180, sprintf('C^*_{th,3}=%.2f', C_th_3), ...
    'FontSize', 10, ...
    'FontName', 'Times New Roman', ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'bottom', ...
    'BackgroundColor', 'w', ...
    'Margin', 1);

%% 15. Axes / labels / legend
xlabel('Time / s');
ylabel('Total generation cost');
title('Total System Generation Cost Over Time');

legend([h_sim, h_th], ...
    {'Simulated total cost', 'Theoretical minimum cost'}, ...
    'Location','northeast');

grid on;
box on;
xlim([t_start t_end]);
ylim([y_min y_max]);

set(gca, 'FontName','Times New Roman', 'FontSize',11);

%% 16. Export figure
exportgraphics(gcf, 'Figure_4_9_Total_System_Generation_Cost.png', 'Resolution', 300);

%% 17. Display theoretical cost and error comparison
Phase = {'Phase 1'; 'Phase 2'; 'Phase 3'};
Theoretical_Minimum_Cost = C_th(:);
Simulated_Steady_State_Cost = C_sim_ss(:);
Absolute_Error = abs_error(:);
Relative_Error_percent = rel_error(:);

Cost_Comparison_Table = table(Phase, ...
                              Theoretical_Minimum_Cost, ...
                              Simulated_Steady_State_Cost, ...
                              Absolute_Error, ...
                              Relative_Error_percent);

disp('Theoretical minimum costs:');
fprintf('Phase 1 theoretical minimum cost = %.4f\n', C_th_1);
fprintf('Phase 2 theoretical minimum cost = %.4f\n', C_th_2);
fprintf('Phase 3 theoretical minimum cost = %.4f\n', C_th_3);

disp(' ');
disp('Cost comparison table:');
disp(Cost_Comparison_Table);

%% 18. Export table as CSV
writetable(Cost_Comparison_Table, 'Cost_Comparison_Table.csv');