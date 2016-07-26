From: Joe Perches <joe@perches.com>
Date: Mon, 25 Jul 2016 18:47:47 -0700
Subject: [lustre-devel] [PATCH 12/15] staging/lustre: Add spaces
 preferred around that '{+, -, *, /, |, <<, >>, &}'
In-Reply-To: <974D47D2-320C-42C0-BA73-1DA12B73737F@linuxhacker.ru>
References: <1469255832-746785-1-git-send-email-green@linuxhacker.ru>
	<1469255832-746785-13-git-send-email-green@linuxhacker.ru>
	<1469295072.1900.162.camel@perches.com>
	<974D47D2-320C-42C0-BA73-1DA12B73737F@linuxhacker.ru>
Message-ID: <1469497667.1900.203.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Emoly Liu <emoly.liu@intel.com>

On Sat, 2016-07-23 at 14:01 -0400, Oleg Drokin wrote:
> On Jul 23, 2016, at 1:31 PM, Joe Perches wrote:
[]
> > And lustre seems to use types with unnecessary __ prefixes.
> Need to see if this file is included in userspace where the __ is needed.

Maybe it'd be good to change the top level makefile to
add -I<non-uapi_dir> and -I<uapi_dir> and then move the
various files appropriately.

And all the odd depth #include "<some..depth>/include/<file>"
could then be rationalized without regard to source file
directory layout.

$ grep -roh 'include ".*include.*"' drivers/staging/lustre/|sort|uniq -c|sort -rn
?????82 include "../include/obd_class.h"
?????82 include "../../include/linux/libcfs/libcfs.h"
?????66 include "../include/obd_support.h"
?????35 include "../include/obd.h"
?????32 include "../include/lustre_net.h"
?????32 include "../include/lustre_dlm.h"
?????27 include "../include/lprocfs_status.h"
?????26 include "../include/lustre_lite.h"
?????22 include "../../include/linux/lnet/lib-lnet.h"
?????21 include "../include/lustre_fid.h"
?????21 include "../include/cl_object.h"
?????20 include "../include/lustre/lustre_idl.h"
?????17 include "../include/lustre_lib.h"
?????13 include "../../../include/linux/libcfs/libcfs.h"
?????12 include "../include/lustre_log.h"
??????9 include "../include/obd_cksum.h"
??????9 include "../include/lustre_sec.h"
??????9 include "../include/lustre_req_layout.h"
??????9 include "../include/lustre_ha.h"
??????8 include "../include/lustre_ver.h"
??????8 include "../include/lustre_import.h"
??????8 include "../../include/linux/lnet/lnetst.h"
??????7 include "../include/lustre_param.h"
??????7 include "../include/lustre_mdc.h"
??????7 include "../../include/linux/lnet/lnet.h"
??????6 include "../include/lustre_disk.h"
??????6 include "../include/lustre_debug.h"
??????5 include "../include/lustre_kernelcomm.h"
??????5 include "../../include/linux/lnet/lib-types.h"
??????4 include "../include/lustre/lustre_user.h"
??????4 include "../include/lustre_intent.h"
??????4 include "../include/lustre_fld.h"
??????4 include "../include/lustre_export.h"
??????4 include "../include/linux/lustre_compat25.h"
??????4 include "../../include/linux/lnet/lib-dlc.h"
??????3 include "../include/lustre/ll_fiemap.h"
??????3 include "../include/lustre_acl.h"
??????3 include "../../../include/linux/lnet/lnet.h"
??????3 include "../../../include/linux/lnet/lib-lnet.h"
??????2 include "../../include/obd_support.h"
??????2 include "../../include/obd_class.h"
??????2 include "../include/lustre_mds.h"
??????2 include "../include/lustre_eacl.h"
??????2 include "../include/lu_ref.h"
??????2 include "../include/lu_object.h"
??????2 include "../../include/lprocfs_status.h"
??????2 include "../../include/linux/lnet/types.h"
??????2 include "../../../include/linux/lnet/socklnd.h"
??????2 include "../../include/linux/lnet/lnetctl.h"
??????2 include "../../include/linux/libcfs/libcfs_hash.h"
??????2 include "../../include/linux/libcfs/libcfs_crypto.h"
??????1 include "../../include/lustre_ver.h"
??????1 include "../../include/lustre/lustre_idl.h"
??????1 include "../include/lustre/lustre_errno.h"
??????1 include "../include/lustre_handles.h"
??????1 include "../../include/linux/lustre_compat25.h"
??????1 include "../../../include/linux/lnet/types.h"
??????1 include "../../include/linux/lnet/nidstr.h"
??????1 include "../../../include/linux/lnet/lnetctl.h"
??????1 include "../../include/linux/lnet/api.h"
??????1 include "../../../include/linux/libcfs/libcfs_crypto.h"
??????1 include "../include/interval_tree.h"
