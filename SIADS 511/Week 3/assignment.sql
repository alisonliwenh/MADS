-- Alter table
select * from pg4e_debug;

alter table pg4e_debug add column neon629 INTEGER;

-- Select distinct
select distinct state from taxdata order by state asc limit 5;

-- Making a stored procedure
CREATE TABLE keyvalue ( 
  id SERIAL,
  key VARCHAR(128) UNIQUE,
  value VARCHAR(128) UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY(id)
);

insert into keyvalue (key, value) values ('this is a key', 'this is a value');
select * from keyvalue;

create or replace function trigger_set_timestamp()
returns trigger as $$
begin
	new.updated_at = NOW();
    return new;
end;
$$ language plpgsql;

create trigger set_timestamp
before update on keyvalue
for each row 
execute procedure trigger_set_timestamp();

update keyvalue set value='new value'
  where key='this is a key'
returning *;

-- Musical tracks many-to-one
CREATE TABLE album (
  id SERIAL,
  title VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);

CREATE TABLE track (
    id SERIAL,
    title VARCHAR(128),
    len INTEGER, rating INTEGER, count INTEGER,
    album_id INTEGER REFERENCES album(id) ON DELETE CASCADE,
    UNIQUE(title, album_id),
    PRIMARY KEY(id)
);

DROP TABLE IF EXISTS track_raw;
CREATE TABLE track_raw
 (title TEXT, artist TEXT, album TEXT, album_id INTEGER,
  count INTEGER, rating INTEGER, len INTEGER);
 
\copy track_raw(title, artist, album, count, rating, len) from 'library.csv' with delimiter ',' csv;

update track_raw set album_id=(select album.id from album where album.title=track_raw.album);

insert into track(title, count, rating, len, album_id) 
  select title, count, rating, len, album_id from track_raw;
 
SELECT track.title, album.title
    FROM track
    JOIN album ON track.album_id = album.id
    ORDER BY track.title LIMIT 3;

-- Unesco heritage sites many-to-one
   
CREATE TABLE unesco_raw
 (name TEXT, description TEXT, justification TEXT, year INTEGER,
    longitude FLOAT, latitude FLOAT, area_hectares FLOAT,
    category TEXT, category_id INTEGER, state TEXT, state_id INTEGER,
    region TEXT, region_id INTEGER, iso TEXT, iso_id INTEGER);

CREATE TABLE category (
  id SERIAL,
  name VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);
CREATE TABLE state (
  id SERIAL,
  name VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);
CREATE TABLE region (
  id SERIAL,
  name VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);
CREATE TABLE iso (
  id SERIAL,
  name VARCHAR(2) UNIQUE,
  PRIMARY KEY(id)
);

CREATE TABLE unesco (
  id SERIAL,
  name TEXT, 
  description TEXT, 
  justification TEXT, 
  year INTEGER,
  longitude FLOAT, 
  latitude FLOAT, 
  area_hectares FLOAT,
  category_id INTEGER,
  state_id INTEGER,
  region_id INTEGER,
  iso_id INTEGER,
  PRIMARY KEY(id)
);

\copy unesco_raw(name,description,justification,year,longitude,latitude,area_hectares,category,state,region,iso) FROM 'whc-sites-2018-small.csv' WITH DELIMITER ',' CSV HEADER;

insert into category (name) (select distinct category from unesco_raw);
insert into state (name) (select distinct state from unesco_raw);
insert into region (name) (select distinct region from unesco_raw);
insert into iso (name) (select distinct iso from unesco_raw);

update unesco_raw set category_id=(select category.id from category where category.name=unesco_raw.category);
update unesco_raw set state_id=(select state.id from state where state.name=unesco_raw.state);
update unesco_raw set region_id=(select region.id from region where region.name=unesco_raw.region);
update unesco_raw set iso_id=(select iso.id from iso where iso.name=unesco_raw.iso);

insert into unesco (name, description, justification, year, longitude, latitude, area_hectares, category_id, state_id, region_id, iso_id) (
  select name, description, justification, year, longitude, latitude, area_hectares, category_id, state_id, region_id, iso_id from unesco_raw);


SELECT unesco.name, year, category.name, state.name, region.name, iso.name
  FROM unesco
  JOIN category ON unesco.category_id = category.id
  JOIN iso ON unesco.iso_id = iso.id
  JOIN state ON unesco.state_id = state.id
  JOIN region ON unesco.region_id = region.id
  ORDER BY iso.name, unesco.name
  LIMIT 3;
  
-- Musical track database plus artists
 
DROP TABLE album CASCADE;
CREATE TABLE album (
    id SERIAL,
    title VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE track CASCADE;
CREATE TABLE track (
    id SERIAL,
    title TEXT, 
    artist TEXT, 
    album TEXT, 
    album_id INTEGER REFERENCES album(id) ON DELETE CASCADE,
    count INTEGER, 
    rating INTEGER, 
    len INTEGER,
    PRIMARY KEY(id)
);

DROP TABLE artist CASCADE;
CREATE TABLE artist (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE tracktoartist CASCADE;
CREATE TABLE tracktoartist (
    id SERIAL,
    track VARCHAR(128),
    track_id INTEGER REFERENCES track(id) ON DELETE CASCADE,
    artist VARCHAR(128),
    artist_id INTEGER REFERENCES artist(id) ON DELETE CASCADE,
    PRIMARY KEY(id)
);

\copy track(title,artist,album,count,rating,len) FROM 'library.csv' WITH DELIMITER ',' CSV;

INSERT INTO album (title) SELECT DISTINCT album FROM track;
UPDATE track SET album_id = (SELECT album.id FROM album WHERE album.title = track.album);

INSERT INTO tracktoartist (track, artist) SELECT DISTINCT on (title) title, artist from track;

INSERT INTO artist (name) select distinct artist from track;

UPDATE tracktoartist SET track_id = (select track.id from track where track.title=tracktoartist.track);
UPDATE tracktoartist SET artist_id = (select artist.id from artist where artist.name=tracktoartist.artist);

-- We are now done with these text fields
--ALTER TABLE track DROP COLUMN album;
--ALTER TABLE track drop column artist;
--ALTER TABLE tracktoartist DROP COLUMN track;
--ALTER TABLE tracktoartist drop column artist;

SELECT track.title, album.title, artist.name
FROM track
JOIN album ON track.album_id = album.id
JOIN tracktoartist ON track.id = tracktoartist.track_id
JOIN artist ON tracktoartist.artist_id = artist.id
LIMIT 3;
