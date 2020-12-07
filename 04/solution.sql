drop table if exists input;
create table input (
    byr text, 
    iyr text, 
    eyr text, 
    hgt text, 
    hcl text, 
    ecl text, 
    pid text, 
    cid text,
    passport text
);

.mode csv
.import -v --csv --skip 1 '|/root/input' input

.mode table 

select count( * )
from input 
where  -- All fiels are present so this passport is valid
      '' not in ( byr, iyr, eyr, hgt, hcl, ecl, pid, cid )
    or -- Missing cid, which is also fine
      '' not in ( byr, iyr, eyr, hgt, hcl, ecl, pid )
    ;

with 
    valid_byr ( rowid ) as ( select rowid from input where byr glob '[0-9][0-9][0-9][0-9]' and ( 0 + byr ) >= 1920 and 2020 >= ( 0 + byr ) ),
    valid_iyr ( rowid ) as ( select rowid from input where iyr glob '[0-9][0-9][0-9][0-9]' and ( 0 + iyr ) >= 2010 and 2020 >= ( 0 + iyr ) ),
    valid_eyr ( rowid ) as ( select rowid from input where eyr glob '[0-9][0-9][0-9][0-9]' and ( 0 + eyr ) >= 2020 and 2030 >= ( 0 + eyr ) ),
    valid_hgt ( rowid ) as ( 
        select rowid from input
        where ( hgt glob '[0-9][0-9][0-9]cm' and ( 0 + hgt ) >= 150 and 193 >= ( 0 + hgt ) )
           or ( hgt glob '[0-9][0-9]in' and ( 0 + hgt ) >= 59 and 76 >= ( 0 + hgt ) )
    ),
    valid_hcl ( rowid ) as ( select rowid from input where hcl glob '#[0-f][0-f][0-f][0-f][0-f][0-f]' ),
    valid_ecl ( rowid ) as ( select rowid from input where ecl in ( 'amb', 'blu', 'brn', 'gry', 'grn', 'hzl', 'oth' ) ),
    valid_pid ( rowid ) as ( select rowid from input where pid glob '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')

select count( * ) from input
where 1
  and rowid in ( select rowid from valid_byr ) 
  and rowid in ( select rowid from valid_iyr )
  and rowid in ( select rowid from valid_eyr )
  and rowid in ( select rowid from valid_hgt )
  and rowid in ( select rowid from valid_hcl )
  and rowid in ( select rowid from valid_ecl )
  and rowid in ( select rowid from valid_pid )
  ;