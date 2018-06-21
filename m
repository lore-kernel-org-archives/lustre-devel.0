From: NeilBrown <neilb@suse.com>
Date: Thu, 21 Jun 2018 13:00:54 +1000
Subject: [lustre-devel] [PATCH 00/24] lustre - more cleanups including
 module reduction.
In-Reply-To: <DM3PR1101MB1213DDB7FC857EE6B1444153CB760@DM3PR1101MB1213.namprd11.prod.outlook.com>
References: <152904663333.10587.10934053155404014785.stgit@noble>
 <alpine.LFD.2.21.1806210239190.3886@casper.infradead.org>
 <DM3PR1101MB1213DDB7FC857EE6B1444153CB760@DM3PR1101MB1213.namprd11.prod.outlook.com>
Message-ID: <87o9g4des9.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jun 21 2018, Patrick Farrell wrote:

> Huh?  Very little of the client is used on the server.  The vast majority of the client is llite, vvp, then lov, osc, and mdc.  These are not used on the servers at all, the modules won't even be loaded.
>
>
> Servers are definitely *not* clients of one another in the sense of "Lustre clients".  They interact with each other, but in a manner very different from client to server.
>
> The ldlm and ptlrpc layers are *partly* shared, and of course, the networking from lnet down is.  But that's not "the client".
>
> The statement that the server layer is a middle layer on top of the client code doesn't make any sense to me.  It's like this:

So llite fid fld lmv lov mdc mgc osc and obdclass
can all be in a "lustre" module.
ldlm and ptlrpc should be in a separate "ptlrpc" module.
And lnet and the klnds are also separate.

On the server side we would have
  lod mdd mdt mgs ofd osp ost

does that seem approximately right?

Thanks,
NeilBrown


