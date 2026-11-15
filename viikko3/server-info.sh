set -euo pipefail 
# otetaan käyttöön virhetilanteiden käsittely
# -e: skripti pysähtyy, mikäli komento epäonnistuu
# -u: skripti pysähtyy, jos siinä käytetään määrittelemätöntä muuttujaa
# -o pipefail: komentoputken virhe huomioidaan, vaikka virheen aiheuttanut komento ei olisi putken viimeinen

#funktio levytilan tarkistukseen
check_space() {
	disk_percent=$(df -P / | awk 'NR == 2 {print $5}') #prosentteina minkä verran kovalevytilaa on käytössä

	percent_number=${disk_percent%\%} #erotetaan pelkkä luku vertailua varten

	if (( percent_number < 80 )); then
  		echo "<span class='ok'><strong> OK ($disk_percent)</strong></span>"
	else
  		echo "<span class='warning'><strong>WARNING ($disk_percent)</strong></span>"
	fi
}

manual_test() {
	if (( $1 < 80 )); then
  		echo "<span class='ok'><strong> OK ($1)</strong></span>"
	else
  		echo "<span class='warning'><strong>WARNING ($1)</strong></span>"
	fi

timestamp=$(TZ=Europe/Helsinki date '+%Y-%m-%d %H:%M:%S %Z (%:z)') # aikaleima ajohetkellä Suomen aikavyöhykkeellä
uptime=$(uptime -p) #päälläoloaika, esim. 1d, 2hours 3minutes

disk_status=$(check_space)

ramfree=$(free -h | grep Mem: | awk '{print $4}') # vapaa muisti
ramfree="${ramfree}B" #koska tulos on esim. 7.0Gi, lisätään vielä perään B
ramtotal=$(free -h | grep Mem: | awk '{print $2}') #kokonaismuisti
ramtotal="${ramtotal}B"

cat << EOF > /var/www/html/viikko3/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Week 3 – Server Status Report</title>
    <link rel="stylesheet" href="../styles/styles.css">
</head>
<body>
        <h1>Palvelimen tilaraportti</h1>
        <p>Viikko 3: Linuxin komentorivi ja bash-skriptaus</p>
        <p>Tehtävänä oli linuxin bash-skriptauksen avulla luoda sivu, joka näyttää palvelimen tilan.<br/>Skripti ajetaan cronilla kerran minuutissa</p>

    <div class="textDiv">
        <h2>Palvelimen tila</h2>

        <div class="table-container">
            <table>
                    <tr>
                        <td>Raportti luotu: $timestamp</td>
                    </tr>
                    <tr>
                        <td>Palvelin ollut päällä: $uptime</td>
                    </tr>
                    <tr>
                        <td>Levyn tila: $disk_status</td>
                    </tr>
                    <tr>
                        <td class="last"> RAM vapaana / yhteensä: $ramfree / $ramtotal </td>
                    </tr>
            </table>
        </div>

        <p>
            Levytila on <strong>OK</strong> alle 80% käyttöasteella
            ja <strong>WARNING</strong> käyttöasteella 80% tai yli.
        </p>

        <p class="note">
            Raportti luodaan bashilla kerran minuutissa. Odota 1-2 minuuttia ja päivitä sivu nähdäksesi ajantasaisen raportin.
        </p>
    </div>

    <div class="textDiv">
        <h2>Käytetyt komennot</h2>
        <ul>
            <li>
                <code>date</code>:
                Tulostaa nykyisen aikaleiman
            </li>
            <li>
                <code>uptime -p</code>:
                näyttää, kuinka kauan palvelin on ollut päällä
            </li>
            <li>
                <code>df -P / | awk 'NR == 2 {print &#36;5}'</code>:
                lähettää tiedostojärjestelmän tiedot awk:lle, joka erottelee käyttöasteen prosentteina toiselta riviltä.
            </li>
            <li>
                <code>free -h</code>:
                Hakee muistin tiedot
            </li>
        </ul>
    </div>

    <div class="textDiv">
        <h2>Miten se toimii?</h2>
        <p>
            Skripti kerää palvelimen tiedot käyttämällä Linuxin komentoja ja tallettaa tiedot muuttujiin Bashissa.
        </p>
        <p>
            Skripti generoi html-tiedoston, jonka se tallentaa index.html-tiedostoon.
            Nginx toimittaa tiedoston kansiosta /viikko3/.
        </p>
        <p>
            df näyttää tiedostojärjestelmän levytilan käytön.<br />
	    -P pyytää tiedot yhdellä rivillä. /-määre osoittaa juureen. <br />
	    | välittää df-komennon tulosteen awk:lle <br />
	    awk käsittelee tulostetta riveittäin ja sarakkeittain <br />
	    NR == 2 valitsee toisen rivin, jolla tiedot ovat, ensimmäisellä rivillä ovat sarakkeiden otsikot <br />
	    &#36;5 ottaa tiedon viidennestä sarakkeesta. <br />
	    print tulostaa arvon. <br />
        </p>
	<p>
	   free -h hakee RAM-muistin käyttötilanteen ja näyttää määrät luettavina yksiköinä, esim. 6.5Gi <br />
	   grep Mem: poimii tulosteesta muistia kuvaavan Mem:-rivin. <br />
	   awk '{print &#36;2} tulostaa rivin toisen sarakkeen arvon, joka on muistin kokonaismäärä. &#36;4 viittaa vapaaseen muistiin.<br />
	</p>

    </div>

    <div class="textDiv">
        <h2>Scheduling</h2>
        <p>
            Käytin ajastamiseen cronia. Cron on tavallisesti aina käynnissä ja se säilyy uudelleen käynnistämisen yli. Tilan voi tarkistaa komennolla <code>systemctl is-enabled cron</code><br />
	    Jos tila ei ole enabled, sen voi laittaa päälle komennolla <code>sudo systemctl enable --now cron</code> <br />
	<code>* * * * * /bin/bash polku/skripti.sh >> /home/ubuntu/server-info-cron.log 2>&1</code> <br />
	* * * * * - tarkoittaa, että skripti jokainen minuutti. Jos skripti haluttaisiin ajaa vaikkapa 10 minuutin välein, laitettaisiin */10 * * * * <br/>
/bin/bas - käynnistää bashin <br />
polku/skripti.sh - suoritettava skripti <br />
>> home/ubuntu/server-info-cron.log - kirjoittaa uuden lokitiedon tiedoston loppuun, ei poista aiempaa lokitietoa
2>&1 - myös virhetiedot kirjoitetaan samaan lokiin.

        </p>
    </div>

    <div class="textDiv">
        <h2>Testitulokset</h2>

        <h3>Syntaksin tarkistus ja testitulokset</h3>
        <p>
            
            Komento <code>bash -n report.sh</code> ei havainnut skriptissä virhettä. Skriptin manuaalinen ajo päivitti index.html:n.
        </p>

        <h3>Levytilan status -testi</h3>
        <p>
            Levytilan muutoksen testauksessa ajoin manuaalisesti arvoksi 50% ja 85%, jotta saan varmuuden, että tarvittaessa status muuttuu oikein.
        </p>

        <div class="table-container">
            <table>
                    <tr>
                        <td>50%</td>
                        <td>OK</td>
                        <td><span class='ok'> manual_test(50) </span></td>
                    </tr>
                    <tr>
                        <td class='last'>85%</td>
                        <td class='last'>WARNING</td>
                        <td class='last'> manual_test(85) </td>
                    </tr>
            </table>
        </div>

        <h3>Automatic updates</h3>
        <p>
            Kaksi viimeistä riviä lokista:<br />
<pre>2026-11-15T19:41:01.598141+00:00 linux-server CRON[6373]: (ubuntu) CMD (/bin/bash /home/ubuntu/linuxAdmin/viikko3/server-info.sh >> /home/ubuntu/server-info-cron.log 2>&1)<br />
2026-11-15T19:42:01.646843+00:00 linux-server CRON[6391]: (ubuntu) CMD (/bin/bash /home/ubuntu/linuxAdmin/viikko3/server-info.sh >> /home/ubuntu/server-info-cron.log 2>&1)<br /></pre>
        </p>

        <h3>Uudelleenkäynnistyksen testi</h3>
        <p>
            Ote lokista osoittaa, että komennon suoritus jatkui uudelleenkäynnistyksen jälkeen: <br />
<pre>2026-11-15T19:43:01.692673+00:00 linux-server CRON[6422]: (ubuntu) CMD (/bin/bash /home/ubuntu/linuxAdmin/viikko3/server-info.sh >> /home/ubuntu/server-info-cron.log 2>&1)
2026-11-15T19:44:01.737176+00:00 linux-server CRON[6440]: (ubuntu) CMD (/bin/bash /home/ubuntu/linuxAdmin/viikko3/server-info.sh >> /home/ubuntu/server-info-cron.log 2>&1)
2026-11-15T19:47:17.725005+00:00 linux-server cron[1072]: (CRON) INFO (pidfile fd = 3)
2026-11-15T19:47:18.218298+00:00 linux-server cron[1072]: (CRON) INFO (Running @reboot jobs)
2026-11-15T19:48:01.235788+00:00 linux-server CRON[1460]: (ubuntu) CMD (/bin/bash /home/ubuntu/linuxAdmin/viikko3/server-info.sh >> /home/ubuntu/server-info-cron.log 2>&1)</pre>
        </p>
    </div>

    <div class="textDiv">
        <h2>Ratkottu ongelma tai opittu asia</h2>
        <p>Koko bash on vielä hyvin uutta, joten tehtävässä oli paljon uusia asioita. Se osaltaan teki tehtävän suorittamisesta todella työlästä. Lisäksi alkuun index.html-tiedoston kirjoittaminen ei onnistunut, mutta oikeuksien korjauksella se saatiin hoidettua.</p>
    </div>

    <footer>
        <p><a href="https://github.com/nikoolio/linuxAdmin/tree/main/viikko3">Tehtävän github</a></p>
		<p><a href="/">Pääsivulle (ensimmäisen viikon tehtävä)</a></p>
    </footer>
</body>
</html>
EOF
