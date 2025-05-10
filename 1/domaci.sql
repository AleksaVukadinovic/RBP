-- 1. Izdvojiti indeks, ime i prezime za svakog studenta koji je upisao fakultet.
SELECT INDEKS, IME, PREZIME
FROM DA.DOSIJE;

-- 2. Izdvojiti sve različite vrednosti u koloni espb u tabeli predmet.
SELECT DISTINCT ESPB
FROM DA.PREDMET;

-- 3. Izdvojiti sva ženska imena studenata.
SELECT DISTINCT IME
FROM DA.DOSIJE;

-- 4. Izdvojiti podatke o ispitima koji su održani u ispitnom roku sa oznakom jan1 i na kojima je student dobio 100 poena.
SELECT *
FROM DA.ISPIT
WHERE OZNAKAROKA = 'jan1'
  AND POENI = 100;

-- 5. Izdvojiti indekse studenata koji su na nekom ispitu dobili između 65 i 87 poena.
SELECT D.INDEKS
FROM DA.ISPIT I
         JOIN DA.DOSIJE D ON I.INDEKS = D.INDEKS
WHERE I.POENI >= 65
  AND I.POENI <= 87;

-- 6. Izdvojiti indeks i godinu upisa na fakultet za studente koji fakultet nisu upisali između 2013. i 2016. godine.
-- Kolonu sa godinom upisa nazvati Godina upisa, a kolonu sa indeksom Student.
-- Koristiti pretpostavkom da godina iz indeksa odgovara godini upisa na fakultet.
SELECT INDEKS AS Student, SUBSTR(DATUPISA, 1, 4) AS "Godina upisa"
FROM DA.DOSIJE
WHERE SUBSTR(DATUPISA, 1, 4) NOT IN ('2013', '2014', '2015', '2016');

-- 7. Izdvojiti indeks i godinu upisa na fakultet za studente koji fakultet nisu upisali između 2013. i 2016. godine.
-- i čije ime počinje na slovo M, treće slovo u imenu je r, a završava se na a.
-- Rezultat urediti prema imenu studenta u rastućem poretku.
SELECT INDEKS AS Student, SUBSTR(DATUPISA, 1, 4) AS "Godina upisa"
FROM DA.DOSIJE
WHERE SUBSTR(DATUPISA, 1, 4) NOT IN ('2013', '2014', '2015', '2016')
  AND IME LIKE 'M_r%a'
ORDER BY IME;

-- 8. Izdvojiti ime i prezime svakog studenta čije ime nije Marko, Veljko ili Ana.
-- Rezultat urediti prema prezimenu u opadajućem poretku, a zatim prema imenu u rastućem poretku.
SELECT IME, PREZIME
FROM DA.DOSIJE
WHERE IME NOT IN ('Marko', 'Veljko', 'Ana')
ORDER BY PREZIME DESC, IME;