>
>
> vfs
> client code
>
> ptlrpc
>
> networking
>
> ------ PHYSICAL BOUNDARY --------
> networking
>
> ptlrpc
>
> server code
>
> ldiskfs
>
>
>
> with LDLM also being explicitly shared, though client & server code is not all shared.  Very little to nothing outside of the networking & ldlm layers is shared.
>
> ________________________________
> From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of James Simmons <jsimmons@infradead.org>
> Sent: Wednesday, June 20, 2018 8:48:07 PM
> To: NeilBrown
> Cc: Oleg Drokin; Andreas Dilger; Lustre Development List
> Subject: Re: [lustre-devel] [PATCH 00/24] lustre - more cleanups including module reduction.
>
>
>> Here are a bunch more cleanups that will appear in my lustre-testing
>> tree shortly.
>>
>> The interesting stuff is some enhancements to kbuild to let us
>> build modules from multiple directories.
>> I've used that to clean up the build of ptlrpc+ldlm and to
>> merge libcfs and lnet into the one module - I've left the lnds
>> separate.
>
> That looks pretty good. It doesn't apply to the stable lustre tree but I
> did try it out on lustre-testing. The module building does seem to
> function well. Only thing not clear is if do a
>
> make SUBDIRS=drivers/staging/lustre/lustre/lmv modules
>
> do lmv.a and the other *.a files get relinked int lustre.ko ?
>
>> I've haven't progressed further in lustre because I'm not sure which -
>> if any - modules are also used by the server.
>> I'd rather shared code was in a separate module to client-only.
>>
>> Which parts of lustre/lustre/* are also used by server?
>
> Basically all the client code is reused on the server except for llite.
> The reason is each server type MDS, MGS, or OSS is treated as a client
> to each other. So in affect the server code is a middle layer level on
> top of the client code.
>
>> After that, it is all fairly simple cleanups.
>>
>> I plan to submit the kbuild stuff upstream next week.
>>
>> Thanks,
>> NeilBrown
>>
>> ---
>>
>> NeilBrown (24):
>>       kbuild: detect directories in components of a module.
>>       kbuild: treat a directory listed in a composite object as foo/mod.a
>>       kbuild: support building of per-directory mod.a
>>       kbuild: disable KBUILD_MODNAME when building for mod.a
>>       kbuild: Add documentation for modobj-m
>>       lustre: build ldlm in the ldlm directory.
>>       lustre: merge libcfs module into lnet.
>
> This seems to work when I tried the lustre-testing tree. I did see
> regression to related to this work in that tree.
>
>>       lustre: use truncate_inode_page in place of truncate_complete_page
>>       lustre: don't use spare bits in iattr.ia_valid
>>       lustre: remove lustre_patchless_compat.h
>>       lustre: discard current_n*groups macros.
>>       lustre: discard LTIME_S macro
>>       lustre: discard NO_QUOTA and QUOTA_OK
>>       lustre: discard ext2* bit operations
>>       lustre: centralize TIMES_SET_FLAGS
>>       lustre: remove redefinition of module_init().
>>       lustre: remove lustre_compat.h
>
> The first two patches of the above seem to break things. The first one was
> pointed out so I avoid issues in my testing by changing the patch to just
> move truncate_inode_page() to lustre_mdc.h for now. The next patch does
> break things.
>
>>       lustre/lnet: move tracefile locking from linux-tracefile.c to tracefile.c
>>       lustre: open code cfs_trace_max_debug_mb() into cfs_trace_set_debug_mb()
>>       lustre: move tcd locking across to tracefile.c
>>       lustre: move remainder of linux-tracefile.c to tracefile.c
>>       lustre: fold cfs_tracefile_*_arch into their only callers.
>>       lustre: renamed CFS_TCD_TYPE_MAX to CFS_TCD_TYPE_CNT
>>       lustre: discard TCD_MAX_TYPES
>
> I see breakage in this code as well.
>
>>  Documentation/kbuild/makefiles.txt                 |   65 +++++
>>  drivers/staging/lustre/lnet/Makefile               |    7 -
>>  drivers/staging/lustre/lnet/libcfs/Makefile        |    7 -
>>  drivers/staging/lustre/lnet/libcfs/debug.c         |    6
>>  .../staging/lustre/lnet/libcfs/linux-tracefile.c   |  258 --------------------
>>  drivers/staging/lustre/lnet/libcfs/module.c        |   26 +-
>>  drivers/staging/lustre/lnet/libcfs/tracefile.c     |  241 +++++++++++++++++--
>>  drivers/staging/lustre/lnet/libcfs/tracefile.h     |   40 ---
>>  drivers/staging/lustre/lnet/lnet/Makefile          |   11 -
>>  drivers/staging/lustre/lnet/lnet/module.c          |    9 +
>>  drivers/staging/lustre/lustre/fid/lproc_fid.c      |    1
>>  drivers/staging/lustre/lustre/fld/lproc_fld.c      |    1
>>  drivers/staging/lustre/lustre/include/cl_object.h  |    6
>>  .../staging/lustre/lustre/include/lustre_compat.h  |   82 ------
>>  drivers/staging/lustre/lustre/include/lustre_net.h |    1
>>  .../lustre/include/lustre_patchless_compat.h       |   68 -----
>>  drivers/staging/lustre/lustre/include/obd.h        |    7 +
>>  .../staging/lustre/lustre/include/obd_support.h    |    1
>>  drivers/staging/lustre/lustre/ldlm/Makefile        |   11 +
>>  drivers/staging/lustre/lustre/llite/dir.c          |    3
>>  drivers/staging/lustre/lustre/llite/file.c         |   36 +--
>>  drivers/staging/lustre/lustre/llite/lcommon_cl.c   |   11 -
>>  .../staging/lustre/lustre/llite/llite_internal.h   |   13 +
>>  drivers/staging/lustre/lustre/llite/llite_lib.c    |   52 ++--
>>  drivers/staging/lustre/lustre/llite/namei.c        |   16 +
>>  drivers/staging/lustre/lustre/llite/vvp_io.c       |    8 -
>>  drivers/staging/lustre/lustre/llite/vvp_object.c   |    6
>>  drivers/staging/lustre/lustre/lmv/lmv_intent.c     |    6
>>  drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   21 +-
>>  drivers/staging/lustre/lustre/lov/lov_io.c         |    3
>>  drivers/staging/lustre/lustre/lov/lov_obd.c        |    2
>>  drivers/staging/lustre/lustre/lov/lov_pack.c       |    1
>>  drivers/staging/lustre/lustre/lov/lov_page.c       |    1
>>  drivers/staging/lustre/lustre/mdc/mdc_lib.c        |   19 +
>>  drivers/staging/lustre/lustre/mdc/mdc_reint.c      |    4
>>  drivers/staging/lustre/lustre/mdc/mdc_request.c    |   12 -
>>  drivers/staging/lustre/lustre/obdclass/class_obd.c |    1
>>  drivers/staging/lustre/lustre/obdclass/llog.c      |    7 -
>>  .../lustre/lustre/obdclass/lprocfs_status.c        |    1
>>  .../staging/lustre/lustre/obdclass/obd_config.c    |    1
>>  drivers/staging/lustre/lustre/obdclass/obd_mount.c |    1
>>  drivers/staging/lustre/lustre/obdclass/obdo.c      |   10 -
>>  .../staging/lustre/lustre/obdecho/echo_client.c    |    1
>>  drivers/staging/lustre/lustre/osc/lproc_osc.c      |    1
>>  drivers/staging/lustre/lustre/osc/osc_cache.c      |    4
>>  drivers/staging/lustre/lustre/osc/osc_io.c         |   23 +-
>>  drivers/staging/lustre/lustre/osc/osc_quota.c      |    4
>>  drivers/staging/lustre/lustre/osc/osc_request.c    |    1
>>  drivers/staging/lustre/lustre/ptlrpc/Makefile      |   12 -
>>  drivers/staging/lustre/lustre/ptlrpc/import.c      |    1
>>  .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |    1
>>  drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |    1
>>  drivers/staging/lustre/lustre/ptlrpc/sec.c         |   15 +
>>  drivers/staging/lustre/lustre/ptlrpc/sec_plain.c   |    1
>>  drivers/staging/lustre/lustre/ptlrpc/service.c     |    1
>>  scripts/Makefile.build                             |   57 +++-
>>  scripts/Makefile.lib                               |   63 +++--
>>  57 files changed, 584 insertions(+), 685 deletions(-)
>>  delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
>>  delete mode 100644 drivers/staging/lustre/lustre/include/lustre_compat.h
>>  delete mode 100644 drivers/staging/lustre/lustre/include/lustre_patchless_compat.h
>>  create mode 100644 drivers/staging/lustre/lustre/ldlm/Makefile
>>
>> --
>> Signature
>>
>>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180621/c2bc7f0e/attachment-0001.sig>
