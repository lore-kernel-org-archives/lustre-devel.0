From: NeilBrown <neilb@suse.com>
Date: Tue, 27 Mar 2018 16:32:42 +1100
Subject: [lustre-devel] Current results and status of my upstream work
In-Reply-To: <alpine.LFD.2.21.1802120233260.3291@casper.infradead.org>
References: <alpine.LFD.2.21.1802112308150.3291@casper.infradead.org>
 <87bmgvrsj8.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1802120233260.3291@casper.infradead.org>
Message-ID: <871sg65bid.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Thu, Mar 22 2018, James Simmons wrote:

> Hi Neil
>
> 	I have been testing the upstream client using lustre 2.10 tools 
> and the test suite that comes with it. I see the following failures in
> my testing and wonder at how it compares to your testing:
>
> sanity: FAIL: test_17n migrate remote dir error 1
> sanity: FAIL: test_17o stat file should fail
> sanity: FAIL: test_24v large readdir doesn't take effect:  2 should be about 0
> sanity: FAIL: test_27z FF stripe count 1 != 0
> sanity: FAIL: test_27D llapi_layout_test failed
> sanity: FAIL: test_29 No mdc lock count
> sanity: FAIL: test_42d failed: client:75497472 server: 92274688.
> sanity: FAIL: test_42e failed: client:76218368 server: 92995584.
> sanity: FAIL: test_56c OST lustre-OST0000 is in status of '', not 'D'
> sanity: FAIL: test_56t "lfs find -S 4M /lustre/lustre/d56t.sanityt" wrong: found 5, expected 3
> sanity: FAIL: test_56w /usr/bin/lfs getstripe -c /lustre/lustre/d56w.sanityw/dir1/file1 wrong: found 2, expected 1
> sanity: FAIL: test_63a failed: client:75497472 server: 92274688.
> sanity: FAIL: test_63b failed: client:75497472 server: 92274688.
> sanity: FAIL: test_64a failed: client:75497472 server: 92274688.
> sanity: FAIL: test_64c failed: client:75497472 server: 92274688.
> sanity: FAIL: test_76 inode slab grew from 182313 to 182399
> sanity: FAIL: test_77c no checksum dump file on Client
> sanity: FAIL: test_101g unable to set max_pages_per_rpc=16M
> sanity: FAIL: test_102a /lustre/lustre/f102a.sanity missing 3 trusted.name xattrs
> sanity: FAIL: test_102b can't get trusted.lov from /lustre/lustre/f102b.sanity
> sanity: FAIL: test_102n setxattr invalid 'trusted.lov' success
> sanity: FAIL: test_103a run_acl_subtest cp failed
> sanity: FAIL: test_125 setfacl /lustre/lustre/d125 failed
> sanity: FAIL: test_154  kernel panics in ll_splice code
> sanity: FAIL: test_154B decode linkea /lustre/lustre/d154B.sanity/f154B.sanity failed
> sanity: FAIL: test_160d migrate fails
> sanity: FAIL: test_161d create should be blocked
> sanity: FAIL: test_162a check path d162a.sanity/d2/p/q/r/slink failed
> sanity: FAIL: test_200 unable to mount /lustre/lustre on MGS
> sanity: FAIL: test_220 unable to mount /lustre/lustre on MGS
> sanity: FAIL: test_225  kills the MDS server
> sanity: FAIL: test_226a cannot get path of FIFO by /lustre/lustre /lustre/lustre/d226a.sanity/fifo
> sanity: FAIL: test_226b cannot get path of FIFO by /lustre/lustre /lustre/lustre/d226b.sanity/remote_dir/fifo
> sanity: FAIL: test_230b fails on migrating remote dir to MDT1
> sanity: FAIL: test_230c mkdir succeeds under migrating directory
> sanity: FAIL: test_230d migrate remote dir error
> sanity: FAIL: test_230e migrate dir fails
> sanity: FAIL: test_230f #1 migrate dir fails
> sanity: FAIL: test_230h migrating d230h.sanity fail
> sanity: FAIL: test_230i migration fails with a tailing slash
> sanity: FAIL: test_233a cannot access /lustre/lustre using its FID '[0x200000007:0x1:0x0]'
> sanity: FAIL: test_233b cannot access /lustre/lustre/.lustre using its FID '[0x200000002:0x1:0x0]'
> sanity: FAIL: test_234 touch failed
> sanity: FAIL: test_240 umount failed
> sanity: FAIL: test_242 ls /lustre/lustre/d242.sanity failed
> sanity: FAIL: test_251 short write happened
> sanity: FAIL: test_300a 1:stripe_count is 0, expect 2
> sanity: FAIL: test_300e set striped bdir under striped dir error
> sanity: FAIL: test_300g create dir1 fails
> sanity: FAIL: test_300h expect 4 get 0 for striped_dir
> sanity: FAIL: test_300i set striped hashdir error
> sanity: FAIL: test_300n create test_dir1 fails
> sanity: FAIL: test_315 read is not accounted (0)
> sanity: FAIL: test_399a fake write is slower
> sanity: FAIL: test_405 One layout swap locked test failed
> sanity: FAIL: test_406 unable to mount /lustre/lustre on MGS
> sanity: FAIL: test_410 no inode match
> sanity: FAIL: test_900 never finishes. ldlm_lock dumps
>
> Some of those failures are due to new functionality that the upstream 
> client doesn't support which at this point is not important. Another
> batch is due to xattr/acl support being broken. John Hammond and I
> have been looking into those failures. I have a bunch of patches done
> and are being tested. Letting you know so we don't duplicate work.
> The other source of the bugs is the sysfs support. I'm porting the
> fixes I have done to upstream and I'm in the process of validating
> the patches. As a last bunch of changes it was found that lustre
> doesn't work properly with its SMP code on systems like KNL and ARM
> on one end and the other end on these massive systems with 100s of
> core also doesn't work well. I have those patches already finished
> and tested. I will be pushing those after the next merge window.
> I'm almost done working out the 64 bit time code as well. Haven't
> ported those yet.

