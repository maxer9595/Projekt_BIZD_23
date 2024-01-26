-- tworzenie glownej tabeli 
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

CREATE SEQUENCE SEQ_DANE_FINANSOWE
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

-- zadanie 6

CREATE SEQUENCE SEQ_LOGI_DANYCH
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;


CREATE OR REPLACE PROCEDURE dodaj_dane_finansowe(
    p_data TIMESTAMP,
    p_symbol VARCHAR2,
    p_open FLOAT,
    p_high FLOAT,
    p_low FLOAT,
    p_close FLOAT,
    p_volume_btc FLOAT,
    p_volume_usd FLOAT
)
AS
BEGIN
    IF p_open < 0 OR p_high < 0 OR p_low < 0 OR p_close < 0 OR p_volume_btc < 0 OR p_volume_usd < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nie można dodawać danych z ujemnymi wartościami.');
    END IF;

    INSERT INTO dane_finansowe (id, data, symbol, open, high, low, close, volume_btc, volume_usd)
    VALUES (SEQ_DANE_FINANSOWE.NEXTVAL, p_data, p_symbol, p_open, p_high, p_low, p_close, p_volume_btc, p_volume_usd);

    COMMIT;
END;
/



-- do usuwania 

CREATE OR REPLACE PROCEDURE usun_dane_finansowe(
    p_id NUMBER
)
AS
BEGIN
    INSERT INTO archiwum_danych
    SELECT * FROM dane_finansowe WHERE id = p_id;

    DELETE FROM dane_finansowe WHERE id = p_id;

    COMMIT;
END;
/

-- do kasowania 

CREATE OR REPLACE TRIGGER trg_archiwizacja
BEFORE DELETE ON dane_finansowe
FOR EACH ROW
BEGIN
    INSERT INTO archiwum_danych
    VALUES (:OLD.id, :OLD.data, :OLD.symbol, :OLD.open, :OLD.high, :OLD.low, :OLD.close, :OLD.volume_btc, :OLD.volume_usd);
END;
/



-- procedura do aktualizacji danych ( dodaje do logow )

CREATE OR REPLACE PROCEDURE aktualizuj_dane_finansowe(
    p_id NUMBER,
    p_data TIMESTAMP,
    p_symbol VARCHAR2,
    p_open FLOAT,
    p_high FLOAT,
    p_low FLOAT,
    p_close FLOAT,
    p_volume_btc FLOAT,
    p_volume_usd FLOAT
)
AS
BEGIN
    INSERT INTO logi_danych (log_id, akcja, id, data, symbol, stara_wartosc, nowa_wartosc, data_logowania)
    SELECT SEQ_LOGI_DANYCH.NEXTVAL, 'Aktualizacja', id, data, symbol, open, p_open, CURRENT_TIMESTAMP
    FROM dane_finansowe WHERE id = p_id;

    UPDATE dane_finansowe
    SET data = p_data,
        symbol = p_symbol,
        open = p_open,
        high = p_high,
        low = p_low,
        close = p_close,
        volume_btc = p_volume_btc,
        volume_usd = p_volume_usd
    WHERE id = p_id;

    COMMIT;
END;
/



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




-- zadanie 7

CREATE TABLE podsumowanie_miesieczne (
    rok INT,
    miesiac INT,
    srednia_open FLOAT,
    max_high FLOAT,
    min_low FLOAT,
    srednia_close FLOAT,
    suma_volume_btc FLOAT,
    suma_volume_usd FLOAT,
    PRIMARY KEY (rok, miesiac)
);

CREATE TABLE podsumowanie_kwartalne (
    rok INT,
    kwartal INT,
    srednia_open FLOAT,
    max_high FLOAT,
    min_low FLOAT,
    srednia_close FLOAT,
    suma_volume_btc FLOAT,
    suma_volume_usd FLOAT,
    PRIMARY KEY (rok, kwartal)
);

CREATE TABLE podsumowanie_roczne (
    rok INT PRIMARY KEY,
    srednia_open FLOAT,
    max_high FLOAT,
    min_low FLOAT,
    srednia_close FLOAT,
    suma_volume_btc FLOAT,
    suma_volume_usd FLOAT
);



CREATE OR REPLACE PROCEDURE generuj_podsumowanie_miesieczne(rok INT, miesiac INT)
AS
BEGIN
  INSERT INTO podsumowanie_miesieczne
  SELECT
    rok,
    miesiac,
    AVG(open),
    MAX(high),
    MIN(low),
    AVG(close),
    SUM(volume_btc),
    SUM(volume_usd)
  FROM dane_finansowe
  WHERE EXTRACT(YEAR FROM data) = rok AND EXTRACT(MONTH FROM data) = miesiac
  GROUP BY rok, miesiac;
END;
/

CREATE OR REPLACE PROCEDURE generuj_podsumowanie_kwartalne(rok INT, kwartal INT)
AS
BEGIN
  INSERT INTO podsumowanie_kwartalne
  SELECT
    rok,
    kwartal,
    AVG(open),
    MAX(high),
    MIN(low),
    AVG(close),
    SUM(volume_btc),
    SUM(volume_usd)
  FROM dane_finansowe
  WHERE EXTRACT(YEAR FROM data) = rok AND TO_CHAR(data, 'Q') = kwartal
  GROUP BY rok, kwartal;
END;
/

CREATE OR REPLACE PROCEDURE generuj_podsumowanie_roczne(rok INT)
AS
BEGIN
  INSERT INTO podsumowanie_roczne
  SELECT
    rok,
    AVG(open),
    MAX(high),
    MIN(low),
    AVG(close),
    SUM(volume_btc),
    SUM(volume_usd)
  FROM dane_finansowe
  WHERE EXTRACT(YEAR FROM data) = rok
  GROUP BY rok;
END;
/

