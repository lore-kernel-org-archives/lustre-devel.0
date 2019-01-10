From: NeilBrown <neilb@suse.com>
Date: Thu, 10 Jan 2019 11:40:35 +1100
Subject: [lustre-devel] [PATCH v2 33/33] lustre: update version to 2.9.99
In-Reply-To: <45806D2E-8AAD-48ED-8B14-6D5CC11D824E@whamcloud.com>
References: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
 <1546812868-11794-34-git-send-email-jsimmons@infradead.org>
 <874lakj5ck.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1901080352210.15230@casper.infradead.org>
 <45806D2E-8AAD-48ED-8B14-6D5CC11D824E@whamcloud.com>
Message-ID: <87muo9ibuk.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Jan 08 2019, Andreas Dilger wrote:

> On Jan 7, 2019, at 21:26, James Simmons <jsimmons@infradead.org> wrote:
>> 
>>> 
>>> On Sun, Jan 06 2019, James Simmons wrote:
>>> 
>>>> With the majority of missing patches and features from the lustre
>>>> 2.10 release merged upstream its time to update the upstream
>>>> client's version.
>>> 
>>> :-)
>>> 
>>> Thanks to some of these patches (this batch or previous) I have fewer
>>> failing tests now .. those not many fewer.
>>> 
>>> The current summary is
>>>     45             status: FAIL
>>>    556             status: PASS
>>>     47             status: SKIP
>>> 
>>> It used to be >50 FAIL.
>>> 
>>> The failing tests are listed below.
>>> I know why the FID patches fail - we've discussed that.
>>> Maybe it is time to start working out why some of the others are
>>> failing.
>> 
>> You are running a much newer test suite. Using the test suite from lustre 
>> 2.10 I see the following failures.
>> 
>> sanity: FAIL: test_103a run_acl_subtest cp failed    (real failure)
>> sanity: FAIL: test_215 cannot read lnet.stats	     (not sysfs aware)
>> sanity: FAIL: test_233a cannot access /lustre/lustre using its FID '[0x200000007:0x1:0x0]'
>> sanity: FAIL: test_233b cannot access /lustre/lustre/.lustre using its FID '[0x200000002:0x1:0x0]'
>> sanity: FAIL: test_256 Changelog catalog has wrong number of slots 0  (fails for 2.10 LTS release as well)
>
> Yes, there are definitely some tests that do not have proper client/server version/feature checks, since the tests are introduced with the code they
> are testing.  There are a number of patches in Gerrit that are adding the
> proper checks that I'd like to get landed, because we do run client/server
> version interop testing, but they always lag a bit behind and we never see
> test-script/client version issues in our testing. 
>
>>> Your two recent series are in my lustre-testing branch now - thanks.
>>> 
>>> NeilBrown
>>> 
>>> 
>>> sanity: FAIL: test_27G 'testpool' is not empty 
>> 
>> See LU-11208. Test currently with older lustre versions.
>> 
>>> sanity: FAIL: test_56w /root/lustre-release/lustre/utils/lfs getstripe -c /mnt/lustre/d56w.sanity/file1 wrong: found 2, expected 1
>>> sanity: FAIL: test_56x migrate failed rc = 11
>>> sanity: FAIL: test_56xa migrate failed rc = 11
>>> sanity: FAIL: test_56z /root/lustre-release/lustre/utils/lfs find did not continue after error
>>> sanity: FAIL: test_56aa lfs find --size wrong under striped dir
>>> sanity: FAIL: test_56ca create /mnt/lustre/d56ca.sanity/f56ca.sanity- failed
>>> sanity: FAIL: test_64b oos.sh failed: 1
>>> sanity: FAIL: test_102c setstripe failed
>>> sanity: FAIL: test_102j file1-0-1: size  != 65536
>> 
>> I believe these are due to the DoM feature missing
>> 
>>> sanity: FAIL: test_103a misc test failed
>> 
>> 103a is real failure. Never solved yet. (LU-11594 and LU-10334 for Ubuntu)
>> 
>>> sanity: FAIL: test_104b lfs check servers test failed
>> 
>> sysfs bug. I have a patch for this.
>> 
>>> sanity: FAIL: test_130a filefrag /mnt/lustre/f130a.sanity failed
>>> sanity: FAIL: test_130b filefrag /mnt/lustre/f130b.sanity failed
>>> sanity: FAIL: test_130c filefrag /mnt/lustre/f130c.sanity failed
>>> sanity: FAIL: test_130e filefrag /mnt/lustre/f130e.sanity failed
>>> sanity: FAIL: test_130f filefrag /mnt/lustre/f130f.sanity failed
>> 
>> What version of e2fsprog are you running? You need a 1.44 version and
>> this should go away.
>
> To be clear - the Lustre-patched "filefrag" at:
>
> https://downloads.whamcloud.com/public/e2fsprogs/1.44.3.wc1/
>

I looked at Commit 41aee4226789 ("filefrag: Lustre changes to filefrag FIEMAP handling")
in the git tree instead.

This appears to add 3, features.

- It adds an optional device to struct fiemap.
  Presumably this is always returned if available, else zero is provided
  which means "the device".
- It adds a flag FIEMAP_EXTENT_NET which indicates that the device
  number is *not*  dev_t, but is some fs-specific value
- It allows FIEMAP_FLAG_DEVICE_ORDER to be requested.  I can't quite
  work out what this does.  Presumably it changes the order that entries
  are returned (why?) and maybe returns multiple entries for a region
  that is mirrored ???

As you say, I can see how these might be useful to other filesystems.
Maybe we should try upstreaming the support sooner rather than later.

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190110/614ef3d7/attachment.sig>
