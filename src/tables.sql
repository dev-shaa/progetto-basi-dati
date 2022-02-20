-- crea un enum per la lingua del riferimento
create type language_enum as enum('ENGLISH', 'ITALIAN', 'FRENCH', 'GERMAN', 'SPANISH', 'RUSSIAN', 'JAPANESE', 'CHINESE', 'ARAB');

-- crea un enum per i tipi di linguaggi di programmazione
create type programming_language_enum as enum('C', 'CSHARP', 'JAVA', 'PYTHON', 'LUA', 'FORTRAN', 'OTHER');

-- crea un nuovo tipo di intero maggiore positivo (o nullo)
create domain positive_integer as integer check(value is null or value > 0) default null;

---------------------------------------------------
-- crea la tabella USER_APP
---------------------------------------------------
create table user_app(
    name varchar(128) primary key,
    password varchar(64) not null
);

---------------------------------------------------
-- crea la tabella BIBLIOGRAPHIC_REFERENCE
---------------------------------------------------
create table bibliographic_reference(
    id serial primary key,
    owner varchar(128) not null,
    title varchar(256) not null,
    doi varchar(128),
    description varchar(1024),
    language language_enum,
    pubblication_date date
);

-- crea il vincolo di foreign key per l'utente proprietario del riferimento
alter table bibliographic_reference
    add constraint reference_owner_fk foreign key (owner) references user_app(name) on update cascade on delete cascade;

-- il titolo di un riferimento deve essere univoco
-- siccome ogni utente ha accesso solo ai propri riferimenti, possono esserci più riferimenti con lo stesso titolo ma appartenenti a utenti diversi
alter table bibliographic_reference
    add constraint unique_reference_per_user unique(owner, title);

-- il doi di un riferimento deve essere univoco
-- siccome ogni utente ha accesso solo ai propri riferimenti, possono esserci più riferimenti con lo stesso doi ma appartenenti a utenti diversi
alter table bibliographic_reference
    add constraint unique_doi_per_user unique(owner, doi);

---------------------------------------------------
-- crea la tabella ARTICLE
---------------------------------------------------
create table article(
    id integer not null unique,
    page_count positive_integer,
    url varchar(256),
    publisher varchar(128),
    issn char(9)
);

-- crea il vincolo di foreign key per bibliographic_reference
alter table article
    add constraint article_id_fk foreign key (id) references bibliographic_reference(id) on update cascade on delete cascade;

-- un codice ISSN è composto da quattro cifre, un trattino, tre cifre e infine una cifra o una x
alter table article
    add constraint issn_pattern_check check (issn is null or issn ~ '^[0-9]{4}-[0-9]{3}[0-9xX]$');

---------------------------------------------------
-- crea la tabella BOOK
---------------------------------------------------
create table book(
    id integer not null unique,
    page_count positive_integer,
    url varchar(256),
    publisher varchar(128),
    isbn char(13)
);

-- crea il vincolo di foreign key per bibliographic_reference
alter table book
    add constraint book_id_fk foreign key (id) references bibliographic_reference(id) on update cascade on delete cascade;

-- TODO: isbn pattern

---------------------------------------------------
-- crea la tabella THESIS
---------------------------------------------------
create table thesis(
    id integer not null unique,
    page_count positive_integer,
    url varchar(256),
    publisher varchar(128),
    university varchar(128),
    faculty varchar(128)
);

-- crea il vincolo di foreign key per bibliographic_reference
alter table thesis
    add constraint thesis_id_fk foreign key (id) references bibliographic_reference(id) on update cascade on delete cascade;

---------------------------------------------------
-- crea la tabella WEBSITE
---------------------------------------------------
create table website(
    id integer not null unique,
    url varchar(256) not null
);

-- crea il vincolo di foreign key per bibliographic_reference
alter table website
    add constraint website_id_fk foreign key (id) references bibliographic_reference(id) on update cascade on delete cascade;

---------------------------------------------------
-- crea la tabella SOURCE_CODE
---------------------------------------------------
create table source_code(
    id integer not null unique,
    url varchar(256) not null,
    programming_language programming_language_enum
);

-- crea il vincolo di foreign key per bibliographic_reference
alter table source_code
    add constraint source_code_id_fk foreign key (id) references bibliographic_reference(id) on update cascade on delete cascade;

---------------------------------------------------
-- crea la tabella VIDEO
---------------------------------------------------
create table video(
    id integer not null unique,
    url varchar(256) not null,
    width positive_integer,
    height positive_integer,
    framerate positive_integer,
    duration positive_integer
);

-- crea il vincolo di foreign key per bibliographic_reference
alter table video
    add constraint video_id_fk foreign key (id) references bibliographic_reference(id) on update cascade on delete cascade;

-- crea la tabella IMAGE
create table image(
    id integer not null unique,
    url varchar(256) not null,
    width positive_integer,
    height positive_integer
);

