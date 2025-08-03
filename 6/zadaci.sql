-- Predmeti se kategorišu kao laki ukoliko nose manje od 6 bodova,
-- kao teški ukoliko nose više od 8 bodova, inače su srednje teški.
-- Prebrojati koliko predmeta pripada kojoj kategoriji.
-- Izdvojiti kategoriju i broj predmeta iz te kategorije.

WITH PREDMET_KATEGORIJA AS (SELECT P.NAZIV,
                                   (CASE
                                        WHEN P.ESPB < 6 THEN 'LAKI'
                                        WHEN P.ESPB BETWEEN 6 AND 8 THEN 'SREDNJI'
                                        ELSE 'TESKI' END) AS KATEGORIJA
                            FROM DA.PREDMET P)
SELECT SUM(CASE WHEN PREDMET_KATEGORIJA.KATEGORIJA = 'LAKI' THEN 1 ELSE 0 END)    AS BROJ_LAKIH,
       SUM(CASE WHEN PREDMET_KATEGORIJA.KATEGORIJA = 'SREDNJI' THEN 1 ELSE 0 END) AS SREDNJIH,
       SUM(CASE WHEN PREDMET_KATEGORIJA.KATEGORIJA = 'TESKI' THEN 1 ELSE 0 END)   AS BROJ_TESKIH
FROM PREDMET_KATEGORIJA;

WITH PREDMET_KATEGORIJA AS (SELECT P.NAZIV,
                                   (CASE
                                        WHEN P.ESPB < 6 THEN 'LAKI'
                                        WHEN P.ESPB BETWEEN 6 AND 8 THEN 'SREDNJI'
                                        ELSE 'TESKI' END) AS KATEGORIJA
                            FROM DA.PREDMET P)
SELECT PK.KATEGORIJA, COUNT(*)
FROM PREDMET_KATEGORIJA PK
GROUP BY PK.KATEGORIJA;

-- Izračunati koliko studenata je položilo više od 10 bodova.

WITH STUDENT_BODOVI AS (SELECT I.INDEKS, SUM(P.ESPB) AS BODOVI
                        FROM DA.ISPIT I
                                 JOIN DA.PREDMET P ON I.IDPREDMETA = P.ID
                        WHERE I.OCENA > 5
                          AND I.STATUS = 'o'
                        GROUP BY I.INDEKS)
SELECT COUNT(*) AS "BROJ STUDENATA"
FROM STUDENT_BODOVI SB
WHERE SB.BODOVI > 10;

-- Naći broj ispitnih rokova u kojima su studenti položili bar 2 različita predmeta.

WITH STUDENT_ROK_POLOZENO AS (SELECT I.INDEKS, I.OZNAKAROKA, I.SKGODINA, COUNT(*) AS POLOZENO
                              FROM DA.ISPIT I
                              WHERE I.OCENA > 5
                                AND I.STATUS = 'o'
                              GROUP BY I.INDEKS, I.OZNAKAROKA, I.SKGODINA
                              HAVING COUNT(*) > 2)
SELECT COUNT(DISTINCT SRP.OZNAKAROKA || SRP.SKGODINA)
FROM STUDENT_ROK_POLOZENO SRP;

-- Za svaki predmet izdvojiti identifikator i broj različitih studenata koji su ga polagali.
-- Uz identifikatore predmeta koje niko nije polagao izdvojiti 0.

SELECT P.ID, COALESCE(COUNT(DISTINCT I.INDEKS), 0)
FROM DA.PREDMET P
         LEFT JOIN DA.ISPIT I ON P.ID = I.IDPREDMETA AND I.STATUS NOT IN ('p', 'n')
GROUP BY P.ID;

-- Za studenta koji ima ocenu 8 ili 9 izračunati iz koliko ispita je dobio ocenu 8 i iz koliko ispita je dobio ocenu 9.
-- Izdvojiti indeks studenta, broj ispita iz kojih je student dobio ocenu 8 i broj ispita iz kojih je student dobio ocenu 9.

