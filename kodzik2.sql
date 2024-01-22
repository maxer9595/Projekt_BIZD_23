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
