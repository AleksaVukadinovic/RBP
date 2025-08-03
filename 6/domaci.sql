-- Za svaki smer na kome studiraju studenti pronaći studenta koji ima najviše položenih espb bodova.
-- Izdvojiti naziv smera, indeks, ime i prezime studenta i broj položenih bodova.

WITH SMER_STUDENT_BODOVI AS (SELECT SP.ID,
                                    SP.NAZIV,
                                    D.INDEKS,
                                    D.IME,
                                    D.PREZIME,
                                    SUM(CASE WHEN I.OCENA > 5 AND I.STATUS = 'o' THEN P.ESPB ELSE 0 END) AS BODOVI
                             FROM DA.STUDIJSKIPROGRAM SP
                                      JOIN DA.DOSIJE D ON SP.ID = D.IDPROGRAMA
                                      JOIN DA.ISPIT I ON D.INDEKS = I.INDEKS
                                      JOIN DA.PREDMET P ON I.IDPREDMETA = P.ID
                             GROUP BY SP.NAZIV, D.INDEKS, D.IME, D.PREZIME, SP.ID
                             ORDER BY SP.NAZIV)
SELECT S.ID,
       S.NAZIV,
       S.INDEKS,
       S.IME,
       S.PREZIME,
       S.BODOVI
FROM SMER_STUDENT_BODOVI S
WHERE NOT EXISTS (SELECT *
                  FROM SMER_STUDENT_BODOVI S2
                  WHERE S2.ID = S.ID
                    AND S2.BODOVI > S.BODOVI);

-- Izdvojiti podatke o studentu koji je predmet, koji u nazivu na 4. i 5. poziciji sadrži nisku 'gr' i
-- koji ima između 5 i 10 espb bodova, polagao dva puta u roku od 20 dana.
-- Izdvojiti naziv predmeta, indeks studenta koji je polagao predmet i broj dana između ispita.
-- Kolonu sa brojem dana između ispita nazvati 'Broj dana'.

WITH STUDENT_PREDMET AS (
    SELECT D.INDEKS, P.NAZIV
    FROM DA.DOSIJE D JOIN DA.ISPIT I ON D.INDEKS = I.INDEKS JOIN DA.PREDMET P ON I.IDPREDMETA = P.ID
    WHERE (P.NAZIV LIKE '___gr%' OR P.NAZIV LIKE '____gr%') AND P.ESPB BETWEEN 5 AND 10 AND I.STATUS NOT IN ('p', 'n')
) SELECT
      --TODO

-- Izdvojiti predmet koji je polagan u samo jednom ispitnom roku. Izdvojiti naziv ispitnog roka, naziv predmeta, indeks, ime i prezime studenta koji je polagao taj predmet u tom ispitnom roku.
-- Izdvojiti podatke o parovima studenata koji su fakultet upisali 2012, 2015. ili 2018. godine i koji su rođeni u istom mestu koje u svom nazivu sadrži podnisku 'evo' počevši od 6. pozicije. Izdvojiti indekse studenata i mesto rođenja.
-- Izdvojiti podatke o ispitima za koje važi da je broj dobijenih bodova na ispitu 6 puta veći od broja bodova koje nosi predmet koji je polagan na ispitu. Izdvojiti indeks, ime i prezime studenta koji je polagao ispit, naziv polaganog predmeta, bodove polaganog predmeta, naziv ispitnog roka u kome je polagan ispit i dobijenu ocenu.
-- Za svaki predmet koji je položio bar jedan student, izdvojiti naziv predmeta i indeks najboljeg studenta sa tog predmeta. Za određivanje najboljeg studenta koristiti broj bodova sa kojima je ispit položen.
-- Za studenta koji najkraće studira fakultet izdvojiti nazive predmeta koje je položio. Ukoliko student nije položio nijedan ispit umesto naziva predmeta ispisati nisku koja sadrži karakter * onoliko puta koliko ima karaktera u prezimenu studenta.
-- Pronaći studenta koji ima najviše položenih espb bodova. Izdvojiti indeks, ime i prezime studenta i broj položenih bodova.
-- Izdvojiti nazive ispitnih rokova u kojima su svi predmeti iz kojih su ispite u tom roku prijavili studenti koji su fakultet upisali u novembru ili decembru položili studenti koji su fakultet upisali u septembru ili oktobru.
-- Za svaki nivo kvalifikacije i smer sa tog nivoa izdvojiti:
-- naziv nivoa kvalifikacija
-- stepen studija
-- naziv smera
-- potreban broj položenih espb bodova da bi student diplomirao na smeru
-- broj studenata koji su ikada upisali taj smer
-- procenat studenata koji su diplomirali na tom smeru u odnosu na broj upisanih
-- procenat studenata koji su se ispisali tog smera u odnosu na broj upisanih
-- procenat studenata tog smera koji su položili bar pola espb bodova predviđenih njihovim smerom.
-- Izdvojiti parove studenata čija imena počinju na slovo A i za koje važi da su bar tri ista predmeta položili u istom ispitnom roku