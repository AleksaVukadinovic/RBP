-- 1. Izdvojiti podatke o studentima čiji je datum diplomiranja nepoznat.
SELECT *
FROM DA.DOSIJE
WHERE DATDIPLOMIRANJA IS NULL;

-- 2. Izdvojiti podatke o studentima čiji datum diplomiranja nije nepoznat.
SELECT *
FROM DA.DOSIJE
WHERE DATDIPLOMIRANJA IS NOT NULL;

-- 3. Prikazati podatke o studentima i ispitima.
SELECT *
FROM DA.DOSIJE,
     DA.ISPIT;

-- 4. Prikazati podatke o studentima i njihovim ispitima.
SELECT *
FROM DA.DOSIJE D
         JOIN DA.ISPIT I on D.INDEKS = I.INDEKS;

-- 5. Prikazati podatke o studentima i njihovim ispitima koji su održani 28.1.2016.
-- Izdvojiti indeks, ime i prezime studenta, id predmeta i ocenu.
SELECT D.INDEKS, D.IME, D.PREZIME, I.IDPREDMETA, I.OCENA
FROM DA.DOSIJE D
         JOIN DA.ISPIT I on D.INDEKS = I.INDEKS
WHERE I.DATPOLAGANJA = '28.1.2016';

-- 6. Izdvojiti podatke o položenim ispitima.
-- Prikazati indeks, ime i prezime studenta koji je položio ispit, naziv položenog predmeta i ocenu.
SELECT D.INDEKS, D.IME, D.PREZIME, P.NAZIV, I.OCENA
FROM DA.DOSIJE D
         JOIN DA.ISPIT I ON D.INDEKS = I.INDEKS
         JOIN DA.PREDMET P ON I.IDPREDMETA = P.ID
WHERE I.STATUS = 'o';

-- 7. Izdvojiti podatke o studentima za koje važi da su diplomirali dana kada je održan neki ispit.
SELECT *
FROM DA.DOSIJE D
         JOIN DA.ISPIT I ON D.DATDIPLOMIRANJA = I.DATPOLAGANJA;

-- 8. Izdvojiti parove predmeta koji imaju isti broj espb bodova.
-- Izdvojiti oznake predmeta i broj espb bodova.
SELECT *
FROM DA.PREDMET P1
         JOIN DA.PREDMET P2 ON P1.ESPB = P2.ESPB and P1.ID <> P2.ID;

-- 9. Izdvojiti indeks, ime i prezime studenata čije prezime sadrži malo slovo 'a' na 4. poziciji
-- i završava na malo slovo 'c' i koji su predmet čiji je broj espb bodova između 2 i 10
-- položili sa ocenom 6, 8 ili 10 između 5. januara 2018. i 15. decembra 2018.
-- Rezultat urediti prema prezimenu u rastućem poretku i imenu u opadajućem poretku.
SELECT D.INDEKS, D.IME, D.PREZIME
FROM DA.DOSIJE D
         JOIN DA.ISPIT I ON D.INDEKS = I.INDEKS
         JOIN DA.PREDMET P ON I.IDPREDMETA = P.ID
WHERE D.PREZIME LIKE '___a%C'
  AND P.ESPB BETWEEN 2 AND 10
  AND I.STATUS = 'o'
  AND I.OCENA IN (6, 8, 10)
  AND DATPOLAGANJA BETWEEN '5.1.2018' AND '15.12.2018'
ORDER BY D.PREZIME ASC, D.IME DESC;

-- 10. Za svaki predmet koji može da se sluša na nekom studijskom programu
-- izdvojiti uslovne predmete tog predmeta.
-- Izdvojiti identifikator studijskog programa, identifikator predmeta,
-- vrstu tog predmeta (obavezan ili izborni) na studijskom programu i identifikator uslovnog predmeta.
-- Izdvojiti i predmete koji nemaju uslovne predmete.
SELECT PP.IDPROGRAMA, PP.IDPREDMETA, PP.VRSTA, UP.IDUSLOVNOGPREDMETA
FROM DA.PREDMETPROGRAMA PP
         LEFT JOIN DA.USLOVNIPREDMET UP
                   ON PP.IDPREDMETA = UP.IDPREDMETA AND PP.IDPROGRAMA = UP.IDPROGRAMA
