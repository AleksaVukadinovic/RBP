-- Napisati pogled koji izdvaja poslednji položeni ispit za svakog studenta koji ima prosek iznad 8.
-- Izdvojiti indeks, ime i prezime studenta i datum polaganja poslednjeg ispita.

CREATE VIEW POSLEDNJI_POLOZENI_ISPIT AS
WITH STUDENTI_SA_PROSEKOM_8 AS (SELECT D.INDEKS, D.IME, D.PREZIME
                                FROM DA.DOSIJE D
                                WHERE (SELECT AVG(I.OCENA + 0.0)
                                       FROM DA.ISPIT I
                                       WHERE I.INDEKS = D.INDEKS
                                         AND I.OCENA > 5
                                         AND I.STATUS = 'o') >= 8.0),
     POSLEDNJI_POLOZENI AS (SELECT I.INDEKS, MAX(I.DATPOLAGANJA) AS DATUM
                            FROM DA.ISPIT I
                            WHERE I.OCENA > 5
                              AND I.STATUS = 'o'
                            GROUP BY I.INDEKS)
SELECT S.INDEKS, S.IME, S.PREZIME, P.DATUM
FROM STUDENTI_SA_PROSEKOM_8 S
         JOIN POSLEDNJI_POLOZENI P ON S.INDEKS = P.INDEKS;

-- Napisati pogled koji izdvaja podatke o studntima koji su bar jedan ispit položili sa ocenom 10.
-- Pogled napisati tako da je kroz njega moguće dodavanje novih studenata.
-- Izdvojiti samo kolone iz tabele dosije koje su neophodne da bi mogao da se izvrši
-- unos podataka o novom studentu preko pogleda.

CREATE VIEW STUDENTI_SA_10 AS
SELECT D.*
FROM DA.DOSIJE D
WHERE D.INDEKS IN (SELECT I.INDEKS
                   FROM DA.ISPIT I
                   WHERE I.OCENA = 10
                     AND I.STATUS = 'o');

-- Napisati korisnički definisanu funkciju koja za prosleđen indeks vraća inicijale studenta.
-- Ukoliko ne postoji stuedent vratiti 'XX'.

CREATE FUNCTION INICIJALI(INDEX INTEGER) RETURNS CHAR(2)
    RETURN
        SELECT COALESCE(SUBSTR(D.IME, 1, 1) || SUBSTR(D.PREZIME, 1, 1), 'XX')
        FROM DA.DOSIJE D
        WHERE D.INDEKS = INDEX;

-- Napisati korisnički definisanu funkciju koja vraća broj različitih rokova u kojim je
-- student sa prosleđenim indeksom položio neki ispit.

CREATE FUNCTION BROJ_ROKOVA(INDEX INTEGER) RETURNS INTEGER
    RETURN
        SELECT COUNT(DISTINCT I.SKGODINA || I.OZNAKAROKA)
        FROM DA.ISPIT I
        WHERE I.INDEKS = INDEX
          AND I.OCENA > 5
          AND I.STATUS = 'o';

-- Napisati korisnički definisanu funkciju koja vraća broj dana studiranja ako je
-- student sa prosleđenim indeksom diplomirao, inače 0.

CREATE FUNCTION DUZINA_STUDIRANJA(INDEX INTEGER) RETURNS INTEGER
BEGIN
    DECLARE REZ INTEGER;
    SELECT COALESCE(DAYS(DATDIPLOMIRANJA) - DAYS(DATUPISA), 0)
    INTO REZ
    FROM DA.DOSIJE
    WHERE INDEKS = INDEX;
    RETURN REZ;
END
;