-- crea il vincolo di foreign key per bibliographic_reference
alter table image
    add constraint image_id_fk foreign key (id) references bibliographic_reference(id) on update cascade on delete cascade;

---------------------------------------------------
-- crea la tabella RELATED_REFERENCES
---------------------------------------------------
create table related_references(
    quoted_by integer not null,
    quotes integer not null
);

-- crea il vincolo di foreign key per il riferimento che cita
alter table related_references
    add constraint quoted_by_fk foreign key (quoted_by) references bibliographic_reference(id) on update cascade on delete cascade;

-- crea il vincolo di foreign key per il riferimento citato
alter table related_references
    add constraint quotes_fk foreign key (quotes) references bibliographic_reference(id) on update cascade on delete cascade;

-- un riferimento non può citare sè stesso
alter table related_references
    add constraint no_self_quotation check(quoted_by <> quotes);

-- un riferimento può citarne un altro solo una volta
alter table related_references
    add constraint unique_quotation unique(quoted_by, quotes);

-----------------------------------------------------------------------------------------------------------------
-- crea tabella AUTHOR
create table author(
    id serial primary key,
    name varchar(256) not null,
    orcid char(20)
);

-- un codice orcid è composto da 16 cifre separate a gruppi di 4 da un trattino
-- l'ultima cifra può essere sostituita da una x
alter table author
    add constraint orcid_pattern_check check (orcid is null or orcid ~ '^[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9xX]$');

-- l'orcid è univoco
alter table author
    add constraint unique_orcid unique(orcid);

-- possono esserci autori omonimi, ma l'orcid deve essere diverso per ognuno
-- non possiamo usare un vincolo unique composito perchè postgresql non considera i valori null,
-- quindi sarebbero possibili due autori con lo stesso nome senza orcid
create unique index unique_author on author(name, (orcid is null)) where orcid is null;

-----------------------------------------------------------------------------------------------------------------
-- crea tabella AUTHOR_REFERENCE_ASSOCIATION
create table author_reference_association(
    reference integer not null,
    author integer not null
);

-- crea il vincolo di foreign key per il riferimento
alter table author_reference_association
    add constraint reference_fk foreign key (reference) references bibliographic_reference(id) on update cascade on delete cascade;

-- crea il vincolo di foreign key per l'autore
alter table author_reference_association
    add constraint author_fk foreign key (author) references author(id) on update cascade on delete cascade;

-- un riferimento può essere associato a un autore una sola volta
alter table author_reference_association
    add constraint unique_author_reference unique(reference, author);

-----------------------------------------------------------------------------------------------------------------
-- crea tabella TAG
create table tag(
    name varchar(128) not null,
    reference integer not null
);

-- crea il vincolo di foreign key per il riferimento a cui è associata la parola chiave
alter table tag
    add constraint reference_fk foreign key (reference) references bibliographic_reference(id) on update cascade on delete cascade;

-- una parola chiave può essere associata a un riferimento una sola volta
alter table tag
    add constraint unique_tag_reference unique(name, reference);

-----------------------------------------------------------------------------------------------------------------
-- crea tabella CATEGORY
create table category(
    id serial primary key,
    name varchar(64) not null,
    parent integer,
    owner varchar(128) not null
);

-- crea il vincolo di foreign key per la categoria padre della categoria
alter table category
    add constraint parent_fk foreign key (parent) references category(id) on update cascade on delete cascade;

-- crea il vincolo di foreign key per il proprietario della categoria
alter table category
    add constraint owner_fk foreign key (owner) references user_app(name) on update cascade on delete cascade;

-- non sono possibili due categorie con lo stesso nome e lo stesso genitore
alter table category
    add constraint unique_name_with_parent unique(name, parent);

-- oltre al vincolo unique è necessario anche creare un indice, perchè postgresql non considera i valori null e sarebbero possibili due categorie senza genitore che hanno lo stesso nome
-- è necessario specificare anche il proprietario della categoria, perchè possono esistere due categorie con lo stesso nome senza genitore ma che appartengono a due utenti diversi
-- con il vincolo unique precedente non è necessario siccome, per un vincolo successivo (vedi subcategory_same_owner), le categorie e le sottocategorie devono avere lo stesso prorietario
-- quindi già si sa a chi appartengono
create unique index unique_name_with_no_parent on category(name, (parent is null), owner) where parent is null;

-----------------------------------------------------------------------------------------------------------------
-- crea tabella CATEGORY_REFERENCE_ASSOCIATION
create table category_reference_association(
    category integer not null,
    reference integer not null
);

-- crea il vincolo di foreign key per la categoria
alter table category_reference_association
    add constraint category_fk foreign key (category) references category(id) on update cascade on delete cascade;

-- crea il vincolo di foreign key per il riferimento
alter table category_reference_association
    add constraint reference_fk foreign key (reference) references bibliographic_reference(id) on update cascade on delete cascade;

-- un riferimento può essere associato a una categoria una sola volta
alter table category_reference_association
    add constraint unique_reference unique(category, reference);