From: James Simmons <jsimmons@infradead.org>
Date: Tue, 1 Oct 2019 18:51:27 +0100 (BST)
Subject: [lustre-devel] [PATCH 021/151] lustre: llog: consolidate common
 error checking
In-Reply-To: <87tv8t6yor.fsf@notabene.neil.brown.name>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
 <1569869810-23848-22-git-send-email-jsimmons@infradead.org>
 <87tv8t6yor.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1910011850110.9239@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> > From: Andreas Dilger <adilger@whamcloud.com>
> >
> > Consolidate error checking for corrupted and empty llog files
> > detected when the llog file is being opened into a single
> > routine llog_cat_process_common().
> >
> > WC-bug-id: https://jira.whamcloud.com/browse/LU-9153
> > Lustre-commit: b522f7b4b1de ("LU-9153 llog: consolidate common error checking")
> > Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
> > Reviewed-on: https://review.whamcloud.com/26211
> > Reviewed-by: Faccini Bruno <bruno.faccini@intel.com>
> > Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
> > Reviewed-by: Oleg Drokin <green@whamcloud.com>
> > Signed-off-by: James Simmons <jsimmons@infradead.org>
> > ---
> >  fs/lustre/obdclass/llog_cat.c | 48 ++++++++++++++++++++++++++++++++-----------
> >  1 file changed, 36 insertions(+), 12 deletions(-)
> >
> > diff --git a/fs/lustre/obdclass/llog_cat.c b/fs/lustre/obdclass/llog_cat.c
> > index b61c858..4536f54 100644
> > --- a/fs/lustre/obdclass/llog_cat.c
> > +++ b/fs/lustre/obdclass/llog_cat.c
> > @@ -140,32 +140,55 @@ int llog_cat_close(const struct lu_env *env, struct llog_handle *cathandle)
> >  }
> >  EXPORT_SYMBOL(llog_cat_close);
> >  
> > -static int llog_cat_process_cb(const struct lu_env *env,
> > -			       struct llog_handle *cat_llh,
> > -			       struct llog_rec_hdr *rec, void *data)
> > +static int llog_cat_process_common(const struct lu_env *env,
> > +				   struct llog_handle *cat_llh,
> > +				   struct llog_rec_hdr *rec,
> > +				   struct llog_handle **llhp)
> >  {
> > -	struct llog_process_data *d = data;
> > -	struct llog_logid_rec *lir = (struct llog_logid_rec *)rec;
> > -	struct llog_handle *llh;
> > +	struct llog_logid_rec *lir = container_of(rec, typeof(*lir), lid_hdr);
> >  	int rc;
> >  
> > -	if (rec->lrh_type != LLOG_LOGID_MAGIC) {
> > +	if (rec->lrh_type != le32_to_cpu(LLOG_LOGID_MAGIC)) {
> > +		rc = -EINVAL;
> > +		CWARN("%s: invalid record in catalog " DFID ":%x: rc = %d\n",
> > +		      cat_llh->lgh_ctxt->loc_obd->obd_name,
> > +		      PFID(&cat_llh->lgh_id.lgl_oi.oi_fid),
> > +		      cat_llh->lgh_id.lgl_ogen, rc);
> > +
> >  		CERROR("invalid record in catalog\n");
> 
> You've got an extra 'invalid record in catalog' here.
> The original deleted this.
> 
> 
> >  		return -EINVAL;
> 
> And this is "RETURN(rc);" in the original..

Thanks for finding that.

Acked-by: James Simmons <jsimmons@infradead.org>
 
> Thanks,
> NeilBrown
> 
> 
> >  	}
> >  	CDEBUG(D_HA,
> >  	       "processing log " DFID ":%x at index %u of catalog " DFID "\n",
> >  	       PFID(&lir->lid_id.lgl_oi.oi_fid), lir->lid_id.lgl_ogen,
> > -	       rec->lrh_index, PFID(&cat_llh->lgh_id.lgl_oi.oi_fid));
> > +	       le32_to_cpu(rec->lrh_index),
> > +	       PFID(&cat_llh->lgh_id.lgl_oi.oi_fid));
> >  
> > -	rc = llog_cat_id2handle(env, cat_llh, &llh, &lir->lid_id);
> > +	rc = llog_cat_id2handle(env, cat_llh, llhp, &lir->lid_id);
> >  	if (rc) {
> > -		CERROR("%s: cannot find handle for llog " DFID ": %d\n",
> > -		       cat_llh->lgh_ctxt->loc_obd->obd_name,
> > -		       PFID(&lir->lid_id.lgl_oi.oi_fid), rc);
> > +		CWARN("%s: can't find llog handle " DFID ":%x: rc = %d\n",
> > +		      cat_llh->lgh_ctxt->loc_obd->obd_name,
> > +		      PFID(&lir->lid_id.lgl_oi.oi_fid),
> > +		      lir->lid_id.lgl_ogen, rc);
> > +
> >  		return rc;
> >  	}
> >  
> > +	return rc;
> > +}
> > +
> > +static int llog_cat_process_cb(const struct lu_env *env,
> > +			       struct llog_handle *cat_llh,
> > +			       struct llog_rec_hdr *rec, void *data)
> > +{
> > +	struct llog_process_data *d = data;
> > +	struct llog_handle *llh = NULL;
> > +	int rc;
> > +
> > +	rc = llog_cat_process_common(env, cat_llh, rec, &llh);
> > +	if (rc)
> > +		goto out;
> > +
> >  	if (rec->lrh_index < d->lpd_startcat)
> >  		/* Skip processing of the logs until startcat */
> >  		rc = 0;
> > @@ -183,6 +206,7 @@ static int llog_cat_process_cb(const struct lu_env *env,
> >  					  NULL, false);
> >  	}
> >  
> > +out:
> >  	llog_handle_put(llh);
> >  
> >  	return rc;
> > -- 
> > 1.8.3.1
> 
