-- SCRIPT PER IL POPOLAMENTO DELLE TABELLE

-- UTENTI

insert into user_app(name, password) values('Mario Rossi', 'qwerty');
insert into user_app(name, password) values('Luca Bianchi', 'password123');
insert into user_app(name, password) values('Salvatore', 'provaPassword!');
insert into user_app(name, password) values('GenericUser', 'my_secret_password');

-- CATEGORIE

insert into category(id, name, owner, parent) values(1, 'Categoria 1', 'Mario Rossi', null);
insert into category(id, name, owner, parent) values(2, 'Categoria 2', 'Mario Rossi', null);
insert into category(name, owner, parent) values('Categoria 3', 'Mario Rossi', null);
insert into category(name, owner, parent) values('Categoria 4', 'Mario Rossi', 1);

insert into category(id, name, owner, parent) values(100, 'AAA', 'Luca Bianchi', null);
insert into category(id, name, owner, parent) values(101, 'BBB', 'Luca Bianchi', 100);
insert into category(id, name, owner, parent) values(102, 'CCC', 'Luca Bianchi', 101);
insert into category(id, name, owner, parent) values(103, 'DDD', 'Luca Bianchi', 102);

insert into category(id, name, owner, parent) values(200, 'Informatica', 'Salvatore', null);
insert into category(id, name, owner, parent) values(201, 'Basi di dati', 'Salvatore', 200);
insert into category(id, name, owner, parent) values(202, 'Object Orientation', 'Salvatore', 200);
insert into category(id, name, owner, parent) values(203, 'Matematica', 'Salvatore', null);

-- AUTORI

insert into author(id, name, orcid) values(1, 'Ciro Esposito', '0000-0000-0000-000x');
insert into author(id, name, orcid) values(2, 'Ramez Elmasri', null);
insert into author(id, name, orcid) values(3, 'Shamkant B. Navathe', null);
insert into author(id, name, orcid) values(4, 'Robert C. Martin', null);
insert into author(id, name, orcid) values(5, 'John Bob', '1111-2222-3333-444x');
insert into author(id, name, orcid) values(6, 'Karl Mover', '1234-5678-9012-3456');

-- RIFERIMENTI

insert into bibliographic_reference(id, owner, title, description, doi, language, pubblication_date)
    values(1, 'Mario Rossi', 'Riferimento 1', 'Il primo riferimento presente nel database', null, 'ITALIAN', '1970-01-01');
insert into bibliographic_reference(id, owner, title, description, doi, language, pubblication_date)
    values(2, 'Mario Rossi', 'Riferimento 2', 'Il secondo riferimento presente nel database', null, 'ITALIAN', '1970-01-01');
insert into bibliographic_reference(id, owner, title, description, doi, language, pubblication_date)
    values(3, 'Mario Rossi', 'Riferimento 3', 'Il terzo riferimento presente nel database', null, 'ITALIAN', '1970-01-01');

insert into article(id, page_count, url, publisher, issn) values(1, 1, null, 'EditoreGenerico', '0000-0000');
insert into book(id, page_count, url, publisher, isbn) values(2, 100, null, null, null);
insert into thesis(id, page_count, url, publisher, university, faculty) values(3, 50, 'www.sito_tesi.it', null, 'Federico II', 'Informatica');

---

insert into bibliographic_reference(id, owner, title, description, doi, language, pubblication_date)
    values(100, 'Luca Bianchi', 'Internetseite', 'Eine generische Website', '10.1000/182.182', 'GERMAN', null);
insert into bibliographic_reference(id, owner, title, description, doi, language, pubblication_date)
    values(101, 'Luca Bianchi', 'RR', 'A famous video', null, 'ENGLISH', '2009-10-25');

insert into website(id, url) values(100, 'www.generisch.de');
insert into video(id, url, width, height, framerate, duration) values(101, 'https://youtu.be/dQw4w9WgXcQ', 640, 360, 25, 212);

---

insert into bibliographic_reference(id, owner, title, description, doi, language, pubblication_date)
    values(200, 'Salvatore', 'Sistemi di basi di dati (Settima Edizione)', 'Libro che spiega il funzionamento di un database', null, 'ENGLISH', '2015-01-01');
