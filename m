From: James Simmons <jsimmons@infradead.org>
Date: Tue, 8 Jan 2019 04:26:39 +0000 (GMT)
Subject: [lustre-devel] [PATCH v2 33/33] lustre: update version to 2.9.99
In-Reply-To: <874lakj5ck.fsf@notabene.neil.brown.name>
References: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
 <1546812868-11794-34-git-send-email-jsimmons@infradead.org>
 <874lakj5ck.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1901080352210.15230@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Sun, Jan 06 2019, James Simmons wrote:
> 
> > With the majority of missing patches and features from the lustre
> > 2.10 release merged upstream its time to update the upstream
> > client's version.
> 
> :-)
> 
> Thanks to some of these patches (this batch or previous) I have fewer
> failing tests now .. those not many fewer.
> 
> The current summary is
>      45             status: FAIL
>     556             status: PASS
>      47             status: SKIP
> 
> It used to be >50 FAIL.
> 
> The failing tests are listed below.
> I know why the FID patches fail - we've discussed that.
> Maybe it is time to start working out why some of the others are
> failing.

You are running a much newer test suite. Using the test suite from lustre 
2.10 I see the following failures.

sanity: FAIL: test_103a run_acl_subtest cp failed    (real failure)
sanity: FAIL: test_215 cannot read lnet.stats	     (not sysfs aware)
sanity: FAIL: test_233a cannot access /lustre/lustre using its FID '[0x200000007:0x1:0x0]'
sanity: FAIL: test_233b cannot access /lustre/lustre/.lustre using its FID '[0x200000002:0x1:0x0]'
sanity: FAIL: test_256 Changelog catalog has wrong number of slots 0  (fails for 2.10 LTS release as well)
 
> Your two recent series are in my lustre-testing branch now - thanks.
> 
> NeilBrown
> 
> 
> sanity: FAIL: test_27G 'testpool' is not empty 

See LU-11208. Test currently with older lustre versions.

> sanity: FAIL: test_56w /root/lustre-release/lustre/utils/lfs getstripe -c /mnt/lustre/d56w.sanity/file1 wrong: found 2, expected 1
> sanity: FAIL: test_56x migrate failed rc = 11
> sanity: FAIL: test_56xa migrate failed rc = 11
> sanity: FAIL: test_56z /root/lustre-release/lustre/utils/lfs find did not continue after error
> sanity: FAIL: test_56aa lfs find --size wrong under striped dir
> sanity: FAIL: test_56ca create /mnt/lustre/d56ca.sanity/f56ca.sanity- failed
> sanity: FAIL: test_64b oos.sh failed: 1
> sanity: FAIL: test_102c setstripe failed
> sanity: FAIL: test_102j file1-0-1: size  != 65536

I believe these are due to the DoM feature missing

> sanity: FAIL: test_103a misc test failed

103a is real failure. Never solved yet. (LU-11594 and LU-10334 for Ubuntu)

> sanity: FAIL: test_104b lfs check servers test failed

sysfs bug. I have a patch for this.

> sanity: FAIL: test_130a filefrag /mnt/lustre/f130a.sanity failed
> sanity: FAIL: test_130b filefrag /mnt/lustre/f130b.sanity failed
> sanity: FAIL: test_130c filefrag /mnt/lustre/f130c.sanity failed
> sanity: FAIL: test_130e filefrag /mnt/lustre/f130e.sanity failed
> sanity: FAIL: test_130f filefrag /mnt/lustre/f130f.sanity failed

What version of e2fsprog are you running? You need a 1.44 version and
this should go away.

> sanity: FAIL: test_160a changelog 'f160a.sanity' fid  != file fid [0x240002342:0xd:0x0]
> sanity: FAIL: test_161d cat failed

Might be missing some more changelog improvements.

> sanity: FAIL: test_205 No jobstats for id.205.mkdir.9480 found on mds1::*.lustre-MDT0000.job_stats

Strange?

> sanity: FAIL: test_208 get lease error
> sanity: FAIL: test_225a mds-survey with zero-stripe failed
> sanity: FAIL: test_225b mds-survey with stripe_count failed

Never ran that since its not in 2.10.

> sanity: FAIL: test_233a cannot access /mnt/lustre using its FID '[0x200000007:0x1:0x0]'
> sanity: FAIL: test_233b cannot access /mnt/lustre/.lustre using its FID '[0x200000002:0x1:0x0]'

> sanity: FAIL: test_255c Ladvise test10 failed, 255
> sanity: FAIL: test_270a Can't create DoM layout
> sanity: FAIL: test_270c bad pattern
> sanity: FAIL: test_270e lfs find -L: found 1, expected 20
> sanity: FAIL: test_270f Can't create file with 262144 DoM stripe
> sanity: FAIL: test_271c Too few enqueues , expected > 2000
> sanity: FAIL: test_271f expect 1 READ RPC,  occured
> sanity: FAIL: test_300g create striped_dir failed
> sanity: FAIL: test_300n create striped dir fails with gid=-1
> sanity: FAIL: test_300q create d300q.sanity fails
> sanity: FAIL: test_315 read is not accounted ()
> sanity: FAIL: test_317 Expected Block 4096 got 10240 for f317.sanity
> sanity: FAIL: test_405 One layout swap locked test failed
> sanity: FAIL: test_406 mkdir d406.sanity failed
> sanity: FAIL: test_409 Fail to cleanup the env!
 
More DoM issues? Could be FLR as well if you are running the latest
test suite.

> sanity: FAIL: test_410 no inode match

This is a weird test running a local kernel module.

> sanity: FAIL: test_412 mkdir failed
> sanity: FAIL: test_413 don't expect 1

More DoM ???? Have to look at this.

> sanity: FAIL: test_802 (5) Mount client with 'ro' should succeed

Is test is broken. It assumes you have a specially patched kernel.
Details are under ticket LU-684.

The nice thing is with the linux client is that we are at a point
it wouldn't be a huge leap to integrate DoM (Data on MetaData).
The reason I suggest cleanups and moving out of staging first was
to perserve git blame a bit better with future patches. Currently
we see a lot of "0846e85ba2346 (NeilBrown 2018-06-07" with git blame.
