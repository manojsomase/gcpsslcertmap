```
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░▒▓██▓▒░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░▒▓█▓▒░░▒▓█▓▒░░░░░░░░░░░░░░░░░░░
░░░░░░░░░▒▒▒▒▒▓▓██▓▒▒░▒▓██▓▒░▒▒▓██▓▓▒▒▒▒▒░░░░░░░░░
░░░░░░░░▓█▒▒▒▒▒░░░▒▓▓████████▓▓▒░░░▒▒▒▒▒█▓░░░░░░░░
░░░░░░░░▓█░░▓▓██████████████████████▓▓▒░██░░░░░░░░
░░░░░░░░▓█░▒██████████████████████████▒░██░░░░░░░░
░░░░░░░░▓█░░██████████████████████████▒░█▓░░░░░░░░
░░░░░░░░▒█▒░██████████████████████████░▒█▒░░░░░░░░
░░░░░░░░░█▓░▓███████CERT MAP█████████▓░▓█░░░░░░░░░
░░░░░░░░░▓█░░██████Automation████████▒░█▓░░░░░░░░░
░░░░░░░░░░██░▓██████████████████████▓░▓█░░░░░░░░░░
░░░░░░░░░░▒█▓░▓████████████████████▓░▒█▒░░░░░░░░░░
░░░░░░░░░░░▒█▒░▓██████████████████▓░▒█▒░░░░░░░░░░░
░░░░░░░░░░░░▒█▓░▒████████████████▒░▓█▒░░░░░░░░░░░░
░░░░░░░░░░░░░░██░░▓█████████████░░██▒░░░░░░░░░░░░░
░░░░░░░░░░░░░░░▓█▓░▒▓████████▓▒░▓█▓░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░▓█▓░░▓████▓░░▓█▓░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░▓█▓▒░░░░▒▓█▓░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░▒▓█▓▓█▓▒░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░▒░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
```
# GCP cert map automation script

This is automation solution written in bash script. This simplifies the process of creating many google managed certificates, creating a certificate map, and finally attaching it to Load balancer on Google Cloud. There are 2 solution bundled with this package.

## 1. Creating individual certificates one after another manully.

This is done by exeuting the file `cert.sh`. You need to run it in your shell prompt as `sh cert.sh`, and it will ask you the following inputs
-  domain name for ssl cert
-  certificate name
-  certificate auth name.

Once you enter the above details, it will create the ssl cert in your account, and will ask you if you want to create more ssl certs. 
Once done, it will proceed to the next steps, to create cert map. One cert map can have many certificates associated with it.
Once you provide the cert map, it will add all the entries of newly created ssl certs to this map, and verifies if the entries are done and propogated successfully.
Once teh entries are propogated, it will ask you if you want to attach this cert to the load balancer. When you select yes, it will give you the list of available load balancers. Select the one you want and done.

It will output a `dns.txt` file where you can ss the required DNS records for certificate provisioning process. Once you make the DNS records, wait for some time for certs to get approved.

## 2. Create certs in bulk quickly.

This is done by providing all the domain names in inout txt file called `domain.txt`. The domain names shoud be present one by one each in new line. Exexute the bash script `sh bulk.sh` and it will create all the ssl certs in 1 go, by giving relevant names to certificates and dns auth.
Once the above step is complete, it will ask you further details of cert map name and will proceed from there like method#1 mentioned above. Finally, it will output a `dns.txt` file where you can ss the required DNS records for certificate provisioning process. Once you make the DNS records, wait for some time for certs to get approved.
