-- robienie tabeli dane_finansowe (główna tabelka)

CREATE TABLE dane_finansowe (
    id NUMBER PRIMARY KEY,
    data TIMESTAMP,
    symbol VARCHAR2(16),
    open FLOAT,
    high FLOAT,
    low FLOAT,
    close FLOAT,
    volume_btc FLOAT,
    volume_usd FLOAT
);


-- tworzenie taeli archiwum_danych 

CREATE TABLE archiwum_danych (
    id NUMBER PRIMARY KEY,
    data TIMESTAMP,
    symbol VARCHAR2(16),
    open FLOAT,
    high FLOAT,
    low FLOAT,
    close FLOAT,
    volume_btc FLOAT,
    volume_usd FLOAT
);

-- tworzenie tabeli logi_danych 

CREATE TABLE logi_danych (
    log_id NUMBER PRIMARY KEY,
    akcja VARCHAR2(20),
    id NUMBER,
    data TIMESTAMP,
    symbol VARCHAR2(16),
    stara_wartosc FLOAT,
    nowa_wartosc FLOAT,
    data_logowania TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- dodawanie rekordu procedura

CREATE OR REPLACE PROCEDURE DodajRekord (
    p_id NUMBER,
    p_data TIMESTAMP,
    p_symbol VARCHAR2,
    p_open FLOAT,
    p_high FLOAT,
    p_low FLOAT,
    p_close FLOAT,
    p_volume_btc FLOAT,
    p_volume_usd FLOAT
) AS
BEGIN
    INSERT INTO dane_finansowe (id, data, symbol, open, high, low, close, volume_btc, volume_usd)
    VALUES (p_id, p_data, p_symbol, p_open, p_high, p_low, p_close, p_volume_btc, p_volume_usd);
    COMMIT;
END DodajRekord;
/

-- kasowanie rekordu procedura

CREATE OR REPLACE PROCEDURE UsunRekord (
    p_id NUMBER
) AS
BEGIN
    INSERT INTO archiwum_danych (id, data, symbol, open, high, low, close, volume_btc, volume_usd)
    SELECT id, data, symbol, open, high, low, close, volume_btc, volume_usd
    FROM dane_finansowe
    WHERE id = p_id;

    DELETE FROM dane_finansowe WHERE id = p_id;
    COMMIT;
END UsunRekord;
/

-- procedura aktualizująca rekord

CREATE OR REPLACE PROCEDURE AktualizujRekord (
    p_id NUMBER,
    p_new_open FLOAT
) AS
BEGIN
    UPDATE dane_finansowe SET open = p_new_open WHERE id = p_id;
    COMMIT;
END AktualizujRekord;
/

-- wyzwalacz logujący informacje do tabeli

CREATE OR REPLACE TRIGGER LogowaniePoAktualizacji
AFTER UPDATE ON dane_finansowe
FOR EACH ROW
BEGIN
    INSERT INTO logi_danych (akcja, id, data, symbol, stara_wartosc, nowa_wartosc)
    VALUES ('AKTUALIZACJA', :old.id, :old.data, :old.symbol, :old.open, :new.open);
END;
/

--- obsługa wyjątku nie wiem na chuj to XDDD

CREATE OR REPLACE PROCEDURE SprawdzSymbol (
    p_symbol VARCHAR2
) AS
    -- Własny wyjątek
    WyjatekSymbolNiepoprawny EXCEPTION;
    PRAGMA EXCEPTION_INIT(WyjatekSymbolNiepoprawny, -20001);

    v_symbol_valid BOOLEAN;
BEGIN
    -- Sprawdzenie poprawności symbolu (tu można umieścić odpowiednią logikę sprawdzającą)
    IF LENGTH(p_symbol) <= 0 THEN
        RAISE WyjatekSymbolNiepoprawny;
    END IF;

    -- Tutaj można umieścić dalszą logikę, jeśli symbol jest poprawny
    DBMS_OUTPUT.PUT_LINE('Symbol jest poprawny.');
EXCEPTION
    WHEN WyjatekSymbolNiepoprawny THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: Niepoprawny symbol.');
END SprawdzSymbol;
/



-- procedura 
CREATE OR REPLACE PROCEDURE GenerujPodsumowanieMiesieczne (
    p_rok NUMBER,
    p_miesiac NUMBER
) AS
BEGIN
    INSERT INTO podsumowanie_miesieczne (rok, miesiac, srednia_open, suma_volume_btc)
    SELECT
        EXTRACT(YEAR FROM data) AS rok,
        EXTRACT(MONTH FROM data) AS miesiac,
        AVG(open) AS srednia_open,
        SUM(volume_btc) AS suma_volume_btc
    FROM dane_finansowe
    WHERE EXTRACT(YEAR FROM data) = p_rok AND EXTRACT(MONTH FROM data) = p_miesiac
    GROUP BY EXTRACT(YEAR FROM data), EXTRACT(MONTH FROM data);
    COMMIT;
END GenerujPodsumowanieMiesieczne;
/
