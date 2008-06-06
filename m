From: Peter Braam <Peter.Braam@Sun.COM>
Date: Thu, 05 Jun 2008 20:30:54 -0700
Subject: [Lustre-devel] security: MGS connection
In-Reply-To: <48481A5E.4050200@sun.com>
Message-ID: <C46DFD7E.587C%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This is well formulated - make sure we get something like this on the arch
wiki and in the manual.

Peter


On 6/5/08 9:54 AM, "Eric Mei" <Eric.Mei@Sun.COM> wrote:

> Eric,
> 
> Here is an updated user interface proposal, please review:
> 
> - MGS can be configured to "only allow RPC with certain level of
> security from certain node". The default is 'allow any'.
> 
> - Each node choose what security flavor to use to connect MGS when
> mounting target device or client, by mount option "mgssec=flavor". By
> default 'null' (no protection) is chosen.
> 
> - For MDT/OST, the option "mgssec=flavor" could also be written on disk,
> like other parameters, but will be override if mount option supplied.
> 
> - If flavor of GSS/Kerberos is specified, some pre-configured machine
> credential will be used, so no need to supply password or whatsoever.
> 
> - The flavor of MGS connection won't change until umount, no matter how
> rest of connection flavors change at runtime.
> 
> - If there's multiple mounts on one node, they must specify the same
> security flavor. For example, if we do:
>    # mount -t lustre -o mgssec=krb5p /dev/sda1 /mnt/ost1
>    # mount -t lustre -o mgssec=null /dev/sda1 /mnt/ost2
> then the second mount will fail immediately.
