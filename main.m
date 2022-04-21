% Mini-drone 경진대회 1차 팀과제.

krw_money = input("원화를 입력하세요 : ");

dollar = countDollar(krw_money);
euro = countEuro(krw_money);
yuan = countYuan(krw_money);
yen = countYen(krw_money);

fprintf("최소 달러 지폐 개수는 %d 개\n",dollar);
fprintf("최소 유로 지폐 개수는 %d 개\n",euro);
fprintf("최소 위안 지폐 개수는 %d 개\n",yuan);
fprintf('최소 엔 지폐 개수는 %d 개\n',yen);

% 한국 원화 1000원 기준 0.81달러
function bill = countDollar(krw_money)
    count = 0;                                              % 갯수
    dollar_list = [100 50 20 10 5 2 1];                     % 미국 지폐 단위 100달러 50달러 20달러 10달러 5달러 2달러 1달러
    money = krw_money / 1000 * 0.81;                        % 환전
    mod1 = money;
    for i = 1:7
        if mod1 > dollar_list(i)
            count = count + floor(mod1 / dollar_list(i));   % 지폐 개수 구하기
            mod1 = mod(mod1, dollar_list(i));               % 나머지값
        else
            continue
        end
    end
    bill = count;  %지폐 총합
end

% 한국 원화 1000원 기준 0.75유로
function bill = countEuro(krw_money)
    count = 0;                                          % 갯수
    euro_list = [500 200 100 50 20 10 5];               % 유럽 지폐 단위 500유로 200유로 100유로 50유로 20유로 10유로 5유로
    money = krw_money / 1000 * 0.75;                    % 환전
    mod1 = money;
    for i = 1:7
        if mod1 > euro_list(i)
            count = count + floor(mod1 / euro_list(i)); % 지폐 개수 구하기
            mod1 = mod(mod1, euro_list(i));             % 나머지값
        else
            continue
        end
    end
    bill = count;  
end

% 한국 원화 1000원 기준 5.18위안
function bill = countYuan(krw_money)
    cny = (krw_money/1000)*5.18;                % 환전- 1000원기준 5.18위안
    cny = floor(cny);
    count = 0;                                  % 지폐 수
    china_unit = [100 50 20 10 5 1];            % 중국 지폐 단위 100위안 50위안 20위안 10위안 5위안 1위안
    remain = [0 0 0 0 0 0];
    for unit = 1:6
        remain(unit) = fix(cny/china_unit(unit));
        cny = mod(cny,china_unit(unit));
    end

    for c = 1:6
        count = count + remain(c);
    end

    bill = count;
end

% 한국 원화 1000원 기준 102.87엔
function bill = countYen(krw_money)
    money_jpy = (krw_money/1000)*102.87;        % 입력받은 원화를 엔화로 환전
    money_jpy = floor(money_jpy);               % 소수점 버림.
    bills = [10000 5000 2000 1000];             % 일본 지폐 단위 10000엔 5000엔 2000엔 1000엔
    bill_count = [0 0 0 0];                     % 단위별 지폐 개수
    bill_sum = 0;                               % 지폐 개수 총합

    for idx = 1:4
        [bill_count(idx), money_jpy] = quorem(sym(money_jpy), sym(bills(idx)));     
        bill_sum = bill_sum + bill_count(idx);
    end
    
    bill = bill_sum;
end
