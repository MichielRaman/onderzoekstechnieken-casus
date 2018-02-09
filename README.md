# Casus onderzoeksproces

Gebruik deze repository voor het bijhouden van alle informatie, code en resultaten van jullie mini-onderzoek rond performantie van databases. Gebruik [Markdown](https://guides.github.com/features/mastering-markdown/) voor verslagen, procedures, enz. (alle bestanden waar je anders Word voor zou gebruiken). Een sjabloon voor het artikel en een bestand voor de bibliografische databank is ook voorzien.

## TODOs

- [ ] Elk teamlid kloont deze repository
- [ ] Vul de namen en contactinfo van de teamleden aan
- [ ] Verander de naam van de teamleden in de tabel hieronder
- [ ] Pas de naam aan van het LaTeX document voor het artikel aan in "familienaam-etal-dbperf.tex" (met de familienaam van het teamlid die alfabetisch eerst komt).
- [ ] Nog niet vertrouwd met het gebruik van Git? Lees [info git md](info-git.md)
- [ ] Reproduceer de testomgeving in [experiment/](experiment/)

Verwijder dit TODO-lijstje als alle taken afgehandeld zijn.

## Teamleden

| Naam     | Github                        | Email                               |
| :---     | :---                          | :---                                |
| student1 | <https://github.com/student1> | <mailto:student1@student.hogent.be> |
| student2 | <https://github.com/student2> | <mailto:student2@student.hogent.be> |
| student3 | <https://github.com/student3> | <mailto:student3@student.hogent.be> |
| student4 | <https://github.com/student4> | <mailto:student4@student.hogent.be> |

## Installatie software

Bij deze opgave is code meegeleverd voor het opzetten van een reproduceerbare testomgeving. Je moet daarvoor twee applicaties installeren:

- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [Vagrant](https://www.vagrantup.com/downloads.html)

Na installatie van de software, ga je naar de directory `experimenten/` en voer je het commando `vagrant up` uit. Er wordt een nieuwe virtuele machine gecreëerd met MariaDB.

### Windows

**Windows**-gebruikers die de [Chocolatey](https://chocolatey.org/) package manager geïnstalleerd hebben kunnen dit het eenvoudigst met:

```console
> choco install -y virtualbox
> choco install -y vagrant
```

### MacOS X

Software installeren op MacOS X doe je best met de [Homebrew](https://brew.sh/) package manager.

```console
$ brew cask install virtualbox
$ brew cask install vagrant
```

### Fedora

Als je **Fedora** gebruikt, is het beter Vagrant te installeren vanaf de website en niet uit de repositories. Deze laatste versie werkt niet samen met VirtualBox.

```console
$ sudo dnf install -y https://download.virtualbox.org/virtualbox/5.2.6/VirtualBox-5.2-5.2.6_120293_fedora26-1.x86_64.rpm
$ sudo dnf install -y https://releases.hashicorp.com/vagrant/2.0.2/vagrant_2.0.2_x86_64.rpm
```

Controleer de URLs op de download-pagina's van de respectievelijke applicaties. Als er een nieuwe versie uitgebracht wordt, zullen de URLs ook veranderen.


