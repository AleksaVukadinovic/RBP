-- Izdvojiti ime i prezime studenta koji ima priznat ispit. Zadatak rešiti na tri načina.
SELECT D.IME, D.PREZIME
FROM DA.DOSIJE D
WHERE EXISTS(SELECT *
             FROM DA.ISPIT I
             WHERE I.STATUS = 'o'
               AND I.OCENA > 5
               AND I.INDEKS = D.INDEKS);

SELECT D.IME, D.PREZIME
FROM DA.DOSIJE D
WHERE D.INDEKS = ANY (SELECT *
                      FROM DA.ISPIT I
                      WHERE I.OCENA > 5
                        AND I.STATUS = 'o');

SELECT D.IME, D.PREZIME
FROM DA.DOSIJE D
WHERE D.INDEKS IN (SELECT *
                   FROM DA.ISPIT I
                   WHERE I.OCENA > 5
                     AND STATUS = 'o');

-- Izdvojiti nazive predmeta koje su polagali svi studenti. (napomena: rezultat je prazna tabela)
SELECT P.NAZIV
FROM DA.PREDMET P
WHERE NOT EXISTS(SELECT *
                 FROM DA.DOSIJE D
                 WHERE NOT EXISTS(SELECT *
                                  FROM DA.ISPIT I
                                  WHERE I.INDEKS = D.INDEKS
                                    AND I.IDPREDMETA = P.ID));

-- Izdvojiti podatke o studentima koji su polagali sve predmete od 30 espb bodova.
SELECT *
FROM DA.DOSIJE D
WHERE NOT EXISTS(SELECT *
                 FROM DA.PREDMET P
                 WHERE P.ESPB = 30
                   AND NOT EXISTS(SELECT *
                                  FROM DA.ISPIT I
                                  WHERE I.IDPREDMETA = P.ID
                                    AND I.IDPREDMETA = P.ID));

-- Izdvojiti podatke o prvom održanom ispitnom roku na fakultetu. Zadatak rešiti na tri načina.
SELECT *
FROM DA.ISPITNIROK IR
WHERE IR.DATPOCETKA < ALL (SELECT IR1.DATPOCETKA
                           FROM DA.ISPITNIROK IR1);

SELECT *
FROM DA.ISPITNIROK IR
WHERE NOT EXISTS(SELECT *
                 FROM DA.ISPITNIROK IR1
                 WHERE IR1.DATPOCETKA < IR.DATPOCETKA);

SELECT *
FROM DA.ISPITNIROK
ORDER BY DATPOCETKA
    FETCH FIRST 1 ROW ONLY;

-- Za predmet koji je prvi polagan na fakultetu izdvojiti njegov naziv i imena i prezimena studenata koji su ga ikada upisali.
SELECT P.NAZIV, D.IME, D.PREZIME
FROM DA.DOSIJE D
         JOIN DA.UPISANKURS UK ON D.INDEKS = UK.INDEKS
         JOIN DA.PREDMET P ON P.ID = UK.IDPREDMETA
WHERE P.ID IN (SELECT I1.IDPREDMETA
               FROM DA.ISPIT I1
               WHERE I1.DATPOLAGANJA IS NOT NULL
                 AND NOT EXISTS (SELECT *
                                 FROM DA.ISPIT I2
                                 WHERE I2.DATPOLAGANJA IS NOT NULL
                                   AND I2.DATPOLAGANJA < I1.DATPOLAGANJA));
