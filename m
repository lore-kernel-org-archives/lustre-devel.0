From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Thu, 29 Oct 2015 08:02:15 +0900
Subject: [lustre-devel] [PATCH 10/10] staging: lustre: remove white
	space in hash.c
In-Reply-To: <1446051271-25189-11-git-send-email-jsimmons@infradead.org>
References: <1446051271-25189-1-git-send-email-jsimmons@infradead.org>
	<1446051271-25189-11-git-send-email-jsimmons@infradead.org>
Message-ID: <20151028230215.GB10118@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Oct 28, 2015 at 12:54:31PM -0400, James Simmons wrote:
> From: James Simmons <uja.ornl@yahoo.com>
> 
> Cleanup all the unneeded white space in hash.c.
> 
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lustre/libcfs/hash.c |  336 ++++++++++++++-------------
>  1 files changed, 174 insertions(+), 162 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/libcfs/hash.c b/drivers/staging/lustre/lustre/libcfs/hash.c
> index 0308744..c5921f7 100644
> --- a/drivers/staging/lustre/lustre/libcfs/hash.c
> +++ b/drivers/staging/lustre/lustre/libcfs/hash.c
> @@ -106,9 +106,9 @@
>   *   Now we support both locked iteration & lockless iteration of hash
>   *   table. Also, user can break the iteration by return 1 in callback.
>   */
> +#include <linux/seq_file.h>
>  
>  #include "../../include/linux/libcfs/libcfs.h"
> -#include <linux/seq_file.h>

Again, not a "whitespace fix".
