From: Peter J Braam <Peter.Braam@Sun.COM>
Date: Mon, 07 Jan 2008 10:24:52 +0100
Subject: [Lustre-devel] I/O trace tool
In-Reply-To: <475C191B.7030204@sun.com>
References: <475C191B.7030204@sun.com>
Message-ID: <4781EFE4.6090104@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Tom -

Tom.Wang wrote:
> Hello,
>
> Here is an idea for lustre I/O trace tool.
>
> We can provide 1 new lfs utility, for example lfs trace.
>
> So in the I/O trace job, we could
>
> 1) lfs trace job_id start   (Enable all the trace dump on OSS and MDS 
> for this job, here the trace means the information under /proc or some
>                                           debug log, but also may add 
> some other information. maybe in llog format)
> 2) Run the application.
> 3) lfs trace job_id stop trace_log. (Disable the trace dump on the 
> servers, and get the trace log from these servers).
>
> But here is a problem,  since  this  tool  will  be  used  by  normal  
> end-user,  so  the lfs should only enable the trace
> for the request of this job.  But current, server can not identify the 
> job id at all.  And also maintaining the job_id for the job
> may also bring some troubles. 

The logging system allows to follow the xid of requests executed on
clients to server threads.  I am not sure if this is fully implemented.

It is important that this problem is resolved, and I think you can do 
it.  Of course requests sometimes initiate from cache flushes etc and in 
this case finding the source is maybe not so easy.

- Peter -

> An alternative way  is to identify the request by uid and gid on the 
> server, then only requests from
> this user will be traced,   but then the end user can only run that 
> trace job at that time.
> Any ideas?
>
> Thanks
> WangDi
>
>
>
>
>
>
>
>
>
>
>
>
