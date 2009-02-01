From: Vitaly Fertman <Vitaly.Fertman@Sun.COM>
Date: Sun, 01 Feb 2009 20:24:41 +0300
Subject: [Lustre-devel] SOM Recovery of open files
In-Reply-To: <C68908D1-8287-4870-903E-DDCDED6E31D0@Sun.COM>
References: <20090130233253.GK3652@webber.adilger.int>
	<63CF2DAF-59F7-4124-8AE9-188927051AAB@sun.com>
	<C68908D1-8287-4870-903E-DDCDED6E31D0@Sun.COM>
Message-ID: <5882C1BC-E01E-42FF-A728-08885E997075@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 1, 2009, at 5:45 PM, Vitaly Fertman wrote:

> thus the only problem here is a stale fh on a client which may let  
> the client
> to write to the file after the SOM cache will be re-obtained on MDS,  
> which
> consists of 2 parts:
>
> - an ability of a client to write to an opened file without a  
> connection to MDS;
> - an absence of file re-opening on re-connection.

I forgot to mention about truncate (locked & lockless) and lockless IO.

MDS must be aware about opened IOEpoch for truncate as well, otherwise
obd_punches must be blocked. The situation is pretty rare as we do not
cache punches on clients and they go away right md_setattr completes,
but I think what if at the time of the client eviction from MDS, the  
connection
between this client and an OST is unstable so that punches will hang  
in the
re-send list for a while, enough for another client to modify the file  
--
MDS gets a new SOM cache, and later punch will modify the file.

The same for lockless IO.

The locked truncate is involved as it could hang in the re-send list  
with
the lock enqueue, so that enqueue+punch will happen after MDS re- 
validates
SOM cache.

Thus:
- block truncate and lockless IO;
- "re-open" truncate on re-connection as well as regularly opened files.

This must happen even if SOM is disabled but the client already  
supports it
(clients are upgraded first). Otherwise, the interoperability will be  
broken.

--
Vitaly
