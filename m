From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Mon, 12 Jul 2010 14:16:32 -0600
Subject: [Lustre-devel] async write and abort_recov
In-Reply-To: <4C3AE9FC.5010705@cea.fr>
References: <4C3AE9FC.5010705@cea.fr>
Message-ID: <4EC6AD38-0BE5-4DDC-B98A-C1C835292305@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-07-12, at 04:10, Aurelien Degremont wrote:
> I'm wondering how Lustre client handles recovery when OST restarts with abort_recov flag set.
> 
> Let's say a client has page to flush to OST, but OST is stopped, then restarts with -o abort_recov.  There is no recovery, so:
> 1- client retakes extent locks and then re-try to flush its pages
> or
> 2- client cannot flush anymore and drop the i/o, returns an error to the caller.

When the client is evicted, it drops all of its locks for that OST, and any unwritten pages for those files is discarded.  While I know Lustre will save errors from async write RPCs into the file descriptor (for later write calls or fsync), I don't know if we save any IO error into the file descriptor if we discard pages due to eviction.  I think only errors due to currently in-flight RPCs that are aborted due to client eviction are returned.

This is the same for "-o abort_recov" or if the client is evicted for other reasons (failed lock callbacks, or failed recovery even if abort_recovery is not used).

> If #2, what if the process has already closed the file ?
> What is the file is still opened and the process try to do another I/O, will it have an error for the former bad i/o?

If the file is not closed yet, then fsync or a later write will return an earlier error.  If the file descriptor is closed then there is no way to return that error.  That is true for local filesystems as well.

> abort_recov is used only at first start, or the OST uses this flag until it is stopped for any other recovery-like mechanisms?

The "abort_recov" mount option is equivalent to:

	lctl --device {ost dev} abort_recovery

it is only affecting the initial startup recovery, and is ignored afterward.

Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.
