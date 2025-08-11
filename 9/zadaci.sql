-- Napisati korisnički definisanu funkciju koja vraća nisku sa imenima.
-- Kao arguemtn se prosleđuje karakter za pol.
-- Ako pol nije m ili z vratiti nisku 'Pol ne moze biti *prosledjen_argument*'.
-- Sortirati po imenu.

CREATE FUNCTION IMENA(POLARG CHAR)
    RETURNS VARCHAR(4000)
    RETURN
        CASE
            WHEN LOWER(POLARG) IN ('z', 'm') THEN
                (SELECT LISTAGG(DISTINCT IME, ',') WITHIN GROUP (ORDER BY IME)
                 FROM DA.DOSIJE
                 WHERE LOWER(POLARG) = POL)
            ELSE
                'Pol ne moze biti ' || POLARG
            END;

-- Napisati korisnički definisanu funkciju koja vraća nisku sa indeksima studenata koji imaju prosek
-- jednak vrednosti prosleđenoj kao argument. Ispret niske sa indeksima ispisti koliko ima indeksa,
-- indekse razdvojiti crticama. Prosek gledati na dve decimale. Izlaz treba da bude na primer: '2:20170325-20170349'.

CREATE FUNCTION STUDENT_PROSEK(ARG_PROSEK FLOAT) RETURNS VARCHAR(4000)
    RETURN
        WITH INDEKS_PROSEK AS (SELECT D.INDEKS, DECIMAL(AVG(I.OCENA + 0.0), 4, 2) AS PROSEK
                               FROM DA.DOSIJE D
                                        JOIN DA.ISPIT I ON D.INDEKS = I.INDEKS
                               WHERE I.OCENA > 5
                                 AND I.STATUS = 'o'
                               GROUP BY D.INDEKS)
        SELECT COUNT(IP.INDEKS) || ':' || LISTAGG(IP.INDEKS, '-')
        FROM INDEKS_PROSEK IP
        WHERE IP.PROSEK = ARG_PROSEK;

-- Napisati naredbu na SQL-u koja:
-- pravi tabelu predmet_student koja čuva podatke koliko studenata je položilo koji predmet.
-- Tabela ima kolone: idpredmeta (tipa integer) i student (tipa smallint).
-- unosi u tabelu predmet_student podatke o obaveznim predmetima na smeru Informatika
-- na osnovnim akademskim studijama (može se uzeti da je id 103).
-- Za svaki predmet uneti podatak da ga je položilo 5 studenata.
-- ažurira tabelu predmet_student, tako što predmetima o kojima postoji evidencija ažurira
-- broj studenata koji su ga položili, a za predmete o kojima ne postoji evidencija unosi podatke.

CREATE TABLE PREDMET_STUDENT
(
    IDPREDMETA INTEGER NOT NULL PRIMARY KEY,
    STUDENT    SMALLINT
);

INSERT INTO PREDMET_STUDENT(IDPREDMETA, STUDENT)
SELECT PP.IDPREDMETA, 5
FROM DA.PREDMETPROGRAMA PP
         JOIN DA.STUDIJSKIPROGRAM SP ON PP.IDPROGRAMA = SP.ID
WHERE PP.VRSTA = 'obavezan'
  AND SP.NAZIV = 'Informatika';

MERGE INTO PREDMET_STUDENT PS
USING (SELECT IDPREDMETA, COUNT(*) BR
       FROM DA.ISPIT
       WHERE OCENA > 5
         AND STATUS = 'o'
       GROUP BY IDPREDMETA) AS P
ON PS.IDPREDMETA = P.IDPREDMETA
WHEN MATCHED THEN
    UPDATE
    SET STUDENT=BR
WHEN NOT MATCHED THEN
    INSERT
    VALUES (IDPREDMETA, BR);

