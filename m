From: James Simmons <jsimmons@infradead.org>
Date: Fri, 17 Aug 2018 23:03:58 +0100 (BST)
Subject: [lustre-devel] [PATCH 01/38] lustre: llite: rename
 ldebugfs_[un]register_mountpoint
In-Reply-To: <87d0uhsjrq.fsf@notabene.neil.brown.name>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
 <1534475441-15543-2-git-send-email-jsimmons@infradead.org>
 <87d0uhsjrq.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1808172246560.2829@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Thu, Aug 16 2018, James Simmons wrote:
> 
> > Rename from ldebugfs_[un]register_mountpoint() to
> > ll_debugfs_[un]register_super().
> 
> I really helps with review if I am told *why* something is happening.
> 
> I can guess, but being told means I'm less concerned that I might have
> missed something.
> 
> I can see that "mountpoint" is an inappropriate name, though I'm not
> entired sure that "super" is a better now.  Surely this code is
> registering an filesystem (instance) with debugfs.... maybe a "super" is
> exactly a "filesystem instance"....
> 
> Why is ll_debugfs better than ldebugfs?  More typing doesn't usually
> thrill me.

This was a request by John Hammond, the lustre style enforcer :-) Same for
the ll_*() function naming. The idea here is all llite function begin
with ll_ prefix. How about this changelog.

--------------------------------------------------------------------------

Rename ldebugfs_[un]register_mountpoint() to ll_debugfs_[un]register_super().
This first aligns the functions name with the major of the llite function
prototypes by starting with the ll_* prefix. The use of mountpoint is not
the best way to describe the functions who's name are being changed. Since
this is managed by struct ll_sb_info, which is the lustre private 
instance for struct super_block, so rename to *_super() instead
