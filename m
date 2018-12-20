From: NeilBrown <neilb@suse.com>
Date: Thu, 20 Dec 2018 12:39:48 +1100
Subject: [lustre-devel] [PATCH RFC 00/28] lustre: PFL port to linux
 client
In-Reply-To: <87mup39wy8.fsf@notabene.neil.brown.name>
References: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
 <87mup39wy8.fsf@notabene.neil.brown.name>
Message-ID: <87y38lt1qz.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Dec 18 2018, NeilBrown wrote:

> On Mon, Dec 17 2018, James Simmons wrote:
>
>> This is the initial PFL port to the linux lustre client. This opens
>> up feed back on the port so far. Currently sanity passes but the
>> test for sanity-pfl fail as below. I have been tracking downing
>> various bugs but this one remains and I haven't found out why its
>> failing. So far from what I can tell is lov_io_setattr_iter_init()
>> it returning -ENODATA due to lsm_entry_inited() is not initialized.
>
> Having that invariant in cl_io_iter_fini() seems strange.
> It is guaranteed to fir eif cl_io_iter_init() fails - if that is not
> permitted, I would expect an invariant a lot closer to the failure.
>
> What happens if you just remove the LINVRNT() ??

I dug through the code some more, and I'm sure that LINVRNT() is wrong.

The cl_io_iter() call is meant to fail early, before ci_state gets to
CIS_LOCKED, let alone CIS_UNLOCKED.  It sets ->ci_need_write_intent when
it records the failure.  The code is then meant to fall through to
the cl_io_fini() call in cl_setattr_ost(), which calls into vvp_io_fini)_
which notices ->ci_need_write_intent, and calls ll_layout_write_intent(),
which presumably initializes the things that weren't initialized before.
This also sets ->ci_need_restart = 1 so that cl_setattr_ost() loops
around to "again:" and calls cl_io_init() again.

So the invariant in cl_io_iter_fini() should probably be

	LINVRNT(io->ci_state == CIS_INIT || io->ci_state == CIS_UNLOCKED);

or something like that.  Maybe needs CIS_IT_ENDED as well.

	LINVRNT(io->ci_state <= CIS_INIT || io->ci_state >= CIS_UNLOCKED);

??

Thanks,
NeilBrown

