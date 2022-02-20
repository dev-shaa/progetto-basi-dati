-- una categoria deve appartenere allo stesso utente della super-categoria (se ce l'ha)
create or replace function subcategory_same_owner_function() returns trigger as $$
declare
    parent_owner user_app.name % type;
begin
    -- se la nuova categoria non ha un genitore assegnato, non è necessario eseguire il controllo
    if new.parent is null then
        return new;
    end if;

    select owner into parent_owner from category where id = new.parent;

    if new.owner <> parent_owner then
        raise exception 'category parent does not belong to the same user';
    end if;

    return new;
end;
$$ language plpgsql;

-- implementa trigger
create trigger subcategory_same_owner before insert or update on category for each row
    execute procedure subcategory_same_owner_function();

-----------------------------------------------------------------------------------------------------------------
-- un riferimento di un utente può essere associato solo a riferimenti dello stesso utente
create or replace function related_reference_same_owner_function() returns trigger as $$
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

-- implementa trigger
create trigger related_reference_same_owner before insert or update on related_references for each row
    execute procedure related_reference_same_owner_function();

-----------------------------------------------------------------------------------------------------------------
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

-- implementa trigger
create trigger category_reference_same_owner_trigger before insert or update on category_reference_association for each row
    execute procedure category_reference_same_owner();

-----------------------------------------------------------------------------------------------------------------
-- le sottoclassi di BIBLIOGRAPHIC_REFERENCE devono essere disgiunte

-- si verifica un'infrazione della disgiunzione se:
-- si sta eseguendo un'operazione di insert e la chiave esterna "id" da inserire è già stata "occupata" da un'altra riga
-- si sta eseguendo un'operazione di update cambiando anche la chiave esterna "id", inserendone una che è già stata "occupata" da un'altra riga
create or replace function disjoint_subreference() returns trigger as $$
begin
    if (tg_op = 'INSERT' or (tg_op = 'UPDATE' and new.id <> old.id)) and new.id in (select id from id_collection) then
        raise exception 'there is another reference subclass associated with this reference';
    end if;

    return new;
end;
$$ language plpgsql;

-- purtroppo non è possibile aggiungere lo stesso trigger a più tabelle,
-- quindi dobbiamo aggiungere un trigger diverso a ogni sottoclasse
-- fortunatamente possono usare la stessa funzione

-- aggiungi trigger alla tabella ARTICLE
create trigger disjoint_article before insert or update on article for each row
    execute procedure disjoint_subreference();

-- aggiungi trigger alla tabella BOOK
create trigger disjoint_book before insert or update on book for each row
    execute procedure disjoint_subreference();

-- aggiungi trigger alla tabella THESIS
create trigger disjoint_thesis before insert or update on thesis for each row
    execute procedure disjoint_subreference();

-- aggiungi trigger alla tabella WEBSITE
create trigger disjoint_website before insert or update on website for each row
    execute procedure disjoint_subreference();

-- aggiungi trigger alla tabella IMAGE
create trigger disjoint_image before insert or update on image for each row
    execute procedure disjoint_subreference();

-- aggiungi trigger alla tabella VIDEO
create trigger disjoint_video before insert or update on video for each row
    execute procedure disjoint_subreference();

-- aggiungi trigger alla tabella SOURCE_CODE
create trigger disjoint_source_code before insert or update on source_code for each row
    execute procedure disjoint_subreference();

-----------------------------------------------------------------------------------------------------------------
-- FIXME: quando si elimina una sottoclasse dovrebbe essere eliminato anche il riferimento base
-- create or replace function delete_super_reference() returns trigger as $$
-- begin
--     delete from bibliographic_reference where id = old.id;
--     return null;
-- end;
-- $$ language plpgsql;

-- create trigger delete_super_reference_article after delete on article for each row
--     execute procedure delete_super_reference();

-----------------------------------------------------------------------------------------------------------------
-- non possono esserci categorie cicliche (sottocategorie di sè stesse, anche transitivamente)
create or replace function cyclic_categories_function() returns trigger as $$
begin
    if is_descendant(new.parent, new.id) then
        raise exception 'category cannot be subcategory of itself';
    end if;

    return new;
end;
$$ language plpgsql;

-- implementa trigger
create trigger no_cyclic_categories before insert or update on category for each row
    execute procedure cyclic_categories_function();

-----------------------------------------------------------------------------------------------------------------
-- un riferimento non può essere associato a una categoria e a una sua sottocategoria esplicitamente
create or replace function no_explicit_associaton_function() returns trigger as $$
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
create trigger no_explicit_associaton_with_category_and_subcategory before insert or update on category_reference_association for each row
    execute procedure no_explicit_associaton_function();