From: =?utf-8?Q?J=C3=BCrgen_Kaiser?= <kaiserj@uni-mainz.de>
Date: Mon, 23 Jan 2017 10:28:27 +0100
Subject: [lustre-devel] Quality of Service Planning in Lustre
In-Reply-To: <1B2C98C4BC048747A2EA06A5FF0D0C76B585D13F@LAX-EX-MB3.datadirect.datadirectnet.com>
References: <A52473FD-8F0A-4684-BEA7-69C26C9F9519@uni-mainz.de>
	<6A9C4AF6-5F51-4DFB-9CC0-0FFC4CEFC49B@intel.com>
	<1B2C98C4BC048747A2EA06A5FF0D0C76B585D13F@LAX-EX-MB3.datadirect.datadirectnet.com>
Message-ID: <234EF2EA-8559-40CA-8085-CD274EC45422@uni-mainz.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

> Am 19.01.2017 um 04:44 schrieb Li Xi <lixi@ddn.com>:
> 
> Hi,
> 
> Glad to hear from you, Andreas.
> 
>> I think there is an open question about what sort of granularity of I/O bandwidth an application needs in order to do its job.  I think the main goal of the user is to avoid having their job contend with another large job that is consuming all of the bandwidth for a long period of time, but they don't necessarily need real-time I/O guarantees.  At the same time, from process scheduling on CPUs we know the most globally efficient scheduling algorithm is "shortest job first", so that small jobs can complete their I/O quickly and return to computation, while the large job is going to take a long time in either case.
> 
> I agree that real-time bandwidth guarantees might not be necessary in some (maybe most) circumstances. But these circumstances have some preconditions or assumptions. And I think the possible assumptions are: 1) Jobs have the same priority and can be scheduled as needed ; 2)  The jobs are queued and waiting the scheduling of QoSP & Slurm; 3) The ultimate goal is to get highest throughput of jobs, i.e. to maximize the sum of the weights of the finished jobs.
> 
> However, these assumptions might not always be ture, for example.
> 
> 1) Jobs have the same priority can be scheduled as needed  -> A job has extermely high priority because the user need to finish it before a deadline otherwise he/she will be fired.
> 
> 2) The jobs are queued and waiting the scheduling of QoSP & Slurm -> A user happens to lose his/her sleep in the midnight and starts a huge job.
> 
> 3) The ultimate goal is to get highest throughput of jobs -> A user complains a lot because he submits a huge job but need to wait after a massive of small jobs.
> 
> Under these circumstance, a real-time performance guarantees is more friendly to the users, since the behaviors and results are more predictable. And another advantage is that the administrator could charge the users according to the QoS guarantees. That means, if a user is not satisfied with the current guarantees, he/she can pay more for better guarantees.
> 

Agreed. However, we see bandwidth guarantees as a long-term (research) goal. As an intermediate step, the QoSP should help to prevent situations as Andreas described it: no two high bandwidth applications at the same time.

>> It may be that instead of working on hard bandwidth guarantees (i.e job A needs 100MB/s, while job B needs 500MB/s), which is hard for users to determine (they want to get the maximum bandwidth all of the time?) it might be better to have jobs provide information about how large their I/O is going to be, and how often.  That is something that users can determine quite easily from one run to the next, and would allow a global scheduler to know that job A wants to read 10 GB of files every 10 minutes, while job B wants to write 10TB of data every 60 minutes, and when job A starts its read it should preempt job B (if currently doing I/O) so it can complete all of its reads quickly and go back to work, and job B will still be writing that 10TB long after job A has finished.
> 
> Ideally, users know clearly about how are the I/O patterns of the jobs, and also how much performance the jobs will need. Unfortunately, it seems difficult to understand/abstract/describe/predict the I/O patterns of the jobs, especially the jobs are parrallel applications. I think that the I/O pattern information provided by users might be helpful for rough estimation, but might not be accurate enough to make real-time QoS decisions. So, QoSP might need to monitor the I/O patterns in real time and make QoS decisions dynamically.
> 
> Also, this gives us another reason why real-time bandwidth guarantees is helpful. Because if users are charged accorrding to the performance guarantees, users will have much more motivation to understand and optimize the I/O patterns. And hopefully, the bad I/O patterns (for example, unccessary 2GB/s write which last for one hour) will be eliminated eventually, which is good for everyone.
> 

