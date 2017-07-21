From: Patrick Farrell <paf@cray.com>
Date: Fri, 21 Jul 2017 16:43:51 +0000
Subject: [lustre-devel] Design proposal for client-side compression
In-Reply-To: <1500650130.3158.6.camel@informatik.uni-hamburg.de>
References: <1483967258.2622.24.camel@informatik.uni-hamburg.de>
	<B5E18A82-79B3-484F-BEBE-998B8AE56397@intel.com>
	<1484223328.3937.60.camel@informatik.uni-hamburg.de>
	<B924BE6D-3C6A-4BA4-96F9-AC053F032B2D@intel.com>
	<1484749185.3965.114.camel@informatik.uni-hamburg.de>
	<1487254536.4777.51.camel@informatik.uni-hamburg.de>,
	<1500650130.3158.6.camel@informatik.uni-hamburg.de>
Message-ID: <BN6PR1101MB2132311AB19B104AD044797ACBA40@BN6PR1101MB2132.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I think basing this on the maximum number of stripes it too simple, and maybe not necessary.

Apologies in advance if what I say below rests on a misunderstanding of the compression design, I should know it better than I do.


But, here goes.

About based on maximum stripe count, there are a number of 1000 OST systems in the world today.  Imagine one of them with 16 MiB stripes, that's ~16 GiB of memory for this.  I think that's clearly too large.  But a global (rather than per OSC) pool could be tricky too, leading to contention on getting and returning pages.

You mention later a 50 MiB pool per client.  As a per OST pre-allocated pool, that would likely be too large.  As a global pool, it seems small...


But why use a global pool?  It sounds like the compression would be handled by the thread putting the data on the wire (Sorry if I've got that wrong).  So - What about a per-thread block of pages, for each ptlrpcd thread?  If the idea is that this compressed data is not retained for replay (instead, you would re-compress), then we only need a block of max rpc size for each thread (You could just use the largest RPC size supported by the client), so it can send that compressed data.

The overhead of compression for replay is probably not something we need to worry about.


Or even per-CPU blocks of pages.  That would probably be better still (less total memory if there are more ptlrpcds than CPUs), if we can guarantee not sleeping during the time the pool is in use.  (I'm not sure.)

Also, you mention limiting the # of threads.  Why is limiting the number of threads doing compression of interest?  What are you specifically trying to avoid with that?

________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of Anna Fuchs <anna.fuchs@informatik.uni-hamburg.de>
Sent: Friday, July 21, 2017 10:15:30 AM
To: Xiong, Jinshan
Cc: Matthew Ahrens; Zhuravlev, Alexey; lustre-devel
Subject: Re: [lustre-devel] Design proposal for client-side compression

Dear all,

for compression within the osc module we need a bunch of pages for the
compressed output (at most the same size like original data), and few
pages for working memory of the algorithms. Since allocating (and later
freeing) the pages every time we enter the compression loop might be
expensive and annoying, we thought about a pool of pages, which is
present exclusively for compression purposes.

We would create that pool at file system start (when loading the osc
module) and destroy at file system stop (when unloading the osc
module). The condition is, of course, the configure option --enable-
compression. The pool would be a queue of page bunches where a thread
can pop pages for compression and put them back after the compressed
portion was transferred. The page content will not be visible to anyone
outside and will also not be cached after the transmission.

We would like to make the pool static since we think, we do not need a
lot of memory. However it depends on the number of stripes or MBs, that
one client can handle at the same time. E.g. for 32 stripes of 1MB
processed at the same time, we need at most 32 MB + few MB for
overhead. Where can I find the exact number or how can I estimate how
many stripes there are at most at the same time? Another limitation is
the number of threads, which can work in parallel on compression at the
same time. We think to exclusively reserve not more than 50 MB for the
compression page pool per client. Do you think it might hurt the
performance?

Once there are not enough pages, for whatever reason, we wouldn't wait,
but just skip the compression for the respective chunk.

Are there any problems you see in that approach?

Regards,
Anna

--
Anna Fuchs
https://wr.informatik.uni-hamburg.de/people/anna_fuchs
_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20170721/4099f4fc/attachment.htm>
