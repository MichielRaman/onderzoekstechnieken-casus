# Environment for database performance experiments

In this directory you will find an example of a reproducible test environment for testing database performance. The first step is to reproduce the experiments from Bassil (2012) on a MariaDB server.

If you run into problems, setting up the test environment, you can contact [Bert Van Vreckem](mailto:bert.vanvreckem@hogent.be).

## Setup instructions

Follow the instructions to setup a MariaDB-server on CentOS 7. The database is created and filled with data as discribed in Bassil (2012).

1. First install VirtualBox and Vagrant.
2. Open a Bash-shell (Git Bash on Windows) and go to this directory (`experiment/`)
3. Execute `vagrant up`. This will create and start a new virtual machine in VirtualBox. The first time you do this, it will download a 500 MByte base VM. So, make sure you have a proper internet connection when doing this.
4. When `vagrant up` finishes, the database server should be ready. To log on, use `vagrant ssh`.

On the server, you will find a directory `/vagrant/` with the same content of this directory (`experiment/`). All changes will be visible in both locations.

## Executing queries

In the database there is a user `dbo` with password `dbo`. The name of the database for the experiment is also `dbo`. Here are some examples on how to execute the queries (after logging on to the server):

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

All queries from Bassil (2012) are available on the server under `/vagrant/queries`. Execute them as below:

```console
[vagrant@srv001 ~]$ mysql -udbo -pdbo dbo < /vagrant/queries/query1.sql
[ ... ]
[vagrant@srv001 ~]$ time ( mysql -udbo -pdbo dbo < /vagrant/queries/query1.sql > /dev/null )

real	0m0.043s
user	0m0.007s
sys	0m0.027s
```

The second example shows you how to measure the time that was necessary to execute the query. The output is not shown (`>/dev/null`) because this is not relevant for this experiment. However, make sure to check the result of the query the first time (for every different query), before you ignore it!

The meaning of the values:

- `real`: the total time that has elapsed
- `user`: the time that the proces has spent in "user mode"
- `sys`: the time that the proces has spent in "kernel mode"

The first number is the most important one. You will have to write a script yourself to execute the query multiple times and to store the execution times in a text or CSV file, so that you can process it in R.

## Code structure

```console
[vagrant@srv001 vagrant]$ tree /vagrant
/vagrant
├── data               # Data to fill the database
│   ├── category.csv   # CSV file with data for the "category" table
│   ├── create-db.sql  # SQL script that generates the tables
│   ├── customer.csv   # CSV file wit data for the "customer" table
│   └── ...            #   etc.
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

### Testdata aanpassen

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

In de huidige opstelling is er één VM gedefinieerd met naam `srv001` en IP-adres 192.168.56.31. Je kan een nieuwe VM toevoegen door de laatste regels uit commentaar te halen. Je kan een ander OS dan CentOS 7 installeren door een alternatieve "base box" te specifiëren. Een overzicht van beschikbare systemen kan je vinden op <https://app.vagrantup.com/boxes/search>. Voorbeeld:


```yaml
- name: srv001
  ip: 192.168.56.31

- name: srv002
  ip: 192.168.56.32
  box: bento/ubuntu-16.04
```

Voeg vervolgens een script met dezelfde naam als de VM toe in de directory `provisioning/`. Je kan bv. het script voor de eerste kopiëren:

```shell
$ cp provisioning/srv001.sh provisioning/srv002.sh
```

Bewerk het script voor je nieuwe VM en start de VM op:

```shell
$ vagrant up srv002
```

**Opmerking:** De VMs krijgen nu 1024MB RAM-geheugen en 1 processorkern toegewezen. Als je deze waarden wilt aanpassen, bewerk dan het bestand `Vagrantfile` en pas de variabelen `MEMORY` en `CPUS` aan:

```Ruby
# Default memory size and number of CPUs for the VMs
MEMORY = 1024
CPUS = 1
```

### Vagrant tips

De belangrijkste commando's om met Vagrant te werken:

| Commando                   | Taak                              |
| :---                       | :---                              |
| `vagrant up srv001`        | start `srv001` op                 |
| `vagrant ssh srv001`       | log in op `srv001`                |
| `vagrant reload srv001`    | `srv001` rebooten                 |
| `vagrant halt srv001`      | `srv001` afsluiten                |
| `vagrant provision srv001` | het provisioning-script uitvoeren |
| `vagrant destroy srv001`   | vernietig `srv001`                |

Als je de naam van de VM weglaat, wordt het commando uitgevoerd op alle gedefinieerde VMs.

Enkele tips:

- De allereerste keer dat je `vagrant up` doet, wordt ook het zgn. provisioning-script (`provisioning/srv001.sh`) dat de VM installeert en configureert. Wanneer je opnieuw opstart, wordt dat niet meer gedaan, en moet je expliciet `vagrant provision` uitvoeren.
- Als je het script wijzigt, dan is het niet noodzakelijk om de VM te verwijderen of te rebooten. `vagrant provision` volstaat.
- Het huidige provisioning-script is zo geschreven dat het meerdere keren na elkaar kan uitgevoerd worden en zal enkel wijzigingen aanbrengen indien nodig. Bijvoorbeeld, als de database al bestaat, zal die niet verwijderd worden. Probeer dat zo te houden.
- Zorg er voor dat er geen manuele wijzigingen meer nodig zijn, maar zet alles in het script. Zo kunnen je teamleden makkelijk de VM reconstrueren en onmiddellijk gebruiken.

## Referenties

Bassil, Y. (2012). A Comparative Study on the Performance of the Top DBMS Systems. *Journal of Computer Science & Research, 1*(1), p. 20 - 31
