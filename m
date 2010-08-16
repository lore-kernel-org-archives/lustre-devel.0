From: Oleg Drokin <oleg.drokin@oracle.com>
Date: Mon, 16 Aug 2010 02:44:51 -0400
Subject: [Lustre-devel] Caching the root directory
In-Reply-To: <201008130037.o7D0bLYh010763@hedwig.cmf.nrl.navy.mil>
References: <201008130037.o7D0bLYh010763@hedwig.cmf.nrl.navy.mil>
Message-ID: <1A6F49A5-1714-4B7F-A960-B6D1092EEBDE@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Aug 12, 2010, at 8:37 PM, Ken Hornstein wrote:

> In the case of md_intent_lock() .... hmmm.  I see in ll_revalidate_it()
> that mountpoints are explicitly skipped (and the attributes are fixed up
> in ll_inode_revalidate_it(), which from what I see unless there is a lock
> already, you don't get a new one).  Does d_mountpoint(de) apply to the
> root node?

No, d_mountpoint() applies to a dentry on some filesystem where something is
mounted.
Mountpoints are skipped just because there is no point in looking at their attrs,
the attrs should come from the underlying fs mounted below.

> 
>> From what I can read ... ll_prep_md_op_data() pretty much requires that
> the first argument (the parent inode) needs to be filled in.  The server
> gets a little complicated to follow, but I do see that the server does:
> 
> 	rc = mdt_object_exists(parent);
> 
> inside of mdt_getattr_name_lock().  Which sure would imply to me that things
> are going to be unhappy if you don't supply a parent node.

Well, there is a simple rule for a root of the fs. The rule says
the parent of the root inode is the root inode.

Besides, when you do getattr by fid (which you do from ll_inode_revalidate),
you don't have parent anyway, so you onl supply child inode information.

Bye,
    Oleg
