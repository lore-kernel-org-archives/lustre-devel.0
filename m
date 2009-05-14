From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Thu, 14 May 2009 10:25:26 -0400
Subject: [Lustre-devel] Thinking of Hacks around bug #12329
In-Reply-To: <20090514062224.GD3209@webber.adilger.int>
References: <9c21eeae0905131106w23032105tdcf9a2399fb550df@mail.gmail.com>
	<20090514062224.GD3209@webber.adilger.int>
Message-ID: <13983758-B9C5-4770-A4AC-39AAF75C6980@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On May 14, 2009, at 2:22 AM, Andreas Dilger wrote:
> Sounds unpleasant.  I wonder if this is driven by the fact that the
> MGS clients (OSTs are also MGS clients) don't expect a huge amount of
> change at any one time so they try to refetch the updated config in
> an eager manner.  This probably increases the queue of requests on
> the MGS linearly with the number of OSTs, and new OST connections are
> getting backed up behind this.

Actually just to combat situqtion like this MGCs are doing a bit of a  
pause
for a few seconds before refetching config, I remember there was a bug
and this measure was introduced as a fix.

What's interesting is that I actually have 1200 OSTs system in a  
single node
and the mount (even format & mount) takes nowhere near 5 hours.
In fact I am up to ~950 OSTs mounted in around 20 minutes or so, I  
think,
at which point the node usually OOMs. (and it's all in a heavily  
swapping vmware too)
And this setup does have some extra complications like hitting a bug  
in MGC
where every target establishes its own connection to MGS where only  
one connection
for entire node is needed, and then there is no dynamic lru enabled,  
so mgc locks
are just pushed out of the lru and I see constant attempts to requeue  
the locks
even if the mount is finished.
Of course on the other hand even if I run mounts in parallel (and I  
do), MGC does not
rush inn with all of the requests in parallel still, I think.


Bye,
     Oleg