Besides charging for reserved resources, another incentive is the waiting time until the job scheduler allows the job to start. If a user wants 100% he/she must wait until every other job is finished. We already see this effect in case of CPUs. Since we allow multi-days jobs users typically must wait several days (sometimes even weeks) if they want that much resources.

I agree that an I/O pattern would be better for us. However, I think that it is easier for users to work with bandwidth values instead of access patterns. Most of our users come from non computer science fields such as biology, physics, meteorology, etc. and typically lack knowledge about the access patterns. In the best case, they know the size of the input files and (from experience) the expected size of the output files. They also might know that the input is read only once and, therefore, (roughly) know the total volume of read/written data. With this information, they can estimate the reservation length of the required resources.

However, in case of checkpointing the users should be able to tell Slurm/QoSP enough details.

>> If the application provides the output directory for the new files, the number of files, and the size, the QoSP can have a very good idea of which OSTs will be used.  In most cases, the number of files exceeds the OST count, or a single file will be striped across all OSTs so the I/O will be evenly balanced across OSTs and it doesn't matter what the exact file placement will be.  If something like an OST pool is set on the directory, this can also be determined by "lfs getstripe" or llapi_layout_get_by_path() or similar.
> 
> Yeah, it seems QoSP needs to a lot of things, including controlling the stripe of the files.
> 
>> I think fine-grained scheduling of the I/O performance of every file in the filesystem is not necessary to achieve improvements in aggregate I/O performance across jobs.  High-level prioritization of jobs is probably enough to gain the majority of performance improvements possible.  For example, if the QoSP knows two jobs have similar I/O times during their busy period, and are contending for writes on OSTs then the first job to submit RPCs can have a short-term but significant boost in I/O priority so it can complete all of its I/O before the second job does.  Even if the jobs do I/O at the same frequency (e.g. every 60 minutes) this would naturally offset the two jobs in time to avoid contention in the future.
> 
> Agreed. Job might be a better granularity/graininess of I/O performance scheduling than file, since users care more about the time costs of jobs than writing/reading a file.

Agreed. We see the fine-grained view as part of a long term research topic.

> 
>> If the QoSP doesn't get any information about a job, it could potentially generate this dynamically from the job's previous I/O submissions (e.g. steady-state reader/writer of N MB/s, bursty every X seconds for Y GB, etc) to use it for later submissions and/or dump this in the job epilog so the user knows what information to submit for later test runs.
> 
> Agreed. This needs a monitor & analyzer to extract the I/O pattern. Various types of monitoring systems have been developed for Lustre by different vendors, however we might need to put further work to them for I/O pattern abstract. A powerful quantitative method to discribe the I/O pattern needs to be designed. This method should be both understandable by human and computer.  For example, something like following discription could be generated automatically after running a job:
> 
> rank: 0, start second: 0, end second: 60, I/O type: exclusive read, total size 10GB, rank size: 10GB, file number: 1, exclusive, grain size: 1MB, comment: "Reading the input";
> rank: 1~100, start second: 0, end second: 60, I/O type: None, comment: "Waiting rank0";
> rank: 0~100, start second: 61, end second: 600, I/O type: None, comment: "Computing";
> rank: 0~100, start second: 601, end second: 660, I/O type: exclusive write, total size 1000GB, rank size: 10GB, file number: 100, grain size: 1MB, comment: "Writing the output";
> 
>> I suspect that even if the user is specifying the job I/O pattern explicitly, this should only be taken as "initial values" and the QoSP should determine what actual I/O pattern the job has (and report large discrepancies in the epilog).  The I/O pattern may change significantly based on input parameters, changes to the system, etc. that make the user-provided data inaccurate.
> 
> Yep, totoally agreed.

Agreed

> 
> Cheers, Andreas
> 

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 1536 bytes
Desc: Message signed with OpenPGP using GPGMail
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20170123/00facc62/attachment.pgp>
