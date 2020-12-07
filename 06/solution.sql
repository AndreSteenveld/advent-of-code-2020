drop table if exists input;
create table input (
    group_no int,
    person_no int,
    answer text
);

.mode csv
.import -v --csv --skip 1 '|/root/input' input

.mode table 

--
-- Part one
--
with 
    group_answers( group_no, answer, occurences ) as (
        select group_no, answer, count( * )
        from input
        group by group_no, answer
    )
select count( * ) from group_answers;

--
-- Part two
--
with
    person ( group_no, person_no ) as (
        select distinct group_no, person_no
        from input
    ),

    group_size( group_no, size ) as (
        select group_no, count( * )
        from person
        group by group_no
    ),

    group_answers( group_no, answer, occurences ) as (
        select group_no, answer, count( * )
        from input
        group by group_no, answer
    )
select sum( s )
from (
    select count( group_no ) as s
    from group_answers
    join group_size using (group_no)
    where occurences = size
    group by group_no 
);