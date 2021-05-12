-- Puzzle: break a hashing function
-- ABCDE & BACDF

-- Regular expressions
select purpose from taxdata where purpose ~ '[?]$';

-- Generating text
create table bigtext(content text);

insert into bigtext(content)
select ('This is record number ') || generate_series(100000, 199999) || ('of quite a few text records.');

select * from bigtext limit 10;

drop table bigtext;
