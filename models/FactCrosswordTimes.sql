with cleaned_data as (select 
    date as DateFK
    , minutes as Minutes
    , seconds as Seconds
    , complete as Complete
    , word_check as WordCheck 
    ,minutes * 60 +seconds as TotalTime 
from nytimescrossword.crossword.crosswordtimes)

select *
    ,   avg(TotalTime) OVER(ORDER BY DateFK
     ROWS BETWEEN 7 PRECEDING AND CURRENT ROW ) 
     as seven_day_average
     ,   avg(TotalTime) OVER(ORDER BY DateFK
     ROWS BETWEEN 30 PRECEDING AND CURRENT ROW ) 
     as thirty_day_average
     , avg(TotalTime) OVER(ORDER BY DateFK) 
     as all_time_average
    FROM cleaned_data
