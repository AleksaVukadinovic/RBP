-- Izdvojiti indekse studenata koji su rođeni u Beogradu ili imaju ocenu 10.
-- Rezultat urediti u opadajućem poretku.
SELECT D.INDEKS
FROM DA.DOSIJE D
WHERE D.MESTORODJENJA LIKE 'Beograd%'
UNION
SELECT I.INDEKS
FROM DA.ISPIT I
WHERE I.OCENA = 10
ORDER BY INDEKS DESC;

-- Izdvojiti indekse studenata koji su rođeni u Beogradu i imaju ocenu 10.
-- Rezultat urediti u opadajućem poretku.
SELECT D.INDEKS
FROM DA.DOSIJE D
WHERE D.MESTORODJENJA LIKE 'Beograd%'
INTERSECT
SELECT I.INDEKS
FROM DA.ISPIT I
WHERE I.OCENA = 10
ORDER BY INDEKS DESC;

-- Izdvojiti indekse studenata koji imaju ocenu 8 i imaju ocenu 10.
-- Rezultat urediti u opadajućem poretku.
SELECT I1.INDEKS
FROM DA.ISPIT I1
WHERE I1.OCENA = 8
INTERSECT
SELECT I2.INDEKS
FROM DA.ISPIT I2
WHERE I2.OCENA = 10
ORDER BY INDEKS DESC;

-- Izdvojiti indekse studenata koji su rođeni u Beogradu i nisu dobili ocenu 10 na nekom ispitu.
-- Rezultat urediti u opadajućem poretku.
SELECT D.INDEKS
FROM DA.DOSIJE D
WHERE D.MESTORODJENJA LIKE 'Beograd%'
INTERSECT
SELECT I.INDEKS
FROM DA.ISPIT I
WHERE I.OCENA < 10
ORDER BY INDEKS;

-- Za svaki polagan ispit izdvojiti indeks, identifikator predmeta i dobijenu ocenu.
-- Vrednost ocene ispisati i slovima. Ako je predmet nepoložen umesto ocene ispisati nepolozen.
SELECT INDEKS,
       IDPREDMETA,
       OCENA,
       CASE
           WHEN OCENA = 10 THEN 'deset'
           WHEN OCENA = 9 THEN 'devet'
           WHEN OCENA = 8 THEN 'osam'
           WHEN OCENA = 7 THEN 'sedam'
           WHEN OCENA = 6 THEN 'sest'
           ELSE 'nepolozen'
           END AS "Ocena slovima"
FROM DA.ISPIT
WHERE STATUS NOT IN ('p', 'n');


-- Klasifikovati predmete prema broju espb bodova na sledeći način:
-- ako predmet ima više od 15 espb bodova tada pripada I kategoriji
-- ako je broj espb bodova predmeta u intervalu [10,15] tada pripada II kategoriji
-- inače predmet pripada III kategoriji.
-- Izdvojiti naziv predmeta, espb bodove i kategoriju.
SELECT P.NAZIV,
       P.ESPB,
       CASE
           WHEN P.ESPB > 15 THEN 'I kategorija'
           WHEN P.ESPB <= 15 AND P.ESPB >= 10 THEN 'II kategorija'
           ELSE 'III kategorija'
           END AS "Kategorija"
FROM DA.PREDMET P;

-- Ispisati trenutno vreme.
SELECT DISTINCT CURRENT_TIME AS "Trenutno vreme"
FROM DA.DOSIJE D;

-- 2. nacin
VALUES CURRENT_TIME;

-- Ispisati trenutnog korisnika i ime podrazumevane sheme.
VALUES USER, CURRENT_SCHEMA;

-- Izračunati koji je dan u nedelji (njegovo ime) bio 3.11.2019.
VALUES DAYNAME('3.11.2019');

-- Za današnji datum izračunati
-- koji je dan u godini
-- u kojoj je nedelji u godini
-- koji je dan u nedelji
-- ime dana
-- ime meseca.
VALUES (DAYOFYEAR(CURRENT_DATE), WEEK(CURRENT_DATE), DAYOFWEEK(CURRENT_DATE), DAYNAME(CURRENT_DATE),
        MONTHNAME(CURRENT_DATE));

-- Izdvojiti sekunde iz trenutnog vremena.
VALUES SECOND(CURRENT_TIME);

-- Izračunati koliko vremena je prošlo između 6.8.2005. i 11.11.2008.
VALUES DATE('11.11.2018') - DATE('6.8.2015');

-- Izračunati koji će datum biti za 12 godina, 5 meseci i 25 dana.
VALUES (CURRENT_DATE + 12 YEARS + 5 MONTHS + 25 DAYS);

-- Izdvojiti ispite koji su održani posle 28. septembra 2020. godine.
SELECT *
FROM DA.ISPIT
WHERE DATE(DATPOLAGANJA) > DATE('28.9.2020');

-- Pronaći ispite koji su održani u poslednjih 8 meseci.
SELECT *
FROM DA.ISPIT
WHERE DATE(DATPOLAGANJA) > CURRENT_DATE - 8 MONTHS;

