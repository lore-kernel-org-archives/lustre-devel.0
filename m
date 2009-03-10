From: Nicholas Henke <nic@cray.com>
Date: Tue, 10 Mar 2009 09:39:13 -0500
Subject: [Lustre-devel] LustreFS performance
In-Reply-To: <20090302204501.GQ3199@webber.adilger.int>
References: <3376C558-E29A-4BB5-8C4C-3E8F4537A195@sun.com>	<02FEAA2B-8D98-4C2D-9CE8-FF6E1EB135A2@sun.com>	<8AD540D2-0B50-4630-B794-E65443352696@Sun.COM>
	<20090302204501.GQ3199@webber.adilger.int>
Message-ID: <49B67B91.9080605@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger wrote:
> On Mar 02, 2009  20:04 +0300, Vitaly Fertman wrote:
>>    RAM: enough to have a tmpfs for MDS;

>> **** Statistics ****
>>
>> During all the tests the following is supposed to be running on all  
>> the servers:
>> 1) vmstat
>> 2) iostat, if there is some disk activity.
>> smth else?
> 
> I would propose either LLNL's LMT or HP's collectl, which both also
> collect Lustre stats.  Those both provide more information than the
> above, and having the IO/CPU load correlated to Lustre RPC counts is
> very useful.

It would be great if we could standardize on a set of tools for performance 
issues. I've got to think a set of tools like this would make it easier for 
customer & partners to gather the correct data the first time.

Cray has been using lstats, a package of scripts we got from Sun a while back. 
We've added things like AT timeout and sar per-cpu usage to it (see bug 18574 
att 22140 for complete set of scripts).

I'm all for using collectl, but I think the requirements and setup for LMT makes 
  it a tough sell. Does Sun have a set of customizations for collectl or does 
the standard collectl collect enough information?

Nic
