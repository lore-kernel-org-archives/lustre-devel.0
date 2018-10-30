From: NeilBrown <neilb@suse.com>
Date: Tue, 30 Oct 2018 17:41:08 +1100
Subject: [lustre-devel] [PATCH 18/28] lustre: mdc: expose changelog
 through char devices
In-Reply-To: <1539543498-29105-19-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
 <1539543498-29105-19-git-send-email-jsimmons@infradead.org>
Message-ID: <87efc82ayj.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Oct 14 2018, James Simmons wrote:

> From: Henri Doreau <henri.doreau@cea.fr>
>
> Register one character device per MDT in order to allow non-llapi to
> read them and to make delivery more efficient.
>
> - open() spawns a thread to prefetch records and enqueue them into a
>   local buffer (unless the device is open in write-only mode).
> - lseek() can be used to jump to a specific record, in which case the
>   offset is a record number (with SEEK_SET) or a number of records to
>   skip (SEEK_CUR). Movement can only be done forward.
> - read() copies records to userland. No truncation happens, so short
>   reads are likely.
> - write() is used to transmit control commands to the device.
>   The only available one is changelog_clear, which is done by writing
>   "clear:cl<user>:<recno>" into the device.
> - close() terminates the prefetch thread if any, and releases resources.
>
> It is possible to poll() on the device to get notified when new records
> are available for read.
>
> Signed-off-by: Henri Doreau <henri.doreau@cea.fr>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-7659
> Reviewed-on: https://review.whamcloud.com/18900
> Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
> Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
> Reviewed-by: Oleg Drokin <green@whamcloud.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>

This patches causes problems around sanity test 161a.
If you run -only '160h 160i 161a' it hangs.

Adding
Commit: 89e52326b5bd ("LU-10166 mdc: invalid free in changelog reader")
seems to fix the problem, so I'll port that into the series immediately
after this patch.

NeilBrown


