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
├── provisioning       # Scripts to configure VMs
│   ├── common.sh      # Stuff executed on every VM
│   ├── srv001.sh      # Script for installation of VM `srv001'
│   └── util.sh        # Contains reusable Bash functions
├── queries
│   ├── query10.sql    # All queries from Bassil (2012)
│   ├── query11.sql
│   ├── query1.sql
│   ├── query2.sql
│   └── ...
├── README_en.md       # This README
├── Vagrantfile        # Configuration Vagrant environment (should not be changed)
└── vagrant-hosts.yml  # Overview of all VMs in this test environment

4 directories, 33 files

```

## Extending the experiments

### Queries

You can add new queries in the directory `queries/` and execute them:

```console
[vagrant@srv001 ~]$ mysql -udbo -pdbo dbo < /vagrant/queries/queryNN.sql
```

Some remarks:

- Query 8 from the article of Bassil (2012) is wrong. You will need to correct this query.
- Make sure that all queries return something. To achieve this you will need to construct additional data. This is the case for the more complex queries in particular.

### Adapting test data

The test data under `data/` is less extensive than the data from Bassil (2012). In this setup we have 100,000 records. The setup of Bassil (2012) contains 1,000,000 records. You have to extend the data set yourself. You can generate random data with a simple script or program. This additional data must be saved in CSV files with the same name and structure as the current ones.

Don't forget to drop the database, before you import new data:

1. To remove the database: log on to the server (`vagrant ssh`) and execute:
    ```
    mysql -uroot -pletmein <<< 'DROP DATABASE dbo'
    ```
2. Next, log off and execute `vagrant provision`

The provisioning script will create a new database and will import the data from the CSV files.

### Adding a new VM

If you want to add a new VM to the setup, you will need to update `vagrant-hosts.yml`. This will be necessary to setup an additional database system, to compare with the MariaDB system:

```yaml
- name: srv001
  ip: 192.168.56.31

# - name: srv002
#   ip: 192.168.56.32
```

Currently there is only one VM defined with the name `srv001` and IP address 192.168.56.31. To add a new VM, just uncomment the concerning lines. You can install another OS than CentOS 7 by specifying a different "base box". You can find an overview of available operating systems on <https://app.vagrantup.com/boxes/search>. Example:


```yaml
- name: srv001
  ip: 192.168.56.31

- name: srv002
  ip: 192.168.56.32
  box: bento/ubuntu-16.04
```

You will need a script with the name of your VM in the `provisioning/` directory. For example, you can copy `srv001.sh` to `srv002.sh`:

```shell
$ cp provisioning/srv001.sh provisioning/srv002.sh
```

Update the script and start your new VM:

```shell
$ vagrant up srv002
```

**Remark:** Currently, the VMs have 1024MB RAM memory and 1 CPU core. You can update these values in the file `Vagrantfile`:

```Ruby
# Default memory size and number of CPUs for the VMs
MEMORY = 1024
CPUS = 1
```

### Vagrant tips

The most important commands to work with Vagrant are:

| Command                    | Task                            |
| :---                       | :---                            |
| `vagrant up srv001`        | start up `srv001`               |
| `vagrant ssh srv001`       | log in on `srv001`              |
| `vagrant reload srv001`    | reboot `srv001`                 |
| `vagrant halt srv001`      | shut down `srv001`              |
| `vagrant provision srv001` | execute the provisioning script |
| `vagrant destroy srv001`   | destroy `srv001`                |

If you omit the name of the VM, the command will be executes on *all* defined VMs.

A few tips:

- The first time you type `vagrant up`, the provisioning script (`provisioning/srv001.sh`) to install and configure your VM will be executed. Next time, the provisioning will not be executed anymore, but you can still *force* it by typing `vagrant provision`.
- If you change the script, it is not necessary to remove or reboot the VM. It is sufficient to run `vagrant provision`.
- The current provisioning script is written so that it can be run multiple times. It will only update what needs to be updated. For example: if the database already exists, it will not be removed. Try to keep it that way.
- Make sure that no manual changes are needed anymore, so put everything in the script. This way, your team members can easily reconstruct the VM and use it immediately.

## References

Bassil, Y. (2012). A Comparative Study on the Performance of the Top DBMS Systems. *Journal of Computer Science & Research, 1*(1), p. 20 - 31