Hi,
 thanks for this.
 Yes, my list is very similar, though not identical.
 I've modified the test harness a little so that it unmounts and
 remounts the filesystem on every test.  I was chasing down a bug that
 happened on unmount, and wanted to trigger it as quickly as possible.
 The might explain some of the differences

 Tests in your list, not in mine:
   56[ctw] 76 154  200 300e 315 399a 900

 Tests in my list, not in yours
   56z 60aa 64b 83 104b 120e  130[abcde] 161c 205 215 

 It might be worth looking in to some of these(?). Last time I
 tried to understand one of the failures, I quickly realized that my
 understand of how lustre works wasn't deep enough.  So I went back
 to code cleaning.  Doing that has slowly improved my understanding
 so it might be worth it to go hunting again.

 I don't think anything you have mentioned will duplicate anything I've
 been working on.  Most of my time recently has been understanding the
 various hash tables and working to convert lustre to use rhashtable.
 I look forward to looking over your patches, I'll probably learn something!

 One failure that I have looked into but haven't posted a patch for yet,
 is that sometimes
        LINVRNT(io->ci_state == CIS_IO_GOING || io->ci_state == CIS_LOCKED);
 in cl_io_read_ahead() fails.  When it does, the value is CIS_INIT.
 Tracing through the code, it seem that CIS_INIT is an easy possibility
 since 1e1db2a97be5 ("staging: lustre: clio: Revise read ahead implementation")
 However CIS_IO_GOING and CIS_LOCKED do also happen and I cannot see
 that patht that leads to those - so I didn't feel that I could
 correctly explain the patch.
 I currently have:

       LINVRNT(io->ci_state == CIS_IO_GOING || io->ci_state == CIS_LOCKED ||
               io->ci_state == CIS_INIT);

 Do you have any idea if that is right?

Thanks,
NeilBrown

 
