Fix ssh conection: 
> user@1.1.1.1: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).

```bash
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart ssh
```