# Omgeving voor experimenten rond database-performance

In deze directory vind je een voorbeeld van een reproduceerbare testopstelling voor het testen van database-performantie. In eerste instantie worden de experimenten van Bassil (2012) gereproduceerd op een installatie van MariaDB.

Indien je problemen ondervindt met het opzetten van de testomgeving, contacteer [Bert Van Vreckem](mailto:bert.vanvreckem@hogent.be).

## Instructies voor opstarten

Volg deze instructies voor het opzetten van een MariaDB-server op CentOS 7. De database zoals gerapporteerd door Bassil (2012) wordt gereconstrueerd en opgevuld met data.

1. Installeer eerst VirtualBox en Vagrant.
2. Open een Bash-shell (Git Bash op Windows) en ga naar deze directory (`experiment/`)
3. Voer het commando `vagrant up` uit. Er wordt een nieuwe virtuele machine in VirtualBox aangemaakt en opgestart. De eerste keer dat je dit doet, wordt er een basisversie van de VM gedownload (~500 MB, dus je doet dit best met een performante internetverbinding).
4. Na afloop van het commando is de database-server klaar. Je kan inloggen op de server met `vagrant ssh`

Je kan alle bestanden in deze directory terugvinden op de server onder `/vagrant/`. Wijzigingen van bestanden zijn ook direct zichtbaar binnen de server.

## Queries uitvoeren

In de database is er een gebruiker aangemaakt met naam `dbo` en wachtwoord `dbo`. De database voor het experiment heet ook `dbo`. Voorbeelden van het uitvoeren van queries (na inloggen op de server):

```console
$ vagrant ssh
[vagrant@srv001] mysql -udbo -pdbo dbo
Welcome to the MariaDB monitor.  [...]
MariaDB [dbo]> SHOW TABLES;
[...]
MariaDB [dbo]> describe category;
[...]
MariaDB [dbo]> select count(*) from category;
[...]
MariaDB [dbo]> insert into category values (88888, "test", "DH459");
Query OK, 1 row affected (0.00 sec)

MariaDB [dbo]> quit
Bye
[vagrant@srv001 ~]$
```

Alle queries uit Bassil (2012) zijn beschikbaar op de server in de directory `/vagrant/queries`. Je kan ze uitvoeren met:

```console
[vagrant@srv001 ~]$ mysql -udbo -pdbo dbo < /vagrant/queries/query1.sql
[ ... ]
[vagrant@srv001 ~]$ time ( mysql -udbo -pdbo dbo < /vagrant/queries/query1.sql > /dev/null )

real	0m0.043s
user	0m0.007s
sys	0m0.027s
```

Het tweede voorbeeld toont hoe je de tijd kan meten die nodig is om een query uit te voeren. Er wordt hier geen uitvoer getoond omdat die voor onze experimenten niet relevant is. Controleer wel eerst of je queries het verwachte resultaat geven voordat je de uitvoer negeert!

De betekenis van de verschillende waarden:

- `real`: de werkelijke verstreken tijd
- `user`: Aantal CPU-seconden dat het proces in "user mode" doorbracht
- `sys`: Aantal CPU-seconden dat het proces in "kernel mode" doorbracht

Vooral de eerste waarde is van belang. Je zal zelf een script moeten schrijven om de query herhaaldelijk uit te voeren en de tijden op te slaan in een tekst-/CSV-bestand voor verwerking met R.

## Structuur code

```console
[vagrant@srv001 vagrant]$ tree /vagrant
/vagrant
├── data
│   ├── category.csv   # CSV-bestand met data voor tabel "category"
│   ├── create-db.sql  # SQL-script dat database-tabellen aanmaakt
│   ├── customer.csv
│   └── ...
├── provisioning       # Bevat scripts voor configuratie VMs
│   ├── common.sh      # Dingen die op elke VM uitgevoerd worden
│   ├── srv001.sh      # Script voor installatie VM `srv001'
│   └── util.sh        # Bevat herbruikbare Bash-functies
├── queries
│   ├── query10.sql    # Alle queries uit Bassil (2012)
│   ├── query11.sql
│   ├── query1.sql
│   ├── query2.sql
│   └── ...
├── README.md          # Dit bestand
├── Vagrantfile        # Configuratie Vagrant-omgeving (geen wijzigingen nodig)
└── vagrant-hosts.yml  # Opsomming van alle VMs in deze testomgeving

4 directories, 33 files

```

## Experimenten uitbreiden

### Queries

Je kan nieuwe queries toevoegen in de directory `queries/` en uitvoeren:

```console
[vagrant@srv001 ~]$ mysql -udbo -pdbo dbo < /vagrant/queries/queryNN.sql
```

Enkele opmerkingen:

- In het artikel van Bassil (2012) is Query 8 fout. Probeer deze te verbeteren.
- Zorg er voor (door het construeren van geschikte data) dat alle queries ook iets van resultaten teruggeven. Dit geldt in het bijzonder de complexere queries.

### Data

De testdata die je in `data/` kan vinden, is minder uitgebreid dan wat Bassil (2012) rapporteerde. In deze opstelling zitten in totaal 100.000 records, terwijl dit er oorspronkelijk 1.000.000 waren. Breid de dataset dus zelf uit. Je kan dit doen met een eenvoudig script of zelfgeschreven programma dat random data genereert. De resultaten moeten opgeslagen worden in een .CSV-bestand met dezelfde naam en structuur als de huidige.

Om nieuwe data in de database te importeren, moet de huidige database eerst verwijderd worden:

1. Verwijder de database door in te loggen op de server (`vagrant ssh`) en het volgende commando uit te voeren:
    ```
    mysql -uroot -pletmein <<< 'DROP DATABASE dbo'
    ```
2. Log vervolgens terug uit en voer `vagrant provision` uit.

Het provisioning-script zal de database opnieuw aanmaken en data inladen uit de CSV-bestanden.

### Nieuwe VM toevoegen

Als je een nieuwe VM wil toevoegen aan de opstelling (bijvoorbeeld met een ander database-systeem waarmee je wil vergelijken), moet je eerst `vagrant-hosts.yml` bewerken:

```yaml
- name: srv001
  ip: 192.168.56.31

# - name: srv002
#   ip: 192.168.56.32
```

In de huidige opstelling is er één VM gedefinieerd met naam `srv001` en IP-adres 192.168.56.31. 


## Referenties

Bassil, Y. (2012). A Comparative Study on the Performance of the Top DBMS Systems. *Journal of Computer Science & Research, 1*(1), p. 20 - 31
