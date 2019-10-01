From: James Simmons <jsimmons@infradead.org>
Date: Tue, 1 Oct 2019 19:03:45 +0100 (BST)
Subject: [lustre-devel] [PATCH 043/151] lustre: lov: add MDT target to
 the LOV device
In-Reply-To: <87wodp718v.fsf@notabene.neil.brown.name>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
 <1569869810-23848-44-git-send-email-jsimmons@infradead.org>
 <87wodp718v.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1910011902200.15141@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> > From: Mikhal Pershin <mpershin@whamcloud.com>
> >
> > MDC becomes LOV target like OSC for Data-on-MDT needs.
> > Patch does the following:
> > - new composite layout entry type is added - LLT_DOM to
> > describe Data-on-MDT striping.
> > - LOV process config log and checks for MDC targets organizing
> > them separately from OSCs
> > - LOV operations are changed where needed to understand new layout
> > entry type
> >
> > WC-bug-id: https://jira.whamcloud.com/browse/LU-3285
> > Lustre-commit: 8b352709a66f ("LU-3285 lov: add MDT target to the LOV device")
> > Signed-off-by: Mikhal Pershin <mpershin@whamcloud.com>
> > Reviewed-on: https://review.whamcloud.com/28010
> > Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
> > Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
> > Signed-off-by: James Simmons <jsimmons@infradead.org>
> 
> Hi James,
>  you appear to have merged (most of) my
>    lustre: use wait_event() in lov_subobject_kill()
>  patch into this.  What that intentional?

No I missed that. It was a direct port from your lustre-testing tree.
It would be best to break out the change. Let me push that work to
OpenSFS tree.
 
