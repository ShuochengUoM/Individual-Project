%% plot_lambda_phase1_auto.m
% Phase 1 lambda figure with:
% 1) theoretical lambda* reference line + value
% 2) automatically computed settling time
%
% Required workspace variable:
% lambda_scope

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

%% 2. Keep Phase 1 only
idx = t < 300;
t1 = t(idx);
lambda1 = lambda(idx,:);

%% 3. Theoretical optimal multiplier for Phase 1
lambda_star = 13.864;

%% 4. Automatically compute settling time
% Settling criterion:
% all lambda_i remain within tol_lambda of lambda_star afterwards

tol_lambda = 0.1;    % You may adjust this, e.g. 0.1 or 0.05

lambda_error = abs(lambda1 - lambda_star);

Ts_idx = NaN;
for k = 1:length(t1)
    if all(lambda_error(k:end,:) <= tol_lambda, 'all')
        Ts_idx = k;
        break;
    end
end

if ~isnan(Ts_idx)
    Ts = t1(Ts_idx);
else
    Ts = NaN;
end

%% 5. Plot
figure('Color','w','Position',[100 100 1100 650]);

plot(t1, lambda1, 'LineWidth', 1.5);
hold on;

% Theoretical lambda* reference line
yline(lambda_star, '--k', ...
    sprintf('\\lambda^* = %.3f', lambda_star), ...
    'LineWidth', 1.3, ...
    'LabelHorizontalAlignment','left', ...
    'LabelVerticalAlignment','bottom');



% Settling time line
if ~isnan(Ts)
    xline(Ts, '--k', ...
        sprintf('Settling time = %.2f s', Ts), ...
        'LineWidth', 1.2, ...
        'LabelOrientation','horizontal', ...
        'LabelVerticalAlignment','bottom', ...
        'LabelHorizontalAlignment','center');
end

%% 6. Axes / labels / legend
xlabel('Time / s');
ylabel('Local multiplier \lambda_i');
title('Incremental Cost Convergence, Phase 1');

legend({'\lambda_1','\lambda_2','\lambda_3','\lambda_4','\lambda_5','\lambda_6'}, ...
       'Location','eastoutside');

grid on;
xlim([0 300]);

set(gca, 'FontName','Times New Roman', 'FontSize',11);

%% 7. Export figure
exportgraphics(gcf, 'Figure_4_2_Lambda_Phase1_auto.png', 'Resolution', 300);

%% 8. Display useful results in Command Window
disp('Final simulated lambda before 300 s:');
disp(lambda1(end,:));

disp('Theoretical lambda*:');
disp(lambda_star);

disp('Absolute lambda errors at the end of Phase 1:');
disp(abs(lambda1(end,:) - lambda_star));

if ~isnan(Ts)
    fprintf('Automatically computed lambda settling time (tol = %.3f): %.4f s\n', tol_lambda, Ts);
else
    fprintf('No lambda settling time found before 300 s under tol = %.3f.\n', tol_lambda);
end