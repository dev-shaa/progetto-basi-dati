-- crea un enum per la lingua del riferimento
create type language_enum as enum('ENGLISH', 'ITALIAN', 'FRENCH', 'GERMAN', 'SPANISH', 'RUSSIAN', 'JAPANESE', 'CHINESE', 'ARAB');

-- crea un enum per i tipi di linguaggi di programmazione
create type programming_language_enum as enum('C', 'CSHARP', 'JAVA', 'PYTHON', 'LUA', 'FORTRAN', 'OTHER');

-- crea un nuovo tipo di intero maggiore positivo (o nullo)
create domain positive_integer as integer check(value is null or value > 0) default null;

-- crea la tabella USER_APP
create table user_app(
    name varchar(128) primary key,
    password varchar(64) not null
);

-- crea la tabella BIBLIOGRAPHIC_REFERENCE
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

-- crea la tabella ARTICLE
create table article(
    id integer not null unique,
    page_count positive_integer,
    url varchar(256),
    publisher varchar(128),
    issn char(9)
);

-- crea il vincolo di foreign key per TODO: commenta
alter table article
    add constraint article_id_fk foreign key (id) references bibliographic_reference(id) on update cascade on delete cascade;

-- un codice ISSN è composto da quattro cifre, un trattino, tre cifre e infine una cifra o una x
alter table article
    add constraint issn_pattern_check check (issn is null or issn ~ '^[0-9]{4}-[0-9]{3}[0-9xX]$');

-- crea la tabella BOOK
create table book(
    id integer not null unique,
    page_count positive_integer,
    url varchar(256),
    publisher varchar(128),
    isbn char(13)
);

-- crea il vincolo di foreign key per TODO: commenta
alter table book
    add constraint book_id_fk foreign key (id) references bibliographic_reference(id) on update cascade on delete cascade;

-- TODO: isbn pattern

-- crea la tabella THESIS
create table thesis(
    id integer not null unique,
    page_count positive_integer,
    url varchar(256),
    publisher varchar(128),
    university varchar(128),
    faculty varchar(128)
);

-- crea il vincolo di foreign key per TODO: commenta
alter table thesis
    add constraint thesis_id_fk foreign key (id) references bibliographic_reference(id) on update cascade on delete cascade;

-- crea la tabella WEBSITE
create table website(
    id integer not null unique,
    url varchar(256) not null
);

-- crea il vincolo di foreign key per TODO: commenta
alter table website
    add constraint website_id_fk foreign key (id) references bibliographic_reference(id) on update cascade on delete cascade;

-- crea la tabella SOURCE_CODE
create table source_code(
    id integer not null unique,
    url varchar(256) not null,
    programming_language programming_language_enum
);

-- crea il vincolo di foreign key per TODO: commenta
alter table source_code
    add constraint source_code_id_fk foreign key (id) references bibliographic_reference(id) on update cascade on delete cascade;

-- crea la tabella VIDEO
create table video(
    id integer not null unique,
    url varchar(256) not null,
    width positive_integer,
    height positive_integer,
    framerate positive_integer,
    duration positive_integer
);

-- crea il vincolo di foreign key per TODO: commenta
alter table video
    add constraint video_id_fk foreign key (id) references bibliographic_reference(id) on update cascade on delete cascade;

-- crea la tabella IMAGE
create table image(
    id integer not null unique,
    url varchar(256) not null,
    width positive_integer,
    height positive_integer
);

-- crea il vincolo di foreign key per TODO: commenta
alter table image
    add constraint image_id_fk foreign key (id) references bibliographic_reference(id) on update cascade on delete cascade;

-- crea la tabella RELATED_REFERENCES
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

-- un riferimento di un utente può essere associato solo a riferimenti dello stesso utente
create or replace function related_reference_same_owner() returns trigger as $$
declare
    first_reference_owner user_app.name % type;
    second_reference_owner user_app.name % type;
begin
    select owner into first_reference_owner from bibliographic_reference where id = new.quoted_by;
    select owner into second_reference_owner from category where id = new.quotes;

    if reference_owner <> category_owner then
        raise exception 'references do not belong to the same user';
    end if;

    return new;
end;
$$ language plpgsql;

-- aggiungi trigger alla tabella RELATED_REFERENCES
create trigger related_reference_same_owner_trigger before insert or update on related_references for each row
    execute procedure related_reference_same_owner();

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
-- non possiamo usare solo il vincolo unique perchè postgresql non considera i valori null, quindi sarebbero possibili due autori con lo stesso nome senza orcid
create unique index unique_author on author(name, (orcid is null)) where orcid is null;

-- crea tabella AUTHOR_REFERENCE_ASSOCIATION
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

-- crea tabella TAG
create table tag(
    name varchar(128) not null,
    reference integer not null
);

-- crea il vincolo di foreign key per il riferimento a cui è associata la parola chiave
alter table tag
    add constraint reference_fk foreign key (reference) references bibliographic_reference(id) on update cascade on delete cascade;

