
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
