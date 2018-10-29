From: James Simmons <jsimmons@infradead.org>
Date: Mon, 29 Oct 2018 03:32:23 +0000 (GMT)
Subject: [lustre-devel] [PATCH] lustre: initialize libcfs_debug_file_path
In-Reply-To: <87y3al4hb9.fsf@notabene.neil.brown.name>
References: <87y3al4hb9.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1810290331490.6811@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> This variable is assumed by the code to either
> be "NONE" or a file name - it shouldn't be NULL.
> 
> So initialise to the compiled default.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> 
> I'm going though failed tests, looking for things to fix.
> This fixes 77c.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
>  drivers/staging/lustre/lnet/libcfs/debug.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
> index 90d756c83520..f9544367389d 100644
> --- a/drivers/staging/lustre/lnet/libcfs/debug.c
> +++ b/drivers/staging/lustre/lnet/libcfs/debug.c
> @@ -224,7 +224,7 @@ char libcfs_debug_file_path_arr[PATH_MAX] = LIBCFS_DEBUG_FILE_PATH_DEFAULT;
>  EXPORT_SYMBOL(libcfs_debug_file_path_arr);
>  
>  /* We need to pass a pointer here, but elsewhere this must be a const */
> -static char *libcfs_debug_file_path;
> +static char *libcfs_debug_file_path = LIBCFS_DEBUG_FILE_PATH_DEFAULT;
>  module_param(libcfs_debug_file_path, charp, 0644);
>  MODULE_PARM_DESC(libcfs_debug_file_path,
>  		 "Path for dumping debug logs, set 'NONE' to prevent log dumping");
> -- 
> 2.14.0.rc0.dirty
> 
> 
