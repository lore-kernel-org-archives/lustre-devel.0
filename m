From: NeilBrown <neilb@suse.com>
Date: Mon, 24 Sep 2018 14:47:50 +1000
Subject: [lustre-devel] [PATCH 4/8] lustre: obdclass: cleanup
 obd_class.h defines
In-Reply-To: <920C9E0E-A2EB-483E-ACB8-0AE680C02CD6@cray.com>
References: <1537205481-6899-1-git-send-email-jsimmons@infradead.org>
 <1537205481-6899-5-git-send-email-jsimmons@infradead.org>
 <920C9E0E-A2EB-483E-ACB8-0AE680C02CD6@cray.com>
Message-ID: <87o9cn4i2x.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Sep 18 2018, Alexey Lyashkov wrote:

> NAK.
> Please use same as original patch 
> ' struct niobuf_local *local, int orig_rc' vs ' struct niobuf_local *local, const int orig_rc'.
>

I've added the "const" and appled the patch.  Thanks.

NeilBrown


>
>
> ?On 17/09/2018, 20:31, "James Simmons" <jsimmons@infradead.org> wrote:
>
>     From: Ben Evans <bevans@cray.com>
>     
>     Get rid of OBT and CTXTP defines.
>     Remove OBD_CHECK_DT_OP
>     Convert EXP_CHECK_MD_OP into a function.
>     Remove CTXT_CHECK_OP.
>     
>     Signed-off-by: Ben Evans <bevans@cray.com>
>     Signed-off-by: Alexey Lyashkov <c17817@cray.com>
>     WC-bug-id: https://jira.whamcloud.com/browse/LU-9855
>     Reviewed-on: https://review.whamcloud.com/29286
>     WC-bug-id: https://jira.whamcloud.com/browse/LU-11169
>     Reviewed-on: https://review.whamcloud.com/#/c/32906
>     Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
>     Reviewed-by: Steve Guminski <stephenx.guminski@intel.com>
>     Reviewed-by: James Simmons <uja.ornl@yahoo.com>
>     Reviewed-by: Oleg Drokin <green@whamcloud.com>
>     Signed-off-by: James Simmons <jsimmons@infradead.org>
>     ---
>      drivers/staging/lustre/lustre/include/obd_class.h | 437 +++++++++++++++-------
>      drivers/staging/lustre/lustre/obdclass/llog_obd.c |   4 +-
>      2 files changed, 311 insertions(+), 130 deletions(-)
>     
>     diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
>     index c6fb2e1..aab1092 100644
>     --- a/drivers/staging/lustre/lustre/include/obd_class.h
>     +++ b/drivers/staging/lustre/lustre/include/obd_class.h
>     @@ -303,10 +303,8 @@ static inline int lprocfs_climp_check(struct obd_device *obd)
>      
>      void obdo_to_ioobj(const struct obdo *oa, struct obd_ioobj *ioobj);
>      
>     -#define OBT(dev)	((dev)->obd_type)
>      #define OBP(dev, op)    ((dev)->obd_type->typ_dt_ops->op)
>      #define MDP(dev, op)    ((dev)->obd_type->typ_md_ops->op)
>     -#define CTXTP(ctxt, op) ((ctxt)->loc_logops->lop_##op)
>      
>      /*
>       * Ensure obd_setup: used for cleanup which must be called
>     @@ -393,56 +391,16 @@ static inline int obd_check_dev_active(struct obd_device *obd)
>      	}								    \
>      } while (0)
>      
>     -#define EXP_CHECK_MD_OP(exp, op)				\
>     -do {								\
>     -	if (!(exp)) {						\
>     -		CERROR("obd_" #op ": NULL export\n");		\
>     -		return -ENODEV;					\
>     -	}							\
>     -	if (!(exp)->exp_obd || !OBT((exp)->exp_obd)) {		\
>     -		CERROR("obd_" #op ": cleaned up obd\n");	\
>     -		return -EOPNOTSUPP;				\
>     -	}							\
>     -	if (!OBT((exp)->exp_obd) || !MDP((exp)->exp_obd, op)) {	\
>     -		CERROR("%s: obd_" #op ": dev %d no operation\n",\
>     -			(exp)->exp_obd->obd_name,		\
>     -			(exp)->exp_obd->obd_minor);		\
>     -		return -EOPNOTSUPP;				\
>     -	}							\
>     -} while (0)
>     -
>     -#define OBD_CHECK_DT_OP(obd, op, err)					\
>     -do {									\
>     -	if (!OBT(obd) || !OBP((obd), op)) {				\
>     -		if (err)						\
>     -			CERROR("%s: no obd_" #op " operation\n",	\
>     -				obd->obd_name);				\
>     -		return err;						\
>     -	}								\
>     -} while (0)
>     +static inline int exp_check_ops(struct obd_export *exp)
>     +{
>     +	if (!exp)
>     +		return -ENODEV;
>      
>     -#define EXP_CHECK_DT_OP(exp, op)				\
>     -do {								\
>     -	if (!(exp)) {						\
>     -		CERROR("obd_" #op ": NULL export\n");		\
>     -		return -ENODEV;					\
>     -	}							\
>     -	if (!(exp)->exp_obd || !OBT((exp)->exp_obd)) {		\
>     -		CERROR("obd_" #op ": cleaned up obd\n");	\
>     -		return -EOPNOTSUPP;				\
>     -	}							\
>     -	OBD_CHECK_DT_OP((exp)->exp_obd, op, -EOPNOTSUPP);	\
>     -} while (0)
>     +	if (!exp->exp_obd || !exp->exp_obd->obd_type)
>     +		return -EOPNOTSUPP;
>      
>     -#define CTXT_CHECK_OP(ctxt, op, err)					\
>     -do {									\
>     -	if (!OBT(ctxt->loc_obd) || !CTXTP((ctxt), op)) {		\
>     -		if (err)						\
>     -			CERROR("%s: no lop_" #op " operation\n",	\
>     -				ctxt->loc_obd->obd_name);		\
>     -		return err;						\
>     -	}								\
>     -} while (0)
>     +	return 0;
>     +}
>      
>      static inline int class_devno_max(void)
>      {
>     @@ -455,7 +413,15 @@ static inline int obd_get_info(const struct lu_env *env,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_DT_OP(exp, get_info);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>     +
>     +	if (!exp->exp_obd->obd_type->typ_dt_ops->get_info) {
>     +		CERROR("%s: no %s operation\n",
>     +		       exp->exp_obd->obd_name, __func__);
>     +		return -ENOTSUPP;
>     +	}
>      	EXP_COUNTER_INCREMENT(exp, get_info);
>      
>      	rc = OBP(exp->exp_obd, get_info)(env, exp, keylen, key, vallen, val);
>     @@ -469,7 +435,15 @@ static inline int obd_set_info_async(const struct lu_env *env,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_DT_OP(exp, set_info_async);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>     +
>     +	if (!exp->exp_obd->obd_type->typ_dt_ops->set_info_async) {
>     +		CERROR("%s: no %s operation\n",
>     +		       exp->exp_obd->obd_name, __func__);
>     +		return -ENOTSUPP;
>     +	}
>      	EXP_COUNTER_INCREMENT(exp, set_info_async);
>      
>      	rc = OBP(exp->exp_obd, set_info_async)(env, exp, keylen, key, vallen,
>     @@ -484,14 +458,14 @@ static inline int obd_set_info_async(const struct lu_env *env,
>       * pieces of configuration process are still based on obd devices.
>       *
>       * Specifically, lu_device_type_operations::ldto_device_alloc() methods fully
>     - * subsume ->o_setup() methods of obd devices they replace. The same for
>     - * lu_device_operations::ldo_process_config() and ->o_process_config(). As a
>     + * subsume ->setup() methods of obd devices they replace. The same for
>     + * lu_device_operations::ldo_process_config() and ->process_config(). As a
>       * result, obd_setup() and obd_process_config() branch and call one XOR
>       * another.
>       *
>       * Yet neither lu_device_type_operations::ldto_device_fini() nor
>       * lu_device_type_operations::ldto_device_free() fully implement the
>     - * functionality of ->o_precleanup() and ->o_cleanup() they override. Hence,
>     + * functionality of ->precleanup() and ->o_cleanup() they override. Hence,
>       * obd_precleanup() and obd_cleanup() call both lu_device and obd operations.
>       */
>      
>     @@ -527,7 +501,11 @@ static inline int obd_setup(struct obd_device *obd, struct lustre_cfg *cfg)
>      		lu_context_fini(&session_ctx);
>      
>      	} else {
>     -		OBD_CHECK_DT_OP(obd, setup, -EOPNOTSUPP);
>     +		if (!obd->obd_type->typ_dt_ops->setup) {
>     +			CERROR("%s: no %s operation\n", obd->obd_name,
>     +			       __func__);
>     +			return -EOPNOTSUPP;
>     +		}
>      		OBD_COUNTER_INCREMENT(obd, setup);
>      		rc = OBP(obd, setup)(obd, cfg);
>      	}
>     @@ -549,7 +527,9 @@ static inline int obd_precleanup(struct obd_device *obd)
>      			lu_env_fini(&env);
>      		}
>      	}
>     -	OBD_CHECK_DT_OP(obd, precleanup, 0);
>     +	if (!obd->obd_type->typ_dt_ops->precleanup)
>     +		return 0;
>     +
>      	OBD_COUNTER_INCREMENT(obd, precleanup);
>      
>      	rc = OBP(obd, precleanup)(obd);
>     @@ -572,7 +552,9 @@ static inline int obd_cleanup(struct obd_device *obd)
>      			obd->obd_lu_dev = NULL;
>      		}
>      	}
>     -	OBD_CHECK_DT_OP(obd, cleanup, 0);
>     +	if (!obd->obd_type->typ_dt_ops->cleanup)
>     +		return 0;
>     +
>      	OBD_COUNTER_INCREMENT(obd, cleanup);
>      
>      	rc = OBP(obd, cleanup)(obd);
>     @@ -599,8 +581,8 @@ static inline void obd_cleanup_client_import(struct obd_device *obd)
>      	up_write(&obd->u.cli.cl_sem);
>      }
>      
>     -static inline int
>     -obd_process_config(struct obd_device *obd, int datalen, void *data)
>     +static inline int obd_process_config(struct obd_device *obd, int datalen,
>     +				     void *data)
>      {
>      	struct lu_device_type *ldt = obd->obd_type->typ_lu;
>      	struct lu_device *d = obd->obd_lu_dev;
>     @@ -616,7 +598,11 @@ static inline void obd_cleanup_client_import(struct obd_device *obd)
>      			lu_env_fini(&env);
>      		}
>      	} else {
>     -		OBD_CHECK_DT_OP(obd, process_config, -EOPNOTSUPP);
>     +		if (!obd->obd_type->typ_dt_ops->process_config) {
>     +			CERROR("%s: no %s operation\n",
>     +			       obd->obd_name, __func__);
>     +			return -EOPNOTSUPP;
>     +		}
>      		rc = OBP(obd, process_config)(obd, datalen, data);
>      	}
>      	OBD_COUNTER_INCREMENT(obd, process_config);
>     @@ -630,7 +616,15 @@ static inline int obd_create(const struct lu_env *env, struct obd_export *exp,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_DT_OP(exp, create);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>     +
>     +	if (!exp->exp_obd->obd_type->typ_dt_ops->create) {
>     +		CERROR("%s: no %s operation\n",
>     +		       exp->exp_obd->obd_name, __func__);
>     +		return -EOPNOTSUPP;
>     +	}
>      	EXP_COUNTER_INCREMENT(exp, create);
>      
>      	rc = OBP(exp->exp_obd, create)(env, exp, obdo);
>     @@ -642,7 +636,15 @@ static inline int obd_destroy(const struct lu_env *env, struct obd_export *exp,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_DT_OP(exp, destroy);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>     +
>     +	if (!exp->exp_obd->obd_type->typ_dt_ops->destroy) {
>     +		CERROR("%s: no %s operation\n",
>     +		       exp->exp_obd->obd_name, __func__);
>     +		return -EOPNOTSUPP;
>     +	}
>      	EXP_COUNTER_INCREMENT(exp, destroy);
>      
>      	rc = OBP(exp->exp_obd, destroy)(env, exp, obdo);
>     @@ -654,7 +656,15 @@ static inline int obd_getattr(const struct lu_env *env, struct obd_export *exp,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_DT_OP(exp, getattr);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>     +
>     +	if (!exp->exp_obd->obd_type->typ_dt_ops->getattr) {
>     +		CERROR("%s: no %s operation\n",
>     +		       exp->exp_obd->obd_name, __func__);
>     +		return -EOPNOTSUPP;
>     +	}
>      	EXP_COUNTER_INCREMENT(exp, getattr);
>      
>      	rc = OBP(exp->exp_obd, getattr)(env, exp, oa);
>     @@ -666,7 +676,15 @@ static inline int obd_setattr(const struct lu_env *env, struct obd_export *exp,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_DT_OP(exp, setattr);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>     +
>     +	if (!exp->exp_obd->obd_type->typ_dt_ops->setattr) {
>     +		CERROR("%s: no %s operation\n",
>     +		       exp->exp_obd->obd_name, __func__);
>     +		return -EOPNOTSUPP;
>     +	}
>      	EXP_COUNTER_INCREMENT(exp, setattr);
>      
>      	rc = OBP(exp->exp_obd, setattr)(env, exp, oa);
>     @@ -682,7 +700,11 @@ static inline int obd_add_conn(struct obd_import *imp, struct obd_uuid *uuid,
>      	rc = obd_check_dev_active(obd);
>      	if (rc)
>      		return rc;
>     -	OBD_CHECK_DT_OP(obd, add_conn, -EOPNOTSUPP);
>     +
>     +	if (!obd->obd_type || !obd->obd_type->typ_dt_ops->add_conn) {
>     +		CERROR("%s: no %s operation\n", obd->obd_name, __func__);
>     +		return -EOPNOTSUPP;
>     +	}
>      	OBD_COUNTER_INCREMENT(obd, add_conn);
>      
>      	rc = OBP(obd, add_conn)(imp, uuid, priority);
>     @@ -697,7 +719,11 @@ static inline int obd_del_conn(struct obd_import *imp, struct obd_uuid *uuid)
>      	rc = obd_check_dev_active(obd);
>      	if (rc)
>      		return rc;
>     -	OBD_CHECK_DT_OP(obd, del_conn, -EOPNOTSUPP);
>     +
>     +	if (!obd->obd_type || !obd->obd_type->typ_dt_ops->del_conn) {
>     +		CERROR("%s: no %s operation\n", obd->obd_name, __func__);
>     +		return -EOPNOTSUPP;
>     +	}
>      	OBD_COUNTER_INCREMENT(obd, del_conn);
>      
>      	rc = OBP(obd, del_conn)(imp, uuid);
>     @@ -708,7 +734,10 @@ static inline struct obd_uuid *obd_get_uuid(struct obd_export *exp)
>      {
>      	struct obd_uuid *uuid;
>      
>     -	OBD_CHECK_DT_OP(exp->exp_obd, get_uuid, NULL);
>     +	if (!exp->exp_obd->obd_type ||
>     +	    !exp->exp_obd->obd_type->typ_dt_ops->get_uuid)
>     +		return NULL;
>     +
>      	EXP_COUNTER_INCREMENT(exp, get_uuid);
>      
>      	uuid = OBP(exp->exp_obd, get_uuid)(exp);
>     @@ -727,16 +756,18 @@ static inline int obd_connect(const struct lu_env *env,
>      			      struct obd_connect_data *data,
>      			      void *localdata)
>      {
>     +	/* for post-condition check */
>     +	u64 ocf = data ? data->ocd_connect_flags : 0;
>      	int rc;
>     -	__u64 ocf = data ? data->ocd_connect_flags : 0; /*
>     -							 * for post-condition
>     -							 * check
>     -							 */
>      
>      	rc = obd_check_dev_active(obd);
>      	if (rc)
>      		return rc;
>     -	OBD_CHECK_DT_OP(obd, connect, -EOPNOTSUPP);
>     +
>     +	if (!obd->obd_type || !obd->obd_type->typ_dt_ops->connect) {
>     +		CERROR("%s: no %s operation\n", obd->obd_name, __func__);
>     +		return -EOPNOTSUPP;
>     +	}
>      	OBD_COUNTER_INCREMENT(obd, connect);
>      
>      	rc = OBP(obd, connect)(env, exp, obd, cluuid, data, localdata);
>     @@ -753,13 +784,16 @@ static inline int obd_reconnect(const struct lu_env *env,
>      				struct obd_connect_data *d,
>      				void *localdata)
>      {
>     +	u64 ocf = d ? d->ocd_connect_flags : 0; /* for post-condition check */
>      	int rc;
>     -	__u64 ocf = d ? d->ocd_connect_flags : 0; /* for post-condition check */
>      
>      	rc = obd_check_dev_active(obd);
>      	if (rc)
>      		return rc;
>     -	OBD_CHECK_DT_OP(obd, reconnect, 0);
>     +
>     +	if (!obd->obd_type || !obd->obd_type->typ_dt_ops->reconnect)
>     +		return 0;
>     +
>      	OBD_COUNTER_INCREMENT(obd, reconnect);
>      
>      	rc = OBP(obd, reconnect)(env, exp, obd, cluuid, d, localdata);
>     @@ -772,7 +806,15 @@ static inline int obd_disconnect(struct obd_export *exp)
>      {
>      	int rc;
>      
>     -	EXP_CHECK_DT_OP(exp, disconnect);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>     +
>     +	if (!exp->exp_obd->obd_type->typ_dt_ops->disconnect) {
>     +		CERROR("%s: no %s operation\n",
>     +		       exp->exp_obd->obd_name, __func__);
>     +		return -ENOTSUPP;
>     +	}
>      	EXP_COUNTER_INCREMENT(exp, disconnect);
>      
>      	rc = OBP(exp->exp_obd, disconnect)(exp);
>     @@ -784,7 +826,8 @@ static inline int obd_fid_init(struct obd_device *obd, struct obd_export *exp,
>      {
>      	int rc;
>      
>     -	OBD_CHECK_DT_OP(obd, fid_init, 0);
>     +	if (!obd->obd_type || !obd->obd_type->typ_dt_ops->fid_init)
>     +		return 0;
>      	OBD_COUNTER_INCREMENT(obd, fid_init);
>      
>      	rc = OBP(obd, fid_init)(obd, exp, type);
>     @@ -795,7 +838,8 @@ static inline int obd_fid_fini(struct obd_device *obd)
>      {
>      	int rc;
>      
>     -	OBD_CHECK_DT_OP(obd, fid_fini, 0);
>     +	if (!obd->obd_type || !obd->obd_type->typ_dt_ops->fid_fini)
>     +		return 0;
>      	OBD_COUNTER_INCREMENT(obd, fid_fini);
>      
>      	rc = OBP(obd, fid_fini)(obd);
>     @@ -809,7 +853,15 @@ static inline int obd_fid_alloc(const struct lu_env *env,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_DT_OP(exp, fid_alloc);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>     +
>     +	if (!exp->exp_obd->obd_type->typ_dt_ops->fid_alloc) {
>     +		CERROR("%s: no %s operation\n",
>     +		       exp->exp_obd->obd_name, __func__);
>     +		return -ENOTSUPP;
>     +	}
>      	EXP_COUNTER_INCREMENT(exp, fid_alloc);
>      
>      	rc = OBP(exp->exp_obd, fid_alloc)(env, exp, fid, op_data);
>     @@ -820,7 +872,10 @@ static inline int obd_pool_new(struct obd_device *obd, char *poolname)
>      {
>      	int rc;
>      
>     -	OBD_CHECK_DT_OP(obd, pool_new, -EOPNOTSUPP);
>     +	if (!obd->obd_type || !obd->obd_type->typ_dt_ops->pool_new) {
>     +		CERROR("%s: no %s operation\n", obd->obd_name, __func__);
>     +		return -EOPNOTSUPP;
>     +	}
>      	OBD_COUNTER_INCREMENT(obd, pool_new);
>      
>      	rc = OBP(obd, pool_new)(obd, poolname);
>     @@ -831,20 +886,25 @@ static inline int obd_pool_del(struct obd_device *obd, char *poolname)
>      {
>      	int rc;
>      
>     -	OBD_CHECK_DT_OP(obd, pool_del, -EOPNOTSUPP);
>     +	if (!obd->obd_type || !obd->obd_type->typ_dt_ops->pool_del) {
>     +		CERROR("%s: no %s operation\n", obd->obd_name, __func__);
>     +		return -EOPNOTSUPP;
>     +	}
>      	OBD_COUNTER_INCREMENT(obd, pool_del);
>      
>      	rc = OBP(obd, pool_del)(obd, poolname);
>      	return rc;
>      }
>      
>     -static inline int obd_pool_add(struct obd_device *obd,
>     -			       char *poolname,
>     +static inline int obd_pool_add(struct obd_device *obd, char *poolname,
>      			       char *ostname)
>      {
>      	int rc;
>      
>     -	OBD_CHECK_DT_OP(obd, pool_add, -EOPNOTSUPP);
>     +	if (!obd->obd_type || !obd->obd_type->typ_dt_ops->pool_add) {
>     +		CERROR("%s: no %s operation\n", obd->obd_name, __func__);
>     +		return -EOPNOTSUPP;
>     +	}
>      	OBD_COUNTER_INCREMENT(obd, pool_add);
>      
>      	rc = OBP(obd, pool_add)(obd, poolname, ostname);
>     @@ -857,7 +917,10 @@ static inline int obd_pool_rem(struct obd_device *obd,
>      {
>      	int rc;
>      
>     -	OBD_CHECK_DT_OP(obd, pool_rem, -EOPNOTSUPP);
>     +	if (!obd->obd_type || !obd->obd_type->typ_dt_ops->pool_rem) {
>     +		CERROR("%s: no %s operation\n", obd->obd_name, __func__);
>     +		return -EOPNOTSUPP;
>     +	}
>      	OBD_COUNTER_INCREMENT(obd, pool_rem);
>      
>      	rc = OBP(obd, pool_rem)(obd, poolname, ostname);
>     @@ -866,7 +929,7 @@ static inline int obd_pool_rem(struct obd_device *obd,
>      
>      static inline void obd_getref(struct obd_device *obd)
>      {
>     -	if (OBT(obd) && OBP(obd, getref)) {
>     +	if (obd->obd_type && OBP(obd, getref)) {
>      		OBD_COUNTER_INCREMENT(obd, getref);
>      		OBP(obd, getref)(obd);
>      	}
>     @@ -874,7 +937,7 @@ static inline void obd_getref(struct obd_device *obd)
>      
>      static inline void obd_putref(struct obd_device *obd)
>      {
>     -	if (OBT(obd) && OBP(obd, putref)) {
>     +	if (obd->obd_type && OBP(obd, putref)) {
>      		OBD_COUNTER_INCREMENT(obd, putref);
>      		OBP(obd, putref)(obd);
>      	}
>     @@ -884,7 +947,7 @@ static inline int obd_init_export(struct obd_export *exp)
>      {
>      	int rc = 0;
>      
>     -	if ((exp)->exp_obd && OBT((exp)->exp_obd) &&
>     +	if (exp->exp_obd && exp->exp_obd->obd_type &&
>      	    OBP((exp)->exp_obd, init_export))
>      		rc = OBP(exp->exp_obd, init_export)(exp);
>      	return rc;
>     @@ -892,7 +955,7 @@ static inline int obd_init_export(struct obd_export *exp)
>      
>      static inline int obd_destroy_export(struct obd_export *exp)
>      {
>     -	if ((exp)->exp_obd && OBT((exp)->exp_obd) &&
>     +	if (exp->exp_obd && exp->exp_obd->obd_type &&
>      	    OBP((exp)->exp_obd, destroy_export))
>      		OBP(exp->exp_obd, destroy_export)(exp);
>      	return 0;
>     @@ -915,7 +978,10 @@ static inline int obd_statfs_async(struct obd_export *exp,
>      		return -EINVAL;
>      
>      	obd = exp->exp_obd;
>     -	OBD_CHECK_DT_OP(obd, statfs, -EOPNOTSUPP);
>     +	if (!obd->obd_type || !obd->obd_type->typ_dt_ops->statfs) {
>     +		CERROR("%s: no %s operation\n", obd->obd_name, __func__);
>     +		return -EOPNOTSUPP;
>     +	}
>      	OBD_COUNTER_INCREMENT(obd, statfs);
>      
>      	CDEBUG(D_SUPER, "%s: osfs %p age %llu, max_age %llu\n",
>     @@ -969,13 +1035,16 @@ static inline int obd_statfs(const struct lu_env *env, struct obd_export *exp,
>      			     struct obd_statfs *osfs, __u64 max_age,
>      			     __u32 flags)
>      {
>     -	int rc = 0;
>      	struct obd_device *obd = exp->exp_obd;
>     +	int rc = 0;
>      
>      	if (!obd)
>      		return -EINVAL;
>      
>     -	OBD_CHECK_DT_OP(obd, statfs, -EOPNOTSUPP);
>     +	if (!obd->obd_type || !obd->obd_type->typ_dt_ops->statfs) {
>     +		CERROR("%s: no %s operation\n", obd->obd_name, __func__);
>     +		return -EOPNOTSUPP;
>     +	}
>      	OBD_COUNTER_INCREMENT(obd, statfs);
>      
>      	CDEBUG(D_SUPER, "osfs %llu, max_age %llu\n",
>     @@ -1009,7 +1078,15 @@ static inline int obd_preprw(const struct lu_env *env, int cmd,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_DT_OP(exp, preprw);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>     +
>     +	if (!exp->exp_obd->obd_type->typ_dt_ops->preprw) {
>     +		CERROR("%s: no %s operation\n",
>     +		       exp->exp_obd->obd_name, __func__);
>     +		return -ENOTSUPP;
>     +	}
>      	EXP_COUNTER_INCREMENT(exp, preprw);
>      
>      	rc = OBP(exp->exp_obd, preprw)(env, cmd, exp, oa, objcount, obj, remote,
>     @@ -1021,13 +1098,23 @@ static inline int obd_commitrw(const struct lu_env *env, int cmd,
>      			       struct obd_export *exp, struct obdo *oa,
>      			       int objcount, struct obd_ioobj *obj,
>      			       struct niobuf_remote *rnb, int pages,
>     -			       struct niobuf_local *local, int rc)
>     +			       struct niobuf_local *local, int orig_rc)
>      {
>     -	EXP_CHECK_DT_OP(exp, commitrw);
>     +	int rc;
>     +
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>     +
>     +	if (!exp->exp_obd->obd_type->typ_dt_ops->commitrw) {
>     +		CERROR("%s: no %s operation\n",
>     +		       exp->exp_obd->obd_name, __func__);
>     +		return -ENOTSUPP;
>     +	}
>      	EXP_COUNTER_INCREMENT(exp, commitrw);
>      
>      	rc = OBP(exp->exp_obd, commitrw)(env, cmd, exp, oa, objcount, obj,
>     -					 rnb, pages, local, rc);
>     +					 rnb, pages, local, orig_rc);
>      	return rc;
>      }
>      
>     @@ -1036,7 +1123,15 @@ static inline int obd_iocontrol(unsigned int cmd, struct obd_export *exp,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_DT_OP(exp, iocontrol);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>     +
>     +	if (!exp->exp_obd->obd_type->typ_dt_ops->iocontrol) {
>     +		CERROR("%s: no %s operation\n",
>     +		       exp->exp_obd->obd_name, __func__);
>     +		return -ENOTSUPP;
>     +	}
>      	EXP_COUNTER_INCREMENT(exp, iocontrol);
>      
>      	rc = OBP(exp->exp_obd, iocontrol)(cmd, exp, len, karg, uarg);
>     @@ -1108,7 +1203,15 @@ static inline int obd_quotactl(struct obd_export *exp,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_DT_OP(exp, quotactl);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>     +
>     +	if (!exp->exp_obd->obd_type->typ_dt_ops->quotactl) {
>     +		CERROR("%s: no %s operation\n",
>     +		       exp->exp_obd->obd_name, __func__);
>     +		return -ENOTSUPP;
>     +	}
>      	EXP_COUNTER_INCREMENT(exp, quotactl);
>      
>      	rc = OBP(exp->exp_obd, quotactl)(exp->exp_obd, exp, oqctl);
>     @@ -1129,7 +1232,7 @@ static inline int obd_health_check(const struct lu_env *env,
>      	int rc;
>      
>      	/* don't use EXP_CHECK_DT_OP, because NULL method is normal here */
>     -	if (!obd || !OBT(obd)) {
>     +	if (!obd || !obd->obd_type) {
>      		CERROR("cleaned up obd\n");
>      		return -EOPNOTSUPP;
>      	}
>     @@ -1166,7 +1269,9 @@ static inline int md_get_root(struct obd_export *exp, const char *fileset,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_MD_OP(exp, get_root);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, get_root);
>      	rc = MDP(exp->exp_obd, get_root)(exp, fileset, fid);
>      	return rc;
>     @@ -1177,7 +1282,9 @@ static inline int md_getattr(struct obd_export *exp, struct md_op_data *op_data,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_MD_OP(exp, getattr);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, getattr);
>      	rc = MDP(exp->exp_obd, getattr)(exp, op_data, request);
>      	return rc;
>     @@ -1188,7 +1295,9 @@ static inline int md_null_inode(struct obd_export *exp,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_MD_OP(exp, null_inode);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, null_inode);
>      	rc = MDP(exp->exp_obd, null_inode)(exp, fid);
>      	return rc;
>     @@ -1200,7 +1309,9 @@ static inline int md_close(struct obd_export *exp, struct md_op_data *op_data,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_MD_OP(exp, close);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, close);
>      	rc = MDP(exp->exp_obd, close)(exp, op_data, mod, request);
>      	return rc;
>     @@ -1213,7 +1324,9 @@ static inline int md_create(struct obd_export *exp, struct md_op_data *op_data,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_MD_OP(exp, create);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, create);
>      	rc = MDP(exp->exp_obd, create)(exp, op_data, data, datalen, mode,
>      				       uid, gid, cap_effective, rdev, request);
>     @@ -1229,7 +1342,9 @@ static inline int md_enqueue(struct obd_export *exp,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_MD_OP(exp, enqueue);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, enqueue);
>      	rc = MDP(exp->exp_obd, enqueue)(exp, einfo, policy, op_data, lockh,
>      					extra_lock_flags);
>     @@ -1242,7 +1357,9 @@ static inline int md_getattr_name(struct obd_export *exp,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_MD_OP(exp, getattr_name);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, getattr_name);
>      	rc = MDP(exp->exp_obd, getattr_name)(exp, op_data, request);
>      	return rc;
>     @@ -1257,7 +1374,9 @@ static inline int md_intent_lock(struct obd_export *exp,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_MD_OP(exp, intent_lock);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, intent_lock);
>      	rc = MDP(exp->exp_obd, intent_lock)(exp, op_data, it, reqp,
>      					    cb_blocking, extra_lock_flags);
>     @@ -1269,7 +1388,9 @@ static inline int md_link(struct obd_export *exp, struct md_op_data *op_data,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_MD_OP(exp, link);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, link);
>      	rc = MDP(exp->exp_obd, link)(exp, op_data, request);
>      	return rc;
>     @@ -1281,7 +1402,9 @@ static inline int md_rename(struct obd_export *exp, struct md_op_data *op_data,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_MD_OP(exp, rename);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, rename);
>      	rc = MDP(exp->exp_obd, rename)(exp, op_data, old, oldlen, new,
>      				       newlen, request);
>     @@ -1294,7 +1417,9 @@ static inline int md_setattr(struct obd_export *exp, struct md_op_data *op_data,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_MD_OP(exp, setattr);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, setattr);
>      	rc = MDP(exp->exp_obd, setattr)(exp, op_data, ea, ealen, request);
>      	return rc;
>     @@ -1305,7 +1430,9 @@ static inline int md_sync(struct obd_export *exp, const struct lu_fid *fid,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_MD_OP(exp, sync);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, sync);
>      	rc = MDP(exp->exp_obd, sync)(exp, fid, request);
>      	return rc;
>     @@ -1319,7 +1446,9 @@ static inline int md_read_page(struct obd_export *exp,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_MD_OP(exp, read_page);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, read_page);
>      	rc = MDP(exp->exp_obd, read_page)(exp, op_data, cb_op, hash_offset,
>      					  ppage);
>     @@ -1331,7 +1460,9 @@ static inline int md_unlink(struct obd_export *exp, struct md_op_data *op_data,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_MD_OP(exp, unlink);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, unlink);
>      	rc = MDP(exp->exp_obd, unlink)(exp, op_data, request);
>      	return rc;
>     @@ -1343,7 +1474,11 @@ static inline int md_get_lustre_md(struct obd_export *exp,
>      				   struct obd_export *md_exp,
>      				   struct lustre_md *md)
>      {
>     -	EXP_CHECK_MD_OP(exp, get_lustre_md);
>     +	int rc;
>     +
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, get_lustre_md);
>      	return MDP(exp->exp_obd, get_lustre_md)(exp, req, dt_exp, md_exp, md);
>      }
>     @@ -1351,7 +1486,11 @@ static inline int md_get_lustre_md(struct obd_export *exp,
>      static inline int md_free_lustre_md(struct obd_export *exp,
>      				    struct lustre_md *md)
>      {
>     -	EXP_CHECK_MD_OP(exp, free_lustre_md);
>     +	int rc;
>     +
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, free_lustre_md);
>      	return MDP(exp->exp_obd, free_lustre_md)(exp, md);
>      }
>     @@ -1361,7 +1500,11 @@ static inline int md_merge_attr(struct obd_export *exp,
>      				struct cl_attr *attr,
>      				ldlm_blocking_callback cb)
>      {
>     -	EXP_CHECK_MD_OP(exp, merge_attr);
>     +	int rc;
>     +
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, merge_attr);
>      	return MDP(exp->exp_obd, merge_attr)(exp, lsm, attr, cb);
>      }
>     @@ -1372,7 +1515,11 @@ static inline int md_setxattr(struct obd_export *exp, const struct lu_fid *fid,
>      			      unsigned int xattr_flags, u32 suppgid,
>      			      struct ptlrpc_request **request)
>      {
>     -	EXP_CHECK_MD_OP(exp, setxattr);
>     +	int rc;
>     +
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, setxattr);
>      	return MDP(exp->exp_obd, setxattr)(exp, fid, obd_md_valid, name,
>      					   value, value_size, xattr_flags,
>     @@ -1383,7 +1530,11 @@ static inline int md_getxattr(struct obd_export *exp, const struct lu_fid *fid,
>      			      u64 obd_md_valid, const char *name,
>      			      size_t buf_size, struct ptlrpc_request **req)
>      {
>     -	EXP_CHECK_MD_OP(exp, getxattr);
>     +	int rc;
>     +
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, getxattr);
>      	return MDP(exp->exp_obd, getxattr)(exp, fid, obd_md_valid, name,
>      					   buf_size, req);
>     @@ -1393,7 +1544,11 @@ static inline int md_set_open_replay_data(struct obd_export *exp,
>      					  struct obd_client_handle *och,
>      					  struct lookup_intent *it)
>      {
>     -	EXP_CHECK_MD_OP(exp, set_open_replay_data);
>     +	int rc;
>     +
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, set_open_replay_data);
>      	return MDP(exp->exp_obd, set_open_replay_data)(exp, och, it);
>      }
>     @@ -1401,7 +1556,11 @@ static inline int md_set_open_replay_data(struct obd_export *exp,
>      static inline int md_clear_open_replay_data(struct obd_export *exp,
>      					    struct obd_client_handle *och)
>      {
>     -	EXP_CHECK_MD_OP(exp, clear_open_replay_data);
>     +	int rc;
>     +
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, clear_open_replay_data);
>      	return MDP(exp->exp_obd, clear_open_replay_data)(exp, och);
>      }
>     @@ -1410,7 +1569,11 @@ static inline int md_set_lock_data(struct obd_export *exp,
>      				   const struct lustre_handle *lockh,
>      				   void *data, __u64 *bits)
>      {
>     -	EXP_CHECK_MD_OP(exp, set_lock_data);
>     +	int rc;
>     +
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, set_lock_data);
>      	return MDP(exp->exp_obd, set_lock_data)(exp, lockh, data, bits);
>      }
>     @@ -1424,7 +1587,9 @@ static inline int md_cancel_unused(struct obd_export *exp,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_MD_OP(exp, cancel_unused);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, cancel_unused);
>      
>      	rc = MDP(exp->exp_obd, cancel_unused)(exp, fid, policy, mode,
>     @@ -1439,7 +1604,11 @@ static inline enum ldlm_mode md_lock_match(struct obd_export *exp, __u64 flags,
>      					   enum ldlm_mode mode,
>      					   struct lustre_handle *lockh)
>      {
>     -	EXP_CHECK_MD_OP(exp, lock_match);
>     +	int rc;
>     +
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, lock_match);
>      	return MDP(exp->exp_obd, lock_match)(exp, flags, fid, type,
>      					     policy, mode, lockh);
>     @@ -1448,7 +1617,11 @@ static inline enum ldlm_mode md_lock_match(struct obd_export *exp, __u64 flags,
>      static inline int md_init_ea_size(struct obd_export *exp, u32 easize,
>      				  u32 def_asize)
>      {
>     -	EXP_CHECK_MD_OP(exp, init_ea_size);
>     +	int rc;
>     +
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, init_ea_size);
>      	return MDP(exp->exp_obd, init_ea_size)(exp, easize, def_asize);
>      }
>     @@ -1458,7 +1631,9 @@ static inline int md_intent_getattr_async(struct obd_export *exp,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_MD_OP(exp, intent_getattr_async);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, intent_getattr_async);
>      	rc = MDP(exp->exp_obd, intent_getattr_async)(exp, minfo);
>      	return rc;
>     @@ -1470,7 +1645,9 @@ static inline int md_revalidate_lock(struct obd_export *exp,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_MD_OP(exp, revalidate_lock);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, revalidate_lock);
>      	rc = MDP(exp->exp_obd, revalidate_lock)(exp, it, fid, bits);
>      	return rc;
>     @@ -1483,7 +1660,9 @@ static inline int md_get_fid_from_lsm(struct obd_export *exp,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_MD_OP(exp, get_fid_from_lsm);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, get_fid_from_lsm);
>      	rc = MDP(exp->exp_obd, get_fid_from_lsm)(exp, lsm, name, namelen, fid);
>      	return rc;
>     @@ -1502,7 +1681,9 @@ static inline int md_unpackmd(struct obd_export *exp,
>      {
>      	int rc;
>      
>     -	EXP_CHECK_MD_OP(exp, unpackmd);
>     +	rc = exp_check_ops(exp);
>     +	if (rc)
>     +		return rc;
>      	EXP_MD_COUNTER_INCREMENT(exp, unpackmd);
>      	rc = MDP(exp->exp_obd, unpackmd)(exp, plsm, lmm, lmm_size);
>      	return rc;
>     diff --git a/drivers/staging/lustre/lustre/obdclass/llog_obd.c b/drivers/staging/lustre/lustre/obdclass/llog_obd.c
>     index 26aea11..e074b6e 100644
>     --- a/drivers/staging/lustre/lustre/obdclass/llog_obd.c
>     +++ b/drivers/staging/lustre/lustre/obdclass/llog_obd.c
>     @@ -93,8 +93,8 @@ int __llog_ctxt_put(const struct lu_env *env, struct llog_ctxt *ctxt)
>      		 !!obd->obd_stopping, !!obd->obd_set_up);
>      
>      	/* cleanup the llog ctxt here */
>     -	if (CTXTP(ctxt, cleanup))
>     -		rc = CTXTP(ctxt, cleanup)(env, ctxt);
>     +	if (ctxt->loc_logops->lop_cleanup)
>     +		rc = ctxt->loc_logops->lop_cleanup(env, ctxt);
>      
>      	llog_ctxt_destroy(ctxt);
>      	wake_up(&olg->olg_waitq);
>     -- 
>     1.8.3.1
>     
>     
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180924/273463a6/attachment-0001.sig>
