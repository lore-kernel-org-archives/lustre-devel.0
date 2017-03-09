From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Thu, 9 Mar 2017 14:15:35 +0100
Subject: [lustre-devel] [PATCH] Minor coding guideline Fix in lusture
	module
In-Reply-To: <1489062127-23258-1-git-send-email-pushkar.iit@gmail.com>
References: <1489062127-23258-1-git-send-email-pushkar.iit@gmail.com>
Message-ID: <20170309131535.GB2908@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pushkar Jambhlekar <pushkar.iit@gmail.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, "John L. Hammond" <john.hammond@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, Fan Yong <fan.yong@intel.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Thu, Mar 09, 2017 at 05:52:07PM +0530, Pushkar Jambhlekar wrote:
> Replacing 'unsigned' with 'unsigned int'  in vvp_pgcache_id.
> Checkpath.pl passed.
> 
> Signed-off-by: Pushkar Jambhlekar <pushkar.iit@gmail.com>
> ---
>  drivers/staging/lustre/lustre/llite/vvp_dev.c | 9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
> index 12c129f7e..8d78755 100644
> --- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
> +++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
> @@ -381,11 +381,10 @@ int cl_sb_fini(struct super_block *sb)
>  #define PGC_DEPTH_SHIFT (32)
>  
>  struct vvp_pgcache_id {
> -	unsigned		 vpi_bucket;
> -	unsigned		 vpi_depth;
> -	uint32_t		 vpi_index;
> -
> -	unsigned		 vpi_curdep;
> +	unsigned int		vpi_bucket;
> +	unsigned int		vpi_depth;
> +	uint32_t		vpi_index;
> +	unsigned int		vpi_curdep;
>  	struct lu_object_header *vpi_obj;
>  };
>  
> -- 
> 2.7.4

Hi,

This is the friendly patch-bot of Greg Kroah-Hartman.  You have sent him
a patch that has triggered this response.  He used to manually respond
to these common problems, but in order to save his sanity (he kept
writing the same thing over and over, yet to different people), I was
created.  Hopefully you will not take offence and will fix the problem
in your patch and resubmit it so that it can be accepted into the Linux
kernel tree.

You are receiving this message because of the following common error(s)
as indicated below:

- You did not specify a description of why the patch is needed, or
  possibly, any description at all, in the email body.  Please read the
  section entitled "The canonical patch format" in the kernel file,
  Documentation/SubmittingPatches for what is needed in order to
  properly describe the change.

- You did not write a descriptive Subject: for the patch, allowing Greg,
  and everyone else, to know what this patch is all about.  Please read
  the section entitled "The canonical patch format" in the kernel file,
  Documentation/SubmittingPatches for what a proper Subject: line should
  look like.

If you wish to discuss this problem further, or you have questions about
how to resolve this issue, please feel free to respond to this email and
Greg will reply once he has dug out from the pending patches received
from other developers.

thanks,

greg k-h's patch email bot
