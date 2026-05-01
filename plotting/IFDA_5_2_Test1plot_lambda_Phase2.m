%% plot_lambda_phase2_auto.m
% Phase 2 lambda figure with:
% 1) lambda_i trajectories from 0 to 500 s
% 2) Unit 1 outage marker at t = 300 s
% 3) Phase 2 theoretical optimal lambda* reference line + value
% 4) automatically computed re-convergence time after outage

clearvars -except lambda_scope
close all; clc;

%% 1. Read data
t = lambda_scope.time;
lambda = squeeze(lambda_scope.signals.values);   % likely 6 x N

% Convert to N x 6 if needed
if size(lambda,1) == 6
    lambda = lambda.';
end

% Force time to column vector
t = t(:);

%% 2. Keep 0-500 s for Phase 1 + Phase 2 display
idx = (t >= 0) & (t <= 500);
t2 = t(idx);
lambda2 = lambda(idx,:);

%% 3. Define outage instant
t_out = 300;

%% 4. Effective treatment after Unit 1 outage
% Unit 1 is disconnected in Phase 2.
% For lambda plot, it is better to hide lambda_1 after outage.
lambda2(t2 >= t_out, 1) = NaN;

%% 5. Theoretical optimal incremental cost (Phase 2)
% Phase 2: active generators 2-6
% lambda* = 14.527
lambda_star_phase2 = 14.527;

%% 6. Automatically compute re-convergence time after outage
% Settling criterion:
% after t = 300 s, all ONLINE lambda_i remain within tol_lambda afterwards
tol_lambda = 0.1;     % adjust if needed
online_units = 2:6;    % Unit 1 is offline in Phase 2

idx_phase2 = t2 >= t_out;
t_post = t2(idx_phase2);
lambda_post = lambda2(idx_phase2,:);

lambda_error_post = abs(lambda_post(:,online_units) - lambda_star_phase2);

Ts_idx = NaN;
for k = 1:length(t_post)
    if all(lambda_error_post(k:end,:) <= tol_lambda, 'all')
        Ts_idx = k;
        break;
    end
end

if ~isnan(Ts_idx)
    Ts_abs = t_post(Ts_idx);   % absolute time instant
    Ts_rec = Ts_abs - t_out;   % re-convergence time after outage
else
    Ts_abs = NaN;
    Ts_rec = NaN;
end

%% 7. Plot
figure('Color','w','Position',[100 100 1100 650]);

plot(t2, lambda2, 'LineWidth', 1.5);
hold on;

x_min = 0;
x_max = 500;

% Unit 1 outage marker
xline(t_out, '--k', 'Unit 1 outage', ...
    'LineWidth', 1.2, ...
    'LabelOrientation', 'horizontal', ...
    'LabelVerticalAlignment', 'bottom', ...
    'LabelHorizontalAlignment', 'center');

% Plot theoretical optimal lambda* line
yline(lambda_star_phase2, '--', 'LineWidth', 1.0, 'HandleVisibility','off');

%% 8. Add numerical label for theoretical optimal value
label_x = 470;   % near right-hand side of the plot

text(label_x, lambda_star_phase2, ...
    sprintf('\\lambda^*=%.3f', lambda_star_phase2), ...
    'FontSize', 10, ...
    'FontName', 'Times New Roman', ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'bottom', ...
    'BackgroundColor', 'w', ...
    'Margin', 1);

% Optional label for Unit 1 being offline
yl = ylim;
text(label_x, yl(1) + 0.08*(yl(2)-yl(1)), ...
    '\lambda_1 hidden after outage', ...
    'FontSize', 10, ...
    'FontName', 'Times New Roman', ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'bottom', ...
    'BackgroundColor', 'w', ...
    'Margin', 1);

%% 9. Re-convergence time line
if ~isnan(Ts_abs)
    xline(Ts_abs, '--k', ...
        sprintf('Re-convergence time = %.2f s', Ts_rec), ...
        'LineWidth', 1.2, ...
        'LabelOrientation', 'horizontal', ...
        'LabelVerticalAlignment', 'top', ...
        'LabelHorizontalAlignment', 'center');
end

%% 10. Axes / labels / legend
xlabel('Time / s');
ylabel('Incremental cost \lambda_i');
title('Incremental Cost Dynamics During Unit Outage');

legend({'\lambda_1','\lambda_2','\lambda_3','\lambda_4','\lambda_5','\lambda_6'}, ...
       'Location','eastoutside');

grid on;
xlim([x_min x_max]);

set(gca, 'FontName','Times New Roman', 'FontSize',11);

%% 11. Export figure
exportgraphics(gcf, 'Figure_4_5_lambda_Phase2_auto.png', 'Resolution', 300);

%% 12. Display useful results in Command Window
disp('Final simulated lambda at 500 s:');
disp(lambda2(end,:));

disp('Theoretical optimal lambda* after Unit 1 outage, Phase 2:');
disp(lambda_star_phase2);

disp('Absolute error at 500 s, online units only:');
disp(abs(lambda2(end,online_units) - lambda_star_phase2));

if ~isnan(Ts_abs)
    fprintf('Automatically computed re-convergence time after outage (tol = %.3f): %.4f s\n', tol_lambda, Ts_rec);
    fprintf('Absolute settling instant: %.4f s\n', Ts_abs);
else
    fprintf('No re-convergence time found before 500 s under tol = %.3f.\n', tol_lambda);
end