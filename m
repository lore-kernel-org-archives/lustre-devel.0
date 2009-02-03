From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Tue, 03 Feb 2009 04:39:59 -0500
Subject: [Lustre-devel] Sub Tree lock ideas.
In-Reply-To: <20090203090409.GT28818@webber.adilger.int>
References: <7D9ABF96-6BD8-4F7A-A5AE-F08BF04854B2@sun.com>
	<20090126100856.GD3652@webber.adilger.int>
	<5EF2479C-CFC4-4CD5-95E8-50368A7D5083@Sun.COM>
	<20090202225044.GL28818@webber.adilger.int>
	<75012621-B9AB-4093-AC23-E6E2E28D774F@Sun.COM>
	<20090203090409.GT28818@webber.adilger.int>
Message-ID: <7AE74BBB-7DE0-4D15-AB62-A004A74F55E3@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Feb 3, 2009, at 4:04 AM, Andreas Dilger wrote:
>> It would be a lot of batching in many common usecases like "untar a
>> file", "Create a working files for applications, all in same dir/ 
>> dir tree".
> Maybe I misunderstand, but all of this batching is in the case of a  
> single
> client that is doing operations to send to the MDS.  What I was  
> thinking
> would be a rare case is batching from the server to the client when  
> e.g.
> a bunch of clients independently open a bunch of files that are in a
> directory for which a client holds a STL.

Right. I am speaking about aggregation at client level to send batched  
RPCs
to the server. (e.g. tons of creates).

> In the latter case, since all of the RPCs are coming from different  
> clients,
> it is much harder for the server to group them together into a  
> single RPC
> to send to the STL client.

Indeed, this is much harder. (but still possible if it is just one  
client that
does readdir+ and we do a batched glimpse to a client holding some  
locks on
files in that dir).

>> From the above my conclusion is we do not necessarily need SubTree  
>> locks
>> for efficient metadata write cache, but we do need it for other
>> scenarios (memory conservation). There are some similarities in the
>> functionality too, but also some differences.
>>
>> One particular complexity I see with multiple read-only STLs is every
>> modifying metadata operation would need to traverse the metadata tree
>> all the way back to the root of the fs in order to notify all  
>> possible
>> clients holding STL locks about the change about to be made.
> Sorry, I was only considering the case of a 1-deep STL (e.g. a DIR  
> lock,
> not the arbitrary-depth STL you originally described).  In that case,
> there is no requirement for more than a single level of STL to be
> checked/cancelled if a client is doing some modifying operation  
> therein.
> This is no different than e.g. if a bunch of clients are holding the
> LOOKUP lock on a directory that has a new entry in it.

The problem in this case then becomes that if we operate within a tree
16 entries deep, we have consumed 10% of our lock capacity (getting a  
lock
on every subdir in process). If we have several apps going on, then  
even more.


> Eric also had a proposal that the DIR lock would be a "hash extent"  
> lock
> instead of a single bit, so that it would be possible (via lock  
> conversion)
> to avoid cancelling all of the entries cached on a client when a  
> single
> new file is being added.  Only the hash range of the entry being added
> would need to be removed from the lock, either via a 3-piece lock  
> split
> (middle extent being cancelled) or via a 2-piece lock split (smallest
> extent being cancelled).

Yes, this is also possible and would be beneficial even with WRITE  
lock on a dir.
But this really is completely orthogonal issue.

Bye,
     Oleg
