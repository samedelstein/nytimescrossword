select 
    date as DateFK
    , minutes as Minutes
    , seconds as Seconds
    , complete as Complete
    , word_check as WordCheck 
    ,minutes * 60 +seconds as TotalTime 
from nytimescrossword.crossword.crosswordtimes
