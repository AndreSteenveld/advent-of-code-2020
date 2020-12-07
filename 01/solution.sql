create table input ( value integer not null );

.mode csv
.import -v --csv --skip 1 '|/root/input' input

.mode table

select left.value as left
     , right.value as right
     , ( left.value + right.value ) as sum
     , ( left.value * right.value ) as multiplied
  from input as left
  cross join input as right
  where 2020 = ( left.value + right.value );

select left.value as left
     , center.value as center
     , right.value as right
     , ( left.value + center.value + right.value ) as sum
     , ( left.value * center.value * right.value ) as multiplied
  from input as left
  cross join input as center
  cross join input as right
  where 2020 = ( left.value + center.value + right.value );