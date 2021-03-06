%   FILL IN / MODIFY THE CODE WITH "" or comments with !!
close all;
clear all;

% Load patient_data.mat 
load('patient_data.mat');
labels = {'Heart Rate','Pulse Rate','Respiration Rate'};

% open the result file
% !! replace # with your own groupID
fid = fopen('ECE313_Mini2_group5', 'w');

%% T0
% !! Subset your data for each signal
% Z = "Heart Rate"
heartRate = data(1,1:30000);
% Y = "Pulse Rate"
pulseRate = data(2, 1:30000);
% X = "Respiration"
respRate = data(3, 1:30000);

% Part a
% !! Plot each signal over time
figure;
subplot(3,1,1);
plot(heartRate);
title(labels(1));
subplot(3,1,2);
plot(pulseRate);
title(labels(2));
subplot(3,1,3);
plot(respRate);
title(labels(3));
xlabel('Time(seconds)')


% Note that Tasks 1.1 and 1.2 should be done only for the respiration rate signal 
% Tasks 2.1 and 2.2 should be performed using all three signals.
%% T1.1
% Part a
% Generating three sample sets of different sizes
sz = [70,1000,30000];
for k = 1:3
    % Pick a random sample of size sz(k) from the data set  
    % (Without replacement)
    Sample = datasample(respRate,sz(k),'Replace',false);

    % Plot the CDF of the whole data set as the reference (in red color)
    figure;  
    subplot(2,1,1);
    [p, xi] = ecdf(respRate);
    plot(xi,p);
    hold on;% For the next plots to be on the same figure        
    h = get(gca,'children'); set(h,'LineWidth',2);set(h,'Color','r')
    
    % !! Call the funcion for calculating and ploting pdf and CDF of X
    pdf_cdf(Sample)
    
    title(strcat(strcat(char(labels(3)),' - Sample Size = '),char(num2str(sz(k)))));
end

% Part b
% !! Use the tabulate function in MATLAB over X and floor(X). 

% Declaring variables, finding pdf and pmf
tabulate_X = tabulate(respRate);
tabulate_floor_X = tabulate(floor(respRate));
min_tabulate_X = min(tabulate_X(1:30000, 3));
max_tabulate_X = max(tabulate_X(1:30000, 3));
min_tabulate_floor_X = min(tabulate_floor_X(1:76, 3));
max_tabulate_floor_X = max(tabulate_floor_X(1:76, 3));

% !! Answer the question by filling in the following printf
fprintf(fid, 'Task 1.1 - Part b\n');
fprintf(fid, 'Min of tabulate(X) = %f\n', min_tabulate_X);
fprintf(fid, 'Max of tabulate(X) = %f\n', max_tabulate_X);
fprintf(fid, 'Min of tabulate(floor(X)) = %f\n', min_tabulate_floor_X);
fprintf(fid, 'Max of tabulate(floor(X)) = %f\n', max_tabulate_floor_X);
fprintf(fid, 'Observed Property of PDF = %s\n\n', 'F(X) is a non-decreasing and Gaussian distribution.');

% Part c
% !! Using CDF of X, find values a and b such that P(X <= a) <= 0.02 and P(X <= b) >= 0.98.
respRate_sorted = sort(respRate);
i = 1;
while p(i) <= 0.02
    a = xi(i);
    i = i + 1;
end

l = 30001;
while p(l) >= 0.98
    b = xi(l);
    l = l - 1;
end


fprintf(fid, 'Task 1.1 - Part c\n');
fprintf(fid, 'Empirical a = %f\n', a);
fprintf(fid, 'Empirical b = %f\n\n', b);

%% Task 1.2;

% Part a
% !! Calculate mean of the signal

fprintf(fid, 'Task 1.2 - Part a\n');
mean_RESP = mean(respRate);
fprintf(fid, 'Mean RESP = %f\n\n', mean_RESP);
% !! Calculate standard deviation of the signal

fprintf(fid, 'Standard Deviation RESP = %f\n', std(respRate));

% Part b
% !! Generate a normal random variable with the same mean & standard deviation 
std_resp = std(respRate);
acounter = 0;
bcounter = 30000;
for k = 1:30000
    % Pick a random sample of size sz(k) from the data set  
    % (Without replacement)
    respRate_normal(k) = normrnd(mean_RESP, std_resp);
    respRate_normalized(k) = (respRate_normal(k)-mean_RESP)/std_resp;
    if respRate_normalized(k) <= -2.05
        acounter = acounter + 1;
    end
    if respRate_normalized(k) >= 2.05
        bcounter = bcounter - 1;
    end

end

% !! Plot pdf and CDF of the generated random variable using pdf_cdf function
figure;
% !! Call the funcion for calculating and ploting pdf and CDF of X
pdf_cdf(respRate_normalized)
title(strcat(char(labels(3)),' Normal Approximation'));


