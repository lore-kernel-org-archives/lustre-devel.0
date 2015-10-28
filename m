From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Thu, 29 Oct 2015 08:01:54 +0900
Subject: [lustre-devel] [PATCH 08/10] staging: lustre: remove white
 space in libcfs_hash.h
In-Reply-To: <1446051271-25189-9-git-send-email-jsimmons@infradead.org>
References: <1446051271-25189-1-git-send-email-jsimmons@infradead.org>
	<1446051271-25189-9-git-send-email-jsimmons@infradead.org>
Message-ID: <20151028230154.GA10118@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Oct 28, 2015 at 12:54:29PM -0400, James Simmons wrote:
> From: James Simmons <uja.ornl@yahoo.com>
> 
> Cleanup all the unneeded white space in libcfs_hash.h.
> 
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  .../lustre/include/linux/libcfs/libcfs_hash.h      |  147 ++++++++++----------
>  1 files changed, 73 insertions(+), 74 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
> index 70b8b29..5df8ba2 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
> @@ -41,6 +41,9 @@
>  
>  #ifndef __LIBCFS_HASH_H__
>  #define __LIBCFS_HASH_H__
> +
> +#include <linux/hash.h>
> +
>  /*
>   * Knuth recommends primes in approximately golden ratio to the maximum
>   * integer representable by a machine word for multiplicative hashing.
> @@ -56,22 +59,13 @@
>  /*  2^63 + 2^61 - 2^57 + 2^54 - 2^51 - 2^18 + 1 */
>  #define CFS_GOLDEN_RATIO_PRIME_64 0x9e37fffffffc0001ULL
>  
> -/*
> - * Ideally we would use HAVE_HASH_LONG for this, but on linux we configure
> - * the linux kernel and user space at the same time, so we need to differentiate
> - * between them explicitly. If this is not needed on other architectures, then
> - * we'll need to move the functions to architecture specific headers.
> - */
> -
> -#include <linux/hash.h>
> -

That's not "cleaning up whitespace", that's "deleting unused/unneeded
stuff.

Please be more careful and only do one thing per patch, you know better
than to try to sneak other changes in.

I'll stop here in applying this series, please fix up and resend.

greg k-h
