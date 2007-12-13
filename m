From: Peter Braam <Peter.Braam@Sun.COM>
Date: Thu, 13 Dec 2007 12:09:28 -0700
Subject: [Lustre-devel] read ahead
In-Reply-To: <4760B247.4030505@sun.com>
References: <475ED623.6090204@sun.com>
	<18270.55813.185376.299242@gargle.gargle.HOWL>
	<20071211234708.GT3214@webber.adilger.int> <475F7759.2080103@sun.com>
	<47603E32.6070203@sun.com> <4760B247.4030505@sun.com>
Message-ID: <47618368.7000202@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



Tom.Wang wrote:
> Hi, Peter
>
> I just talked with Matt about his pCIFS test. In his test, there are 2 
> clients, 2 OST, (stripe_count =2, stripe_size=1M).
> Each client run 1 thread to read a shared file. Each thread(client) 
> will only read data of the shared file from 1 OST, so
> read request is discontiguous (1M step stride I/O) for each of thread, 
> which will not trigger read-ahead,  because
> read-ahead window will be reset once it met discontinuous  read  
> request.  So  kept  read-ahead in the same step
> of stride step ((stripe_count -1) * stripe_size) instead of 
> contiguous  could just fix this problem, and it is what we are
> working now.
>
Finally!  This makes a lot of sense.

> Btw:  we also need this in lustre collective read  ADIO driver,  
> since  we  will also  need  reorganize the  data  as  1client-> 1OST 
>          model  like pCIFS does.

I now see why this stripe behavior with read-ahead is so very important 
for Lustre in some cases.

It would also be important to know that in basic cases we really get as 
good read performance as write.

- Peter -

>          Another alternative way maybe move read-ahead mechanism to 
> osc layer, but maybe a bad idea.
> Thanks
> WangDi
>
