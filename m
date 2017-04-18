From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 18 Apr 2017 09:54:05 +0000
Subject: [lustre-devel] [PATCH v2] staging: lustre: Fix sparse
 endianness warnings cast to restricted __le64 and __le32
In-Reply-To: <1492303739-32762-1-git-send-email-skanda.kashyap@gmail.com>
References: <20170414081534.GB16598@kroah.com>
	<1492303739-32762-1-git-send-email-skanda.kashyap@gmail.com>
Message-ID: <A0226106-C801-455B-A802-5E0C9DA85EEE@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Apr 15, 2017, at 18:48, skanda.kashyap at gmail.com wrote:
> 
> From: Skanda Guruanand <skanda.kashyap@gmail.com>
> 
> The struct lu_dirpage elements in lustre_idl.h file are modified to
> __le64 and __le32 types since the  elements are always converted from
> litte endian to processor native format in mdc_request.c file.
> 
> Following warnings are removed by this fix.
> 
> drivers/staging/lustre/lustre/mdc/mdc_request.c:958:42: warning: cast to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:959:42: warning: cast to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:962:42: warning: cast to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:963:42: warning: cast to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:985:50: warning: cast to restricted __le32
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1193:24: warning: cast to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1328:25: warning: cast to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1329:23: warning: cast to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1332:25: warning: cast to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1333:23: warning: cast to restricted __le64
> 
> Signed-off-by: Skanda Guruanand <skanda.kashyap@gmail.com>

Thanks for the patch.

The resend of this patch should really have been marked "[PATCH v3]", but hopefully Greg
will still notice this one.

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> drivers/staging/lustre/lustre/include/lustre/lustre_idl.h | 8 ++++----
> 1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
> index 60b827e..df48b8d 100644
> --- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
> +++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
> @@ -846,10 +846,10 @@ struct luda_type {
> #endif
> 
> struct lu_dirpage {
> -	__u64	    ldp_hash_start;
> -	__u64	    ldp_hash_end;
> -	__u32	    ldp_flags;
> -	__u32	    ldp_pad0;
> +	__le64	    ldp_hash_start;
> +	__le64	    ldp_hash_end;
> +	__le32	    ldp_flags;
> +	__le32	    ldp_pad0;
> 	struct lu_dirent ldp_entries[0];
> };
> 
> -- 
> 1.9.1
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
