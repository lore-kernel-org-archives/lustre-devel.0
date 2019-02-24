From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Feb 2019 16:56:13 +0000 (GMT)
Subject: [lustre-devel] [PATCH 05/37] lustre: obd_type: use
 typ_kobj.name as typ_name
In-Reply-To: <155053494507.24125.1847979512182217144.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494507.24125.1847979512182217144.stgit@noble.brown>
Message-ID: <alpine.LFD.2.21.1902241656020.22752@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> As the kobject has a name (after kobject_add has been called),
> we don't need to also store it in typ_name.
> So use typ_kobj.name instead of typ_name.
> 
> This requires changing some "char *" to "const char *" as
> typ.kobj.name is const.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/include/lustre_net.h |    4 ++-
>  drivers/staging/lustre/lustre/include/obd.h        |    2 +-
>  drivers/staging/lustre/lustre/include/obd_class.h  |    2 +-
>  drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |    2 +-
>  drivers/staging/lustre/lustre/obdclass/genops.c    |   25 ++++++++------------
>  drivers/staging/lustre/lustre/ptlrpc/client.c      |    2 +-
>  6 files changed, 16 insertions(+), 21 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
> index 47b9632e5660..f3b6ba061eed 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_net.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_net.h
> @@ -308,7 +308,7 @@ struct ptlrpc_client {
>  	/** What portal do we expect replies on */
>  	u32			cli_reply_portal;
>  	/** Name of the client */
> -	char			*cli_name;
> +	const char		*cli_name;
>  };
>  
>  /** state flags of requests */
> @@ -1817,7 +1817,7 @@ void ptlrpc_request_committed(struct ptlrpc_request *req, int force);
>  int ptlrpc_inc_ref(void);
>  void ptlrpc_dec_ref(void);
>  
> -void ptlrpc_init_client(int req_portal, int rep_portal, char *name,
> +void ptlrpc_init_client(int req_portal, int rep_portal, const char *name,
>  			struct ptlrpc_client *);
>  struct ptlrpc_connection *ptlrpc_uuid_to_connection(struct obd_uuid *uuid,
>  						    lnet_nid_t nid4refnet);
> diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
> index b161542855fc..3aa9cc889949 100644
> --- a/drivers/staging/lustre/lustre/include/obd.h
> +++ b/drivers/staging/lustre/lustre/include/obd.h
> @@ -103,12 +103,12 @@ struct obd_type {
>  	struct obd_ops		*typ_dt_ops;
>  	struct md_ops		*typ_md_ops;
>  	struct dentry		*typ_debugfs_entry;
> -	char			*typ_name;
>  	int			 typ_refcnt;
>  	struct lu_device_type	*typ_lu;
>  	spinlock_t		 obd_type_lock;
>  	struct kobject		 typ_kobj;
>  };
> +#define typ_name typ_kobj.name
>  
>  struct brw_page {
>  	u64			off;
> diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
> index e4695f5b748d..a61c7950393c 100644
> --- a/drivers/staging/lustre/lustre/include/obd_class.h
> +++ b/drivers/staging/lustre/lustre/include/obd_class.h
> @@ -74,7 +74,7 @@ int class_name2dev(const char *name);
>  struct obd_device *class_name2obd(const char *name);
>  int class_uuid2dev(struct obd_uuid *uuid);
>  struct obd_device *class_find_client_obd(struct obd_uuid *tgt_uuid,
> -					 const char *typ_name,
> +					 const char *type_name,
>  					 struct obd_uuid *grp_uuid);
>  struct obd_device *class_devices_in_group(struct obd_uuid *grp_uuid,
>  					  int *next);
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
> index aef83ffc8bb3..ac0fbb24fc92 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
> @@ -247,7 +247,7 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
>  	struct obd_import *imp;
>  	struct obd_uuid server_uuid;
>  	int rq_portal, rp_portal, connect_op;
> -	char *name = obddev->obd_type->typ_name;
> +	const char *name = obddev->obd_type->typ_name;
>  	enum ldlm_ns_type ns_type = LDLM_NS_TYPE_UNKNOWN;
>  	struct ptlrpc_connection fake_conn = {
>  		.c_self = 0,
> diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
> index 4c0dc2098823..32581f1a92ac 100644
> --- a/drivers/staging/lustre/lustre/obdclass/genops.c
> +++ b/drivers/staging/lustre/lustre/obdclass/genops.c
> @@ -147,7 +147,6 @@ static void class_sysfs_release(struct kobject *kobj)
>  	list_del(&type->typ_chain);
>  	spin_unlock(&obd_types_lock);
>  
> -	kfree(type->typ_name);
>  	kfree(type->typ_md_ops);
>  	kfree(type->typ_dt_ops);
>  	kfree(type);
> @@ -186,28 +185,24 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
>  
>  	type->typ_dt_ops = kzalloc(sizeof(*type->typ_dt_ops), GFP_NOFS);
>  	type->typ_md_ops = kzalloc(sizeof(*type->typ_md_ops), GFP_NOFS);
> -	type->typ_name = kzalloc(strlen(name) + 1, GFP_NOFS);
>  
>  	if (!type->typ_dt_ops ||
> -	    !type->typ_md_ops ||
> -	    !type->typ_name)
> +	    !type->typ_md_ops)
>  		goto failed;
>  
>  	*type->typ_dt_ops = *dt_ops;
>  	/* md_ops is optional */
>  	if (md_ops)
>  		*type->typ_md_ops = *md_ops;
> -	strcpy(type->typ_name, name);
>  	spin_lock_init(&type->obd_type_lock);
>  
> -	type->typ_debugfs_entry = debugfs_create_dir(type->typ_name,
> -						     debugfs_lustre_root);
> -
>  	rc = kobject_add(&type->typ_kobj, &lustre_kset->kobj, "%s", name);
> -
>  	if (rc)
>  		goto failed;
>  
> +	type->typ_debugfs_entry = debugfs_create_dir(type->typ_name,
> +						     debugfs_lustre_root);
> +
>  	if (ldt) {
>  		type->typ_lu = ldt;
>  		rc = lu_device_type_init(ldt);
> @@ -534,7 +529,7 @@ struct obd_device *class_num2obd(int num)
>   * otherwise any client connected to the tgt is returned.
>   */
>  struct obd_device *class_find_client_obd(struct obd_uuid *tgt_uuid,
> -					 const char *typ_name,
> +					 const char *type_name,
>  					 struct obd_uuid *grp_uuid)
>  {
>  	int i;
> @@ -545,8 +540,8 @@ struct obd_device *class_find_client_obd(struct obd_uuid *tgt_uuid,
>  
>  		if (!obd)
>  			continue;
> -		if ((strncmp(obd->obd_type->typ_name, typ_name,
> -			     strlen(typ_name)) == 0)) {
> +		if ((strncmp(obd->obd_type->typ_name, type_name,
> +			     strlen(type_name)) == 0)) {
>  			if (obd_uuid_equals(tgt_uuid,
>  					    &obd->u.cli.cl_target_uuid) &&
>  			    ((grp_uuid) ? obd_uuid_equals(grp_uuid,
> @@ -1358,7 +1353,7 @@ EXPORT_SYMBOL(obd_get_max_rpcs_in_flight);
>  int obd_set_max_rpcs_in_flight(struct client_obd *cli, u32 max)
>  {
>  	struct obd_request_slot_waiter *orsw;
> -	const char *typ_name;
> +	const char *type_name;
>  	u32 old;
>  	int diff;
>  	int rc;
> @@ -1367,8 +1362,8 @@ int obd_set_max_rpcs_in_flight(struct client_obd *cli, u32 max)
>  	if (max > OBD_MAX_RIF_MAX || max < 1)
>  		return -ERANGE;
>  
> -	typ_name = cli->cl_import->imp_obd->obd_type->typ_name;
> -	if (!strcmp(typ_name, LUSTRE_MDC_NAME)) {
> +	type_name = cli->cl_import->imp_obd->obd_type->typ_name;
> +	if (!strcmp(type_name, LUSTRE_MDC_NAME)) {
>  		/*
>  		 * adjust max_mod_rpcs_in_flight to ensure it is always
>  		 * strictly lower that max_rpcs_in_flight
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
> index b2b11047ea19..0a76a8549fac 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/client.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
> @@ -67,7 +67,7 @@ static int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async);
>  /**
>   * Initialize passed in client structure \a cl.
>   */
> -void ptlrpc_init_client(int req_portal, int rep_portal, char *name,
> +void ptlrpc_init_client(int req_portal, int rep_portal, const char *name,
>  			struct ptlrpc_client *cl)
>  {
>  	cl->cli_request_portal = req_portal;
> 
> 
> 
