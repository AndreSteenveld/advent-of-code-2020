create table input (
    min int,
    max int,
    char text,
    input text,
    count int
);

.mode csv
.import -v --csv --skip 1 '|/root/input' input

.mode table

select count( * ) 
  from input 
 where max >= count and count >= min;

select count( * )
from input
where substr( input, min, 1 ) <> substr( input, max, 1 ) 
  and char in ( substr( input, min, 1 ), substr( input, max, 1 ) );