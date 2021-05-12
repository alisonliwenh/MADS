create table textfun (content TEXT);
-- create a b-tree index
create index textfun_b on textfun (content);

select * from textfun;

-- pg_relation_size says how much data is what's in this relation taking currently.
-- pg_indexes_size is how much size of indexes.
-- The whole idea of an index is you're trading off space for speed. Create indexes is to make the database fast, 
-- whether it's fast for inserts, deletes, updates, or reads.
select pg_relation_size('textfun'), pg_indexes_size('textfun');

insert into textfun (content)
select (case when (random() < 0.5)              -- Generate a set of rows which are going to inserted into the column of content of textfun.
        then 'https://www.pg4e.com/neon/'       -- Can't do if-then-else in sql because it's not a procedural language.
        else 'https://www.pg4e.com/LEMONS/'     -- from case to end generate one of two strings, neon and LEMONS strings
        end) || generate_series(100000,200000); -- Generate 100000 records
       
select pg_relation_size('textfun'), pg_indexes_size('textfun');

select content from textfun limit 5;

select content from textfun where content like '%150000%';

select upper(content) from textfun where content like '%150000%';

select right(content,4) from textfun where content like '%150000';

select strpos(content, 'ttps://') from textfun where content like'%150000';

select substr(content, 2, 4) from textfun where content like'%150000';

select split_part(content, '/', 4) from textfun where content like'%150000';

select translate(content, 'th.p/','TH!P_') from textfun where content like'%150000';

-- B-Tree index performance

-- Index only scan using textfun_b on textfun
explain analyze select content from textfun where content like 'racing%'; -- fast scorchingly

explain analyze select content from textfun where content like '%racing%'; -- slower
-- avoid sequential scan
explain analyze select content from textfun where content ilike 'racing%'; -- ilike is to ignore the case -- get the data, change its case, then do the searching. -- slowest
-- avoid sequential scan

explain analyze select content from textfun where content like '%150000%' limit 1; -- Ask postgresql to scan the data, if it encounters it, then it can stop. Because we know that there's only one 150000 row

-- IN clause
explain analyze select content from textfun where content in ('http://www.pg4e/neon/150000', 'https://www.pg4e.com/neon/150000');

explain analyze select content from textfun where content in (select content from textfun where content like '%150000%');
-- The inside part is doing the sequential scan. It slows down the speed even though the outside part is fast.
-- Not using sub query

-- Character sets
-- Don't cut and paste code or text from PDFs
select ascii('H'), ascii('e'), ascii('l'), chr(72), chr(12);

-- Unicode
select chr(20013);

select char_length('学习管理'), octet_length('学习管理'), bit_length('学习管理'), ascii('学');
-- 4 character; 12 bytes to store four characters; 96 bits=12*8; 23398 unicode#

show server_encoding;

-- Index choices and index techniques
create table cr2 (id SERIAL, url text, content text); -- no index -- slowest

-- To compute the MD5 hash function of the url
create unique index cr2_md5 on cr2 (md5(url)); -- MD5 index on url -- fast

-- the size of indexes is much smaller
select pg_relation_size('cr2'), pg_indexes_size('cr2');

explain select * from cr2 where url='lemons';

explain select * from cr2 where md5(url)=md5('lemons');

explain analyze select * from cr2 where md5(url)=md5('lemons');

explain analyze select * from cr2 where url='lemons';

-- Hashing with a separate column
create table cr3(id serial, url text, url_md5 uuid unique, content text); -- Separate column -- fastest
-- uuid is a datatype

insert into cr3(url) select repeat('Neon', 1000) || generate_series(1,5000);

update cr3 set url_md5=md5(url)::uuid;


select pg_relation_size('cr3'), pg_indexes_size('cr3');

explain analyze select * from cr3 where url_md5=md5('lemons')::uuid;

-- Demo
select line from mbox where line ~ 'From';

select substring(line, '(.+@[^ ]+)') from mbox where line ~ 'From';

select substring(line, '(.+@[^ ]+)'), count(substring(line, '(.+@[^ ]+)'))
from mbox where line ~ 'From'
group by substring(line, '(.+@[^ ]+)')
order by substring(line, '(.+@[^ ]+)') desc;

select email, count(email) from 
(select substring(line, '(.+@[^ ]+)') as email
 from mbox where line ~ 'From'
) as badsub
group by email order by count(email) desc;
