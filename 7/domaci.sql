-- Napraviti tabelu student_ispiti koja ima kolone:
-- indeks – indeks studenta;
-- broj_polozenih_ispita – broj položenih ispita;
-- prosek – prosek studenta.
-- Definisati primarni ključ i strani ključ na tabelu dosije.

CREATE TABLE STUDENTI_ISPITI
(
    INDEKS                INTEGER NOT NULL,
    BROJ_POLOZENIH_ISPITA INTEGER,
    PROSEK                FLOAT,
    PRIMARY KEY (INDEKS),
    FOREIGN KEY FK_SID (INDEKS) REFERENCES DA.DOSIJE
);

-- Tabeli student_ispiti dodati kolonu broj_prijavljenih_ispita koja predstavlja broj polaganih ispita.
-- Dodati i ograničenje da broj polaganih ispita mora biti veći ili jednak broju položenih ispita.

ALTER TABLE STUDENTI_ISPITI
    ADD COLUMN BROJ_PRIJAVLJENIH_ISPITA INTEGER;
ALTER TABLE STUDENTI_ISPITI
    ADD CONSTRAINT BROJ_ISPITA_CHECK
        CHECK (BROJ_PRIJAVLJENIH_ISPITA >= BROJ_POLOZENIH_ISPITA);

-- U tabelu student_ispiti uneti podatke za studente koji su polagali ispite.

INSERT INTO STUDENTI_ISPITI(INDEKS, BROJ_POLOZENIH_ISPITA, BROJ_PRIJAVLJENIH_ISPITA, PROSEK)
SELECT I.INDEKS,
       COUNT(CASE WHEN I.OCENA > 5 AND I.STATUS = 'o' THEN 1 ELSE NULL END),
       COUNT(CASE WHEN I.STATUS NOT IN ('p', 'n') THEN 1 ELSE NULL END),
       AVG(CASE WHEN I.OCENA > 5 AND I.STATUS = 'o' THEN I.OCENA * 1.0 ELSE NULL END)
FROM DA.ISPIT I
GROUP BY I.INDEKS;

-- U tabelu student_ispiti uneti podatke za studente koji nisu ništa polagali. U odgovarajuće kolone uneti NULL.
INSERT INTO STUDENTI_ISPITI(INDEKS, BROJ_POLOZENIH_ISPITA, BROJ_PRIJAVLJENIH_ISPITA, PROSEK)
SELECT D.INDEKS, NULL, NULL, NULL
FROM DA.DOSIJE D
WHERE NOT EXISTS (SELECT 1
                  FROM DA.ISPIT I
                  WHERE I.INDEKS = D.INDEKS);


-- Obrisati tabelu student_ispiti.
DROP TABLE STUDENTI_ISPITI;

-- Za sve polagane ispite u roku jan2 2016 promeniti datum polaganja ispita na datum poslednjeg položenog ispita,
-- a ocenu na 10.

UPDATE DA.ISPIT
SET DATPOLAGANJA = (SELECT MAX(DATPOLAGANJA)
                    FROM DA.ISPIT I2
                    WHERE I2.SKGODINA = 2016
                      AND I2.OZNAKAROKA = 'jan2'
                      AND I2.OCENA > 5
                      AND I2.STATUS = 'o'),
    OCENA        = 10
WHERE SKGODINA = 2016
  AND OZNAKAROKA = 'jan2'
  AND OCENA > 5
  AND STATUS = 'o';