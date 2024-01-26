--- dodawanie danych finansowych 
BEGIN
    dodaj_dane_finansowe(TO_TIMESTAMP('2022-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ABC', 100.0, 120.0, 80.0, 110.0, 500.0, 55000.0);
END;


--- podmianka wartosci uzywajac aktualizuj dane finansowe 
DECLARE
    CURSOR cur_dane_finansowe IS
        SELECT id
        FROM dane_finansowe
        WHERE EXTRACT(YEAR FROM data) = 2024 AND EXTRACT(MONTH FROM data) = 1;
BEGIN
    FOR rec IN cur_dane_finansowe
    LOOP
        -- Aktualizacja dla każdego rekordu
        BEGIN
            aktualizuj_dane_finansowe(
                rec.id,
                TO_TIMESTAMP('2024-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), -- Nowa data
                'ABC', -- Nowy symbol
                120.0, -- Nowa wartość dla open
                140.0, -- Nowa wartość dla high
                110.0, -- Nowa wartość dla low
                130.0, -- Nowa wartość dla close
                600.0, -- Nowa wartość dla volume_btc
                70000.0 -- Nowa wartość dla volume_usd
            );
            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                -- Obsługa błędów, na przykład zapis do logu lub rzuć wyjątek dalej
                DBMS_OUTPUT.PUT_LINE('Błąd aktualizacji dla rekordu o ID: ' || rec.id);
        END;
    END LOOP;
END;