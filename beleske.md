
# 🧠 CAS 1 – SQL Osnove (IBM Db2 LUW)

## 📌 Redosled izvršavanja SQL naredbi

1. `FROM` – biranje tabela i join-ova  
2. `WHERE` – filtriranje redova  
3. `SELECT` – biranje kolona i izraza  

> **Napomena**: `SELECT` je poslednji koji se izvršava, iako prvi stoji u upitu.

---

## ❗ Operator `!=` ne postoji u Db2

Umesto toga koristi se:
- `<>`  
- Ili negacija: `NOT kolona = vrednost`

**Primeri:**
```sql
-- Pogrešno:
-- WHERE ocena != 10

-- Ispravno:
WHERE ocena <> 10
-- Ili
WHERE NOT ocena = 10
```

---

## ✅ Uklanjanje duplikata: `SELECT DISTINCT`

```sql
SELECT DISTINCT smer
FROM studenti;
```

---

## 🔍 Provera vrednosti unutar skupa: `IN`

```sql
SELECT ime, prezime
FROM studenti
WHERE ocena IN (8, 9, 10);
```

Umesto:
```sql
-- Dugacko:
WHERE ocena = 8 OR ocena = 9 OR ocena = 10
```

---

## 🏷️ Imenovanje kolona i dodavanje "phony" kolona

### Alias (`AS`)
```sql
SELECT naziv, espb * 2000 AS cena
FROM predmeti;
```

> Alias može biti u navodnicima ako sadrži razmake:
```sql
SELECT espb * 2000 AS "Cena poena"
FROM predmeti;
```

### Fiktivna kolona (konstantna vrednost)
```sql
SELECT 'Ovo je test' AS "Status"
FROM SYSIBM.SYSDUMMY1;
```

---

## 🔡 LIKE i jednostavni regularni izrazi

| Simbol | Značenje |
|--------|----------|
| `_`    | bilo koji **jedan** karakter |
| `%`    | bilo koji broj karaktera (uključujući 0) |

### Primer:
```sql
SELECT ime
FROM studenti
WHERE ime LIKE 'A_%';
```

---

## 🔐 Escape karakter u LIKE obrascu

```sql
SELECT *
FROM dosije
WHERE komentar LIKE '%/_%/%' ESCAPE '/';
```

> Ovde `/` označava "escape" karakter – znači da je `_` bukvalan karakter, ne wildcard.

---

## 🧮 Sortiranje: `ORDER BY`

```sql
SELECT ime, prezime, prosek
FROM studenti
ORDER BY prosek DESC;
```

Takođe se može koristiti redni broj kolone:
```sql
SELECT ime, prezime, prosek
FROM studenti
ORDER BY 3 DESC;
```

---

## 🗓️ Poređenje datuma

```sql
SELECT ime, prezime, datupisa
FROM dosije
WHERE datupisa BETWEEN '10.07.2017' AND '15.09.2017'
ORDER BY prezime;
```

Takođe moguće:
```sql
WHERE datupisa >= '01.01.2020' AND datupisa < '01.01.2021'
```

---

## ➕ Dodatni saveti

### `IS NULL` i `IS NOT NULL`
```sql
SELECT *
FROM studenti
WHERE prosek IS NULL;
```

### Kombinovanje uslova: `AND`, `OR`, `NOT`
```sql
SELECT *
FROM predmeti
WHERE espb > 5 AND naziv LIKE 'Mat%';
```

---

# 🧠 CAS 2 - Vrste spajanja

- Db2 je striktan u vezi sa tipovima – poređenje `VARCHAR` i `DATE` mora biti eksplicitno konvertovano ako nije kompatibilno.
- Koristi `SYSIBM.SYSDUMMY1` kao dummy tabelu (ekvivalent `DUAL` u Oracleu).
- Date format je često `'DD.MM.YYYY'`, ali ako ne radi, probaj `'YYYY-MM-DD'`.

---

## 🔗 JOIN-ovi u SQL-u

U SQL-u se **JOIN** koristi da se kombinuju podaci iz više tabela na osnovu logičke veze među njima (najčešće kroz strane ključeve).

Postoje dve glavne kategorije:

---

### 🔸 **INNER JOIN**

Vraća **samo one redove koji imaju podudaranje u obe tabele**.

```sql
SELECT D.IME, D.PREZIME, I.OCENA
FROM DA.DOSIJE D
INNER JOIN DA.ISPIT I ON D.INDEKS = I.INDEKS;
```

> Rezultat: samo studenti koji imaju bar jedan ispit.

---

### 🔸 **OUTER JOIN**

Vraća sve redove iz jedne (ili obe) tabele, **bez obzira da li postoji odgovarajući red u drugoj**. Ako nema poklapanja, polja iz nedostajuće tabele biće `NULL`.

---

#### 🟡 LEFT OUTER JOIN (ili samo `LEFT JOIN`)

Vraća **sve redove iz leve tabele** i **odgovarajuće iz desne** (ako ih ima).

