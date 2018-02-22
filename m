From: NeilBrown <neilb@suse.com>
Date: Thu, 22 Feb 2018 14:06:54 +1100
Subject: [lustre-devel] [PATCH 24/41] staging: lustre: clio: add
 CIT_DATA_VERSION and remove IOC_LOV_GETINFO
In-Reply-To: <1475461717-21631-25-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
 <1475461717-21631-25-git-send-email-jsimmons@infradead.org>
Message-ID: <871shdk9ip.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: "John L. Hammond" <john.hammond@intel.com>, Bobi Jam <bobijam.xu@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


Another ancient patch....


On Sun, Oct 02 2016, James Simmons wrote:

> From: John L. Hammond <john.hammond@intel.com>
>
> During development a new api, cl_object_obd_info_get()
> and cl_object_data_version() which then were later
> replaced by a better solution CIT_DATA_VERSION. For
> the case of the upstream client their is no point in
> introducing a API to only have it removed later. Due
> to the way the patches landed with their dependencies
> it is not possible to separate out two patches. These
> two combined patches do the following:
>
>  * Add a new cl_io type CIT_DATA_VERSION to get file
>    data version.
>  * Remove the unused IOC_LOV_GETINFO ioctl.
>  * Remove ll_glimpse_ioctl() and ll_lsm_getattr().
>  * Remove the OBD API method obd_getattr_async().
>
> Signed-off-by: John L. Hammond <john.hammond@intel.com>
> Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5823
> Reviewed-on: http://review.whamcloud.com/12748
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6356
> Reviewed-on: http://review.whamcloud.com/14649
> Reviewed-by: Henri Doreau <henri.doreau@cea.fr>
> Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>

With so many Reviewed-by :-)


>  
> +static void
> +lov_io_data_version_end(const struct lu_env *env, const struct cl_io_slice *ios)
> +{
> +	struct lov_io *lio = cl2lov_io(env, ios);
> +	struct cl_io *parent = lio->lis_cl.cis_io;
> +	struct lov_io_sub *sub;
> +
> +	list_for_each_entry(sub, &lio->lis_active, sub_linkage) {
> +		lov_io_end_wrapper(env, sub->sub_io);

This sort of construct occurs several other times in the same file:

lov_io_read_ahead:
	rc = cl_io_read_ahead(sub->sub_env, sub->sub_io,

lov_io_submit:
		rc = cl_io_submit_rw(sub->sub_env, sub->sub_io,
				     crt, queue);

lio_io_commit_async:
		rc = cl_io_commit_async(sub->sub_env, sub->sub_io, queue,
					from, to, cb);

lov_io_fsync_end:
		struct cl_io *subio = sub->sub_io;
		lov_io_end_wrapper(sub->sub_env, subio);


Every other time, sub->sub_env is used with sub->sub_io.
In this new code, 'env' is (incorrectly) used with sub->sub_io.

This reliably causes my testing to crash as the LNVRNT() in cl2osc_io()
fails, and I test with
   CONFIG_LUSTRE_DEBUG_EXPENSIVE_CHECK=y

Does anyone have any idea why no other testing trips over this?

lustre-release has the same bug in
  Commit: fcd45488711a ("LU-5683 clio: add CIT_DATA_VERSION")

I'll send a patch for Linux.  Someone else might like to fix
lustre-release.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180222/0749fe05/attachment.sig>
