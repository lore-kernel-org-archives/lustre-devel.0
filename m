From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 2 Mar 2011 14:23:52 -0700
Subject: [Lustre-devel] system crashes mounting mds
In-Reply-To: <4D6EA112.8040400@mellanox.com>
References: <4D6EA112.8040400@mellanox.com>
Message-ID: <2938460B-B801-4692-8C79-2AC4A7B29C27@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2011-03-02, at 12:57 PM, Vu Pham wrote:
> I got system crash with message "BUG: scheduling while atomic: 
> Lustre:     Lustre Version: 1.8.5
> Lustre:     Build Version: 1.8.5-20101117053234-PRISTINE-2.6.18-194.17.1.el5_lustre.1.8.5
> ll_mgs_01/0xffff8103/11347" after mounting lustre

This is often caused by a stack overflow.

Looking at the stack trace, it _shouldn't_ be atomic in that context due to Lustre (submitting a block IO) so I suspect that the "preempt_count" in the tast struct is corrupted or similar.

> Here is the stack dump:
> 
> BUG: scheduling while atomic: ll_mgs_01/0xffff8103/11347
> 
> Call Trace:
> [<ffffffff8006243d>] __sched_text_start+0x7d/0xbd6
> [<ffffffff880765a6>] :scsi_mod:scsi_done+0x0/0x18
> [<ffffffff8001cc65>] __mod_timer+0x100/0x10f
> [<ffffffff8006e1d7>] do_gettimeofday+0x40/0x90
> [<ffffffff8005a7a2>] getnstimeofday+0x10/0x28
> [<ffffffff80015504>] sync_buffer+0x0/0x3f
> [<ffffffff800637ea>] io_schedule+0x3f/0x67
> [<ffffffff8001553f>] sync_buffer+0x3b/0x3f
> [<ffffffff80063a16>] __wait_on_bit+0x40/0x6e
> [<ffffffff80015504>] sync_buffer+0x0/0x3f
> [<ffffffff80063ab0>] out_of_line_wait_on_bit+0x6c/0x78
> [<ffffffff800a09f8>] wake_bit_function+0x0/0x23
> [<ffffffff886e4bc8>] :ldiskfs:bh_submit_read+0x58/0x70
> [<ffffffff886e4ef8>] :ldiskfs:read_block_bitmap+0xc8/0x1c0
> [<ffffffff886e51cf>] :ldiskfs:ldiskfs_new_blocks_old+0x1df/0x750
> [<ffffffff886e9fb6>] :ldiskfs:ldiskfs_get_blocks_handle+0x596/0xd30
> [<ffffffff886e9b3a>] :ldiskfs:ldiskfs_get_blocks_handle+0x11a/0xd30
> [<ffffffff886e9b3a>] :ldiskfs:ldiskfs_get_blocks_handle+0x11a/0xd30
> [<ffffffff8000b476>] __find_get_block+0x15c/0x16c
> [<ffffffff886ea83a>] :ldiskfs:ldiskfs_getblk+0xea/0x320
> [<ffffffff880310b4>] :jbd:start_this_handle+0x341/0x3ed
> [<ffffffff80019bcc>] __getblk+0x25/0x236
> [<ffffffff886ebe51>] :ldiskfs:ldiskfs_bread+0x11/0x80
> [<ffffffff88031233>] :jbd:journal_start+0xd3/0x107
> [<ffffffff88afea8d>] :fsfilt_ldiskfs:fsfilt_ldiskfs_write_record+0x1cd/0x4b0
> [<ffffffff8000cf57>] do_lookup+0x65/0x1e6
> [<ffffffff887bdc89>] :obdclass:llog_lvfs_write_blob+0x119/0x440
> [<ffffffff887bf15f>] :obdclass:llog_lvfs_write_rec+0xb1f/0xda0
> [<ffffffff8002317b>] file_move+0x36/0x44
> [<ffffffff8000d47a>] dput+0x2c/0x113
> [<ffffffff88ad2c4e>] :mgs:record_lcfg+0x38e/0x4c0
> [<ffffffff8000984c>] __d_lookup+0xb0/0xff
> [<ffffffff88ad6e4a>] :mgs:record_marker+0x83a/0xa30
> [<ffffffff8002ca48>] mntput_no_expire+0x19/0x89
> [<ffffffff88ad83eb>] :mgs:mgs_write_log_lov+0x37b/0xf80
> [<ffffffff801537bf>] snprintf+0x44/0x4c
> [<ffffffff8875bff0>] :lvfs:pop_ctxt+0x290/0x370
> [<ffffffff887c4036>] :obdclass:__llog_ctxt_put+0x26/0x150
> [<ffffffff88adbbb3>] :mgs:__mgs_write_log_mdt+0x2b3/0x5d0
> [<ffffffff88ae3c0f>] :mgs:mgs_write_log_target+0xb5f/0x21e0
> [<ffffffff8886d060>] :ptlrpc:ldlm_completion_ast+0x0/0x880
> [<ffffffff88acd989>] :mgs:mgs_handle+0xf09/0x16c0
> [<ffffffff888a115a>] :ptlrpc:ptlrpc_server_handle_request+0x97a/0xdf0
> [<ffffffff888a18a8>] :ptlrpc:ptlrpc_wait_event+0x2d8/0x310
> [<ffffffff8008b3bd>] __wake_up_common+0x3e/0x68
> [<ffffffff888a2817>] :ptlrpc:ptlrpc_main+0xf37/0x10f0
> [<ffffffff8005dfb1>] child_rip+0xa/0x11
> [<ffffffff888a18e0>] :ptlrpc:ptlrpc_main+0x0/0x10f0
> [<ffffffff8005dfa7>] child_rip+0x0/0x11
> 
> 
> By the way, I also try the same setup steps on different device ie. /dev/cciss/c0d0p6 and it is fine.
> 
> I'm writing scsi lld driver FCoIB, sdc is scsi device (ie. FC lun) seen/controlled by FCoIB driver, I can mount filesystems ext2/ext3/reiserfs... and run normal I/O on sdc without problem.

Those filesystems use far less stack - Lustre is using a bunch of extra stack on top of ext4 (i.e. everything on top of "fsfilt_ldiskfs_write_record()" is on top of the stack usage of the local filesystem.

> Could anyone help/shed some lights on what the problem is?

Cheers, Andreas
--
Andreas Dilger 
Principal Engineer
Whamcloud, Inc.
