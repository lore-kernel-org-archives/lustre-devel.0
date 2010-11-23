From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Tue, 23 Nov 2010 14:40:31 -0700
Subject: [Lustre-devel] Stripe offset default
In-Reply-To: <016b01cb8b32$cc3a9c90$64afd5b0$@com>
References: <016b01cb8b32$cc3a9c90$64afd5b0$@com>
Message-ID: <B167E04A-8D08-4E24-A7A8-D25CD37C0A5E@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-11-23, at 10:20, Eric Barton wrote:
> ... setting the default stripe offset is positively dangerous.

Replied to this on Chris Morrone's email, though it seems his email lost Nick from the CC list...  I wouldn't go so far as to call it "dangerous", but the use of old 1.4.x or 1.6.x positional parameters should be eliminated.  That is something that only Nick can manage, since it doesn't matter what we do in newer Lustre releases if the users are only running old versions of the tools.

Starting by applying the "positional parameters return an error" to his 1.6.x lfs would be a good start.  I made this available as attachment 32308 on bug 14836, where that usage was originally deprecated.

> P.S. Do people also agree that setting user/group/ACL permissions on
> OST pools would be a Good Thing?

Sure - being able to limit the use of pools, including the default "use all OSTs" pool, to specific users/groups/nodes/networks would be great.  Similarly, being able to specify certain pools as defaults for particular users/groups/nodes/networks is equally desirable.  Both would need some effort in the LOV QOS code on the MDS, to allow the layout to come from something other than the parent directory.

Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.
