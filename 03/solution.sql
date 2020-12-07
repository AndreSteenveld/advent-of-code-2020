create table input (
    line text,
    line_mask int
);

.mode csv
.import -v --csv --skip 1 '|/root/input' input

.mode table 

-- with recursive path ( x, y, field, width ) as (
--     -- The sample data is 11 columns wide, the actual input is 31 cols wide
--     values( 1, 1, ( select substr( line, 1, 1 ) from input where rowid = 1 ), 31 )
--     union all
--         select
--             x + 3, 
--             y + 1,
--             ( 
--                 select substr( line, iif( (x + 3) % width, (x + 3) % width, width ), 1 ) 
--                 from input 
--                 where rowid = y + 1
--             ),
--             width
--         from path
--         limit ( select max( rowid ) from input )
-- )
-- --select x, y, field from path;
-- select count( * ) from path where field = '#';

--
-- Now for part two, it would be nice if SQLite had stored proceedures or prepared statents
-- or stuff along that line... For now lets just make do with a insert trigger
--
create table result ( 
    x int,
    y int,
    trees int
);

create trigger calculate_trees after insert on result
begin

    update result set trees = (

        with recursive path ( x, y, field, width, offset_x, offset_y ) as (
            -- The sample data is 11 columns wide, the actual input is 31 cols wide
            values( 1, 1, ( select substr( line, 1, 1 ) from input where rowid = 1 ), 31, new.x, new.y )
            union all
                select
                    x + offset_x, 
                    y + offset_y,
                    ( 
                        select substr( line, iif( (x + offset_x) % width, (x + offset_x) % width, width ), 1 ) 
                        from input 
                        where rowid = y + offset_y
                    ),
                    width,
                    offset_x,
                    offset_y
                from path
                limit ( select max( rowid ) from input )
            )
        --select x, y, field from path;
        select count( * ) from path where field = '#'

    )
    where result.rowid = new.rowid;

end;

insert into result ( x, y ) values 
    ( 1, 1 ),
    ( 3, 1 ),
    ( 5, 1 ),
    ( 7, 1 ),
    ( 1, 2 );

-- Ok this is me just being lazy and now writing the proper select for this but, danm running
-- multiplications are hard. The only relevant example I could find was: https://stackoverflow.com/questions/43262780/multiply-rows-in-group-with-sqlite
-- which isn't great.
--
-- select 58 * 223 * 105 * 74 * 35;
-- +--------------------------+
-- | 58 * 223 * 105 * 74 * 35 |
-- +--------------------------+
-- | 3517401300               |
-- +--------------------------+
--