-- crea tabella CATEGORY
create table category(
    id serial primary key, -- essere primary key impedisce anche che una categoria sia sotto-categoria transitivamente di sè stessa
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

-- non sono possibili due categorie con lo stesso nome e lo stesso genitore appartenenti allo stesso utente
alter table category
    add constraint unique_name_with_parent unique(name, parent, owner);

-- non possiamo usare solo il vincolo unique perchè postgresql non considera i valori null, quindi sarebbero possibili due categorie senza genitore che hanno lo stesso nome
create unique index unique_name_with_no_parent on category(name, (parent is null), owner) where parent is null;

-- una categoria non può essere sottocategoria di sè stessa
alter table category
    add constraint no_subcategory_of_itself check(id <> parent);

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

-- un riferimento di un utente può essere associato solo ad una categoria dello stesso utente
create or replace function category_reference_same_owner() returns trigger as $$
declare
    reference_owner user_app.name % type;
    category_owner user_app.name % type;
begin
    select owner into reference_owner from bibliographic_reference where id = new.reference;
    select owner into category_owner from category where id = new.category;

    if reference_owner <> category_owner then
        raise exception 'reference and category do not belong to the same user';
    end if;

    return new;
end;
$$ language plpgsql;

-- aggiungi trigger alla tabella CATEGORY_REFERENCE_ASSOCIATION
create trigger category_reference_same_owner_trigger before insert or update on category_reference_association for each row
    execute procedure category_reference_same_owner();


-- creazione vista comprendente tutti gli id usati come foreign key, usata per il trigger di disgiunzione tra sottoclassi di BIBLIOGRAPHIC_REFERENCE
-- nota: non possiamo usare direttamente le chiavi presenti in BIBLIOGRAPHIC_REFERENCE perchè dobbiamo tenere conto soltanto delle chiavi usate come foreign key
create view id_collection as (
  select id from "thesis" union
  select id from "book" union
  select id from "article" union
  select id from "video" union
  select id from "image" union
  select id from "source_code" union
  select id from "website"
);

-- implementazione vincolo di disgiunzione tra sottoclassi di BIBLIOGRAPHIC_REFERENCE

-- funzione da usare nel trigger di disgiunzione totale delle sottoclassi di BIBLIOGRAPHIC_REFERENCE
-- si verifica un'infrazione se:
-- si sta eseguendo un'operazione di insert e la chiave esterna "id" da inserire è già stata "occupata" da un altro dato
-- si sta eseguendo un'operazione di update cambiando anche la chiave esterna "id", inserendone una che è già stata "occupata" da un altro dato
create or replace function disjoint_total_subreference() returns trigger as $$
begin
    if (tg_op = 'INSERT' or (tg_op = 'UPDATE' and new.id <> old.id)) and new.id in (select id from id_collection) then
        raise exception 'there is another reference subclass associated with this reference';
    end if;

    return new;
end;
$$ language plpgsql;

-- aggiungi trigger alla tabella ARTICLE
create trigger disjoint_article_trigger before insert or update on article for each row
    execute procedure disjoint_total_subreference();

-- aggiungi trigger alla tabella BOOK
create trigger disjoint_book_trigger before insert or update on book for each row
    execute procedure disjoint_total_subreference();

-- aggiungi trigger alla tabella THESIS
create trigger disjoint_thesis_trigger before insert or update on thesis for each row
    execute procedure disjoint_total_subreference();

-- aggiungi trigger alla tabella WEBSITE
create trigger disjoint_website_trigger before insert or update on website for each row
    execute procedure disjoint_total_subreference();

-- aggiungi trigger alla tabella IMAGE
create trigger disjoint_image_trigger before insert or update on image for each row
    execute procedure disjoint_total_subreference();

-- aggiungi trigger alla tabella VIDEO
create trigger disjoint_video_trigger before insert or update on video for each row
    execute procedure disjoint_total_subreference();

-- aggiungi trigger alla tabella SOURCE_CODE
create trigger disjoint_source_code_trigger before insert or update on source_code for each row
    execute procedure disjoint_total_subreference();


-- un riferimento non può essere associato esplicitamente a una categoria e una sua sottocategoria

-- funzione per controllare se category1 è discendente di category2
create or replace function is_descendant(category1 category.id % type, category2 category.id % type) returns boolean as $$
declare
    current_parent category.id % type;
begin
    -- se sono lo stesso nodo conta come discendente
    if category1 = category2 then
        return true;
    end if;

    select parent into current_parent from category where id = category1;

    while current_parent is not null loop
        if current_parent = category2 then
            return true;
        end if;

        select parent into current_parent from category where id = category1;
    end loop;

    return false;
end;
$$ language plpgsql;

-- funzione da usare nel trigger di disgiunzione totale delle sottoclassi di BIBLIOGRAPHIC_REFERENCE
-- funzione per controllare se si sta associando un riferimento a una categoria di cui è già associata una sottocategoria o un suo genitore
create or replace function cyclic_dependency_trigger_function() returns trigger as $$
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
create trigger cyclic_dependency_trigger before insert or update on category_reference_association for each row
    execute procedure cyclic_dependency_trigger_function();