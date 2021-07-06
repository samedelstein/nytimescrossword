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
  select match_id,
  Complete,
  case when Complete = 'yes' and lag(Complete) over (order by datefk) = 'no' then 1 else 0 end new_streak
  from game_log
), 

streak_no as (
  select 
  match_id,
  sum(new_streak) over (order by match_id) streak_num
  from new_streaks
  where Complete = 'yes'
),

records_per_streak as (
  select 
  count(*) counter,
  streak_num
  from streak_no
  group by streak_num
)

select max(counter) longest_streak
from records_per_streak