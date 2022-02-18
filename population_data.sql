-- UTENTI

insert into user_app(name, password) values('Mario Rossi', 'qwerty');
insert into user_app(name, password) values('Luca Bianchi', 'password123');
insert into user_app(name, password) values('Salvatore', 'provaPassword!');
insert into user_app(name, password) values('GenericUser', 'my_secret_password');

-- CATEGORIE

insert into category(id, name, owner, parent) values(1, 'AAA', null, 'Mario Rossi');
insert into category(name, owner, parent) values('BBB', null, 'Mario Rossi');
insert into category(name, owner, parent) values('CCC', null, 'Mario Rossi');
insert into category(name, owner, parent) values('DDD', 1, 'Mario Rossi');

insert into category(id, name, owner, parent) values(100, 'Categoria 1', null, 'Luca Bianchi');
insert into category(id, name, owner, parent) values(101, 'Categoria 2', 100, 'Luca Bianchi');
insert into category(id, name, owner, parent) values(102, 'Categoria 3', 101, 'Luca Bianchi');
insert into category(id, name, owner, parent) values(103, 'Categoria 4', 102, 'Luca Bianchi');

insert into category(id, name, owner, parent) values(200, 'Informatica', null, 'Salvatore');
insert into category(id, name, owner, parent) values(201, 'Basi di dati', 200, 'Salvatore');
insert into category(id, name, owner, parent) values(202, 'Object Orientation', 200, 'Salvatore');
insert into category(id, name, owner, parent) values(203, 'Matematica', null, 'Salvatore');

-- AUTORI

insert into author(id, name, orcid) values(1, 'Ciro Esposito', '0000-0000-0000-0000');
insert into author(id, name, orcid) values(2, 'Ramez Elmasri', null);
insert into author(id, name, orcid) values(3, 'Shamkant B. Navathe', null);
insert into author(id, name, orcid) values(4, 'Robert C. Martin', null);
insert into author(name, orcid) values('John Bob', '1111-2222-3333-444x');