SELECT I.INDEKS,
       SUM(CASE WHEN I.OCENA = 8 THEN 1 ELSE 0 END) AS BROJ_OSMICA,
       SUM(CASE WHEN I.OCENA = 9 THEN 1 ELSE 0 END) AS BROJ_DEVETKI
FROM DA.ISPIT I
WHERE OCENA = 8
   OR OCENA = 9
GROUP BY I.INDEKS;

-- Studentima koji su položili neki ispit, izdvojti pored imena i prezimena,
-- naziv predmeta koji su položili iz prvog pokušaja.

WITH STUNDET_PREDMET_POKUSAJI AS (SELECT D.INDEKS,
                                         D.IME,
                                         D.PREZIME,
                                         P.NAZIV,
                                         COUNT(*)                                                        AS POKUSAJI,
                                         SUM(CASE WHEN I.OCENA > 5 AND I.STATUS = 'o' THEN 1 ELSE 0 END) AS POLOZENO
                                  FROM DA.DOSIJE D
                                           JOIN DA.ISPIT I ON D.INDEKS = I.INDEKS
                                           JOIN DA.PREDMET P ON I.IDPREDMETA = P.ID
                                  GROUP BY D.IME, D.PREZIME, P.NAZIV, D.INDEKS)
SELECT *
FROM STUNDET_PREDMET_POKUSAJI
WHERE POKUSAJI = 1
  AND POLOZENO = 1;

-- Izdvojiti ime i prezime studenta i naziv ispitnog roka u kome student ima svoj najmanji procenat uspešnosti na ispitima.
-- Izdvojiti i procenat uspešnosti na ispitima u tom roku kao decimalan broj sa 2 cifre iza decimalne tačke.
-- Procenat uspešnosti studenta u ispitnom roku se računa kao procenat broja položenih ispita u odnosu na broj prijavljenih ispita.
-- Izdvojiti samo podatke za studente iz Aranđelovca i koji u tom roku imaju najmanji procenat uspešnosti u poređenju sa ostalim studentima.

-- !!! NETACNO RESENJE TODO: FIX
WITH STUDENT_USPESNOST AS (SELECT I.INDEKS,
                                  IR.NAZIV,
                                  DECIMAL(SUM(CASE WHEN I.OCENA > 5 AND I.STATUS = 'o' THEN 1.0 ELSE 0 END) /
                                          (COUNT(*) + 0.0), 6, 2) AS USPESNOST
                           FROM DA.ISPIT I
                                    JOIN DA.ISPITNIROK IR ON I.OZNAKAROKA = IR.OZNAKAROKA AND I.SKGODINA = IR.SKGODINA
                           GROUP BY I.INDEKS, IR.NAZIV)
SELECT D.IME, D.PREZIME, SU.NAZIV, SU.USPESNOST
FROM DA.DOSIJE D
         JOIN STUDENT_USPESNOST SU ON D.INDEKS = SU.INDEKS
WHERE D.MESTORODJENJA = 'Arandjelovac'
  AND SU.USPESNOST = (SELECT MIN(SU2.USPESNOST) FROM STUDENT_USPESNOST SU2);

-- Za sva imena studenata izdvojiti predmete na kojima su studenti sa tim imenom dobili najveću ocenu. Ukoliko su za neko ime studenti sa tim imenom iz više predmeta dobili maksimalnu ocenu, izdvojiti sve takve predmete. Izdvojiti ime, naziv predmeta i dobijenu ocenu. Pored toga, izdvojiti takozvani dugi kod imena. Dugi kod imena dobija se na sledeći način:
-- ukoliko je ocena koja je izdvojena uz ime nepoznata, dugi kod jeste niska 'NULL';
-- ukoliko je ocena koja je izdvojena uz ime manja od deset, dugi kod jeste niska koja se dobija prema forumli inicijale iz imena i naziva predmeta * ocena
-- Npr. ako je Mirko položio Analizu 3 sa ocenom 6, kod je 'MAMAMAMAMAMA'.
-- ukoliko je dobijena ocena deset, kod predstavlja poslednje slovo imena ponovljeno 10 puta. Kolonu nazvati dugi kod.
-- Rezultat urediti prema imenu u opadajućem poretku.
-- TODO
