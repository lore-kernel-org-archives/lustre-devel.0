From: Andreas Dilger <adilger@sun.com>
Date: Thu, 13 Dec 2007 17:21:09 -0700
Subject: [Lustre-devel] read ahead
In-Reply-To: <18271.30583.338003.357861@gargle.gargle.HOWL>
References: <475ED623.6090204@sun.com>
	<18270.55813.185376.299242@gargle.gargle.HOWL>
	<20071211234708.GT3214@webber.adilger.int>
	<18271.30583.338003.357861@gargle.gargle.HOWL>
Message-ID: <20071214002109.GO3214@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Dec 12, 2007  08:53 +0300, Nikita Danilov wrote:
> Andreas Dilger writes:
>  > Two areas where our readahead is lacking are:
>  > - strided reads (may turn the above 16 x 4kB reads into a situation
>  >   where the client will prefetch pages instead of "random" IO, depending
>  >   on access pattern, and will avoid prefetch of data the client is not
>  >   expecting to use)
>  > - limiting the readahead to the rate that the client is actually consuming
>  >   it (currently once we detect sequential reads the readahead window grows
>  >   eventually to the maximum even if this is far more than what the client
>  >   needs)
> 
> I wonder how useful can inter-file read-ahead be. For example, starting
> an executable almost always incurs a sequence of reads of the shared
> libraries, compilation re-reads header files in the same order over and
> over again, etc.

Well, we already have a beginning of this kind of operation on the client
with client-side metadata statahead.  That detects readdir->stat operation
and prefetches the MDS attribute data.  The next step would be OST statahead,
which could be started asynchronously as soon as the LOV EA is returned
from the MDS instead of waiting for the userspace process to get to that
entry and force the OST stat.

OST statahead will not be needed on 1.8 in many cases when size-on-MDS
is available (if file is closed) but would still be useful for 1.6 and
the case of "impatient user running 'ls -l' in the job output directory
while files are being written".

The logical extension would be to detect readdir + read (for e.g. updatedb,
find ... | xargs grep, etc) type loads and prefetch the file data if it is
not too big, or at least just the first block for "file" or similar.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
