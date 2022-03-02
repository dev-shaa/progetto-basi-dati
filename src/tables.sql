-- crea un enum per la lingua del riferimento
create type language_enum as enum('ENGLISH', 'ITALIAN', 'FRENCH', 'GERMAN', 'SPANISH', 'RUSSIAN', 'JAPANESE', 'CHINESE', 'ARAB');

-- crea un enum per i tipi di linguaggi di programmazione
create type programming_language_enum as enum('C', 'CSHARP', 'JAVA', 'PYTHON', 'LUA', 'FORTRAN', 'OTHER');

-- crea un nuovo tipo di intero maggiore positivo (o nullo)
create domain positive_integer as integer check(value is null or value > 0) default null;

-----------------------------------------------------------------------------------------------------------------
-- crea la tabella USER_APP
create table user_app(
    name varchar(128) primary key,
    password varchar(64) not null
);

-- il nome di un utente non deve essere vuoto
alter table user_app
    add constraint no_empty_user_name check(name <> '');

-- la password di un utente non deve essere vuoto
alter table user_app
    add constraint no_empty_user_password check(password <> '');

-----------------------------------------------------------------------------------------------------------------
-- crea la tabella BIBLIOGRAPHIC_REFERENCE
create table bibliographic_reference(
    id serial primary key,
    owner varchar(128) not null,
    title varchar(256) not null,
    doi varchar,
    description varchar(1024),
    language language_enum,
    pubblication_date date
);

-- il titolo di un riferimento non deve essere vuoto
alter table bibliographic_reference
    add constraint no_empty_reference_title check(title <> '');

-- controlla se il doi è valido, secondo lo standard indicato
-- https://www.doi.org/doi_handbook/2_Numbering.html#2.6.1
-- esempio: 10.1000/182.182
alter table bibliographic_reference
    add constraint valid_doi check (doi is null or doi ~ '^10\.[0-9]{4,}\/\w{1,}(\.\w{1,})*$')

-- crea il vincolo di foreign key per l'utente proprietario del riferimento
alter table bibliographic_reference
    add constraint reference_owner_fk foreign key (owner) references user_app(name) on update cascade on delete cascade;

-- il titolo di un riferimento deve essere univoco
-- siccome ogni utente ha accesso solo ai propri riferimenti, possono esserci più riferimenti con lo stesso titolo ma appartenenti a utenti diversi
create unique index unique_reference_per_user on bibliographic_reference(owner, lower(title));

-- il doi di un riferimento deve essere univoco
-- siccome ogni utente ha accesso solo ai propri riferimenti, possono esserci più riferimenti con lo stesso doi ma appartenenti a utenti diversi
alter table bibliographic_reference
    add constraint unique_doi_per_user unique(owner, doi);

-----------------------------------------------------------------------------------------------------------------
-- crea la tabella ARTICLE
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
    add constraint valid_issn check (issn is null or issn ~ '[0-9]{4}-[0-9]{3}[0-9xX]');

-----------------------------------------------------------------------------------------------------------------
-- crea la tabella BOOK
create table book(
    id integer not null unique,
    page_count positive_integer,
    url varchar(256),
    publisher varchar(128),
    isbn varchar(13)
);

-- crea il vincolo di foreign key per bibliographic_reference
alter table book
    add constraint book_id_fk foreign key (id) references bibliographic_reference(id) on update cascade on delete cascade;

-----------------------------------------------------------------------------------------------------------------
-- crea la tabella THESIS
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

-----------------------------------------------------------------------------------------------------------------
-- crea la tabella WEBSITE
create table website(
    id integer not null unique,
    url varchar(256) not null
);

-- crea il vincolo di foreign key per bibliographic_reference
alter table website
    add constraint website_id_fk foreign key (id) references bibliographic_reference(id) on update cascade on delete cascade;

-- l'url non può essere vuoto
alter table website
    add constraint no_empty_website_url check(url <> '');

-----------------------------------------------------------------------------------------------------------------
-- crea la tabella SOURCE_CODE
create table source_code(
    id integer not null unique,
    url varchar(256) not null,
    programming_language programming_language_enum
);

-- crea il vincolo di foreign key per bibliographic_reference
alter table source_code
    add constraint source_code_id_fk foreign key (id) references bibliographic_reference(id) on update cascade on delete cascade;

-- l'url non può essere vuoto
alter table source_code
    add constraint no_empty_source_code_url check(url <> '');

-----------------------------------------------------------------------------------------------------------------
-- crea la tabella VIDEO
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

-- l'url non può essere vuoto
alter table video
    add constraint no_empty_video_url check(url <> '');

-----------------------------------------------------------------------------------------------------------------
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

-- l'url non può essere vuoto
alter table image
    add constraint no_empty_image_url check(url <> '');

-----------------------------------------------------------------------------------------------------------------
-- crea la tabella QUOTATIONS
create table quotations(
    quoted_by integer not null,
    quotes integer not null
);

