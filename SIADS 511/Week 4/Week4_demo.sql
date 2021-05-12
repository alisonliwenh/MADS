-- Generate data

select random(), random(), trunc(random()*100); -- trunc: get a number between 0 and 100
select repeat('Neon', 5); -- repeat
select generate_series(1,5); -- like range() in Python
select 'Neon' || generate_series(1,5); -- || concate

-- [ 'Neon' + str(x) for x in range(1,6) ] in Python

drop table textfun;
create table textfun(content text);

insert into textfun (content) select 'Neon' || generate_series(1,5);

select * from textfun;

delete from textfun;

-- BTree index is default
create index textfun_b on textfun(content);

select pg_relation_size('textfun'), pg_indexes_size('textfun'); -- how much data is allocated on disk for the relation itself, which is the rows? how much is in the all of the indexes?

select (case when (random() < 0.5)           -- case statement, like if-else
        then 'https://www.pg4e.com/neon/'
        else 'http://www.pg4e.com/LEMONS/'
        end) || generate_series(1000,1005);

insert into textfun(content)
select (case when (random() < 0.5)
        then 'https://www.pg4e.com/neon'
        else 'http://www.pg4e.com/LEMONS/'
        end) || generate_series(10000,20000);
        
select pg_relation_size('textfun'), pg_indexes_size('textfun');  -- the relations size correlates directly to the rows

select content from textfun where content like '%15000%';
-- https://www.pg4e.com/neon15000
select upper(content) from textfun where content like '%15000%';
-- HTTPS://WWW.PG4E.COM/NEON15000
select lower(content) from textfun where content like '%15000%';
-- https://www.pg4e.com/neon15000
select right(content, 4) from textfun where content like '%15000%';
-- 5000
select strpos(content, 'ttps://') from textfun where content like '%15000'; -- find the position of the string
-- 2
select substr(content, 2, 4) from textfun where content like '%15000%';
-- ttps
select split_part(content, '/', 4) from textfun where content like '%15000%';  -- break the string into pieces
-- neon15000
select translate(content, 'th.p/', 'TH!P_') from textfun where content like '%15000%';  -- one-to-one mapping
-- HTTPs:__www!Pg4e!com_neon15000

-- like-style wild cards
select content from textfun where content like '%15000%';
select content from textfun where content like '%15_00%';
select content from textfun where content in ('https://www.pg4e.com/neon/15000', 'https://www.pg4e.com/neon/15001');

drop table textfun;

-- Regex
create table em (id serial, primary key(id), email text);

insert into em(email) values('csev@umich.edu'), ('sally@uiuc.edu'), ('color@umich.edu'), ('bear22@umuc.edu'), ('john@apple.com'), ('ally@apple.com');

select * from em;

select email from em where email ~ 'umich';
select email from em where email ~ '^c';  -- start with 'c' in a line
select email from em where email ~ 'edu$';  -- end with 'edu'
select email from em where email ~ '^[abc]';  -- start with 'a', 'b', or 'c'
select email from em where email ~ '[0-9]';
select email from em where email ~ '[0-9][0-9]';

select substring(email from '[0-9]+') from em where email ~ '[0-9]';  -- '+' one or more of numbers

select substring(email from '.+@(.*)$') from em;  -- '.+' one or more any characters 

select distinct substring(email from '.+@(.*)$') from em;

select substring(email from '.+@(.*)$'),
    count(substring(email from '.+@(.*)$'))
from em group by substring(email from '.+@(.*)$');

select * from em where substring(email from '.+@(.*)$') = 'umich.edu';

create table tw (id serial, primary key(id), tweet text);

insert into tw(tweet) values('This is #SQL and #FUN stuff'), ('More people should learn #SQL from #UMSI'), ('#UMSI also teaches #PYTHON');

select tweet from tw;

select id, tweet from tw where tweet ~ '#SQL';

select regexp_matches(tweet, '#([A-Za-z0-9_]+)','g') from tw; 
select distinct regexp_matches(tweet, '#([A-Za-z0-9_]+)','g') from tw; 

select id, regexp_matches(tweet, '#([A-Za-z0-9_]+)','g') from tw; 

drop table mbox;
create table mbox(line TEXT);

\copy mbox from 'mbox-short.txt' with delimiter E'\007';
\copy mbox from 'wget -q -O - "$@" https://www.pg4e.com/lectures/mbox-short.txt' with delimiter E'\007';

select line from mbox where line ~ '^From';
-- From stephen.marquard@uct.ac.za Sat Jan  5 09:14:16 2008
select substring(line, '(.+@[^ ]+) ') from mbox where line ~ '^From ';
-- From stephen.marquard@uct.ac.za

select substring(line, '(.+@[^ ]+) '), count(substring(line, '(.+@[^ ]+) ')) from mbox where line ~ '^From'
group by substring(line, '(.+@[^ ]+) ')
order by count(substring(line, '(.+@[^ ]+) ')) desc;

select email, count(email) from (
  select substring(line, '(.+@[^ ]+) ') as email from mbox where line ~ '^From'
) as badsub  -- sub-select
group by email
order by count(email) desc;
