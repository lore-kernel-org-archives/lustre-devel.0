From: Vitaly Fertman <Vitaly.Fertman@Sun.COM>
Date: Mon, 11 Jan 2010 20:05:22 +0300
Subject: [Lustre-devel] SOM safety
In-Reply-To: <FCF9512F-B081-4307-AA58-9A161790073D@sun.com>
References: <079601ca8e36$70c5f480$5251dd80$@com>
	<FCF9512F-B081-4307-AA58-9A161790073D@sun.com>
Message-ID: <5C3E1B93-49A2-4DE5-A099-C297FABAA623@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 6, 2010, at 12:50 AM, Andreas Dilger wrote:

> This brings up an interesting question.  When the client does a lookup
> on a file, or first opens it, the client gets the cached size from the
> MDS (assuming SOM cache is valid).  However, after this initial
> update, what guarantee does the client have that the size is still
> valid?  Must it do further MDS getattr or OST glimpse operations in
> order to revalidate the size?  I don't recall any lock bit that the
> MDS gives the client that tells the client that the file size it has
> is still valid.

MDS returns size to client if it gives the client the UPDATE lock
and SOM cache is valid (file is not opened, SOM cache is rebuilt).
If file is opened for write, MDS revokes UPDATE lock given to clients,
if SOM cache is valid by the time of open (thus 2nd open will not
revoke it).
If client gets size from MDS, it considers it valid as long as the
current UPDATE lock is cached on the client.
If client gets no size from MDS (i.e. for next getattr when file is
already opened for write) it has to go to OST for its part of  
attributes.

> In this regard, it seems that SOM would only provide an improvement on
> the initial "ls -l" operation, and subsequent "ls -l" operations would
> be slower than the current "readdir + statahead + DLM lock
> cache" (which would not need to do any RPCs for the second "ls -l").


subsequent "ls -l" operations will be faster because we do not need
to re-obtain attributes from MDS if we have UPDATE lock. As SOM cancels
this lock on open for write and on attribute update, an extra RPC will
be sent only on the very 1st getattr after any of these 2 cases occur,
subsequent "ls -l" within enabled or disabled SOM cache have no extra  
RPC.

--
Vitaly
