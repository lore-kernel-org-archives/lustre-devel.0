From: tao.peng at emc.com <tao.peng@emc.com>
Date: Mon, 30 Jan 2012 02:44:52 -0500
Subject: [Lustre-devel] Lustre dcache clean up and distributed locking
In-Reply-To: <CALxHnhL5Oz7cwqF15x65enx1qhgadSkftGa-=QAuY1N+9B5rSw@mail.gmail.com>
References: <F19688880B763E40B28B2B462677FBF805E7E684CD@MX09A.corp.emc.com>
	<AC57B2B9-5559-4713-905D-7AC9BAE3B1DB@whamcloud.com>
	<28CD3A7C-52EE-4E75-B00F-4280D60CE17D@whamcloud.com>
	<CALxHnhL5Oz7cwqF15x65enx1qhgadSkftGa-=QAuY1N+9B5rSw@mail.gmail.com>
Message-ID: <F19688880B763E40B28B2B462677FBF805E7E68AA5@MX09A.corp.emc.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Siyao,

Yes, ll_lookup_lock should be able to be removed. And looks like it will be handled by Yang Sheng in ?LU-506 kernel: FC15 - Dcache RCU-walk changes? as commented by Fan Yong (http://review.whamcloud.com/#patch,sidebyside,1865,2,lustre/include/linux/lustre_patchless_compat.h). I will leave it as is to let Sheng handle it.

Thanks,
Tao

From: Lai Siyao [mailto:laisiyao at whamcloud.com]<mailto:[mailto:laisiyao@whamcloud.com]>
Sent: Friday, January 20, 2012 10:56 AM
To: Oleg Drokin
Cc: Andreas Dilger; Peng, Tao; faibish, sorin; Tang, Haiying; Liu, Xuezhao; Fan Yong; Eric Barton
Subject: Re: Lustre dcache clean up and distributed locking

Hi Tao,

The reason why ll_lookup_lock is introduced is because in some kernels (eg. 2.6.32 for RHEL6), d_rehash_cond() doesn't exist and only d_rehash can be used, which needs unlock dcache_lock before entry, therefore there is a race here, and a similar global lock like dcache_lock is needed. The improvement can be done here is when d_rehash_cond() is exported, ll_lookup_lock lock/unlock can be a null operation, and in recent kernels, dcache_lock is removed, ll_lookup_lock should be able to be removed too.

I like most of the cleanups, but I don't see much benefits introducing a DENTRY bit lock, because a dentry without LOOKUP lock can hardly be used, and inodebit lock coverage upgrade/downgrade is more useful here.

Bye,
- Lai
On Fri, Jan 20, 2012 at 1:11 AM, Oleg Drokin <green at whamcloud.com<mailto:green@whamcloud.com>> wrote:
Hello!

On Jan 17, 2012, at 3:16 AM, Andreas Dilger wrote:

> On 2012-01-16, at 9:25 PM, <tao.peng at emc.com<mailto:tao.peng@emc.com>> wrote:
>> I finally started to work on Lustre dcache cleanup and locking. After reading Lustre, ocfs2 and VFS dcache related code, I came to a design for cleaning up Lustre dcache code and doing distributed locking under dcache. For distributed locking, the main idea is to add a new inode bitlock DENTRY lock to just protect valid dentry, instead of letting LOOKUP lock handle multiple purpose, which makes client unable to know whether file is deleted or not when server cancels LOOKUP lock. Instead, client holds PR mode DENTRY lock on all valid denties and when server cancels it, client knows the file is deleted.
>>
>> For details, please see the attachments (I attached both word and pdf versions as I am not sure if which is more convenient for you:). And please help to review and comment. Thank you!
Thanks for looking into this.
It is indeed possible to add another bit for just the dentry, but the problem is it would need to be granted in conjunction with
the LOOKUP bit anyway (along with permission information), if we don't do this, then we would need to send an additional RPC to get
this information very shortly after lookup in a lot of times and that would be pretty slow. Of course there is no way to get different
lock mode for every bit, so in this scheme the lock mode swould really be the same.
And the (currently) big problem with multiple bit locks is we don't have a way to cancel just subset of a lock (or degrade a lock coverage
I should say). This was planned for quite a while ago, but somehow never ended up at the top of the priority list so was never implemented after all.
There are minor comments on the logic flow after that too. E.g. the locks in lustre are unlocked right away on the client side, but just placed in the LRU and remain on the client in this sort of unreferenced state. When there is a conflict, the server sends the AST RPC and then the lock
is actually released (cancelled) by client. Currently the AST is not delivered to a lock that has non-zero usage counters.
Additionally due to the way we implement locks, it's not possible to have a separate lock for every name of the file.

For your cleanup list, I think that is good. Note that item 'c' was already implemented some time ago, you can see it here:
https://bugzilla.lustre.org/show_bug.cgi?id=16417 the patch is this: https://bugzilla.lustre.org/attachment.cgi?id=24200
It's probably somewhat stale now. It did not work correctly back at the time due to some other logic, but should work now.
You can read the comments in that bug for some more info.

Bye,
   Oleg
--
Oleg Drokin
Senior Software Engineer
Whamcloud, Inc.

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20120130/e5aab0d3/attachment.htm>
