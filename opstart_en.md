# Start-up

## TODOs

- [ ] Install the necessary software (see below)
- [ ] Each team member clones this repository (see below)
- [ ] Fill out the names and contact information of team members in [README_en.md](README_en.md)
- [ ] Adjust the name of "dbperf.tex" under [paper_en/](paper_en/) into "dbperf-icX.tex" (with X being the number of your group)
- [ ] Get familiar with Git (More info at the bottom of this document)
- [ ] Reproduce the test environment under [experiment/](experiment/)

## Software installation

There are some scripts provided to help you setting up the test environment. You will need the following applications to run these scripts:

- [Git client](https://git-scm.com/downloads)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [Vagrant](https://www.vagrantup.com/downloads.html)

### Windows

For **Windows** users, the easiest way is to first install the [Chocolatey](https://chocolatey.org/) package manager, and then run the commands below one by one:

```console
> choco install -y git
> choco install -y virtualbox
> choco install -y vagrant
```

### MacOS X

To install the software on MacOS X, it is preferred to use the [Homebrew](https://brew.sh/) package manager.

```console
$ brew install git
$ brew cask install virtualbox
$ brew cask install vagrant
```

### Fedora

If you are using **Fedora**, it is better to install Vagrant from the website (dnf install https://...) and *not* from the Fedora repositories (dnf install vagrant). The latter is not compatible with VirtualBox.

```console
$ sudo dnf install -y git
$ sudo dnf install -y https://download.virtualbox.org/virtualbox/5.2.6/VirtualBox-5.2-5.2.6_120293_fedora26-1.x86_64.rpm
$ sudo dnf install -y https://releases.hashicorp.com/vagrant/2.0.2/vagrant_2.0.2_x86_64.rpm
```

Check the URLs above. You might need to update the version numbers and/or adapt the path.

## Create a VM with Vagrant

Af the installation of the software, go to the directory `experimenten/` and execute the command `vagrant up`. This will create a new virtal machine (VM) with MariaDB.

## Git workflow for a team

When working with Git in a team, chances are that you create conflicts when several contributors change the same file independently and push their version to Github. A few tips to avoid this, and the most important commands to use follow below. Most students may prefer a graphical tool like SourceTree or Github Desktop, but for learning and understanding Git, we prefer that you use the command line tool. The command line is actually pretty good and also explains every time what the next step should be and how to undo a step. Error messages, when read carefully, usually give a good idea of what went wrong and how to solve it.

Try to become proficient with Git as soon as possible, you will need it continually... Commit regularly, multiple times per session that you're working on the project. Provide a descriptive commit message, your fellow team members and your future self will be grateful.

Working with branches is probably unnecessary and will not be discussed here.

### Installing and configuring Git

When installing [Git for Windows](https://git-scm.com/download/), ensure that Git Bash is included. To simplify syncing with Github, it is recommended to generate and use an [SSH key pair](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/). When prompted for a passphrase, you can leave it empty. Follow Github's instructions to [register your SSH-key](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/).

Start a Git Bash (Windows) or bash in a console (Linux/Mac) and issue the following commands for the basic configuration of Git. Use the email address that you have used to register your Github accound.

```
$ git config --global user.name "FIRST_NAME SURNAME"
$ git config --global user.email "NAME@EXAMPLE.COM"
$ git config --global push.default simple
```

### Project start

Each team member creates a local copy (clone) of the Github repository.

1. Go to the Github repository, click the green button "Clone or Download" on the right. Ensure that "Use SSH" is selected. Copy the URL (starts with `git@github.com:HoGentTIN`)
2. Open Git Bash in a directory where you want to keep the local repository
3. `git clone git@github.com:HoGentTIN/TEAM-REPO.git`

You can rename or move the directory with your local copy of the repository. This will have no impact on the repository or the synchronisation of the repository with Github, as long as you never touch the hidden `.git/` directory.

### Workflow

1. Before you start making changes, first pull in any new commits from Github:

    ```
    $ git pull
    ```

2. Make your own changes and commit them locally:

    ```
    $ git add .
    $ git commit -m "Descriptive message about your changes"
    ```

3. Send your local changes to Github:

    ```
    $ git push
    ```

4. If the `git push` from step 3 succeeds, then you are done. If the `git push` fails with an error message `[rejected]`, you will need to get the new changes from Github first and ***merge*** them with your local changes:

    ```
    $ git pull --no-commit
    ```
    
5. Review the result of this merge: 

    ```
    $ git diff HEAD
    ```

6. Resolve possible conflicts by editing the affected files. Repeat the `git diff HEAD` until you are satisfied. Then commit the result of the merge:

	```
	$ git add .
	$ git commit -m "Merging from master"
	```
	
7. Go back to step 3.

Execute the `git pull` (step 1) and `git push` (step 3) as frequent as possible.
This will minimize the number of "rejected" pushes, and thus the number of merges and conflicts.
Obviously, making good arrangements and distributing tasks properly, also helps to prevent merge conflicts.

Additionally, there are a few commands that will give you additional information and a better understanding,
without changing the state of your repository or files. Try these commands:

```
$ git status
$ git diff
$ git log
$ git log --graph --pretty="%C(red)%h %C(blue)%ai %C(green)%aN %C(reset)%s%C(red)%d"
$ git whatchanged
$ git whatchanged --graph --pretty="%C(red)%h %C(blue)%ai %C(green)%aN %C(reset)%s%C(red)%d"
$ git blame FILENAME
```

To get more information about a command, use `git help`. For example:

```
$ git help commit
$ git help diff
$ git help log
```
