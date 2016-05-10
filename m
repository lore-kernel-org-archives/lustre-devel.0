From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 10 May 2016 16:20:16 +0300
Subject: [lustre-devel] [PATCH 5/9] staging: lustre: fid: packing
	ost_idx in IDIF
In-Reply-To: <1462372140-27880-6-git-send-email-jsimmons@infradead.org>
References: <1462372140-27880-1-git-send-email-jsimmons@infradead.org>
	<1462372140-27880-6-git-send-email-jsimmons@infradead.org>
Message-ID: <20160510132016.GC4298@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Fan Yong <fan.yong@intel.com>, wang di <di.wang@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, May 04, 2016 at 10:28:56AM -0400, James Simmons wrote:
> From: Fan Yong <fan.yong@intel.com>
> 
> For a normal FID, we can know on which target the related object
> is allocated via querying FLDB; but it is not true for an IDIF.
> 
> To locate the OST via the given IDIF, when the IDIF is generated,
> we pack the OST index in it. Then for any given FID, in spite of
> t is a normal FID or not, we has the method to know which target

Missing words.  "in spite of *whether it* is a normal FID or not."

> it belongs to. That is useful for LFSCK.
> 
> For old IDIF, the OST index is not part of the IDIF, means that
> ifferent OSTs may have the same IDIFs, that may cause the IFID

different.

> in LMA does not match the read FID.

s/does/to/

> Under such case, we need to
> make some compatible check to avoid to trigger unexpected.
> 
> tgt_validate_obdo() converts the ostid contained in the RPC body
> to fid and changes the "struct ost_id" union, then the users can
> access ost_id::oi_fid directly without call ostid_to_fid() again.

calling.

> 
> It also contains some other fixing and cleanup.

These are trigger words to avoid.

> 
> Signed-off-by: wang di <di.wang@intel.com>
> Signed-off-by: Fan Yong <fan.yong@intel.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3569
> Reviewed-on: http://review.whamcloud.com/7053
> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  .../lustre/lustre/include/lustre/lustre_idl.h      | 76 +++++++++++++++-------
>  drivers/staging/lustre/lustre/include/lustre_fid.h | 22 ++-----
>  2 files changed, 57 insertions(+), 41 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
> index a70545a..9c53c17 100644
> --- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
> +++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
> @@ -584,7 +584,7 @@ static inline __u64 ostid_seq(const struct ost_id *ostid)
>  	if (fid_seq_is_mdt0(ostid->oi.oi_seq))
>  		return FID_SEQ_OST_MDT0;
>  
> -	if (fid_seq_is_default(ostid->oi.oi_seq))
> +	if (unlikely(fid_seq_is_default(ostid->oi.oi_seq)))

Adding unlikely() is the opposite of a cleanup.  It's now messier.  That
sort of thing needs to be justified by benchmarks.  Please remove all
the new likely/unlikelys and add them in a separate patch later.


>  		return FID_SEQ_LOV_DEFAULT;
>  
>  	if (fid_is_idif(&ostid->oi_fid))
> @@ -596,9 +596,12 @@ static inline __u64 ostid_seq(const struct ost_id *ostid)
>  /* extract OST objid from a wire ost_id (id/seq) pair */
>  static inline __u64 ostid_id(const struct ost_id *ostid)
>  {
> -	if (fid_seq_is_mdt0(ostid_seq(ostid)))
> +	if (fid_seq_is_mdt0(ostid->oi.oi_seq))
>  		return ostid->oi.oi_id & IDIF_OID_MASK;
>  
> +	if (unlikely(fid_seq_is_default(ostid->oi.oi_seq)))
> +		return ostid->oi.oi_id;
> +
>  	if (fid_is_idif(&ostid->oi_fid))
>  		return fid_idif_id(fid_seq(&ostid->oi_fid),
>  				   fid_oid(&ostid->oi_fid), 0);
> @@ -642,12 +645,22 @@ static inline void ostid_set_seq_llog(struct ost_id *oi)
>   */
>  static inline void ostid_set_id(struct ost_id *oi, __u64 oid)
>  {
> -	if (fid_seq_is_mdt0(ostid_seq(oi))) {
> +	if (fid_seq_is_mdt0(oi->oi.oi_seq)) {
>  		if (oid >= IDIF_MAX_OID) {
>  			CERROR("Bad %llu to set " DOSTID "\n", oid, POSTID(oi));
>  			return;
>  		}
>  		oi->oi.oi_id = oid;
> +	} else if (fid_is_idif(&oi->oi_fid)) {
> +		if (oid >= IDIF_MAX_OID) {
> +			CERROR("Bad %llu to set "DOSTID"\n",
> +			       oid, POSTID(oi));
> +			return;
> +		}
> +		oi->oi_fid.f_seq = fid_idif_seq(oid,
> +						fid_idif_ost_idx(&oi->oi_fid));
> +		oi->oi_fid.f_oid = oid;
> +		oi->oi_fid.f_ver = oid >> 48;
>  	} else {
>  		if (oid > OBIF_MAX_OID) {
>  			CERROR("Bad %llu to set " DOSTID "\n", oid, POSTID(oi));
> @@ -657,25 +670,31 @@ static inline void ostid_set_id(struct ost_id *oi, __u64 oid)
>  	}
>  }
>  
> -static inline void ostid_inc_id(struct ost_id *oi)
> +static inline int fid_set_id(struct lu_fid *fid, __u64 oid)
>  {
> -	if (fid_seq_is_mdt0(ostid_seq(oi))) {
> -		if (unlikely(ostid_id(oi) + 1 > IDIF_MAX_OID)) {
> -			CERROR("Bad inc "DOSTID"\n", POSTID(oi));
> -			return;
> +	if (unlikely(fid_seq_is_igif(fid->f_seq))) {
> +		CERROR("bad IGIF, "DFID"\n", PFID(fid));
> +		return -EBADF;
> +	}
> +
> +	if (fid_is_idif(fid)) {
> +		if (oid >= IDIF_MAX_OID) {
> +			CERROR("Too large OID %#llx to set IDIF "DFID"\n",
> +			       (unsigned long long)oid, PFID(fid));
> +			return -EBADF;
>  		}
> -		oi->oi.oi_id++;
> +		fid->f_seq = fid_idif_seq(oid, fid_idif_ost_idx(fid));
> +		fid->f_oid = oid;
> +		fid->f_ver = oid >> 48;
>  	} else {
> -		oi->oi_fid.f_oid++;
> +		if (oid > OBIF_MAX_OID) {

Is this off by one?  Hopely it is.  Otherwise, it's really confusing.


> +			CERROR("Too large OID %#llx to set REG "DFID"\n",
> +			       (unsigned long long)oid, PFID(fid));
> +			return -EBADF;
> +		}
> +		fid->f_oid = oid;
>  	}

regards,
dan carpenter
