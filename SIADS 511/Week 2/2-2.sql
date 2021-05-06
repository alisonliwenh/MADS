create table student (
  id serial, 
  name VARCHAR(128) unique,
  primary key(id)
);

drop table course cascade;
create table course(
  id serial,
  title VARCHAR(128) unique,
  primary key(id)
);

drop table roster cascade;
create table roster (
  id serial, 
  student_id INTEGER references student(id) on delete cascade,
  course_id INTEGER references course(id) on delete cascade,
  role INTEGER,
  UNIQUE(student_id, course_id),
  primary key(id)
);

insert into student (name) values ('Jasmine');

insert into student (name) values ('Charles');

insert into student (name) values ('Errin');

insert into student (name) values ('Karla');

insert into student (name) values ('Sydnee');

insert into student (name) values ('Carol');

insert into student (name) values ('Eila');

insert into student (name) values ('Haghdann');

insert into student (name) values ('Jayla');

insert into student (name) values ('Olurotimi');

insert into student (name) values ('Kjae');

insert into student (name) values ('Arzoo');

insert into student (name) values ('Kallen');

insert into student (name) values ('Kodi');

insert into student (name) values ('Torquil');

select * from student;

insert into course (title) values ('si106'),('si110'),('si206');

select * from course;

insert into roster (student_id, course_id, role) values (1, 1, 1),(2,1,0),(3,1,0),(4,1,0),(5,1,0),(6,2,1),(7,2,0),(8,2,0),(9,2,0),(10,2,0),(11,3,1),(12,3,0),(13,3,0),(14,3,0),(15,3,0);

select * from roster;

SELECT student.name, course.title, roster.role
    FROM student 
    JOIN roster ON student.id = roster.student_id
    JOIN course ON roster.course_id = course.id
    ORDER BY course.title, roster.role DESC, student.name;
