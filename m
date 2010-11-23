From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Tue, 23 Nov 2010 14:47:40 -0700
Subject: [Lustre-devel] Stripe offset default
In-Reply-To: <4FE51862-3264-4248-948F-CF70C56FD8AD@xyratex.com>
References: <016b01cb8b32$cc3a9c90$64afd5b0$@com>
	<4FE51862-3264-4248-948F-CF70C56FD8AD@xyratex.com>
Message-ID: <70CD76E6-0E31-4E98-8937-175C9C17C352@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-11-23, at 13:50, Peter Braam wrote:
> The  proposal for acl / Group / users violates Posix, and may lead to results users don't expect.  Sgid directories and inheritance on ACLs are safer I think.

I think you misunderstood Eric's comment.  He wasn't suggesting that the use of an OST pool would set the user, group, or ACL of a file created within that pool.  That would indeed be confusing to users.


Rather, Eric was suggesting that there should be a user/group/ACL permission check for the _use_ of a particular pool, so that only allowed users/groups could access the "SSD" pool, for instance.  That has been under discussion for a long time already, and is a natural extension of the base OST pool functionality.  Extending this further to allow and/or select pools based on the originating client NID or the filename also makes sense.

> On Nov 23, 2010, at 10:20, "Eric Barton" <eeb@whamcloud.com> wrote:
>> P.S. Do people also agree that setting user/group/ACL permissions on
>> OST pools would be a Good Thing?

Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.
