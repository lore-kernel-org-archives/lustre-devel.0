From: Andreas Dilger <adilger@sun.com>
Date: Fri, 20 Feb 2009 17:21:09 -0700
Subject: [Lustre-devel] SOM Recovery of open files
In-Reply-To: <5882C1BC-E01E-42FF-A728-08885E997075@sun.com>
References: <20090130233253.GK3652@webber.adilger.int>
	<63CF2DAF-59F7-4124-8AE9-188927051AAB@sun.com>
	<C68908D1-8287-4870-903E-DDCDED6E31D0@Sun.COM>
	<5882C1BC-E01E-42FF-A728-08885E997075@sun.com>
Message-ID: <20090221002109.GA3863@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 01, 2009  20:24 +0300, Vitaly Fertman wrote:
> On Feb 1, 2009, at 5:45 PM, Vitaly Fertman wrote:
>> thus the only problem here is a stale fh on a client which may let the 
>> client to write to the file after the SOM cache will be re-obtained on
>> MDS, which consists of 2 parts:
>>
>> - an ability of a client to write to an opened file without a  
>>   connection to MDS;

With the layout lock this would not be possible.  The client would be
required to have the layout lock (hence be connected to the MDS) in
order to generate a new write.

>> - an absence of file re-opening on re-connection.
>
> I forgot to mention about truncate (locked & lockless) and lockless IO.
>
> MDS must be aware about opened IOEpoch for truncate as well, otherwise
> obd_punches must be blocked. The situation is pretty rare as we do not
> cache punches on clients and they go away right md_setattr completes,
> but I think what if at the time of the client eviction from MDS, the  
> connection between this client and an OST is unstable so that punches
> will hang in the re-send list for a while, enough for another client
> to modify the file  

I a second client is trying to modify the file while the first one is
having OST connection problems, then the first client would either
succeed to flush its cache, or be evicted by the OST before the second
client can get the extent locks needed to truncate the file.

The same is true whether the truncate is from a remote client (with
client lock) or a lockless truncate (OST holds lock).

> MDS gets a new SOM cache, and later punch will modify the file.
>
> The same for lockless IO.
>
> The locked truncate is involved as it could hang in the re-send list  
> with the lock enqueue, so that enqueue+punch will happen after MDS re- 
> validates SOM cache.

In this case the client will not even begin to send the truncate RPC
until the lock enqueue has succeeded.

> Thus:
> - block truncate and lockless IO;
> - "re-open" truncate on re-connection as well as regularly opened files.
>
> This must happen even if SOM is disabled but the client already supports 
> it (clients are upgraded first). Otherwise, the interoperability will be  
> broken.

It isn't clear to me why the done_writing RPC needs to be sent separately
for each truncate?  The client is already sending an RPC to the MDS for
each truncate to update the size there, if file is not open (and currently
has no objects), and to verify file write permission (avoid truncate of
in-use executables).

Now, if this only happens on recovery I don't have a huge objection.  If
the "done_writing" RPC needs to be sent to the MDS for every single truncate,
then that is a major performance concern.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
