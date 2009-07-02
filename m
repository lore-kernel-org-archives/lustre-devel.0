From: Josephine Palencia <josephin@psc.edu>
Date: Thu, 2 Jul 2009 13:21:34 -0400 (EDT)
Subject: [Lustre-devel] Kerb cross-site-forcing back clients to null/plain
Message-ID: <Pine.LNX.4.64.0907021313320.20445@pscuxa.psc.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


OS:      Centos 5.2 x86_64
Kernel:  2.6.18-92.1.6
Lustre:  1.9.50


Is there/can there be a mechanism by which kerb auth on the 
clients both from local & different kerb realm can be forced back to
null/plain from krb5n/a/i/p if the remote site's kerb is not
yet ready (properly configured)?

I'd rather the filesystem continues to be mounted on the client and 
indicates it did so auto-reversing back to null/plain instead of just 
hanging.

Thanks,
josephin
