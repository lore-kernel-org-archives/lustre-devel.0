From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Tue, 03 Feb 2009 01:24:32 -0500
Subject: [Lustre-devel] Sub Tree lock ideas.
In-Reply-To: <20090202225044.GL28818@webber.adilger.int>
References: <7D9ABF96-6BD8-4F7A-A5AE-F08BF04854B2@sun.com>
	<20090126100856.GD3652@webber.adilger.int>
	<5EF2479C-CFC4-4CD5-95E8-50368A7D5083@Sun.COM>
	<20090202225044.GL28818@webber.adilger.int>
Message-ID: <75012621-B9AB-4093-AC23-E6E2E28D774F@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Feb 2, 2009, at 5:50 PM, Andreas Dilger wrote:

> On Jan 27, 2009  23:39 -0500, Oleg Drokin wrote:
>> On Jan 26, 2009, at 5:08 AM, Andreas Dilger wrote:
>>> A few comments that I have from the later discussions:
>>> - you previously mentioned that only a single client would be able  
>>> to
>>> hold a subtree lock.  I think it is critical that multiple clients  
>>> be
>>> able to get read subtree locks on the same directory.  This would be
>>> very important for uses like many clients and a shared read-mostly
>>> directory like /usr/bin or /usr/lib.
>> In fact I see zero benefit for read-only subtree lock except memory
>> conservation, which should not be such a big issue. Much more  
>> important
>> is to reduce amount of RPCs, esp. synchronous ones.
> Memory conservation on the server is very important.  If there are  
> 100k
> clients and a DLM lock is 2kB in size then we are looking at 200MB for
> each lock given to all clients.  With an MDS having, say, 32GB of  
> RAM and
> we would consume all of the server RAM with only 160 locks/client.

Well. You are of course right and ad certain scale we indeed need to
consider the memory conservation effect as well.

>> We can start with implementation of just allowing WRITE locks on a
>> directory that would be only responsible for this directory and its
>> content (HELPS: by allowing to aggregate creates into bunches before
>> sending) + a special "entire file lock" (perhaps implemented by just
>> WRITE lock on a file) metadata lock that would guard all file data
>> without obtaining any locks from OSTs (would be revoked by open from
>> another client, perhaps would need to support glimpses too).
> Well, if the client will generate the layout on the newly-created
> files, or will request the layout (LOV EA) lock on the files it wants
> exclusive access to this is essentially the "entire file lock" you  
> need.
> For existing files the client holding the layout lock needs to cancel
> the OST extent locks first, to ensure they flush their cache.

This is fine as one of teh idea, but would not work all that nicely in  
all
possible usecases. Suppose we would want read-only lock like this too,
for example.

>> Another important thing we would need is lock conversion  
>> (downconversion
>> and try-up conversion) so that we do not lose our entire cached  
>> directory
>> content after conflicting ls came in and we wrote it out. (we do  
>> not care
>> all that much about writing out entire content of the dirty  
>> metadata cache
>> at this point, since we still achieve the aggregation and  
>> asynchronous
>> creation, even just asynchronous creation would help).
> We also want to have lock conversion for regular files (write->read)  
> and
> for the layout lock bit (so clients can drop the LOV EA lock without
> dropping the LOOKUP or UPDATE bits).

Yes, absolutely.

>> Perhaps another useful addition would be to deliver multiple blocking
>> and glimpse callbacks from server to the client in a single RPC (as a
>> result of a readdir+ sort of operation inside a dir where many  
>> files have
>> "entire file lock") (we already have aggregated cancels in the other
>> direction).
> Well, I'm not sure how much batching we will get from this, since it  
> will
> be completely non-deterministic whether multiple independent client
> requests can be grouped into a single RPC.

It would be a lot of batching in many common usecases like "untar a  
file",
"Create a working files for applications, all in same dir/dir tree".

 From the above my conclusion is we do not necessarily need SubTree  
locks
for efficient metadata write cache, but we do need it for other  
scenarios
(memory conservation). There are some similarities in the  
functionality too,
but also some differences.

One particular complexity I see with multiple read-only STLs is every
modifying metadata operation would need to traverse the metadata tree  
all
the way back to the root of the fs in order to notify all possible  
clients
holding STL locks about the change about to be made.

Bye,
     Oleg
