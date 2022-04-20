krw_money = input("원화를 입력하세요 : " );
euro = countEuro(krw_money);
fprintf("최소 달러 지폐 개수는 %d 개\n",euro);

function bill = countEuro(krw_money)
    count = 0;  %갯수
    euro_list = [500 200 100 50 20 10 5];  %지폐 단위
    money = krw_money / 1000 * 0.75;  %환전
    fprintf("값 %f",money)
    mod1 = money;
    for i = 1:7
        if mod1 > euro_list(i)
            count = count + floor(mod1 / euro_list(i)); %지폐 개수 구하기
            mod1 = mod(mod1, euro_list(i)); %나머지값
            fprintf("지폐값: %d 지폐개수: %d",euro_list(i),count)
        else
            continue
        end
    end
    bill = count;  %지폐 총합
end