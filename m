From: Andreas Dilger <adilger@sun.com>
Date: Fri, 22 Aug 2008 11:18:05 -0600
Subject: [Lustre-devel] Readx issue
In-Reply-To: <C4D3A486.57CB%peter.braam@sun.com>
References: <48AE46F0.9060105@sun.com> <C4D3A486.57CB%peter.braam@sun.com>
Message-ID: <20080822171805.GZ3392@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 8/21/08 10:56 PM, "Tom.Wang" <Tom.Wang@Sun.COM> wrote:
> Since the target here is to issue the vector read extents req parallel,
> so I chosed to implement that by read-ahead
> group io, which is async and parallel. And also by this way, it will not
> touch other module of lustre.
> 
> In vector read-ahead, each read request will control their read-ahead by
> itself, instead of by the current read-ahead window, where multi
> read-threads(for the same file) use single read ahead window.
> 
> Because current read-ahead
>   1)Use a single continuous RA window to control the read ahead.
>   2)The read-ahead moves forward according to the global RA window(for
> all the read threads of this file), so it tries to favour all the read
> threads of the file,

Tom,
the current readahead mechanism is done on a per-file-descriptor basis.
Are the threads in question here actually sharing the same file descriptor
(i.e. file was opened once, then threads forked and descriptor is copied),
or is each thread opening the file itself?  In the latter case we _should_
have a separate readahead window for each thread already...

> This algorithm is not very nice for vector read-ahead. because
>  1) It is hard to manage the multi discontinuous read-ahead window, for
> example add/remove the extents from the window will be very subtle.
>  2) It is hard to favour all the vector read-threads(for the file) by 1
> single read-ahead window.
> 
> So I let each vector read threads control their read-ahead themselves,
> which will make implementation very easy, and it will also not touch
> original read-ahead algorithm for non-vector read.  If you disagree
> about this, please tell me.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
