with cleaned_data as (select 
    date as DateFK
    , minutes as Minutes
    , seconds as Seconds
    , complete as Complete
    , word_check as WordCheck 
    ,minutes * 60 +seconds as TotalTime 
from nytimescrossword.crossword.crosswordtimes),

avgtimes as (
    select *
    ,   avg(TotalTime) OVER(ORDER BY DateFK
     ROWS BETWEEN 7 PRECEDING AND CURRENT ROW ) 
     as seven_day_average
     ,   avg(TotalTime) OVER(ORDER BY DateFK
     ROWS BETWEEN 30 PRECEDING AND CURRENT ROW ) 
     as thirty_day_average
     , avg(TotalTime) OVER(ORDER BY DateFK) 
     as all_time_average
    FROM cleaned_data),

winslosses as (
    select *,
    row_number() over (order by datefk) as wins,
    null as losses 
from avgtimes
where Complete is not NULL and Complete = 'yes'

union all

select *,
    null as wins,
    row_number() over ( order by datefk) as losses 
from avgtimes
where Complete is not NULL and Complete = 'no'
order by datefk),

cumulativewinslosses as (
  select  DateFK,
        Minutes,
        Seconds,
        Complete,
        WordCheck,
        TotalTime,
        seven_day_average,
        thirty_day_average,
        all_time_average,
        max(wins) OVER (Order by datefk asc rows unbounded preceding) CumulativeWins,
        max(losses) OVER (Order by datefk asc rows unbounded preceding)  CumulativeLosses
from winslosses
order by datefk)

select 
    c.DateFK,
    Minutes,
    Seconds,
    Complete,
    WordCheck,
    TotalTime,
    seven_day_average,
    thirty_day_average,
    all_time_average,
    CumulativeWins,
    CASE WHEN CumulativeLosses is null then 0 else CumulativeLosses end as CulumativeLosses,
    CumulativeWins/(CumulativeWins + CumulativeLosses) as WinPercentage, 
    WinStreak
FROM cumulativewinslosses c
LEFT JOIN {{ref('stg_winstreak')}} s 
ON c.DateFK = s.DateFK
