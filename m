From: Bernd Schubert <bs@q-leap.de>
Date: Thu, 6 Mar 2008 12:10:52 +0100
Subject: [Lustre-devel] oss umount hangs forever
Message-ID: <200803061210.52475.bs@q-leap.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

I'm not sure about this, when a device is set read-only, 
are journal commit still allowed then, or is this the reason,
why the umount hangs forever?

[44825.302262] LustreError: Skipped 572 previous similar messages
[44882.668079] Lustre: Failing over pfs1work-OST0026
[44882.674578] Lustre: *** setting obd pfs1work-OST0026 device 'unknown-block(9,7)' read-only ***


(gdb) l *(log_wait_commit+0xa3)
0xffffffff802e9f76 is in log_wait_commit (fs/jbd/journal.c:550).
545             while (tid_gt(tid, journal->j_commit_sequence)) {
546                     jbd_debug(1, "JBD: want %d, j_commit_sequence=%d\n",
547                                       tid, journal->j_commit_sequence);
548                     wake_up(&journal->j_wait_commit);
549                     spin_unlock(&journal->j_state_lock);
550                     wait_event(journal->j_wait_done_commit,
551                                     !tid_gt(tid, journal->j_commit_sequence));
552                     spin_lock(&journal->j_state_lock);
553             }
554             spin_unlock(&journal->j_state_lock);


[46237.813097] umount        D 0000000100a9e444     0 31369      1 (NOTLB)
[46237.820001]  ffff81000a5ada18 0000000000000086 0000000000000000 0000000000000000
[46237.827756]  0000000000000000 0000000000000000 0000000000000007 ffff81000ec640c0
[46237.835488]  ffff81012b6a96b0 000028d210c60a79 0000000000001328 ffff81000ec64270
[46237.843057] Call Trace:
[46237.845815]  [<ffffffff802e9f76>] log_wait_commit+0xa3/0xf5
[46237.851681]  [<ffffffff802e48a0>] journal_stop+0x214/0x244
[46237.857341]  [<ffffffff8851c259>] :obdfilter:filter_iocontrol+0x139/0xa20
[46237.864413]  [<ffffffff8825fe64>] :obdclass:class_cleanup+0x514/0xfc0
[46237.871219]  [<ffffffff88263aec>] :obdclass:class_process_config+0x137c/0x1a90
[46237.878749]  [<ffffffff88264519>] :obdclass:class_manual_cleanup+0x319/0xf70
[46237.886137]  [<ffffffff882707a1>] :obdclass:server_put_super+0xb61/0xf70
[46237.893111]  [<ffffffff80271942>] generic_shutdown_super+0x60/0xf1
[46237.899584]  [<ffffffff802719fa>] kill_anon_super+0x9/0x35
[46237.905263]  [<ffffffff80271aab>] deactivate_super+0x6a/0x82
[46237.911204]  [<ffffffff80284195>] sys_umount+0x21b/0x24e
[46237.916751]  [<ffffffff802094de>] system_call+0x7e/0x83
[46237.922218]  [<00002b0aadea7789>]


Thanks,
Bernd

-- 
Bernd Schubert
Q-Leap Networks GmbH