```sql
SELECT D.IME, D.PREZIME, I.OCENA
FROM DA.DOSIJE D
LEFT JOIN DA.ISPIT I ON D.INDEKS = I.INDEKS;
```

> Rezultat: svi studenti, pa i oni koji **nisu polagali nijedan ispit** (`OCENA` će biti `NULL`).

---

#### 🟠 RIGHT OUTER JOIN (ili samo `RIGHT JOIN`)

Vraća **sve redove iz desne tabele**, i **odgovarajuće iz leve**.

```sql
SELECT D.IME, D.PREZIME, I.OCENA
FROM DA.DOSIJE D
RIGHT JOIN DA.ISPIT I ON D.INDEKS = I.INDEKS;
```

> Rezultat: svi ispiti, pa i oni koji **ne pripadaju nijednom studentu** (teoretski – ako postoji takav slučaj u bazi).

---

#### 🔵 FULL OUTER JOIN

Vraća **sve redove iz obe tabele**. Ako nema poklapanja, nedostajuća polja su `NULL`.

```sql
SELECT D.IME, D.PREZIME, I.OCENA
FROM DA.DOSIJE D
FULL JOIN DA.ISPIT I ON D.INDEKS = I.INDEKS;
```

> Rezultat: svi studenti i svi ispiti – čak i ako neki student nije polagao nijedan ispit, ili ako postoji ispit koji nije povezan ni sa jednim studentom.

---

### 📌 Napomena:

- `INNER JOIN` je najčešći i podrazumevani tip.
- `OUTER JOIN` je koristan za **analizu nedostajućih podataka**.
- `LEFT JOIN` se koristi mnogo češće nego `RIGHT JOIN`, jer redosled možeš lako da obrneš.

---

### 🔁 Kratka paralela

| JOIN tip        | Šta vraća?                                |
|----------------|--------------------------------------------|
| `INNER JOIN`   | Samo poklapanja                            |
| `LEFT JOIN`    | Svi iz leve + poklapanja iz desne          |
| `RIGHT JOIN`   | Svi iz desne + poklapanja iz leve          |
| `FULL JOIN`    | Sve iz obe – i poklapanja i nepoklapanja   |

---

# 🧠 ČAS 3 – Podupiti (Subqueries) u SQL-u

Podupiti (engl. *subqueries*) su SELECT upiti unutar drugih upita. Mogu se koristiti u:
- WHERE klauzuli (najčešće),
- FROM klauzuli (kao privremene tabele),
- SELECT klauzuli (agregatne vrednosti po kolonama).

---

## 🎯 [NOT] IN (SELECT ...)

Proveravamo da li se neka vrednost nalazi (ili ne nalazi) među rezultatima podupita.

```sql
-- Primer: Izdvojiti studente koji su polagali neki ispit:
SELECT *
FROM dosije
WHERE indeks IN (
  SELECT indeks
  FROM ispit
);
```

> Važno: Vraćeni podaci u podupitu moraju imati isti broj kolona kao levo od `IN`.

Može se koristiti i za više kolona:

```sql
WHERE (oznakaRoka, skGodina) IN (
  SELECT oznaka, godina
  FROM ispitnirok
);
```

---

## 🧪 [NOT] EXISTS (SELECT ...)

Uslov je zadovoljen ako podupit vraća bar jedan red (ili nijedan, u slučaju `NOT EXISTS`).

```sql
-- Primer: Izdvojiti predmete koje je neki student položio
SELECT naziv
FROM predmet P
WHERE EXISTS (
  SELECT *
  FROM ispit I
  WHERE I.idpredmeta = P.id AND I.status = 'o'
);
```

---

## 🔁 X < ALL (SELECT ...)

Uslov važi ako je **X manje od svih vrednosti** koje vraća podupit.

```sql
-- Primer: predmeti sa najmanjim brojem espb
SELECT *
FROM predmet
WHERE espb < ALL (
  SELECT espb
  FROM predmet
  WHERE espb IS NOT NULL
);
```

> Operator može biti `<`, `=`, `>=`, itd.

---

## 🔁 X < SOME (SELECT ...) ili X < ANY (SELECT ...)

Uslov važi ako je **X manje od bar jedne vrednosti** iz podupita.

```sql
-- Primer: predmeti sa manje bodova nego neki drugi predmet
SELECT *
FROM predmet
WHERE espb < SOME (
  SELECT espb
  FROM predmet
  WHERE naziv LIKE 'Mat%'
);
```

Napomena: `SOME` i `ANY` su sinonimi u ovom kontekstu.

---

## ❗ X = ANY (SELECT ...)

Ekvivalentno `IN`, proverava da li je `X` jednako **nekoj vrednosti** iz podupita.

```sql
-- Primer: studenti koji su upisali neki predmet
SELECT *
FROM dosije
WHERE indeks = ANY (
  SELECT indeks
  FROM upisankurs
);
```

---

