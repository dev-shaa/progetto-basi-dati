create table category(
  id serial primary key,
  name varchar not null,
  parent integer references category(id),
  user_parent varchar references project_user(name),
  unique(name, parent) -- non sono possibili due categorie con lo stesso nome e lo stesso genitore
);