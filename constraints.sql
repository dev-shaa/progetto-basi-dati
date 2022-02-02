-- controlla se node1 è un discendente di node2
create
or replace function is_descendant(node1 category.id % type, node2 category.id % type) returns boolean as $$
declare
  current_parent category.id % type;
begin
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

-- un riferimento non può essere associato esplicitamente a una categoria e una sua sottocategoria
create
or replace function recursive_parenting() returns trigger as $$
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

create trigger recursive_parenting_trigger before
insert
  on category_reference_association for each row execute procedure recursive_parenting();

--
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

create
or replace function disjoint_total_subclass() returns trigger as $$
begin
  if new.id in (select * from id_collection) then
    raise exception 'there is another reference subclass associated with this reference';
  end if;

  return new;
end;
$$ language plpgsql;

create trigger disjoint_total_subclass_trigger before
insert
  or
update
  on article for each row execute procedure disjoint_total_subclass();