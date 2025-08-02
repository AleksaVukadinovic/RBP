-- Napraviti tabelu kandidati_za_upis u kojoj će se nalaziti podaci o prijavama za upis na fakultet.
-- Tabela ima kolone:
-- - id - identifikator prijave, ceo broj
-- - idprograma - identifikator željenog studijskog programa
-- - ime - ime kandidata, niska maksimalne dužine 50 karaktera
-- - prezime -prezime kandidata, niska maksimalne dužine 50 karaktera
-- - pol - pol kandidata; moguće vrednosti su m i z
-- - mestorodjenja -mesto rođenja kandidata, niska maksimalne dužine 50 karaktera
-- - datumprijave - datum prijave kandidata
-- - bodovi - bodovi za upis
-- Definisati primarni ključ u tabeli kandidati_za_upis i strani ključ na tabelu studijskiprogram.
-- Postaviti ograničenje za moguće vrednosti kolone pol.

CREATE TABLE kandidati_za_upis
(
    id            INTEGER     NOT NULL GENERATED ALWAYS AS IDENTITY (MINVALUE 1),
    idprograma    INTEGER     NOT NULL,
    ime           VARCHAR(50) NOT NULL,
    prezime       VARCHAR(50) NOT NULL,
    pol           CHAR,
    mestorodjenja VARCHAR(50),
    datumprijave  DATE,
    bodovi        FLOAT(4),
    PRIMARY KEY (id),
    FOREIGN KEY fk_smer (idprograma) REFERENCES DA.STUDIJSKIPROGRAM,
    CONSTRAINT vrednost_pol CHECK (POL IN ('m', 'z'))
);

-- U tabelu kandidati_za_upis uneti novog kandidata Marka Markovića, muškog pola ,
-- koji je rođen u Kragujevcu, a prijavio se 12.11.2020. za studjski program Informatika (id 103).

INSERT INTO kandidati_za_upis(id, idprograma, ime, prezime, pol, mestorodjenja, datumprijave, bodovi)
VALUES (DEFAULT, 103, 'Marko', 'Markovic', 'm', 'Kragujevac', DATE('12.11.2020'), NULL);

-- Iz tabele kandidati_za_upis ukloniti kolonu mestorodjenja.

ALTER TABLE kandidati_za_upis
    DROP COLUMN mestorodjenja;

-- Postaviti uslov u tabeli kandidati_za_upis da bodovi za upis mogu biti samo između 0 i 100
-- i da je podrazumevan datum prijave datum izvršavanja naredbe.

ALTER TABLE kandidati_za_upis
    ADD CONSTRAINT vrednost_bodovi CHECK ( bodovi BETWEEN 0 AND 100)
    ALTER COLUMN datumprijave SET DEFAULT CURRENT_DATE;

-- U tabelu kandidati_za_upis uneti nove kandidate sa podacima
-- Snezana Peric, pol ženski, željeni smer Informatika (id 103)
-- Marija Peric, pol ženski, željeni smer Matematika (id 101)

INSERT INTO kandidati_za_upis (ime, prezime, pol, idprograma)
VALUES ('Snezana', 'Peric', 'z', 103),
       ('Marija', 'Peric', 'z', 101);

-- U tabelu kandidati_za_upis uneti kao kandidate studente koji imaju status Ispisan u tabeli dosije.
-- Kao željeni studijski program navesti studijski program koji su studirali kada su se ispisali.
-- Kao broj ostvarenih bodova za upis uneti vrednost 90.

INSERT INTO kandidati_za_upis (ime, prezime, idprograma, pol, bodovi)
SELECT IME, PREZIME, IDPROGRAMA, POL, 90
FROM DA.DOSIJE D
         JOIN DA.STUDENTSKISTATUS S
              ON D.IDSTATUSA = S.ID
WHERE S.NAZIV = 'Ispisan';

-- Iz tabele kandidati_za_upis obrisati podatke o kandidatima za koje je nepoznat broj bodova za upis.

DELETE
FROM kandidati_za_upis
WHERE bodovi IS NULL;

-- Iz tabele kandidati_za_upis obrisati podatke o kandidatima koji se zovu kao neki student koji ima položen ispit.

DELETE
FROM kandidati_za_upis
WHERE (ime, prezime) IN (SELECT DISTINCT IME, PREZIME
                         FROM DA.ISPIT I
                                  JOIN DA.DOSIJE D
                                       ON I.INDEKS = D.INDEKS
                         WHERE STATUS = 'o'
                           AND OCENA > 5);

-- Svim kandidatima za upis na fakultet koji su se prijavili u poslednja dva dana i imaju unet broj bodova za upis
-- povećati broj bodova za upis za 20%.

UPDATE kandidati_za_upis
SET bodovi = CASE WHEN bodovi * 1.2 <= 100 THEN bodovi * 1.2 WHEN bodovi IS NOT NULL THEN 100 END
WHERE datumprijave >= CURRENT_DATE - 2 DAYS;

-- Ukloniti tabelu kandidati_za_upis.

DROP TABLE kandidati_za_upis;

-- Promeniti broj indeksa studenta sa indeksom 20171063 U indeks 20172063 u tabeli dosije.

UPDATE DA.DOSIJE
SET INDEKS = 20172063
WHERE INDEKS = 20171063;
-- OVO JE TRIK I JAVICE GRESKU ZBOG STRANOG KLJUCA, UMESTO TOGA MORA OVAKO:

INSERT INTO DA.DOSIJE
SELECT 20172063,
       IDPROGRAMA,
       IME,
       PREZIME,
       POL,
       MESTORODJENJA,
       IDSTATUSA,
       DATUPISA,
       DATDIPLOMIRANJA
FROM DA.DOSIJE
WHERE INDEKS = 20171063;
UPDATE DA.UPISGODINE
SET INDEKS = 20172063
WHERE INDEKS = 20171063;

-- Na svim ispitima na kojima su u ispitnom roku jun1 2015. godine studenti polagali Analizu 1 promeniti rok u jan1 2015.
-- Za datum polaganja staviti da je nepoznat.

CREATE TABLE ISPIT1 AS
(
    SELECT *
    FROM DA.ISPIT
) WITH DATA;

UPDATE ISPIT1
SET (OZNAKAROKA, DATPOLAGANJA) = ('jan1', null)
WHERE IDPREDMETA IN (SELECT ID
                     FROM DA.PREDMET
                     WHERE NAZIV = 'Analiza 1')
  AND SKGODINA = 2015
  AND OZNAKAROKA = 'jun1';

-- Predmetima koje su polagali studenti iz Beograda postaviti broj bodova na najveći broj bodova koji postoji u tabeli predmet.

CREATE TABLE PREDMET1 AS
(
    SELECT *
    FROM DA.PREDMET
) WITH DATA;

UPDATE PREDMET1 P
SET ESPB = (SELECT MAX(ESPB)
            FROM DA.PREDMET1)
WHERE EXISTS(SELECT *
             FROM DA.DOSIJE D
                      JOIN DA.ISPIT I ON D.INDEKS = I.INDEKS
             WHERE D.MESTORODJENJA LIKE 'Beograd%'
               AND I.IDPREDMETA = P.ID);

-- Promeniti sve padove iz predmeta Programiranje 1 na polaganja sa ocenom 6.

UPDATE ISPIT1
SET (OCENA, STATUS) = (6, 'o')
WHERE STATUS = 'o'
  AND OCENA = 5
  AND IDPREDMETA IN (SELECT ID
                     FROM DA.PREDMET
                     WHERE NAZIV = 'Programiranje 1');
