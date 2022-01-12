-- USER TABLE
create table user(
  name varchar(64) primary key,
  password varchar(64) not null
);
--
-- REFERENCES
create type language_enum as enum('English', 'Italian', 'French', 'German');
create type programming_language_enum as enum('C/C++', 'C#', 'Java', 'Python');
create domain positive_nullable_integer as integer check(
  value is null
  or value > 0
);
create table bibliographic_reference(
  id serial primary key,
  owner varchar(64) not null references user(name) on update cascade on delete cascade,
  title varchar(128) not null,
  DOI varchar,
  description varchar(1024),
  language language_enum,
  pubblication_date date,
  unique(owner, title),
  unique(owner, DOI)
);
create table article(
  id integer not null references bibliographic_reference(id) on update cascade on delete cascade,
  page_count positive_nullable_integer,
  url varchar default null,
  publisher varchar,
  -- un codice ISSN è composta da 4 cifre, un trattino, tre cifre e infine una cifra o una x
  ISSN char(9) check (
    ISSN is null
    or ISSN ~ '^[0-9]{4}-[0-9]{3}[0-9xX]$'
  )
);
create table book(
  id integer not null references bibliographic_reference(id) on update cascade on delete cascade,
  page_count positive_nullable_integer,
  url varchar default null,
  publisher varchar default null,
  ISBN char(13) default null,
);
create table thesis(
  id integer not null references bibliographic_reference(id) on update cascade on delete cascade,
  page_count positive_nullable_integer,
  url varchar default null,
  publisher varchar default null,
  university varchar default null,
  faculty varchar default null,
);
create table website(
  id integer not null references bibliographic_reference(id) on update cascade on delete cascade,
  url varchar not null,
);
create table source_code(
  id integer not null references bibliographic_reference(id) on update cascade on delete cascade,
  url varchar not null,
  code_language programming_language_enum default null
);
create table video(
  id integer not null references bibliographic_reference(id) on update cascade on delete cascade,
  url varchar not null,
  width positive_nullable_integer,
  height positive_nullable_integer,
  frameRate positive_nullable_integer,
  duration positive_nullable_integer,
);
create table quotations(
  quoted_by integer not null references bibliographic_reference(id) on update cascade on delete cascade,
  has_quoted integer not null references bibliographic_reference(id) on update cascade on delete cascade
);
--
-- AUTHOR
create table author(
  first_name varchar,
  last_name varchar,
  orcid char(20)
);
create table author_reference_associations(
  reference integer not null references bibliographic_reference(id) on update cascade on delete cascade,
  -- TODO: foreign key autore
);
--
-- TAGS
create table tag(name varchar primary_key);
create table reference_tag_associations(
  reference integer not null references bibliographic_reference(id) on update cascade on delete cascade,
  tag varchar not null references tag(name) on update cascade on delete cascade
);
--
-- CATEGORY
create table category(
  id serial primary key,
  name varchar(64) not null,
  parent integer default null references category(id),
  owner varchar(64) not null references user(name),
  unique(owner, name, parent) -- non sono possibili due categorie con lo stesso nome e lo stesso genitore
);
create table category_reference_association(
  category integer not null references category(id),
  reference integer not null references bibliographicReference(id)
);