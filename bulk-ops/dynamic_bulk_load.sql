Use ApolloCE

set nocount on

declare @path varchar(100) = 'C:\Users\a_rleandro\Downloads\ApolloCE-data'

declare @tables cursor
set @tables = cursor for (select name  from (values
        ('Package'),
        ('Event')
        ,('EventScan')
        ,('EventImage')
    ) as tables(name))

declare @sqlTemplate varchar(max) = '
    print ''Importing %table%...''
    if object_id(''tempdb..%table%'') is not null drop table #%table%
    select top(0) %createList% into #%table% from %table%
    bulk insert #%table% from ''%path%\%table%.dat'' with (formatfile = ''%path%\%table%.fmt'')
    set identity_insert %table% on
    insert %table% (%insertList%) select %insertList% from #%table% where id not in (select id from %table%)
    print formatmessage(''(%i rows imported)'', @@rowcount)
    set identity_insert %table% off'

declare @table varchar(50)
declare @createList varchar(max) = ''
declare @insertList varchar(max) = ''

open @tables
fetch next from @tables into @table
while @@fetch_status = 0 
begin
    select  @insertList += case when isnull(@insertList, '') = '' then insertName else ', ' + insertName end,
            @createList += case when isnull(@createList, '') = '' then createName else ', ' + createName end
        from (	select top 100 percent
                        name as insertName,
                        case when name != 'id' then name
                            else case when xtype = 127 then 'cast(id as bigint) as id'
                            else 'cast(id as int) as id'
                        end end as createName
                    from sys.syscolumns
                    where object_name(id) = @table
                        and iscomputed = 0
                    order by colorder) as syscolumns
    declare @sql varchar(max) = replace(replace(replace(replace(@sqlTemplate, '%path%', @path), '%table%', @table), '%insertList%', @insertList), '%createList%', @createList)
    exec(@sql)
	--print(@sql)
	--print(@table)
	--print(@insertList)
	--print(@createList)
	select  @insertList='',@createList=''
    fetch next from @tables into @table
end
close @tables
deallocate @tables
