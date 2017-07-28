From: Anna Fuchs <anna.fuchs@informatik.uni-hamburg.de>
Date: Fri, 28 Jul 2017 11:57:27 +0200
Subject: [lustre-devel] Design proposal for client-side compression
In-Reply-To: <BN6PR1101MB2132BBFB8979EA3FBFA4AE2DCBBE0@BN6PR1101MB2132.namprd11.prod.outlook.com>
References: <1483967258.2622.24.camel@informatik.uni-hamburg.de>
	<B5E18A82-79B3-484F-BEBE-998B8AE56397@intel.com>
	<1484223328.3937.60.camel@informatik.uni-hamburg.de>
	<B924BE6D-3C6A-4BA4-96F9-AC053F032B2D@intel.com>
	<1484749185.3965.114.camel@informatik.uni-hamburg.de>
	<1487254536.4777.51.camel@informatik.uni-hamburg.de>
	,<1500650130.3158.6.camel@informatik.uni-hamburg.de>
	<BN6PR1101MB2132311AB19B104AD044797ACBA40@BN6PR1101MB2132.namprd11.prod.outlook.com>
	,<1500992740.4728.5.camel@informatik.uni-hamburg.de>
	<BN6PR1101MB2132DD0CCFF2F83BB3BE7F54CBB90@BN6PR1101MB2132.namprd11.prod.outlook.com>
	,<1501143960.3412.3.camel@informatik.uni-hamburg.de>
	<BN6PR1101MB2132BBFB8979EA3FBFA4AE2DCBBE0@BN6PR1101MB2132.namprd11.prod.outlook.com>
Message-ID: <1501235847.3412.12.camel@informatik.uni-hamburg.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Patrick,

On Thu, 2017-07-27 at 19:22 +0000, Patrick Farrell wrote:
> Ann,
> 
> I would be happy to help with review, etc, on this once it's ready to
> be posted.

thanks for that! 

> In the meantime, I am curious about how you handled the compression
> and the discontiguous set of pages problem.  Did you use scatter-
> gather lists like the encryption code does, or some other solution?

I am mainly working on the infrastructure and Lustre/ZFS integration
regardless the concrete algorithm, but we faced this problem very
early. In my prototype I still have the very costly approach of
allocating three contiguous buffers (src, dst, wrkmem), allocating
additional destination pages, copying original pages to void* src
buffer, compressing to void* dst buffer and again copying to dst page
buffer. A lot of expensive copies and memory wasting. But with the
original Kernel-LZ4 there is no other way. I can send you the
corresponding code part, but it is totally boring - alloc, alloc,
alloc... copy, copy, ... copy.

In parallel to my work site, we assigned a student to adopt LZ4 to the
page structure. Our first idea has also been scatter-lists seen in the
encryption code. Since scatter-lists use linked lists it somehow turned
out to be very inefficient for traversing the data. The corresponding
Bachelor's thesis will be submitted soon (within a month?), so we have
to proofread it in detail. However, the student implemented another
version of LZ4, which works directly on pages (code party online, full
version will follow).
It is tested, but might be not in the productive stage now (will
hopefully be after submission and reviewing). This version shows a
little lower compression ratio but comparable or better speed. We will
see how we can use it to avoid the memory and copy overhead. It seemed 
there is no good way how to change only the data structure in a clean
way without changing the de-/compressor's logic. 

Another interesting thing is the newest LZ4m [0], which is similar to
the work of our student in many aspects, but still differs (waiting for
final thesis). 

However, for the LZ4 we see good chances to get rid of that overhead by
using which ever modification. But since we want and should support
more algorithms, we still do not have any universal solution. E.g. for
zstd, which also seems to be suitable for our needs (another thesis..),
we would need to make same efforts again or pay the overhead. 

[0] http://csl.skku.edu/papers/icce17.pdf

If anyone has other ideas, please, let me know!

Regards,
Anna
