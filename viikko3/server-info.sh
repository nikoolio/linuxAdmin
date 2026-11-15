set -euo pipefail 
# otetaan käyttöön virhetilanteiden käsittely
# -e: skripti pysähtyy, mikäli komento epäonnistuu
# -u: skripti pysähtyy, jos siinä käytetään määrittelemätöntä muuttujaa
# -o pipefail: komentoputken virhe huomioidaan, vaikka virheen aiheuttanut komento ei olisi putken viimeinen

timestamp=$(TZ=Europe/Helsinki date '+%Y-%m-%d %H:%M:%S %Z (%:z)') # aikaleima ajohetkellä Suomen aikavyöhykkeellä
uptime=$(uptime -p) #päälläoloaika, esim. 1d, 2hours 3minutes
disk_percent=$(df -P / | awk 'NR == 2 {print $5}') #prosentteina minkä verran kovalevytilaa on käytössä

percent_number=${disk_percent%\%} #erotetaan pelkkä luku vertailua varten

if (( percent_number < 80 )); then
  disk_status="<span class='ok'>OK ($disk_percent)</span>"
else
  disk_status="<span class='warning'>WARNING ($disk_percent)</span>"
fi

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
                        <td> RAM vapaana / yhteensä: $ramfree / $ramtotal </td>
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
            TODO: State whether you used cron or a systemd timer.
            Explain the schedule and how you ensured that it
            continues after a reboot.
        </p>
    </div>

    <div class="textDiv">
        <h2>Test results</h2>

        <h3>Syntax check and manual execution</h3>
        <p>
            TODO: Describe the results of running
            <code>bash -n report.sh</code>
            and executing the script manually.
        </p>

        <h3>Disk space status tests</h3>
        <p>
            TODO: Test the status logic using temporary input values.
            Record your actual results below and restore real disk
            usage afterwards.
        </p>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th scope="col">Test input</th>
                        <th scope="col">Expected status</th>
                        <th scope="col">Actual status</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>50%</td>
                        <td>OK</td>
                        <td>TODO</td>
                    </tr>
                    <tr>
                        <td>80%</td>
                        <td>WARNING</td>
                        <td>TODO</td>
                    </tr>
                    <tr>
                        <td>90%</td>
                        <td>WARNING</td>
                        <td>TODO</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <h3>Automatic updates</h3>
        <p>
            TODO: Record the generation times of at least two
            consecutive automatic updates.
        </p>

        <h3>Reboot test</h3>
        <p>
            TODO: Record when you rebooted the VM and whether the
            Week 2 application and Week 3 page opened afterwards.
            Include evidence that the report continued to update.
        </p>
    </div>

    <div class="textDiv">
        <h2>Ratkottu ongelma tai opittu asia</h2>
        <p>Koko bash on vielä hyvin uutta, joten tehtävässä oli paljon uusia asioita. Se osaltaan teki tehtävän suorittamisesta todella työlästä.</p>
    </div>

    <footer>
        <p><a href="">Tehtävän github</a></p>
		<p><a href="/">Pääsivulle (ensimmäisen viikon tehtävä)</a></p>
    </footer>
</body>
</html>
EOF