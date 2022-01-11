create type language_enum as enum('English', 'Italian', 'French', 'German');
create table bibliographic_reference(
  id serial primary key,
  owner varchar(64) not null references user(name) on update cascade on delete cascade,
  title varchar(128) not null,
  -- TODO: check DOI
  DOI varchar default null,
  description varchar(1024) default null,
  language language_enum default null,
  pubblication_date date default null,
  unique(owner, title),
  unique(owner, DOI)
);
create table article(
  id integer not null references bibliographic_reference(id) on update cascade on delete cascade,
  page_count integer,
  url varchar,
  publisher varchar,
  ISSN varchar
);
create table book(
  id integer not null references bibliographic_reference(id) on update cascade on delete cascade,
  page_count integer,
  url varchar,
  publisher varchar,
  ISBN varchar(13),
);
create table thesis(
  id integer not null references bibliographic_reference(id) on update cascade on delete cascade,
  page_count integer,
  url varchar,
  publisher varchar,
  university varchar,
  faculty varchar,
);
create table website(
  id integer not null references bibliographic_reference(id) on update cascade on delete cascade,
  url varchar not null,
);
create table video(
  id integer not null references bibliographic_reference(id) on update cascade on delete cascade,
  owner varchar not null,
  title varchar not null,
  url varchar not null,
  width integer,
  height integer,
  frameRate integer,
  duration float
);
create table tag(name varchar primary_key);
create table reference_tag_associations(
  reference integer not null references bibliographic_reference(id) on update cascade on delete cascade,
  tag varchar not null references tag(name) on update cascade on delete cascade
);
create table quotations(
  quoted_by integer not null references bibliographic_reference(id) on update cascade on delete cascade,
  has_quoted integer not null references bibliographic_reference(id) on update cascade on delete cascade
);