% Part c
figure;
title(strcat(char(labels(3)),' Normplot'));
% !! Use normplot function to estimate the difference between distributions
normplot(respRate_normal);


% Part d
% !! Show your work in the report, then plug in the numbers that you calculated here
fprintf(fid, 'Task 1.2 - Part d\n');
fprintf(fid, 'Theoretical a = %f\n', respRate_sorted(acounter));
fprintf(fid, 'Theoretical b = %f\n\n', respRate_sorted(bcounter));

%% Task 2.1;
% Tasks 2.1 and 2.2 should be done twice, 
% once with the empirical threshold, and once with the theoretical threshold
% !! Change the code to do this.

% Part a
% !! Call the threshold function and generate alarms for each signal
for k = 1:30000
   
% Calculate for empirical threshold
HR_empirical_threshold(k) = threshold_func(heartRate(k), 80.17, 98.52);
PR_empirical_threshold(k) = threshold_func(pulseRate(k), 79.00, 97.07);
RESP_empirical_threshold(k) = threshold_func(respRate(k), a, b);

%calculate for theoretical threshold
HR_theoretical_threshold(k) = threshold_func(heartRate(k), 78.84, 96.86);
PR_theoretical_threshold(k) = threshold_func(pulseRate(k), 78.15, 96.09);
RESP_theoretical_threshold(k) = threshold_func(respRate(k), respRate_sorted(acounter), respRate_sorted(bcounter));

end


% Parts b and c
% !! Write the code for coalescing alarms and majority voting here 

for i = 1:3000
    flag_HR_empirical = 0;
    flag_HR_theoretical = 0;
    flag_PR_empirical = 0;
    flag_PR_theoretical = 0;
    flag_RESP_empirical = 0;
    flag_RESP_theoretical = 0;
    k = (i-1)*10;
    for j = 1:10
        if HR_empirical_threshold(k+j) == 1;
            flag_HR_empirical = 1;
        end
        if HR_theoretical_threshold(k+j) == 1;
            flag_HR_theoretical = 1;
        end
        if PR_empirical_threshold(k+j) == 1;
            flag_PR_empirical = 1;
        end
        if PR_theoretical_threshold(k+j) == 1;
            flag_PR_theoretical = 1;
        end
        if RESP_empirical_threshold(k+j) == 1;
            flag_RESP_empirical = 1;
        end
        if RESP_empirical_threshold(k+j) == 1;
            flag_RESP_theoretical = 1;
        end
    end
    HR_empirical_threshold_10(i) = flag_HR_empirical;
    HR_theoretical_threshold_10(i) = flag_HR_theoretical;
    PR_empirical_threshold_10(i) = flag_PR_empirical;
    PR_theoretical_threshold_10(i) = flag_PR_theoretical;
    RESP_empirical_threshold_10(i) = flag_RESP_empirical;
    RESP_theoretical_threshold_10(i) = flag_RESP_theoretical;
end


for k = 1:3000

    if(HR_empirical_threshold_10(k) + PR_empirical_threshold_10(k) + RESP_empirical_threshold_10(k) >= 2)
        empirical_alarm(k) = 1;
    else
        empirical_alarm(k) = 0;
    end


    if(HR_theoretical_threshold_10(k) + PR_theoretical_threshold_10(k) + RESP_theoretical_threshold_10(k) >= 2)
        theoretical_alarm(k) = 1;
    else
        theoretical_alarm(k) = 0;
    end

end


% Part d
% !! Fill in the bar functions with the name of vectors storing your alarms

% empirical thresholds
figure;
subplot(5,1,1);
bar(HR_empirical_threshold_10);
title(strcat(char(labels(1)),' Alarms'));
subplot(5,1,2);
bar(PR_empirical_threshold_10);
title(strcat(char(labels(2)),' Alarms'));
subplot(5,1,3);
bar(RESP_empirical_threshold_10);
title(strcat(char(labels(3)),' Alarms'));
subplot(5,1,4);
bar(empirical_alarm);
title('Majority Voter Alarms - Empirical Thresholds');
subplot(5,1,5);
title('Golden Alarms');
bar(golden_alarms,'r');

%% Task 2.2;
% Parts a and b
% !! Write the code to calculate the probabilities of:
%    false alarm, miss detection and error 

empirical_miss_detection = 0;
empirical_false_alarm = 0;
theoretical_miss_detection = 0;
theoretical_false_alarm = 0;

