-- Korišćenjem agregatnih funkcija, pronaći podatke o predmetima sa najvećim broj espb podova.
SELECT *
FROM DA.PREDMET P
WHERE P.ESPB = (SELECT MAX(P2.ESPB) FROM DA.PREDMET P2);

-- Za svaki predmet izdvojiti naziv, prosečnu ocenu dobijenu na položenim ispitima,
-- broj studenata koji su položili ispit iz tog predmeta i najveću ocenu dobijenu na položenim ispitima iz tog predmeta.
SELECT P.NAZIV,
       DECIMAL(AVG(I.OCENA + 0.0), 6, 2) AS PROSEK,
       COUNT(*)                          AS BROJ_STUDENATA,
       MAX(I.OCENA)                      AS NAJVECA_OCENA
FROM DA.PREDMET P
         JOIN DA.ISPIT I ON P.ID = I.IDPREDMETA AND I.OCENA > 5 AND I.STATUS = 'o'
GROUP BY P.NAZIV;

-- Za svakog studenta koji zadovoljava uslove:
-- rođen je u mestu koje u imenu sadrži malo slovo o i malo slovo a (slovo o se pojavlju pre slova a) DONE
-- prijavio je bar 3 ispita
-- najveća ocena sa kojom je položio ispit je 9 DONE
-- Izdvojiti indeks, ime, prezime, mesto rođenja i ime dana u kome je polagao prvi ispit.  DONE
-- Rezultat urediti prema mestu rođenja i indeksu u rastućem poretku.
SELECT D.INDEKS, D.IME, D.PREZIME, D.MESTORODJENJA, DAYNAME(MIN(I.DATPOLAGANJA)) AS DAN_PRVOG_ISPITA
FROM DA.DOSIJE D
         JOIN DA.ISPIT I ON D.INDEKS = I.INDEKS AND D.MESTORODJENJA LIKE '%o%a%'
GROUP BY D.INDEKS, D.IME, D.PREZIME, D.MESTORODJENJA
HAVING MAX(I.OCENA) = 9
   AND COUNT(*) > 3
ORDER BY D.MESTORODJENJA, D.INDEKS;


-- Za svaki ispitni rok izdvojiti predmet koji su u tom ispitnom roku studenti položili sa najvećom prosečnom ocenom.
-- Izdvojiti naziv ispitnog roka, naziv predmeta sa najvećom prosečnom ocenom i najveću prosečnu ocenu.
-- TODO