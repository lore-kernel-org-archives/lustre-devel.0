From: Eric Barton <eeb@sun.com>
Date: Fri, 06 Jun 2008 01:20:55 +0100
Subject: [Lustre-devel] security: MGS connection
In-Reply-To: <48481218.9010703@sun.com>
References: <C46C26CE.574E%peter.braam@sun.com> <4846C394.1020801@sun.com>
	<023e01c8c66b$0eabce80$0281a8c0@ebpc> <4846E11A.7010604@sun.com>
	<028801c8c678$922e1d50$0281a8c0@ebpc> <48481218.9010703@sun.com>
Message-ID: <056d01c8c76b$2fb35890$0281a8c0@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

> > It's OK if the MGS will reject any connection attempt with insufficient
> > security.  In that case, you could put the security in the mount option
> > and it should probably be an error to specify different levels of security
> > when talking to the same MGS.
> 
> I guess there's misunderstanding. The problem is not on MGS, it's on 
> MGC. Each node have only one MGC, thus only one ptlrpc connection to 
> MGS, which is shared by _all_ Lustre components live on this node. So in 
> case of mounting 2 OSTs on a single node, only one security flavor could 
> be used.

Yes - I didn't make myself clear enough.  I grok there is only 1 MGC and I
suggest we report an error if the MGC has already established a connection
with insufficient security for a subsequent mount because this reveals an
inconsistency.

    Cheers,
              Eric
