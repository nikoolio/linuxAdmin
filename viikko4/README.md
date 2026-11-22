# linuxAdmin viiko4
## 1. testilinkit
Palvelin A: http://195.148.21.3/viikko2/

Palvelin B: http://128.214.254.225/viikko4/

Sivujen toimivuuden tarkistus bashissa:

curl -i http://195.148.21.3/viikko2/ TAI

curl -i http://128.214.254.225/viikko4/

## 2. A:n sivun avaaminen päivittää B:llä näkyvää laskuria

1. B:n laskuri ennen päivitystä: 94

2. A:n päivitys - Sivun A laskuri: 95

3. B:n päivitys - laskurin arvo: 95

Testi tehty 22.11. klo n. 22.01

## 3. B:n päivittäminen ei nosta laskuria

1. B:n laskuri ennen päivitystä: 95

2. B:n päivitys - laskuri edelleen 95

Testi tehty 22.11. klo n. 22.02

## 4. Tietokannan replikoinnin toiminta

Replikoinnin tilan voi tarkistaa käynnistämällä mariadb ja kirjoittamalla komennon  SHOW REPLICA STATUS\G. Testitulos:

- Slave_IO_Running: Yes
- Slave_SQL_Running: Yes
- Last_IO_Error:
- Last_SQL_Error:

Replikointi siis toimii normaalisti.

## 5. Vähintään kaksi ajettua varmuuskopiota onnistuu

Asetin ensin cronin 1 minuuttiin, jotta saadaan nopeasti varmennus varmuuskopioista. Komennolla <code>sudo ls -lah /srv/backups/www-html</code> tarkistin palvelimelta B, että varmuuskopioita on syntynyt.

<code>
drwxr-xr-x 4 wwwbackup wwwbackup 4.0K Nov 22 19:25 2026-11-22_20-29-01
drwxr-xr-x 4 wwwbackup wwwbackup 4.0K Nov 22 19:25 2026-11-22_20-30-01
drwxr-xr-x 4 wwwbackup wwwbackup 4.0K Nov 22 19:25 2026-11-22_20-31-01
</code>

Palvelimelta löytyi kolme varmuuskopiota, joten varmuuskopiointi toimii oikein.
