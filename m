From: NeilBrown <neilb@suse.com>
Date: Tue, 27 Nov 2018 09:28:35 +1100
Subject: [lustre-devel] [PATCH RFC] lustre: llite: add LL_IOC_FUTIMES_3
In-Reply-To: <075A6FB1-D778-46F7-B780-FC9229902690@whamcloud.com>
References: <alpine.LFD.2.21.1811260455120.32255@casper.infradead.org>
 <87mupvr14s.fsf@notabene.neil.brown.name>
 <075A6FB1-D778-46F7-B780-FC9229902690@whamcloud.com>
Message-ID: <87k1kzqxrg.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Nov 26 2018, Andreas Dilger wrote:

> On Nov 26, 2018, at 14:15, NeilBrown <neilb@suse.com> wrote:
>> 
>> On Mon, Nov 26 2018, James Simmons wrote:
>> 
>>> Add a new regular file ioctl LL_IOC_FUTIMES_3 similar to futimes() but
>>> which allows setting of all three inode timestamps. Use this ioctl
>>> during HSM restore to ensure that the volatile file has the same
>>> timestamps as the file to be restored. Strengthen sanity-hsm test_24a
>>> to check that archive, release, and restore do not change a file's
>>> ctime. Add sanity-hsm test_24e to check that tar will succeed when it
>>> encounters a HSM released file.
>> 
>> What is this used for?  What is the minimum functionality that would be
>> acceptable?
>
> Correct, this is for restoring files from HSM archive or migrating between
> different tiers of storage within the filesystem.  This is transparent to the user, and we don't want the migration/restore to cause the file to be backed up again.
>
>> I'm guessing that it is used to migrate files between different levels
>> in the HSM storage hierarchy.  Why is it important that the ctime not
>> change?  How is the ctime used in a way that would be confused?
>> Would it be sufficient, for example, to be able to set the ctime to the
>> same as the mtime?
>
> There are lots of different kinds of backup tools out there, I can't
> comment on whether ctime == mtime is sufficient to avoid triggering
> another backup cycle.  Keeping the same timestamps over this process
> is safest.  It seems that XFS has a similar requirement, and it is
> using "FMODE_NOCMTIME", but that only avoids updating the timestamps,
> it doesn't allow setting them.

Interesting.. FMODE_NOCMTIME was added 10 years ago (next month) with
the comment

+ * Currently a special hack for the XFS open_by_handle ioctl, but we'll
+ * hopefully graduate it to a proper O_CMTIME flag supported by open(2) soon.

"soon" is an imprecise term of course...

But as you say, there is no way to set the ctime, even at file creation.
I wonder how this is used.

Maybe it would make sense to add a flag to utimensat() to expect a third
time-stamp and use that for ctime.  That would be a fairly simple and
safe API change.
It would be nice to creae an O_NOCMTIME and plumb it through properly
too.
Possibly utimensat(AT_3TIMES) would required an fd that was opened with
N_NOCMTIME...

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181127/f72b03d2/attachment.sig>
