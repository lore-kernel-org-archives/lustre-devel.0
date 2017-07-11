From: Greg KH <gregkh@linuxfoundation.org>
Date: Tue, 11 Jul 2017 19:08:18 +0200
Subject: [lustre-devel] [PATCH 8/8] Staging: lustre :lustre: include
 :lustre_compat.h: Prefer using the BIT macro
In-Reply-To: <1499325195-17466-1-git-send-email-rjdurga@gmail.com>
References: <1499325195-17466-1-git-send-email-rjdurga@gmail.com>
Message-ID: <20170711170818.GA5013@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jaya Durga <rjdurga@gmail.com>
Cc: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, john.hammond@intel.com, bobijam@hotmail.com, mingo@kernel.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Thu, Jul 06, 2017 at 12:43:15PM +0530, Jaya Durga wrote:
> Replace all instances of (1 << 27) with BIT(27) to fix
> checkpatch check messages
> 
> Signed-off-by: Jaya Durga <rjdurga@gmail.com>
> ---
>  drivers/staging/lustre/lustre/include/lustre_compat.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/lustre_compat.h b/drivers/staging/lustre/lustre/include/lustre_compat.h
> index da9ce19..686a251 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_compat.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_compat.h
> @@ -43,7 +43,7 @@
>   * set ATTR_BLOCKS to a high value to avoid any risk of collision with other
>   * ATTR_* attributes (see bug 13828)
>   */
> -#define ATTR_BLOCKS    (1 << 27)
> +#define ATTR_BLOCKS    BIT(27)

Isn't this used in lustre's userspace code?  If so, you can't use the
BIT() macro there :(

Please check before you redo this.

thanks,

greg k-h
