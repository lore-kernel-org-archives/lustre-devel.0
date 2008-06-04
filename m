From: Eric Barton <eeb@sun.com>
Date: Wed, 04 Jun 2008 18:47:28 +0100
Subject: [Lustre-devel] security: MGS connection
In-Reply-To: <4846C394.1020801@sun.com>
References: <C46C26CE.574E%peter.braam@sun.com> <4846C394.1020801@sun.com>
Message-ID: <023e01c8c66b$0eabce80$0281a8c0@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Eric,

> Here is the user interface change according to previous discussion, 
> please review:
> 
> - The security flavor of MGS connection is determined by each node, not 
>   controllable by MGS.

Is this an unavoidable fact of life or a design decision?  See below "XXX"

> - By default there's no protection.

See below "XXX"

> 
> - Given the GSS/Kerberos env is ready, mount option "mgssec=flavor" 
> could be supplied. Pre-configured machine credential will be used, so no 
> need to supply password or whatsoever.
> 
> - For MDT/OST, the option "mgssec=flavor" could also be written on disk, 
> like other parameters, but will be override if mount option supplied.
> 
> - The flavor of MGS connection won't change until umount, no matter how 
> rest of connection flavors change at runtime.

> - MGC->MGS connection is one per node, so only one flavor could be used. 
> For example, suppose 2 OSTs live in a single node, we do:
>    # mount -t lustre -o mgssec=krb5p /dev/sda1 /mnt/ost1
>    # mount -t lustre -o mgssec=null /dev/sda1 /mnt/ost2
> then only 'mgssec=krb5p' will take effect, the second 'mgssec=null' will 
> be ignored.

I don't think it's acceptable to allow a previous mount to compromise
the security of a later mount.

XXX

This raises the interesting question of whether servers (MGS included) can
demand a minimim level of security from clients connecting to them.  Is this
normally part of configuring security on a given node (e.g. to set the
machine credentials you mentioned above)?

> Are these (especially the last one) reasonable? Thanks.
> 
> -- 
> Eric
> 