> ---
>  .../include/uapi/linux/lustre/lustre_ioctl.h       |   2 +-
>  .../include/uapi/linux/lustre/lustre_kernelcomm.h  |   3 -
>  .../lustre/include/uapi/linux/lustre/lustre_user.h |   7 -
>  drivers/staging/lustre/lustre/include/obd.h        |   2 +
>  drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |   2 +
>  drivers/staging/lustre/lustre/llite/dir.c          |   8 -
>  drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  13 -
>  drivers/staging/lustre/lustre/mdc/Makefile         |   2 +-
>  drivers/staging/lustre/lustre/mdc/mdc_changelog.c  | 722 +++++++++++++++++++++
>  drivers/staging/lustre/lustre/mdc/mdc_internal.h   |   4 +
>  drivers/staging/lustre/lustre/mdc/mdc_request.c    | 198 +-----
>  11 files changed, 745 insertions(+), 218 deletions(-)
>  create mode 100644 drivers/staging/lustre/lustre/mdc/mdc_changelog.c
>
> diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
> index 6e4e109..098b6451 100644
> --- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
> +++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
> @@ -172,7 +172,7 @@ static inline __u32 obd_ioctl_packlen(struct obd_ioctl_data *data)
>  #define OBD_GET_VERSION		_IOWR('f', 144, OBD_IOC_DATA_TYPE)
>  /*	OBD_IOC_GSS_SUPPORT	_IOWR('f', 145, OBD_IOC_DATA_TYPE) */
>  /*	OBD_IOC_CLOSE_UUID	_IOWR('f', 147, OBD_IOC_DATA_TYPE) */
> -#define OBD_IOC_CHANGELOG_SEND	_IOW('f', 148, OBD_IOC_DATA_TYPE)
> +/*	OBD_IOC_CHANGELOG_SEND	_IOW('f', 148, OBD_IOC_DATA_TYPE) */
>  #define OBD_IOC_GETDEVICE	_IOWR('f', 149, OBD_IOC_DATA_TYPE)
>  #define OBD_IOC_FID2PATH	_IOWR('f', 150, OBD_IOC_DATA_TYPE)
>  /*	lustre/lustre_user.h	151-153 */
> diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_kernelcomm.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_kernelcomm.h
> index 94dadbe..d84a8fc 100644
> --- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_kernelcomm.h
> +++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_kernelcomm.h
> @@ -54,15 +54,12 @@ struct kuc_hdr {
>  	__u16 kuc_msglen;
>  } __aligned(sizeof(__u64));
>  
> -#define KUC_CHANGELOG_MSG_MAXSIZE (sizeof(struct kuc_hdr) + CR_MAXSIZE)
> -
>  #define KUC_MAGIC		0x191C /*Lustre9etLinC */
>  
>  /* kuc_msgtype values are defined in each transport */
>  enum kuc_transport_type {
>  	KUC_TRANSPORT_GENERIC	= 1,
>  	KUC_TRANSPORT_HSM	= 2,
> -	KUC_TRANSPORT_CHANGELOG	= 3,
>  };
>  
>  enum kuc_generic_message_type {
> diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
> index b8525e5..715f1c5 100644
> --- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
> +++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
> @@ -967,13 +967,6 @@ static inline void changelog_remap_rec(struct changelog_rec *rec,
>  	rec->cr_flags = (rec->cr_flags & CLF_FLAGMASK) | crf_wanted;
>  }
>  
> -struct ioc_changelog {
> -	__u64 icc_recno;
> -	__u32 icc_mdtindex;
> -	__u32 icc_id;
> -	__u32 icc_flags;
> -};
> -
>  enum changelog_message_type {
>  	CL_RECORD = 10, /* message is a changelog_rec */
>  	CL_EOF    = 11, /* at end of current changelog */
> diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
> index 11e7ae8..76ae0b3 100644
> --- a/drivers/staging/lustre/lustre/include/obd.h
> +++ b/drivers/staging/lustre/lustre/include/obd.h
> @@ -345,6 +345,8 @@ struct client_obd {
>  	void			*cl_lru_work;
>  	/* hash tables for osc_quota_info */
>  	struct rhashtable	cl_quota_hash[MAXQUOTAS];
> +	/* Links to the global list of registered changelog devices */
> +	struct list_head	cl_chg_dev_linkage;
>  };
>  
>  #define obd2cli_tgt(obd) ((char *)(obd)->u.cli.cl_target_uuid.uuid)
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
> index 32eda4f..732ef3a 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
> @@ -395,6 +395,8 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
>  	init_waitqueue_head(&cli->cl_mod_rpcs_waitq);
>  	cli->cl_mod_tag_bitmap = NULL;
>  
> +	INIT_LIST_HEAD(&cli->cl_chg_dev_linkage);
> +
>  	if (connect_op == MDS_CONNECT) {
>  		cli->cl_max_mod_rpcs_in_flight = cli->cl_max_rpcs_in_flight - 1;
>  		cli->cl_mod_tag_bitmap = kcalloc(BITS_TO_LONGS(OBD_MAX_RIF_MAX),
> diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
> index 19c5e9c..36cea8d 100644
> --- a/drivers/staging/lustre/lustre/llite/dir.c
> +++ b/drivers/staging/lustre/lustre/llite/dir.c
> @@ -1481,14 +1481,6 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
>  		return obd_iocontrol(cmd, sbi->ll_md_exp, 0, NULL,
>  				     (void __user *)arg);
>  	}
> -	case OBD_IOC_CHANGELOG_SEND:
> -	case OBD_IOC_CHANGELOG_CLEAR:
> -		if (!capable(CAP_SYS_ADMIN))
> -			return -EPERM;
> -
> -		rc = copy_and_ioctl(cmd, sbi->ll_md_exp, (void __user *)arg,
> -				    sizeof(struct ioc_changelog));
> -		return rc;
>  	case OBD_IOC_FID2PATH:
>  		return ll_fid2path(inode, (void __user *)arg);
>  	case LL_IOC_GETPARENT:
> diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> index 952c68e..32bb9fc 100644
> --- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> +++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> @@ -951,19 +951,6 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
>  		kfree(oqctl);
>  		break;
>  	}
> -	case OBD_IOC_CHANGELOG_SEND:
> -	case OBD_IOC_CHANGELOG_CLEAR: {
> -		struct ioc_changelog *icc = karg;
> -
> -		if (icc->icc_mdtindex >= count)
> -			return -ENODEV;
> -
> -		tgt = lmv->tgts[icc->icc_mdtindex];
> -		if (!tgt || !tgt->ltd_exp || !tgt->ltd_active)
> -			return -ENODEV;
> -		rc = obd_iocontrol(cmd, tgt->ltd_exp, sizeof(*icc), icc, NULL);
> -		break;
> -	}
>  	case LL_IOC_GET_CONNECT_FLAGS: {
>  		tgt = lmv->tgts[0];
>  
> diff --git a/drivers/staging/lustre/lustre/mdc/Makefile b/drivers/staging/lustre/lustre/mdc/Makefile
> index 64cf49e..5f48e91 100644
> --- a/drivers/staging/lustre/lustre/mdc/Makefile
> +++ b/drivers/staging/lustre/lustre/mdc/Makefile
> @@ -2,4 +2,4 @@ ccflags-y += -I$(srctree)/drivers/staging/lustre/include
>  ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
>  
>  obj-$(CONFIG_LUSTRE_FS) += mdc.o
> -mdc-y := mdc_request.o mdc_reint.o mdc_lib.o mdc_locks.o lproc_mdc.o
> +mdc-y := mdc_changelog.o mdc_request.o mdc_reint.o mdc_lib.o mdc_locks.o lproc_mdc.o
> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_changelog.c b/drivers/staging/lustre/lustre/mdc/mdc_changelog.c
> new file mode 100644
> index 0000000..a5f3c64
> --- /dev/null
> +++ b/drivers/staging/lustre/lustre/mdc/mdc_changelog.c
> @@ -0,0 +1,722 @@
> +// SPDX-License-Identifier: GPL-2.0
> +/*
> + * GPL HEADER START
> + *
> + * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 only,
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> + * General Public License version 2 for more details (a copy is included
> + * in the LICENSE file that accompanied this code).
> + *
> + * You should have received a copy of the GNU General Public License
> + * version 2 along with this program; If not, see
> + * http://www.gnu.org/licenses/gpl-2.0.html
> + *
> + * GPL HEADER END
> + */
> +/*
> + * Copyright (c) 2017, Commissariat a l'Energie Atomique et aux Energies
> + *                     Alternatives.
> + *
> + * Author: Henri Doreau <henri.doreau@cea.fr>
> + */
> +
> +#define DEBUG_SUBSYSTEM S_MDC
> +
> +#include <linux/init.h>
> +#include <linux/kthread.h>
> +#include <linux/poll.h>
> +#include <linux/miscdevice.h>
> +
> +#include <lustre_log.h>
> +
> +#include "mdc_internal.h"
> +
> +/*
> + * -- Changelog delivery through character device --
> + */
> +
> +/**
> + * Mutex to protect chlg_registered_devices below
> + */
> +static DEFINE_MUTEX(chlg_registered_dev_lock);
> +
> +/**
> + * Global linked list of all registered devices (one per MDT).
> + */
> +static LIST_HEAD(chlg_registered_devices);
> +
> +struct chlg_registered_dev {
> +	/* Device name of the form "changelog-{MDTNAME}" */
> +	char			ced_name[32];
> +	/* Misc device descriptor */
> +	struct miscdevice	ced_misc;
> +	/* OBDs referencing this device (multiple mount point) */
> +	struct list_head	ced_obds;
> +	/* Reference counter for proper deregistration */
> +	struct kref		ced_refs;
> +	/* Link within the global chlg_registered_devices */
> +	struct list_head	ced_link;
> +};
> +
> +struct chlg_reader_state {
> +	/* Shortcut to the corresponding OBD device */
> +	struct obd_device	*crs_obd;
> +	/* An error occurred that prevents from reading further */
> +	bool			 crs_err;
> +	/* EOF, no more records available */
> +	bool			 crs_eof;
> +	/* Userland reader closed connection */
> +	bool			 crs_closed;
> +	/* Desired start position */
> +	u64			 crs_start_offset;
> +	/* Wait queue for the catalog processing thread */
> +	wait_queue_head_t	 crs_waitq_prod;
> +	/* Wait queue for the record copy threads */
> +	wait_queue_head_t	 crs_waitq_cons;
> +	/* Mutex protecting crs_rec_count and crs_rec_queue */
> +	struct mutex		 crs_lock;
> +	/* Number of item in the list */
> +	u64			 crs_rec_count;
> +	/* List of prefetched enqueued_record::enq_linkage_items */
> +	struct list_head	 crs_rec_queue;
> +};
> +
> +struct chlg_rec_entry {
> +	/* Link within the chlg_reader_state::crs_rec_queue list */
> +	struct list_head	enq_linkage;
> +	/* Data (enq_record) field length */
> +	u64			enq_length;
> +	/* Copy of a changelog record (see struct llog_changelog_rec) */
> +	struct changelog_rec	enq_record[];
> +};
> +
> +enum {
> +	/* Number of records to prefetch locally. */
> +	CDEV_CHLG_MAX_PREFETCH = 1024,
> +};
> +
> +/**
> + * ChangeLog catalog processing callback invoked on each record.
> + * If the current record is eligible to userland delivery, push
> + * it into the crs_rec_queue where the consumer code will fetch it.
> + *
> + * @param[in]     env  (unused)
> + * @param[in]     llh  Client-side handle used to identify the llog
> + * @param[in]     hdr  Header of the current llog record
> + * @param[in,out] data chlg_reader_state passed from caller
> + *
> + * @return 0 or LLOG_PROC_* control code on success, negated error on failure.
> + */
> +static int chlg_read_cat_process_cb(const struct lu_env *env,
> +				    struct llog_handle *llh,
> +				    struct llog_rec_hdr *hdr, void *data)
> +{
> +	struct llog_changelog_rec *rec;
> +	struct chlg_reader_state *crs = data;
> +	struct chlg_rec_entry *enq;
> +	size_t len;
> +	int rc;
> +
> +	LASSERT(crs);
> +	LASSERT(hdr);
> +
> +	rec = container_of(hdr, struct llog_changelog_rec, cr_hdr);
> +
> +	if (rec->cr_hdr.lrh_type != CHANGELOG_REC) {
> +		rc = -EINVAL;
> +		CERROR("%s: not a changelog rec %x/%d in llog : rc = %d\n",
> +		       crs->crs_obd->obd_name, rec->cr_hdr.lrh_type,
> +		       rec->cr.cr_type, rc);
> +		return rc;
> +	}
> +
> +	/* Skip undesired records */
> +	if (rec->cr.cr_index < crs->crs_start_offset)
> +		return 0;
> +
> +	CDEBUG(D_HSM, "%llu %02d%-5s %llu 0x%x t=" DFID " p=" DFID " %.*s\n",
> +	       rec->cr.cr_index, rec->cr.cr_type,
> +	       changelog_type2str(rec->cr.cr_type), rec->cr.cr_time,
> +	       rec->cr.cr_flags & CLF_FLAGMASK,
> +	       PFID(&rec->cr.cr_tfid), PFID(&rec->cr.cr_pfid),
> +	       rec->cr.cr_namelen, changelog_rec_name(&rec->cr));
> +
> +	wait_event_idle(crs->crs_waitq_prod,
> +			(crs->crs_rec_count < CDEV_CHLG_MAX_PREFETCH ||
> +			 crs->crs_closed));
> +
> +	if (crs->crs_closed)
> +		return LLOG_PROC_BREAK;
> +
> +	len = changelog_rec_size(&rec->cr) + rec->cr.cr_namelen;
> +	enq = kzalloc(sizeof(*enq) + len, GFP_KERNEL);
> +	if (!enq)
> +		return -ENOMEM;
> +
> +	INIT_LIST_HEAD(&enq->enq_linkage);
> +	enq->enq_length = len;
> +	memcpy(enq->enq_record, &rec->cr, len);
> +
> +	mutex_lock(&crs->crs_lock);
> +	list_add_tail(&enq->enq_linkage, &crs->crs_rec_queue);
> +	crs->crs_rec_count++;
> +	mutex_unlock(&crs->crs_lock);
> +
> +	wake_up_all(&crs->crs_waitq_cons);
> +
> +	return 0;
> +}
> +
> +/**
> + * Remove record from the list it is attached to and free it.
> + */
> +static void enq_record_delete(struct chlg_rec_entry *rec)
> +{
> +	list_del(&rec->enq_linkage);
> +	kfree(rec);
> +}
> +
> +/**
> + * Release resources associated to a changelog_reader_state instance.
> + *
> + * @param  crs  CRS instance to release.
> + */
> +static void crs_free(struct chlg_reader_state *crs)
> +{
> +	struct chlg_rec_entry *rec;
> +	struct chlg_rec_entry *tmp;
> +
> +	list_for_each_entry_safe(rec, tmp, &crs->crs_rec_queue, enq_linkage)
> +		enq_record_delete(rec);
> +
> +	kfree(crs);
> +}
> +
> +/**
> + * Record prefetch thread entry point. Opens the changelog catalog and starts
> + * reading records.
> + *
> + * @param[in,out]  args  chlg_reader_state passed from caller.
> + * @return 0 on success, negated error code on failure.
> + */
> +static int chlg_load(void *args)
> +{
> +	struct chlg_reader_state *crs = args;
> +	struct obd_device *obd = crs->crs_obd;
> +	struct llog_ctxt *ctx = NULL;
> +	struct llog_handle *llh = NULL;
> +	int rc;
> +
> +	ctx = llog_get_context(obd, LLOG_CHANGELOG_REPL_CTXT);
> +	if (!ctx) {
> +		rc = -ENOENT;
> +		goto err_out;
> +	}
> +
> +	rc = llog_open(NULL, ctx, &llh, NULL, CHANGELOG_CATALOG,
> +		       LLOG_OPEN_EXISTS);
> +	if (rc) {
> +		CERROR("%s: fail to open changelog catalog: rc = %d\n",
> +		       obd->obd_name, rc);
> +		goto err_out;
> +	}
> +
> +	rc = llog_init_handle(NULL, llh, LLOG_F_IS_CAT | LLOG_F_EXT_JOBID,
> +			      NULL);
> +	if (rc) {
> +		CERROR("%s: fail to init llog handle: rc = %d\n",
> +		       obd->obd_name, rc);
> +		goto err_out;
> +	}
> +
> +	rc = llog_cat_process(NULL, llh, chlg_read_cat_process_cb, crs, 0, 0);
> +	if (rc < 0) {
> +		CERROR("%s: fail to process llog: rc = %d\n",
> +		       obd->obd_name, rc);
> +		goto err_out;
> +	}
> +
> +err_out:
> +	crs->crs_err = true;
> +	wake_up_all(&crs->crs_waitq_cons);
> +
> +	if (llh)
> +		llog_cat_close(NULL, llh);
> +
> +	if (ctx)
> +		llog_ctxt_put(ctx);
> +
> +	wait_event_idle(crs->crs_waitq_prod, crs->crs_closed);
> +	crs_free(crs);
> +	return rc;
> +}
> +
> +/**
> + * Read handler, dequeues records from the chlg_reader_state if any.
> + * No partial records are copied to userland so this function can return less
> + * data than required (short read).
> + *
> + * @param[in]   file   File pointer to the character device.
> + * @param[out]  buff   Userland buffer where to copy the records.
> + * @param[in]   count  Userland buffer size.
> + * @param[out]  ppos   File position, updated with the index number of the next
> + *		       record to read.
> + * @return number of copied bytes on success, negated error code on failure.
> + */
> +static ssize_t chlg_read(struct file *file, char __user *buff, size_t count,
> +			 loff_t *ppos)
> +{
> +	struct chlg_reader_state *crs = file->private_data;
> +	struct chlg_rec_entry *rec;
> +	struct chlg_rec_entry *tmp;
> +	ssize_t  written_total = 0;
> +	LIST_HEAD(consumed);
> +
> +	if (file->f_flags & O_NONBLOCK && crs->crs_rec_count == 0)
> +		return -EAGAIN;
> +
> +	wait_event_idle(crs->crs_waitq_cons,
> +			crs->crs_rec_count > 0 || crs->crs_eof || crs->crs_err);
> +
> +	mutex_lock(&crs->crs_lock);
> +	list_for_each_entry_safe(rec, tmp, &crs->crs_rec_queue, enq_linkage) {
> +		if (written_total + rec->enq_length > count)
> +			break;
> +
> +		if (copy_to_user(buff, rec->enq_record, rec->enq_length)) {
> +			if (written_total == 0)
> +				written_total = -EFAULT;
> +			break;
> +		}
> +
> +		buff += rec->enq_length;
> +		written_total += rec->enq_length;
> +
> +		crs->crs_rec_count--;
> +		list_move_tail(&rec->enq_linkage, &consumed);
> +
> +		crs->crs_start_offset = rec->enq_record->cr_index + 1;
> +	}
> +	mutex_unlock(&crs->crs_lock);
> +
> +	if (written_total > 0)
> +		wake_up_all(&crs->crs_waitq_prod);
> +
> +	list_for_each_entry_safe(rec, tmp, &consumed, enq_linkage)
> +		enq_record_delete(rec);
> +
> +	*ppos = crs->crs_start_offset;
> +
> +	return written_total;
> +}
> +
> +/**
> + * Jump to a given record index. Helper for chlg_llseek().
> + *
> + * @param[in,out]  crs     Internal reader state.
> + * @param[in]      offset  Desired offset (index record).
> + * @return 0 on success, negated error code on failure.
> + */
> +static int chlg_set_start_offset(struct chlg_reader_state *crs, u64 offset)
> +{
> +	struct chlg_rec_entry *rec;
> +	struct chlg_rec_entry *tmp;
> +
> +	mutex_lock(&crs->crs_lock);
> +	if (offset < crs->crs_start_offset) {
> +		mutex_unlock(&crs->crs_lock);
> +		return -ERANGE;
> +	}
> +
> +	crs->crs_start_offset = offset;
> +	list_for_each_entry_safe(rec, tmp, &crs->crs_rec_queue, enq_linkage) {
> +		struct changelog_rec *cr = rec->enq_record;
> +
> +		if (cr->cr_index >= crs->crs_start_offset)
> +			break;
> +
> +		crs->crs_rec_count--;
> +		enq_record_delete(rec);
> +	}
> +
> +	mutex_unlock(&crs->crs_lock);
> +	wake_up_all(&crs->crs_waitq_prod);
> +	return 0;
> +}
> +
> +/**
> + * Move read pointer to a certain record index, encoded as an offset.
> + *
> + * @param[in,out] file   File pointer to the changelog character device
> + * @param[in]	  off    Offset to skip, actually a record index, not byte count
> + * @param[in]	  whence Relative/Absolute interpretation of the offset
> + * @return the resulting position on success or negated error code on failure.
> + */
> +static loff_t chlg_llseek(struct file *file, loff_t off, int whence)
> +{
> +	struct chlg_reader_state *crs = file->private_data;
> +	loff_t pos;
> +	int rc;
> +
> +	switch (whence) {
> +	case SEEK_SET:
> +		pos = off;
> +		break;
> +	case SEEK_CUR:
> +		pos = file->f_pos + off;
> +		break;
> +	case SEEK_END:
> +	default:
> +		return -EINVAL;
> +	}
> +
> +	/* We cannot go backward */
> +	if (pos < file->f_pos)
> +		return -EINVAL;
> +
> +	rc = chlg_set_start_offset(crs, pos);
> +	if (rc != 0)
> +		return rc;
> +
> +	file->f_pos = pos;
> +	return pos;
> +}
> +
> +/**
> + * Clear record range for a given changelog reader.
> + *
> + * @param[in]  crs     Current internal state.
> + * @param[in]  reader  Changelog reader ID (cl1, cl2...)
> + * @param[in]  record  Record index up which to clear
> + * @return 0 on success, negated error code on failure.
> + */
> +static int chlg_clear(struct chlg_reader_state *crs, u32 reader, u64 record)
> +{
> +	struct obd_device *obd = crs->crs_obd;
> +	struct changelog_setinfo cs  = {
> +		.cs_recno = record,
> +		.cs_id    = reader
> +	};
> +
> +	return obd_set_info_async(NULL, obd->obd_self_export,
> +				  strlen(KEY_CHANGELOG_CLEAR),
> +				  KEY_CHANGELOG_CLEAR, sizeof(cs), &cs, NULL);
> +}
> +
> +/** Maximum changelog control command size */
> +#define CHLG_CONTROL_CMD_MAX	64
> +
> +/**
> + * Handle writes() into the changelog character device. Write() can be used
> + * to request special control operations.
> + *
> + * @param[in]  file  File pointer to the changelog character device
> + * @param[in]  buff  User supplied data (written data)
> + * @param[in]  count Number of written bytes
> + * @param[in]  off   (unused)
> + * @return number of written bytes on success, negated error code on failure.
> + */
> +static ssize_t chlg_write(struct file *file, const char __user *buff,
> +			  size_t count, loff_t *off)
> +{
> +	struct chlg_reader_state *crs = file->private_data;
> +	char *kbuf;
> +	u64 record;
> +	u32 reader;
> +	int rc = 0;
> +
> +	if (count > CHLG_CONTROL_CMD_MAX)
> +		return -EINVAL;
> +
> +	kbuf = kzalloc(CHLG_CONTROL_CMD_MAX, GFP_KERNEL);
> +	if (!kbuf)
> +		return -ENOMEM;
> +
> +	if (copy_from_user(kbuf, buff, count)) {
> +		rc = -EFAULT;
> +		goto out_kbuf;
> +	}
> +
> +	kbuf[CHLG_CONTROL_CMD_MAX - 1] = '\0';
> +
> +	if (sscanf(kbuf, "clear:cl%u:%llu", &reader, &record) == 2)
> +		rc = chlg_clear(crs, reader, record);
> +	else
> +		rc = -EINVAL;
> +
> +out_kbuf:
> +	kfree(kbuf);
> +	return rc < 0 ? rc : count;
> +}
> +
> +/**
> + * Find the OBD device associated to a changelog character device.
> + * @param[in]  cdev  character device instance descriptor
> + * @return corresponding OBD device or NULL if none was found.
> + */
> +static struct obd_device *chlg_obd_get(dev_t cdev)
> +{
> +	int minor = MINOR(cdev);
> +	struct obd_device *obd = NULL;
> +	struct chlg_registered_dev *curr;
> +
> +	mutex_lock(&chlg_registered_dev_lock);
> +	list_for_each_entry(curr, &chlg_registered_devices, ced_link) {
> +		if (curr->ced_misc.minor == minor) {
> +			/* take the first available OBD device attached */
> +			obd = list_first_entry(&curr->ced_obds,
> +					       struct obd_device,
> +					       u.cli.cl_chg_dev_linkage);
> +			break;
> +		}
> +	}
> +	mutex_unlock(&chlg_registered_dev_lock);
> +	return obd;
> +}
> +
> +/**
> + * Open handler, initialize internal CRS state and spawn prefetch thread if
> + * needed.
> + * @param[in]  inode  Inode struct for the open character device.
> + * @param[in]  file   Corresponding file pointer.
> + * @return 0 on success, negated error code on failure.
> + */
> +static int chlg_open(struct inode *inode, struct file *file)
> +{
> +	struct chlg_reader_state *crs;
> +	struct obd_device *obd = chlg_obd_get(inode->i_rdev);
> +	struct task_struct *task;
> +	int rc;
> +
> +	if (!obd)
> +		return -ENODEV;
> +
> +	crs = kzalloc(sizeof(*crs), GFP_KERNEL);
> +	if (!crs)
> +		return -ENOMEM;
> +
> +	crs->crs_obd = obd;
> +	crs->crs_err = false;
> +	crs->crs_eof = false;
> +	crs->crs_closed = false;
> +
> +	mutex_init(&crs->crs_lock);
> +	INIT_LIST_HEAD(&crs->crs_rec_queue);
> +	init_waitqueue_head(&crs->crs_waitq_prod);
> +	init_waitqueue_head(&crs->crs_waitq_cons);
> +
> +	if (file->f_mode & FMODE_READ) {
> +		task = kthread_run(chlg_load, crs, "chlg_load_thread");
> +		if (IS_ERR(task)) {
> +			rc = PTR_ERR(task);
> +			CERROR("%s: cannot start changelog thread: rc = %d\n",
> +			       obd->obd_name, rc);
> +			goto err_crs;
> +		}
> +	}
> +
> +	file->private_data = crs;
> +	return 0;
> +
> +err_crs:
> +	kfree(crs);
> +	return rc;
> +}
> +
> +/**
> + * Close handler, release resources.
> + *
> + * @param[in]  inode  Inode struct for the open character device.
> + * @param[in]  file   Corresponding file pointer.
> + * @return 0 on success, negated error code on failure.
> + */
> +static int chlg_release(struct inode *inode, struct file *file)
> +{
> +	struct chlg_reader_state *crs = file->private_data;
> +
> +	if (file->f_mode & FMODE_READ) {
> +		crs->crs_closed = true;
> +		wake_up_all(&crs->crs_waitq_prod);
> +	} else {
> +		/* No producer thread, release resource ourselves */
> +		crs_free(crs);
> +	}
> +	return 0;
> +}
> +
> +/**
> + * Poll handler, indicates whether the device is readable (new records) and
> + * writable (always).
> + *
> + * @param[in]  file   Device file pointer.
> + * @param[in]  wait   (opaque)
> + * @return combination of the poll status flags.
> + */
> +static unsigned int chlg_poll(struct file *file, poll_table *wait)
> +{
> +	struct chlg_reader_state *crs  = file->private_data;
> +	unsigned int mask = 0;
> +
> +	mutex_lock(&crs->crs_lock);
> +	poll_wait(file, &crs->crs_waitq_cons, wait);
> +	if (crs->crs_rec_count > 0)
> +		mask |= POLLIN | POLLRDNORM;
> +	if (crs->crs_err)
> +		mask |= POLLERR;
> +	if (crs->crs_eof)
> +		mask |= POLLHUP;
> +	mutex_unlock(&crs->crs_lock);
> +	return mask;
> +}
> +
> +static const struct file_operations chlg_fops = {
> +	.owner		= THIS_MODULE,
> +	.llseek		= chlg_llseek,
> +	.read		= chlg_read,
> +	.write		= chlg_write,
> +	.open		= chlg_open,
> +	.release	= chlg_release,
> +	.poll		= chlg_poll,
> +};
> +
> +/**
> + * This uses obd_name of the form: "testfs-MDT0000-mdc-ffff88006501600"
> + * and returns a name of the form: "changelog-testfs-MDT0000".
> + */
> +static void get_chlg_name(char *name, size_t name_len, struct obd_device *obd)
> +{
> +	int i;
> +
> +	snprintf(name, name_len, "changelog-%s", obd->obd_name);
> +
> +	/* Find the 2nd '-' from the end and truncate on it */
> +	for (i = 0; i < 2; i++) {
> +		char *p = strrchr(name, '-');
> +
> +		if (!p)
> +			return;
> +		*p = '\0';
> +	}
> +}
> +
> +/**
> + * Find a changelog character device by name.
> + * All devices registered during MDC setup are listed in a global list with
> + * their names attached.
> + */
> +static struct chlg_registered_dev *
> +chlg_registered_dev_find_by_name(const char *name)
> +{
> +	struct chlg_registered_dev *dit;
> +
> +	list_for_each_entry(dit, &chlg_registered_devices, ced_link)
> +		if (strcmp(name, dit->ced_name) == 0)
> +			return dit;
> +	return NULL;
> +}
> +
> +/**
> + * Find chlg_registered_dev structure for a given OBD device.
> + * This is bad O(n^2) but for each filesystem:
> + *   - N is # of MDTs times # of mount points
> + *   - this only runs at shutdown
> + */
> +static struct chlg_registered_dev *
> +chlg_registered_dev_find_by_obd(const struct obd_device *obd)
> +{
> +	struct chlg_registered_dev *dit;
> +	struct obd_device *oit;
> +
> +	list_for_each_entry(dit, &chlg_registered_devices, ced_link)
> +		list_for_each_entry(oit, &dit->ced_obds,
> +				    u.cli.cl_chg_dev_linkage)
> +			if (oit == obd)
> +				return dit;
> +	return NULL;
> +}
> +
> +/**
> + * Changelog character device initialization.
> + * Register a misc character device with a dynamic minor number, under a name
> + * of the form: 'changelog-fsname-MDTxxxx'. Reference this OBD device with it.
> + *
> + * @param[in] obd  This MDC obd_device.
> + * @return 0 on success, negated error code on failure.
> + */
> +int mdc_changelog_cdev_init(struct obd_device *obd)
> +{
> +	struct chlg_registered_dev *exist;
> +	struct chlg_registered_dev *entry;
> +	int rc;
> +
> +	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
> +	if (!entry)
> +		return -ENOMEM;
> +
> +	get_chlg_name(entry->ced_name, sizeof(entry->ced_name), obd);
> +
> +	entry->ced_misc.minor = MISC_DYNAMIC_MINOR;
> +	entry->ced_misc.name  = entry->ced_name;
> +	entry->ced_misc.fops  = &chlg_fops;
> +
> +	kref_init(&entry->ced_refs);
> +	INIT_LIST_HEAD(&entry->ced_obds);
> +	INIT_LIST_HEAD(&entry->ced_link);
> +
> +	mutex_lock(&chlg_registered_dev_lock);
> +	exist = chlg_registered_dev_find_by_name(entry->ced_name);
> +	if (exist) {
> +		kref_get(&exist->ced_refs);
> +		list_add_tail(&obd->u.cli.cl_chg_dev_linkage, &exist->ced_obds);
> +		rc = 0;
> +		goto out_unlock;
> +	}
> +
> +	/* Register new character device */
> +	rc = misc_register(&entry->ced_misc);
> +	if (rc != 0)
> +		goto out_unlock;
> +
> +	list_add_tail(&obd->u.cli.cl_chg_dev_linkage, &entry->ced_obds);
> +	list_add_tail(&entry->ced_link, &chlg_registered_devices);
> +
> +	entry = NULL;	/* prevent it from being freed below */
> +
> +out_unlock:
> +	mutex_unlock(&chlg_registered_dev_lock);
> +	kfree(entry);
> +	return rc;
> +}
> +
> +/**
> + * Deregister a changelog character device whose refcount has reached zero.
> + */
> +static void chlg_dev_clear(struct kref *kref)
> +{
> +	struct chlg_registered_dev *entry = container_of(kref,
> +							 struct chlg_registered_dev,
> +							 ced_refs);
> +	list_del(&entry->ced_link);
> +	misc_deregister(&entry->ced_misc);
> +	kfree(entry);
> +}
> +
> +/**
> + * Release OBD, decrease reference count of the corresponding changelog device.
> + */
> +void mdc_changelog_cdev_finish(struct obd_device *obd)
> +{
> +	struct chlg_registered_dev *dev = chlg_registered_dev_find_by_obd(obd);
> +
> +	mutex_lock(&chlg_registered_dev_lock);
> +	list_del_init(&obd->u.cli.cl_chg_dev_linkage);
> +	kref_put(&dev->ced_refs, chlg_dev_clear);
> +	mutex_unlock(&chlg_registered_dev_lock);
> +}
> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
> index 941a896..6da9046 100644
> --- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
> +++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
> @@ -129,6 +129,10 @@ enum ldlm_mode mdc_lock_match(struct obd_export *exp, __u64 flags,
>  			      enum ldlm_mode mode,
>  			      struct lustre_handle *lockh);
>  
> +int mdc_changelog_cdev_init(struct obd_device *obd);
> +
> +void mdc_changelog_cdev_finish(struct obd_device *obd);
> +
>  static inline int mdc_prep_elc_req(struct obd_export *exp,
>  				   struct ptlrpc_request *req, int opc,
>  				   struct list_head *cancels, int count)
> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> index 8f8e3d2..3692b1c 100644
> --- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
> +++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> @@ -35,7 +35,6 @@
>  
>  # include <linux/module.h>
>  # include <linux/pagemap.h>
> -# include <linux/miscdevice.h>
>  # include <linux/init.h>
>  # include <linux/utsname.h>
>  # include <linux/file.h>
> @@ -1810,174 +1809,6 @@ static int mdc_ioc_hsm_request(struct obd_export *exp,
>  	return rc;
>  }
>  
> -static struct kuc_hdr *changelog_kuc_hdr(char *buf, size_t len, u32 flags)
> -{
> -	struct kuc_hdr *lh = (struct kuc_hdr *)buf;
> -
> -	LASSERT(len <= KUC_CHANGELOG_MSG_MAXSIZE);
> -
> -	lh->kuc_magic = KUC_MAGIC;
> -	lh->kuc_transport = KUC_TRANSPORT_CHANGELOG;
> -	lh->kuc_flags = flags;
> -	lh->kuc_msgtype = CL_RECORD;
> -	lh->kuc_msglen = len;
> -	return lh;
> -}
> -
> -struct changelog_show {
> -	__u64		cs_startrec;
> -	enum changelog_send_flag	cs_flags;
> -	struct file	*cs_fp;
> -	char		*cs_buf;
> -	struct obd_device *cs_obd;
> -};
> -
> -static inline char *cs_obd_name(struct changelog_show *cs)
> -{
> -	return cs->cs_obd->obd_name;
> -}
> -
> -static int changelog_kkuc_cb(const struct lu_env *env, struct llog_handle *llh,
> -			     struct llog_rec_hdr *hdr, void *data)
> -{
> -	struct changelog_show *cs = data;
> -	struct llog_changelog_rec *rec = (struct llog_changelog_rec *)hdr;
> -	struct kuc_hdr *lh;
> -	size_t len;
> -	int rc;
> -
> -	if (rec->cr_hdr.lrh_type != CHANGELOG_REC) {
> -		rc = -EINVAL;
> -		CERROR("%s: not a changelog rec %x/%d: rc = %d\n",
> -		       cs_obd_name(cs), rec->cr_hdr.lrh_type,
> -		       rec->cr.cr_type, rc);
> -		return rc;
> -	}
> -
> -	if (rec->cr.cr_index < cs->cs_startrec) {
> -		/* Skip entries earlier than what we are interested in */
> -		CDEBUG(D_HSM, "rec=%llu start=%llu\n",
> -		       rec->cr.cr_index, cs->cs_startrec);
> -		return 0;
> -	}
> -
> -	CDEBUG(D_HSM, "%llu %02d%-5s %llu 0x%x t=" DFID " p=" DFID
> -		" %.*s\n", rec->cr.cr_index, rec->cr.cr_type,
> -		changelog_type2str(rec->cr.cr_type), rec->cr.cr_time,
> -		rec->cr.cr_flags & CLF_FLAGMASK,
> -		PFID(&rec->cr.cr_tfid), PFID(&rec->cr.cr_pfid),
> -		rec->cr.cr_namelen, changelog_rec_name(&rec->cr));
> -
> -	len = sizeof(*lh) + changelog_rec_size(&rec->cr) + rec->cr.cr_namelen;
> -
> -	/* Set up the message */
> -	lh = changelog_kuc_hdr(cs->cs_buf, len, cs->cs_flags);
> -	memcpy(lh + 1, &rec->cr, len - sizeof(*lh));
> -
> -	rc = libcfs_kkuc_msg_put(cs->cs_fp, lh);
> -	CDEBUG(D_HSM, "kucmsg fp %p len %zu rc %d\n", cs->cs_fp, len, rc);
> -
> -	return rc;
> -}
> -
> -static int mdc_changelog_send_thread(void *csdata)
> -{
> -	enum llog_flag flags = LLOG_F_IS_CAT;
> -	struct changelog_show *cs = csdata;
> -	struct llog_ctxt *ctxt = NULL;
> -	struct llog_handle *llh = NULL;
> -	struct kuc_hdr *kuch;
> -	int rc;
> -
> -	CDEBUG(D_HSM, "changelog to fp=%p start %llu\n",
> -	       cs->cs_fp, cs->cs_startrec);
> -
> -	cs->cs_buf = kzalloc(KUC_CHANGELOG_MSG_MAXSIZE, GFP_NOFS);
> -	if (!cs->cs_buf) {
> -		rc = -ENOMEM;
> -		goto out;
> -	}
> -
> -	/* Set up the remote catalog handle */
> -	ctxt = llog_get_context(cs->cs_obd, LLOG_CHANGELOG_REPL_CTXT);
> -	if (!ctxt) {
> -		rc = -ENOENT;
> -		goto out;
> -	}
> -	rc = llog_open(NULL, ctxt, &llh, NULL, CHANGELOG_CATALOG,
> -		       LLOG_OPEN_EXISTS);
> -	if (rc) {
> -		CERROR("%s: fail to open changelog catalog: rc = %d\n",
> -		       cs_obd_name(cs), rc);
> -		goto out;
> -	}
> -
> -	if (cs->cs_flags & CHANGELOG_FLAG_JOBID)
> -		flags |= LLOG_F_EXT_JOBID;
> -
> -	rc = llog_init_handle(NULL, llh, flags, NULL);
> -	if (rc) {
> -		CERROR("llog_init_handle failed %d\n", rc);
> -		goto out;
> -	}
> -
> -	rc = llog_cat_process(NULL, llh, changelog_kkuc_cb, cs, 0, 0);
> -
> -	/* Send EOF no matter what our result */
> -	kuch = changelog_kuc_hdr(cs->cs_buf, sizeof(*kuch), cs->cs_flags);
> -	kuch->kuc_msgtype = CL_EOF;
> -	libcfs_kkuc_msg_put(cs->cs_fp, kuch);
> -
> -out:
> -	fput(cs->cs_fp);
> -	if (llh)
> -		llog_cat_close(NULL, llh);
> -	if (ctxt)
> -		llog_ctxt_put(ctxt);
> -	kfree(cs->cs_buf);
> -	kfree(cs);
> -	return rc;
> -}
> -
> -static int mdc_ioc_changelog_send(struct obd_device *obd,
> -				  struct ioc_changelog *icc)
> -{
> -	struct changelog_show *cs;
> -	struct task_struct *task;
> -	int rc;
> -
> -	/* Freed in mdc_changelog_send_thread */
> -	cs = kzalloc(sizeof(*cs), GFP_NOFS);
> -	if (!cs)
> -		return -ENOMEM;
> -
> -	cs->cs_obd = obd;
> -	cs->cs_startrec = icc->icc_recno;
> -	/* matching fput in mdc_changelog_send_thread */
> -	cs->cs_fp = fget(icc->icc_id);
> -	cs->cs_flags = icc->icc_flags;
> -
> -	/*
> -	 * New thread because we should return to user app before
> -	 * writing into our pipe
> -	 */
> -	task = kthread_run(mdc_changelog_send_thread, cs,
> -			   "mdc_clg_send_thread");
> -	if (IS_ERR(task)) {
> -		rc = PTR_ERR(task);
> -		CERROR("%s: can't start changelog thread: rc = %d\n",
> -		       cs_obd_name(cs), rc);
> -		kfree(cs);
> -	} else {
> -		rc = 0;
> -		CDEBUG(D_HSM, "%s: started changelog thread\n",
> -		       cs_obd_name(cs));
> -	}
> -
> -	CERROR("Failed to start changelog thread: %d\n", rc);
> -	return rc;
> -}
> -
>  static int mdc_ioc_hsm_ct_start(struct obd_export *exp,
>  				struct lustre_kernelcomm *lk);
>  
> @@ -2087,21 +1918,6 @@ static int mdc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
>  		return -EINVAL;
>  	}
>  	switch (cmd) {
> -	case OBD_IOC_CHANGELOG_SEND:
> -		rc = mdc_ioc_changelog_send(obd, karg);
> -		goto out;
> -	case OBD_IOC_CHANGELOG_CLEAR: {
> -		struct ioc_changelog *icc = karg;
> -		struct changelog_setinfo cs = {
> -			.cs_recno = icc->icc_recno,
> -			.cs_id = icc->icc_id
> -		};
> -
> -		rc = obd_set_info_async(NULL, exp, strlen(KEY_CHANGELOG_CLEAR),
> -					KEY_CHANGELOG_CLEAR, sizeof(cs), &cs,
> -					NULL);
> -		goto out;
> -	}
>  	case OBD_IOC_FID2PATH:
>  		rc = mdc_ioc_fid2path(exp, karg);
>  		goto out;
> @@ -2670,12 +2486,22 @@ static int mdc_setup(struct obd_device *obd, struct lustre_cfg *cfg)
>  
>  	rc = mdc_llog_init(obd);
>  	if (rc) {
> -		CERROR("failed to setup llogging subsystems\n");
> +		CERROR("%s: failed to setup llogging subsystems: rc = %d\n",
> +		       obd->obd_name, rc);
>  		goto err_llog_cleanup;
>  	}
>  
> +	rc = mdc_changelog_cdev_init(obd);
> +	if (rc) {
> +		CERROR("%s: failed to setup changelog char device: rc = %d\n",
> +		       obd->obd_name, rc);
> +		goto err_changelog_cleanup;
> +	}
> +
>  	return 0;
>  
> +err_changelog_cleanup:
> +	mdc_llog_finish(obd);
>  err_llog_cleanup:
>  	ldebugfs_free_md_stats(obd);
>  	ptlrpc_lprocfs_unregister_obd(obd);
> @@ -2714,6 +2540,8 @@ static int mdc_precleanup(struct obd_device *obd)
>  	if (obd->obd_type->typ_refcnt <= 1)
>  		libcfs_kkuc_group_rem(0, KUC_GRP_HSM);
>  
> +	mdc_changelog_cdev_finish(obd);
> +
>  	obd_cleanup_client_import(obd);
>  	ptlrpc_lprocfs_unregister_obd(obd);
>  	lprocfs_obd_cleanup(obd);
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181030/624c8059/attachment-0001.sig>
