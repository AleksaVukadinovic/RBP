-- Predmeti se kategorišu kao laki ukoliko nose manje od 6 bodova, kao teški ukoliko nose više od 8 bodova, inače su srednje teški.
-- Prebrojati koliko predmeta pripada kojoj kategoriji. Izdvojiti kategoriju i broj predmeta iz te kategorije.

-- MOJE RESENJE
WITH PREDMETI_PO_TEZINI AS (SELECT P.ID,
                                   P.NAZIV,
                                   (CASE
                                        WHEN P.ESPB < 6 THEN 'Laki'
                                        WHEN P.ESPB >= 6 AND P.ESPB <= 8 THEN 'Srednji'
                                        ELSE 'Teski' END) AS TEZINA
                            FROM DA.PREDMET P)
SELECT DISTINCT (SELECT COUNT(P.ID) FROM PREDMETI_PO_TEZINI P WHERE P.TEZINA = 'Laki')    AS BROJ_LAKIH,
                (SELECT COUNT(P.ID) FROM PREDMETI_PO_TEZINI P WHERE P.TEZINA = 'Srednji') AS BROJ_SREDNJIH,
                (SELECT COUNT(P.ID) FROM PREDMETI_PO_TEZINI P WHERE P.TEZINA = 'Teski')   AS BROJ_TESKIH
FROM PREDMETI_PO_TEZINI P
GROUP BY TEZINA;

-- RESENJE SA VEZBI
WITH PREDMET_KATEGORIJA AS (SELECT ID,
                                   CASE
                                       WHEN ESPB < 6 THEN 'LAK'
                                       WHEN ESPB > 8 THEN 'SREDNJE TEZAK'
                                       ELSE 'TEZAK'
                                       END AS TEZINA
                            FROM DA.PREDMET)
SELECT TEZINA, COUNT(*)
FROM PREDMET_KATEGORIJA
GROUP BY TEZINA;

-- Izračunati koliko studenata je položilo više od 10 bodova.
SELECT COUNT(*) AS BROJ_STUDENATA
FROM (SELECT I.INDEKS
      FROM DA.ISPIT I
               JOIN DA.PREDMET P ON I.IDPREDMETA = P.ID
      WHERE OCENA > 5
        AND STATUS = 'o'
      GROUP BY INDEKS
      HAVING SUM(ESPB) > 10);

-- Naći broj ispitnih rokova u kojima su studenti položili bar 2 različita predmeta.
WITH STUDENT_ROK_POLOZENO AS (SELECT I.INDEKS, I.OZNAKAROKA, I.SKGODINA, COUNT(*) AS POLOZENO
                              FROM DA.ISPIT I
                              WHERE I.STATUS = 'o'
                                AND OCENA > 5
                              GROUP BY I.INDEKS, I.OZNAKAROKA, I.SKGODINA
                              HAVING COUNT(*) > 2)
SELECT COUNT(DISTINCT SRP.OZNAKAROKA || SRP.SKGODINA)
FROM STUDENT_ROK_POLOZENO SRP;

-- Za svaki predmet izdvojiti identifikator i broj različitih studenata koji su ga polagali.
-- Uz identifikatore predmeta koje niko nije polagao izdvojiti 0.

-- moje resenje
WITH POLAGANI_PREDMETI AS (SELECT P.ID,
                                  (SELECT COUNT(DISTINCT I.INDEKS)
                                   FROM DA.ISPIT I
                                   WHERE I.IDPREDMETA = P.ID
                                     AND I.OCENA > 5
                                     AND I.STATUS = 'o') AS POLAGANJA
                           FROM DA.PREDMET P
                                    LEFT JOIN DA.ISPIT I ON P.ID = I.IDPREDMETA)
SELECT DISTINCT PP.ID, COALESCE(PP.POLAGANJA, 0)
FROM POLAGANI_PREDMETI PP
ORDER BY 2;

-- resenje sa vezbi
SELECT IDPREDMETA, COUNT(DISTINCT INDEKS) "BROJ STUDENATA"
FROM DA.ISPIT
WHERE STATUS NOT IN ('p', 'n')
GROUP BY IDPREDMETA
UNION
SELECT ID, 0
FROM DA.PREDMET
WHERE NOT EXISTS(SELECT *
                 FROM DA.ISPIT I
                 WHERE ID = IDPREDMETA
                   AND STATUS NOT IN ('p', 'n'))
ORDER BY 2;

-- Za studenta koji ima ocenu 8 ili 9 izračunati iz koliko ispita je dobio ocenu 8 i iz koliko ispita je dobio ocenu 9.
-- Izdvojiti indeks studenta, broj ispita iz kojih je student dobio ocenu 8 i broj ispita iz kojih je student dobio ocenu 9.
SELECT INDEKS,
       SUM(CASE WHEN OCENA = 8 THEN 1 ELSE 0 END) OSAM,
       SUM(CASE WHEN OCENA = 9 THEN 1 ELSE 0 END) DEVET
FROM DA.ISPIT
WHERE OCENA = 8
   OR OCENA = 9
GROUP BY INDEKS
ORDER BY INDEKS;

-- Studentima koji su položili neki ispit, izdvojti pored imena i prezimena, naziv predmeta koji su položili iz prvog pokušaja.
WITH INDEKS_PREDMET_POLAGANO AS (SELECT INDEKS,
                                        NAZIV,
                                        COUNT(*)                                                    POLAGANO,
                                        SUM(CASE WHEN OCENA > 5 AND STATUS = 'o' THEN 1 ELSE 0 END) POLOZENO
                                 FROM DA.ISPIT I
                                          JOIN DA.PREDMET P
                                               ON I.IDPREDMETA = P.ID
                                 GROUP BY INDEKS, NAZIV, P.ID)
SELECT *
FROM DA.DOSIJE D
         JOIN INDEKS_PREDMET_POLAGANO I
              ON D.INDEKS = I.INDEKS
WHERE POLAGANO = 1
  AND POLOZENO = 1;


-- Izdvojiti ime i prezime studenta i naziv ispitnog roka u kome student ima svoj najmanji procenat uspešnosti na ispitima.
-- Izdvojiti i procenat uspešnosti na ispitima u tom roku kao decimalan broj sa 2 cifre iza decimalne tačke.
-- Procenat uspešnosti studenta u ispitnom roku se računa kao procenat broja položenih ispita u odnosu na broj prijavljenih ispita.
-- Izdvojiti samo podatke za studente iz Aranđelovca i koji u tom roku imaju najmanji procenat uspešnosti u poređenju sa ostalim studentima.
-- TODO

-- Za sva imena studenata izdvojiti predmete na kojima su studenti sa tim imenom dobili najveću ocenu. Ukoliko su za neko ime studenti sa tim imenom iz više predmeta dobili maksimalnu ocenu, izdvojiti sve takve predmete. Izdvojiti ime, naziv predmeta i dobijenu ocenu. Pored toga, izdvojiti takozvani dugi kod imena. Dugi kod imena dobija se na sledeći način:
-- ukoliko je ocena koja je izdvojena uz ime nepoznata, dugi kod jeste niska 'NULL';
-- ukoliko je ocena koja je izdvojena uz ime manja od deset, dugi kod jeste niska koja se dobija prema forumli inicijale iz imena i naziva predmeta * ocena
-- Npr. ako je Mirko položio Analizu 3 sa ocenom 6, kod je 'MAMAMAMAMAMA'.
-- ukoliko je dobijena ocena deset, kod predstavlja poslednje slovo imena ponovljeno 10 puta. Kolonu nazvati dugi kod.
-- Rezultat urediti prema imenu u opadajućem poretku.
-- TODO
