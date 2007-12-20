From: Alex Lyashkov <Alexey.Lyashkov@Sun.COM>
Date: Thu, 20 Dec 2007 12:20:31 +0200
Subject: [Lustre-devel] read ahead
In-Reply-To: <20071214002109.GO3214@webber.adilger.int>
References: <475ED623.6090204@sun.com>
	<18270.55813.185376.299242@gargle.gargle.HOWL>
	<20071211234708.GT3214@webber.adilger.int>
	<18271.30583.338003.357861@gargle.gargle.HOWL>
	<20071214002109.GO3214@webber.adilger.int>
Message-ID: <1198146031.3528.24.camel@bear.shadowland>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, 2007-12-13 at 17:21 -0700, Andreas Dilger wrote:
> On Dec 12, 2007  08:53 +0300, Nikita Danilov wrote:
> > Andreas Dilger writes:
> >  > Two areas where our readahead is lacking are:
> >  > - strided reads (may turn the above 16 x 4kB reads into a situation
> >  >   where the client will prefetch pages instead of "random" IO, depending
> >  >   on access pattern, and will avoid prefetch of data the client is not
> >  >   expecting to use)
> >  > - limiting the readahead to the rate that the client is actually consuming
> >  >   it (currently once we detect sequential reads the readahead window grows
> >  >   eventually to the maximum even if this is far more than what the client
> >  >   needs)
> > 
> > I wonder how useful can inter-file read-ahead be. For example, starting
> > an executable almost always incurs a sequence of reads of the shared
> > libraries, compilation re-reads header files in the same order over and
> > over again, etc.
> 
> Well, we already have a beginning of this kind of operation on the client
> with client-side metadata statahead.  That detects readdir->stat operation
> and prefetches the MDS attribute data.  
I'm not sure this was good idea. stat readahead is slow for single cpu
box, and slow in testing with local devices (very low network latency) -
and can add noticeable speedup only with high latency network links,
because can send many stats requests when main thread block in waiting
one answer.

-- 
Alex Lyashkov <Alexey.lyashkov@sun.com>
Lustre Group, Sun Microsystems
