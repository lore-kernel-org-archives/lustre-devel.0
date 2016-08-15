From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 15 Aug 2016 23:04:20 +0200
Subject: [lustre-devel] [PATCH 1/2] staging: lustre: Add include path to
	Makefile
In-Reply-To: <5f9f49c1e0caeb3b9ee0656b6d922dbaf52a15b7.1471289489.git.joe@perches.com>
References: <cover.1471289489.git.joe@perches.com>
	<5f9f49c1e0caeb3b9ee0656b6d922dbaf52a15b7.1471289489.git.joe@perches.com>
Message-ID: <20160815210420.GA30864@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Mon, Aug 15, 2016 at 12:33:23PM -0700, Joe Perches wrote:
> Start to rationalize include paths in source code files.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/staging/lustre/Makefile | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/staging/lustre/Makefile b/drivers/staging/lustre/Makefile
> index 95ffe33..9d00237 100644
> --- a/drivers/staging/lustre/Makefile
> +++ b/drivers/staging/lustre/Makefile
> @@ -1,2 +1,5 @@
> +subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include/
> +subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include/
> +
>  obj-$(CONFIG_LNET)		+= lnet/
>  obj-$(CONFIG_LUSTRE_FS)		+= lustre/

This is good, but does this break the subdir make command:
	make M=drivers/staging/lustre/foo_dir/
?

I remember the last time I tried to clean this up, it took a while...

thanks,

greg k-h
