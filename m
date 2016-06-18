From: Oleg Drokin <oleg.drokin@intel.com>
Date: Sat, 18 Jun 2016 12:20:53 -0400
Subject: [lustre-devel] dead??? URLs in code/comments
In-Reply-To: <a6359829-3b23-d2b2-9efa-cad5f0c63812@gmail.com>
References: <a6359829-3b23-d2b2-9efa-cad5f0c63812@gmail.com>
Message-ID: <D61CFFFF-2CED-4C48-ABBE-A12FF11A92B3@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Jun 18, 2016, at 5:50 AM, Xose Vazquez Perez wrote:

> Hi,
> 
> Do you want to keep these URLs?
> 
> include/linux/libcfs/libcfs_crypto.h: * Please  visit http://www.xyratex.com/contact if you need additional
> lnet/libcfs/linux/linux-crypto.c: * Please  visit http://www.xyratex.com/contact if you need additional
> lnet/libcfs/linux/linux-crypto.h: * Please  visit http://www.xyratex.com/contact if you need additional
> lnet/libcfs/linux/linux-crypto-adler.c: * Please  visit http://www.xyratex.com/contact if you need additional

We can let Seagate deal with that I guess.

> include/linux/libcfs/libcfs_hash.h: * http://www.citi.umich.edu/techreports/reports/citi-tr-00-1.pdf

This one is still alive, why kill it?

> 
> lnet/lnet/router.c: *   http://sourceforge.net/projects/sandiaportals/
> lnet/lnet/router_proc.c: *   http://sourceforge.net/projects/sandiaportals/

This one is also alive and it does point to predecessor of the code.

> lustre/include/lustre_fid.h: * http://wiki.lustre.org/index.php/Architecture_-_Interoperability_fids_zfs
> lustre/include/lustre/lustre_idl.h: * http://arch.lustre.org/index.php?title=Interoperability_fids_zfs
> lustre/include/lustre/lustre_idl.h: * http://arch.lustre.org/index.php?title=Interoperability_fids_zfs#NEW.0

Hm, these were moved to, I guess 
http://wiki.old.lustre.org/index.php/Architecture_-_Interoperability_fids_zfs

We can change that. The ZFS is relatively new and sure, it's server side,
but there are client implications, that's why the pointer is still useful.

> lustre/Kconfig:   http://downloads.whamcloud.com/public/lustre/
> 
> lustre/Kconfig:   http://git.whamcloud.com/?p=fs/lustre-release.git;a=summary

These two still work just fine.
They are pointers to the userspace tools (you know, you need them to operate)
and to server side stuff (that I imagine you might want too unless you bought
it from a vendor).

> lustre/llite/llite_lib.c:                        "inode="DFID"(%p) nrpages=%lu, see http://jira.whamcloud.com/browse/LU-118\n",
> 
> lustre/obdecho/echo_client.c:   LCONSOLE_INFO("Echo OBD driver; http://www.lustre.org/\n");
> 
> lustre/osc/osc_request.c:                       CWARN("Saw flags 0x%x and 0x%x in the same brw, please report this at http://bugs.whamcloud.com/\n",
> 
> lustre/ptlrpc/import.c:         CERROR("%s went back in time (transno %lld was previously committed, server now claims %lld)!  See https://bugzilla.lustre.org/show_bug.cgi?id=9646\n",

What's wrong with these, they are essentially pointers to documentation in one way or
the other.