-- Za sve ispite koji su održani u poslednjih 5 godina izračunati koliko je godina, meseci i dana prošlo od njihovog održavanja.
-- Izdvojiti indeks, naziv predmeta, ocenu, broj godina, broj meseci i broj dana.
SELECT I.INDEKS,
       P.NAZIV,
       I.OCENA,
       YEARS_BETWEEN(CURRENT_DATE, DATPOLAGANJA)  GODINA,
       MONTHS_BETWEEN(CURRENT_DATE, DATPOLAGANJA) MESECI,
       DAYS_BETWEEN(CURRENT_DATE, DATPOLAGANJA)   DANA,
       YEAR(CURRENT_DATE - DATPOLAGANJA)          GODINA,
       MONTH(CURRENT_DATE - DATPOLAGANJA)         MESECI,
       DAY(CURRENT_DATE - DATPOLAGANJA)           DANA
FROM DA.ISPIT I
         JOIN DA.PREDMET P ON I.IDPREDMETA = P.ID
WHERE DATE(I.DATPOLAGANJA) > CURRENT_DATE - 5 YEARS;

-- Izdvojiti indeks, ime, prezime, mesto rođenja i inicijale studenata.
-- Ime i prezime napisati u jednoj koloni, a za studente rođene u Beogradu kao mesto rođenja ispisati Bg.
SELECT D.INDEKS,
       CONCAT(D.IME || ' ', D.PREZIME)                                              AS "Ime i prezime",
       CASE WHEN D.MESTORODJENJA LIKE 'Beograd%' THEN 'Bg' ELSE D.MESTORODJENJA END AS "Mesto rodjenja"
FROM DA.DOSIJE D;

-- Za priznate ispite izdvojiti indeks, naziv predmeta i dobijenu ocenu. Ako je ocena nepoznata,
-- umesto NULL vrednosti ispisati -1.

SELECT INDEKS, NAZIVPREDMETA, CASE WHEN OCENA IS NULL THEN -1 ELSE OCENA END
FROM DA.PRIZNATISPIT;


-- Prikazati trenutno vreme i trenutni datum u
-- ISO formatu
-- USA formatu
-- EUR formatu.
VALUES CHAR(CURRENT_DATE, ISO), CHAR(CURRENT_DATE, USA), CHAR(CURRENT_DATE, EUR), CHAR(CURRENT_TIME, ISO), CHAR(CURRENT_TIME, USA), CHAR(CURRENT_TIME, EUR);

-- Ako je predmetima potrebno uvećati broj espb bodova za 20% prikazati koliko će svaki predmet imati espb bodova nakon uvećanja.
-- Uvećani broj bodova prikazati sa dve decimale.
SELECT OZNAKA,
       NAZIV,
       DECIMAL(ESPB * 1.2, 6, 2) UVECANO
FROM DA.PREDMET;

-- Ako je predmetima potrebno uvećati broj espb bodova za 20% prikazati koliko će espb bodova imati predmeti koji nakon uvećanja imaju više od 8 bodova.
-- Uvećani broj espb bodova zaokružiti na veću ili jednaku celobrojnu vrednost.
SELECT OZNAKA,
       NAZIV,
       CEIL(ESPB * 1.2) UVECANO
FROM DA.PREDMET
WHERE ESPB * 1.2 > 8;

-- Pronaći indekse studenata koji su jedini položili ispit iz nekog predmeta sa ocenom 10.
-- Za studenta sa brojem indeksa GGGGBBBB izdvojiti indeks u formatu BBBB/GGGG.
SELECT SUBSTR(INDEKS, 5) || '/' || SUBSTR(INDEKS, 1, 4), NAZIV
FROM DA.ISPIT I
         JOIN DA.PREDMET P
              ON I.IDPREDMETA = P.ID
WHERE OCENA = 10
  AND STATUS = 'o'
  AND NOT EXISTS (SELECT *
                  FROM DA.ISPIT I1
                  WHERE I.INDEKS <> I1.INDEKS
                    AND I.IDPREDMETA = I1.IDPREDMETA
                    AND I1.OCENA = 10
                    AND I1.STATUS = 'o');

-- Za svaki ispitni rok koji je održan između 2000/2001. i 2020/2021. školske godine
-- izdvojiti imena dana u kojima su polagani ispiti u tom roku.
-- Izdvojiti naziv ispitnog roka i ime dana.
-- Za ispitne rokove u kojima nije polagan nijedan ispit ili je datum polaganja nepoznat
-- umesto dana ispisati 'nije bilo ispita ili je nepoznat datum'.
SELECT DISTINCT IR.NAZIV,
                COALESCE(DAYNAME(I.DATPOLAGANJA), 'Nije bilo ispita ili nepoznat datum')
FROM DA.ISPITNIROK IR
         LEFT JOIN DA.ISPIT AS I
                   ON IR.OZNAKAROKA = I.OZNAKAROKA AND
                      IR.SKGODINA = I.SKGODINA
WHERE IR.SKGODINA BETWEEN 2000 AND 2020;


-- U prethodnom zadatku za nepoznat datum ispisati poruku u zavisnosti da li ispit nije održan ili je datum nepoznat.
SELECT DISTINCT IR.NAZIV,
                COALESCE(DAYNAME(I.DATPOLAGANJA), 'Nepoznat datum')
FROM DA.ISPITNIROK IR
         JOIN DA.ISPIT AS I
              ON IR.OZNAKAROKA = I.OZNAKAROKA AND
                 IR.SKGODINA = I.SKGODINA
WHERE IR.SKGODINA BETWEEN 2000 AND 2020
UNION
SELECT DISTINCT IR.NAZIV, ('Nije bilo ispita')
FROM DA.ISPITNIROK IR
WHERE NOT EXISTS(SELECT *
                 FROM DA.ISPIT I
                 WHERE I.OZNAKAROKA = IR.OZNAKAROKA
                   AND I.SKGODINA = IR.SKGODINA);