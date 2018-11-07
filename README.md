dns
===

Ansible role to manage bind DNS zones.

Role Variables
--------------

A description of the settable variables for this role:

* Note that many of these options map directly to bind options.  Reference [bind 
documentation](https://www.isc.org/downloads/bind/doc/) for more details!

| Variable              | Required | Description                                                    |
|:----------------------|:--------:|:---------------------------------------------------------------|
| named_log_updates     | false    | Log DNS updates?  (Default: true)                              |
| named_listen_on       | true     | IPv4 addresses to listen on.  (Default: any)                   |
| named_listen_on_v6    | true     | IPv6 addresses to listen on.  (Default: any)                   |
| named_allow_recursion | true     | Addresses that can do recursive queries.  (Default: localhost) |
| named_forward_policy  | false    | The DNS forward policy.  (Default: only)                       |
| named_forwarders      | false    | Required if above is set.  (Defaults: [8.8.8.8, 8.8.4.4])      |

Several values control default values for SOA records, if they aren't specified within each record:

(None of these are required, in other words.)

| Variable              | Description                                                                  |
|:----------------------|:-----------------------------------------------------------------------------|
| named_soa_refresh     | DNS secondary check time  (Default: 3600)                                    |
| named_soa_retry       | Secondary wait on error time.  (Default: 600)                                |
| named_soa_expire      | Secondary stops answering after this time with no updates.  (Default: 86400) |
| named_soa_ttl         | Minimum TTL for all records in the file.  (Default: 3600)                    |
| named_extra_options   | List of strings with extra option lines for the 'options' statement.         |

Each DNS zone will be listed in the `named_zones` dictionary as its key.  The value is a dictionary with the 
following keys:

| Variable              | Required | Description                                                    |
|:----------------------|:--------:|:---------------------------------------------------------------|
| type                  | true     | Type of zone: `master` or `slave`.                             |

For slave zones, these keys are provided:

| Variable              | Required | Description                                                    |
|:----------------------|:--------:|:---------------------------------------------------------------|
| masters               | true     | List of servers that are masters for this zone.                |

For master zones, these keys are needed:

| Variable              | Required | Description                                                    |
|:----------------------|:--------:|:---------------------------------------------------------------|
| soa_contact           | true     | SOA record contact.                                            |
| soa_ns                | true     | SOA primary master nameserver.                                 |
| serial                | false    | Zone serial number.  (Default: current UNIX timestamp)         |
| default_ttl           | false    | Default TTL for the zone.                                      |
| extra_options         | false    | List of strings for extra zone options.                        |
| allow_transfer        | false    | List of servers that can transfer this zone.                   |
| records               | false    | List of DNS records for this zone.  (Information below.)       |
| dynamic               | false    | Please see [Dynamic Master Zones](#dynamic-master-zones) below.|

Master zone records are simple lists-of-lists that allow storing data in YAML by column:

| Name | TTL | Class | Type | Value1 | Value2          | Notes                                       |
|:----:|:---:|:-----:|:----:|:------:|:---------------:|:--------------------------------------------|
|      |     |       | NS   |        | ns1.master_zone | NS record                                   |
| ns1  |     | IN    | A    |        | 1.2.3.5         | A record for nameserver                     |
|      |     |       | MX   | 10     | mx.master_zone  | MX record for domain - only use of `Value1` |

In YAML syntax, this will appear like this:

```
...
    records:
      #   name,     TTL,    class,  type,   value,  value
      - [ '',       '',     '',     'NS',           'ns1.master_zone.' ]
      - [ 'ns1',    '',     'IN',   'A',            '1.2.3.5' ]
      - [ '',       '',     '',     'MX',   10,     'mx.master_zone.' ]
...
```

Dynamic Master Zones
--------------------

When a master zone is defined as `dynamic`, care is taken to filter out any existing dynamic entries to add them
to the new zone.

The primary use case is for using this playbook to update a server's DNS zones that DHCP also updates.

DNS Keys
--------

(Note that this documentation and methodology matches the [bind](https://github.com/buzzbombnc/bind) role.)

DNS keys are typically needed on more than one server.  As such, variables are applied in a group that ends with 
"_dnskey".

Each of these keys will be included in the `named.conf` file automatically if the server is in the 
specific `*_dnskey` group.

The format of `X_dnskey` is a dictionary with two keys:
* `algorithm`
* `secret`

Example:
```
test_dnskey:
    algorithm: hmac-sha256
    secret: "EFh57V/BI2BeR0QqEzBMfBiaGriOK0azJQHle8QkxPE="  # DON'T USE THIS.
```

*Storing this in a vault is probably the right choice.*

Generating this is beyond the scope of this document, but as a quickstart:
```
$ /usr/sbin/tsig-keygen -r /dev/urandom test
key "test" {
        algorithm hmac-sha256;
        secret "EFh57V/BI2BeR0QqEzBMfBiaGriOK0azJQHle8QkxPE=";  <-- DON'T USE THIS.
};
```

Dependencies
------------

* [bind](https://github.com/buzzbombnc/bind) role

TODO
----

* Convert records arrays to neater dictionaries?

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

MIT License

Copyright (c) 2018 Ken Treadway

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
