From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Date: Thu, 13 Dec 2007 10:15:53 -0500
Subject: [Lustre-devel] read ahead
In-Reply-To: <6C95C14E-9F4E-4E3E-A435-5010C2EFC999@sun.com> 
Message-ID: <200712131515.lBDFFrCa014152@cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

In message <6C95C14E-9F4E-4E3E-A435-5010C2EFC999@sun.com>,Oleg Drokin writes:
>Yes it is.
>DIRECT IO by it's nature is "direct", i.e. it gets straight into  
>application buffers,
>we are not to put any more data there than application said it can  
>accept.

i agree with this interpretation of O_DIRECT.

>And we are not allowed to cache any of that data (or to use any cache  
>to get
>the data during reads) too.

this seems a bit stricter than i would expect.  while i would expect
O_DIRECT to bypass the kernel readahead mechanism, i think that lustre's
readahead is outside of the scope of O_DIRECT.
