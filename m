From: Andreas Dilger <adilger@sun.com>
Date: Mon, 03 Nov 2008 04:32:49 -0700
Subject: [Lustre-devel] Interoperability between Lustre 1.9.50
	and	1.9.80?
In-Reply-To: <Pine.LNX.4.64.0810310055380.5445@pscuxa.psc.edu>
References: <Pine.LNX.4.64.0810310042430.4907@pscuxa.psc.edu>
	<Pine.LNX.4.64.0810310055380.5445@pscuxa.psc.edu>
Message-ID: <20081103113249.GC3184@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Oct 31, 2008  00:56 -0400, Josephine Palencia wrote:
> Correction.
> 
> ..client build with lustre-1.9.80..
> 
> On Fri, 31 Oct 2008, Josephine Palencia wrote:
> 
> > NB: Kerberos cross-realm authentication (testing) enabled
> >
> > Mounting of lustre-1.9.50 lustre filesystem by a client built with 
> > lustre-1.9.5 produces the following error below:

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
