create table input (
    line text,
    line_mask int
);

.mode csv
.import -v --csv --skip 1 '|/root/input' input

.mode table 

with recursive path ( x, y, field, width ) as (
    -- The sample data is 11 columns wide, the actual input is 31 cols wide
    values( 1, 1, ( select substr( line, 1, 1 ) from input where rowid = 1 ), 31 )
    union all
        select
            x + 3, 
            y + 1,
            ( 
                select substr( line, iif( (x + 3) % width, (x + 3) % width, width ), 1 ) 
                from input 
                where rowid = y + 1
            ),
            width
        from path
        limit ( select max( rowid ) from input )
)
--select x, y, field from path;
select count( * ) from path where field = '#';