> NeilBrown
> 
> > ---
> >  fs/lustre/include/obd.h                 |   8 +
> >  fs/lustre/lmv/lmv_obd.c                 |   2 +-
> >  fs/lustre/lov/lov_cl_internal.h         |  76 +++-
> >  fs/lustre/lov/lov_dev.c                 | 276 +++++++++++--
> >  fs/lustre/lov/lov_ea.c                  |  20 +-
> >  fs/lustre/lov/lov_internal.h            |   7 +
> >  fs/lustre/lov/lov_io.c                  |   6 +-
> >  fs/lustre/lov/lov_obd.c                 |  39 +-
> >  fs/lustre/lov/lov_object.c              | 696 +++++++++++++++++++++-----------
> >  fs/lustre/lov/lov_offset.c              |   3 +
> >  fs/lustre/mdc/mdc_request.c             |   7 +-
> >  fs/lustre/obdclass/obd_config.c         |  36 +-
> >  fs/lustre/ptlrpc/wiretest.c             |   4 +-
> >  include/uapi/linux/lustre/lustre_user.h |   2 +-
> >  14 files changed, 883 insertions(+), 299 deletions(-)
> >
> > diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
> > index 9514260..baa97a9 100644
> > --- a/fs/lustre/include/obd.h
> > +++ b/fs/lustre/include/obd.h
> > @@ -381,6 +381,11 @@ struct lov_tgt_desc {
> >  				ltd_reap:1;  /* should this target be deleted */
> >  };
> >  
> > +struct lov_md_tgt_desc {
> > +	struct obd_device *lmtd_mdc;
> > +	u32		   lmtd_index;
> > +};
> > +
> >  struct lov_obd {
> >  	struct lov_desc		desc;
> >  	struct lov_tgt_desc   **lov_tgts;	/* sparse array */
> > @@ -403,10 +408,13 @@ struct lov_obd {
> >  	struct rw_semaphore     lov_notify_lock;
> >  
> >  	struct kobject	       *lov_tgts_kobj;
> > +	/* Data-on-MDT: MDC array */
> > +	struct lov_md_tgt_desc	*lov_mdc_tgts;
> >  };
> >  
> >  struct lmv_tgt_desc {
> >  	struct obd_uuid		ltd_uuid;
> > +	struct obd_device	*ltd_obd;
> >  	struct obd_export      *ltd_exp;
> >  	u32			ltd_idx;
> >  	struct mutex		ltd_fid_mutex;
> > diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
> > index bcbda30..aabd043 100644
> > --- a/fs/lustre/lmv/lmv_obd.c
> > +++ b/fs/lustre/lmv/lmv_obd.c
> > @@ -389,7 +389,7 @@ static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
> >  
> >  	if ((index < lmv->tgts_size) && lmv->tgts[index]) {
> >  		tgt = lmv->tgts[index];
> > -		CERROR("%s: UUID %s already assigned at LOV target index %d: rc = %d\n",
> > +		CERROR("%s: UUID %s already assigned at LMV target index %d: rc = %d\n",
> >  		       obd->obd_name,
> >  		       obd_uuid2str(&tgt->ltd_uuid), index, -EEXIST);
> >  		mutex_unlock(&lmv->lmv_init_mutex);
> > diff --git a/fs/lustre/lov/lov_cl_internal.h b/fs/lustre/lov/lov_cl_internal.h
> > index 22ef7b2..069b30e 100644
> > --- a/fs/lustre/lov/lov_cl_internal.h
> > +++ b/fs/lustre/lov/lov_cl_internal.h
> > @@ -91,6 +91,12 @@ enum lov_device_flags {
> >   * Upper half.
> >   */
> >  
> > +/* Data-on-MDT array item in lov_device::ld_md_tgts[] */
> > +struct lovdom_device {
> > +	struct cl_device	*ldm_mdc;
> > +	int			 ldm_idx;
> > +};
> > +
> >  struct lov_device {
> >  	/*
> >  	 * XXX Locking of lov-private data is missing.
> > @@ -101,6 +107,13 @@ struct lov_device {
> >  	u32			ld_target_nr;
> >  	struct lovsub_device  **ld_target;
> >  	u32			ld_flags;
> > +
> > +	/* Data-on-MDT devices */
> > +	u32			  ld_md_tgts_nr;
> > +	struct lovdom_device	 *ld_md_tgts;
> > +	struct obd_device	 *ld_lmv;
> > +	/* LU site for subdevices */
> > +	struct lu_site		  ld_site;
> >  };
> >  
> >  /**
> > @@ -129,6 +142,34 @@ static inline char *llt2str(enum lov_layout_type llt)
> >  	return "";
> >  }
> >  
> > +/**
> > + * Return lov_layout_entry_type associated with a given composite layout
> > + * entry.
> > + */
> > +static inline u32 lov_entry_type(struct lov_stripe_md_entry *lsme)
> > +{
> > +	if ((lov_pattern(lsme->lsme_pattern) == LOV_PATTERN_RAID0) ||
> > +	    (lov_pattern(lsme->lsme_pattern) == LOV_PATTERN_MDT))
> > +		return lov_pattern(lsme->lsme_pattern);
> > +	return 0;
> > +}
> > +
> > +struct lov_layout_entry;
> > +struct lov_object;
> > +struct lov_lock_sub;
> > +
> > +struct lov_comp_layout_entry_ops {
> > +	int (*lco_init)(const struct lu_env *env, struct lov_device *dev,
> > +			struct lov_object *lov, unsigned int index,
> > +			const struct cl_object_conf *conf,
> > +			struct lov_layout_entry *lle);
> > +	void (*lco_fini)(const struct lu_env *env,
> > +			 struct lov_layout_entry *lle);
> > +	int  (*lco_getattr)(const struct lu_env *env, struct lov_object *obj,
> > +			    unsigned int index, struct lov_layout_entry *lle,
> > +			    struct cl_attr **attr);
> > +};
> > +
> >  struct lov_layout_raid0 {
> >  	unsigned int		lo_nr;
> >  	/**
> > @@ -165,6 +206,25 @@ struct lov_layout_raid0 {
> >  	struct cl_attr		lo_attr;
> >  };
> >  
> > +struct lov_layout_dom {
> > +	/* keep this always at first place so DOM layout entry
> > +	 * can be addressed also as RAID0 after initialization.
> > +	 */
> > +	struct lov_layout_raid0 lo_dom_r0;
> > +	struct lovsub_object	*lo_dom;
> > +	struct lov_oinfo	*lo_loi;
> > +};
> > +
> > +struct lov_layout_entry {
> > +	u32					lle_type;
> > +	struct lu_extent			lle_extent;
> > +	struct lov_comp_layout_entry_ops	*lle_comp_ops;
> > +	union {
> > +		struct lov_layout_raid0		lle_raid0;
> > +		struct lov_layout_dom		lle_dom;
> > +	};
> > +};
> > +
> >  /**
> >   * lov-specific file state.
> >   *
> > @@ -220,13 +280,10 @@ struct lov_object {
> >  		} released;
> >  		struct lov_layout_composite {
> >  			/**
> > -			 * Current valid entry count of lo_entries.
> > +			 * Current valid entry count of entries.
> >  			 */
> >  			unsigned int lo_entry_count;
> > -			struct lov_layout_entry {
> > -				struct lu_extent lle_extent;
> > -				struct lov_layout_raid0 lle_raid0;
> > -			} *lo_entries;
> > +			struct lov_layout_entry *lo_entries;
> >  		} composite;
> >  	} u;
> >  	/**
> > @@ -633,6 +690,15 @@ static inline struct lov_thread_info *lov_env_info(const struct lu_env *env)
> >  	return info;
> >  }
> >  
> > +static inline struct lov_layout_entry *lov_entry(struct lov_object *lov, int i)
> > +{
> > +	LASSERT(lov->lo_type == LLT_COMP);
> > +	LASSERTF(i < lov->u.composite.lo_entry_count,
> > +		 "entry %d entry_count %d", i, lov->u.composite.lo_entry_count);
> > +
> > +	return &lov->u.composite.lo_entries[i];
> > +}
> > +
> >  static inline struct lov_layout_raid0 *lov_r0(struct lov_object *lov, int i)
> >  {
> >  	LASSERT(lov->lo_type == LLT_COMP);
> > diff --git a/fs/lustre/lov/lov_dev.c b/fs/lustre/lov/lov_dev.c
> > index a55b3f9..5ddf49a 100644
> > --- a/fs/lustre/lov/lov_dev.c
> > +++ b/fs/lustre/lov/lov_dev.c
> > @@ -146,23 +146,55 @@ struct lu_context_key lov_session_key = {
> >  /* type constructor/destructor: lov_type_{init,fini,start,stop}() */
> >  LU_TYPE_INIT_FINI(lov, &lov_key, &lov_session_key);
> >  
> > +
> > +static int lov_mdc_dev_init(const struct lu_env *env, struct lov_device *ld,
> > +			    struct lu_device *mdc_dev, u32 idx, u32 nr)
> > +{
> > +	struct cl_device *cl;
> > +
> > +	cl = cl_type_setup(env, &ld->ld_site, &lovsub_device_type,
> > +			   mdc_dev);
> > +	if (IS_ERR(cl))
> > +		return PTR_ERR(cl);
> > +
> > +	ld->ld_md_tgts[nr].ldm_mdc = cl;
> > +	ld->ld_md_tgts[nr].ldm_idx = idx;
> > +	return 0;
> > +}
> > +
> >  static struct lu_device *lov_device_fini(const struct lu_env *env,
> >  					 struct lu_device *d)
> >  {
> > -	int i;
> >  	struct lov_device *ld = lu2lov_dev(d);
> > +	int i;
> >  
> >  	LASSERT(ld->ld_lov);
> > -	if (!ld->ld_target)
> > -		return NULL;
> >  
> > -	lov_foreach_target(ld, i) {
> > -		struct lovsub_device *lsd;
> > +	if (ld->ld_lmv) {
> > +		class_decref(ld->ld_lmv, "lov", d);
> > +		ld->ld_lmv = NULL;
> > +	}
> > +
> > +	if (ld->ld_md_tgts) {
> > +		for (i = 0; i < ld->ld_md_tgts_nr; i++) {
> > +			if (!ld->ld_md_tgts[i].ldm_mdc)
> > +				continue;
> >  
> > -		lsd = ld->ld_target[i];
> > -		if (lsd) {
> > -			cl_stack_fini(env, lovsub2cl_dev(lsd));
> > -			ld->ld_target[i] = NULL;
> > +			cl_stack_fini(env, ld->ld_md_tgts[i].ldm_mdc);
> > +			ld->ld_md_tgts[i].ldm_mdc = NULL;
> > +			ld->ld_lov->lov_mdc_tgts[i].lmtd_mdc = NULL;
> > +		}
> > +	}
> > +
> > +	if (ld->ld_target) {
> > +		lov_foreach_target(ld, i) {
> > +			struct lovsub_device *lsd;
> > +
> > +			lsd = ld->ld_target[i];
> > +			if (lsd) {
> > +				cl_stack_fini(env, lovsub2cl_dev(lsd));
> > +				ld->ld_target[i] = NULL;
> > +			}
> >  		}
> >  	}
> >  	return NULL;
> > @@ -175,9 +207,28 @@ static int lov_device_init(const struct lu_env *env, struct lu_device *d,
> >  	int i;
> >  	int rc = 0;
> >  
> > -	LASSERT(d->ld_site);
> > +	/* check all added already MDC subdevices and initialize them */
> > +	for (i = 0; i < ld->ld_md_tgts_nr; i++) {
> > +		struct obd_device *mdc;
> > +		u32 idx;
> > +
> > +		mdc = ld->ld_lov->lov_mdc_tgts[i].lmtd_mdc;
> > +		idx = ld->ld_lov->lov_mdc_tgts[i].lmtd_index;
> > +
> > +		if (!mdc)
> > +			continue;
> > +
> > +		rc = lov_mdc_dev_init(env, ld, mdc->obd_lu_dev, idx, i);
> > +		if (rc) {
> > +			CERROR("%s: failed to add MDC %s as target: rc = %d\n",
> > +			       d->ld_obd->obd_name,
> > +			       obd_uuid2str(&mdc->obd_uuid), rc);
> > +			goto out_err;
> > +		}
> > +	}
> > +
> >  	if (!ld->ld_target)
> > -		return rc;
> > +		return 0;
> >  
> >  	lov_foreach_target(ld, i) {
> >  		struct lovsub_device *lsd;
> > @@ -188,21 +239,21 @@ static int lov_device_init(const struct lu_env *env, struct lu_device *d,
> >  		if (!desc)
> >  			continue;
> >  
> > -		cl = cl_type_setup(env, d->ld_site, &lovsub_device_type,
> > +		cl = cl_type_setup(env, &ld->ld_site, &lovsub_device_type,
> >  				   desc->ltd_obd->obd_lu_dev);
> >  		if (IS_ERR(cl)) {
> >  			rc = PTR_ERR(cl);
> > -			break;
> > +			goto out_err;
> >  		}
> > +
> >  		lsd = cl2lovsub_dev(cl);
> >  		ld->ld_target[i] = lsd;
> >  	}
> > +	ld->ld_flags |= LOV_DEV_INITIALIZED;
> > +	return 0;
> >  
> > -	if (rc)
> > -		lov_device_fini(env, d);
> > -	else
> > -		ld->ld_flags |= LOV_DEV_INITIALIZED;
> > -
> > +out_err:
> > +	lu_device_fini(d);
> >  	return rc;
> >  }
> >  
> > @@ -211,8 +262,17 @@ static struct lu_device *lov_device_free(const struct lu_env *env,
> >  {
> >  	struct lov_device *ld = lu2lov_dev(d);
> >  
> > +	lu_site_fini(&ld->ld_site);
> > +
> >  	cl_device_fini(lu2cl_dev(d));
> >  	kfree(ld->ld_target);
> > +	ld->ld_target = NULL;
> > +	kfree(ld->ld_md_tgts);
> > +	ld->ld_md_tgts = NULL;
> > +	/* free array of MDCs */
> > +	kfree(ld->ld_lov->lov_mdc_tgts);
> > +	ld->ld_lov->lov_mdc_tgts = NULL;
> > +
> >  	kfree(ld);
> >  	return NULL;
> >  }
> > @@ -277,9 +337,7 @@ static int lov_cl_add_target(const struct lu_env *env, struct lu_device *dev,
> >  
> >  	rc = lov_expand_targets(env, ld);
> >  	if (rc == 0 && ld->ld_flags & LOV_DEV_INITIALIZED) {
> > -		LASSERT(dev->ld_site);
> > -
> > -		cl = cl_type_setup(env, dev->ld_site, &lovsub_device_type,
> > +		cl = cl_type_setup(env, &ld->ld_site, &lovsub_device_type,
> >  				   tgt->ltd_obd->obd_lu_dev);
> >  		if (!IS_ERR(cl)) {
> >  			lsd = cl2lovsub_dev(cl);
> > @@ -297,6 +355,84 @@ static int lov_cl_add_target(const struct lu_env *env, struct lu_device *dev,
> >  	return rc;
> >  }
> >  
> > +/**
> > + * Add new MDC target device in LOV.
> > + *
> > + * This function is part of the configuration log processing. It adds new MDC
> > + * device to the MDC device array indexed by their indexes.
> > + *
> > + * @env		execution environment
> > + * @d		LU device of LOV device
> > + * @mdc		MDC device to add
> > + * @idx		MDC device index
> > + *
> > + * Return:	0 if successful
> > + *		negative value on error
> > + */
> > +static int lov_add_mdc_target(const struct lu_env *env, struct lu_device *d,
> > +			      struct obd_device *mdc, u32 idx)
> > +{
> > +	struct lov_device *ld = lu2lov_dev(d);
> > +	struct obd_device *lov_obd = d->ld_obd;
> > +	struct obd_device *lmv_obd;
> > +	int next;
> > +	int rc = 0;
> > +
> > +	LASSERT(mdc);
> > +	if (ld->ld_md_tgts_nr == LOV_MDC_TGT_MAX) {
> > +		/* If the maximum value of LOV_MDC_TGT_MAX will become too
> > +		 * small then all MD target handling must be rewritten in LOD
> > +		 * manner, check lod_add_device() and related functionality.
> > +		 */
> > +		CERROR("%s: cannot serve more than %d MDC devices\n",
> > +		       lov_obd->obd_name, LOV_MDC_TGT_MAX);
> > +		return -ERANGE;
> > +	}
> > +
> > +	/* grab FLD from lmv, do that here, when first MDC is added
> > +	 * to be sure LMV is set up and can be found
> > +	 */
> > +	if (!ld->ld_lmv) {
> > +		next = 0;
> > +		while ((lmv_obd = class_devices_in_group(&lov_obd->obd_uuid,
> > +							 &next)) != NULL) {
> > +			if ((strncmp(lmv_obd->obd_type->typ_name,
> > +				     LUSTRE_LMV_NAME,
> > +				     strlen(LUSTRE_LMV_NAME)) == 0))
> > +				break;
> > +		}
> > +		if (!lmv_obd) {
> > +			CERROR("%s: cannot find LMV OBD by UUID (%s)\n",
> > +			       lov_obd->obd_name,
> > +			       obd_uuid2str(&lmv_obd->obd_uuid));
> > +			return -ENODEV;
> > +		}
> > +		spin_lock(&lmv_obd->obd_dev_lock);
> > +		class_incref(lmv_obd, "lov", ld);
> > +		spin_unlock(&lmv_obd->obd_dev_lock);
> > +		ld->ld_lmv = lmv_obd;
> > +	}
> > +
> > +	LASSERT(!lov_obd->u.lov.lov_mdc_tgts[ld->ld_md_tgts_nr].lmtd_mdc);
> > +
> > +	if (ld->ld_flags & LOV_DEV_INITIALIZED) {
> > +		rc = lov_mdc_dev_init(env, ld, mdc->obd_lu_dev, idx,
> > +				      ld->ld_md_tgts_nr);
> > +		if (rc) {
> > +			CERROR("%s: failed to add MDC %s as target: rc = %d\n",
> > +			       lov_obd->obd_name, obd_uuid2str(&mdc->obd_uuid),
> > +			       rc);
> > +			return rc;
> > +		}
> > +	}
> > +
> > +	lov_obd->u.lov.lov_mdc_tgts[ld->ld_md_tgts_nr].lmtd_mdc = mdc;
> > +	lov_obd->u.lov.lov_mdc_tgts[ld->ld_md_tgts_nr].lmtd_index = idx;
> > +	ld->ld_md_tgts_nr++;
> > +
> > +	return rc;
> > +}
> > +
> >  static int lov_process_config(const struct lu_env *env,
> >  			      struct lu_device *d, struct lustre_cfg *cfg)
> >  {
> > @@ -309,23 +445,52 @@ static int lov_process_config(const struct lu_env *env,
> >  	lov_tgts_getref(obd);
> >  
> >  	cmd = cfg->lcfg_command;
> > +
> >  	rc = lov_process_config_base(d->ld_obd, cfg, &index, &gen);
> > -	if (rc == 0) {
> > -		switch (cmd) {
> > -		case LCFG_LOV_ADD_OBD:
> > -		case LCFG_LOV_ADD_INA:
> > -			rc = lov_cl_add_target(env, d, index);
> > -			if (rc != 0)
> > -				lov_del_target(d->ld_obd, index, NULL, 0);
> > -			break;
> > -		case LCFG_LOV_DEL_OBD:
> > -			lov_cl_del_target(env, d, index);
> > -			break;
> > +	if (rc < 0)
> > +		goto out;
> > +
> > +	switch (cmd) {
> > +	case LCFG_LOV_ADD_OBD:
> > +	case LCFG_LOV_ADD_INA:
> > +		rc = lov_cl_add_target(env, d, index);
> > +		if (rc != 0)
> > +			lov_del_target(d->ld_obd, index, NULL, 0);
> > +		break;
> > +	case LCFG_LOV_DEL_OBD:
> > +		lov_cl_del_target(env, d, index);
> > +		break;
> > +	case LCFG_ADD_MDC:
> > +	{
> > +		struct obd_device *mdc;
> > +		struct obd_uuid tgt_uuid;
> > +
> > +		/* modify_mdc_tgts add 0:lustre-clilmv  1:lustre-MDT0000_UUID
> > +		 * 2:0  3:1  4:lustre-MDT0000-mdc_UUID
> > +		 */
> > +		if (LUSTRE_CFG_BUFLEN(cfg, 1) > sizeof(tgt_uuid.uuid)) {
> > +			rc = -EINVAL;
> > +			goto out;
> >  		}
> > -	}
> >  
> > -	lov_tgts_putref(obd);
> > +		obd_str2uuid(&tgt_uuid, lustre_cfg_buf(cfg, 1));
> >  
> > +		if (sscanf(lustre_cfg_buf(cfg, 2), "%d", &index) != 1) {
> > +			rc = -EINVAL;
> > +			goto out;
> > +		}
> > +		mdc = class_find_client_obd(&tgt_uuid, LUSTRE_MDC_NAME,
> > +					    &obd->obd_uuid);
> > +		if (!mdc) {
> > +			rc = -ENODEV;
> > +			goto out;
> > +		}
> > +		rc = lov_add_mdc_target(env, d, mdc, index);
> > +		break;
> > +	}
> > +	}
> > +out:
> > +	lov_tgts_putref(obd);
> >  	return rc;
> >  }
> >  
> > @@ -355,13 +520,50 @@ static struct lu_device *lov_device_alloc(const struct lu_env *env,
> >  	obd = class_name2obd(lustre_cfg_string(cfg, 0));
> >  	LASSERT(obd);
> >  	rc = lov_setup(obd, cfg);
> > -	if (rc) {
> > -		lov_device_free(env, d);
> > -		return ERR_PTR(rc);
> > +	if (rc)
> > +		goto out;
> > +
> > +	/* Alloc MDC devices array */
> > +	/* XXX: need dynamic allocation at some moment */
> > +	ld->ld_md_tgts = kcalloc(LOV_MDC_TGT_MAX, sizeof(*ld->ld_md_tgts),
> > +				 GFP_NOFS);
> > +	if (!ld->ld_md_tgts) {
> > +		rc = -ENOMEM;
> > +		goto out;
> >  	}
> > +	ld->ld_md_tgts_nr = 0;
> >  
> >  	ld->ld_lov = &obd->u.lov;
> > +	ld->ld_lov->lov_mdc_tgts =
> > +		kcalloc(LOV_MDC_TGT_MAX,
> > +			sizeof(*ld->ld_lov->lov_mdc_tgts),
> > +			GFP_NOFS);
> > +	if (!ld->ld_lov->lov_mdc_tgts) {
> > +		rc = -ENOMEM;
> > +		goto out_md_tgts;
> > +	}
> > +
> > +	rc = lu_site_init(&ld->ld_site, d);
> > +	if (rc != 0)
> > +		goto out_mdc_tgts;
> > +
> > +	rc = lu_site_init_finish(&ld->ld_site);
> > +	if (rc != 0)
> > +		goto out_site;
> > +
> >  	return d;
> > +out_site:
> > +	lu_site_fini(&ld->ld_site);
> > +out_mdc_tgts:
> > +	kfree(ld->ld_lov->lov_mdc_tgts);
> > +	ld->ld_lov->lov_mdc_tgts = NULL;
> > +out_md_tgts:
> > +	kfree(ld->ld_md_tgts);
> > +	ld->ld_md_tgts = NULL;
> > +out:
> > +	kfree(ld);
> > +
> > +	return ERR_PTR(rc);
> >  }
> >  
> >  static const struct lu_device_type_operations lov_device_type_ops = {
> > diff --git a/fs/lustre/lov/lov_ea.c b/fs/lustre/lov/lov_ea.c
> > index 395ef77..e1630f6 100644
> > --- a/fs/lustre/lov/lov_ea.c
> > +++ b/fs/lustre/lov/lov_ea.c
> > @@ -95,7 +95,8 @@ static int lsm_lmm_verify_v1v3(struct lov_mds_md *lmm, size_t lmm_size,
> >  		return -EINVAL;
> >  	}
> >  
> > -	if (lov_pattern(le32_to_cpu(lmm->lmm_pattern)) != LOV_PATTERN_RAID0) {
> > +	if (lov_pattern(le32_to_cpu(lmm->lmm_pattern)) != LOV_PATTERN_MDT &&
> > +	    lov_pattern(le32_to_cpu(lmm->lmm_pattern)) != LOV_PATTERN_RAID0) {
> >  		CERROR("bad striping pattern\n");
> >  		lov_dump_lmm_common(D_WARNING, lmm);
> >  		return -EINVAL;
> > @@ -206,6 +207,12 @@ void lsm_free(struct lov_stripe_md *lsm)
> >  		}
> >  	}
> >  
> > +	/* with Data-on-MDT set maxbytes to stripe size */
> > +	if (lsme_is_dom(lsme)) {
> > +		lov_bytes = lsme->lsme_stripe_size;
> > +		goto out_dom;
> > +	}
> > +
> >  	for (i = 0; i < stripe_count; i++) {
> >  		struct lov_tgt_desc *ltd;
> >  		struct lov_oinfo *loi;
> > @@ -253,6 +260,7 @@ void lsm_free(struct lov_stripe_md *lsm)
> >  
> >  	lov_bytes = min_stripe_maxbytes * stripe_count;
> >  
> > +out_dom:
> >  	if (maxbytes) {
> >  		if (lov_bytes < min_stripe_maxbytes) /* handle overflow */
> >  			*maxbytes = MAX_LFS_FILESIZE;
> > @@ -385,7 +393,8 @@ static int lsm_verify_comp_md_v1(struct lov_comp_md_v1 *lcm,
> >  	unsigned int magic;
> >  
> >  	stripe_count = le16_to_cpu(lmm->lmm_stripe_count);
> > -	if (stripe_count == 0)
> > +	if (stripe_count == 0 &&
> > +	    lov_pattern(le32_to_cpu(lmm->lmm_pattern)) != LOV_PATTERN_MDT)
> >  		return ERR_PTR(-EINVAL);
> >  
> >  	/* un-instantiated lmm contains no ost id info, i.e. lov_ost_data_v1 */
> > @@ -474,9 +483,10 @@ static int lsm_verify_comp_md_v1(struct lov_comp_md_v1 *lcm,
> >  			/* the last component hasn't been defined, or
> >  			 * lsm_maxbytes overflowed.
> >  			 */
> > -			if (lsme->lsme_extent.e_end != LUSTRE_EOF ||
> > -			    lsm->lsm_maxbytes <
> > -			    (loff_t)lsme->lsme_extent.e_start)
> > +			if (!lsme_is_dom(lsme) &&
> > +			    (lsme->lsme_extent.e_end != LUSTRE_EOF ||
> > +			     lsm->lsm_maxbytes <
> > +			     (loff_t)lsme->lsme_extent.e_start))
> >  				lsm->lsm_maxbytes = MAX_LFS_FILESIZE;
> >  		}
> >  	}
> > diff --git a/fs/lustre/lov/lov_internal.h b/fs/lustre/lov/lov_internal.h
> > index f69f2d6..e18ea8e 100644
> > --- a/fs/lustre/lov/lov_internal.h
> > +++ b/fs/lustre/lov/lov_internal.h
> > @@ -57,6 +57,11 @@ struct lov_stripe_md_entry {
> >  	struct lov_oinfo       *lsme_oinfo[];
> >  };
> >  
> > +static inline bool lsme_is_dom(struct lov_stripe_md_entry *lsme)
> > +{
> > +	return (lov_pattern(lsme->lsme_pattern) == LOV_PATTERN_MDT);
> > +}
> > +
> >  static inline void copy_lsm_entry(struct lov_stripe_md_entry *dst,
> >  				  struct lov_stripe_md_entry *src)
> >  {
> > @@ -300,6 +305,8 @@ struct lov_stripe_md *lov_unpackmd(struct lov_obd *lov, void *buf,
> >  /* lov_cl.c */
> >  extern struct lu_device_type lov_device_type;
> >  
> > +#define LOV_MDC_TGT_MAX 256
> > +
> >  /* ost_pool methods */
> >  int lov_ost_pool_init(struct ost_pool *op, unsigned int count);
> >  int lov_ost_pool_extend(struct ost_pool *op, unsigned int min_count);
> > diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
> > index a72069f..c7fe4a2 100644
> > --- a/fs/lustre/lov/lov_io.c
> > +++ b/fs/lustre/lov/lov_io.c
> > @@ -533,7 +533,11 @@ static int lov_io_setattr_iter_init(const struct lu_env *env,
> >  
> >  	if (cl_io_is_trunc(io) && lio->lis_pos > 0) {
> >  		index = lov_lsm_entry(lsm, lio->lis_pos - 1);
> > -		if (index > 0 && !lsm_entry_inited(lsm, index)) {
> > +		/* no entry found for such offset */
> > +		if (index < 0) {
> > +			io->ci_result = -ENODATA;
> > +			return io->ci_result;
> > +		} else if (!lsm_entry_inited(lsm, index)) {
> >  			io->ci_need_write_intent = 1;
> >  			io->ci_result = -ENODATA;
> >  			return io->ci_result;
> > diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
> > index 5dbc00e..4ced5f7 100644
> > --- a/fs/lustre/lov/lov_obd.c
> > +++ b/fs/lustre/lov/lov_obd.c
> > @@ -852,6 +852,9 @@ int lov_process_config_base(struct obd_device *obd, struct lustre_cfg *lcfg,
> >  	int rc = 0;
> >  
> >  	switch (cmd = lcfg->lcfg_command) {
> > +	case LCFG_ADD_MDC:
> > +	case LCFG_DEL_MDC:
> > +		break;
> >  	case LCFG_LOV_ADD_OBD:
> >  	case LCFG_LOV_ADD_INA:
> >  	case LCFG_LOV_DEL_OBD: {
> > @@ -1179,31 +1182,32 @@ static int lov_set_info_async(const struct lu_env *env, struct obd_export *exp,
> >  {
> >  	struct obd_device *obddev = class_exp2obd(exp);
> >  	struct lov_obd *lov = &obddev->u.lov;
> > -	u32 count;
> > -	int i, rc = 0, err;
> >  	struct lov_tgt_desc *tgt;
> > -	int do_inactive = 0, no_set = 0;
> > +	bool do_inactive = false;
> > +	bool no_set = false;
> > +	int rc = 0;
> > +	int err;
> > +	u32 i;
> >  
> >  	if (!set) {
> > -		no_set = 1;
> > +		no_set = true;
> >  		set = ptlrpc_prep_set();
> >  		if (!set)
> >  			return -ENOMEM;
> >  	}
> >  
> >  	lov_tgts_getref(obddev);
> > -	count = lov->desc.ld_tgt_count;
> >  
> >  	if (KEY_IS(KEY_CHECKSUM)) {
> > -		do_inactive = 1;
> > +		do_inactive = true;
> >  	} else if (KEY_IS(KEY_CACHE_SET)) {
> >  		LASSERT(!lov->lov_cache);
> >  		lov->lov_cache = val;
> > -		do_inactive = 1;
> > +		do_inactive = true;
> >  		cl_cache_incref(lov->lov_cache);
> >  	}
> >  
> > -	for (i = 0; i < count; i++) {
> > +	for (i = 0; i < lov->desc.ld_tgt_count; i++) {
> >  		tgt = lov->lov_tgts[i];
> >  
> >  		/* OST was disconnected */
> > @@ -1216,14 +1220,29 @@ static int lov_set_info_async(const struct lu_env *env, struct obd_export *exp,
> >  
> >  		err = obd_set_info_async(env, tgt->ltd_exp, keylen, key,
> >  					 vallen, val, set);
> > -		if (!rc)
> > +
> > +		if (rc == 0)
> > +			rc = err;
> > +	}
> > +
> > +	/* cycle through MDC target for Data-on-MDT */
> > +	for (i = 0; i < LOV_MDC_TGT_MAX; i++) {
> > +		struct obd_device *mdc;
> > +
> > +		mdc = lov->lov_mdc_tgts[i].lmtd_mdc;
> > +		if (!mdc)
> > +			continue;
> > +
> > +		err = obd_set_info_async(env, mdc->obd_self_export,
> > +					 keylen, key, vallen, val, set);
> > +		if (rc == 0)
> >  			rc = err;
> >  	}
> >  
> >  	lov_tgts_putref(obddev);
> >  	if (no_set) {
> >  		err = ptlrpc_set_wait(set);
> > -		if (!rc)
> > +		if (rc == 0)
> >  			rc = err;
> >  		ptlrpc_set_destroy(set);
> >  	}
> > diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
> > index caeff89..186b875 100644
> > --- a/fs/lustre/lov/lov_object.c
> > +++ b/fs/lustre/lov/lov_object.c
> > @@ -90,13 +90,6 @@ static void lov_lsm_put(struct lov_stripe_md *lsm)
> >   * Lov object layout operations.
> >   *
> >   */
> > -static int lov_init_empty(const struct lu_env *env, struct lov_device *dev,
> > -			  struct lov_object *lov, struct lov_stripe_md *lsm,
> > -			  const struct cl_object_conf *conf,
> > -			  union lov_layout_state *state)
> > -{
> > -	return 0;
> > -}
> >  
> >  static struct cl_object *lov_sub_find(const struct lu_env *env,
> >  				      struct cl_device *dev,
> > @@ -110,9 +103,25 @@ static struct cl_object *lov_sub_find(const struct lu_env *env,
> >  	return lu2cl(o);
> >  }
> >  
> > +static int lov_page_slice_fixup(struct lov_object *lov,
> > +				struct cl_object *stripe)
> > +{
> > +	struct cl_object_header *hdr = cl_object_header(&lov->lo_cl);
> > +	struct cl_object *o;
> > +
> > +	if (!stripe)
> > +		return hdr->coh_page_bufsize - lov->lo_cl.co_slice_off -
> > +		       cfs_size_round(sizeof(struct lov_page));
> > +
> > +	cl_object_for_each(o, stripe)
> > +		o->co_slice_off += hdr->coh_page_bufsize;
> > +
> > +	return cl_object_header(stripe)->coh_page_bufsize;
> > +}
> > +
> >  static int lov_init_sub(const struct lu_env *env, struct lov_object *lov,
> > -			struct cl_object *subobj, struct lov_layout_raid0 *r0,
> > -			struct lov_oinfo *oinfo, int idx)
> > +			struct cl_object *subobj, struct lov_oinfo *oinfo,
> > +			int idx)
> >  {
> >  	int stripe = lov_comp_stripe(idx);
> >  	int entry = lov_comp_entry(idx);
> > @@ -146,13 +155,14 @@ static int lov_init_sub(const struct lu_env *env, struct lov_object *lov,
> >  	spin_lock(&subhdr->coh_attr_guard);
> >  	parent = subhdr->coh_parent;
> >  	if (!parent) {
> > +		struct lovsub_object *lso = cl2lovsub(subobj);
> > +
> >  		subhdr->coh_parent = hdr;
> >  		spin_unlock(&subhdr->coh_attr_guard);
> >  		subhdr->coh_nesting = hdr->coh_nesting + 1;
> >  		lu_object_ref_add(&subobj->co_lu, "lov-parent", lov);
> > -		r0->lo_sub[stripe] = cl2lovsub(subobj);
> > -		r0->lo_sub[stripe]->lso_super = lov;
> > -		r0->lo_sub[stripe]->lso_index = idx;
> > +		lso->lso_super = lov;
> > +		lso->lso_index = idx;
> >  		result = 0;
> >  	} else {
> >  		struct lu_object *old_obj;
> > @@ -183,33 +193,19 @@ static int lov_init_sub(const struct lu_env *env, struct lov_object *lov,
> >  	return result;
> >  }
> >  
> > -static int lov_page_slice_fixup(struct lov_object *lov,
> > -				struct cl_object *stripe)
> > -{
> > -	struct cl_object_header *hdr = cl_object_header(&lov->lo_cl);
> > -	struct cl_object *o;
> > -
> > -	if (!stripe)
> > -		return hdr->coh_page_bufsize - lov->lo_cl.co_slice_off -
> > -		       cfs_size_round(sizeof(struct lov_page));
> > -
> > -	cl_object_for_each(o, stripe)
> > -		o->co_slice_off += hdr->coh_page_bufsize;
> > -
> > -	return cl_object_header(stripe)->coh_page_bufsize;
> > -}
> > -
> >  static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
> > -			  struct lov_object *lov, int index,
> > -			  struct lov_layout_raid0 *r0)
> > +			  struct lov_object *lov, unsigned int index,
> > +			  const struct cl_object_conf *conf,
> > +			  struct lov_layout_entry *lle)
> >  {
> >  	struct lov_stripe_md_entry *lse = lov_lse(lov, index);
> > +	struct lov_layout_raid0 *r0 = &lle->lle_raid0;
> >  	struct lov_thread_info *lti = lov_env_info(env);
> >  	struct cl_object_conf *subconf = &lti->lti_stripe_conf;
> >  	struct lu_fid *ofid = &lti->lti_fid;
> >  	struct cl_object *stripe;
> >  	int result;
> > -	int psz;
> > +	int psz, sz;
> >  	int i;
> >  
> >  	spin_lock_init(&r0->lo_sub_lock);
> > @@ -261,7 +257,7 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
> >  			goto out;
> >  		}
> >  
> > -		result = lov_init_sub(env, lov, stripe, r0, oinfo,
> > +		result = lov_init_sub(env, lov, stripe, oinfo,
> >  				      lov_comp_index(index, i));
> >  		if (result == -EAGAIN) { /* try again */
> >  			--i;
> > @@ -270,8 +266,9 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
> >  		}
> >  
> >  		if (result == 0) {
> > -			int sz = lov_page_slice_fixup(lov, stripe);
> > +			r0->lo_sub[i] = cl2lovsub(stripe);
> >  
> > +			sz = lov_page_slice_fixup(lov, stripe);
> >  			LASSERT(ergo(psz > 0, psz == sz));
> >  			psz = sz;
> >  		}
> > @@ -282,12 +279,333 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
> >  	return result;
> >  }
> >  
> > +static void lov_subobject_kill(const struct lu_env *env, struct lov_object *lov,
> > +			       struct lov_layout_raid0 *r0,
> > +			       struct lovsub_object *los, int idx)
> > +{
> > +	struct cl_object *sub;
> > +	struct lu_site *site;
> > +	wait_queue_head_t *wq;
> > +
> > +	LASSERT(r0->lo_sub[idx] == los);
> > +
> > +	sub = lovsub2cl(los);
> > +	site = sub->co_lu.lo_dev->ld_site;
> > +	wq = lu_site_wq_from_fid(site, &sub->co_lu.lo_header->loh_fid);
> > +
> > +	cl_object_kill(env, sub);
> > +	/* release a reference to the sub-object and ... */
> > +	lu_object_ref_del(&sub->co_lu, "lov-parent", lov);
> > +	cl_object_put(env, sub);
> > +
> > +	/* ... wait until it is actually destroyed---sub-object clears its
> > +	 * ->lo_sub[] slot in lovsub_object_free()
> > +	 */
> > +	wait_event(*wq, r0->lo_sub[idx] != los);
> > +	LASSERT(!r0->lo_sub[idx]);
> > +}
> > +
> > +static void lov_delete_raid0(const struct lu_env *env, struct lov_object *lov,
> > +			     struct lov_layout_entry *lle)
> > +{
> > +	struct lov_layout_raid0 *r0 = &lle->lle_raid0;
> > +
> > +	if (r0->lo_sub) {
> > +		int i;
> > +
> > +		for (i = 0; i < r0->lo_nr; ++i) {
> > +			struct lovsub_object *los = r0->lo_sub[i];
> > +
> > +			if (los) {
> > +				cl_object_prune(env, &los->lso_cl);
> > +				/*
> > +				 * If top-level object is to be evicted from
> > +				 * the cache, so are its sub-objects.
> > +				 */
> > +				lov_subobject_kill(env, lov, r0, los, i);
> > +			}
> > +		}
> > +	}
> > +}
> > +
> > +static void lov_fini_raid0(const struct lu_env *env,
> > +			   struct lov_layout_entry *lle)
> > +{
> > +	struct lov_layout_raid0 *r0 = &lle->lle_raid0;
> > +
> > +	if (r0->lo_sub) {
> > +		kvfree(r0->lo_sub);
> > +		r0->lo_sub = NULL;
> > +	}
> > +}
> > +
> > +static int lov_print_raid0(const struct lu_env *env, void *cookie,
> > +			   lu_printer_t p, const struct lov_layout_entry *lle)
> > +{
> > +	const struct lov_layout_raid0 *r0 = &lle->lle_raid0;
> > +	int i;
> > +
> > +	for (i = 0; i < r0->lo_nr; ++i) {
> > +		struct lu_object *sub;
> > +
> > +		if (r0->lo_sub[i]) {
> > +			sub = lovsub2lu(r0->lo_sub[i]);
> > +			lu_object_print(env, cookie, p, sub);
> > +		} else {
> > +			(*p)(env, cookie, "sub %d absent\n", i);
> > +		}
> > +	}
> > +	return 0;
> > +}
> > +
> > +static int lov_attr_get_raid0(const struct lu_env *env, struct lov_object *lov,
> > +			      unsigned int index, struct lov_layout_entry *lle,
> > +			      struct cl_attr **lov_attr)
> > +{
> > +	struct lov_layout_raid0 *r0 = &lle->lle_raid0;
> > +	struct lov_stripe_md *lsm = lov->lo_lsm;
> > +	struct ost_lvb *lvb = &lov_env_info(env)->lti_lvb;
> > +	struct cl_attr *attr = &r0->lo_attr;
> > +	u64 kms = 0;
> > +	int result = 0;
> > +
> > +	if (r0->lo_attr_valid) {
> > +		*lov_attr = attr;
> > +		return 0;
> > +	}
> > +
> > +	memset(lvb, 0, sizeof(*lvb));
> > +
> > +	/* XXX: timestamps can be negative by sanity:test_39m,
> > +	 * how can it be?
> > +	 */
> > +	lvb->lvb_atime = LLONG_MIN;
> > +	lvb->lvb_ctime = LLONG_MIN;
> > +	lvb->lvb_mtime = LLONG_MIN;
> > +
> > +	/*
> > +	 * XXX that should be replaced with a loop over sub-objects,
> > +	 * doing cl_object_attr_get() on them. But for now, let's
> > +	 * reuse old lov code.
> > +	 */
> > +
> > +	/*
> > +	 * XXX take lsm spin-lock to keep lov_merge_lvb_kms()
> > +	 * happy. It's not needed, because new code uses
> > +	 * ->coh_attr_guard spin-lock to protect consistency of
> > +	 * sub-object attributes.
> > +	 */
> > +	lov_stripe_lock(lsm);
> > +	result = lov_merge_lvb_kms(lsm, index, lvb, &kms);
> > +	lov_stripe_unlock(lsm);
> > +	if (result == 0) {
> > +		cl_lvb2attr(attr, lvb);
> > +		attr->cat_kms = kms;
> > +		r0->lo_attr_valid = 1;
> > +		*lov_attr = attr;
> > +	}
> > +
> > +	return result;
> > +}
> > +
> > +static struct lov_comp_layout_entry_ops raid0_ops = {
> > +	.lco_init      = lov_init_raid0,
> > +	.lco_fini      = lov_fini_raid0,
> > +	.lco_getattr   = lov_attr_get_raid0,
> > +};
> > +
> > +static int lov_attr_get_dom(const struct lu_env *env, struct lov_object *lov,
> > +			    unsigned int index, struct lov_layout_entry *lle,
> > +			    struct cl_attr **lov_attr)
> > +{
> > +	struct lov_layout_dom *dom = &lle->lle_dom;
> > +	struct lov_oinfo *loi = dom->lo_loi;
> > +	struct cl_attr *attr = &dom->lo_dom_r0.lo_attr;
> > +
> > +	if (dom->lo_dom_r0.lo_attr_valid) {
> > +		*lov_attr = attr;
> > +		return 0;
> > +	}
> > +
> > +	if (OST_LVB_IS_ERR(loi->loi_lvb.lvb_blocks))
> > +		return OST_LVB_GET_ERR(loi->loi_lvb.lvb_blocks);
> > +
> > +	cl_lvb2attr(attr, &loi->loi_lvb);
> > +	attr->cat_kms = attr->cat_size > loi->loi_kms ? attr->cat_size :
> > +							loi->loi_kms;
> > +	dom->lo_dom_r0.lo_attr_valid = 1;
> > +	*lov_attr = attr;
> > +
> > +	return 0;
> > +}
> > +
> > +/**
> > + * Lookup FLD to get MDS index of the given DOM object FID.
> > + *
> > + * @ld		LOV device
> > + * @fid		FID to lookup
> > + * @nr		index in MDC array to return back
> > + *
> > + * Return:	0 and @mds filled with MDS index if successful
> > + *		negative value on error
> > + */
> > +static int lov_fld_lookup(struct lov_device *ld, const struct lu_fid *fid,
> > +			  u32 *nr)
> > +{
> > +	u32 mds_idx;
> > +	int i, rc;
> > +
> > +	rc = fld_client_lookup(&ld->ld_lmv->u.lmv.lmv_fld, fid_seq(fid),
> > +			       &mds_idx, LU_SEQ_RANGE_MDT, NULL);
> > +	if (rc) {
> > +		CERROR("%s: error while looking for mds number. Seq %#llx, err = %d\n",
> > +		       lu_dev_name(cl2lu_dev(&ld->ld_cl)), fid_seq(fid), rc);
> > +		return rc;
> > +	}
> > +
> > +	CDEBUG(D_INODE, "FLD lookup got mds #%x for fid=" DFID "\n",
> > +	       mds_idx, PFID(fid));
> > +
> > +	/* find proper MDC device in the array */
> > +	for (i = 0; i < ld->ld_md_tgts_nr; i++) {
> > +		if (ld->ld_md_tgts[i].ldm_mdc &&
> > +		    ld->ld_md_tgts[i].ldm_idx == mds_idx)
> > +			break;
> > +	}
> > +
> > +	if (i == ld->ld_md_tgts_nr) {
> > +		CERROR("%s: cannot find corresponding MDC device for mds #%x for fid=" DFID "\n",
> > +		       lu_dev_name(cl2lu_dev(&ld->ld_cl)), mds_idx, PFID(fid));
> > +		rc = -EINVAL;
> > +	} else {
> > +		*nr = i;
> > +	}
> > +	return rc;
> > +}
> > +
> > +/**
> > + * Implementation of lov_comp_layout_entry_ops::lco_init for DOM object.
> > + *
> > + * Init the DOM object for the first time. It prepares also RAID0 entry
> > + * for it to use in common methods with ordinary RAID0 layout entries.
> > + *
> > + * @env		execution environment
> > + * @dev		LOV device
> > + * @lov		LOV object
> > + * @index	Composite layout entry index in LSM
> > + * @lle		Composite LOV layout entry
> > + */
> > +static int lov_init_dom(const struct lu_env *env, struct lov_device *dev,
> > +			struct lov_object *lov, unsigned int index,
> > +			const struct cl_object_conf *conf,
> > +			struct lov_layout_entry *lle)
> > +{
> > +	struct lov_thread_info *lti = lov_env_info(env);
> > +	struct lov_stripe_md_entry *lsme = lov_lse(lov, index);
> > +	struct cl_object *clo;
> > +	struct lu_object *o = lov2lu(lov);
> > +	const struct lu_fid *fid = lu_object_fid(o);
> > +	struct cl_device *mdcdev;
> > +	struct lov_oinfo *loi = NULL;
> > +	struct cl_object_conf *sconf = &lti->lti_stripe_conf;
> > +	struct inode *inode = conf->coc_inode;
> > +	u32 idx = 0;
> > +	int rc;
> > +
> > +	LASSERT(index == 0);
> > +
> > +	/* find proper MDS device */
> > +	rc = lov_fld_lookup(dev, fid, &idx);
> > +	if (rc)
> > +		return rc;
> > +
> > +	LASSERTF(dev->ld_md_tgts[idx].ldm_mdc,
> > +		 "LOV md target[%u] is NULL\n", idx);
> > +
> > +	/* check lsm is DOM, more checks are needed */
> > +	LASSERT(lsme->lsme_stripe_count == 0);
> > +
> > +	/*
> > +	 * Create lower cl_objects.
> > +	 */
> > +	mdcdev = dev->ld_md_tgts[idx].ldm_mdc;
> > +
> > +	LASSERTF(mdcdev, "non-initialized mdc subdev\n");
> > +
> > +	/* DoM object has no oinfo in LSM entry, create it exclusively */
> > +	loi = kmem_cache_zalloc(lov_oinfo_slab, GFP_NOFS);
> > +	if (!loi)
> > +		return -ENOMEM;
> > +
> > +	fid_to_ostid(lu_object_fid(lov2lu(lov)), &loi->loi_oi);
> > +	/* Initialize lvb structure */
> > +	loi->loi_lvb.lvb_mtime = inode->i_mtime.tv_sec;
> > +	loi->loi_lvb.lvb_atime = inode->i_atime.tv_sec;
> > +	loi->loi_lvb.lvb_ctime = inode->i_ctime.tv_sec;
> > +	loi->loi_lvb.lvb_blocks = inode->i_blocks;
> > +	loi->loi_lvb.lvb_size = i_size_read(inode);
> > +	if (loi->loi_lvb.lvb_size > lsme->lsme_stripe_size)
> > +		loi->loi_lvb.lvb_size = lsme->lsme_stripe_size;
> > +	loi_kms_set(loi, loi->loi_lvb.lvb_size);
> > +
> > +	sconf->u.coc_oinfo = loi;
> > +again:
> > +	clo = lov_sub_find(env, mdcdev, fid, sconf);
> > +	if (IS_ERR(clo)) {
> > +		rc = PTR_ERR(clo);
> > +		goto out;
> > +	}
> > +
> > +	rc = lov_init_sub(env, lov, clo, loi, lov_comp_index(index, 0));
> > +	if (rc == -EAGAIN) /* try again */
> > +		goto again;
> > +	else if (rc != 0)
> > +		goto out;
> > +
> > +	lle->lle_dom.lo_dom = cl2lovsub(clo);
> > +	spin_lock_init(&lle->lle_dom.lo_dom_r0.lo_sub_lock);
> > +	lle->lle_dom.lo_dom_r0.lo_nr = 1;
> > +	lle->lle_dom.lo_dom_r0.lo_sub = &lle->lle_dom.lo_dom;
> > +	lle->lle_dom.lo_loi = loi;
> > +
> > +	rc = lov_page_slice_fixup(lov, clo);
> > +	return rc;
> > +
> > +out:
> > +	kmem_cache_free(lov_oinfo_slab, loi);
> > +	return rc;
> > +}
> > +
> > +/**
> > + * Implementation of lov_layout_operations::llo_fini for DOM object.
> > + *
> > + * Finish the DOM object and free related memory.
> > + *
> > + * @env		execution environment
> > + * @lov		LOV object
> > + * @state	LOV layout state
> > + */
> > +static void lov_fini_dom(const struct lu_env *env,
> > +			 struct lov_layout_entry *lle)
> > +{
> > +	if (lle->lle_dom.lo_dom)
> > +		lle->lle_dom.lo_dom = NULL;
> > +	kmem_cache_free(lov_oinfo_slab, lle->lle_dom.lo_loi);
> > +}
> > +
> > +static struct lov_comp_layout_entry_ops dom_ops = {
> > +	.lco_init	= lov_init_dom,
> > +	.lco_fini	= lov_fini_dom,
> > +	.lco_getattr	= lov_attr_get_dom,
> > +};
> > +
> >  static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
> >  			      struct lov_object *lov, struct lov_stripe_md *lsm,
> >  			      const struct cl_object_conf *conf,
> >  			      union lov_layout_state *state)
> >  {
> >  	struct lov_layout_composite *comp = &state->composite;
> > +	struct lov_layout_entry *lle;
> >  	unsigned int entry_count;
> >  	unsigned int psz = 0;
> >  	int result = 0;
> > @@ -306,24 +624,45 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
> >  	if (!comp->lo_entries)
> >  		return -ENOMEM;
> >  
> > +	/* Initiate all entry types and extents data at first */
> >  	for (i = 0; i < entry_count; i++) {
> > -		struct lov_layout_entry *le = &comp->lo_entries[i];
> > +		lle = &comp->lo_entries[i];
> >  
> > -		le->lle_extent = lsm->lsm_entries[i]->lsme_extent;
> > +		lle->lle_type = lov_entry_type(lsm->lsm_entries[i]);
> > +		switch (lle->lle_type) {
> > +		case LOV_PATTERN_RAID0:
> > +			lle->lle_comp_ops = &raid0_ops;
> > +			break;
> > +		case LOV_PATTERN_MDT:
> > +			lle->lle_comp_ops = &dom_ops;
> > +			break;
> > +		default:
> > +			CERROR("%s: unknown composite layout entry type %i\n",
> > +			       lov2obd(dev->ld_lov)->obd_name,
> > +			       lsm->lsm_entries[i]->lsme_pattern);
> > +			dump_lsm(D_ERROR, lsm);
> > +			return -EIO;
> > +		}
> > +		lle->lle_extent = lsm->lsm_entries[i]->lsme_extent;
> > +	}
> > +
> > +	i = 0;
> > +	lov_foreach_layout_entry(lov, lle) {
> >  		/**
> >  		 * If the component has not been init-ed on MDS side, for
> >  		 * PFL layout, we'd know that the components beyond this one
> >  		 * will be dynamically init-ed later on file write/trunc ops.
> >  		 */
> > -		if (!lsm_entry_inited(lsm, i))
> > -			continue;
> > -
> > -		result = lov_init_raid0(env, dev, lov, i, &le->lle_raid0);
> > -		if (result < 0)
> > -			break;
> > +		if (lsm_entry_inited(lsm, i)) {
> > +			result = lle->lle_comp_ops->lco_init(env, dev, lov, i,
> > +							     conf, lle);
> > +			if (result < 0)
> > +				break;
> >  
> > -		LASSERT(ergo(psz > 0, psz == result));
> > -		psz = result;
> > +			LASSERT(ergo(psz > 0, psz == result));
> > +			psz = result;
> > +		}
> > +		i++;
> >  	}
> >  	if (psz > 0)
> >  		cl_object_header(&lov->lo_cl)->coh_page_bufsize += psz;
> > @@ -331,10 +670,19 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
> >  	return result > 0 ? 0 : result;
> >  }
> >  
> > -static int lov_init_released(const struct lu_env *env, struct lov_device *dev,
> > -			     struct lov_object *lov, struct lov_stripe_md *lsm,
> > +static int lov_init_empty(const struct lu_env *env, struct lov_device *dev,
> > +			  struct lov_object *lov, struct lov_stripe_md *lsm,
> > +			  const struct cl_object_conf *conf,
> > +			  union lov_layout_state *state)
> > +{
> > +	return 0;
> > +}
> > +
> > +static int lov_init_released(const struct lu_env *env,
> > +			     struct lov_device *dev, struct lov_object *lov,
> > +			     struct lov_stripe_md *lsm,
> >  			     const struct cl_object_conf *conf,
> > -			     union  lov_layout_state *state)
> > +			     union lov_layout_state *state)
> >  {
> >  	LASSERT(lsm);
> >  	LASSERT(lsm->lsm_is_released);
> > @@ -344,41 +692,6 @@ static int lov_init_released(const struct lu_env *env, struct lov_device *dev,
> >  	return 0;
> >  }
> >  
> > -static struct cl_object *lov_find_subobj(const struct lu_env *env,
> > -					 struct lov_object *lov,
> > -					 struct lov_stripe_md *lsm,
> > -					 int index)
> > -{
> > -	struct lov_device *dev = lu2lov_dev(lov2lu(lov)->lo_dev);
> > -	struct lov_thread_info *lti = lov_env_info(env);
> > -	struct lu_fid *ofid = &lti->lti_fid;
> > -	int stripe = lov_comp_stripe(index);
> > -	int entry = lov_comp_entry(index);
> > -	struct cl_object *result = NULL;
> > -	struct cl_device *subdev;
> > -	struct lov_oinfo *oinfo;
> > -	int ost_idx;
> > -	int rc;
> > -
> > -	if (lov->lo_type != LLT_COMP)
> > -		goto out;
> > -
> > -	if (entry >= lsm->lsm_entry_count ||
> > -	    stripe >= lsm->lsm_entries[entry]->lsme_stripe_count)
> > -		goto out;
> > -
> > -	oinfo = lsm->lsm_entries[entry]->lsme_oinfo[stripe];
> > -	ost_idx = oinfo->loi_ost_idx;
> > -	rc = ostid_to_fid(ofid, &oinfo->loi_oi, ost_idx);
> > -	if (rc)
> > -		goto out;
> > -
> > -	subdev = lovsub2cl_dev(dev->ld_target[ost_idx]);
> > -	result = lov_sub_find(env, subdev, ofid, NULL);
> > -out:
> > -	return result ? result : ERR_PTR(-EINVAL);
> > -}
> > -
> >  static int lov_delete_empty(const struct lu_env *env, struct lov_object *lov,
> >  			    union lov_layout_state *state)
> >  {
> > @@ -388,75 +701,6 @@ static int lov_delete_empty(const struct lu_env *env, struct lov_object *lov,
> >  	return 0;
> >  }
> >  
> > -static void lov_subobject_kill(const struct lu_env *env, struct lov_object *lov,
> > -			       struct lov_layout_raid0 *r0,
> > -			       struct lovsub_object *los, int idx)
> > -{
> > -	struct cl_object *sub;
> > -	struct lu_site *site;
> > -	wait_queue_head_t *wq;
> > -	wait_queue_entry_t *waiter;
> > -
> > -	LASSERT(r0->lo_sub[idx] == los);
> > -
> > -	sub = lovsub2cl(los);
> > -	site = sub->co_lu.lo_dev->ld_site;
> > -	wq = lu_site_wq_from_fid(site, &sub->co_lu.lo_header->loh_fid);
> > -
> > -	cl_object_kill(env, sub);
> > -	/* release a reference to the sub-object and ... */
> > -	lu_object_ref_del(&sub->co_lu, "lov-parent", lov);
> > -	cl_object_put(env, sub);
> > -
> > -	/* ... wait until it is actually destroyed---sub-object clears its
> > -	 * ->lo_sub[] slot in lovsub_object_fini()
> > -	 */
> > -	if (r0->lo_sub[idx] == los) {
> > -		waiter = &lov_env_info(env)->lti_waiter;
> > -		init_waitqueue_entry(waiter, current);
> > -		add_wait_queue(wq, waiter);
> > -		set_current_state(TASK_UNINTERRUPTIBLE);
> > -		while (1) {
> > -			/* this wait-queue is signaled at the end of
> > -			 * lu_object_free().
> > -			 */
> > -			set_current_state(TASK_UNINTERRUPTIBLE);
> > -			spin_lock(&r0->lo_sub_lock);
> > -			if (r0->lo_sub[idx] == los) {
> > -				spin_unlock(&r0->lo_sub_lock);
> > -				schedule();
> > -			} else {
> > -				spin_unlock(&r0->lo_sub_lock);
> > -				set_current_state(TASK_RUNNING);
> > -				break;
> > -			}
> > -		}
> > -		remove_wait_queue(wq, waiter);
> > -	}
> > -	LASSERT(!r0->lo_sub[idx]);
> > -}
> > -
> > -static void lov_delete_raid0(const struct lu_env *env, struct lov_object *lov,
> > -			     struct lov_layout_raid0 *r0)
> > -{
> > -	if (r0->lo_sub) {
> > -		int i;
> > -
> > -		for (i = 0; i < r0->lo_nr; ++i) {
> > -			struct lovsub_object *los = r0->lo_sub[i];
> > -
> > -			if (los) {
> > -				cl_object_prune(env, &los->lso_cl);
> > -				/*
> > -				 * If top-level object is to be evicted from
> > -				 * the cache, so are its sub-objects.
> > -				 */
> > -				lov_subobject_kill(env, lov, r0, los, i);
> > -			}
> > -		}
> > -	}
> > -}
> > -
> >  static int lov_delete_composite(const struct lu_env *env,
> >  				struct lov_object *lov,
> >  				union lov_layout_state *state)
> > @@ -469,7 +713,7 @@ static int lov_delete_composite(const struct lu_env *env,
> >  	lov_layout_wait(env, lov);
> >  	if (comp->lo_entries)
> >  		lov_foreach_layout_entry(lov, entry)
> > -			lov_delete_raid0(env, lov, &entry->lle_raid0);
> > +			lov_delete_raid0(env, lov, entry);
> >  
> >  	return 0;
> >  }
> > @@ -480,15 +724,6 @@ static void lov_fini_empty(const struct lu_env *env, struct lov_object *lov,
> >  	LASSERT(lov->lo_type == LLT_EMPTY || lov->lo_type == LLT_RELEASED);
> >  }
> >  
> > -static void lov_fini_raid0(const struct lu_env *env,
> > -			   struct lov_layout_raid0 *r0)
> > -{
> > -	if (r0->lo_sub) {
> > -		kvfree(r0->lo_sub);
> > -		r0->lo_sub = NULL;
> > -	}
> > -}
> > -
> >  static void lov_fini_composite(const struct lu_env *env,
> >  			       struct lov_object *lov,
> >  			       union lov_layout_state *state)
> > @@ -499,7 +734,7 @@ static void lov_fini_composite(const struct lu_env *env,
> >  		struct lov_layout_entry *entry;
> >  
> >  		lov_foreach_layout_entry(lov, entry)
> > -			lov_fini_raid0(env, &entry->lle_raid0);
> > +			entry->lle_comp_ops->lco_fini(env, entry);
> >  
> >  		kvfree(comp->lo_entries);
> >  		comp->lo_entries = NULL;
> > @@ -523,24 +758,6 @@ static int lov_print_empty(const struct lu_env *env, void *cookie,
> >  	return 0;
> >  }
> >  
> > -static int lov_print_raid0(const struct lu_env *env, void *cookie,
> > -			   lu_printer_t p, struct lov_layout_raid0 *r0)
> > -{
> > -	int i;
> > -
> > -	for (i = 0; i < r0->lo_nr; ++i) {
> > -		struct lu_object *sub;
> > -
> > -		if (r0->lo_sub[i]) {
> > -			sub = lovsub2lu(r0->lo_sub[i]);
> > -			lu_object_print(env, cookie, p, sub);
> > -		} else {
> > -			(*p)(env, cookie, "sub %d absent\n", i);
> > -		}
> > -	}
> > -	return 0;
> > -}
> > -
> >  static int lov_print_composite(const struct lu_env *env, void *cookie,
> >  			       lu_printer_t p, const struct lu_object *o)
> >  {
> > @@ -556,12 +773,15 @@ static int lov_print_composite(const struct lu_env *env, void *cookie,
> >  
> >  	for (i = 0; i < lsm->lsm_entry_count; i++) {
> >  		struct lov_stripe_md_entry *lse = lsm->lsm_entries[i];
> > +		struct lov_layout_entry *lle = lov_entry(lov, i);
> >  
> > -		(*p)(env, cookie, DEXT ": { 0x%08X, %u, %u, %#x, %u, %u }\n",
> > +		(*p)(env, cookie,
> > +		     DEXT ": { 0x%08X, %u, %#x, %u, %#x, %u, %u }\n",
> >  		     PEXT(&lse->lsme_extent), lse->lsme_magic,
> > -		     lse->lsme_id, lse->lsme_layout_gen, lse->lsme_flags,
> > -		     lse->lsme_stripe_count, lse->lsme_stripe_size);
> > -		lov_print_raid0(env, cookie, p, lov_r0(lov, i));
> > +		     lse->lsme_id, lse->lsme_pattern, lse->lsme_layout_gen,
> > +		     lse->lsme_flags, lse->lsme_stripe_count,
> > +		     lse->lsme_stripe_size);
> > +		lov_print_raid0(env, cookie, p, lle);
> >  	}
> >  
> >  	return 0;
> > @@ -595,52 +815,6 @@ static int lov_attr_get_empty(const struct lu_env *env, struct cl_object *obj,
> >  	return 0;
> >  }
> >  
> > -static int lov_attr_get_raid0(const struct lu_env *env, struct lov_object *lov,
> > -			      unsigned int index, struct lov_layout_raid0 *r0)
> > -{
> > -	struct lov_stripe_md *lsm = lov->lo_lsm;
> > -	struct ost_lvb *lvb = &lov_env_info(env)->lti_lvb;
> > -	struct cl_attr *attr = &r0->lo_attr;
> > -	int result = 0;
> > -	u64 kms = 0;
> > -
> > -	if (r0->lo_attr_valid)
> > -		return 0;
> > -
> > -	memset(lvb, 0, sizeof(*lvb));
> > -
> > -	/* XXX: timestamps can be negative by sanity:test_39m,
> > -	 * how can it be?
> > -	 */
> > -	lvb->lvb_atime = LLONG_MIN;
> > -	lvb->lvb_ctime = LLONG_MIN;
> > -	lvb->lvb_mtime = LLONG_MIN;
> > -
> > -	/*
> > -	 * XXX that should be replaced with a loop over sub-objects,
> > -	 * doing cl_object_attr_get() on them. But for now, let's
> > -	 * reuse old lov code.
> > -	 */
> > -
> > -	/*
> > -	 * XXX take lsm spin-lock to keep lov_merge_lvb_kms()
> > -	 * happy. It's not needed, because new code uses
> > -	 * ->coh_attr_guard spin-lock to protect consistency of
> > -	 * sub-object attributes.
> > -	 */
> > -	lov_stripe_lock(lsm);
> > -	result = lov_merge_lvb_kms(lsm, index, lvb, &kms);
> > -	lov_stripe_unlock(lsm);
> > -	if (result)
> > -		return result;
> > -
> > -	cl_lvb2attr(attr, lvb);
> > -	attr->cat_kms = kms;
> > -	r0->lo_attr_valid = 1;
> > -
> > -	return result;
> > -}
> > -
> >  static int lov_attr_get_composite(const struct lu_env *env,
> >  				  struct cl_object *obj,
> >  				  struct cl_attr *attr)
> > @@ -653,19 +827,22 @@ static int lov_attr_get_composite(const struct lu_env *env,
> >  	attr->cat_size = 0;
> >  	attr->cat_blocks = 0;
> >  	lov_foreach_layout_entry(lov, entry) {
> > -		struct lov_layout_raid0 *r0 = &entry->lle_raid0;
> > -		struct cl_attr *lov_attr = &r0->lo_attr;
> > +		struct cl_attr *lov_attr = NULL;
> >  
> >  		/* PFL: This component has not been init-ed. */
> >  		if (!lsm_entry_inited(lov->lo_lsm, index))
> >  			break;
> >  
> > -		result = lov_attr_get_raid0(env, lov, index, r0);
> > -		if (result != 0)
> > -			break;
> > +		result = entry->lle_comp_ops->lco_getattr(env, lov, index,
> > +							  entry, &lov_attr);
> > +		if (result < 0)
> > +			return result;
> >  
> >  		index++;
> >  
> > +		if (!lov_attr)
> > +			continue;
> > +
> >  		/* merge results */
> >  		attr->cat_blocks += lov_attr->cat_blocks;
> >  		if (attr->cat_size < lov_attr->cat_size)
> > @@ -679,7 +856,7 @@ static int lov_attr_get_composite(const struct lu_env *env,
> >  		if (attr->cat_mtime < lov_attr->cat_mtime)
> >  			attr->cat_mtime = lov_attr->cat_mtime;
> >  	}
> > -	return result;
> > +	return 0;
> >  }
> >  
> >  static const struct lov_layout_operations lov_dispatch[] = {
> > @@ -1235,6 +1412,49 @@ struct fiemap_state {
> >  	bool			fs_enough;
> >  };
> >  
> > +static struct cl_object *lov_find_subobj(const struct lu_env *env,
> > +					 struct lov_object *lov,
> > +					 struct lov_stripe_md *lsm,
> > +					 int index)
> > +{
> > +	struct lov_device *dev = lu2lov_dev(lov2lu(lov)->lo_dev);
> > +	struct lov_thread_info *lti = lov_env_info(env);
> > +	struct lu_fid *ofid = &lti->lti_fid;
> > +	struct lov_oinfo *oinfo;
> > +	struct cl_device *subdev;
> > +	int entry = lov_comp_entry(index);
> > +	int stripe = lov_comp_stripe(index);
> > +	int ost_idx;
> > +	int rc;
> > +	struct cl_object *result;
> > +
> > +	if (lov->lo_type != LLT_COMP) {
> > +		result = NULL;
> > +		goto out;
> > +	}
> > +
> > +	if (entry >= lsm->lsm_entry_count ||
> > +	    stripe >= lsm->lsm_entries[entry]->lsme_stripe_count) {
> > +		result = NULL;
> > +		goto out;
> > +	}
> > +
> > +	oinfo = lsm->lsm_entries[entry]->lsme_oinfo[stripe];
> > +	ost_idx = oinfo->loi_ost_idx;
> > +	rc = ostid_to_fid(ofid, &oinfo->loi_oi, ost_idx);
> > +	if (rc != 0) {
> > +		result = NULL;
> > +		goto out;
> > +	}
> > +
> > +	subdev = lovsub2cl_dev(dev->ld_target[ost_idx]);
> > +	result = lov_sub_find(env, subdev, ofid, NULL);
> > +out:
> > +	if (!result)
> > +		result = ERR_PTR(-EINVAL);
> > +	return result;
> > +}
> > +
> >  static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
> >  			     struct lov_stripe_md *lsm, struct fiemap *fiemap,
> >  			     size_t *buflen, struct ll_fiemap_info_key *fmkey,
> > @@ -1457,6 +1677,12 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
> >  		}
> >  	}
> >  
> > +	/* No support for DOM layout yet. */
> > +	if (lsme_is_dom(lsm->lsm_entries[0])) {
> > +		rc = -ENOTSUPP;
> > +		goto out_lsm;
> > +	}
> > +
> >  	if (lsm->lsm_is_released) {
> >  		if (fiemap->fm_start < fmkey->lfik_oa.o_size) {
> >  			/**
> > diff --git a/fs/lustre/lov/lov_offset.c b/fs/lustre/lov/lov_offset.c
> > index 26f5066..56a2d7b 100644
> > --- a/fs/lustre/lov/lov_offset.c
> > +++ b/fs/lustre/lov/lov_offset.c
> > @@ -43,6 +43,9 @@ static u64 stripe_width(struct lov_stripe_md *lsm, unsigned int index)
> >  
> >  	LASSERT(index < lsm->lsm_entry_count);
> >  
> > +	if (lsme_is_dom(entry))
> > +		return (loff_t)entry->lsme_stripe_size;
> > +
> >  	return entry->lsme_stripe_size * entry->lsme_stripe_count;
> >  }
> >  
> > diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
> > index 1103c15..eefaf44 100644
> > --- a/fs/lustre/mdc/mdc_request.c
> > +++ b/fs/lustre/mdc/mdc_request.c
> > @@ -2265,7 +2265,12 @@ static int mdc_set_info_async(const struct lu_env *env,
> >  		return 0;
> >  	}
> >  
> > -	CERROR("Unknown key %s\n", (char *)key);
> > +	/* TODO: these OSC-related keys are ignored for now */
> > +	if (KEY_IS(KEY_CHECKSUM) || KEY_IS(KEY_CACHE_SET) ||
> > +	    KEY_IS(KEY_CACHE_LRU_SHRINK) || KEY_IS(KEY_GRANT_SHRINK))
> > +		return 0;
> > +
> > +	CERROR("%s: Unknown key %s\n", exp->exp_obd->obd_name, (char *)key);
> >  	return -EINVAL;
> >  }
> >  
> > diff --git a/fs/lustre/obdclass/obd_config.c b/fs/lustre/obdclass/obd_config.c
> > index 73264fd..26b3e01 100644
> > --- a/fs/lustre/obdclass/obd_config.c
> > +++ b/fs/lustre/obdclass/obd_config.c
> > @@ -972,7 +972,6 @@ int class_process_config(struct lustre_cfg *lcfg)
> >  		err = -EINVAL;
> >  		goto out;
> >  	}
> > -
> >  	switch (lcfg->lcfg_command) {
> >  	case LCFG_SETUP: {
> >  		err = class_setup(obd, lcfg);
> > @@ -1020,6 +1019,41 @@ int class_process_config(struct lustre_cfg *lcfg)
> >  		err = 0;
> >  		goto out;
> >  	}
> > +	/* Process config log ADD_MDC record twice to add MDC also to LOV
> > +	 * for Data-on-MDT:
> > +	 *
> > +	 * add 0:lustre-clilmv 1:lustre-MDT0000_UUID 2:0 3:1
> > +	 *     4:lustre-MDT0000-mdc_UUID
> > +	 */
> > +	case LCFG_ADD_MDC: {
> > +		struct obd_device *lov_obd;
> > +		char *clilmv;
> > +
> > +		err = obd_process_config(obd, sizeof(*lcfg), lcfg);
> > +		if (err)
> > +			goto out;
> > +
> > +		/* make sure this is client LMV log entry */
> > +		clilmv = strstr(lustre_cfg_string(lcfg, 0), "clilmv");
> > +		if (!clilmv)
> > +			goto out;
> > +
> > +		/* replace 'lmv' with 'lov' name to address LOV device and
> > +		 * process llog record to add MDC there.
> > +		 */
> > +		clilmv[4] = 'o';
> > +		lov_obd = class_name2obd(lustre_cfg_string(lcfg, 0));
> > +		if (!lov_obd) {
> > +			err = -ENOENT;
> > +			CERROR("%s: Cannot find LOV by %s name, rc = %d\n",
> > +			       obd->obd_name, lustre_cfg_string(lcfg, 0), err);
> > +		} else {
> > +			err = obd_process_config(lov_obd, sizeof(*lcfg), lcfg);
> > +		}
> > +		/* restore 'lmv' name */
> > +		clilmv[4] = 'm';
> > +		goto out;
> > +	}
> >  	default: {
> >  		err = obd_process_config(obd, sizeof(*lcfg), lcfg);
> >  		goto out;
> > diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
> > index eb8bffe..2a38d1e 100644
> > --- a/fs/lustre/ptlrpc/wiretest.c
> > +++ b/fs/lustre/ptlrpc/wiretest.c
> > @@ -1479,8 +1479,8 @@ void lustre_assert_wire_constants(void)
> >  		 (unsigned int)LOV_PATTERN_RAID0);
> >  	LASSERTF(LOV_PATTERN_RAID1 == 0x00000002UL, "found 0x%.8xUL\n",
> >  		 (unsigned int)LOV_PATTERN_RAID1);
> > -	LASSERTF(LOV_PATTERN_FIRST == 0x00000100UL, "found 0x%.8xUL\n",
> > -		 (unsigned int)LOV_PATTERN_FIRST);
> > +	LASSERTF(LOV_PATTERN_MDT == 0x00000100UL, "found 0x%.8xUL\n",
> > +		 (unsigned int)LOV_PATTERN_MDT);
> >  	LASSERTF(LOV_PATTERN_CMOBD == 0x00000200UL, "found 0x%.8xUL\n",
> >  		 (unsigned int)LOV_PATTERN_CMOBD);
> >  
> > diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
> > index 17bad49..4a6ed5e 100644
> > --- a/include/uapi/linux/lustre/lustre_user.h
> > +++ b/include/uapi/linux/lustre/lustre_user.h
> > @@ -337,7 +337,7 @@ enum ll_lease_type {
> >  
> >  #define LOV_PATTERN_RAID0	0x001
> >  #define LOV_PATTERN_RAID1	0x002
> > -#define LOV_PATTERN_FIRST	0x100
> > +#define LOV_PATTERN_MDT		0x100
> >  #define LOV_PATTERN_CMOBD	0x200
> >  
> >  #define LOV_PATTERN_F_MASK	0xffff0000
> > -- 
> > 1.8.3.1
> 
