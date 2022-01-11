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