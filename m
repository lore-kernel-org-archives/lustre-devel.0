From: Andreas Dilger <adilger@sun.com>
Date: Thu, 14 May 2009 15:28:33 -0600
Subject: [Lustre-devel] Thinking of Hacks around bug #12329
In-Reply-To: <C4317953-7323-4FD0-9D36-A78DA94EF216@sun.com>
References: <9c21eeae0905131106w23032105tdcf9a2399fb550df@mail.gmail.com>
	<20090514062224.GD3209@webber.adilger.int>
	<13983758-B9C5-4770-A4AC-39AAF75C6980@sun.com>
	<C4317953-7323-4FD0-9D36-A78DA94EF216@sun.com>
Message-ID: <20090514212833.GN3209@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On May 14, 2009  11:48 -0400, Oleg Drokin wrote:
> On May 14, 2009, at 10:25 AM, Oleg Drokin wrote:
>> Actually just to combat situqtion like this MGCs are doing a bit of a
>> pause
>> for a few seconds before refetching config, I remember there was a bug
>> and this measure was introduced as a fix.
>
> Nic actually tuned in and said that the backoff (set at 3 seconds now)
> is certainly not enough, since it takes this long to only mount actual
> on-disk fs.

> Anyway that got me thinking that we have a "coarse-grained" locking  
> problem.  Since OSTs don't connect to other OSTs, they do not care about
> OST connections, and perhaps if we introduce bit-locks to MGS locks as
> well to indicate client type, then locks from OSTs would only be revoked
> when MDS connects or disconnects, MDS locks would only be revoked when
> OSTs connect or disconnect and client locks would be revoked always.
> Or alternatively we can split our single resource right now to a few  
> separate:

> one for osts one for MDSes for example, sure that would mean clients  
> would not have to take two locks, but on the other hand there would
> be supposedly less information to reparse when one of those locks is
> invalidated.

I would tend to prefer the latter.  Having separate resource IDs for
the different llogs makes it a lot cleaner in the end.  Ideally,
picking a relatively unique resource ID for that config log would
allow us to separate the configs between different filesystems.

The OSTs in fact don't really need to read the same llog as the client for
very many things (some shared tunables, perhaps), and there also isn't
a big problem IMHO to store the same tunables in two different config
llogs (one for servers and one for clients).  Generally, the server-side
tunables are not used by the client, and vice versa.  Probably the only
place that would need to read two config llogs is the MDS, which is both
a server and a client of the OSTs.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
