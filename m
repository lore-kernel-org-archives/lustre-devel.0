From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Fri, 25 Nov 2016 23:49:16 +0000
Subject: [lustre-devel] [PATCH 09/10] staging: lustre: libcfs: remove
 zero	comparisons in headers
In-Reply-To: <1479487724-20386-10-git-send-email-jsimmons@infradead.org>
References: <1479487724-20386-1-git-send-email-jsimmons@infradead.org>
	<1479487724-20386-10-git-send-email-jsimmons@infradead.org>
Message-ID: <0DBDC329-9FB2-4749-9EC3-5B81901BA6D5@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Nov 18, 2016, at 09:48, James Simmons <jsimmons@infradead.org> wrote:
> 
> Remove the zero comparisions in the libcfs headers.
> 
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
> .../lustre/include/linux/libcfs/libcfs_crypto.h    |    2 +-
> .../lustre/include/linux/libcfs/libcfs_fail.h      |    4 +-
> .../lustre/include/linux/libcfs/libcfs_hash.h      |   32 ++++++++++----------
> 3 files changed, 19 insertions(+), 19 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
> index a0865e5..8f34c5d 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
> @@ -137,7 +137,7 @@ static inline unsigned char cfs_crypto_hash_alg(const char *algname)
> 	enum cfs_crypto_hash_alg hash_alg;
> 
> 	for (hash_alg = 0; hash_alg < CFS_HASH_ALG_MAX; hash_alg++)
> -		if (strcmp(hash_types[hash_alg].cht_name, algname) == 0)
> +		if (!strcmp(hash_types[hash_alg].cht_name, algname))

I'd really rather keep the "== 0" comparison for strcmp(), because IMHO
!strcmp() reads like "the strings do not compare the same" and is confusing.

> static inline int
> cfs_hash_is_iterating(struct cfs_hash *hs)
> {
> 	/* someone is calling cfs_hash_for_each_* */
> -	return hs->hs_iterating || hs->hs_iterators != 0;
> +	return hs->hs_iterating || hs->hs_iterators;

Likewise, I'd rather keep comparisons == 0 or != 0 for cases where the
variable is an actual number instead of just a return code or a pointer.

I don't think we need to be totally dogmatic about removing every comparison
with 0 in all of the code, as that can reduce readability in some cases.

I know this patch has already landed, and it isn't the end of the world
either way, but just wanted to forestall similar changes being made through
the rest of the code.

Cheers, Andreas