-- Napisati naredbu na SQL-u koja:
-- pravi tabelu student_podaci sa kolonama: indeks (tipa integer),
-- broj _predmeta (tipa smallint), prosek (tipa float) i datupisa (tipa date);
-- u tabelu student_podaci unosi indeks, broj položenih predmeta i prosek za
-- studente koji imaju prosek iznad 8 i nisu diplomirali;
-- za studente koji su diplomirali kao broj predmeta uneti vrednost 10,
-- a kao prosek vrednost 10;
-- ažurira tabelu student_podaci tako što studentima o kojima u tabeli postoje podaci i koji su:
-- diplomirali ažurira datum upisa na fakultet
-- trenutno na budžetu ažurira broj položenih predmeta i prosek;
-- studente koji su ispisani briše iz tabele;
-- unosi podatke o studentima koji nisu ispisani i o njima ne postoje podaci u tabeli student_podaci; uneti indeks, broj položenih predmeta i prosek;
-- uklanja tabelu student_podaci.

DROP TABLE IF EXISTS STUDENT_PODACI;

CREATE TABLE STUDENT_PODACI
(
    INDEKS        INTEGER,
    BROJ_PREDMETA SMALLINT,
    PROSEK        FLOAT,
    DATUPISA      DATE
);

INSERT INTO STUDENT_PODACI(INDEKS, BROJ_PREDMETA, PROSEK)
SELECT INDEKS, COUNT(*), AVG(OCENA * 1.0)
FROM DA.ISPIT I
WHERE INDEKS NOT IN (SELECT INDEKS
                     FROM DA.DOSIJE D
                              JOIN DA.STUDENTSKISTATUS SS
                                   ON D.IDSTATUSA = SS.ID
                     WHERE SS.NAZIV = 'Diplomirao')
  AND OCENA > 5
  AND STATUS = 'o'
GROUP BY INDEKS
HAVING AVG(OCENA + 0.0) > 8
UNION
SELECT INDEKS, 10, 10
FROM DA.DOSIJE D
         JOIN DA.STUDENTSKISTATUS SS
              ON D.IDSTATUSA = SS.ID
WHERE SS.NAZIV = 'Diplomirao';

MERGE INTO STUDENT_PODACI SP
USING (SELECT D.INDEKS,
              AVG(OCENA * 1.0) PROSEK,
              COUNT(*)         PREDMETI,
              SS.NAZIV         STATUSSTUDENTA,
              DATUPISA         DATUMUPISA
       FROM DA.ISPIT I
                JOIN DA.DOSIJE D
                     ON I.INDEKS = D.INDEKS
                JOIN DA.STUDENTSKISTATUS SS
                     ON SS.ID = D.IDSTATUSA
       WHERE OCENA > 5
         AND STATUS = 'o'
       GROUP BY D.INDEKS, DATUPISA, SS.NAZIV) AS TMP
ON SP.INDEKS = TMP.INDEKS
WHEN MATCHED AND TMP.STATUSSTUDENTA = 'Diplomirao' THEN
    UPDATE
    SET SP.DATUPISA = TMP.DATUMUPISA
WHEN MATCHED AND TMP.STATUSSTUDENTA = 'Budzet' THEN
    UPDATE
    SET (BROJ_PREDMETA, PROSEK) = (TMP.PREDMETI, TMP.PROSEK)
WHEN MATCHED AND LOWER(TMP.STATUSSTUDENTA) LIKE '%ispis%' THEN
    DELETE
WHEN NOT MATCHED AND LOWER(TMP.STATUSSTUDENTA) NOT LIKE '%ispis%' THEN
    INSERT (INDEKS, BROJ_PREDMETA, PROSEK)
    VALUES (TMP.INDEKS, TMP.PREDMETI, TMP.PROSEK)
    ELSE IGNORE;

DROP TABLE STUDENT_PODACI;

-- Napraviti okidač koji sprečava brisanje studenata koji su diplomirali.
-- U tabelu uneti studenta koji je diplomirao i proveriti da li trigger radi.
-- Na kraju obrisati trigger.

