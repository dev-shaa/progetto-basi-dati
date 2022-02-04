create type language_enum as enum(
    'ENGLISH',
    'ITALIAN',
    'FRENCH',
    'GERMAN',
    'SPANISH',
    'RUSSIAN',
    'JAPANESE',
    'CHINESE',
    'ARAB'
);

create type programming_language_enum as enum(
    'C',
    'CSHARP',
    'JAVA',
    'PYTHON',
    'LUA',
    'FORTRAN',
    'OTHER'
);

create domain positive_nullable_integer as integer check(
    value is null
    or value > 0
);

create table user_app(
    name varchar(128) primary key,
    password varchar(64) not null
);

create table bibliographic_reference(
    id serial primary key,
    owner varchar(64) not null references user_app(name) 
        on update cascade on delete cascade,
    title varchar(256) not null,
    DOI varchar(128),
    description varchar(1024),
    language language_enum,
    pubblication_date date
);

alter table bibliographic_reference
    add constraint unique_reference_per_user unique(owner, title);

-- FIXME: dovrebbe ammettere più valori null
alter table bibliographic_reference
    add constraint unique_doi_per_user unique(owner, doi);

create table article(
    id integer not null unique references bibliographic_reference(id) 
        on update cascade on delete cascade,
    page_count positive_nullable_integer,
    url varchar(256),
    publisher varchar(128),
    issn char(9)
);

-- un codice ISSN è composta da 4 cifre, un trattino, tre cifre e infine una cifra o una x
alter table article
    add constraint issn_pattern_check check (issn is null or issn ~ '^[0-9]{4}-[0-9]{3}[0-9xX]$');

create table book(
    id integer not null unique references bibliographic_reference(id)
        on update cascade on delete cascade,
    page_count positive_nullable_integer,
    url varchar(256),
    publisher varchar(128),
    isbn char(13)
);

create table thesis(
    id integer not null unique references bibliographic_reference(id)
        on update cascade on delete cascade,
    page_count positive_nullable_integer,
    url varchar(256),
    publisher varchar(128),
    university varchar(128),
    faculty varchar(128)
);

create table website(
    id integer not null unique references bibliographic_reference(id)
        on update cascade on delete cascade,
    url varchar(128) not null
);

create table source_code(
    id integer not null unique references bibliographic_reference(id)
        on update cascade on delete cascade,
    url varchar(128) not null,
    code_language programming_language_enum
);

create table video(
    id integer not null unique references bibliographic_reference(id)
        on update cascade on delete cascade,
    url varchar(128) not null,
    width positive_nullable_integer,
    height positive_nullable_integer,
    frameRate positive_nullable_integer,
    duration positive_nullable_integer
);

create table image(
    id integer not null unique references bibliographic_reference(id)
        on update cascade on delete cascade,
    url varchar(128) not null,
    width positive_nullable_integer,
    height positive_nullable_integer
);

create table quotations(
    quoted_by integer not null references bibliographic_reference(id)
        on update cascade on delete cascade,
    has_quoted integer not null references bibliographic_reference(id)
        on update cascade on delete cascade
);

create table author(
    name varchar(256),
    orcid char(20)
);

create table author_reference_associations(
    reference integer references bibliographic_reference(id)
        on update cascade on delete cascade,
    -- TODO: author foreign key
);

create table tag(
    name varchar(128) primary key
);

create table reference_tag_associations(
    reference integer not null references bibliographic_reference(id)
        on update cascade on delete cascade,
    tag varchar(128) not null references tag(name)
        on update cascade on delete cascade
);

create table category(
    id serial primary key,
    name varchar(64) not null,
    parent integer default null references category(id)
        on update cascade on delete cascade,
    owner varchar(128) not null references user_app(name)
        on update cascade on delete cascade,
    unique(owner, name, parent) -- non sono possibili due categorie con lo stesso nome e lo stesso genitore
);

create table category_reference_association(
    category integer not null references category(id)
        on update cascade on delete cascade,
    reference integer not null references bibliographic_reference(id)
        on update cascade on delete cascade,
    unique(category, reference)
);