From: Aurelien Degremont <aurelien.degremont@cea.fr>
Date: Thu, 15 Jul 2010 10:05:07 +0200
Subject: [Lustre-devel] async write and abort_recov
In-Reply-To: <4EC6AD38-0BE5-4DDC-B98A-C1C835292305@oracle.com>
References: <4C3AE9FC.5010705@cea.fr>
	<4EC6AD38-0BE5-4DDC-B98A-C1C835292305@oracle.com>
Message-ID: <4C3EC133.2030800@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger a ?crit :
> While I know Lustre will save errors from async write RPCs into the file descriptor 
 > for later write calls or fsync), I don't know if we save any IO error into the file
 > descriptor if we discard pages due to eviction.  I think only errors due to currently
 > in-flight RPCs that are aborted due to client eviction are returned.

Sounds like a bug to me?
That means, if a process write data on a client, those data goes to page cache.
Not yet to OST if there is no local memory pressure. At that moment, if the client is evicted, those pages are dropped.
Then client reconnect, the process writes other data. Those I/O are successful, client has missed that some previous I/O 
failed?

Am I correct?

-- 
Aurelien Degremont
CEA
