-- funzione per controllare se category1 è discendente di category2
-- restituisce true se category1 è discendente di category2 (se sono la stessa categoria contano come discendenti)
create or replace function is_descendant(category1 category.id % type, category2 category.id % type) returns boolean as $$
declare
    current_node category.id % type;
begin
    current_node := category1;

    while current_node is not null loop
        if current_node = category2 then
            return true;
        end if;

        select parent into current_node from category where id = current_node;
    end loop;

    return false;
end;
$$ language plpgsql;

-- funzione che restituisce il numero di volte in cui un riferimento è presente nei rimandi degli altri
create or replace function get_received_quotation_count(reference bibliographic_reference.id % type) returns integer as $$
declare
    quoted_count integer;
begin
    select count(*) into quoted_count from quotations where quotes = reference;
    return quoted_count;
end;
$$ language plpgsql;