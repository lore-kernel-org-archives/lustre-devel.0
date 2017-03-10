From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Fri, 10 Mar 2017 05:25:22 +0000
Subject: [lustre-devel] [PATCH] Minor coding guideline Fix in lusture
	module
In-Reply-To: <1489062127-23258-1-git-send-email-pushkar.iit@gmail.com>
References: <1489062127-23258-1-git-send-email-pushkar.iit@gmail.com>
Message-ID: <E7F5CE15-001C-4F6F-B7D5-AEE3650A0B9C@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pushkar Jambhlekar <pushkar.iit@gmail.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Hammond, John" <john.hammond@intel.com>, "Xiong, Jinshan" <jinshan.xiong@intel.com>, lustre-devel <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, LKML <linux-kernel@vger.kernel.org>

On Mar 9, 2017, at 05:22, Pushkar Jambhlekar <pushkar.iit@gmail.com> wrote:
> Subject: Minor coding guideline Fix in lusture module

I suspect the patchbot is unhappy with the subject line not containing anything
useful, and not containing the subsystem name. Something like:

staging/lustre/llite: replace "unsigned" with "unsigned int"

> Replacing 'unsigned' with 'unsigned int'  in vvp_pgcache_id.

Remove double space, and reference function names like vvp_pgcache_id().
 
> Checkpath.pl passed.

"checkpatch.pl"

Cheers, Andreas

> Signed-off-by: Pushkar Jambhlekar <pushkar.iit@gmail.com>
> ---
> drivers/staging/lustre/lustre/llite/vvp_dev.c | 9 ++++-----
> 1 file changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
> index 12c129f7e..8d78755 100644
> --- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
> +++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
> @@ -381,11 +381,10 @@ int cl_sb_fini(struct super_block *sb)
> #define PGC_DEPTH_SHIFT (32)
> 
> struct vvp_pgcache_id {
> -	unsigned		 vpi_bucket;
> -	unsigned		 vpi_depth;
> -	uint32_t		 vpi_index;
> -
> -	unsigned		 vpi_curdep;
> +	unsigned int		vpi_bucket;
> +	unsigned int		vpi_depth;
> +	uint32_t		vpi_index;
> +	unsigned int		vpi_curdep;
> 	struct lu_object_header *vpi_obj;
> };
> 
> -- 
> 2.7.4
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
