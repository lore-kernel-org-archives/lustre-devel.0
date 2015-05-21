From: Michael Shuey <shuey@purdue.edu>
Date: Thu, 21 May 2015 18:04:17 -0400
Subject: [lustre-devel] [PATCH v4 10/13] staging: lustre: lnet: lnet:
	checkpatch.pl fixes
In-Reply-To: <alpine.DEB.2.10.1505212328500.5370@hadrien>
References: <1432237849-53947-1-git-send-email-shuey@purdue.edu>
	<1432237849-53947-11-git-send-email-shuey@purdue.edu>
	<1432242004.20840.68.camel@perches.com>
	<alpine.DEB.2.10.1505212328500.5370@hadrien>
Message-ID: <CABqvwjuKypiacf3336j-q450FGKaO4wh0Ld7PF8MGz0VPsYBbw@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

That's a task (of many) I've been putting on the back burner until the code
is cleaner.  It's also a HUGE change, since there are debug macros
everywhere, and they all check a #define'd mask to see if they should fire,
and the behavior is likely governed by parts of the lustre user land tools
as well.

Suggestions are welcome.  Do other parts of the linux kernel define complex
debugging macros like these, or is this a lustre-ism?  Any suggestions on
how to handle this more in line with existing drivers?

--
Mike Shuey

On Thu, May 21, 2015 at 5:29 PM, Julia Lawall <julia.lawall@lip6.fr> wrote:
>
>
>
> On Thu, 21 May 2015, Joe Perches wrote:
>
> > On Thu, 2015-05-21 at 15:50 -0400, Mike Shuey wrote:
> > > Fix many checkpatch.pl warnings.
> > []
> > > diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c
b/drivers/staging/lustre/lnet/lnet/acceptor.c
> > []
> > > @@ -99,38 +99,42 @@ lnet_connect_console_error(int rc, lnet_nid_t
peer_nid,
> > >     switch (rc) {
> > >     /* "normal" errors */
> > >     case -ECONNREFUSED:
> > > -           CNETERR("Connection to %s at host %pI4h on port %d was
refused: check that Lustre is running on that node.\n",
> > > -                   libcfs_nid2str(peer_nid),
> > > -                   &peer_ip, peer_port);
> > > +           CNETERR(
> > > +                   "Connection to %s at host %pI4h on port %d was
refused: check that Lustre is running on that node.\n",
> > > +                   libcfs_nid2str(peer_nid), &peer_ip, peer_port);
> >
> > These are not improvements and checkpatch messages aren't dicta.
> >
> > Please don't convert code unless the conversion makes it better
> > for a human reader.
> >
> > These don't.
>
> I haven't looked into it, but perhaps there is a standard kernel printing
> function that these could be converted to directly?
>
> julia
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150521/6a2a74fc/attachment.htm>