for k = 1:3000
    if(golden_alarms(k) && ~empirical_alarm(k))
        empirical_miss_detection = empirical_miss_detection + 1;
    end
    if(~golden_alarms(k) && empirical_alarm(k))
        empirical_false_alarm = empirical_false_alarm + 1;
    end
    
    if(golden_alarms(k) && ~theoretical_alarm(k))
        theoretical_miss_detection = theoretical_miss_detection + 1;
    end
    if(~golden_alarms(k) && theoretical_alarm(k))
        theoretical_false_alarm = theoretical_false_alarm + 1;
    end
   
end
  empirical_error = empirical_false_alarm + empirical_miss_detection;
  
fprintf(fid, 'Task 2.2 - Parts a and b\n');
fprintf(fid, 'Using Empirical Thresholds:\n');
fprintf(fid, 'Probability of False Alarm    = %f\n', empirical_false_alarm / sum(empirical_alarm));
fprintf(fid, 'Probability of Miss Detection = %f\n', empirical_miss_detection / sum(golden_alarms));
fprintf(fid, 'Probability of Error          = %f\n\n', empirical_error / (sum(empirical_alarm) + sum(golden_alarms)));

% Part c
% !! Repeat Tasks 2.1 and 2.2 with Theoretical thresholds

% theoretical thresholds
figure;
subplot(5,1,1);
bar(HR_theoretical_threshold_10);
title(strcat(char(labels(1)),' Alarms'));
subplot(5,1,2);
bar(PR_theoretical_threshold_10);
title(strcat(char(labels(2)),' Alarms'));
subplot(5,1,3);
bar(RESP_theoretical_threshold_10);
title(strcat(char(labels(3)),' Alarms'));
subplot(5,1,4);
bar(theoretical_alarm);
title('Majority Voter Alarms - Theoretical Thresholds');
subplot(5,1,5);
title('Golden Alarms');
bar(golden_alarms,'r');
theoretical_error = theoretical_false_alarm + theoretical_miss_detection;
fprintf(fid, 'Task 2.2 - Part c\n');
fprintf(fid, 'Using Theoretical Thresholds:\n');
fprintf(fid, 'Probability of False Alarm    = %f\n', theoretical_false_alarm / sum(theoretical_alarm));
fprintf(fid, 'Probability of Miss Detection = %f\n', theoretical_miss_detection / sum(golden_alarms));
fprintf(fid, 'Probability of Error          = %f\n\n', theoretical_error / (sum(empirical_alarm) + sum(golden_alarms)));

%% Task 3
% Part a
% !! Calculate the rate of alarms
alarm_rate = sum(golden_alarms)/3000;

fprintf(fid, 'Task 3 - Part a\n');
fprintf(fid, 'Rate of alarms in Golden alarms= %f\n', alarm_rate);

% Parts b
% !! Derive the time interval between to consecutive alarms, and generate alarms up to 3,000 windows
alarm_win_array = zeros(1, 3000);
k = 0;
expRand = 0;
while (k < 3000)
	% generate a exp. random number.
	k = k + exprnd(1/alarm_rate);
	% mark the sample window indicated by the time interval
    if (k < 3000)
        alarm_win_array(ceil(k)+1) = alarm_win_array(ceil(k)+1) + 1;
    end
end 

% !! Fill in the bar functions with the name of vectors storing your alarms
figure;
subplot(2, 1, 1);
bar(golden_alarms);
title('Golden Alarms');

subplot(2, 1, 2);
bar(alarm_win_array);
title('Exp. dist Alarms');


% Part c
% !! Write the code to calculate the probabilities of:
%    false alarm, miss detection and error 

% Note, please make sure to consider the tolerance interval when evaluating
% the performance of the Exp. distribution based detector.
false_pos_total = 0;
missed_detect_total = 0;
for n = 1:3000
    if alarm_win_array(n) == 1
        false_pos_flag = 1;
        for j = 1:101
            if (n+j-51) > 1 && (n+j-51) < 3000
                if golden_alarms(n + j-51) == 1
                    false_pos_flag = 0;
                end
            end
        end
        false_pos_total = false_pos_total + false_pos_flag;
    end
    if golden_alarms(n) == 1
        missed_detect = 1;
        for j = 1:101
            if (n+j-51) > 1 && (n+j-51) < 3000
                if alarm_win_array(n + j-51) == 1
                    missed_detect = 0;
                end
            end
        end
        missed_detect_total = missed_detect_total + missed_detect;
    end
end

error = false_pos_total + missed_detect_total;

fprintf(fid, 'Task 3 - Part c\n');
fprintf(fid, 'Probability of False Alarm    = %f\n', false_pos_total/sum(alarm_win_array));
fprintf(fid, 'Probability of Miss Detection = %f\n', missed_detect_total/sum(golden_alarms));
fprintf(fid, 'Probability of Error          = %f\n\n', error/(sum(golden_alarms)+ sum(alarm_win_array)));


fclose(fid);
