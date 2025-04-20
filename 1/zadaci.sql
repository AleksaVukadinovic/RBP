-- 1. Izdvojiti podatke o svim predmetima.
SELECT *
FROM DA.PREDMET;

-- 2. Izdvojiti podatke o svim studentima rođenim u Beogradu.
SELECT *
FROM DA.DOSIJE D
WHERE D.MESTORODJENJA = 'Beograd';

-- 3. Izdvojiti podatke o svim studentima koji nisu rođeni u Beogradu.
SELECT  *
FROM  DA.DOSIJE D
WHERE NOT D.MESTORODJENJA = 'Beograd';

-- 4. Izdvojiti podatke o svim studentima koji su rođeni u Beogradu ili Zrenjaninu.
SELECT *
FROM DA.DOSIJE
WHERE MESTORODJENJA = 'Beograd' OR MESTORODJENJA = 'Zrenjanin';

-- 5. Izdvojiti podatke o svim studentkinjama rođenim u Beogradu.
SELECT *
FROM DA.DOSIJE
WHERE MESTORODJENJA='Beograd' AND POL='z';

-- 6. Izdvojiti nazive mesta u kojima su rođeni studenti.
SELECT DISTINCT MESTORODJENJA
FROM DA.DOSIJE;

-- 7. Izdvojiti nazive predmeta koji imaju više od 6 ESPB.
SELECT NAZIV
FROM DA.PREDMET
WHERE ESPB > 6;

-- 8. Izdvojiti oznake i nazive predmeta koji imaju između 8 i 15 ESPB.
SELECT OZNAKA, NAZIV
FROM DA.PREDMET
WHERE ESPB >= 8 AND ESPB <= 15;

-- 9. Izdvojiti podatke o ispitnim rokovima održanim u 2015/2016, 2016/2017. ili 2018/2019. školskoj godini.
SELECT *
FROM DA.ISPITNIROK
WHERE SKGODINA IN (2015, 2016, 2018);

-- 10. Izdvojiti podatke o ispitnim rokovima koji nisu održani u 2015/2016, 2016/2017. ili 2018/2019. školskoj godini.
SELECT *
FROM DA.ISPITNIROK
WHERE SKGODINA NOT IN (2015, 2016, 2018);

-- 11. Izdvojiti podatke o studentima koji su fakultet upisali 2015. godine, pod pretpostavkom da godina iz indeksa odgovara godini upisa na fakultet.
SELECT *
FROM DA.DOSIJE
WHERE INDEKS/10000 = 2015;

-- 12. Izdvojiti nazive predmeta i njihovu cenu za samofinansirajuće studente izraženu u dinarima. Jedan ESPB košta 2000 dinara.
SELECT NAZIV, ESPB, ESPB*2000 AS CENA
FROM DA.PREDMET;

-- 13. U prethodnom upitu izdvojiti samo redove sa cenom bodova većom od 10 000.
SELECT NAZIV, ESPB, ESPB*2000 AS CENA
FROM DA.PREDMET
WHERE ESPB*2000>10000;

-- 14. Izdvojiti nazive predmeta i njihovu cenu za samofinansirajuće studente izraženu u dinarima. Jedan ESPB košta 2000 dinara. Između kolone naziv i kolone cena dodati kolonu u kojoj će za svaku vrstu biti ispisano Cena u dinarima.

SELECT NAZIV, 'Cena u dinarima' as OPIS, ESPB*2000 AS CENA
FROM DA.PREDMET;

-- 15. Izdvojiti podatke o studentima koji su rođeni u mestu čiji naziv sadrži malo slovo o kao drugo slovo.
SELECT  *
FROM DA.DOSIJE
WHERE MESTORODJENJA LIKE '_o%';

-- 16. Izdvojiti podatke o studentima koji su rođeni u mestu čiji naziv sadrži malo slovo o.
SELECT *
FROM DA.DOSIJE
WHERE MESTORODJENJA LIKE '%o%';

-- 17. Izdvojiti podatke o studentima koji su rođeni u mestu čiji naziv se završava sa malo e.
SELECT *
FROM DA.DOSIJE
WHERE MESTORODJENJA LIKE '%e';

-- 18. Izdvojiti podatke o studentima koji su rođeni u mestu čiji naziv počinje sa N a završava sa d.
SELECT *
FROM DA.DOSIJE
WHERE MESTORODJENJA LIKE 'N%d';

-- 19. Napraviti masku koja bi mogla da prepozna naredni string "%x_"
SELECT *
FROM DA.DOSIJE
WHERE MESTORODJENJA LIKE  '\%x\_' ESCAPE '\';

-- 20. Izdvojiti podatke o predmetima. Rezultat urediti po ESPB u rastućem poretku.
SELECT *
FROM DA.PREDMET
ORDER BY ESPB;

-- 21. Izdvojiti podatke o predmetima. Rezultat urediti po ESPB u opadajućem poretku.
SELECT *
FROM DA.PREDMET
ORDER BY ESPB DESC;

-- 22. Izdvojiti podatke o predmetima. Rezultat urediti po ESPB u rastućem poretku i po nazivu u opadajućem poretku
SELECT *
FROM DA.PREDMET
ORDER BY ESPB, NAZIV DESC;

-- 23. Izdvojiti ime, prezime i datum upisa na fakultet za studenate koji su fakultet upisali
-- između 10. jula 2017. i 15.9.2017. godine. Rezultat urediti prema prezimenu studenta.
SELECT IME, PREZIME, DATUPISA
FROM DA.DOSIJE
WHERE DATUPISA BETWEEN '10.07.2017' AND '15.09.2017'
ORDER BY PREZIME;

-- 24. Izdvojiti podatke o studijskim programima čija je predviđena dužina studiranja 3 ili više godina.
-- Izdvojiti oznaku i naziv studijskog programa i broj godina predviđenih za studiranje studijskog programa.
-- Rezultat urediti prema predviđenom broju godina za studiranje i nazivu studijskog programa.
SELECT  OZNAKA, NAZIV, OBIMESPB / 60 BROJGODINA
FROM DA.STUDIJSKIPROGRAM
WHERE OBIMESPB / 60 >= 3
ORDER BY BROJGODINA, NAZIV;
