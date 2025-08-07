-- Napraviti tabelu student_ispiti koja ima kolone:
-- indeks – indeks studenta;
-- broj_polozenih_ispita – broj položenih ispita;
-- prosek – prosek studenta.
-- Definisati primarni ključ i strani ključ na tabelu dosije.

CREATE TABLE STUDENTI_ISPITI
(
    INDEKS                INTEGER NOT NULL GENERATED AS IDENTITY PRIMARY KEY,
    BROJ_POLOZENIH_ISPITA INTEGER,
    PROSEK                FLOAT,
    FOREIGN KEY FK_INDEKS (INDEKS) REFERENCES DA.DOSIJE
);

-- Tabeli student_ispiti dodati kolonu broj_prijavljenih_ispita koja predstavlja broj polaganih ispita.
-- Dodati i ograničenje da broj polaganih ispita mora biti veći ili jednak broju položenih ispita.

ALTER TABLE STUDENTI_ISPITI
    ADD COLUMN BROJ_PRIJAVLJENIH_ISPITA INTEGER;
ALTER TABLE STUDENTI_ISPITI
    ADD CONSTRAINT BROJ_PRIJAVLJENIH_ISPITA_CHK CHECK ( STUDENTI_ISPITI.BROJ_PRIJAVLJENIH_ISPITA >= BROJ_POLOZENIH_ISPITA );

-- U tabelu student_ispiti uneti podatke za studente koji su polagali ispite.

INSERT INTO STUDENTI_ISPITI(INDEKS, BROJ_POLOZENIH_ISPITA, PROSEK, BROJ_PRIJAVLJENIH_ISPITA)
SELECT I.INDEKS,
       COUNT(CASE WHEN I.OCENA > 5 AND I.STATUS = 'o' THEN 1 ELSE 0 END),
       AVG(CASE WHEN I.OCENA > 5 AND I.STATUS = 'o' THEN I.OCENA END),
       COUNT(*)
FROM DA.ISPIT I
GROUP BY I.INDEKS;

-- U tabelu student_ispiti uneti podatke za studente koji nisu ništa polagali. U odgovarajuće kolone uneti NULL.

INSERT INTO STUDENTI_ISPITI(INDEKS, BROJ_POLOZENIH_ISPITA, PROSEK, BROJ_PRIJAVLJENIH_ISPITA)
SELECT I.INDEKS, 0, NULL, 0
FROM DA.ISPIT I
WHERE I.OCENA <= 5
   OR I.STATUS <> 'o';

-- Obrisati tabelu student_ispiti.
DROP TABLE STUDENTI_ISPITI;

-- Za sve polagane ispite u roku jan2 2016 promeniti datum polaganja ispita na datum poslednjeg položenog ispita,
-- a ocenu na 10.

UPDATE DA.ISPIT I
SET I.DATPOLAGANJA = (SELECT MAX(DATPOLAGANJA) FROM DA.ISPIT I WHERE I.OCENA > 5 AND I.STATUS = 'o'),
    I.OCENA        = 10
WHERE I.OZNAKAROKA = 'jan2'
  AND I.SKGODINA = 2016;