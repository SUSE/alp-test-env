# ALP Test Env

This repo provides a framework for bringing up one of more ALP VMs, via
libvirt, in a repeatable fashion.

# Support for Remote Libvirt Host

The Libvirt host can either be the local system (default) or a remote
system specified via the `settings/libvirt_host.yml`.


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

Additional actions are required, beyond those that are provided by the
ansible.builtin collection; the required collections are specified in
the `ansible/requirements.yml` file, and can be install using the
`ansible-galaxy` command if not available.


# Getting Started
See the example files in settings/ for available configuration settings.
Example configuration files are provided with comments explaining what
options are available.

NOTE: It is is highly recommended to create the config.yml, vnets.yml
and vms.yml under settings. Setup the libvirt_host.yml if you want to
use a remote Libvirt host.

If you don't already have a suitable version of Ansible available, you
can run `bin/create-venv` to create an appropriatlely setup virtualenv,
with all of the relevant Ansible commands symlinked under the `bin`
directory.

## Creating a Test Env

Run `bin/ansible-playbook ansible/test_env_create.yml` to create the VMs,
and associated libvirt networking infrastructure, on the target Libvirt
host, as specified by the configured `settings/*.yml` files.

## Installing Workloads

To customise the workloads that will be installed, you can copy the
`settings/workloads.yml.example` to `settings/workloads.yml` and modify
the example list, which specifies the `ansible` and `kvm` workloads to
be installed. These settings match the defaults that will be used if
no workloads are specified.

Run `bin/ansible-playbook ansible/setup_alp_workloads.yml` to install
the specified workloads.

### Support for runlabels

It is expected that any workload container images specified will have
labels defined that provide 'install' and 'uninstall' capabilities,
though the actual names used can be customised.

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
settings, such as ProxyCommand directives, allowing direct access to
the created VMs.

For example, assuming default VM config settings, you could SSH to the
*alptestvm* VM, running locally or on a remote Libvirt host as follows:

```
% ssh -F ssh/config alptestvm
Last login: Thu Feb 16 20:45:09 UTC 2023 from 192.168.187.1 on ssh
Have a lot of fun...
testenv@alptestvm:~>
```

# Future Enhancements

TODO:
  * Add support for installing relevant required packages as part of
    the provisioning process.
  * Dynamically figure out latest Build or Snapshot image and download
    that, exposing via a generic symlink so that VM creation workflow
    can be agnostic of image version.
  * Finish off support for kvm_encrypted VM type.
  * After bringing up ALP VMs mount extra disks on specified mount points
  * Use ansible container to:
    * (re-)configure networking
    * setup Libvirt via container and bring up nested VMs.
