From: Josephine Palencia <josephin@psc.edu>
Date: Tue, 4 Nov 2008 11:41:45 -0500 (EST)
Subject: [Lustre-devel] Mounted successfully : Interoperability between
 Lustre 1.9.50 and 1.9.80?
Message-ID: <Pine.LNX.4.64.0811041136361.4963@pscuxa.psc.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Mounting of PSC's lustre-wan filesystem (kerberos, cross-realm) by SDSC now successful.
We used the same lustre-version. We'll refine and continue to explore other features.

Thanks,
Josephin


-----------------


Andreas Dilger adilger at sun.com
Mon Nov 3 03:32:49 PST 2008

> On Fri, 31 Oct 2008, Josephine Palencia wrote:
>
> > NB: Kerberos cross-realm authentication (testing) enabled
> >
> > Mounting of lustre-1.9.50 lustre filesystem by a client built with
> > lustre-1.9.80 produces the following error below:

Note that lustre 1.9 is an unsupported alpha branch, and there is
absolutely no guarantee nor attempt at keeping interoperability
between builds at this stage.  There is actually a considerable amount
of change to the wire protocol underway in order to make it interoperate
with the 1.8.0 release (which is also getting similar change before
release), and to be more performant in the final 2.0 release.

It is great that you are testing this release, but please always ensure
that the same version of code is being run on both the client and server
at this stage.  As we get closer to the 2.0 final release the wire
protocol changes will be finished.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
