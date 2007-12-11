From: Andreas Dilger <adilger@sun.com>
Date: Tue, 11 Dec 2007 16:47:08 -0700
Subject: [Lustre-devel] read ahead
In-Reply-To: <18270.55813.185376.299242@gargle.gargle.HOWL>
References: <475ED623.6090204@sun.com>
	<18270.55813.185376.299242@gargle.gargle.HOWL>
Message-ID: <20071211234708.GT3214@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Dec 11, 2007  21:42 +0300, Nikita Danilov wrote:
> Peter Braam writes:
>  > Can anyone tell me if read ahead in Lustre includes "early return" 
>  > features.  I mean that if I read 4K and readahead decides to fetch 1M 
>  > will my request get serviced when the first 4K arrives?  Is this important?
> 
> Currently read system call will proceed when the first RPC (including
> first 4K page and some number of read-ahead pages) is serviced:
> generic_file_read() waits on a page lock, and lock is released by
> completion routine (ll_ap_completion()).

Another thing worth mentioning here is that if this is the FIRST 4kB read
from the file, then only that 4kB will be returned in the RPC, because
readahead hasn't done linear vs. random IO detection yet.  If it is the
second read (and linear) then the client will get the _rest_ of the 1MB
and will have to wait for that second RPC to complete.  For subsequent
reads the readahead will of course prefetch the pages.

For random reads the code does understand the difference between e.g.
reads of 16 sequential pages (64kB generally) read at non-consecutive
offsets and 16 sequential 4kB page reads.  The former will NOT start
readahead, while the latter does.

Two areas where our readahead is lacking are:
- strided reads (may turn the above 16 x 4kB reads into a situation
  where the client will prefetch pages instead of "random" IO, depending
  on access pattern, and will avoid prefetch of data the client is not
  expecting to use)
- limiting the readahead to the rate that the client is actually consuming
  it (currently once we detect sequential reads the readahead window grows
  eventually to the maximum even if this is far more than what the client
  needs)

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
