From: Aurelien Degremont <aurelien.degremont@cea.fr>
Date: Mon, 12 Jul 2010 12:10:04 +0200
Subject: [Lustre-devel] async write and abort_recov
Message-ID: <4C3AE9FC.5010705@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello

I'm wondering how Lustre client handles recovery when OST restarts with abort_recov flag set.

Let's say a client has page to flush to OST, but OST is stopped, then restarts with -o abort_recov.
There is no recovery, so:
1- client retakes extent locks and then re-try to flush its pages
or
2- client cannot flush anymore and drop the i/o, returns an error to the caller.


If #2, what if the process has already closed the file ?
What is the file is still opened and the process try to do another I/O, will it have an error for the former bad i/o?


abort_recov is used only at first start, or the OST uses this flag until it is stopped for any other recovery-like
mechanisms?


Thanks

-- 
Aurelien Degremont