ORDER BY PP.IDPROGRAMA;

-- 11. U prethodnom zadatku pored identifikatora predmeta dodati njihove nazive.
SELECT PP.IDPROGRAMA, PP.IDPREDMETA, P1.NAZIV, PP.VRSTA, UP.IDUSLOVNOGPREDMETA, P2.NAZIV
FROM DA.PREDMETPROGRAMA PP
         LEFT JOIN DA.USLOVNIPREDMET UP
                   ON PP.IDPREDMETA = UP.IDPREDMETA AND PP.IDPROGRAMA = UP.IDPROGRAMA
         JOIN DA.PREDMET AS P1
              ON PP.IDPREDMETA = P1.ID
         LEFT JOIN DA.PREDMET AS P2
                   ON UP.IDUSLOVNOGPREDMETA = P2.ID;

-- 12. Izdvojiti parove naziva različitih ispitnih rokova u kojima je isti student polagao isti predmet.
SELECT IR1.NAZIV, IR2.NAZIV
FROM DA.ISPIT I1
         JOIN DA.ISPIT I2
              ON I1.INDEKS = I2.INDEKS AND I1.IDPREDMETA = I2.IDPREDMETA AND I1.DATPOLAGANJA < I2.DATPOLAGANJA
                  AND I1.STATUS NOT IN ('p', 'n') AND I2.STATUS NOT IN ('p', 'n')
         JOIN DA.ISPITNIROK IR1
              ON IR1.SKGODINA = I1.SKGODINA AND IR1.OZNAKAROKA = I1.OZNAKAROKA
         JOIN DA.ISPITNIROK IR2
              ON IR2.SKGODINA = I2.SKGODINA AND IR2.OZNAKAROKA = I2.OZNAKAROKA;

-- 13. Izdvojiti parove student-ispitni rok za koje važi da je student diplomirao poslednjeg dana roka.
-- Izdvojiti indeks, ime, prezime, datum diplomiranja studenta, naziv ispitnog roka i datum kraja ispitnog roka.
-- Prikazati i studente i ispitne rokove koji nemaju odgovarajućeg para.
SELECT D.INDEKS, D.IME, D.PREZIME, D.DATDIPLOMIRANJA, IR.NAZIV, IR.DATKRAJA
FROM DA.DOSIJE D
         FULL JOIN DA.ISPITNIROK IR
                   ON D.DATDIPLOMIRANJA = IR.DATKRAJA;

-- 14. Za svaki ispitni rok izdvojiti ocene sa kojima su studenti položili ispite u tom roku.
-- Izdvojiti naziv ispitnog roka i ocene.
-- Izdvojiti i ispitne rokove u kojima nije položen nijedan ispit.
-- Rezultat urediti prema nazivu ispitnog roka u rastućem poretku i prema oceni u opadajućem poretku.
SELECT IR.NAZIV, I.OCENA
FROM DA.ISPITNIROK IR
         LEFT JOIN DA.ISPIT I ON IR.SKGODINA = I.SKGODINA AND IR.OZNAKAROKA = I.OZNAKAROKA
ORDER BY IR.NAZIV ASC, I.OCENA DESC;

-- 15. Za svakog studenta koji u imenu sadrži nisku "ark" izdvojiti podatke o položenim ispitima.
-- Izdvojiti indeks, ime i prezime studenta, naziv položenog predmeta i dobijenu ocenu.
-- Izdvojiti podatke i o studentu koji nema nijedan položen ispit.
-- Rezultat urediti prema indeksu.
SELECT D.INDEKS, D.IME, D.PREZIME, P.NAZIV, I.OCENA
FROM DA.DOSIJE D
         LEFT JOIN DA.ISPIT I ON D.INDEKS = I.INDEKS
         JOIN DA.PREDMET P ON I.IDPREDMETA = P.ID
ORDER BY INDEKS