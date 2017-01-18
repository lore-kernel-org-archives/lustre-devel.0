From: Oleg Drokin <oleg.drokin@intel.com>
Date: Wed, 18 Jan 2017 15:39:36 -0500
Subject: [lustre-devel] Proposal for JobID caching
In-Reply-To: <D4A5356C.C519%jevans@cray.com>
References: <D4A5356C.C519%jevans@cray.com>
Message-ID: <6E2CFE03-A158-4D82-82BA-AF0A175AA358@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Jan 18, 2017, at 3:08 PM, Ben Evans wrote:

> Overview
>             The Lustre filesystem added the ability to track I/O performance of a job across a cluster.  The initial algorithm was relatively simplistic:  for every I/O, look up the job ID of the process and include it in the RPC being sent to the server.  This imposed a non-trivial performance impact on client I/O performance.
>             An additional algorithm was introduced to handle the single job per node case, where instead of looking up the job ID of the process, Lustre simply accesses the value of a variable set through the proc interface.  This improved performance greatly, but only functions when a single job is being run.
>             A new approach is needed for multiple job per node systems.
>  
> Proposed Solution
>             The proposed solution to this is to create a small PID->JobID table in kernel memory.  When a process performs an IO, a lookup is done in the table for the PID, if a JobID exists for that PID, it is used, otherwise it is retrieved via the same methods as the original Jobstats algorithm.  Once located the JobID is stored in a PID/JobID table in memory. The existing cfs_hash_table structure and functions will be used to implement the table.
>  
> Rationale
>             This reduces the number of calls into userspace, minimizing the time taken on each I/O.  It also easily supports multiple job per node scenarios, and like other proposed solutions has no issue with multiple jobs performing I/O on the same file at the same time.
>  
> Requirements
> ?      Performance cannot significantly detract from baseline performance without jobstats
> ?      Supports multiple jobs per node
> ?      Coordination with the scheduler is not required, but interfaces may be provided
> ?      Supports multiple PIDs per job
>              
> New Data Structures
>             pid_to_jobid {
>                         struct hlist_node pj_hash;
>                         u54 pj_pid;
>                         char pj_jobid[LUSTRE_JOBID_SIZE];
> spinlock_t jp_lock;
>                         time_t jp_time;
> }
> Proc Variables
> Writing to /proc/fs/lustre/jobid_name while not in ?nodelocal? mode will cause all entries in the cache for that jobID to be removed from the cache
>  
> Populating the Cache
>             When lustre_get_jobid is called, the process, and in the cached mode, first a check will be done in the cache for a valid PID to JobID mapping.  If none exists, it uses the same mechanisms to get the JobID and populates the appropriate PID to JobID map.
> If a lookup is performed and the PID to JobID mapping exists, but is more than 30 seconds old, the JobID is refreshed.
> Purging the Cache
>             The cache can be purged of a specific job by writing the JobID to the jobid_name proc file.  Any items in the cache that are more than 300 seconds out of date will also be purged at this time.


I'd much rather prefer you go to the table that's populated outside of the kernel
somehow.
Let's be realistic, poking around in userspace process environments for random
strings is not such a great idea at all even though it did look like a good idea
in the past for simplicity reasons.
Similar to nodelocal, we probably just switch to a method where you call a
particular lctl command that would mark the whole session as belonging
to some job. This might take several forms, e.g. nodelocal itself could
be extended to only apply to a current namespace/container
But if you do really run different jobs in the global namespace, we probably can
probably just make the lctl to spawn a shell with commands that all would
be marked as a particular job? Or we can probably trace the parent of lctl and
mark that so that all its children become somehow marked too.

Bye,
    Oleg