## 🧠 "SVAKI" <=> "NE POSTOJI NEKI KOJI NIJE"

Ako želimo da proverimo da **nešto važi za sve**, pišemo to kao:
> “Ne postoji neki za koji ne važi”.

```sql
-- Primer: student je položio sve ispite koje je polagao
SELECT *
FROM dosije D
WHERE NOT EXISTS (
  SELECT *
  FROM ispit I
  WHERE I.indeks = D.indeks
    AND I.status <> 'o'
);
```

---

## 💡 Dodatni saveti

- `EXISTS` je često brži od `IN`, naročito kada podupit vraća mnogo redova.
- Ako podupit vraća više kolona nego što se očekuje – dolazi do greške.
- `NOT IN` sa `NULL` vrednostima može dati neočekivane rezultate – izbegavaj ako je moguće, koristi `NOT EXISTS`.

---


# 📚 ČAS 4 – Skupovni operatori i funkcije u SQL-u (IBM Db2 LUW)

---

## 🔀 Skupovni operatori

Skupovni operatori kombinuju rezultate više SELECT upita.

> 📌 **Pravilo**: Svi uključeni upiti moraju imati **isti broj kolona** i **kompatibilne tipove podataka**.

### `UNION`

Kombinuje rezultate dva upita i uklanja duplikate.

```sql
SELECT ime, ocena FROM studenti
UNION
SELECT prezime, indeks FROM prijave;
```

### `UNION ALL`

Kao `UNION`, ali **zadržava duplikate**. Efikasniji jer ne proverava ponavljanja.

```sql
SELECT ime FROM studenti
UNION ALL
SELECT ime FROM alumni;
```

### `INTERSECT`

Rezultat su samo oni redovi koji su **zajednički** za oba upita (bez duplikata).

```sql
SELECT indeks FROM studenti
INTERSECT
SELECT indeks FROM ispit;
```

### `INTERSECT ALL`

Zadržava duplikate koji se pojavljuju u **oba** skupa.

```sql
SELECT indeks FROM studenti
INTERSECT ALL
SELECT indeks FROM prisutni;
```

### `EXCEPT` / `MINUS`

Vraća redove iz prvog upita **koji ne postoje u drugom**. `EXCEPT` i `MINUS` znače isto.

```sql
SELECT indeks FROM studenti
EXCEPT
SELECT indeks FROM diplomirani;
```

### `EXCEPT ALL`

Zadržava višestruke pojave redova koji se ne javljaju u drugom upitu.

```sql
SELECT indeks FROM studenti
EXCEPT ALL
SELECT indeks FROM iskljuceni;
```

---

## 🕓 Funkcije za rad sa datumom i vremenom

### 📅 Trenutni datum i vreme
- `CURRENT DATE`
- `CURRENT TIME`

### 📌 Parsiranje i formatiranje
- `DATE('01.01.2020')`
- `TIME('13:45')`
- `TIMESTAMP(DATE, TIME)`

### 📆 Izvlačenje delova datuma
```sql
YEAR(datum)
MONTH(datum)
DAY(datum)
DAYOFMONTH(datum)
DAYOFYEAR(datum)
DAYOFWEEK(datum)
WEEK(datum)
DAYNAME(datum, 'sr_latn_sr')
MONTHNAME(datum, 'sr_latn_sr')
```

### 🧮 Razlika između datuma
```sql
DAYS_BETWEEN(date1, date2)
MONTHS_BETWEEN(date1, date2)
YEARS_BETWEEN(date1, date2)
```

### ➕ Dodavanje na datum/vreme
```sql
CURRENT DATE + 5 DAYS
CURRENT TIME + 10 MINUTES - 30 SECONDS
DATE('1.1.2020') + 2 YEARS
```

---

## 🔠 Funkcije za rad sa tekstom (karakterima)

```sql
SUBSTR(str, start, len)
CONCAT(x, y)
x || y  -- spajanje stringova
SPACE(x)
POSSTR(x, y)
REPEAT(str, x)
REPLACE(str, x, y)
LTRIM(str), RTRIM(str), TRIM(str)
LENGTH(str)
```

---

## ❓ Funkcije za rad sa NULL vrednostima

```sql
COALESCE(x, y, z...)  -- prvi ne-NULL
NULLIF(x, y)          -- NULL ako su x i y jednaki
```

---

## 🔄 Funkcije za konverziju

```sql
DECIMAL(x, y, z) / DEC(x, y, z)
DOUBLE(x)
CHAR(x)               -- broj u string
CHAR(datetime, format) -- npr. CHAR(CURRENT DATE, USA)
```

---

## 🔢 Numeričke funkcije

```sql
MOD(x, y)
ABS(x)
SIGN(x)      -- -1, 0, 1
SQRT(x)
RAND(seed)
CEIL(x)
FLOOR(x)
ROUND(num, broj_decimala)
SIN, COS, TAN, COTAN, ASIN, ACOS, ATAN, EXP...
```