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