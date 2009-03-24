From: Robert Read <rread@sun.com>
Date: Tue, 24 Mar 2009 16:53:29 -0700
Subject: [Lustre-devel] some observations about metadata writeback cache
In-Reply-To: <m37i2x3mny.fsf@bzzz.home.net>
References: <m37i2x3mny.fsf@bzzz.home.net>
Message-ID: <3AF28E58-CF74-49C9-AED7-86BDBB5EEC65@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Alex,

I'm trying to figure out how untrusted (what I'm calling simple)  
clients and trusted WBC-type clients will work together at the same  
time. Simple clients will need to participate in the oldest volatile  
epoch calculation, but will need to retain operations for replay.   
I've draw a simplified picture of how I think things are beginning to  
fit together, but more thought is needed here.

Simple clients
     - don't participate in global epochs
     - don't have a node epoch or add epochs to messages
     - sends operations to MD server
     - replies include extended opaque "replay" data field
     - replayed operations the replay data is included
     - replay list is flushed based on "transno" (which may actually  
be the
       epoch and the replay data contains the actual transnos)
     - multiple operations can have the same "transno"
Trusted clients
     - participate in global epochs
     - have a capability that allows them to participate
     - sends updates to OSD servers with epochs
     - replay-data contains only a single reply, could be same as today
     - when all update replies are received operation is placed on redo
       list
     - redo list flushed based on OVE
MD server
     - MDT/MDD receives operations without epochs
	- sets the operation epoch to the node's current epoch
         - all updates executed for that operation will use same epoch.
         - replies are gathered and sent in "replay data" field
	- participates in OVE - how much state does it need to retain to do  
this on
	  behalf of the clients?
     - OSD receives updates epochs
         - handled locally
         - normal reply returned

robert

-------------- next part --------------
A non-text attachment was scrubbed...
Name: cmd-recovery.pdf
Type: application/pdf
Size: 50831 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090324/f9b54ac6/attachment.pdf>
-------------- next part --------------



On Mar 9, 2009, at 23:41 , Alex Zhuravlev wrote:

>
> Hello,
>
> I spent quite amount time thinking of wbc problem and I'd like to  
> share
> the thoughts.
>
> for wbc we store metadata in local memory for two purposes:
> 1) later reintegration
> 2) read access (lookup, getattr, readdir) w/o server involvement
>
> for (2) it makes sense to store everything as "state". e.g. directory
> contains all alive entries, inode contains last valid attributes, etc.
> let's call it state cache.
>
> in theory reintegration can be done from the state cache and this is
> probably the most efficient way (in terms of network traffic and  
> memory
> footprint). but for simpler implementation we can introduce log of
> changes for (1). in turn, the log can be per-object or just global log
> for given filesystem.
>
> it's hard to implement state cache in terms of operations because  
> usual
> operation involves more than one object (e.g. parent directory +  
> file).
> it's much simpler when state cache is per-object. literally the best
> example is linux's dcache and inode cache.
>
> it's also fairly simple to maintain such cache at level where single
> object is being modified. for our purposes this matches layer  
> implementing
> OSD API - because all operations in OSD API are per single object.
>
> the same applies to reintegration because:
> * we need to break complex operations to be sent to different  
> servers anyway
> * if we'd need to optimize log (i.e., create/unlink), then it's  
> simpler
>  to collapse log entries when they are basic operations
> * when we'd want to reintegrate from state cache
>
> we also need a layer to take metadata operations and translate them  
> into
> per-object basic operations (updates). responsbility of this layer is:
> * to grab all required ldlm locks
>  as the layer understands operation's nature, locking rules, etc
> * to check current state
>  whether name exists alread (for create), permissions
> * to apply updates to state cache (and reintegration backend, if  
> required)
> * to release ldlm locks
>
> essentially this is what current metadata server does. the  
> difference is
> * locks to be acquired on remote node
> * current state can be on remote node (not in local state cache)
> * updates can be stored in local memory for later reintegration
>  (perhaps this applies to usual mds)
>
> it looks quite obvious that it'd make sense to use metadata server  
> code to
> implement wbc:
> * ldlm hides where lock is being mastered
> * dedicated osd layer below metadata server can maintain state cache  
> needed
>  to check existing names, attributes, permissions, etc
> * dedicated osd layer below metadata server can take care of  
> reintegration
>
>
> implementation would look like set of the following modules:
> * mdf - metadata filter
>  this is location-free metadata server operating on top of osd api,  
> grabs
>  ldlm locks, check current state, apply changes.
> * cosd - caching osd
>  this is dedicated layer with osd api, it maintains state cache and  
> all data
>  needed for reintegration. it also tries to use network efficient:  
> regular
>  lookup can be implemented via underlying readdir, etc.
> * gosd - global osd
>  very specific module allowing node to talk to remote storage over  
> osd api,
>  it's stateless, something similar to current mdc, but using  
> different apis.
>
>
> some obvious cons of this approach:
> * implementation doesn't rely on any system specific thing like  
> dcache/icache
> * we can unify the code and re-use it to implement regular metadata  
> server,
>  wbc and metadata proxy server
> * overall simplicity
>  inter-layer interaction is well defined and simple, same about  
> layer's
>  functionality
> * clustered metadata fits this model very well because metadata server
>  doesn't need to know whether some update local or remote
>
> any comments and suggestions are very welcome!
>
>
> thanks, Alex
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
