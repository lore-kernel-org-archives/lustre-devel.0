From: Peter J Braam <Peter.Braam@Sun.COM>
Date: Wed, 23 Jan 2008 09:00:36 +0800
Subject: [Lustre-devel] [Fwd: Re: WBC subcomponents.]
Message-ID: <479691B4.6020004@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Hi Nikita -

This looks excellent, except that I don't feel we have a good basis for 
the estimates yet. 

This has major architectural value as it gives a component breakdown and 
should be recorded as such on the architecture wiki.  When you do these 
component breakdowns it is important to identify what interfaces are 
offered and used by the components (this is the static aspect of the 
interface).  It is also useful to make interaction diagrams showing how 
the components use each other to execute use cases (this is the dynamic 
aspect).

- Peter -

Nikita Danilov wrote:
> Hello,
>
> below is a tentative list of tasks into which WBC effort can be
> sub-divided. I also provided a less exact list for the EPOCH component,
> and an incomplete list for the STL component.
>
> WBC tasks are estimated in lines-of-code with the total of (9100 + 3000)
> LOC, where LOC is a non-comment, non-whitespace line of the source
> file. I believe it is too early to estimate all EPOCH tasks, hopefully
> there will be more clear understanding of the situation during next
> week. I tried to estimate the EPOCH tasks that are absolutely necessary
> during the early stages of WBC development.
>
> Vladimir is the best person to complete the list of STL tasks,
> together with the estimations.
>
> C-* tasks are for the client, S-* tasks are for the server.
>
> ESTIMATION
>
>                      scope                                                effort
>                                                                              loc
> WBC
>
>     C-VFS-MM         integration with vfs: inodes, dentries, memory         2500
>                      pressure. Executing operation effects locally.
>
>     C-ops-caching    tracking operations: list vs. fragments. Tracking      2500
>                      dependencies.
>
>     C-write-out      policy deciding when to write-out cached state         1000
>                      updates, and with what granularity: age, amount,
>                      max-in-flight
>
>     C-dir-pages      caching of directory pages and using them for local    1000
>                      lookups
>
>     C-new-files      creation of new files locally                           200
>
>     C-new-objects    creation of new objects locally                         200
>
>     C-DLM            invoking reintegration on a lock cancel, lock           200
>                      weighting
>
>     C-data           dependencies between cached data and meta-data          200
>
>     C-IO             switching between whole-file mds-based locking and      250
>                      extent locking
>
>     C-grants         unified resource range leasing mechanism                250
>
>     S-grants         unified resource range leasing mechanism                250
>
>     C-misc           sync, fsync, compatibility flag, mount option           200
>
>     S-misc           compatibility flags                                     100
>
> STL
>
>     C-policy         track usage statistics and use them to decide when to
>                      ask for an STL
>
>     S-policy         track usage statistics and use them to decide when to
>                      grant an STL
>
> EPOCHS
>
>     formalization    formal reintegration model with "proofs" of recovery
>                      correctness and concurrency control description
>
>     C-reintegration  reintegration, including concurrency control,          1000
>                      integration with ptlrpc
>
>     S-compound       implementation of the compound operations on           1000
>                      the server
>
>     S-reintegration  reintegration of batches on the server, thread         1000
>                      scheduling
>
>     S-undo           keeping undo logs
>
>     S-cuts           implementation of the CUTs algorithm
>
>     C-gc             garbage collection: when to discard cached batches
>
>     S-gc             garbage collection: when to discard undo logs
>
>     C-recovery       replay, including optional optimistic "pre-replay"
>
>     S-recovery-0     roll-back of the uncommitted epochs
>
>     S-recovery-1     roll-forward from the clients
>
> EXTERNAL DEPENDENCIES
>
>     ost-fid          ost understanding fids, and granting fid sequences
>                      to the clients
> Nikita.
>   
</div>
