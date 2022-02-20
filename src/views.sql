-- creazione vista comprendente tutti gli id usati come foreign key, usata per il trigger di disgiunzione tra sottoclassi di BIBLIOGRAPHIC_REFERENCE
-- nota: non possiamo usare direttamente le chiavi presenti in BIBLIOGRAPHIC_REFERENCE perchè dobbiamo tenere conto soltanto delle chiavi usate come foreign key
create view id_collection as (
  select id from thesis union
  select id from book union
  select id from article union
  select id from video union
  select id from image union
  select id from source_code union
  select id from website
);