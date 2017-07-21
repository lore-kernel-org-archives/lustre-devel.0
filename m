From: Anna Fuchs <anna.fuchs@informatik.uni-hamburg.de>
Date: Fri, 21 Jul 2017 17:15:30 +0200
Subject: [lustre-devel] Design proposal for client-side compression
In-Reply-To: <1487254536.4777.51.camel@informatik.uni-hamburg.de>
References: <1483967258.2622.24.camel@informatik.uni-hamburg.de>
	<B5E18A82-79B3-484F-BEBE-998B8AE56397@intel.com>
	<1484223328.3937.60.camel@informatik.uni-hamburg.de>
	<B924BE6D-3C6A-4BA4-96F9-AC053F032B2D@intel.com>
	<1484749185.3965.114.camel@informatik.uni-hamburg.de>
	<1487254536.4777.51.camel@informatik.uni-hamburg.de>
Message-ID: <1500650130.3158.6.camel@informatik.uni-hamburg.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

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
