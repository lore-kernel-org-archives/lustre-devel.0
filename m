From: Greg KH <gregkh@linuxfoundation.org>
Date: Sun, 20 May 2018 14:44:08 +0200
Subject: [lustre-devel] [PATCH 2/5] staging: lustre: Fix block comments
 style
In-Reply-To: <20180516182707.5191-1-sabin.rapan@gmail.com>
References: <20180516182707.5191-1-sabin.rapan@gmail.com>
Message-ID: <20180520124408.GA10692@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sabin Mihai Rapan <sabin.rapan@gmail.com>
Cc: jsimmons@infradead.org, andreas.dilger@intel.com, oleg.drokin@intel.com, lustre-devel@lists.lustre.org, kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, May 16, 2018 at 08:27:07PM +0200, Sabin Mihai Rapan wrote:
> This patch fixes the checkpatch.pl warning:
> 
> WARNING:BLOCK_COMMENT_STYLE: Block comments use a trailing */ on a separate line
> 
> Signed-off-by: Sabin Mihai Rapan <sabin.rapan@gmail.com>
> ---
>  .../staging/lustre/include/uapi/linux/lustre/lustre_idl.h   | 6 ++++--
>  .../staging/lustre/include/uapi/linux/lustre/lustre_user.h  | 6 ++++--
>  2 files changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
> index e6016a71ad23..f13138972be2 100644
> --- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
> +++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
> @@ -1526,9 +1526,11 @@ struct mdt_rec_setattr {
>  #define MDS_OPEN_HAS_OBJS    020000000000 /* Just set the EA the obj exist */
>  #define MDS_OPEN_NORESTORE  0100000000000ULL /* Do not restore file at open */
>  #define MDS_OPEN_NEWSTRIPE  0200000000000ULL /* New stripe needed (restripe or
> -					      * hsm restore) */
> +					      * hsm restore)
> +					      */
>  #define MDS_OPEN_VOLATILE   0400000000000ULL /* File is volatile = created
> -						unlinked */
> +					      * unlinked 
> +					      */

Always run checkpatch.pl on your patches so you do not get grumpy
maintainers telling you to run checkpatch.pl on your patches :)

Also, do not create a patch to fix up a checkpatch warning, only to have
it add another one, unless you want to have an eternal number of changes
to make over time...

Please fix up and resend the whole series.

thanks,

greg k-h
