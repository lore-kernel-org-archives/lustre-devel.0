From: Jacek Tomaka <jacekt@dug.com>
Date: Tue, 2 Jul 2019 15:19:55 +0800
Subject: [lustre-devel] Kernel panic - not syncing: LBUG:
 llite_mmap.c:71:our_vma()
Message-ID: <CAKVxXCWdEtazYGhKE2bF3sxWQxyr-ZQ2chHmUmdr+b-4P5fWvA@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,
I was wondering if you would be interested in the following failed assertion:

2019-07-02T01:45:11-05:00 nanny1926 kernel: LustreError:
251884:0:(llite_mmap.c:71:our_vma()) ASSERTION(
!down_write_trylock(&mm->mmap_sem) ) failed:
2019-07-02T01:45:11-05:00 nanny1926 kernel: LustreError:
251884:0:(llite_mmap.c:71:our_vma()) LBUG
2019-07-02T01:45:11-05:00 nanny1926 kernel: Pid: 251884, comm: java
2019-07-02T01:45:11-05:00 nanny1926 kernel: #012Call Trace:
2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffffc03d67ae>]
libcfs_call_trace+0x4e/0x60 [libcfs]
2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffffc03d683c>]
lbug_with_loc+0x4c/0xb0 [libcfs]
2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffffc116e66b>]
our_vma+0x16b/0x170 [lustre]
2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffffc11857f9>]
vvp_io_rw_lock+0x409/0x6e0 [lustre]
2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffffc0fbb312>] ?
lov_io_iter_init+0x302/0x8b0 [lov]
2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffffc1185b29>]
vvp_io_write_lock+0x59/0xf0 [lustre]
2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffffc063ebec>]
cl_io_lock+0x5c/0x3d0 [obdclass]
2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffffc063f1db>]
cl_io_loop+0x11b/0xc90 [obdclass]
2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffffc1133258>]
ll_file_io_generic+0x498/0xc40 [lustre]
2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffffc1133cdd>]
ll_file_aio_write+0x12d/0x1f0 [lustre]
2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffffc1133e6e>]
ll_file_write+0xce/0x1e0 [lustre]
2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffff81200cad>]
vfs_write+0xbd/0x1e0
2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffff8111f394>] ?
__audit_syscall_entry+0xb4/0x110
2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffff81201abf>]
SyS_write+0x7f/0xe0
2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffff816b5292>]
tracesys+0xdd/0xe2
2019-07-02T01:45:11-05:00 nanny1926 kernel:
2019-07-02T01:45:11-05:00 nanny1926 kernel: Kernel panic - not syncing: LBUG

Is there any other place where you would want it reported?

-- 
Jacek Tomaka
Geophysical Software Developer




DownUnder GeoSolutions

76 Kings Park Road
West Perth 6005 WA, Australia
tel +61 8 9287 4143
jacekt at dug.com
www.dug.com
