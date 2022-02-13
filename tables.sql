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

-- un intero maggiore di 0 (o nullo)
create domain positive_integer as integer check(value is null or value > 0) default null;

create table user_app(
    name varchar(128) primary key,
    password varchar(64) not null
);

-- crea la tabella bibliographic_reference
create table bibliographic_reference(
    id serial primary key,
    owner varchar(64) not null,
    title varchar(256) not null,
    DOI varchar(128),
    description varchar(1024),
    language language_enum,
    pubblication_date date
);

-- foreign key
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

-- crea la tabella article
create table article(
    id integer not null unique,
    page_count positive_integer,
    url varchar(256),
    publisher varchar(128),
    issn char(9)
);

-- foreign key
alter table article
    add constraint article_id_fk foreign key (id) references bibliographic_reference(id) on update cascade on delete cascade;

-- un codice ISSN è composto da 4 cifre, un trattino, tre cifre e infine una cifra o una x (minuscola o maiuscola)
alter table article
    add constraint issn_pattern_check check (issn is null or issn ~ '^[0-9]{4}-[0-9]{3}[0-9xX]$');

-- crea la tabella book
create table book(
    id integer not null unique,
    page_count positive_integer,
    url varchar(256),
    publisher varchar(128),
    isbn char(13)
);

-- foreign key
alter table book
    add constraint book_id_fk foreign key (id) references bibliographic_reference(id) on update cascade on delete cascade;

-- crea la tabella thesis
create table thesis(
    id integer not null unique,
    page_count positive_integer,
    url varchar(256),
    publisher varchar(128),
    university varchar(128),
    faculty varchar(128)
);

-- foreign key
alter table thesis
    add constraint thesis_id_fk foreign key (id) references bibliographic_reference(id) on update cascade on delete cascade;

-- crea la tabella website
create table website(
    id integer not null unique,
    url varchar(256) not null
);

-- foreign key
alter table website
    add constraint website_id_fk foreign key (id) references bibliographic_reference(id) on update cascade on delete cascade;

-- crea la tabella source_code
create table source_code(
    id integer not null unique,
    url varchar(256) not null,
    programming_language programming_language_enum
);

-- foreign key
alter table source_code
    add constraint source_code_id_fk foreign key (id) references bibliographic_reference(id) on update cascade on delete cascade;

-- crea la tabella video
create table video(
    id integer not null unique,
    url varchar(256) not null,
    width positive_integer,
    height positive_integer,
    framerate positive_integer,
    duration positive_integer
);

-- foreign key
alter table video
    add constraint video_id_fk foreign key (id) references bibliographic_reference(id) on update cascade on delete cascade;

-- crea la tabella image
create table image(
    id integer not null unique,
    url varchar(256) not null,
    width positive_integer,
    height positive_integer
);

-- foreign key
alter table image
    add constraint image_id_fk foreign key (id) references bibliographic_reference(id) on update cascade on delete cascade;

-- implementazione vincolo di disgiunzione tra sottoclassi di bibliographic_reference

-- creazione vista comprendente tutti gli id usati come foreign key
-- TODO: commenta
create view id_collection as (
  select id from "thesis"
  union
  select id from "book"
  union
  select id from "article"
  union
  select id from "video"
  union
  select id from "image"
  union
  select id from "source_code"
  union
  select id from "website"
);

-- TODO: commenta
create or replace function disjoint_total_subreference() returns trigger as $$
begin
    if (tg_op = 'INSERT' or (tg_op = 'UPDATE' and new.id <> old.id)) and new.id in (select id from id_collection) then
        raise exception 'there is another reference subclass associated with this reference';
    end if;

    return new;
end;
$$ language plpgsql;

-- aggiungi trigger alla tabella article
create trigger disjoint_article_trigger before insert or update on article for each row
    execute procedure disjoint_total_subreference();

-- aggiungi trigger alla tabella book
create trigger disjoint_book_trigger before insert or update on book for each row
    execute procedure disjoint_total_subreference();

-- aggiungi trigger alla tabella thesis
create trigger disjoint_thesis_trigger before insert or update on thesis for each row
    execute procedure disjoint_total_subreference();

-- aggiungi trigger alla tabella website
create trigger disjoint_website_trigger before insert or update on website for each row
    execute procedure disjoint_total_subreference();

-- aggiungi trigger alla tabella image
create trigger disjoint_image_trigger before insert or update on image for each row
    execute procedure disjoint_total_subreference();

-- aggiungi trigger alla tabella video
create trigger disjoint_video_trigger before insert or update on video for each row
    execute procedure disjoint_total_subreference();

-- aggiungi trigger alla tabella source_code
create trigger disjoint_source_code_trigger before insert or update on source_code for each row
    execute procedure disjoint_total_subreference();

