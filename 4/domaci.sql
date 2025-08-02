-- Izdvojiti ime i prezime studenata za koga važi da postoji student koji je rođen u istom mestu i koji je godinu dana ranije upisao fakultet.
SELECT D1.IME, D1.PREZIME
FROM DA.DOSIJE D1
WHERE EXISTS (SELECT *
              FROM DA.DOSIJE D2
                       JOIN DA.UPISGODINE UG2 ON D2.INDEKS = UG2.INDEKS
                       JOIN DA.UPISGODINE UG1 ON D1.INDEKS = UG1.INDEKS
              WHERE D2.MESTORODJENJA = D1.MESTORODJENJA
                AND ADD_MONTHS(UG2.DATUPISA, 12) = UG1.DATUPISA
                AND D2.INDEKS <> D1.INDEKS);

-- Napisati SQL-u upit koji za svaki predmet izdvaja studenta koji je taj predmet položio u poslednjih 5 godina i 3 meseca.
-- Izdvojiti naziv predmeta i ime i prezime studenta.
-- Ime i prezime studenta izdvojiti kao jednu nisku i kolonu koja sadrži ime i prezime studenta nazvati Student.
-- Ako nijedan student nije položio predmet u zadatom periodu, umesto imena i prezimena studenta ispisati Nema studenata.
-- Rezultat urediti prema nazivu predmeta.

SELECT P.NAZIV,
       CASE
           WHEN I.OCENA > 5 AND I.STATUS = 'o' AND I.DATPOLAGANJA > CURRENT_DATE - 63 MONTHS
               THEN D.IME || ' ' || D.PREZIME
           ELSE 'Nema studenata'
           END AS "Student"
FROM DA.PREDMET P
         LEFT JOIN DA.ISPIT I ON P.ID = I.IDPREDMETA
         LEFT JOIN DA.DOSIJE D ON I.INDEKS = D.INDEKS
ORDER BY P.NAZIV;


-- Za sve studente koji su fakultet upisali u julu ili septembru kod kojih su ime i prezime iste dužine,
-- izdvojiti informacije o polaganjima svih predmeta čiji naziv počinje slovom P.
-- Izdvojiti indeks studenta, ime i prezime studenta u obliku prezime razmak ime (kolonu nazvati Prezime pa ime), naziv predmeta i dobijenu ocenu.
-- U rezultatu izdvojiti i podatke o studentima koji su fakultet upisali u julu ili septembru, a nisu polagali predmet čiji naziv pocinje slovom P.
-- U ovom slučaju umesto predmeta ispisati ----, a umesto ocene -1.

SELECT D.INDEKS,
       (D.PREZIME || ' ' || D.IME) AS "Prezime pa ime",
       COALESCE(P.NAZIV, '----')   AS NAZIV,
       COALESCE(I.OCENA, -1)       AS OCENA
FROM DA.DOSIJE D
         LEFT JOIN DA.ISPIT I ON D.INDEKS = I.INDEKS
         LEFT JOIN DA.PREDMET P ON I.IDPREDMETA = P.ID AND P.NAZIV LIKE 'P%'
WHERE LENGTH(D.IME) = LENGTH(D.PREZIME)
  AND (MONTH(DATUPISA) = 7 OR MONTH(DATUPISA) = 9);


-- Pronaći nazive ispitnih rokova u kojima su polagali svi studenti koji imaju bar jednu ocenu 10.
SELECT IR.NAZIV
FROM DA.ISPITNIROK IR
WHERE NOT EXISTS (SELECT *
                  FROM (SELECT DISTINCT I1.INDEKS
                        FROM DA.ISPIT I1
                        WHERE I1.OCENA = 10) AS StudentiSaDesetkom
                  WHERE NOT EXISTS (SELECT *
                                    FROM DA.ISPIT I2
                                    WHERE I2.INDEKS = StudentiSaDesetkom.INDEKS
                                      AND I2.SKGODINA = IR.SKGODINA
                                      AND I2.OZNAKAROKA = IR.OZNAKAROKA));


-- Ispisati nazive ispitnih rokove takvih da su svi studenti dobili 10 u tom roku.
SELECT IR.NAZIV
FROM DA.ISPITNIROK IR
WHERE NOT EXISTS(SELECT *
                 FROM DA.ISPIT I
                 WHERE IR.SKGODINA = I.SKGODINA
                   AND I.OZNAKAROKA = IR.OZNAKAROKA
                   AND I.OCENA < 10);