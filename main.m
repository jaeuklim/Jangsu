% Mini-drone 경진대회 1차 팀과제.

krw_money = input("원화를 입력하세요 : ");

JPY = countJPY(krw_money);
% 이곳에 나머지 함수 호출해주세요


fprintf('최소 엔 지폐 개수는 %d 개', JPY);
% 이곳에 나머지 출력문 코드 작성해주세요


% 한국 원화 1000원 기준 0.81달러
% 한국 원화 1000원 기준 0.75유로
% 한국 원화 1000원 기준 102.87엔
% 한국 원화 1000원 기준 5.18위안


function bill = countJPY(krw_money)
    money_jpy = 102.87*(krw_money/1000);        % 입력받은 원화를 엔화로 환전
    money_jpy = int64(money_jpy);               % 정수형으로 변환.
    bills = [10000 5000 2000 1000];             % 일본 지폐 단위 10000엔 5000엔 2000엔 1000엔
    bill_count = [0 0 0 0];                     % 단위별 지폐 개수
    bill_sum = 0;                               % 지폐 개수 총합

    for idx = 1:4
        [bill_count(idx), money_jpy] = quorem(sym(money_jpy), sym(bills(idx)));     
        bill_sum = bill_sum + bill_count(idx);
    end

    bill_count                                 % 개수 확인용 변수(제출 전 삭제예정)
    
    bill = bill_sum;
end