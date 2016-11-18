From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 18 Nov 2016 08:53:02 +0100
Subject: [lustre-devel] [PATCH v3] staging: lustre: llog: fix wrong
 offset in llog_process_thread()
In-Reply-To: <1479425348-21854-1-git-send-email-jsimmons@infradead.org>
References: <1479425348-21854-1-git-send-email-jsimmons@infradead.org>
Message-ID: <20161118075302.GA666@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Bob Glossman <bob.glossman@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mikhail Pershin <mike.pershin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Thu, Nov 17, 2016 at 06:29:08PM -0500, James Simmons wrote:
> From: Mikhail Pershin <mike.pershin@intel.com>
> 
> - llh_cat_idx may become bigger than llog bitmap size in
>   llog_cat_set_first_idx() function
> - it is wrong to use previous cur_offset as new buffer offset,
>   new offset should be calculated from value returned by
>   llog_next_block().
> - optimize llog_skip_over() to find llog entry offset by index
>   for llog with fixed-size records.
> 
> Signed-off-by: Mikhail Pershin <mike.pershin@intel.com>
> Signed-off-by: Bob Glossman <bob.glossman@intel.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6714
> Reviewed-on: http://review.whamcloud.com/15316
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6163
> Reviewed-on: http://review.whamcloud.com/18819
> Reviewed-by: John L. Hammond <john.hammond@intel.com>
> Reviewed-by: James Simmons <uja.ornl@yahoo.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
> 
> ChangeLog:
> 
> v1) Initial patch with umoddi issue
> v2) Included fix from patch LU-6163 that fixed umoddi problem
> v3) Remove no longer needed last_offset variable
> 
>  drivers/staging/lustre/lustre/obdclass/llog.c |   82 +++++++++++++++++-------
>  include/linux/fs.h                            |    2 +-
>  2 files changed, 59 insertions(+), 25 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
> index 3bc1789..ae63047 100644
> --- a/drivers/staging/lustre/lustre/obdclass/llog.c
> +++ b/drivers/staging/lustre/lustre/obdclass/llog.c
> @@ -217,8 +217,7 @@ static int llog_process_thread(void *arg)
>  	struct llog_log_hdr		*llh = loghandle->lgh_hdr;
>  	struct llog_process_cat_data	*cd  = lpi->lpi_catdata;
>  	char				*buf;
> -	__u64				 cur_offset;
> -	__u64				 last_offset;
> +	u64 cur_offset, tmp_offset;
>  	int chunk_size;
>  	int				 rc = 0, index = 1, last_index;
>  	int				 saved_index = 0;
> @@ -229,6 +228,8 @@ static int llog_process_thread(void *arg)
>  
>  	cur_offset = llh->llh_hdr.lrh_len;
>  	chunk_size = llh->llh_hdr.lrh_len;
> +	/* expect chunk_size to be power of two */
> +	LASSERT(is_power_of_2(chunk_size));
>  
>  	buf = libcfs_kvzalloc(chunk_size, GFP_NOFS);
>  	if (!buf) {
> @@ -245,38 +246,50 @@ static int llog_process_thread(void *arg)
>  	else
>  		last_index = LLOG_HDR_BITMAP_SIZE(llh) - 1;
>  
> -	/* Record is not in this buffer. */
> -	if (index > last_index)
> -		goto out;
> -
>  	while (rc == 0) {
> +		unsigned int buf_offset = 0;
>  		struct llog_rec_hdr *rec;
> +		bool partial_chunk;
> +		off_t chunk_offset;
>  
>  		/* skip records not set in bitmap */
>  		while (index <= last_index &&
>  		       !ext2_test_bit(index, LLOG_HDR_BITMAP(llh)))
>  			++index;
>  
> -		LASSERT(index <= last_index + 1);
> -		if (index == last_index + 1)
> +		if (index > last_index)
>  			break;
> -repeat:
> +
>  		CDEBUG(D_OTHER, "index: %d last_index %d\n",
>  		       index, last_index);
> -
> +repeat:
>  		/* get the buf with our target record; avoid old garbage */
>  		memset(buf, 0, chunk_size);
> -		last_offset = cur_offset;
>  		rc = llog_next_block(lpi->lpi_env, loghandle, &saved_index,
>  				     index, &cur_offset, buf, chunk_size);
>  		if (rc)
>  			goto out;
>  
> +		/*
> +		 * NB: after llog_next_block() call the cur_offset is the
> +		 * offset of the next block after read one.
> +		 * The absolute offset of the current chunk is calculated
> +		 * from cur_offset value and stored in chunk_offset variable.
> +		 */
> +		tmp_offset = cur_offset;
> +		if (do_div(tmp_offset, chunk_size)) {
> +			partial_chunk = true;
> +			chunk_offset = cur_offset & ~(chunk_size - 1);
> +		} else {
> +			partial_chunk = false;
> +			chunk_offset = cur_offset - chunk_size;
> +		}
> +
>  		/* NB: when rec->lrh_len is accessed it is already swabbed
>  		 * since it is used at the "end" of the loop and the rec
>  		 * swabbing is done at the beginning of the loop.
>  		 */
> -		for (rec = (struct llog_rec_hdr *)buf;
> +		for (rec = (struct llog_rec_hdr *)(buf + buf_offset);
>  		     (char *)rec < buf + chunk_size;
>  		     rec = llog_rec_hdr_next(rec)) {
>  			CDEBUG(D_OTHER, "processing rec 0x%p type %#x\n",
> @@ -288,13 +301,28 @@ static int llog_process_thread(void *arg)
>  			CDEBUG(D_OTHER, "after swabbing, type=%#x idx=%d\n",
>  			       rec->lrh_type, rec->lrh_index);
>  
> -			if (rec->lrh_index == 0) {
> -				/* probably another rec just got added? */
> -				rc = 0;
> -				if (index <= loghandle->lgh_last_idx)
> -					goto repeat;
> -				goto out; /* no more records */
> +			/*
> +			 * for partial chunk the end of it is zeroed, check
> +			 * for index 0 to distinguish it.
> +			 */
> +			if (partial_chunk && !rec->lrh_index) {
> +				/* concurrent llog_add() might add new records
> +				 * while llog_processing, check this is not
> +				 * the case and re-read the current chunk
> +				 * otherwise.
> +				 */
> +				if (index > loghandle->lgh_last_idx) {
> +					rc = 0;
> +					goto out;
> +				}
> +				CDEBUG(D_OTHER, "Re-read last llog buffer for new records, index %u, last %u\n",
> +				       index, loghandle->lgh_last_idx);
> +				/* save offset inside buffer for the re-read */
> +				buf_offset = (char *)rec - (char *)buf;
> +				cur_offset = chunk_offset;
> +				goto repeat;
>  			}
> +
>  			if (!rec->lrh_len || rec->lrh_len > chunk_size) {
>  				CWARN("invalid length %d in llog record for index %d/%d\n",
>  				      rec->lrh_len,
> @@ -309,6 +337,14 @@ static int llog_process_thread(void *arg)
>  				continue;
>  			}
>  
> +			if (rec->lrh_index != index) {
> +				CERROR("%s: Invalid record: index %u but expected %u\n",
> +				       loghandle->lgh_ctxt->loc_obd->obd_name,
> +				       rec->lrh_index, index);
> +				rc = -ERANGE;
> +				goto out;
> +			}
> +
>  			CDEBUG(D_OTHER,
>  			       "lrh_index: %d lrh_len: %d (%d remains)\n",
>  			       rec->lrh_index, rec->lrh_len,
> @@ -316,7 +352,7 @@ static int llog_process_thread(void *arg)
>  
>  			loghandle->lgh_cur_idx = rec->lrh_index;
>  			loghandle->lgh_cur_offset = (char *)rec - (char *)buf +
> -						    last_offset;
> +						    chunk_offset;
>  
>  			/* if set, process the callback on this record */
>  			if (ext2_test_bit(index, LLOG_HDR_BITMAP(llh))) {
> @@ -325,16 +361,14 @@ static int llog_process_thread(void *arg)
>  				last_called_index = index;
>  				if (rc)
>  					goto out;
> -			} else {
> -				CDEBUG(D_OTHER, "Skipped index %d\n", index);
>  			}
>  
> -			/* next record, still in buffer? */
> -			++index;
> -			if (index > last_index) {
> +			/* exit if the last index is reached */
> +			if (index >= last_index) {
>  				rc = 0;
>  				goto out;
>  			}
> +			index++;
>  		}
>  	}
>  
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index dc0478c..3f70ec3 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2690,7 +2690,7 @@ enum kernel_read_file_id {
>  
>  static inline const char *kernel_read_file_id_str(enum kernel_read_file_id id)
>  {
> -	if (id < 0 || id >= READING_MAX_ID)
> +	if (id >= READING_MAX_ID)
>  		return kernel_read_file_str[READING_UNKNOWN];
>  
>  	return kernel_read_file_str[id];

Why are you modifying this fs.h function in this patch?  Your changelog
does not talk about it at all.  Nor does lustre even call this function,
only a security module, loadpin.

totally confused,

greg k-h
