create table Employees (
      eid     integer,
      ename   text,
      age     integer,
      salary  real check (salary >= 15000),
      primary key (eid)
);
create table Departments (
      did     integer,
      dname   text,
      budget  real,
      manager integer not null references Employees(eid),
      primary key (did)
      constraint fullTimeManager check ((select sum(w.percent) from worksin w where w.eid=manager) = 1.0)
);
create table WorksIn (
      eid     integer references Employees(eid) on delete cascade,
      did     integer references Departments(did),
      percent real check ((select sum(w.percent) from worksin w where w.eid=eid) <= 1.0),
      primary key (eid,did)
);

-- q2
update Employees set salary=salary*0.8 where age<25;

-- q3
update Employees e set e.salary=e.salary*1.1 where e.eid in 
(select w.eid from Departments d join WorksIn w on d.did=w.did where d.dname='Sales')

--q9
update department set manager= someEID where did = ourDepartmentDID

create table Suppliers (
      sid     integer primary key,
      sname   text,
      address text
);
create table Parts (
      pid     integer primary key,
      pname   text,
      colour  text
);
create table Catalog (
      sid     integer references Suppliers(sid),
      pid     integer references Parts(pid),
      cost    real,
      primary key (sid,pid)
);

-- Find the names of suppliers who supply some red part.
select s.sname from Suppliers s join Catalog c on s.sid=c.sid join Parts p on p.pid=c.pid where p.colour='red'

-- Find the sids of suppliers who supply some red or green part.
select c.sid from Catalog c join Parts p on p.pid=c.pid where p.colour='red' or p.colour='green'

-- Find the sids of suppliers who supply some red part or whose address is 221 Packer Street.
select s.sid from Suppliers s join Catalog c on s.sid=c.sid join Parts p on p.pid=c.pid where p.colour='red' or s.address='221 Packer St'

-- Find the sids of suppliers who supply some red part and some green part.
(select s.sid from Suppliers s join Catalog c on s.sid=c.sid join Parts p on p.pid=c.pid where p.colour='red')
intersect
(select s.sid from Suppliers s join Catalog c on s.sid=c.sid join Parts p on p.pid=c.pid where p.colour='green')

-- Find the sids of suppliers who supply every part.
select s.sid from supplier s where not exists (
    (select p.pid from parts p) except (select c.pid from catalog c where c.sid=s.sid))

-- Find the sids of suppliers who supply every red part.
select s.sid from supplier s where not exists (
    (select p.pid from parts p where p.colour='red') except (select c.pid from catalog c where c.sid=s.sid))
-- Find the sids of suppliers who supply every red or green part.
select s.sid from supplier s where not exists (
    (select p.pid from parts p where p.colour'red' or p.colour='green') except (select c.pid from catalog c where c.sid=s.sid))
-- Find the sids of suppliers who supply every red part or supply every green part.
(select s.sid from supplier s where not exists (
    (select p.pid from parts p where p.colour='red') except (select c.pid from catalog c where c.sid=s.sid)))
union
(select s.sid from supplier s where not exists (
    (select p.pid from parts p where p.colour='green') except (select c.pid from catalog c where c.sid=s.sid)))
-- Find pairs of sids such that the supplier with the first sid charges more for some part than the supplier with the second sid.
select c1.sid, c2.sid from catalog c1, catalog c2 where c1.pid =c2.pid and c1.sid!=c2.sid and c1.cost > c2.cost
-- Find the pids of parts that are supplied by at least two different suppliers.
select c.pid from catalog c where (select count(c1.sid) from catalog c1 where c1.pid=c.pid) >= 2

select c.pid from catalog c where exists (select c1.sid from catalog c1 where c1.pid =c.pid and c1.sid != c.sid)
-- Find the pids of the most expensive part(s) supplied by suppliers named "Yosemite Sham".
select c.pid from catalog c join suppliers s on c.sid=s.sid where s.name = 'Yosemite Sham'
and c.cost >= all(select c1.cost from catalog c1 join suppliers s1 on c1.sid=s1.sid where s1.name='Yosemite Sham' and c1.sid!=c.sid)
-- Find the pids of parts supplied by every supplier at a price less than 200 dollars (if any supplier either does not supply the part or charges more than 200 dollars for it, the part should not be selected).
select c.pid from catalog c where c.price < 200 group by c.pid 
having count(*) = (select count(*) from Suppliers)