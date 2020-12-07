drop table if exists input;
create table input (
    group_no int,
    person_no int,
    answer text
);

.mode csv
.import -v --csv --skip 1 '|/root/input' input

.mode table 

with 
    group_answers( group_no, answer, occurences ) as (
        select group_no, answer, count( * )
        from input
        group by group_no, answer
    )
-- First part of the puzzle
select count( * ) from group_answers;