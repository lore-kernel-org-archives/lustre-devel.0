From: Peter Braam <Peter.Braam@Sun.COM>
Date: Wed, 24 Sep 2008 10:48:48 +0800
Subject: [Lustre-devel] Interoperability ambitions
In-Reply-To: <48D9A1F3.5020504@sun.com>
Message-ID: <C4FFCB90.7DC3%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Yes - and having this "stop the client" principle will make for something
that can be used in future upgrade scenarios as well.

Note that I have copied lustre-devel as this is of general interest.

Peter


On 9/24/08 10:12 AM, "Huang Hua" <H.Huang@Sun.COM> wrote:

> Hello All,
> 
> This is what I propose (it is mentioned in the revised HLD: see bug
> 11824, but I'd like to enhance it as followings)
> 
> 
> --------------------------------
> Upgrade is a special fail-over, invoked and controlled by administrator.
> We can try to make the whole lustre into a ``Quiescent'' state and block
> any update operations.
> This is something similar while we take a snapshot for a file system.
> Clients block any incoming update operations (maybe all operations
> except sys_statfs()) and sync all pending operations. By this, all
> transactions on client side and server side are committed. There are
> only some ``open'' requests in the replay queue. These open requests are
> already committed on server side. They are still in replay queue because
> the files are not closed yet.
> 
> In this "Quiescent" state, all read-only operations, such as getattr,
> lookup, statfs can pass through.
> Maybe only statfs() can pass through. Wire protocol for statfs() does
> not change from 1.8 to 2.0.
> And this enables users can execute "df" command in this state.
> 
> This idea is similar to super_operation->write_super_lockfs() in local
> file system.
> 
> By this mechanism, we can avoid reformatting for all requests except
> open+create enqueue.
> Since the open+create enqueue itself is committed by server at the time
> of upgrade, the server only need to open the newly created file.
> The new file, created by 1.8 MDS server, can be opened by 2.0 MDS server
> while replay.
> 
> The clients will leave this "Quiescent" state while the upgrade is done.
> 
> This will tremendously simplify the upgrade.
> Especially the reformatting of all resend/replay/delayed request, and
> then handle replay case in upgrade case, and
> test all possible upgrade cases.
> --------------------------------
> 
> What's your comment?
> 
> Thanks,
> Huang Hua
> 
> 
> 
> Andreas Dilger wrote:
>> On Sep 23, 2008  08:33 +0800, Peter J. Braam wrote:
>>   
>>> I understood from Huang Hua that a considerable degree of perfection is
>>> being pursued with the interoperability of 1.8 clients and 1.8/2.0 servers.
>>> 
>>> In particular I was quite worried when I heard what Huang Hua has been asked
>>> to do.  It seems excessive to me to make replay/resend/version recovery all
>>> work in a failover situation from 1.8 to 2.0.  This requires incredibly
>>> detailed testing of every RPC that might be rolled back or in transit across
>>> such an upgrade, something that is not too easy to automate I think.  Quite
>>> apart from this, it might not be transparent to user applications if during
>>> 1.8(client)-2.0(server) the same fids are not allocated to the client (I am
>>> not sure if this would be the case).
>>>     
>> 
>> Minor note - IGIF will ensure that client-visible identifiers remain the
>> same over a 1.8->2.0 upgrade.  This will NOT be true in the case of a
>> 2.0->1.8 downgrade (which will require client eviction), but that should
>> only happen if there are already serious problems with 2.0.
>> 
>>   
>>> It would be much better, to dramatically reduce the hassles with protocol
>>> interoperability, to have a mechanism to tell a client to wait for
>>> completion of its requests and block new ones while the server failover is
>>> in progress.  This would be organized through the configuration lock.  This
>>> would lead to a situation where no state in the protocol needs to be
>>> recovered.
>>> 
>>> Why is this not being pursued?
>>> 
>>> Peter
>>>     
>> 
>> Cheers, Andreas
>> --
>> Andreas Dilger
>> Sr. Staff Engineer, Lustre Group
>> Sun Microsystems of Canada, Inc.
>> 
>>   
> 
