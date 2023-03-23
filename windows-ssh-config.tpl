add-content -path c:/Users/Veeresh/.ssh/config -value @`

Host ${hostname}
    HostName ${hostname}
    User ${user}
    IdentityFile ${identityfile}
'@