insert into bibliographic_reference(id, owner, title, description, doi, language, pubblication_date)
    values(201, 'Salvatore', 'Clean Code', 'Libro con numerosi consigli per scrivere codice pulito ed efficiente', null, 'ENGLISH', '2009-01-01');
insert into bibliographic_reference(id, owner, title, description, doi, language, pubblication_date)
    values(202, 'Salvatore', 'Progetto', 'Progetto per la gestione di riferimenti bibliografici', null, 'ITALIAN', null);

insert into book(id, page_count, url, publisher, isbn) values(200, 800, null, 'Pearson', '9788891902594');
insert into book(id, page_count, url, publisher, isbn) values(201, 575, null, 'Pearson', '9788850334384');
insert into source_code(id, url, programming_language) values(202, 'www.github.com', 'JAVA');

---

insert into bibliographic_reference(id, owner, title, description, doi, language, pubblication_date)
    values(300, 'GenericUser', 'Nice image', 'A very nice image i found online', null, null, null);
insert into bibliographic_reference(id, owner, title, description, doi, language, pubblication_date)
    values(301, 'GenericUser', 'A book about flowers', 'A book about flowers', '10.4500/891.aaa.1', 'ENGLISH', '2015-06-24');

insert into image(id, url, width, height) values(300, 'https://cdn.mr-fothergills.co.uk/product-images/op/z/33182az.jpg', 800, 800);
insert into book(id, page_count, url, publisher, isbn) values(301, 40, 'www.anotherpublisher.co.uk/books/flower/000000', 'AnotherPublisher', null);

-- RIMANDI

insert into quotations(quoted_by, quotes) values(2, 1);
insert into quotations(quoted_by, quotes) values(2, 3);

insert into quotations(quoted_by, quotes) values(202, 201);
insert into quotations(quoted_by, quotes) values(202, 200);

insert into quotations(quoted_by, quotes) values(301, 300);

-- ASSOCIAZIONE RIFERIMENTI - CATEGORIE

insert into reference_grouping(category, reference) values(1, 1);
insert into reference_grouping(category, reference) values(2, 2);

insert into reference_grouping(category, reference) values(100, 100);
insert into reference_grouping(category, reference) values(103, 101);

insert into reference_grouping(category, reference) values(201, 200);
insert into reference_grouping(category, reference) values(202, 201);
insert into reference_grouping(category, reference) values(200, 202);

-- ASSOCIAZIONE RIFERIMENTI - AUTORI

insert into authorship(reference, author) values(1, 1);
insert into authorship(reference, author) values(2, 1);

insert into authorship(reference, author) values(100, 6);

insert into authorship(reference, author) values(200, 2);
insert into authorship(reference, author) values(200, 3);
insert into authorship(reference, author) values(201, 4);

insert into authorship(reference, author) values(301, 5);

-- ASSOCIAZIONE RIFERIMENTI - TAG

insert into tag(name, reference) values('tag1', 1);
insert into tag(name, reference) values('tag2', 1);
insert into tag(name, reference) values('tag3', 2);
insert into tag(name, reference) values('tag4', 3);

insert into tag(name, reference) values('music', 101);
insert into tag(name, reference) values('these', 100);
insert into tag(name, reference) values('famous', 101);

insert into tag(name, reference) values('database', 200);
insert into tag(name, reference) values('sql', 200);
insert into tag(name, reference) values('relazionale', 200);
insert into tag(name, reference) values('università', 200);

insert into tag(name, reference) values('java', 201);
insert into tag(name, reference) values('codice', 201);
insert into tag(name, reference) values('clean code', 201);
insert into tag(name, reference) values('object orientation', 201);
insert into tag(name, reference) values('università', 201);

insert into tag(name, reference) values('java', 202);
insert into tag(name, reference) values('codice', 202);
insert into tag(name, reference) values('progetto', 202);
insert into tag(name, reference) values('object orientation', 202);
insert into tag(name, reference) values('sql', 202);
insert into tag(name, reference) values('università', 202);

insert into tag(name, reference) values('flower', 300);
insert into tag(name, reference) values('pink', 300);

insert into tag(name, reference) values('flower', 301);