drop table if exists input;
create table input (
    ic int,
    op text,
    arg int
);

.mode csv
.import -v --csv --skip 1 '|/root/input' input

.mode table 

create index input_instruction_count on input( ic );

with 
    recursive program ( ic, op, arg, pc, acc, _ ) as (

        select ic, op, arg, 1, iif( op = 'acc', arg, 0 ), '[1]'
          from input
         where ic = 1

        union all
            select 
                i.ic, 
                
                iif( i.ic in ( select value from json_each( _ ) ), 'hlt', i.op ), 
                
                i.arg, 
                
                p.pc + 1, 
                
                p.acc + iif( i.op = 'acc', i.arg, 0 ),

                json_insert( _, '$[' || json_array_length( _ ) || ']', i.ic )

            from program as p
            join input as i on ( i.ic = p.ic + iif( p.op = 'jmp', p.arg, 1 ) )
            where p.op <> 'hlt'

    )
select ic, op, arg, acc from program where op <> 'hlt';
