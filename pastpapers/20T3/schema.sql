-- Football/Soccer Schema

-- These domains are not actually defined in the database
-- They appear as constraints in the relevant tables

-- Time in minutes since game started
create domain GameTime as integer check (value between 0 and 120);

-- Cards are warnings given to players for naughty acts
-- Yellow card = final warning;  Red card = send off
create domain CardColour as varchar(6) check (value in ('red','yellow'));

-- Tables

create table Matches (
	id          integer,
	city        varchar(50) not null,
	playedOn    date not null,
	primary key (id)
);

create table Teams (
	id          integer,
	country     varchar(50) not null,
	primary key (id)
);

create table Involves (
	match       integer not null,
	team        integer not null,
	primary key (match,team),
	foreign key (match) references Matches(id),
	foreign key (team) references Teams(id)
);

create table Players (
	id          integer,
	name        varchar(50) not null,
	birthday    date,
	memberOf    integer not null,
	position    varchar(20),
	primary key (id),
	foreign key (memberOf) references Teams(id)
);

create table Goals (
	id          integer,
	scoredIn    integer not null,
	scoredBy    integer not null,
	timeScored  GameTime not null,
	rating      varchar(20),
	primary key (id),
	foreign key (scoredIn) references Matches(id),
	foreign key (scoredBy) references Players(id)
);

create table Cards (
	id          integer,
	givenIn     integer not null,
	givenTo     integer not null,
	timeGiven   GameTime not null,
	cardType    CardColour not null,
	primary key (id),
	foreign key (givenIn) references Matches(id),
	foreign key (givenTo) references Players(id)
);

-- Some assumptions made in developing the above schema:

-- players play for a single country throughout their career
-- players are categorised into a particular position in the team
-- what position each player plays in a given match is not recorded
-- matches are played all over the world
-- each match involves teams from two countries
-- no match runs for more than 120 minutes
-- we need to record who scored each goal and when in the match it was scored
-- goals are rated by a "panel of experts" to determine how good they are
-- if players do something naughty during the game, they are "shown a card"
-- a yellow card means that they did something relatively minor
-- a red card means that they did something bad and are sent off