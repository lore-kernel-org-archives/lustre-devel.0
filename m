From: James Simmons <jsimmons@infradead.org>
Date: Mon, 26 Nov 2018 01:30:25 +0000 (GMT)
Subject: [lustre-devel] [PATCH 2/9] lustre: remove EIOCBRETRY handling
In-Reply-To: <154295732791.2850.17753016627908700130.stgit@noble>
References: <154295730810.2850.961218355189474016.stgit@noble>
 <154295732791.2850.17753016627908700130.stgit@noble>
Message-ID: <alpine.LFD.2.21.1811260130160.32255@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> From: James Simmons <uja.ornl@yahoo.com>
> 
> With linux commit 41003a7bcfed ("aio: remove retry-based AIO")
> AIO retry handling was removed due to it being buggy and no
> one using it, including lustre. Since this is the case
> remove EIOCBRETRY since it no longer in the kernel starting
> with version 3.18.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: James Simmons <uja.ornl@yahoo.com>
> Reviewed-on: http://review.whamcloud.com/14507
> WC-bug-id: https://jira.whamcloud.com/browse/LU-6426
> Reviewed-by: Bob Glossman <bob.glossman@intel.com>
> Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
> Reviewed-by: Blake Caldwell <blakec@ornl.gov>
> Reviewed-by: Thomas Stibor <thomas@stibor.net>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/lustre/include/lustre_errno.h   |    1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/lustre_errno.h b/drivers/staging/lustre/lustre/include/lustre_errno.h
> index 59fbb9f47ff1..806e79672482 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_errno.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_errno.h
> @@ -181,7 +181,6 @@
>  #define LUSTRE_EBADTYPE		527	/* Type not supported by server */
>  #define LUSTRE_EJUKEBOX		528	/* Request won't finish until timeout */
>  #define LUSTRE_EIOCBQUEUED	529	/* iocb queued await completion event */
> -#define LUSTRE_EIOCBRETRY	530	/* iocb queued, will trigger a retry */
>  
>  /*
>   * Translations are optimized away on x86.  Host errnos that shouldn't be put
> 
> 
> 
