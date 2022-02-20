-- UTENTI

insert into user_app(name, password) values('Mario Rossi', 'qwerty');
insert into user_app(name, password) values('Luca Bianchi', 'password123');
insert into user_app(name, password) values('Salvatore', 'provaPassword!');
insert into user_app(name, password) values('GenericUser', 'my_secret_password');

-- CATEGORIE

insert into category(id, name, owner, parent) values(1, 'Categoria 1', null, 'Mario Rossi');
insert into category(id, name, owner, parent) values(2, 'Categoria 2', null, 'Mario Rossi');
insert into category(name, owner, parent) values('Categoria 3', null, 'Mario Rossi');
insert into category(name, owner, parent) values('Categoria 4', 1, 'Mario Rossi');

insert into category(id, name, owner, parent) values(100, 'AAA', null, 'Luca Bianchi');
insert into category(id, name, owner, parent) values(101, 'BBB', 100, 'Luca Bianchi');
insert into category(id, name, owner, parent) values(102, 'CCC', 101, 'Luca Bianchi');
insert into category(id, name, owner, parent) values(103, 'DDD', 102, 'Luca Bianchi');

insert into category(id, name, owner, parent) values(200, 'Informatica', null, 'Salvatore');
insert into category(id, name, owner, parent) values(201, 'Basi di dati', 200, 'Salvatore');
insert into category(id, name, owner, parent) values(202, 'Object Orientation', 200, 'Salvatore');
insert into category(id, name, owner, parent) values(203, 'Matematica', null, 'Salvatore');

-- AUTORI

insert into author(id, name, orcid) values(1, 'Ciro Esposito', '0000-0000-0000-0000');
insert into author(id, name, orcid) values(2, 'Ramez Elmasri', null);
insert into author(id, name, orcid) values(3, 'Shamkant B. Navathe', null);
insert into author(id, name, orcid) values(4, 'Robert C. Martin', null);
insert into author(id, name, orcid) values(5, 'John Bob', '1111-2222-3333-444x');
insert into author(id, name, orcid) values(6, 'Karl Mover', '1234-5678-9012-3456');
insert into author(name, orcid) values('Ivan Ivanovich', null);

-- RIFERIMENTI

insert into bibliographic_reference(id, owner, title, description, doi, language, pubblication_date)
    values(1, 'Mario Rossi', 'Riferimento 1', 'Il primo riferimento presente nel database', null, 'ITALIAN', 1970-01-01);
insert into bibliographic_reference(id, owner, title, description, doi, language, pubblication_date)
    values(2, 'Mario Rossi', 'Riferimento 2', 'Il secondo riferimento presente nel database', null, 'ITALIAN', 1970-01-01);
insert into bibliographic_reference(id, owner, title, description, doi, language, pubblication_date)
    values(3, 'Mario Rossi', 'Riferimento 3', 'Il terzo riferimento presente nel database', null, 'ITALIAN', 1970-01-01);

insert into article(id, page_count, url, publisher, issn) values(1, 1, null, null, null);
insert into book(id, page_count, url, publisher, isbn) values(2, 100, null, null, null);
insert into thesis(id, page_count, url, publisher, university, faculty) values(3, 50, null, null, null, null);

insert into bibliographic_reference(id, owner, title, description, doi, language, pubblication_date)
    values(200, 'Salvatore', 'Sistemi di basi di dati (Settima Edizione)', 'Libro che spiega il funzionamento di un database', null, 'ENGLISH', 2015-01-01);
insert into bibliographic_reference(id, owner, title, description, doi, language, pubblication_date)
    values(201, 'Salvatore', 'Clean Code', 'Libro con numerosi consigli per scrivere codice pulito ed efficiente', null, 'ENGLISH', 2009-01-01);

insert into book(id, page_count, url, publisher, isbn) values(200, 800, null, 'Pearson', '9788891902594B');
insert into book(id, page_count, url, publisher, isbn) values(201, 575, null, 'Pearson', '9788850334384');

-- RIMANDI

insert into related_references(quoted_by, quotes) values(2, 2);
insert into related_references(quoted_by, quotes) values(2, 3);

-- ASSOCIAZIONE RIFERIMENTI - CATEGORIE

insert into category_reference_association(category, reference) values(1, 1);
insert into category_reference_association(category, reference) values(2, 2);

insert into category_reference_association(category, reference) values(201, 200);
insert into category_reference_association(category, reference) values(202, 201);

-- ASSOCIAZIONE RIFERIMENTI - AUTORI

insert into author_reference_association(reference, author) values(1, 1);
insert into author_reference_association(reference, author) values(2, 1);

insert into author_reference_association(reference, author) values(200, 2);
insert into author_reference_association(reference, author) values(200, 3);
insert into author_reference_association(reference, author) values(201, 4);

-- ASSOCIAZIONE RIFERIMENTI - TAG

insert into tag(name, reference) values('tag1', 1);
insert into tag(name, reference) values('tag2', 1);
insert into tag(name, reference) values('tag3', 2);
insert into tag(name, reference) values('tag4', 3);

insert into tag(name, reference) values('database', 200);
insert into tag(name, reference) values('sql', 200);
insert into tag(name, reference) values('relazionale', 200);
insert into tag(name, reference) values('università', 200);

insert into tag(name, reference) values('java', 201);
insert into tag(name, reference) values('codice', 201);
insert into tag(name, reference) values('clean code', 201);
insert into tag(name, reference) values('object orientation', 201);
insert into tag(name, reference) values('università', 201);