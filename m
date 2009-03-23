From: Robert Read <rread@sun.com>
Date: Mon, 23 Mar 2009 16:17:33 -0700
Subject: [Lustre-devel] WBC HLD outline
In-Reply-To: <200903240058.30343.alexander.zarochentsev@sun.com>
References: <200903240058.30343.alexander.zarochentsev@sun.com>
Message-ID: <0B02BFB6-2461-48E7-A572-946898BAC9B0@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Zam,


On Mar 23, 2009, at 14:58 , Alexander Zarochentsev wrote:

> Hello,
>
> here is a wbc hld outline.
> Please take a look.
>
> ===============================================
> WBC HLD OUTLINE
>
> * Definitions

> WBC (MD WBC): (Meta Data) Write Back Cache.
>
> MD operation: whole MD operation over an object:
> rename/create/open/close/setattr/getattr/link/unlink/mkdir/rmdir +
> readdir.
>
> Reintegration: The process of applying accumulated MD operation to the
> MD servers.
>
> MDS/RAW: MDS API extension to do "raw" fs operations: inserting of a
> dir entry w/o creating inode and so.
>
> MD update: a part of MD operation to be executed on one server,
> contains one or more MDS/RAW operations.

Why does the client need to to be more granular than an update?  It  
seems MDS/Raw and update should be the same.

>
> MD batch: a collection of per-server MD updates.
>
> MDTR: MD translator: translates MD operations into MD/Raw ones.

Isn't this essentially what the cmm is doing today? (Breaking down  
distributed operations into per-node updates?)  Are you expanding on  
Alex's idea of creating a new generic MD server stack?

>
> * Requirements
>
> Client application is able to create 64k files/second.
>
> Reintergration moves fs from one consistent state to another

> consistent state.
>
> Non-WBC client support w/o visible overhead.
>
> Avoid MDS code rewrite if possible.
>
> * Design outline
>
> ** Overall picture
>
> [Application]
>    |
> =syscalls=
>    |
>    V
>  [VFS]
>    |
> =vfs hooks=
>    |
>    V
> [LLITE/MDC]
>    |
> =MD (non-WBC) proto=
>    |
>    V
> [MD CACHE MANAGER] ---> [LDLM]
>    |
>    V
> [MDTR]
>   +-----------+----------+
>   |           |          |
>  =======WBC proto==========
>   |           |          |
>   V           V          V
> [MDS1/RAW] [MDS2/RAW] [MDS3/RAW]
>
> ** WBC
>
> WBC client has a MDTR running on client side,
> it also can be a proxy server, acting as a server for
> non-WBC clients and as a client for MD servers.
>
> *** WBC vs non-WBC
>
> Processing MD operation request (lock enqueue + op intent, by Alex
> suggestion), MD server may decide to execute it by itself, or grant a
> only a lock (subtree one) and allow client to continue in WBC mode.
>
> *** Locks
>
> needed LDLM locks are taken before operation starts and held until the
> corresponded batch is re-integrated.
>
> *** Local cache management
>
> WBC client executes operations locally, modifying local in-memory
> objects. WBC client has a (redo-)log of all operations.
>
> The cache manager controls process of MD cache re-integration.
>
> *** MDS/RAW operations
>
> Managing directory entries and inodes, without maintaining
> fs consistency automatically.
>
> create/update/delete methods for directory entries and inodes.
>
> *** MDTR
>
> MDTR is responsible for converting MD operations into set of
> per-server MD/RAW operations.
>
> *** Client re-integration
>
> Periodically, or because of (sub-)lock releasing, dirty memory
> flushing or so, WBC client submits batches to all MD servers involved
> into the operations.
>
> Process of re-integration is protected by LDLM locks. MD servers are
> updated
> using WBC protocol.
>
> *** WBC protocol
>
> WBC request contains a set of MD/RAW operations, tagged with one epoch
> number.  Bulk transfers are used.

All the updates in a single operation must have the same epoch, but I  
don't think we can guarantee that all the operations in a batch will  
be in the same epoch, unless we stop exchanging messages with all the  
MD servers. I don't see a need for them to be in the same epoch, either.

>
> *** File data
> Flushing file data to the OST servers is delayed until file creation
> is re-integrated.
>
> *** Recovery
>
> The redo-log preserved until it is not needed in recovery (i.e. epoch
> gets stable)
>
> Client replay the log and re-execute all operations from it, repeating
> MDTR processing (dispatching the operation between MD servers).

Since the MD servers all roll back before recovery, recovery will be  
very similar to the original reintegration, with the exception of  
using versions.  So we should try to keep the recovery (replay) code  
as similar to the normal code as possible, and move recovery higher  
into the stack.

>
> **** WBC client eviction, uncompleted updates
>
> If client dies until re-integration is completed, there are three
> choices:
>
> a) Cluster-wide rollback, all servers roll back to the last globally
> stable epoch, then clients to replay heir redo-logs.
>
> This scenario should be avoided because a single client failure may
> may stop whole cluster for recovery.
>
> b) All servers participating in re-integration coordinate to undo
> uncompleted updates.
>
> c) The servers have all information needed to complete re-integration
> w/o client.

You mean by keeping the original operation info in the undo logs?

>
> The recovery strategy is a subject of CMD Recovery Design document,
> but a possibility of (c) need a support in the WBC protocol.
>
> ** non-WBC
>
> *** MD protocol
>
> MD (non-WBC) protocol remains the same as now.
>
> ** Use cases
>
> *** WBC / non-WBC decision
>
> 1. Check whether server and client can operate in WBC-mode through
> connect flags.
>
> 2. I they can, a lock enqueue request may contain a request for
> WBC-mode, the server may respond with granting WBC-mode and STL or PW
> lock on the directory. MD server accepts or rejects WBC-mode request
> depending on server rules and per-object access statistics.
>
> *** File creation
>
> client gets a PW lock on directory.
>
> client fetches directory content.
>
> client does file creation locally, in cache, the operation record is
> added to the client redo-log.
>
> Another client want to read the directory, lock conflict triggers
> re-integration.
>
> MD Cache manager processes the redo-log, prepares batches with MDS/RAW
> operations and submits them to the MD servers.
>
> The MD servers integrate the batches.
>
> MD Cache manager frees local cache content and cancels the directory
> lock.
>
> ** Questions
>
> Q: Can several wbc clients work in one directory simultaneously?
> A: If extent locks for directories are implemented, each WBC client
>   can take a lock on a hash interval.
>
> Q: can  wbc clients do massive file creation in one directory
>   efficiently?
> A: the idea that may help: if we can guess that the file names created
>   by a client are lexicographically ordered, a special hash function
>   may reduce lock conflicts between clients holding locks on
>   directory extents.


cheers,
robert
