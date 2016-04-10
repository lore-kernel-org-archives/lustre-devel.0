From: Jeff Mahoney <jeffm@suse.com>
Date: Sun, 10 Apr 2016 09:22:23 -0400
Subject: [lustre-devel] [PATCH 13/17] staging: lustre: lloop: Fix build
	failure on ppc64
In-Reply-To: <1460294020-2111-14-git-send-email-jsimmons@infradead.org>
References: <1460294020-2111-1-git-send-email-jsimmons@infradead.org>
	<1460294020-2111-14-git-send-email-jsimmons@infradead.org>
Message-ID: <63807394-FF62-4376-95FD-412309D47BF7@suse.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

This patch was shown not to work. I just haven't removed it from opensuse yet.

-Jeff

--
Jeff Mahoney
(apologies for the top post -- from my mobile)

> On Apr 10, 2016, at 9:13 AM, James Simmons <jsimmons@infradead.org> wrote:
> 
> From: Jeff Mahoney <jeffm@suse.com>
> 
> On ppc64 with 64k pages, we get a build failure in lloop:
> 
> drivers/staging/lustre/lustre/llite/lloop.c:527:2:
> note: in expansion of macro 'CLASSERT'
> CLASSERT(PAGE_CACHE_SIZE < (1 << (sizeof(unsigned short) * 8)));
> 
> There's no need to change the queue's logical block size. Even if it could
> accept a 64k value, that would result in any file system on top of it
> needing to also use 64k blocks. It'd be safe to set it to 4k, but there's
> no actual need for it. It's not used to split requests except for WRITE_SAME,
> which lloop doesn't implement anyway.
> 
> Signed-off-by: Jeff Mahoney <jeffm@suse.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4000
> Reviewed-on: http://review.whamcloud.com/7745
> Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
> Reviewed-by: Minh Diep <minh.diep@intel.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
> drivers/staging/lustre/lustre/llite/lloop.c |    3 ---
> 1 files changed, 0 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/llite/lloop.c b/drivers/staging/lustre/lustre/llite/lloop.c
> index b725fc1..f396753 100644
> --- a/drivers/staging/lustre/lustre/llite/lloop.c
> +++ b/drivers/staging/lustre/lustre/llite/lloop.c
> @@ -525,9 +525,6 @@ static int loop_set_fd(struct lloop_device *lo, struct file *unused,
>    lo->lo_queue->queuedata = lo;
> 
>    /* queue parameters */
> -    CLASSERT(PAGE_CACHE_SIZE < (1 << (sizeof(unsigned short) * 8)));
> -    blk_queue_logical_block_size(lo->lo_queue,
> -                     (unsigned short)PAGE_CACHE_SIZE);
>    blk_queue_max_hw_sectors(lo->lo_queue,
>                 LLOOP_MAX_SEGMENTS << (PAGE_CACHE_SHIFT - 9));
>    blk_queue_max_segments(lo->lo_queue, LLOOP_MAX_SEGMENTS);
> -- 
> 1.7.1
> 
> 
