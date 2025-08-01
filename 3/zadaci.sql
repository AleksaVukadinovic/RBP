-- Izdvojiti nazive predmeta koje je POLAGAO student sa indeksom 22/2017.
SELECT P.NAZIV
FROM DA.PREDMET P
WHERE P.ID IN (SELECT I.IDPREDMETA
               FROM DA.ISPIT I
               WHERE I.INDEKS = 20170022
                 AND STATUS NOT IN ('p', 'n'));

--  Izdvojiti ime i prezime studenta koji ima ispit položen sa ocenom 9.
SELECT D.IME, D.PREZIME
FROM DA.DOSIJE D
WHERE D.INDEKS IN (SELECT I.INDEKS
                   FROM DA.ISPIT I
                   WHERE I.OCENA = 9
                     AND STATUS = 'o');

-- Izdvojiti indekse studenata koji su položili bar jedan predmet koji nije položio student sa indeksom 22/2017.
SELECT DISTINCT INDEKS
FROM DA.ISPIT
WHERE OCENA > 5
  AND STATUS = 'o'
  AND IDPREDMETA NOT IN (SELECT IDPREDMETA
                         FROM DA.ISPIT
                         WHERE OCENA > 5
                           AND STATUS = 'o'
                           AND INDEKS = 20170022);

-- Korišćenjem egzistencijalnog kvantifikatora exists izdvojiti nazive predmeta koje je položio student sa indeksom 22/2017.
SELECT DISTINCT P.NAZIV
FROM DA.PREDMET P
WHERE EXISTS(SELECT *
             FROM DA.ISPIT I
             WHERE I.INDEKS = 20172022);

-- Izdvojiti naziv predmeta čiji je kurs organizovan u svim školskim godinama o kojima postoje podaci u bazi podataka.
SELECT DISTINCT P.NAZIV
FROM DA.PREDMET P
WHERE NOT EXISTS(SELECT *
                 FROM DA.SKOLSKAGODINA SG
                 WHERE NOT EXISTS(SELECT *
                                  FROM DA.KURS K
                                  WHERE K.IDPREDMETA = P.ID
                                    AND SG.SKGODINA = K.SKGODINA));

-- Izdvojiti podatke o studentu koji je upisao sve školske godine o kojima postoje podaci u bazi podataka.
SELECT *
FROM DA.DOSIJE AS D
WHERE NOT EXISTS (SELECT *
                  FROM DA.SKOLSKAGODINA SG
                  WHERE NOT EXISTS (SELECT *
                                    FROM DA.UPISGODINE UG
                                    WHERE D.INDEKS = UG.INDEKS
                                      AND SG.SKGODINA = UG.SKGODINA));

-- Izdvojiti indekse studenata koji su polagali u svim ispitnim rokovima.
SELECT D.INDEKS
FROM DA.DOSIJE D
WHERE NOT EXISTS(SELECT *
                 FROM DA.ISPITNIROK IR
                 WHERE NOT EXISTS(SELECT *
                                  FROM DA.ISPIT I
                                  WHERE I.INDEKS = D.INDEKS
                                    AND IR.SKGODINA = I.SKGODINA
                                    AND I.OZNAKAROKA = IR.OZNAKAROKA
                                    AND I.STATUS NOT IN ('p', 'n')));

-- Izdvojiti indekse studenata koji su polagali u svim ispitnim rokovima održanim u 2018/2019. šk. godini.
SELECT D.INDEKS
FROM DA.DOSIJE D
WHERE NOT EXISTS(SELECT *
                 FROM DA.ISPITNIROK IR
                 WHERE IR.SKGODINA = 2018
                   AND NOT EXISTS(SELECT *
                                  FROM DA.ISPIT I
                                  WHERE I.INDEKS = D.INDEKS
                                    AND I.SKGODINA = IR.SKGODINA
                                    AND I.OZNAKAROKA = IR.OZNAKAROKA
                                    AND I.STATUS NOT IN ('p', 'n')));


-- Izdvojiti podatke o predmetima sa najvećim brojem espb bodova.
SELECT *
FROM DA.PREDMET P1
WHERE NOT EXISTS(SELECT *
                 FROM DA.PREDMET P2
                 WHERE P2.ESPB > P1.ESPB);

-- Izdvojiti podatke o studentima sa najranijim datumom diplomiranja.
SELECT *
FROM DA.DOSIJE D1
WHERE NOT EXISTS(SELECT *
                 FROM DA.DOSIJE D2
                 WHERE D2.DATDIPLOMIRANJA < D1.DATDIPLOMIRANJA
                   AND D1.DATDIPLOMIRANJA IS NOT NULL
                   AND D2.DATDIPLOMIRANJA IS NOT NULL);
-- 2. nacin
SELECT *
FROM DA.DOSIJE D
WHERE D.DATDIPLOMIRANJA <= ALL (SELECT DATDIPLOMIRANJA
                                FROM DA.DOSIJE
                                WHERE D.DATDIPLOMIRANJA IS NOT NULL);

-- Izdvojiti podatke o svim studentima osim onih sa najranijim datumom diplomiranja.
SELECT *
FROM DA.DOSIJE
WHERE DATDIPLOMIRANJA IS NULL
   OR NOT DATDIPLOMIRANJA <= ALL (SELECT DATDIPLOMIRANJA
                                  FROM DA.DOSIJE
                                  WHERE DATDIPLOMIRANJA IS NOT NULL);


-- Izdvojiti podatke o predmetima koje su upisali neki studenti.
SELECT *
FROM DA.PREDMET P
WHERE P.ID = ANY (SELECT UK.IDPREDMETA
                  FROM DA.UPISANKURS UK);

-- Za studente koji su polagali ispit u ispitnom roku održanom u 2018/2019. šk. godini izdvojiti podatke o položenim ispitima.
-- Izdvojiti indeks, ime, prezime studenta, naziv položenog predmeta, oznaku ispitnog roka i školsku godinu u kojoj je ispit položen.
SELECT D.INDEKS, D.IME, D.PREZIME, P.NAZIV, I.OZNAKAROKA, I.SKGODINA
FROM DA.DOSIJE D
         JOIN DA.ISPIT I ON D.INDEKS = I.INDEKS AND OCENA > 5 AND STATUS = 'o'
         JOIN DA.PREDMET P ON I.IDPREDMETA = P.ID
WHERE EXISTS(SELECT *
             FROM DA.ISPIT I1
             WHERE I1.INDEKS = D.INDEKS
               AND I1.SKGODINA = 2018
               AND I.STATUS NOT IN ('p', 'n'));

-- Izdvojiti podatke o predmetima koje su polagali svi studenti iz Berana koji studiraju smer sa oznakom I.
SELECT *
FROM DA.PREDMET P
WHERE NOT EXISTS(SELECT *
                 FROM DA.DOSIJE D
                          JOIN DA.STUDIJSKIPROGRAM SP
                               ON D.IDPROGRAMA = SP.ID AND SP.OZNAKA = 'I' AND MESTORODJENJA = 'Berane'
                 WHERE NOT EXISTS(SELECT *
                                  FROM DA.ISPIT I
                                  WHERE I.INDEKS = D.INDEKS
                                    AND I.IDPREDMETA = P.ID
                                    AND STATUS NOT IN ('p', 'n')));