CREATE TRIGGER BRISANJE_STUDENATA
    BEFORE DELETE
    ON DA.DOSIJE
    REFERENCING OLD AS STARI
    FOR EACH ROW
    WHEN ( STARI.DATDIPLOMIRANJA IS NOT NULL)
BEGIN
    ATOMIC
    SIGNAL SQLSTATE '75000' ('Ne mozete obrisati studenta koji je diplomirao');
END;

-- Napraviti okidač koji dozvoljava ažuriranje broja espb bodova predmetima
-- samo za jedan bod. Ako je nova vrednost espb bodova veća od postojeće,
-- broj bodova se povećava za 1, a ako je manja smajuje se za 1.

CREATE TRIGGER UPDATE_ESPB
    BEFORE UPDATE OF ESPB
    ON DA.PREDMET
    REFERENCING OLD AS STARI NEW AS NOVI
    FOR EACH ROW
BEGIN
    ATOMIC
    SET NOVI.ESPB = CASE
                        WHEN STARI.ESPB > NOVI.ESPB THEN STARI.ESPB - 1
                        WHEN STARI.ESPB < NOVI.ESPB THEN STARI.ESPB + 1
                        ELSE STARI.ESPB END;
END;

-- Napraviti tabelu broj_predmeta koja ima jednu kolonu broj tipa smallint i u nju uneti jedan entitet koji predstavlja broj predmeta u tabeli predmet.
-- Napraviti okidač koji ažurira tabelu broj_predmeta tako što povećava vrednosti u koloni broj za 1 kada se unese novi predmet u tabelu predmet.
-- Napisati okidač koji ažurira tabelu broj_predmeta tako što smanjuje vrednost u koloni broj za 1 kada se obriše predmet iz tabele predmet.
-- Uneti podatke o novom predmetu čiji je id 2002, oznaka predm1, naziv Predmet 1, i ima 15 espb.

CREATE TABLE BROJ_PREDMETA
(
    KOLONA SMALLINT NOT NULL PRIMARY KEY
);

CREATE TRIGGER UVECAVAC
    AFTER INSERT
    ON DA.PREDMET
    REFERENCING NEW AS NOVI
    FOR EACH ROW
BEGIN
    ATOMIC
    UPDATE BROJ_PREDMETA SET KOLONA = KOLONA + 1;
END;

CREATE TRIGGER UMANJIVAC
    AFTER DELETE
    ON DA.PREDMET
    FOR EACH ROW
BEGIN
    ATOMIC
    UPDATE BROJ_PREDMETA SET KOLONA = KOLONA - 1;
END;

-- Napraviti tabelu student_polozeno koja za svakog studenta koji je položio barem jedan predmet sadrži podatak koliko je espb bodovoa položio.
-- Tabela ima kolone indeks i espb.
-- Napraviti tabelu predmet_polozeno koja za svaki predmet koji je položio barem jedan student sadrži podatak koliko je studenata položilo taj predmet.
-- Tabela ima kolone idpredmeta i brojstudenata.
-- Uneti podatke u tabelu student_polozeno za studente koji su položili sve obavezne predmete na smeru koji studiraju.
-- Napisati naredbu koja menja tabelu student_polozeno tako što ažurira broj položenih espb bodova za studente o kojima sadrži podatke, a unosi informaicje za studente o kojima ne postoje podaci u tabeli student_polozeno.
-- Uneti podatke u tabelu predmet_polozeno.
-- Napraviti okidač koji nakon unosa položenog ispita ažurira tabele student_polozeno i predmet_polozeno tako da sadrže podatak o novom ispitu.
-- Uneti podatak da je student sa indeksom 20150320 polagao predmet sa id 2010 u ispitnom roku jun2 2017/2018. šk. godine. Student je ispit položio sa 95 poena i dobio ocenu 10.
-- Uneti podatak da je student sa indeksom 20152003 polagao predmet sa id 1695 u ispitnom roku jun1 2017/2018. šk. godine. Student je ispit položio sa 95 poena i dobio je ocenu 10.

-- TODO