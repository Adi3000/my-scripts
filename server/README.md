# How to

## Dependencies

```bash
apt-get install jq yq git ufw sudo openssl
```
## Add to sudo

```bash
echo -n "What is the new user to add : "
read user_to_add
echo -n "What is the password ? : "
read -s password_to_set
useradd --user-group --create-home -s /bin/bash -p $password_to_set $user_to_add
usermod -a -G sudo $user_to_add
```

## Install docker

* [Documentation](https://docs.docker.com/engine/install/debian/#install-using-the-repository)

## Resources

* [UFW docker rules](https://github.com/chaifeng/ufw-docker?tab=readme-ov-file#tldr=)
