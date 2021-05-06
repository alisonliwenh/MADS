  id serial,
  name varchar(128) unique,
  primary key (id)
);

create table model (
  id serial,
  name VARCHAR(128),
  make_id INTEGER references make(id) on delete cascade,
  primary key(id)
);

insert into make (name) values ('Chevrolet')

insert into make (name) values ('Subaru')

insert into model (name, make_id) values ('Silverado 4WD', 1)

insert into model (name, make_id) values ('Silverado 4WD TrailBoss', 1)

insert into model (name, make_id) values ('Silverado C10 2WD', 1)

insert into model (name, make_id) values ('SVX', 2)

insert into model (name, make_id) values ('SVX AWD', 2)