>
> NeilBrown
>
>> Hoping that sending this out more eyes might help to see where this
>> last problem is.
>>
>> Lustre: DEBUG MARKER: == sanity-pfl test 0: Create full components file, no reused OSTs =======
>> ============================= 10:53:08 (1545061988)
>> Lustre: DEBUG MARKER: create directory /lustre/lustre/d0.sanity-pfl
>> Lustre: DEBUG MARKER: create comp_file
>> Lustre: DEBUG MARKER: instantiate components
>> LustreError: 19350:0:(cl_io.c:439:cl_io_iter_fini()) ASSERTION( io->ci_state == CIS_UNLOCKED )
>> failed:
>> LustreError: 19350:0:(cl_io.c:439:cl_io_iter_fini()) LBUG
>> Pid: 19350, comm: dd 4.20.0-rc6+ #1 SMP PREEMPT Sat Dec 15 11:22:06 EST 2018
>> Call Trace:
>>   libcfs_call_trace+0x8b/0xc0 [libcfs]
>>   lbug_with_loc+0x41/0x90 [libcfs]
>>   cl_io_iter_fini+0x10c/0x110 [obdclass]
>>   cl_io_loop+0x46/0x220 [obdclass]
>>   cl_setattr_ost+0x1ed/0x2a0 [lustre]
>>   ll_setattr_raw+0x797/0x980 [lustre]
>>   notify_change+0x1dc/0x430
>>   do_truncate+0x72/0xc0
>>   do_sys_ftruncate+0xf5/0x160
>>   do_syscall_64+0x68/0x38f
>>
>> Bobi Jam (20):
>>   lustre: lov: move code for PFL work
>>   lustre: lov: merge lov_mds_md_v3 and lov_mds_md_v1 handling
>>   lustre: lov: fold lmm_verify() handling into lmm_unpackmd()
>>   lustre: lov: create struct lov_stripe_md_entry
>>   lustre: lov: add composite layout unpacking
>>   lustre: lov: embedded raid0 in struct lov_layout_composite
>>   lustre: lov: migrate lov raid0 to future PFL component handling
>>   lustre: lov: reduce code indentation
>>   lustre: lov: change lo_entries to array.
>>   lustre: lov: move around PFL code and cleanups
>>   lustre: lov: remove lsm_stripe_by_[index|offset]_plain
>>   lustre: lov: add looping lsm_entry_count times
>>   lustre: lov: create lov_comp_* wrappers
>>   lustre: clio: client side implementation for PFL
>>   lustre: pfl: dynamic layout modification with write/truncate
>>   lustre: pfl: calculate PFL file LOVEA correctly
>>   lustre: lov: keep minimum LOVEA size
>>   lustre: pfl: fix hang with grouplocks
>>   lustre: pfl: fix ost pool op->size handling
>>   lustre: llite: restore ll_file_getstripe in ll_lov_setstripe
>>
>> Fan Yong (1):
>>   lustre: pfl: enhance PFID EA for PFL
>>
>> Jinshan Xiong (3):
>>   lustre: pfl: Read should not trigger layout write intent
>>   lustre: lov: readahead shouldn't exceed component boundary
>>   lustre: lov: do not split IO for single striped file
>>
>> Niu Yawei (4):
>>   lustre: pfl: Basic data structures for composite layout
>>   lustre: clio: getstripe support comp layout
>>   lustre: uapi: support negative flags
>>   lustre: llite: return v1/v3 layout for legacy app
>>
>>  .../lustre/include/uapi/linux/lustre/lustre_idl.h  |  36 +-
>>  .../lustre/include/uapi/linux/lustre/lustre_user.h |  88 ++-
>>  drivers/staging/lustre/lustre/include/cl_object.h  |  12 +-
>>  drivers/staging/lustre/lustre/include/lustre_sec.h |   4 +-
>>  .../staging/lustre/lustre/include/lustre_swab.h    |   1 +
>>  drivers/staging/lustre/lustre/include/obd.h        |   4 -
>>  drivers/staging/lustre/lustre/llite/dir.c          |  38 +-
>>  drivers/staging/lustre/lustre/llite/file.c         | 185 +++--
>>  .../staging/lustre/lustre/llite/llite_internal.h   |   3 +
>>  drivers/staging/lustre/lustre/llite/vvp_io.c       |  44 +-
>>  drivers/staging/lustre/lustre/llite/xattr.c        |  70 +-
>>  .../staging/lustre/lustre/lov/lov_cl_internal.h    | 191 ++---
>>  drivers/staging/lustre/lustre/lov/lov_ea.c         | 570 ++++++++++----
>>  drivers/staging/lustre/lustre/lov/lov_internal.h   | 175 +++--
>>  drivers/staging/lustre/lustre/lov/lov_io.c         | 651 +++++++++-------
>>  drivers/staging/lustre/lustre/lov/lov_lock.c       |  94 ++-
>>  drivers/staging/lustre/lustre/lov/lov_merge.c      |  12 +-
>>  drivers/staging/lustre/lustre/lov/lov_object.c     | 833 ++++++++++++---------
>>  drivers/staging/lustre/lustre/lov/lov_offset.c     |  65 +-
>>  drivers/staging/lustre/lustre/lov/lov_pack.c       | 364 +++++----
>>  drivers/staging/lustre/lustre/lov/lov_page.c       |  42 +-
>>  drivers/staging/lustre/lustre/lov/lov_pool.c       |  20 +-
>>  drivers/staging/lustre/lustre/lov/lovsub_object.c  |  23 +-
>>  drivers/staging/lustre/lustre/mdc/mdc_locks.c      |  79 +-
>>  drivers/staging/lustre/lustre/obdclass/cl_object.c |   5 +-
>>  drivers/staging/lustre/lustre/obdclass/genops.c    |  16 +-
>>  drivers/staging/lustre/lustre/osc/osc_io.c         |   4 +-
>>  drivers/staging/lustre/lustre/ptlrpc/layout.c      |   6 +-
>>  .../staging/lustre/lustre/ptlrpc/pack_generic.c    |  84 ++-
>>  .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |   7 +-
>>  drivers/staging/lustre/lustre/ptlrpc/sec.c         |   5 +-
>>  drivers/staging/lustre/lustre/ptlrpc/wiretest.c    | 125 +++-
>>  32 files changed, 2483 insertions(+), 1373 deletions(-)
>>
>> -- 
>> 1.8.3.1
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
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181220/04645519/attachment.sig>
