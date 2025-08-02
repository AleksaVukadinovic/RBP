-- Izdvojiti ukupan broj studenata.
SELECT COUNT(*) "Broj studenata"
FROM DA.DOSIJE;

-- Izdvojiti ukupan broj studenata koji bar iz jednog predmeta imaju ocenu 10.
SELECT COUNT(DISTINCT INDEKS)
FROM DA.ISPIT
WHERE OCENA = 10;

-- Izdvojiti ukupan broj položenih predmeta i položenih espb bodova za studenta sa indeksom 25/2016.
SELECT COUNT(*) AS BROJ_PREDMETA, SUM(P.ESPB)
FROM DA.PREDMET P
         JOIN DA.ISPIT I ON P.ID = I.IDPREDMETA
WHERE I.OCENA > 5
  AND I.STATUS = 'o'
  AND I.INDEKS = 20160025;

-- Izlistati ocene dobijene na ispitima i ako je ocena jednaka 5 ispisati NULL .
SELECT OCENA, NULLIF(OCENA, 5)
FROM DA.ISPIT;

-- Koliko ima različitih ocena dobijenih na ispitima, a da ocena nije 5.
SELECT COUNT(DISTINCT NULLIF(OCENA, 5))
FROM DA.ISPIT;

-- Izdvojiti oznake, nazive i espb bodove predmeta čiji je broj espb bodova veći od prosečnog broja espb bodova svih predmeta.
SELECT P.OZNAKA, P.NAZIV, P.ESPB
FROM DA.PREDMET P
WHERE P.ESPB > (SELECT AVG(ALL P.ESPB)
                FROM DA.PREDMET)
ORDER BY ESPB;

-- Za svakog studenta upisanog na fakultet 2018. godine, koji ima bar jedan položen ispit,
-- izdvojiti broj indeksa, prosečnu ocenu zaokruženu na dve decimale, najmanju ocenu i najveću ocenu iz položenih ispita.
SELECT D.INDEKS,
       DECIMAL(AVG(OCENA + 0.0), 4, 2) AS PROSEK,
       MIN(OCENA)                      AS NAJMANJA_OCENA,
       MAX(OCENA)                      AS NAJVECA_OCENA
FROM DA.DOSIJE D
         JOIN DA.ISPIT I
              ON D.INDEKS = I.INDEKS
WHERE YEAR(DATUPISA) = 2018
  AND OCENA > 5
  AND STATUS = 'o'
GROUP BY(D.INDEKS);

-- Izdvojiti naziv predmeta, školsku godinu u kojoj je održan ispit iz tog predmeta i najveću ocenu dobijenu na ispitima
-- iz tog predmeta u toj školskoj godini.
SELECT P.NAZIV, I.SKGODINA, MAX(I.OCENA) AS NAJVECA_OCENA
FROM DA.PREDMET P
         JOIN DA.ISPIT I ON P.ID = I.IDPREDMETA
GROUP BY P.NAZIV, I.SKGODINA;

-- Za svaki predmet izračunati koliko studenata ga je položilo. Izdvojite i predmete koje niko nije položio.
SELECT P.NAZIV, COUNT(DISTINCT I.INDEKS) AS POLOZILO
FROM DA.PREDMET P
         LEFT JOIN DA.ISPIT I ON P.ID = I.IDPREDMETA
WHERE I.OCENA > 5
  AND I.STATUS = 'o'
GROUP BY P.NAZIV
ORDER BY POLOZILO;

-- Izdvojiti identifikatore predmeta za koje je ispit prijavilo više od 50 različitih studenata.
SELECT ID
FROM DA.PREDMET P
WHERE 50 < (SELECT COUNT(DISTINCT INDEKS)
            FROM DA.ISPIT I
            WHERE I.IDPREDMETA = P.ID);

-- 2. nacin

SELECT I.IDPREDMETA, COUNT(DISTINCT I.INDEKS)
FROM DA.ISPIT I
GROUP BY I.IDPREDMETA
HAVING COUNT(DISTINCT INDEKS) > 50;

-- Za ispitne rokove koji su održani u 2016. godini i u kojima su svi regularno polagani ispiti i položeni,
-- izdvojiti oznaku roka, broj položenih ispita u tom roku i broj studenata koji su položili ispite u tom roku.
SELECT I.OZNAKAROKA,
       COUNT(*)                 AS BROJ_ISPITA,
       COUNT(DISTINCT I.INDEKS) AS BROJ_STUDENATA
FROM DA.ISPIT I
WHERE I.STATUS = 'o'
GROUP BY I.OZNAKAROKA, I.SKGODINA
HAVING I.SKGODINA = 2016
   AND MIN(I.OCENA) > 5;

-- Za svakog studenta izdvojiti broj indeksa i mesec u kome je položio više od dva ispita (nije važno koje godine).
-- Izdvojiti indeks studenta, ime meseca i broj položenih predmeta.
-- Rezultat urediti prema broju indeksa i mesecu polaganja.
SELECT INDEKS,
       MONTHNAME(DATPOLAGANJA) MESEC,
       COUNT(*)                POLOZENO
FROM DA.ISPIT
WHERE OCENA > 5
  AND STATUS = 'o'
GROUP BY INDEKS, MONTHNAME(DATPOLAGANJA)
HAVING COUNT(*) > 2
ORDER BY INDEKS, MONTHNAME(DATPOLAGANJA);

-- Za svaki predmet koji nosi najmanje espb bodova izdvojiti studente koji su ga položili.
-- Izdvojiti naziv predmeta i ime i prezime studenta.
-- Ime i prezime studenta izdvojiti u jednoj koloni.
-- Za predmete sa najmanjim brojem espb koje nije položio nijedan student umesto imena i prezimena ispisati nema.
SELECT P.NAZIV, COALESCE((D.IME || ' ' || D.PREZIME), 'Nema') AS IME_I_PREZIME
FROM DA.PREDMET P
         LEFT JOIN DA.ISPIT I ON P.ID = I.IDPREDMETA AND I.OCENA > 5
    AND I.STATUS = 'o'
         LEFT JOIN DA.DOSIJE D ON I.INDEKS = D.INDEKS
WHERE P.ESPB = (SELECT MIN(ESPB) FROM DA.PREDMET);

-- Za svakog studenta koji je položio između 15 i 25 bodova i čije ime sadrži malo ili veliko slovo o ili a
-- izdvojiti indeks, ime, prezime, broj prijavljenih ispita, broj različitih predmeta koje je prijavio,
-- broj ispita koje je položio i prosečnu ocenu.
-- Rezultat urediti prema indeksu.
-- TODO

-- Izdvojiti parove studenata čija imena počinju na slovo M i za koje važi
-- da su bar dva ista predmeta položili u istom ispitnom roku.
-- TODO