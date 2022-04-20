krw_money = input("원화를 입력하세요 : " );
dollar = countDollar(krw_money);
fprintf("최소 달러 지폐 개수는 %d 개\n",dollar);

function bill = countDollar(krw_money)
    count = 0;  %갯수
    dollar_list = [100 50 20 10 5 2 1];  %지폐 단위
    money = krw_money / 1000 * 0.81;  %환전
    mod1 = money;
    for i = 1:7
        if mod1 > dollar_list(i)
            count = count + floor(mod1 / dollar_list(i)); %지폐 개수 구하기
            mod1 = mod(mod1, dollar_list(i)); %나머지값
        else
            continue
        end
    end
    bill = count;  %지폐 총합
end