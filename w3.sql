-- q1
-- q2
-- white board
-- q4
-- white board
-- q7
multivariate pk can only be done like primary key (a,b)
-- q9
a. integer attribute ina sequence
b. insert into R(name, d_o_b) values ('Kate', 1/1/2002) returning id;
c. person integer references R(id)

-- q11
CREATE TABLE Person (
    familyName varchar(30),
    givenName varchar(30),
    initial char(1),
    streetNumber varchar(5),
    streetName varrchar(45),
    suburb varchar(45),
    birthday date,
    primary key (familyName, givenName, initial)
);

-- q15
create table Teams (
    name varchar(30) primary key,
    captain varchar(30) not null
);

create table Players (
    name varchar(30) primary key,
    team varchar(30) not null references Teams(name),
);

alter table Teams add foreign key (captain) references Players(name)

create table Fans (
    name varchar(30) primary key,
);

create table FavTeams (
    fan varchar(30) references Fans(name),
    team varchar(30) references Teams(name),
    primary key( fan,team),
);

create table FavPlayers (
    fan varchar(30) references Fans(name),
    player varchar(30) references Players(name),
    primary key(fan,player),
);

create table FavColours (
     colour varchar(10)
    "" "" ""
);

create table TeamColours (
    "" "" "" 
);

--q17
--whiteboard

-- q20
ER style
create domain TFN as char(11)
    check (value ~ '^[0-9]{3}-[0-9]{3}-[0-9]{3}$');

create domain ISBN ....

create domain ABN as varchar(14) 
    check (value ~ '^[0-9]{2} [0-9]{3} [0-9]{3} [0-9]{3}')

create table Persons (
    name varchar(30),
    address varchar(100),
    tfn TFN primary key,
);

create table Publishers (
    abn ABN primary key,
    address varchar(100),
);

create table Authors (
    person primary key references people(tfn),
    penname varchar(30),
);

create table Editors (
    person primary key references people(tfn),
    publisher ABN references Publishers(abn)
);

create table Books (
    isbn ISBN primary key,
    title varchar(100),
    edition integer,
    publisher ABN references Publishers(abn),
    editor TFN references Editors(person)
);


create table Writes (
    author references Author(person),
    book refernces Books(isbn),
    primary key (author,book)
);

----------------------------
Single table w nulls for person
create table Persons (
    name varchar(30),
    address varchar(100),
    tfn TFN primary key,
    kind varchar(10) check (kind in ('author', 'editor'))
    -- attributes for authors
    penname varchar(30),
    -- attributes for editors
    publisher ABN references Publishers(abn),
    constraint CheckAuthorEditor check
            ((kind='editor' and penname is null) or (kind='author' and publisher is null))
);