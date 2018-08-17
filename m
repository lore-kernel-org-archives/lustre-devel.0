From: NeilBrown <neilb@suse.com>
Date: Fri, 17 Aug 2018 14:24:09 +1000
Subject: [lustre-devel] [PATCH 01/38] lustre: llite: rename
 ldebugfs_[un]register_mountpoint
In-Reply-To: <1534475441-15543-2-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
 <1534475441-15543-2-git-send-email-jsimmons@infradead.org>
Message-ID: <87d0uhsjrq.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Aug 16 2018, James Simmons wrote:

> Rename from ldebugfs_[un]register_mountpoint() to
> ll_debugfs_[un]register_super().

I really helps with review if I am told *why* something is happening.

I can guess, but being told means I'm less concerned that I might have
missed something.

I can see that "mountpoint" is an inappropriate name, though I'm not
entired sure that "super" is a better now.  Surely this code is
registering an filesystem (instance) with debugfs.... maybe a "super" is
exactly a "filesystem instance"....

Why is ll_debugfs better than ldebugfs?  More typing doesn't usually
thrill me.


I don't really care about this particular change - it seems innocuous.
I do really care about good change logs.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180817/81ed97d5/attachment-0001.sig>
