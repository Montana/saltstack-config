users:
  www-data:
    uid: 1011
    groups:
      - www-data
  auser:
    uid: 1018
    sudouser: True
    ssh_auth: ssh-rsa YOUR_SSH_PUB_KEY
  git:
    uid: 3019
    sudouser: True

absent_users:
  - badguy
