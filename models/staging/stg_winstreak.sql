with game_log as (select 
    date as DateFK
    , minutes as Minutes
    , seconds as Seconds
    , complete as Complete
    , word_check as WordCheck 
    ,minutes * 60 +seconds as TotalTime 
    , row_number() OVER (order by date) as match_id
from nytimescrossword.crossword.crosswordtimes),

new_streaks as (
  select *,
  case when Complete = 'yes' and lag(Complete) over (order by datefk) = 'no' then 1 else 0 end new_streak
  from game_log
),

streak_no as (
  select 
  *,
  sum(new_streak) over (order by match_id) streak_num
  from new_streaks
  where Complete = 'yes'
)

select datefk, 
row_number() over (partition by streak_num order by datefk) as WinStreak
from streak_no
order by datefk
