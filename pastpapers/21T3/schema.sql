create type StreetType as enum
	( 'Avenue', 'Close', 'Crescent', 'Drive', 'Highway',
	  'Parade', 'Place', 'Road', 'Street'
	);
create type PropertyType as enum
	( 'Apartment', 'House', 'Townhouse' );
create type FeatureType as enum
	( 'bedrooms', 'bathrooms', 'carspaces', 'pool', 'elevator' );
create domain PriceType integer check (value > 100000);

create table Suburbs (
	id          integer,
	name        text not null,
	postcode    integer not null,
	primary key (id)
);

create table Streets (
	id          integer,
	name        text not null,
	stype       StreetType not null,
	suburb      integer not null references Suburbs(id),
	primary key (id)
);

create table Properties (
	id          integer,
	unit_no     integer,    -- null if not an Apartment
	street_no   integer not null,
	street      integer not null references Streets(id),
	ptype       PropertyType not null,
	list_price  PriceType not null,
	sold_price  PriceType,  -- null if not yet sold
	sold_date   date,       -- null if not yet sold
	primary key (id)
);

create table Features (
	property	integer references Properties(id),
	feature     FeatureType,  -- e.g. # bedrooms
	number      integer check (number between 1 and 10),
	primary key (property,feature)
);

-- Notes on the above schema:

-- the schema is heavily normalised
-- there are only four suburbs with properties; not all streets have a listed property
-- properties have two price attributes:
-- list_price is set when the property is added to the database and is a price guide for potential buyers
-- sold_price is set when the property is sold; it may be different to the list price (could be higher or lower)
-- all properties have at least one bedroom and at least one bathroom (with details in the Features table)
-- for each property, there is at most one entry for each feature type (the number attribute tells how many instances)
-- properties with a null sold_price are still on the market (unsold)