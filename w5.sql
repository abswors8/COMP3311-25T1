-- week 5: PLpgSQL functions & SQL Functions

-- SQL functions are just subqueries 

create or replace function funcName(n integer) returns integer
as $$
declare
    record i;
begin
    blah blah blah
    for record in select .....
end;
$$ language plpgsql;

-- q1
create or replace function sqr(n numeric) returns integer
as $$
begin
    return n * n;
end;
$$ language plpgsql;

-- q2
create or replace function spread(text) returns text
as $$
declare
    result text := '';
    i integer;
begin
    i := 1;
    while (i <= length($1)) loop
        result := result || substr($1, i, 1) || ' ';
        i := i+1;
    end loop;
    return result;
end;
$$ language plpgsql;
--q3
create or replace
    function seq(n integer) returns setof integer
as $$
declare
    i integer;
begin
    for i in 1..n loop
        return next i;
    end loop;
end;
$$ language plpgsql;

-- q4
-- Generalise the previous function so that it returns a table of integers, 
-- starting from lo up to at most hi, with an increment of inc. 
-- The function should also be able to count down from lo to hi if the 
-- value of inc is negative. An inc value of 0 should produce an empty table.
create or replace function seq(lo int, hi int, inc int) returns setof integer
as $$
declare 
    i integer;
begin
    i := lo;
    if (inc > 0) then
        while (i <= hi) loop
            return next i;
            i = i + inc;
        end loop;
    elsif (inc < 0) then
        while (i >= hi) loop
            return next i;
            i = i + inc;
        end loop;
    end if;
    return;
end;
$$ language plpgsql;

-- q5
create or replace function
    seq(n int) returns setof integer
as $$
select * from seq(1,n,1);
$$ language sql;

-- q6
create function fac(n int) returns integer as $$
select product(seqp) from seq(n);
$$ language sql;

-- q9
create or replace function happyHourPrice(_hotel text,
    _beer text, _discount real) returns text
as $$
declare
    counter integer;
    new_price real;
    old_price real;
begin
    select count(*) into counter from Bars where name = _hotel;
    if (counter=0) then 
        return 'There is no hotel called ' || _hotel; 
    end if;
    select count(*) into counter from Beers where name = _beer;
    if (counter = 0) then
        return 'There is no beer called ' || _beer;
    end if;
    select s.price into old_price from Sells s where s.beer=_beer and s.bar = _hotel;
    if (not found) then
        return 'The ' || _hotel || ' does not sell ' || _beer;
    end if;
    new_price := old_price - _discount;
    if (new_price < 0) then
        return 'Price reduction is too large ' || _beer || ' only costs ' || to_char(old_price, '$9.99');
    else
        return 'Happy hour price for ' || _beer || ' at ' || _hotel || ' is ' || to_char(new_price, '$9.99');
    end if;
end;
$$ language plpgsql;

-- q13
create or replace function branchList() returns text as $$
declare
    b record;
    a record;
    total integer;
    return_text text := e'\n';
begin
    for b in select * from Branches
    loop
        return_text := return_text || 'Branch: ' || b.location || ',' || b.address || e'\n' || 'Customers: ';
        for a in select * from Accounts where branch=b.location
        loop
            return_text := return_text || ' ' || a.holder;
        end loop;
        select sum(balance) into total from Accounts where branch =b.location;
        return_text := return_text || e'\nTotal deposits: ' || to_char(total, '$9999999.99') || e'\n';
    end loop;
    return return_text;
end;
$$ language plpgsql;

-- q14
create or replace function unitName(_ouid integer) returns text as
$$
declare
    unitname text;
begin
    select * from OrgUnit where id=_ouid;
    if (not found) then
        raise exception 'No such unit: %', _ouid;
    end if;
    select case
        when t.name = 'University' then 'UNSW'
        when t.name = 'Faculty' then t.longname
        when t.name = 'School' then 'School of ' || t.longname
        when t.name = 'Department' then 'Department of ' || t.longname
        when t.name = 'Centre' then 'Centre for ' || t.longname
        when t.name = 'Institute' then 'Institute of ' || t.longname
        else null
        end into unitname
    from OrgUnit u join OrgUnitType t on u.utype=t.id where u.id=_ouid;
    return unitname;
end;
$$ language plpgsql;

-- q15
create or replace function unitID(partName text) returns integer
as $$ 
select id from OrgUnit where longname ilike '%' || partName || '%';
$$ language sql;

-- q16
create or replace function facultyOf(_ouid integer) returns integer
as $$
declare
    _parent integer;
    _type text;
begin
    perform * from orgUnit where id = _ouid;
    if (not found) then
        raise exception 'No such unit: %', _ouid;
    end if;
    select t.name into _type from OrgUnit u join OrgUnitType t 
    on u.utype=t.id where u.id=_ouid;
    if (_type = 'Faculty') then
        return _ouid;
    elsif (_type is null) then 
        return null;
    elsif (_type ='University') then
        return null;
    else 
        select owner into _parent from UnitGroups where member = _ouid;
        return facultyOf(_parent);
    end if;
end;
$$ language plpgsql;
