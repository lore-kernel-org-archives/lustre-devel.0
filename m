From: Oleg Drokin <oleg.drokin@intel.com>
Date: Wed, 19 Jul 2017 02:18:39 -0400
Subject: [lustre-devel] [PATCH 03/12] staging: lustre: llite: fix
	various issues with ll_splice_alias.
In-Reply-To: <87o9shxcyq.fsf@notabene.neil.brown.name>
References: <150041997277.20736.17112251996623587423.stgit@noble>
	<150042040744.20736.6110134708456645941.stgit@noble>
	<030281CD-CC74-429C-910F-86706CFC57DA@intel.com>
	<87o9shxcyq.fsf@notabene.neil.brown.name>
Message-ID: <244467F8-2775-4014-90FF-9CBC74F76B38@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Greg Kroah-Hartman <greg@kroah.com>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


On Jul 19, 2017, at 12:33 AM, NeilBrown wrote:

> On Tue, Jul 18 2017, Oleg Drokin wrote:
> 
>> Unfortunately this patch causes insta-crash on first stat call after mount.
>> Sorry, I cannot dig into this deeper right this moment, but I will a bit later.
> 
> V.strange.  The crash suggests that the lock, and hence the inode, is
> not initialized.  I cannot see how that might happen.
> though...
> 
>>> +		spin_lock(&lli->lli_lock);
>>> +		new = ll_find_invalid_alias(inode, de);
>>> +		if (!new)
>>> +			d_add(de, inode);
>>> +		spin_lock(&lli->lli_lock);
> 
> Had it not crashed, it would have deadlocked.  That second spin_lock()
> should be spin_unlock() :-( I don't *think* that would have caused this crash?

No, that's not it.
-	d_add(de, inode);
-	CDEBUG(D_DENTRY, "Add dentry %p inode %p refc %d flags %#x\n",
-	       de, d_inode(de), d_count(de), de->d_flags);
+	de = d_splice_alias(inode, de);
+	if (!IS_ERR(de))
+		CDEBUG(D_DENTRY, "Add dentry %p inode %p refc %d flags %#x\n",
+		       de, d_inode(de), d_count(de), de->d_flags);
	return de;

This is likely it.
d_splice_alias would return NULL if there's no alias, after d_add of the de.
But ll_splice_alias callers expect either an ERR_PTR on error or dentry to use
otherwise.
So in ll_lookup_it_finish() we have:
        alias = ll_splice_alias(inode, *de);
        if (IS_ERR(alias)) {
                rc = PTR_ERR(alias);
                goto out;
        }
        *de = alias;
?
                if (md_revalidate_lock(ll_i2mdexp(parent), &parent_it, &fid,
                                       NULL)) {
===>>> whoops!          d_lustre_revalidate(*de);
                        ll_intent_release(&parent_it);
                }

>> I am adding Al that we discussed this code at some length and he found no problems
>> here, so I am a bit surprised by your findings.
> I'd be very happy to read Al's thoughts.

Some of the discussions were in lkml under subject of "More parallel
atomic_open/d_splice_alias fun with NFS and possibly more FSes"
in July 2016, in between nfs stuff.
There was more but I cannot readily find it.

>> Also the reason we reinvent the d_splice_alias is because we need to
>> splice not just directories, but also regular files.
> 
> I see that.  A key simplification I bring is that directories and
> non-directories can be handled separately.  d_splice_alias() does
> all we need for directories, and nothing useful for non-dirs.

I see.
I still need to  think some more about this whole thing.

Please see commit 99f1c013194e64d4b67d5d318148303b0e1585e1 for double d_add
of the same dentry fix.6
