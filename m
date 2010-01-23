From: Alexey Lyashkov <alexey.lyashkov@clusterstor.com>
Date: Sat, 23 Jan 2010 09:09:26 +0200
Subject: [Lustre-devel] proposal on implementing a new readahead in clio
In-Reply-To: <4B598390.5030504@sun.com>
References: <4B56F907.3090308@sun.com>  <4B598390.5030504@sun.com>
Message-ID: <1264230566.11892.62.camel@berloga.shadowland>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>>
We have an idea to spawn a per file readahead thread for each process,
and this thread can be used to issue the readahead RPC async.
>>
I correctly understand: you suggest a spawn one new thread per open
file?
so if client have 10 processes, and each process is open 100 files, you
need spawn 1000 new threads?


On Fri, 2010-01-22 at 18:53 +0800, jay wrote:
> UP!!
> 
> Here is a pdf version of design document. Also I'm attaching a picture 
> because the pictures in pdf is not clear.
> 
> Thanks,
> Jay
> 
> jay wrote:
> > Hello,


-- 
Alexey Lyashkov <alexey.lyashkov@clusterstor.com>
ClusterStor
