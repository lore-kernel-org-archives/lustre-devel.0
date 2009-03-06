From: Andreas Dilger <adilger@sun.com>
Date: Fri, 06 Mar 2009 16:48:59 -0700
Subject: [Lustre-devel] layout lock / extent lock interaction
In-Reply-To: <49B1AAEE.2080104@sun.com>
References: <20090130233253.GK3652@webber.adilger.int>
	<63CF2DAF-59F7-4124-8AE9-188927051AAB@sun.com>
	<C68908D1-8287-4870-903E-DDCDED6E31D0@Sun.COM>
	<5882C1BC-E01E-42FF-A728-08885E997075@sun.com>
	<20090221002109.GA3863@webber.adilger.int> <49B16509.9000409@sun.com>
	<20090306191620.GB3199@webber.adilger.int> <49B1AAEE.2080104@sun.com>
Message-ID: <20090306234859.GH3199@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mar 06, 2009  14:59 -0800, Nathaniel Rutman wrote:
> How about if we introduce the concept of a layout generation?  The  
> generation is stored in the layout and also with each OST object.  When  
> the MDT takes the extent locks it sends the new generation to the OSTs.   
> Clients send the layout generation along with any extent lock enqueue.   
> The OSTs only grant extents to clients that match the current  
> generation.  Maybe "match or exceed" in case OST dies before new gen can  
> be recorded.  And OST increases gen to latest seen whenever any (MDT or  
> client) extent lock is enqueued.

I like this idea.  We would need some place to store this information in
the LOV EA on the MDT and pass it to the client, and to/on the OST.
We already have:
- inode versions (VBR; change on each file modification)
- IO epochs (SOM; change slowly as files are written, not persistent)
- recovery epochs (CMD/WBC; change frequently as global epochs are committed)

We could concievably use the space in "l_ost_gen" in the first stripe,
as we have never implemented OST generations.  Those were intended for
OST replacement, and/or OST snapshots, but have never been implemented.
It also has the drawback that it is per-stripe, and we would likely be
wasting the additional l_ost_gen values in later stripes in addition
to breaking their intended use.

Maybe we just bite the bullet and add another LOV EA type?

>> A safe option (AFAICS) is to have MDS eviction force OST eviction (via
>> obd_set_info_async(EVICT_BY_NID).  That would also resolve some other
>> recovery problems, but might be overly drastic if e.g. the client is
>> being evicted from the MDS due to router failure or simple network
>> partition.  Having a proper health network and also server-side RPC
>> resending would help avoid such problems.
>   
> This is drastic, but on the other hand we only need to do this if the  
> layout is being changed.  Of course, since eviction would happen before  
> layout change we would need to remember who was evicted and hasn't  
> reconnected...

No, I don't think we need to remember recently-evicted clients, since
the MDS would also evict clients from all OSTs immediately.  The goal
to avoid this drastic action would be to avoid evicting the client
from the MDS in the first place (e.g. by request resend, health net),
which is a double win.

>> This is one of the main reasons why having DLM servers on one node
>> controlling resources on another node is a bad idea.  We had similar
>> issues in the past when we locked all objects via the OST only on
>> stripe index 0, and we might have similar problems with subtree locks
>> in the future with CMD or any SNS RAID that is only locking a subset
>> of objects.
>>   

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
