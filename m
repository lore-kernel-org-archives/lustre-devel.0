From: Andreas Dilger <adilger@sun.com>
Date: Mon, 03 Nov 2008 16:42:00 -0700
Subject: [Lustre-devel] Agent/Coordinator RPC mechanisms.
In-Reply-To: <490F5D26.3000105@sun.com>
References: <490F2F10.1040302@cea.fr> <490F5D26.3000105@sun.com>
Message-ID: <20081103234200.GL3184@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Nov 03, 2008  12:20 -0800, Nathaniel Rutman wrote:
> Aurelien Degremont wrote:
>>
>> A - Coordinator/Agent start
>> ---
>>
>> 1 - MDT starts (Coordinator features are available by default as the
>> coordinator reuse MDT threads)
>> 2 - Client start with a agent flag (mount -o agent)
>> 3 - Client connects to MDT (piggyback the coordinator registration on
>> the MDT connection RPC (with a flag?) ?)
> yes, I think so, just use a connect flag

In some existing cases (e.g. read-only mount) it is desirable to change
the configuration after the client is mounted (e.g. mount -o remount -o ro)
and this should probably be possible if this is really a mount option.
This is normally implemented with a "MDS_SET_INFO" RPC.

>> 4 - If no direct registration, Client send a registration request to the
>> coordinator through MDT connection after it was initiated.
> don't see a need, unless there's some agent data we want to report at  
> registration
>> 5 - Agent is ready.
>>
>> B - Request dispatch
>> ---
>>
>> 1 - Coordinator receives a request. It writes in its llog file the
>> migration request.
>> 2 - Coordinator sends a migration request to one of its registered agents.
> On the client's reverse import, presumably.  So we need to add a service  
> during
> agent startup, probably mdc startup.   No agents on a liblustre client.
>>
>> 3 - The agent manages the requests.
>> 4 - The agent sends periodically some migration status update to
>> coordinator.
> We were talking about the copytool sending updates via file ioctls
>> 5 - When coordinator receives status finished, it cleans its llog entry
>> for this migration.
> This works for copyin/copyout, but not unlink, since there's no file for
> an agent to do an update ioctl on.
>>
>> C - MDT crash
>> ---
>>
>> 1 - MDT crashes.
>> 2 - MDT is restarted.
>> 3 - The coordinator recreates its migration list, reading the its llog.
>> 4 - The client, when doing its recovery with the MDT, reconnects to the
>> coordinator. It also sends the current status of its migrations.
> Status is sent by copytools periodically, asynchronously from reconnect.
> As far as the copytools/agent is concerned, the MDT restart is invisible.
>> 5 - Thanks to this, the coordinator has rebuilt its migration list and
>> agent list.
>> (as this is standard mdt recovery, this supports failover also)
> The agent list is rebuild at reconnect time.  The migration list is simply
> the list of unfinished migrations; it reads that from the llog whenever  
> it wants to
> (no need to keep it in memory all the time) and decides to restart
> stuck/broken migrations as usual.  (E.g. it could read the log once  
> every minute
> checking for last_status_update_time's older than X.)  I don't see any  
> reason it needs
> to be in memory all the time.
> So logs should contain fid, request type, agent_id (for aborts),  
> last_status_update_time, last_status.
>>
>> E - Client crash
>> ---
>>
>> 1 - Client crashes
>> 2 - MDT notices the client node did not respond anymore. The node is
>> evicted, its migrations are dispatched on another nodes. Node eviction
>> (oss are supposed to evict it also) prevent the movers from this node to
>> go on their migration. We could restart it on another agent without  
>> issue.
> 2. MDT evicts client

Note that there is already a mechanism for the MDS to evict a client from
all of the OSTs at the same time - "evict_by_nid".

> 3. Eviction triggers coordinator to re-dispatch immediately all of the  
> migrations from that agent
> 4. For copyin, MDT must force any existing agent I/O to stop.  Hmm, but  
> agents are ignoring
> the layout lock - how are we going to do this?  Maybe it's not so bad if  
> two agents are trying to
> copyin the file at the same time?  File data is the same...
>
> F - Copytool crash
> Copytool crash is different from a client crash, since the client will  
> not get evicted
> 1. Copytool crashes
> 2. Coordinator periodically scans the list of open migrations for old  
> last_status_update_time's
> 3. Coordinator sends abort signal to old agent
> 4. Coordinator re-dispatches migration

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
