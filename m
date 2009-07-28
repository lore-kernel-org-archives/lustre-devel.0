From: Vitaly Fertman <Vitaly.Fertman@Sun.COM>
Date: Wed, 29 Jul 2009 00:42:01 +0400
Subject: [Lustre-devel] SOM Recovery of open files
Message-ID: <0F955918-4B3F-4CAB-B273-3479B8F82F08@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi All,

after our today talk on irc about SOM re-connect issues, I have tried to
re-phrase the SOM problem in some more clear way, the result is the  
list of
items we need to add/care about:

1. re-open files (precisely IOEpochs here) on re-connect for opened  
files.
MDS must be aware about opened IOEpochs in the cluster to maintain the
SOM cache properly. If IOEpoch is closed, the dirty cache must not  
exist in
the cluster nor new IO is allowed [this is to be done as a part of  
simplified
interoperability].

2. re-open IOEpochs on re-connect for truncates.
there is a gap between md_setattr and obd_punch, and MDS must be aware
punch has completed, md_setattr opens IOEpoch and the later  
md_done_writing
closes it saying the punch completed. the reasoning of re-openning  
IOEpoch
is similar to (1).

3. block new IO rpc if there is no connection to MDS (syscalls).
the reasoning is similar to (1), thus after eviction MDS thinks  
IOEpoch is
closed and let next client to re-build the SOM cache, but the evicted  
client
may want to write to the file. [this is to be done through LOV EA lock]

4. block cached lockless IO rpc (i.e. rpc is sitting in the sending or  
re-sending
lists) if there is no connection to MDS.
the reasoning is similar to (3), but there is a gap in time between  
syscall
happens and rpc is issued, moreover, rpc may be re-sent several times,  
if
the time is enough for next client to access the file and re-built the  
cache,
our write/truncate will destroy the cache.

5. block cached enqueue rpc if there is no connection to MDS.
the reasoning is similar to (4), the write/truncate syscall happens  
when the
connection existed but has been lost just before issuing the enqueue  
rpc,
if the time is enough for next client to rebuild the cache on MDS  
before the
evicted client gets the extent lock, the data put into clients cache  
in the
same syscall will destroy the cache once get flushed to OST.

note: the existent dirty cache under extent lock is not a problem, it  
could be
flushed later (just before rebuilding the SOM cache) by canceling  
extent lock;

6. there is a gap between client eviction and the time when client  
detects it
is evicted.
it concerns (4&5), the client is not aware about its eviction from  
MDS, it continues
to write to OST for some time. if the time is long enough for next  
client to rebuild
the SOM cache on MDS, such a later write will destroy the cache.

7. there is a gap between rpc is send and obtained by OST.
even if we cancel IO rpc from re-send queue, some previous attempt to  
send
it may finally succeed, if the client has been evicted and the time is  
long
enough for next client to rebuild the SOM cache on MDS, such a later  
write will
destroy the cache.

note: this all concerns MDS failover and MDS upgrade as well as client  
may
disappear at any time.

p.s. the previous email is attached, it has some more detailed  
scenarios and
has some attempts to resolve it, not very successful though.

--
Vitaly

-------------- next part --------------
An embedded message was scrubbed...
From: Vitaly Fertman <Vitaly.Fertman@Sun.COM>
Subject: Re: [Lustre-devel] SOM Recovery of open files
Date: Fri, 13 Mar 2009 18:32:00 +0300
Size: 11729
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090729/c0a94f3e/attachment.eml>
-------------- next part --------------
