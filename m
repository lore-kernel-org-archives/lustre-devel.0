From: Aurelien Degremont <aurelien.degremont@cea.fr>
Date: Mon, 13 Oct 2008 18:39:16 +0200
Subject: [Lustre-devel] "Simple" HSM straw man
In-Reply-To: <48EE87A1.7000003@sun.com>
References: <48EE87A1.7000003@sun.com>
Message-ID: <48F379B4.6040209@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nathaniel Rutman a ?crit :
>     c. restore on file open, not data read/write

take care of the difficulties to move this behavious to a 
restore-on-first-I/O later

>     d. interfaces with hardware-specific copy tool to access HSM files
rather "HSM-specific"

>     e. kernel process encompasses service threads listening for 
> coordinator requests, passes these up to userspace process via upcall.  
> No interaction with the client is needed; this is a simple message 
> passing service.

Depending on how you can manage a user-space process, but, AFAIK, to be 
able to manage the copy tool process, that means:
  - start this process
  - send a signal
  - get its output (for "complex" hsm, we will need feedback from copy 
tool process)
  - wait for the process end
  - ...
All of this is easily doable from userspace, and very hard in 
kernel-space (we cannot use the fire-and-forget call call_usermodehelper).
So I rather imagine:
  - a kernel space mover, simply getting LNET messages and passing them 
to user-space mover
  - a user-space mover, forking, spawning and managing the copy tool 
process.

Maybe it will need to manage several copy tool processes, so it will 
need queues, process list, etc...

So I think this tool needs a bit more than just a "simple message 
passing service".

>     b. lov EA changes
>        i.  flags: file_is_purged "purged", copyout_begin, 
> file_in_HSM_is_out_of_date "hsm_dirty", copyout_complete.  The purged 
> flag is always manipulated under a write layout lock, the other flags 
> are not.
>        ii: "window" EA range of non-purged data (rev2)

If you add a window EA (will be needed anyway for hsm v2), you do not 
need a purged flag:

window.start ==window.end is comparable to a purged flag unset. (or 
window.end == 0)


>     c. new file ioctls: HSMCopyOut, HSMPurge, HSMCopyinDone
> 
> 
> Algorithms
> 1. copyout
>     a. Policy engine decides to copy a file to HSM, executes HSMCopyOut 
> ioctl on file
>     b. ioctl handled by MDT, which passes request to Coordinator
>     c. coordinator dispatches request to mover.  request should include 
> file extents (for future purposes)
>     d. normal extents read lock is taken by mover running on client
>     e. mover sets "copyout_begin" bit and clears "hsm_dirty" bit in EA.
>     f. any writes to the file set the "hsm_dirty" bit (may be 
> lazy/delayed with mtime or filesize change updates on MDT).  Note that 
> file writes need not cancel copyout; for a fs with a single big file, we 
> don't want to keep interrupting copyout or it will never finish. 

Is it interesting to have a file that is outdated and possibly uncoherent?

>     g. when done, mover checks hsm_dirty bit.  If set, clears 
> copyout_begin, indicating current file is not in HSM.  If not set,  
> mover sets "copyout_complete" bit.  File layout write lock is not taken 
> during mover flag manipulation.  (Note: file modifications after copyout 
> is complete will have both copyout_complete and hsm_dirty bits set.)
> 
> 2. purge (aka punch)
>     a. Policy engine decides to purge a file, exectues HSMPurge ioctl on 
> file
>     b. ioctl handled by MDT
>     c. MDT takes a write lock on the file layout lock
>     d. MDT enques write locks on all extents of the file.  After these 
> are granted, then no client has any dirty cache and no child can take 
> new extent locks until layout lock is released.  MDT drops all extent locks.
>     e. MDT verifies that hsm_dirty bit is clear and copyout_complete bit 
> is set
>     f. MDT marks the LOV EA as "purged"
>     g. MDT sends destroys the OST objects, using destroy llog entries to 
> guard against object leakage during OST failover

Are you sure you want to remove those objects if we will need them 
later, in "complex" HSM?
As this mecanism will need to change a lot when we will implement the 
restore-in-place feature, i'm not sure this is the best idea.


>     h. MDT drops layout lock.
> 
> 3. restore (aka copyin aka cache miss)
>     a. Client open intent enques layout read lock. 
>     b. MDT checks "purged" bit; if purged, lock request response 
> includes "wait forever" flag, causing client to block the open.
>     c. MDT creates a new layout with a similar stripe pattern as the 
> original, allocating new objects on new OSTs.  (We should try to respect 
> specific layout settings (pool, stripecount, stripesize), but be 
> flexible if e.g. pool doesn't exist anymore.  Maybe we want to ignore 
> offset and/or specific ost allocations in order to rebalance.)
>     d. MDT sends request to coordinator requesting copyin of the file to 
> .lustre/fid/XXXX with extents 0-EOF. Extents may be used in the future 
> to (a) copy in part of a file, in low-disk-space situations; (b) copy in 
> individual stripes simultaneously on multiple OSTs.
>     e. Coordinator distributes that request to an appropriate mover.
>     f. Writes into .lustre/fid/* are not required to hold layout read 
> lock (or special flag is passed to open, or group write lock on layout 
> is passed to mover)
>     g. Mover copies data from HSM
>     h. When finished, mover calls ioctl HSM_COPYIN_DONE on the file
>     i. MDT clears "purged" bit from LOV EA
>     j. MDT releases the layout lock
>     k. This sends a completion AST to the original client, who now 
> completes his open. 




Concerning the new flag copyout_begin/copyout_complete, I'm not a 
ldlm/recovery specialist but is it possible to have the mover to take a 
kind of write extent lock on the area it has to copied in/out and 
downgrade it on a smaller range as the copy tool goes along.

Copy-out
- Mover take a specific lock on range (0-EOF for the moment)
- On this range, reads pass, writes raise a callback on the mover.
- Receiving this callback, if the mover release its lock, the copyout is 
cancelled, if not, the write i/o is blocked
- When the mover has copied [0 - cursor], it can downgrade its lock to 
[cursor - EOF] and release the lock on [ 0 - cursor].

Same thing could be done for copy in.

The two key points are:
  - Could we have a layout lock on a specific range?
  - Is it possible to downgrade a range lock with ldlm?



-- 
Aurelien Degremont
CEA
