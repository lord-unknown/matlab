clear
clc
format compact
% notes
% if you want to type in the chance percent please work out the payout and
% then type in the payout (the chance percent is worked out but no code yet
% to allow for typing the percent in)

bank_start = 100;
starting_bet = 1; % starting bet % 0.00000001
current_bet = starting_bet;
house_advantage = 1; % percent 0 - 100
payout = 2; % payout for the return (2 for martingale)
number_rounds_start = 2000; % ignore until for loop
amount_games = 1000;
reset_bet_longchain = 10; % reset the bet if its to many steps up
loss_multiplier = payout;
win_multiplier = 1;
loss_increase = 0;
win_increase = 0;
stop_win_size = 200;
LossDistributions = [0;0;0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Screen printing options
printDistributionTable = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% do not modify below
bank=0;
range_high = 1000000;
longest_losing_streak = 0;
current_longest_losing_streak = 0;
largest_bank = 0;
rounds_played = 0;
round_longest_streak = 0;
round_longest_streak_bank = 0;
losing_streak_distribution = 0;
profitTrue = 0;
bankrollLeft = 0;
losing_streak_round = 0;

for x=1:amount_games
    if bank > largest_bank
        largest_bank = bank;
    end
    
    % reset variables
    bank = bank_start;
    number_rounds = number_rounds_start;
    current_longest_losing_streak = 0;
    longest_losing_streak = 0;
    current_bet = starting_bet;
    
    while number_rounds > 0
        if bank >= stop_win_size
            number_rounds = 0;
            break;
        end
        if current_longest_losing_streak > reset_bet_longchain
            current_bet = starting_bet;
        end
            
        if current_longest_losing_streak > longest_losing_streak
            losing_streak_round = number_rounds;
            round_longest_streak = rounds_played;
            %round_longest_streak_bank = bank;
            longest_losing_streak = current_longest_losing_streak;
        end
        
        % add counter to distribution matrix
        % If current losing streak is not in matrix
        [~,columns] = size(LossDistributions);
        if columns <  current_longest_losing_streak
            TMP = zeros(3,current_longest_losing_streak);
            TMP(1:3,1:columns) = LossDistributions;
            LossDistributions = TMP;
            for XX=1:current_longest_losing_streak
                LossDistributions(1,XX) = XX;
            end
        end

        if current_longest_losing_streak > 0
            LossDistributions(2,current_longest_losing_streak) = LossDistributions(2,current_longest_losing_streak) + 1;
        end

        % begin a round of betting
        if bank <= 0
            number_rounds = 0;
            %disp('dead')
            break;
        end
        rounds_played = rounds_played + 1;
        % remember the current round number
        current_round = number_rounds;

        % reduce number of rounds for next turn
        number_rounds = number_rounds - 1;

        % generate random number
        random_number = randi(range_high,1,1);

        % create chance number
        % turn percent into a number
        if house_advantage == 0
            chance_number = range_high / payout;
        else
            chance_number = (range_high - (house_advantage * (range_high / 100))) / payout;
        end

        % calculate win or loss (roll low for a win)
        if random_number <= chance_number
            % win!
            % set current bet to starting bet and add winning to bank
            bank = bank + (current_bet * payout) - current_bet;
            current_bet = starting_bet;
            
            
            
            current_longest_losing_streak = 0;
        else
            % lose!
            % double the current bet and minus the loss from bank
            bank = bank - current_bet;
            current_longest_losing_streak = current_longest_losing_streak + 1;

            current_bet = current_bet * loss_multiplier + loss_increase;
            
            
            
        end
        %fprintf('Bank: %0.5f  random number: %0.i\n',bank,random_number)
        %fprintf('Bank: %0i current bet: %0i\n',bank,current_bet)

    end
    if bank > 0
        bankrollLeft = bankrollLeft + bank;
    end
    if bank >= bank_start
        profitTrue = profitTrue + 1;
    end
    if bank < 0
        bank = 0;
    end
    
    fprintf('Game: %4i, End bank: %15.8f, Losing streak: %3.i, ',x,bank,longest_losing_streak)
    fprintf('Losing streak round number: %5i\n',losing_streak_round);
end

[rows, columns] = size(LossDistributions);
sumAmount = sum(LossDistributions,2);
sumAmount = sumAmount(2,1);


if printDistributionTable == true
    % print distrubtions table
    fprintf('\n')
    fprintf('       Loss streak       Amount          Percent \n')
    for y=1:columns
        LossDistributions(3,y) = LossDistributions(2,y) / sumAmount * 100;
        fprintf('%15.2f %15.2f %15.5f%% \n',LossDistributions(1,y),LossDistributions(2,y),LossDistributions(3,y))
    end
end

fprintf('\nChance: %0.5f%%',chance_number/10000)
fprintf('\nRounds played: %0i',rounds_played)
fprintf('\nProfit Chance: %0.2f%%',  profitTrue / amount_games * 100)
fprintf('\nBankroll percent left: %0.2f%%\n',  bankrollLeft / amount_games / bank_start * 100)

