From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Thu, 19 Jan 2017 00:32:23 +0000
Subject: [lustre-devel] Quality of Service Planning in Lustre
In-Reply-To: <A52473FD-8F0A-4684-BEA7-69C26C9F9519@uni-mainz.de>
References: <A52473FD-8F0A-4684-BEA7-69C26C9F9519@uni-mainz.de>
Message-ID: <6A9C4AF6-5F51-4DFB-9CC0-0FFC4CEFC49B@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 16, 2017, at 08:28, J?rgen Kaiser <kaiserj@uni-mainz.de> wrote:
> 
> Hello everyone,
> 
> my name is J?rgen Kaiser and I'm a research assistant at the Johannes Gutenberg University Mainz. As part of an IPCC project, we developed a tool for handling Quality of Service requirements in Lustre. We would like to explain what we did and hear your thoughts about it. We hope that our work will help the Lustre community in the future.
> 
> ==== What we did ===
> 
> HPC centers typically use scheduling systems such as LSF or Slurm to manage the computations of the users and the resources themselves. These schedulers force the users to define compute jobs and to submit these jobs to the schedulers. In return, the schedulers guarantee the users that their job will have the required compute resources. So far, storage bandwidth is (mostly) excluded from the list of managed resources. Unlike resources like CPU or memory, there is no easy method for schedulers to handle storage bandwidth because they lack knowledge about storage system internals. For example, a scheduler must know the placement of a file?s data on Lustre's OSTs plus the workload as well as the maximum performance of the involved parts to reason about the available read throughput for the file.
> 
> It would be more practical if the storage system would provide a generic API for schedulers to set Quality of Service (QoS) configurations while abstracting the internal dependencies. With such an interface, a scheduler easily could request available storage resources. In our project, we're developing a Quality of Service Planner (QoSP) that provides this interface. Its task is to receive storage bandwidth requests (e.g. 100MB/s read throughput for files X,Y,Z for one hour), check for resource availability and, if available, guarantee the reserved resources by configuring Lustre. The main tool here is a (modified) TBF strategy in Lustre's NRS.

I think there is an open question about what sort of granularity of I/O bandwidth an application needs in order to do its job.  I think the main goal of the user is to avoid having their job contend with another large job that is consuming all of the bandwidth for a long period of time, but they don't necessarily need real-time I/O guarantees.  At the same time, from process scheduling on CPUs we know the most globally efficient scheduling algorithm is "shortest job first", so that small jobs can complete their I/O quickly and return to computation, while the large job is going to take a long time in either case.

It may be that instead of working on hard bandwidth guarantees (i.e job A needs 100MB/s, while job B needs 500MB/s), which is hard for users to determine (they want to get the maximum bandwidth all of the time?) it might be better to have jobs provide information about how large their I/O is going to be, and how often.  That is something that users can determine quite easily from one run to the next, and would allow a global scheduler to know that job A wants to read 10 GB of files every 10 minutes, while job B wants to write 10TB of data every 60 minutes, and when job A starts its read it should preempt job B (if currently doing I/O) so it can complete all of its reads quickly and go back to work, and job B will still be writing that 10TB long after job A has finished.

> The QoSP still is under development. You can see the code on github: https://github.com/jkaiser/qos-planner . We see further use cases beyond the HPC scheduling scenario. For example, applications could negotiate I/O Phases with the storage backend (e.g. HPC checkpoints). We would like to hear your thoughts about this project in general and about several problems we face in detail. You can find a pdf a with detailed description and discussion about some core problems we face here: https://seafile.rlp.net/f/55e4c7b619/?raw=1. Two example issues are:
> 
> === The NRS and the TBF ===
> 
> Users require _guaranteed_ storage bandwidth to reason about the run time of their applications so that they can reserve enough time on the computation cluster. In other words: users require minimum bandwidths instead of maximum ones. The current TBF strategy, however, only supports upper thresholds. There are two options here:
> 1) Implement minimums indirectly. This involves a monitoring of the actual resource consumption on the OSTs and a repeatedly readjusting of TBF rules.
> 2) Modify the TBF so that it supports lower thresholds. Here, the NRS would try to satisfy the minimums first. This additionally has the advantage that there is no underutilized bandwidth: each job can use free resources if necessary because there is no upper limit.
> 
> We would like to implement Option 2. We are in contact with DDN and discuss this work including the TBF strategy.

Good to hear that you are in contact with DDN on this, since they are the TBF developers and are already working to improve that code, and can help as needed for global NRS scheduling.

> === Handling Write Throughput ===
> 
> When an application requests write throughput, this usually means that it will create new files. However, at request time, these files do not exist yet, therefore the QoSP cannot know which OSTs will have to process the write throughput. Hence, the QoSP somehow must predict/determine the placement of new files on the OSTs within the Lustre system. This requires several modifications in Lustre including a new interface to query such information. We would like to discuss this issue with the Lustre community. The mentioned PDF file contains further details. We would be happy to hear your thoughts on this.

If the application provides the output directory for the new files, the number of files, and the size, the QoSP can have a very good idea of which OSTs will be used.  In most cases, the number of files exceeds the OST count, or a single file will be striped across all OSTs so the I/O will be evenly balanced across OSTs and it doesn't matter what the exact file placement will be.  If something like an OST pool is set on the directory, this can also be determined by "lfs getstripe" or llapi_layout_get_by_path() or similar.

I think fine-grained scheduling of the I/O performance of every file in the filesystem is not necessary to achieve improvements in aggregate I/O performance across jobs.  High-level prioritization of jobs is probably enough to gain the majority of performance improvements possible.  For example, if the QoSP knows two jobs have similar I/O times during their busy period, and are contending for writes on OSTs then the first job to submit RPCs can have a short-term but significant boost in I/O priority so it can complete all of its I/O before the second job does.  Even if the jobs do I/O at the same frequency (e.g. every 60 minutes) this would naturally offset the two jobs in time to avoid contention in the future.

If the QoSP doesn't get any information about a job, it could potentially generate this dynamically from the job's previous I/O submissions (e.g. steady-state reader/writer of N MB/s, bursty every X seconds for Y GB, etc) to use it for later submissions and/or dump this in the job epilog so the user knows what information to submit for later test runs.

I suspect that even if the user is specifying the job I/O pattern explicitly, this should only be taken as "initial values" and the QoSP should determine what actual I/O pattern the job has (and report large discrepancies in the epilog).  The I/O pattern may change significantly based on input parameters, changes to the system, etc. that make the user-provided data inaccurate.

Cheers, Andreas
