From: Jim Vanns <james.vanns@framestore.com>
Date: Wed, 18 May 2011 10:29:09 +0100
Subject: [Lustre-devel] Understanding of LDLM SLV, CLV correct?
Message-ID: <1305710949.8503.95.camel@sys367.ldn.framestore.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi, this is my first post to the list and sadly I've had to resort to
the developer list because I can't find much detailed info about the
LDLM intrinsics other than the comments in the source code (which I've
read).

OS: Linux 2.6
Client-side version: 1.8.x
Server-side version: 1.6.x
Configuration: 4 nodes (each w/ 4G RAM, 4 CPUs) make up 12 OSSs, 1 MDS

This is an old and perhaps odd configuration that I've been trying to
get my head around!

I'm helping our sysadmins get to the bottom of poor client-side
performance where the client is evicting pages from it's cache before a
process has finished with them essentially causing a reread from disk,
network and back into the cache! Repeat ad infinitum.

As I understand it this boils down to the server lock volume remaining
almost constantly as 1 and certainly never greater than the client lock
volume causing a quicker than normal expiry of the lock(s) the client
had been granted and when these locks are released so are the pages
flushed from the cache.

We're using, on the client-side, the dynamic calculation of the LDLM LRU
size which is based on the numbers I mentioned above - the SLV and CLV.
Sure enough if I overwrite every OSC lru_size on a single client node to
NR_CPU*100 (using lctl set_param or /proc) then the LRU size dynamic
calculation is disabled and we can see our pages remain in RAM (in the
page cache).

Conversely if I get clients that have had several large files open for
some time to kill-off the processes that had them open, the lock grant
does not go down and neither does the page cache. This is a little
ironic because this is what we want other clients to do! Is there some
sort of (resource/lock) contention here?

It seems that there is a correlation between the SLV and the number of
current granted locks? As I said the SLV on every OSS is more-or-less 1
all the time. The #locks granted is quite high - in the order of 10s to
100s of thousands per OSS. The number of client nodes is approximately
1000 with God knows how many millions of files!

Am I correct in my assumption that on any individual client node that
the following files:

cat /proc/fs/lustre/ldlm/namespaces/<OSCs>/lock_count

contain the number of locks granted from each OSS to that client only?
Is there a cancel/evict/expiry timeout attributed to each of these
locks? As I hinted in the previous paragraph on machines that have
closed files their lock_count does not decrease and therefore(?) neither
does their page cache (until pressure to remove them comes from
elsewhere in the OS).

The problem is, is that I think this is preventing other nodes in the
cluster from being able to retain any pages in their cache for a decent
amount of time (i.e. when they are still processing data from open
files).

I guess what I am asking is for confirmation on all of the above. I'm
pretty new to Lustre diagnosis! If this was ever a bug (the calculation
of the SLV never changing for instance or simply not being granular
enough) then it is probably fixed by now - 2.0 is the current release
right?

Are there any configuration parameters that may help in this instance,
however? Could setting the following:

options ost oss_num_threads=384

per *server* be a little over zealous considering each server acts as 4
OSSs and it only has 4G of RAM? This is how it is set at the moment.

Any further direction would be appreciated!

Regards,

Jim Vanns

-- 
Jim Vanns
Systems Programmer
Framestore
