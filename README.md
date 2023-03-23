# ALP Test Env

This repo provides a framework for bringing up one of more ALP VMs, via
libvirt, in a repeatable fashion.


# Ensuring that a viable version of Ansible is available

To be able to use these tools you will need a recent version of
Ansible, based upon ansible-core 2.13.x (Ansible 6.x) or newer.

If needed, you can use the `bin/create-venv` helper script to create
a Python venv with the latest version of Ansible that is compatible
with your system's Python version, which will make all of the Ansible
commands available under the `bin/` directory.

The example commands, shown below, assume that the venv is being using,
so the Ansible commands will be prefixed by `bin/`; remove this if you
have an appropriate Ansible version already available.


# Quick Start

Assuming you have an appropriate version of Ansible available, with
the relevant Ansible collections installed (see below for the Ansible
requirements) to quickly get started you can create an ALP test env
by running the `ansible/test_env_create.yml` playbook, like so:

```shell
$ bin/ansible-playbook ansible/test_env_create.yml
```

Doing so will automatically setup the `vms.yml` and `vnets.yml` files
under the `settings/` directory using the corresponding example files,
and, all going well, should create a Libvirt managed ALP VM, called
`alptestvm`, on the local system, with the Ansible workload for ALP
installed, that you can log in to using the generated SSH config file,
`ssh/config`, as follows:

```shell
$ ssh -F ssh/config alptestvm
```

Re-running the `ansible/test_env_create.yml` playbook will destroy and
recreate the configured VMs and associated networks.

If you want to completely cleanup all of these resources you can run
the `ansible/test_env_cleanup.yml` playbook as follows:

```shell
$ bin/ansible-playbook ansible/test_env_create.yml
```

See below for further details on requirements, using a remote Libvirt
host, and customising the test env that will be deployed.


# Requirements

## Ansible
It is recommended to use an Ansible Core >= 2.13, which corresponds to
version 6 or later of the Ansible meta package.

NOTE: The Ansible commands must have viable Python Libvirt support.

Tested with Ansible installed in a virtualenv (see below):
  * Ansible meta package version 6.7.0
  * Ansible core version 2.13.7

### Ansible Virtualenv

A helper script, `bin/create-venv` is available that can be used to
create a Python virtualenv with an appropriate version of Ansible,
Ansible Lint, and their dependent packages installed. The virtualenv
is created with access to host site packages enabled so that it can
leverage the system Python Libvirt integration support.

The `bin/create-venv` also creates symlinks under the `bin` directory
for all of the Ansible commands provided by the virtualenv, allowing
those commands to be run by simply prefixing them with `bin/` when
cd'd to the top-level directory of this repo.

### Ansible Collection Requirements

Additional collections may be required, beyond those that are provided
by the ansible.builtin collection. The list of required collections are
specified in `ansible/requirements.yml` file, and can be installed by
running the `ansible-galaxy` command as follows:

```shell
$ ansible-galaxy collection install -r ansible/requirements.ym
```

## Libvirt host

The VMs will be created on the specified Libvirt host, defaulting to
the local system. Please ensure that the system has been appropriately
setup and is ready to use.

If using a remote Libvirt host, please ensure that SSH access to the
system works for the current user to connect to the required account
on the Libvirt host.


# Getting Started

See the example files in settings/ for available configuration settings.
Example configuration files are provided with comments explaining what
options are available.

It is highly recommended to at least create the `vnets.yml` and `vms.yml`
files under settings/.

NOTE: If you run the `test_env_create.yml` playbook without having created
the required settings files, the example versions will be used to create
these files automatically but those example settings could potentially
conflict with other network resources so please check they are correct.

## Ansible

If you don't already have a suitable version of Ansible available, you
can run `bin/create-venv` to create an appropriatlely setup virtualenv,
with all of the relevant Ansible commands symlinked under the `bin`
directory.

## Remote Libvirt host

Setup the `libvirt_host.yml` if you want to use a remote Libvirt host.
The default is to use the local system as the Libvirt host.

## Configuring Workloads to be setup

To customise the workloads that will be installed, you can copy the
`settings/workloads.yml.example` to `settings/workloads.yml` and modify
the example list, which, by default, specifies the `ansible` workload
to be installed. These settings match the defaults that will be used if
no workloads are specified.

The configured workloads will automatically be installed when bringing
up the test env, but if you configure additional workloads after having
created a test-env, you can run the `ansible/setup_alp_workloads.yml`
playbook to install them without having to recreate the entire test env.

### Support for runlabels

It is expected that any workload container images specified will have
labels defined that provide 'install' and 'uninstall' capabilities,
though the actual names used can be customised.

## Creating a Test Env

Run `bin/ansible-playbook ansible/test_env_create.yml` to create the VMs,
and associated libvirt networking infrastructure, on the target Libvirt
host, as specified by the configured `settings/*.yml` files.

## Cleaning up a Test Env

Run `bin/ansible-playbook ansible/test_env_cleanup.yml` to cleanup any
previously created VMs and associated resources.


# SSH Access to Test Env VMs

As part of bringing up any test VMs for the first time an SSH key pair,
of type ed25519, will be created under the `ssh` directory.

This generated key's public value, along with any others that may have
been specified via *ssh_pub_keys* in the `settings/config.yml`, will be
added to the `authorized_keys` files of both the root and test env user
accounts, via th Ignition config settings, when bringing up the VMs, and
will be used by Ansible to access the VMs.

Additionally `ssh/config` will be generated, with appropriate config
settings, such as ProxyCommand directives when using a remote Libvirt
host, allowing direct access to the created VMs.

For example, assuming default VM config settings, you could SSH to the
*alptestvm* VM, running locally or on a remote Libvirt host as follows:

```
% ssh -F ssh/config alptestvm
Last login: Thu Feb 16 20:45:09 UTC 2023 from 192.168.187.1 on ssh
Have a lot of fun...
testenv@alptestvm:~>
```


# Contributing

The code should pass validation with `bin/ansible-lint` (version 6.14 as
of writing), noting that 'yaml[comments]' are explicitly ignored for
the `settings/*.yml` files that may have been created.

## Some rules explicitly ignored in code
Some `# noqa ...` comment markers exist in the code to explicitly ignore
certain rules, such as complaints that handlers should be used for actions
that run because something has changed.


# Future Enhancements

TODO:
  * Finish off support for kvm_encrypted VM type.
  * After bringing up ALP VMs mount extra disks on specified mount points
