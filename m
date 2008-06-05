From: Eric Mei <Eric.Mei@Sun.COM>
Date: Thu, 05 Jun 2008 10:54:54 -0600
Subject: [Lustre-devel] security: MGS connection
In-Reply-To: <028801c8c678$922e1d50$0281a8c0@ebpc>
References: <C46C26CE.574E%peter.braam@sun.com> <4846C394.1020801@sun.com>
	<023e01c8c66b$0eabce80$0281a8c0@ebpc> <4846E11A.7010604@sun.com>
	<028801c8c678$922e1d50$0281a8c0@ebpc>
Message-ID: <48481A5E.4050200@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Eric,

Here is an updated user interface proposal, please review:

- MGS can be configured to "only allow RPC with certain level of 
security from certain node". The default is 'allow any'.

- Each node choose what security flavor to use to connect MGS when 
mounting target device or client, by mount option "mgssec=flavor". By 
default 'null' (no protection) is chosen.

- For MDT/OST, the option "mgssec=flavor" could also be written on disk, 
like other parameters, but will be override if mount option supplied.

- If flavor of GSS/Kerberos is specified, some pre-configured machine 
credential will be used, so no need to supply password or whatsoever.

- The flavor of MGS connection won't change until umount, no matter how 
rest of connection flavors change at runtime.

- If there's multiple mounts on one node, they must specify the same 
security flavor. For example, if we do:
   # mount -t lustre -o mgssec=krb5p /dev/sda1 /mnt/ost1
   # mount -t lustre -o mgssec=null /dev/sda1 /mnt/ost2
then the second mount will fail immediately.

-- 
Eric
