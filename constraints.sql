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

create or replace function disjoint_total_subreference() returns trigger as $$
begin

  if tg_op = 'INSERT' and new.id in (select * from id_collection) then
    raise exception 'there is another reference subclass associated with this reference';
  end if;

  return new;
end;
$$ language plpgsql;

create trigger disjoint_total_subreference_trigger before insert or update on article for each row
  execute procedure disjoint_total_subreference();