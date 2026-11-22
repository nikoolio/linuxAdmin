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


