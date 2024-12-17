# DNS setup for library sites

When going live with a library site, DNS needs to be updated. Update
all domain names configured on the site to the IP/name documented in
[Current Platform
environments](platform-environments#dns-setup-for-library-sites).

A records should point to `20.86.109.250`

CNAME records should point to `cluster-1.folkebibliotekernescms.dk`

If any of the domains have CAA records, they should be updated
according to [ZeroSSL's
guide](https://help.zerossl.com/hc/en-us/articles/360060119753-Invalid-CAA-Records).

This is documented for the library staff in [the end user
documentation](https://www.folkebibliotekernescms.dk/main/bliv-klar-til-folkebibliotekernes-cms/11dns/).
