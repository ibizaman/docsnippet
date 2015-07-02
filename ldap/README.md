$ ldapmodify -D "cn=root,dc=my,dc=domain,dc=com" -W
dn: uid=NAME,ou=People,dc=my,dc=domain,dc=com
changetype: modify
replace: userPassword
userPassword: password
