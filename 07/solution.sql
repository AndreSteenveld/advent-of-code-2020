drop table if exists input;
create table input (
    outer text,
    amount int,
    inner text
);

.mode csv
.import -v --csv --skip 1 '|/root/input' input

.mode table 

drop view if exists bag;
create view bag as
    with
        bags ( bag ) as (
            select distinct bag
            from (
                          select outer as bag from input
                union all select inner as bag from input
            )
        ),

        children ( bag, children ) as (
            select bag, json_group_array( inner ) 
            from (
                select bag, coalesce( inner, '' ) as inner
                from bags
                left outer join input on ( bag = outer )
            )
            group by bag
        ),
        
        parents ( bag, parents ) as (
            select bag, json_group_array( outer )
            from (
                select bag, coalesce( outer, '' ) as outer
                from bags
                left outer join input on ( bag = inner )
            )
            group by bag
        )
    
    select bag as name, parents, children
    from ( select distinct outer as bag from input )
    join children using ( bag )
    join parents using ( bag )
;

with 
    recursive bag_parents( name, parent ) as (

        select bag.name, value as parent
          from bag
          join json_each( parents )
         where name = 'shiny gold' 
        
        union all 
            select bag.name, value as parent
              from bag_parents
              join bag on ( bag_parents.parent = bag.name )
              join json_each( bag.parents ) 
             where bag_parents.parent <> ''

    )
-- select distinct name from bag_parents where name <> 'shiny gold';
select count( * ) from ( select distinct name from bag_parents where name <> 'shiny gold' );

with
    recursive bag_childern( outer, amount, inner ) as (

        select outer, amount, inner
          from input
         where outer = 'shiny gold'

        union all
            select input.outer, input.amount * bag_childern.amount, input.inner
              from bag_childern
              join input on ( input.outer = bag_childern.inner )
    
    )
select sum( amount ) from bag_childern;

