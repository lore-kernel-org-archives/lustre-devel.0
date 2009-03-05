From: Andreas Dilger <adilger@sun.com>
Date: Thu, 05 Mar 2009 14:16:53 -0700
Subject: [Lustre-devel] Fast checkpoints in Lustre today,
 at essentially	zero cost.
In-Reply-To: <47835A78-9713-4C6B-B65C-DA243115C656@Sun.COM>
References: <7636AEA6-3D56-491E-A085-C85CA4D96020@sun.com>
	<20090305200035.GF3199@webber.adilger.int>
	<47835A78-9713-4C6B-B65C-DA243115C656@Sun.COM>
Message-ID: <20090305211653.GH3199@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mar 05, 2009  15:35 -0500, Oleg Drokin wrote:
> On Mar 5, 2009, at 3:00 PM, Andreas Dilger wrote:
>> We don't need to go to the sub-optimal striping to get this result,
>> as that causes not only lots of seeking on the OSTs, but also requires
>> the clients to get locks on every OST.  Instead it is possible today
>> to just increase this limit to be much larger via /proc tunings on
>> the client for testing (assume 1/2 of RAM is large enough):
>> client# lctl set_param osc.*.max_dirty_mb=${ramsize/2}
>
> Of course! But I am speaking of a situation like say ORNL, where
> users cannot control this setting directly.

But if this is just testing, then we may as well avoid the extra overhead
and apples-to-oranges comparison of single-stripe vs. many-stripe files
and allow single-stripe files to cache a lot of data.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
