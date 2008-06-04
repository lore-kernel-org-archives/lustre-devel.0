From: Eric Mei <Eric.Mei@Sun.COM>
Date: Wed, 04 Jun 2008 12:38:18 -0600
Subject: [Lustre-devel] security: MGS connection
In-Reply-To: <023e01c8c66b$0eabce80$0281a8c0@ebpc>
References: <C46C26CE.574E%peter.braam@sun.com> <4846C394.1020801@sun.com>
	<023e01c8c66b$0eabce80$0281a8c0@ebpc>
Message-ID: <4846E11A.7010604@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Eric Barton wrote:
>> Here is the user interface change according to previous discussion, 
>> please review:
>>
>> - The security flavor of MGS connection is determined by each node, not 
>>   controllable by MGS.
> 
> Is this an unavoidable fact of life or a design decision?

I think it's not completely unavoidable. For example, MGC can do initial 
connect without protect, and tell MGS what kind of security mode it 
support, and MGS replay with its decision, and MGC reconnect with 
choosed flavor.

This way will be much more complicated. And more importantly, what if 
someone hijack the initial non-protected connection? Things seem not 
getting any better...

>> - By default there's no protection.
> 
> See below "XXX"
> 
>> - Given the GSS/Kerberos env is ready, mount option "mgssec=flavor" 
>> could be supplied. Pre-configured machine credential will be used, so no 
>> need to supply password or whatsoever.
>>
>> - For MDT/OST, the option "mgssec=flavor" could also be written on disk, 
>> like other parameters, but will be override if mount option supplied.
>>
>> - The flavor of MGS connection won't change until umount, no matter how 
>> rest of connection flavors change at runtime.
> 
>> - MGC->MGS connection is one per node, so only one flavor could be used. 
>> For example, suppose 2 OSTs live in a single node, we do:
>>    # mount -t lustre -o mgssec=krb5p /dev/sda1 /mnt/ost1
>>    # mount -t lustre -o mgssec=null /dev/sda1 /mnt/ost2
>> then only 'mgssec=krb5p' will take effect, the second 'mgssec=null' will 
>> be ignored.
> 
> I don't think it's acceptable to allow a previous mount to compromise
> the security of a later mount.

Indeed it looks not so good. But the fact of per-node shared MGS 
connection means only one flavor could be used. To avoid the confusion, 
to me the only way is don't allow the choice via mount option, instead 
to choose a "proper" one automatically somehow.

> XXX
> 
> This raises the interesting question of whether servers (MGS included) can
> demand a minimim level of security from clients connecting to them.  Is this
> normally part of configuring security on a given node (e.g. to set the
> machine credentials you mentioned above)?

This is the root problem I guess: we can't assume there's security 
environment ready on each nodes.

The procedure of setup gss/kerberos is not extremely easy: configure 
KDC, installing keytabs, configure gssapi, keyring, etc. And for most 
Luster clusters, strong security are not needed at all, so people most 
likely choose to skip that.

-- 
Eric
