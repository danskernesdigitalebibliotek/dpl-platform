# Troubleshooting error when connecting to Lagoon throug Lagoon CLI

## When to use

When you encounter an ssh error like this:
`ssh: attempting connection using private key: /home/dplsh/.ssh/id_rsa
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ssh-ed25519 key sent by the remote host is
SHA256:HpeJZyqXUSwShXoHwY0vx2r02QGzAR4anHw1WoHCrNA
Add correct host key in /home/dplsh/.ssh/known_hosts to get rid of this messagecouldn't refresh token: unable to authenticate or connect to host 20.238.202.21:22
there may be an issue determining which ssh-key to use, or there may be an issue establishing a connection to the host
the error returned was: ssh: handshake failed: knownhosts: host key verification failed`

This error occurs because the Lagoon SSH server had its key rolled, most
likely during an upgrade to the Lagoon Chart.

## How to fix

This part needs to be run outside of the DPL shell.
The first thing we need to know, is which entry in the `known_hosts` file is
wrong.
This can be discovered by running the following command:
`ssh -t lagoon@<external IP of lagoon-core-ssh> token`
The IP can be found by running the following command:
`kubectl get -o jsonpath='{.status.loadBalancer.ingress[0].ip}' -n lagoon-core service lagoon-core-ssh`

Next, run the command `ssh·-t·lagoon@<external·IP·of·lagoon-core-ssh>·token`
with the populated IP of the SSH server.

This should trigger the following error:
`@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ED25519 key sent by the remote host is
SHA256:HpeJZyqXUSwShXoHwY0vx2r02QGzAR4anHw1WoHCrNA.
Please contact your system administrator.
Add correct host key in /home/dplsh/.ssh/known_hosts to get rid of this message.
Offending ED25519 key in /home/dplsh/.ssh/known_hosts:7
Host key for 20.238.202.21 has changed and you have requested strict checking.
Host key verification failed.`

We need the following part of the eror:
`Offending ED25519 key in /home/dplsh/.ssh/known_hosts:7`
The number at the end is the entry index number of the known_hosts file which
has gone bad.

Now delete the bad entry by by running this command:
`sed -i -e <index of bad entry>d /home/dplsh/.ssh/known_hosts`

If you have the Lagoon CLI installed on your local machine you can run this part
while outside of the shell. Otherwise, open the shell, but don't log in yet.
Now readd the Lagoon Config, but add a pointer to which ssh key to use:
`lagoon config add --lagoon dplplat01
lagoon config add \
    --graphql https://api.lagoon.dplplat01.dpl.reload.dk/graphql \
    --force \
    --ui https://ui.lagoon.dplplat01.dpl.reload.dk \
    --hostname 20.238.147.183 \
    --port 22 \
    --ssh-key <path to ssh key, which in DPLSH is located at /home/dplsh/.ssh/somkey>`

now run `lagoon login`. There might be another bad key that needs to be removed
else it should now log you in again.

