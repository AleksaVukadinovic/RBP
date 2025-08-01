-- Izdvojiti podatke o priznatim ispitima sa poznatom ocenom.
SELECT I.*
FROM DA.DOSIJE D JOIN DA.ISPIT I ON D.INDEKS = I.INDEKS
WHERE I.STATUS = 'o';

-- Izdvojiti podatke o upisanim školskim godinama studenata.
-- Izdvojiti indeks, ime i prezime studenta, školsku godinu i datum upisa godine.
-- Rezultat urediti prema indeksu u opadajućem poretku i školskoj godini u rastućem poretku.
SELECT D.INDEKS, D.IME, D.PREZIME, UG.SKGODINA, UG.DATUPISA
FROM DA.DOSIJE D JOIN DA.UPISGODINE UG ON D.INDEKS = UG.INDEKS JOIN DA.SKOLSKAGODINA S on UG.SKGODINA = S.SKGODINA
ORDER BY D.INDEKS DESC, UG.SKGODINA ASC;

-- Izdvojiti parove studenata koji su rođeni u istom mestu. Izdvojiti indekse studenata.
SELECT D1.INDEKS, D2.INDEKS, D1.MESTORODJENJA
FROM DA.DOSIJE D1, DA.DOSIJE D2
WHERE D1.MESTORODJENJA = D2.MESTORODJENJA AND D1.INDEKS < D2.INDEKS;

-- Za svaki predmet izdvojiti podatke o ispitnim rokovima u kojima je predmet poništen.
-- Izdvojiti naziv predmeta, školsku godinu u kojoj je održan ispitni rok i oznaku roka.
-- Izdvojiti podatke i o predmetima čiji nijedan ispit nije poništen.
-- Upit napisati tako da nema ponavljanja redova u rezultatu.
SELECT DISTINCT P.NAZIV, I.SKGODINA, I.OZNAKAROKA
FROM DA.PREDMET P
LEFT JOIN DA.ISPIT I ON P.ID = I.IDPREDMETA AND I.STATUS = 'x';

-- Izdvojiti podatke o studentima i njihovim upisanim predmetima od 5, 10, 12 ili 25 espb
-- čiji naziv počinje sa Pr i sadrži malo slovo o.
-- Izdvojiti podatke samo za školske godine u intervalu od 2016/2017. do 2020/2021.
-- Izdvojiti indeks, ime, prezime studenta, školsku godinu, naziv upisanog predmeta i broj espb predmeta.
-- Rezultat urediti prema indeks, školskoj godini i oznaci predmeta.

SELECT D.INDEKS, D.IME, D.PREZIME, UK.SKGODINA, P.NAZIV, P.ESPB
FROM DA.DOSIJE D JOIN DA.UPISANKURS UK ON D.INDEKS = UK.INDEKS LEFT JOIN DA.PREDMET P ON UK.IDPREDMETA = P.ID
WHERE P.ESPB IN (5, 10, 12, 25) AND P.NAZIV LIKE 'Pr%o%' AND UK.SKGODINA > 2016 AND UK.SKGODINA < 2020;