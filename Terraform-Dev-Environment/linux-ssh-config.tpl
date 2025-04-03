cat << EOF >> ~/.ssh/config

Host ${host}
    HostName ${host}
    User ${user}
    IdentityFile ${identityfile}
EOF