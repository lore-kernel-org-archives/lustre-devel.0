From: NeilBrown <neilb@suse.com>
Date: Mon, 12 Feb 2018 12:05:44 +1100
Subject: [lustre-devel] testing lustre
In-Reply-To: <649030A5-48A9-4C67-A911-28FBC5F183E1@intel.com>
References: <151538168618.23920.8261096424342988792.stgit@noble>
 <20180108145943.GA5761@kroah.com>
 <alpine.LFD.2.21.1801081607120.1698@casper.infradead.org>
 <87po5gmqph.fsf@notabene.neil.brown.name>
 <94546355-FD93-4B50-AC98-4AB38EDC9BF0@gmail.com>
 <87tvurkm9e.fsf@notabene.neil.brown.name>
 <3C5A4767-EBDC-42C0-9A46-46C8356C5067@gmail.com>
 <87r2ptpvp2.fsf@notabene.neil.brown.name>
 <649030A5-48A9-4C67-A911-28FBC5F183E1@intel.com>
Message-ID: <874lmnrp93.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Feb 09 2018, Oleg Drokin wrote:

>> On Feb 9, 2018, at 6:52 PM, NeilBrown <neilb@suse.com> wrote:
>> 
>> On Fri, Feb 09 2018, ???????????? ????? wrote:
>>> 
>>>> I cannot find anywhere in the code that would write out a new label, or
>>>> that would call e2label or tune2fs to do it.
>>> 
>>> mount utility (mount_lustre.c)
>>> Main->
>>> 	parse_ldd() -> ldd() read ldd. In  and change : to - in memory
>>> 	mount() - mount target, register it on mgs
>>> 	label_lustre () write new label with ?-? on disk
>> 
>> Ahhh.. found it.  Thanks for lot for the details!!
>> 
>> And and I can see in an strace that this is being called - mount.lustre
>> forks and runs "tune2fs -f -L ....".
>> But still the volume name doesn't change.
>> Maybe I have a buggy tune2fs.
>> 
>> I note that tune2fs says "recovering journal" or something like that.
>> I suspect we don't want that to happen when the filesystem is mounted.
>> Maybe that is related to the failure to change the label.
>> I will dig in more deeply.
>
> This sounds very familiar, but I cannot quite find the ticket for it.
>
> Anyway, I do wonder if you use our patched e2fsprogs and if not,
> if you could give it a try first.

No, I haven't been using the patched e2fsprogs ... looks ....
Oh, that branched from mainline in May 2015 with nothing new merged in
since.
One of the things that hasn't been merged in is
Commit: c864b9eb5001 ("tune2fs: recover the journal")

so lustre-tunefs doesn't try to recover the journal. Upstream does and
breaks lustre.

This is easily fixed with

diff --git a/misc/tune2fs.c b/misc/tune2fs.c
index c33fb9d80b10..703e55b6b972 100644
--- a/misc/tune2fs.c
+++ b/misc/tune2fs.c
@@ -3337,7 +3337,7 @@ _("Warning: The journal is dirty. You may wish to replay the journal like:\n\n"
 	}
 #else
 	/* Recover the journal if possible. */
-	if ((open_flag & EXT2_FLAG_RW) && !(mount_flags & EXT2_MF_MOUNTED) &&
+	if ((open_flag & EXT2_FLAG_RW) && !(mount_flags & (EXT2_MF_BUSY | EXT2_MF_MOUNTED)) &&
 	    ext2fs_has_feature_journal_needs_recovery(fs->super)) {
 		errcode_t err;
 

which I think is a sensible patch in any case.
I'll send it upstream.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180212/28e1ffd5/attachment.sig>
