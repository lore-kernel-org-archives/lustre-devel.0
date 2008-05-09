From: Andreas Dilger <adilger@sun.com>
Date: Fri, 09 May 2008 17:01:15 -0600
Subject: [Lustre-devel] Wide area use of Lustre and client caches
In-Reply-To: <C449C4F5.418F%peter.braam@sun.com>
References: <1210343110.23307.203.camel@pc.ilinx>
	<C449C4F5.418F%peter.braam@sun.com>
Message-ID: <20080509230115.GO3627@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On May 09, 2008  09:08 -0600, Peter J. Braam wrote:
> Nono - striping should only be used to get more bandwidth from servers.  The
> correct solution to the problem you point out is a lock conversion, planned
> long ago, still far away maybe (Nikita?).

This task is something that Oleg has been working on occasionally,
I think there are patches around but fairly old (though not as bad
as might be expected, because LDLM code changes relatively slowly).

> On 5/9/08 8:25 AM, "Brian J. Murrell" <Brian.Murrell@Sun.COM> wrote:
> > Even still it's useful during implementation to think of the use case of
> > that remote client having read a file and caching and holding a read
> > lock on that file, say 1GB in size, and then another client wanting to
> > update say, 1KB in the middle of the file.  It would be beneficial for
> > that 1GB file to have a small (but still practical) stripe size so that
> > the amount of cache that needs to be thrown away to accommodate the
> > write is relatively small.

Having multiple stripes would save invalidation of (nstripes - 1) / nstripes
of the file, but in general the "update in the middle" paradigm is very
rare in real life, so in practise I don't think this will help much.

Even the "add a byte in the middle of a text file" case always causes
the whole file to be rewritten because of backing up the old file.

The only common applications I'm aware of that do partial-file read/write
operations are databases and peer-to-peer file sharing.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
