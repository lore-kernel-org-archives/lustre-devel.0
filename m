From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Thu, 09 Oct 2008 15:37:21 -0700
Subject: [Lustre-devel] "Simple" HSM straw man
Message-ID: <48EE87A1.7000003@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This is intended to be a starting point for discussion; the concepts 
here have been hashed through a few times and hopefully represent the 
best current thinking.


Baseline concepts
1. all single-file coherency issues are in kernel space (file locking, 
recovery)
2. all policy decisions are in user space (using changelogs, df, etc)
3. coordinator/mover communication will use LNET
4. "simple" refers to
    a. integration with HPSS only
    b. depends on changelog for policy decisions
    c. restore on file open, not data read/write
5. HSM tracks entire files, not stripe objects
6. HSM namespace is flat, all files are addressed by FID only
7. Desired: coordinator and movers can be reused by (non-HSM) replication


Components
1. Mover
    a. combined kernel (LNET comms) and userspace processes
    b. userspace processes will use Lustre clients for data i/o
    c. will use special fid directory for file access (.lustre/fid/XXXX)
    d. interfaces with hardware-specific copy tool to access HSM files
    e. kernel process encompasses service threads listening for 
coordinator requests, passes these up to userspace process via upcall.  
No interaction with the client is needed; this is a simple message 
passing service.
2. Coordinator
    a. decides and dispatches copyin and copyout requests to movers
    b. consolidates repeat requests
    c. re-queues requests to a new agent if an agent becomes unresponsive
    d. kernel space, associated with the MDT for cache-miss
    e. ioctl interface for copyout, purge requests from policy engine
3. Policy engine (aka Space Manager)
    a. makes policy decisions for copyout, purge
    b. normally uses changelogs and 'df' for input; rarely is allowed to 
scan filesystem
    c. userspace process, requests copyout and purge via ioctl to 
coordinator
4. MDT changes
    a. Per-file layout lock

    A new layout lock is created for every file.  Private writer lock is
    taken by the MDT when allocating/changing file layout (LOV EA). 
    Shared reader locks are taken by anyone reading the layout (client
    opens, lfs getstripe).  Anyone taking a new extent lock anywhere in
    the file must first hold the layout lock.
    Problem: Layout lock can't be held by liblustre during i/o? 

    b. lov EA changes
       i.  flags: file_is_purged "purged", copyout_begin, 
file_in_HSM_is_out_of_date "hsm_dirty", copyout_complete.  The purged 
flag is always manipulated under a write layout lock, the other flags 
are not.
       ii: "window" EA range of non-purged data (rev2)
    c. new file ioctls: HSMCopyOut, HSMPurge, HSMCopyinDone


Algorithms
1. copyout
    a. Policy engine decides to copy a file to HSM, executes HSMCopyOut 
ioctl on file
    b. ioctl handled by MDT, which passes request to Coordinator
    c. coordinator dispatches request to mover.  request should include 
file extents (for future purposes)
    d. normal extents read lock is taken by mover running on client
    e. mover sets "copyout_begin" bit and clears "hsm_dirty" bit in EA.
    f. any writes to the file set the "hsm_dirty" bit (may be 
lazy/delayed with mtime or filesize change updates on MDT).  Note that 
file writes need not cancel copyout; for a fs with a single big file, we 
don't want to keep interrupting copyout or it will never finish. 
    g. when done, mover checks hsm_dirty bit.  If set, clears 
copyout_begin, indicating current file is not in HSM.  If not set,  
mover sets "copyout_complete" bit.  File layout write lock is not taken 
during mover flag manipulation.  (Note: file modifications after copyout 
is complete will have both copyout_complete and hsm_dirty bits set.)

2. purge (aka punch)
    a. Policy engine decides to purge a file, exectues HSMPurge ioctl on 
file
    b. ioctl handled by MDT
    c. MDT takes a write lock on the file layout lock
    d. MDT enques write locks on all extents of the file.  After these 
are granted, then no client has any dirty cache and no child can take 
new extent locks until layout lock is released.  MDT drops all extent locks.
    e. MDT verifies that hsm_dirty bit is clear and copyout_complete bit 
is set
    f. MDT marks the LOV EA as "purged"
    g. MDT sends destroys the OST objects, using destroy llog entries to 
guard against object leakage during OST failover
    h. MDT drops layout lock.

3. restore (aka copyin aka cache miss)
    a. Client open intent enques layout read lock. 
    b. MDT checks "purged" bit; if purged, lock request response 
includes "wait forever" flag, causing client to block the open.
    c. MDT creates a new layout with a similar stripe pattern as the 
original, allocating new objects on new OSTs.  (We should try to respect 
specific layout settings (pool, stripecount, stripesize), but be 
flexible if e.g. pool doesn't exist anymore.  Maybe we want to ignore 
offset and/or specific ost allocations in order to rebalance.)
    d. MDT sends request to coordinator requesting copyin of the file to 
.lustre/fid/XXXX with extents 0-EOF. Extents may be used in the future 
to (a) copy in part of a file, in low-disk-space situations; (b) copy in 
individual stripes simultaneously on multiple OSTs.
    e. Coordinator distributes that request to an appropriate mover.
    f. Writes into .lustre/fid/* are not required to hold layout read 
lock (or special flag is passed to open, or group write lock on layout 
is passed to mover)
    g. Mover copies data from HSM
    h. When finished, mover calls ioctl HSM_COPYIN_DONE on the file
    i. MDT clears "purged" bit from LOV EA
    j. MDT releases the layout lock
    k. This sends a completion AST to the original client, who now 
completes his open. 


State machines
TBD - I think there's enough in here to chew on for awhile

Things requiring a more detailed look
1. configuration of HSM/movers
2. policy engine
3. "complex" HSM roadmap
    a. partial access to files during restore
    b. partial purging for file type identification, image thumbnails, ??
    c. integration with other HSM backends (ADM, ??)
4. layout locks and liblustre
