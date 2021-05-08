create table account(
  id SERIAL,
  email VARCHAR(128) unique,
  created_at DATE not null default NOW(),
  updated_at DATE not null default NOW(),
  primary key(id)
);

create table post(
  id SERIAL,
  title VARCHAR(128) unique not null, -- Will extend with alter
  content VARCHAR(1024),
  account_id INTEGER references account(id) on delete cascade,
  created_at TIMESTAMPTZ not null default NOW(),
  updated_at TIMESTAMPTZ not null default NOW(),
  primary key(id)
);

create table comment(
  id SERIAL,
  content text not null,
  account_id INTEGER references account(id) on delete cascade,
  post_id INTEGER references post(id) on delete cascade,
  created_at TIMESTAMPTZ not null default NOW(),
  updated_at TIMESTAMPTZ not null default NOW(),
  primary key(id)
);

create table fav(
  id SERIAL,
  oops text, -- Will remove later with alter
  post_id INTEGER references post(id),
  account_id INTEGER references account(id) on delete cascade,
  created_at TIMESTAMPTZ not null default NOW(),
  updated_at TIMESTAMPTZ not null default NOW(),
  unique(post_id, account_id),
  primary key(id)
);

alter table post alter column content type text;

alter table fav drop column oops;

alter table fav add column howmuch INTEGER;

create table racing (
  make VARCHAR,
  model VARCHAR,
  year INTEGER,
  price INTEGER
);

insert into RACING (make, model, year, price)
values
('Nissan','Stanza',1990,2000),
('Dodge','Neon',1995,800),
('Dodge','Neon',1998,2500),
('Dodge','Neon',1999,3000),
('Ford','Mustang',2001,1000),
('Ford','Mustang',2005, 2000),
('Subaru','Impreza',1997,1000),
('Mazda','Miata',2001,5000),
('Mazda','Miata',2001,3000),
('Mazda','Miata',2001,2500),
('Mazda','Miata',2002,5500),
('Opel','GT',1972,1500),
('Opel','GT',1969,7500),
('Opel','Cadet',1973,500)
;

select make from racing;

select distinct make from racing;

select distinct make,model from racing;

select distinct on (model) make,model,year from racing; -- remove duplicate rows in the column of model

select make,model,year from racing order by year desc;

select make,model,year from racing order by model,year desc; -- ordered by the model first and then the year

select distinct on (model) make,model,year from racing order by model,year desc;

select distinct on (model) make,model,year from racing order by model,year;

select make,model,year from racing;

select distinct model from racing;

-- GROUP BY

select * from pg_timezone_names limit 20;

select count(*) from pg_timezone_names;

select distinct is_dst from pg_timezone_names;

select is_dst from pg_timezone_names limit 20;

select count(is_dst), is_dst from pg_timezone_names group by is_dst;

select count(abbrev), abbrev from pg_timezone_names group by abbrev;

-- WHERE is before GROUP BY; HAVING is after GROUP by 

select count(abbrev) as ct, abbrev from pg_timezone_names where is_dst='t' group by abbrev having count(abbrev)>10;

select count(abbrev) as ct, abbrev from pg_timezone_names where is_dst='t' group by abbrev;

select count(abbrev) as ct, abbrev from pg_timezone_names where is_dst='t' group by abbrev having count(abbrev) > 10 order by count(abbrev) desc;

-- Subquery

select * from account
where email='ed@umich.edu';

select content from comment where account_id=1;

select id from account where email='ed@umich.edu';

-- It requires in effect two separate operations which the outer operation is in a sense paused until the inner operation finishes.
select content from comment where account_id=(select id from account where email='ed@umich.edu'); 

-- If you did not have the HAVING clause
select ct,abbrev from (select count(abbrev) as ct, abbrev from pg_timezone_names where is_dst='t' group by abbrev) as zap where ct>10;

--Concurrency

-- fav is a many-to-many table
insert into fav(post_id, account_id, howmuch) values (1,1,1);

select * from fav;

-- run into one single transaction
update fav set howmuch=howmuch+1 where post_id=1 and account_id=1
returning *;

-- on conflict means if that insert failed because of a conflict of post_id and account_id, do the content of update set.
insert into fav(post_id, account_id, howmuch) values (1,1,1) on conflict(post_id, account_id) do update set howmuch=fav.howmuch+1;

select * from fav;

insert into fav(post_id, account_id, howmuch) 
  values (1,1,1)
  on conflict(post_id,account_id)
  do update set howmuch=fav.howmuch + 1
  returning *;
 
-- Transactions

begin;
select howmuch from fav where account_id=1 and post_id=1 for update of fav;
-- Time passes...
update fav set howmuch=999 where account_id=1 and post_id=1;
rollback; -- go back to begin and the transaction is discarded
select howmuch from fav where account_id=1 and post_id=1;


begin;
select howmuch from fav where account_id=1 and post_id=1 for update of fav;
-- Time passes...
update fav set howmuch=999 where account_id=1 and post_id=1;
commit; -- committed to the real database
select howmuch from fav where account_id=1 and post_id=1;
rollback;

-- Stored procedures

select * from fav;

update fav set howmuch=howmuch+1
  where post_id=1 and account_id=1
returning *;

create or replace function trigger_set_timestamp()
returns trigger as $$
begin
	new.updated_at = NOW();
    return new;
end;
$$ language plpgsql;

create trigger set_timestamp
before update on post
for each row
execute procedure trigger_set_timestamp();

create trigger set_timestamp
before update on fav
for each row
execute procedure trigger_set_timestamp();

create trigger set_timestamp
before update on comment
for each row
execute procedure trigger_set_timestamp();

update fav set howmuch=howmuch+1
  where post_id = 1 and account_id = 1
returning *;

-- the date and time of updated_at is updated automatically
update fav set howmuch=howmuch+1
  where post_id = 1 and account_id = 1
returning *;

-- Loading and normalized CSV data 
-- Load a CSV file and automatically normalize into one-to-many

create table xy_raw(x text, y text, y_id integer);
create table y (id serial, primary key(id), y text);
create table xy(id serial, primary key(id), x text, y_id integer, unique(x,y_id));

\copy xy_raw(x,y) from '03-Techniques.csv' with delimiter ',' csv;

select * from xy_raw;
select distinct y from xy_raw;

insert into y (y) select distinct y from xy_raw;

select * from y;

update xy_raw set y_id = (select y.id from y where y.y=xy_raw.y);

select * from xy_raw;

insert into xy (x,y_id) select x,y_id from xy_raw;

select * from xy join y on xy.y_id=y.id;

select * from xy;
