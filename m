From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Thu, 05 Mar 2009 15:35:58 -0500
Subject: [Lustre-devel] Fast checkpoints in Lustre today,
 at	essentially zero cost.
In-Reply-To: <20090305200035.GF3199@webber.adilger.int>
References: <7636AEA6-3D56-491E-A085-C85CA4D96020@sun.com>
	<20090305200035.GF3199@webber.adilger.int>
Message-ID: <47835A78-9713-4C6B-B65C-DA243115C656@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Mar 5, 2009, at 3:00 PM, Andreas Dilger wrote:
> We don't need to go to the sub-optimal striping to get this result,
> as that causes not only lots of seeking on the OSTs, but also requires
> the clients to get locks on every OST.  Instead it is possible today
> to just increase this limit to be much larger via /proc tunings on
> the client for testing (assume 1/2 of RAM is large enough):
> client# lctl set_param osc.*.max_dirty_mb=${ramsize/2}

Of course! But I am speaking of a situation like say ORNL, where
users cannot control this setting directly.

> One possible downfall is that when multiple clients are writing to the
> same file, if the first client to get the lock (full [0-EOF] lock) can
> dump a huge amount of dirty data under the lock, all of the other  
> clients
> will not even be able to get a lock and start writing until the first
> client is finished.

This is unlikely case, since as soon as lock is cancelled, it cannot  
be rematched.

> I think this shows up in SSF IOR testing today when the write chunk  
> size
> is 4MB being slower than when it is 1MB, because the clients need to  
> flush
> 4MB of data before their lock can be revoked and split, instead of  
> just 1MB.
> Having lock conversion allow the client to shrink or split the lock  
> would
> avoid this contention.

I would think the reason is different since essentially 4M memory copy  
is very small
and chances are client was ably to issue write syscall many times per  
lock acquisition.
But this is pure speculation from my side.

Bye,
     Oleg
