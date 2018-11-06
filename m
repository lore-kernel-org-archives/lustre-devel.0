From: Patrick Farrell <paf@cray.com>
Date: Tue, 6 Nov 2018 17:19:55 +0000
Subject: [lustre-devel] Apparent bug in LU-8130 ptlrpc: convert conn_hash to
 rhashtable / Linux-commit: ac2370ac2bc5215daf78546cd8d925510065bb7f
Message-ID: <86CBD270-5FA9-482D-8AA4-C6309096BD81@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Neil, James,

It looks like the patch we landed as:

LU-8130 ptlrpc: convert conn_hash to rhashtable

Linux has a resizeable hashtable implementation in lib,
so we should use that instead of having one in libcfs.

This patch converts the ptlrpc conn_hash to use rhashtable.
In the process we gain lockless lookup.

As connections are never deleted until the hash table is destroyed,
there is no need to count the reference in the hash table. There
is also no need to enable automatic_shrinking.

Linux-commit: ac2370ac2bc5215daf78546cd8d925510065bb7f

Introduced a bug.  Ihara-san opened something to track it here:
https://jira.whamcloud.com/browse/LU-11624

It?s a null pointer in nid_hash(); there are some more details at that link.

We?re seeing it at Cray as well, when testing the current WhamCloud branch.

Basically, when we fail over an MDS(/MDT) under load (ie with real activity on the file system) we hit this panic about 30-50% of the time right now.  I assume it?s possible on OSSes as well but we haven?t seen it there.

I haven?t done any detailed investigation, but I thought I?d bring it to your attention.  Per Ihara-san in LU-11624, the crash does not happen without the commit listed above.


  *   Patrick
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181106/103b69a0/attachment.html>