-- crea tabella related_references
create table related_references(
    quoted_by integer not null,
    quotes integer not null,
);

-- foreign key
alter table related_references
    add constraint quoted_by_fk foreign key (quoted_by) references bibliographic_reference(id) on update cascade on delete cascade;

alter table related_references
    add constraint quotes_fk foreign key (quotes) references bibliographic_reference(id) on update cascade on delete cascade;

-- un riferimento può citarne un altro solo una volta
alter table related_references
    add constraint unique_quotation unique(quoted_by, quotes);

-- un riferimento non può citare sè stesso
alter table related_references
    add constraint no_self_quotation check(quoted_by <> quotes);

-- crea tabella author
create table author(
    id serial primary key,
    name varchar(256) not null,
    orcid char(20)
);

-- TODO: orcid check https://support.orcid.org/hc/en-us/articles/360006897674-Structure-of-the-ORCID-Identifier

-- l'orcid è univoco
alter table author
    add constraint unique_orcid unique(orcid);

-- possono esserci omonimi, ma l'orcid deve essere diverso per ognuno
-- non possiamo usare solo il vincolo unique perchè postgresql non considera i valori null, quindi sarebbero possibili
-- due autori con lo stesso nome senza orcid
create unique index unique_author on author(name, (orcid is null)) where orcid is null;

-- crea tabella author_reference_association
create table author_reference_association(
    reference integer not null,
    author integer not null
);

-- foreign key
alter table author_reference_association
    add constraint reference_fk foreign key (reference) references bibliographic_reference(id) on update cascade on delete cascade;

alter table author_reference_association
    add constraint author_fk foreign key (author) references author(id) on update cascade on delete cascade;

-- un riferimento può essere associato a un autore una sola volta
alter table author_reference_association
    add constraint unique_author_reference unique(reference, author);

-- crea tabella tag
create table tag(
    name varchar(128) not null,
    reference integer not null
);

-- foreign key
alter table tag
    add constraint reference_fk foreign key (reference) references bibliographic_reference(id) on update cascade on delete cascade;

-- crea tabella category
create table category(
    id serial primary key, -- essere primary key impedisce anche che una categoria sia sotto-categoria di sè stessa
    name varchar(64) not null,
    parent integer,
    owner varchar(128) not null
);

-- foreign key
alter table category
    add constraint parent_fk foreign key (parent) references category(id) on update cascade on delete cascade;

alter table category
    add constraint owner_fk foreign key (owner) references user_app(name) on update cascade on delete cascade;

-- non sono possibili due categorie con lo stesso nome e lo stesso genitore appartenenti allo stesso utente
alter table category
    add constraint unique_name_with_parent unique(name, parent, owner);

-- non possiamo usare solo il vincolo unique perchè postgresql non considera i valori null, quindi sarebbero possibili
-- due categorie senza genitore che hanno lo stesso nome
create unique index unique_name_with_no_parent on category(name, (parent is null), owner) where parent is null;

-- crea tabella category_reference_association
create table category_reference_association(
    category integer not null,
    reference integer not null
);

-- foreign key
alter table category_reference_association
    add constraint category_fk foreign key (category) references category(id) on update cascade on delete cascade;

alter table category_reference_association
    add constraint reference_fk foreign key (reference) references bibliographic_reference(id) on update cascade on delete cascade;

-- un riferimento può essere associato a una categoria una sola volta
alter table category_reference_association
    add constraint unique_reference unique(category, reference);

-- un riferimento non può essere associato esplicitamente a una categoria e una sua sottocategoria

-- funzione per controllare se node1 è un discendente di node2
create or replace function is_descendant(node1 category.id % type, node2 category.id % type) returns boolean as $$
declare
    current_parent category.id % type;
begin
    -- se sono lo stesso nodo conta come discendente
    if node1 = node2 then
        return true;
    end if;

    select parent into current_parent from category where id = node1;

    while current_parent is not null loop
        if current_parent = node2 then
            return true;
        end if;

        select parent into current_parent from category where id = node1;
    end loop;

    return false;
end;
$$ language plpgsql;

-- funzione per controllare se si sta associando un riferimento a una categoria di cui è già associata
-- una sottocategoria o un suo genitore
create or replace function cyclic_dependency() returns trigger as $$
declare
    category_cursor record;
begin
    for category_cursor in select category from category_reference_association where reference = new.reference loop
        if is_descendant(new.category, category_cursor.category) or is_descendant(category_cursor.category, new.category) then
            raise exception 'reference cannot be in a category and its subcategory explicitly: %', new.reference;
        end if;
    end loop;

    return new;
end;
$$ language plpgsql;

-- trigger per l'associazione tra riferimento e categoria
create trigger cyclic_dependency_trigger before insert on category_reference_association for each row
    execute procedure cyclic_dependency();