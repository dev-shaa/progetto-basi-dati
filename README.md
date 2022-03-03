# Progetto Base Dati

Basi di dati relazionale per la gestione di bibliografie, implementata con PostgreSQL 12.9.

## Requisiti

- PostgreSQL 12.9

## Istruzioni

Il codice è stato diviso in diversi file per renderlo più leggibile, tuttavia per poter ricreare il database è necessario eseguirli nel seguente ordine:
1. `tables.sql`
2. `views.sql`
3. `functions.sql`
4. `constraints.sql`

Viene fornito anche il file `population_data.sql` in cui sono presenti dati per popolare il database.
Si consiglia di eseguirlo con un database vuoto per evitare eventuali conflitti.
