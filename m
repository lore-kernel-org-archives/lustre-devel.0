From: NeilBrown <neilb@suse.com>
Date: Wed, 19 Jul 2017 14:33:33 +1000
Subject: [lustre-devel] [PATCH 03/12] staging: lustre: llite: fix
	various issues with ll_splice_alias.
In-Reply-To: <030281CD-CC74-429C-910F-86706CFC57DA@intel.com>
References: <150041997277.20736.17112251996623587423.stgit@noble>
	<150042040744.20736.6110134708456645941.stgit@noble>
	<030281CD-CC74-429C-910F-86706CFC57DA@intel.com>
Message-ID: <87o9shxcyq.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Al Viro <viro@ZenIV.linux.org.uk>
Cc: Greg Kroah-Hartman <greg@kroah.com>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Tue, Jul 18 2017, Oleg Drokin wrote:

> Unfortunately this patch causes insta-crash on first stat call after mount.
> Sorry, I cannot dig into this deeper right this moment, but I will a bit later.

V.strange.  The crash suggests that the lock, and hence the inode, is
not initialized.  I cannot see how that might happen.
though...

>> +		spin_lock(&lli->lli_lock);
>> +		new = ll_find_invalid_alias(inode, de);
>> +		if (!new)
>> +			d_add(de, inode);
>> +		spin_lock(&lli->lli_lock);

Had it not crashed, it would have deadlocked.  That second spin_lock()
should be spin_unlock() :-( I don't *think* that would have caused this crash...

> I am adding Al that we discussed this code at some length and he found no problems
> here, so I am a bit surprised by your findings.

I'd be very happy to read Al's thoughts.

> Also the reason we reinvent the d_splice_alias is because we need to
> splice not just directories, but also regular files.

I see that.  A key simplification I bring is that directories and
non-directories can be handled separately.  d_splice_alias() does
all we need for directories, and nothing useful for non-dirs.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20170719/3c6e7ef8/attachment.pgp>
