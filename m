From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Thu, 13 Jul 2017 00:27:03 +0000
Subject: [lustre-devel] [PATCH v5] staging: lustre: lnet: remove dead
 code and useless wrapper
In-Reply-To: <1499468622-10276-1-git-send-email-dmitriy@oss-tech.org>
References: <1498801841-5799-1-git-send-email-dmitriy@oss-tech.org>
	<1499468622-10276-1-git-send-email-dmitriy@oss-tech.org>
Message-ID: <58312993-66C3-4B40-A8B7-A2BFC07069E8@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dmitriy Cherkasov <dmitriy@oss-tech.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Jul 7, 2017, at 16:03, Dmitriy Cherkasov <dmitriy@oss-tech.org> wrote:
> 
> After removing commented out code, ksocknal_csum() becomes a useless 
> wrapper for crc32_le(). Remove it, and instead call crc32_le() directly.
> 
> Fixes the following checkpatch warning:
> 
> WARNING: space prohibited before semicolon
> 
> Signed-off-by: Dmitriy Cherkasov <dmitriy@oss-tech.org>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>


> ---
> v5:
> 	- fix incomplete patch changelog
> 	- improve code alignment
> 	- reword commit message and summary to be more concise
> v4:
> 	- fix spacing issues
> 	- fix typo in commit message
> 	- add patch changelog
> v3:
> 	- fix spacing and alignment issues 
> 	  (suggested by Joe Perches)
> v2:
> 	- remove ksocknal_csum() and call crc32_le() directly
> 	  (suggested by Greg KH)
> 	- update commit message and summary to reflect these changes
> 
> drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h  | 11 -----------
> .../staging/lustre/lnet/klnds/socklnd/socklnd_lib.c  | 20 ++++++++++----------
> 2 files changed, 10 insertions(+), 21 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
> index 5540de6..9eb169d 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
> @@ -519,17 +519,6 @@ struct ksock_proto {
> #define CPU_MASK_NONE   0UL
> #endif
> 
> -static inline __u32 ksocknal_csum(__u32 crc, unsigned char const *p, size_t len)
> -{
> -#if 1
> -	return crc32_le(crc, p, len);
> -#else
> -	while (len-- > 0)
> -		crc = ((crc + 0x100) & ~0xff) | ((crc + *p++) & 0xff) ;
> -	return crc;
> -#endif
> -}
> -
> static inline int
> ksocknal_route_mask(void)
> {
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
> index 8a036f4..9c328dc 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
> @@ -201,9 +201,9 @@
> 			if (fragnob > sum)
> 				fragnob = sum;
> 
> -			conn->ksnc_rx_csum = ksocknal_csum(conn->ksnc_rx_csum,
> -							   iov[i].iov_base,
> -							   fragnob);
> +			conn->ksnc_rx_csum = crc32_le(conn->ksnc_rx_csum,
> +						      iov[i].iov_base,
> +						      fragnob);
> 		}
> 		conn->ksnc_msg.ksm_csum = saved_csum;
> 	}
> @@ -243,8 +243,8 @@
> 			if (fragnob > sum)
> 				fragnob = sum;
> 
> -			conn->ksnc_rx_csum = ksocknal_csum(conn->ksnc_rx_csum,
> -							   base, fragnob);
> +			conn->ksnc_rx_csum = crc32_le(conn->ksnc_rx_csum,
> +						      base, fragnob);
> 
> 			kunmap(kiov[i].bv_page);
> 		}
> @@ -265,22 +265,22 @@
> 
> 	tx->tx_msg.ksm_csum = 0;
> 
> -	csum = ksocknal_csum(~0, tx->tx_iov[0].iov_base,
> -			     tx->tx_iov[0].iov_len);
> +	csum = crc32_le(~0, tx->tx_iov[0].iov_base,
> +			tx->tx_iov[0].iov_len);
> 
> 	if (tx->tx_kiov) {
> 		for (i = 0; i < tx->tx_nkiov; i++) {
> 			base = kmap(tx->tx_kiov[i].bv_page) +
> 			       tx->tx_kiov[i].bv_offset;
> 
> -			csum = ksocknal_csum(csum, base, tx->tx_kiov[i].bv_len);
> +			csum = crc32_le(csum, base, tx->tx_kiov[i].bv_len);
> 
> 			kunmap(tx->tx_kiov[i].bv_page);
> 		}
> 	} else {
> 		for (i = 1; i < tx->tx_niov; i++)
> -			csum = ksocknal_csum(csum, tx->tx_iov[i].iov_base,
> -					     tx->tx_iov[i].iov_len);
> +			csum = crc32_le(csum, tx->tx_iov[i].iov_base,
> +					tx->tx_iov[i].iov_len);
> 	}
> 
> 	if (*ksocknal_tunables.ksnd_inject_csum_error) {
> -- 
> 1.9.1
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
