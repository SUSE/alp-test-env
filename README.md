# ALP Test Env

Bring up ALP test instances in a repeatable fashion.

See the example files in settings/ for configuration settings.

Run `bin/create-venv` to create an appropriate Ansible virtualenv to be
able to run the ansible playbooks in this repo.

Run `bin/ansible-playbook ansible/test_env_create.yml` to create the VMs,
and associated libvirt networking infrastructure on the target Libvirt
host (defaults to localhost).

Run `bin/ansible-playbook ansible/test_env_cleanup.yml` to cleanup any
previously created VMs and associated resources.

TODO:
  * After bringing up ALP VMs mount extra disks on specified mount points
    * The default is to add an extra disk that will replace the existing
      /home subvolume.
  * Fix sudoers settings (disable targetpw settings)
  * Create test user account for remote access, rather than root account
  * Install ansible container and use it to:
    * (re-)configure networking
    * setup Libvirt via container and bring up nested VMs.