-- crea il vincolo di foreign key per il riferimento che cita
alter table quotations
    add constraint quoted_by_fk foreign key (quoted_by) references bibliographic_reference(id) on update cascade on delete cascade;

-- crea il vincolo di foreign key per il riferimento citato
alter table quotations
    add constraint quotes_fk foreign key (quotes) references bibliographic_reference(id) on update cascade on delete cascade;

-- un riferimento non può citare sè stesso
alter table quotations
    add constraint no_self_quotation check(quoted_by <> quotes);

-- un riferimento può citarne un altro solo una volta
alter table quotations
    add constraint unique_quotation unique(quoted_by, quotes);

-----------------------------------------------------------------------------------------------------------------
-- crea la tabella AUTHOR
create table author(
    id serial primary key,
    name varchar(256) not null,
    orcid char(20)
);

-- il nome dell'autore non può essere vuoto
alter table author
    add constraint no_empty_author_name check(name <> '');

-- un codice orcid è composto da 16 cifre separate a gruppi di 4 da un trattino
-- l'ultima cifra può essere sostituita da una x
alter table author
    add constraint valid_orcid check (orcid is null or orcid ~ '[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9xX]');

-- l'orcid è univoco
alter table author
    add constraint unique_orcid unique(orcid);

-- possono esserci autori omonimi, ma l'orcid deve essere diverso per ognuno
-- non possiamo usare un vincolo unique composito perchè postgresql non considera i valori null,
-- quindi sarebbero possibili due autori con lo stesso nome senza orcid
-- nota: la capitalizzazione del nome non è importante
create unique index unique_author on author(lower(name), (orcid is null)) where orcid is null;

-----------------------------------------------------------------------------------------------------------------
-- crea la tabella AUTHOR_REFERENCE_ASSOCIATION
create table authorship(
    reference integer not null,
    author integer not null
);

-- crea il vincolo di foreign key per il riferimento
alter table authorship
    add constraint reference_fk foreign key (reference) references bibliographic_reference(id) on update cascade on delete cascade;

-- crea il vincolo di foreign key per l'autore
alter table authorship
    add constraint author_fk foreign key (author) references author(id) on update cascade on delete cascade;

-- un riferimento può essere associato a un autore una sola volta
alter table authorship
    add constraint unique_author_reference_association unique(reference, author);

-----------------------------------------------------------------------------------------------------------------
-- crea la tabella TAG
create table tag(
    name varchar(128) not null,
    reference integer not null
);

-- il nome del tag non può essere vuoto
alter table tag
    add constraint no_empty_tag_name check(name <> '');

-- crea il vincolo di foreign key per il riferimento a cui è associata la parola chiave
alter table tag
    add constraint reference_fk foreign key (reference) references bibliographic_reference(id) on update cascade on delete cascade;

-- una parola chiave può essere associata a un riferimento una sola volta (anche se capitalizzato in maniera diversa)
create unique index unique_tag_per_reference on tag(lower(name), reference);

-----------------------------------------------------------------------------------------------------------------
-- crea la tabella CATEGORY
create table category(
    id serial primary key,
    name varchar(64) not null,
    parent integer,
    owner varchar(128) not null
);

-- il nome della categoria non può essere vuoto
alter table category
    add constraint no_empty_category_name check(name <> '');

-- crea il vincolo di foreign key per la categoria padre della categoria
alter table category
    add constraint parent_fk foreign key (parent) references category(id) on update cascade on delete cascade;

-- crea il vincolo di foreign key per il proprietario della categoria
alter table category
    add constraint owner_fk foreign key (owner) references user_app(name) on update cascade on delete cascade;

-- per l'implementazione del vincolo "no same name in directory" servono due indici di unicità
-- non sono possibili due categorie con lo stesso nome e lo stesso genitore
create unique index unique_name_with_parent on category(lower(name), parent);

-- serve un altro indice per controllare le categorie senza genitore, perchè postgresql non considera i valori null e sarebbero possibili due categorie con lo stesso nome
-- siccome possono esistere due categorie con lo stesso nome senza genitore, ma devono appartenere a due utenti diversi, è necessario specificare anche il proprietario
-- con l'indice precedente non è necessario perchè per un vincolo successivo le categorie e le sottocategorie devono avere lo stesso proprietario (vedi subcategory_same_owner)
create unique index unique_name_with_no_parent on category(lower(name), (parent is null), owner) where parent is null;

-----------------------------------------------------------------------------------------------------------------
-- crea la tabella REFERENCE_GROUPING
create table reference_grouping(
    category integer not null,
    reference integer not null
);

-- crea il vincolo di foreign key per la categoria
alter table reference_grouping
    add constraint category_fk foreign key (category) references category(id) on update cascade on delete cascade;

-- crea il vincolo di foreign key per il riferimento
alter table reference_grouping
    add constraint reference_fk foreign key (reference) references bibliographic_reference(id) on update cascade on delete cascade;

-- un riferimento può essere associato a una categoria una sola volta
alter table reference_grouping
    add constraint unique_reference_per_category unique(category, reference);