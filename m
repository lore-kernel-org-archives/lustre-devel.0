From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 3 Jan 2017 15:12:48 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: headers: potential UAPI
	headers
In-Reply-To: <1482167207-22800-1-git-send-email-jsimmons@infradead.org>
References: <1482167207-22800-1-git-send-email-jsimmons@infradead.org>
Message-ID: <20170103141248.GA8695@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Dec 19, 2016 at 12:06:47PM -0500, James Simmons wrote:
> Not for landing. This is the purposed UAPI headers
> with the removal of unlikely and debugging macros.
> This is just for feedback to see if this is acceptable
> for the upstream client.
> 
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  .../lustre/lustre/include/lustre/lustre_fid.h      | 353 +++++++++++++++++++++
>  .../lustre/lustre/include/lustre/lustre_ostid.h    | 233 ++++++++++++++

Can you make a lustre "uapi" directory so we can see which files you
really want to be UAPI and which you don't as time goes on?


>  2 files changed, 586 insertions(+)
>  create mode 100644 drivers/staging/lustre/lustre/include/lustre/lustre_fid.h
>  create mode 100644 drivers/staging/lustre/lustre/include/lustre/lustre_ostid.h
> 
> diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre/lustre_fid.h
> new file mode 100644
> index 0000000..cb6afa5
> --- /dev/null
> +++ b/drivers/staging/lustre/lustre/include/lustre/lustre_fid.h
> @@ -0,0 +1,353 @@
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
> + * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
> + * Use is subject to license terms.
> + *
> + * Copyright (c) 2011, 2014, Intel Corporation.
> + *
> + * Copyright 2016 Cray Inc, all rights reserved.
> + * Author: Ben Evans.
> + *
> + * all fid manipulation functions go here
> + *
> + * FIDS are globally unique within a Lustre filessytem, and are made up
> + * of three parts: sequence, Object ID, and version.
> + *
> + */
> +#ifndef _LUSTRE_LUSTRE_FID_H_
> +#define _LUSTRE_LUSTRE_FID_H_
> +
> +#include <lustre/lustre_idl.h>
> +
> +/** returns fid object sequence */
> +static inline __u64 fid_seq(const struct lu_fid *fid)
> +{
> +	return fid->f_seq;
> +}
> +
> +/** returns fid object id */
> +static inline __u32 fid_oid(const struct lu_fid *fid)
> +{
> +	return fid->f_oid;
> +}
> +
> +/** returns fid object version */
> +static inline __u32 fid_ver(const struct lu_fid *fid)
> +{
> +	return fid->f_ver;
> +}
> +
> +static inline void fid_zero(struct lu_fid *fid)
> +{
> +	memset(fid, 0, sizeof(*fid));
> +}
> +
> +static inline __u64 fid_ver_oid(const struct lu_fid *fid)
> +{
> +	return (__u64)fid_ver(fid) << 32 | fid_oid(fid);
> +}
> +
> +static inline bool fid_seq_is_mdt0(__u64 seq)
> +{
> +	return seq == FID_SEQ_OST_MDT0;
> +}
> +
> +static inline bool fid_seq_is_mdt(__u64 seq)
> +{
> +	return seq == FID_SEQ_OST_MDT0 || seq >= FID_SEQ_NORMAL;
> +};
> +
> +static inline bool fid_seq_is_echo(__u64 seq)
> +{
> +	return seq == FID_SEQ_ECHO;
> +}
> +
> +static inline bool fid_is_echo(const struct lu_fid *fid)
> +{
> +	return fid_seq_is_echo(fid_seq(fid));
> +}
> +
> +static inline bool fid_seq_is_llog(__u64 seq)
> +{
> +	return seq == FID_SEQ_LLOG;
> +}
> +
> +static inline bool fid_is_llog(const struct lu_fid *fid)
> +{
> +	/* file with OID == 0 is not llog but contains last oid */
> +	return fid_seq_is_llog(fid_seq(fid)) && fid_oid(fid) > 0;
> +}
> +
> +static inline bool fid_seq_is_rsvd(__u64 seq)
> +{
> +	return seq > FID_SEQ_OST_MDT0 && seq <= FID_SEQ_RSVD;
> +};
> +
> +static inline bool fid_seq_is_special(__u64 seq)
> +{
> +	return seq == FID_SEQ_SPECIAL;
> +};
> +
> +static inline bool fid_seq_is_local_file(__u64 seq)
> +{
> +	return seq == FID_SEQ_LOCAL_FILE ||
> +	       seq == FID_SEQ_LOCAL_NAME;
> +};
> +
> +static inline bool fid_seq_is_root(__u64 seq)
> +{
> +	return seq == FID_SEQ_ROOT;
> +}
> +
> +static inline bool fid_seq_is_dot(__u64 seq)
> +{
> +	return seq == FID_SEQ_DOT_LUSTRE;
> +}
> +
> +static inline bool fid_seq_is_default(__u64 seq)
> +{
> +	return seq == FID_SEQ_LOV_DEFAULT;
> +}
> +
> +static inline bool fid_is_mdt0(const struct lu_fid *fid)
> +{
> +	return fid_seq_is_mdt0(fid_seq(fid));
> +}
> +
> +static inline void lu_root_fid(struct lu_fid *fid)
> +{
> +	fid->f_seq = FID_SEQ_ROOT;
> +	fid->f_oid = FID_OID_ROOT;
> +	fid->f_ver = 0;
> +}
> +
> +static inline void lu_echo_root_fid(struct lu_fid *fid)
> +{
> +	fid->f_seq = FID_SEQ_ROOT;
> +	fid->f_oid = FID_OID_ECHO_ROOT;
> +	fid->f_ver = 0;
> +}
> +
> +static inline void lu_update_log_fid(struct lu_fid *fid, __u32 index)
> +{
> +	fid->f_seq = FID_SEQ_UPDATE_LOG;
> +	fid->f_oid = index;
> +	fid->f_ver = 0;
> +}
> +
> +static inline void lu_update_log_dir_fid(struct lu_fid *fid, __u32 index)
> +{
> +	fid->f_seq = FID_SEQ_UPDATE_LOG_DIR;
> +	fid->f_oid = index;
> +	fid->f_ver = 0;
> +}
> +
> +/**
> + * Check if a fid is igif or not.
> + * \param fid the fid to be tested.
> + * \return true if the fid is an igif; otherwise false.
> + */
> +static inline bool fid_seq_is_igif(__u64 seq)
> +{
> +	return seq >= FID_SEQ_IGIF && seq <= FID_SEQ_IGIF_MAX;
> +}
> +
> +static inline bool fid_is_igif(const struct lu_fid *fid)
> +{
> +	return fid_seq_is_igif(fid_seq(fid));
> +}
> +
> +/**
> + * Check if a fid is idif or not.
> + * \param fid the fid to be tested.
> + * \return true if the fid is an idif; otherwise false.

Odd kernel doc style :(

> + */
> +static inline bool fid_seq_is_idif(__u64 seq)
> +{
> +	return seq >= FID_SEQ_IDIF && seq <= FID_SEQ_IDIF_MAX;
> +}
> +
> +static inline bool fid_is_idif(const struct lu_fid *fid)
> +{
> +	return fid_seq_is_idif(fid_seq(fid));
> +}
> +
> +static inline bool fid_is_local_file(const struct lu_fid *fid)
> +{
> +	return fid_seq_is_local_file(fid_seq(fid));
> +}
> +
> +static inline bool fid_seq_is_norm(__u64 seq)
> +{
> +	return (seq >= FID_SEQ_NORMAL);
> +}
> +
> +static inline bool fid_is_norm(const struct lu_fid *fid)
> +{
> +	return fid_seq_is_norm(fid_seq(fid));
> +}
> +
> +static inline int fid_is_layout_rbtree(const struct lu_fid *fid)
> +{
> +	return fid_seq(fid) == FID_SEQ_LAYOUT_RBTREE;
> +}

bool?

thanks,

greg k-h
