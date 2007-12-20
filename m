From: Andreas Dilger <adilger@sun.com>
Date: Thu, 20 Dec 2007 13:44:06 -0700
Subject: [Lustre-devel] read ahead
In-Reply-To: <1198146031.3528.24.camel@bear.shadowland>
References: <475ED623.6090204@sun.com>
	<18270.55813.185376.299242@gargle.gargle.HOWL>
	<20071211234708.GT3214@webber.adilger.int>
	<18271.30583.338003.357861@gargle.gargle.HOWL>
	<20071214002109.GO3214@webber.adilger.int>
	<1198146031.3528.24.camel@bear.shadowland>
Message-ID: <20071220204406.GY3214@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Dec 20, 2007  12:20 +0200, Alex Lyashkov wrote:
> On Thu, 2007-12-13 at 17:21 -0700, Andreas Dilger wrote:
> > Well, we already have a beginning of this kind of operation on the client
> > with client-side metadata statahead.  That detects readdir->stat operation
> > and prefetches the MDS attribute data.  
>
> I'm not sure this was good idea. stat readahead is slow for single cpu
> box, and slow in testing with local devices (very low network latency) -
> and can add noticeable speedup only with high latency network links,
> because can send many stats requests when main thread block in waiting
> one answer.

This isn't the common configuration that we run in, however.  Most Lustre
setups today (and even laptops) have multiple CPUs, and clients are
generally remote instead of local.  In such testing the statahead is about
2x faster than without, and I think it could be even faster if we also had
OST statahead.

The current statahead is limited by the fact we are only hiding the
client->MDS latency (1 of 2 synchronous RPCs) and not the client->OSTs
latency (which happen concurrently for N stripes, but will be the slowest
of all OST getattrs).  So our maximum "ls -l" improvement is currently
2x until SOM (for closed files) or OST statahead is implemented.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
