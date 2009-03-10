From: Vitaly Fertman <Vitaly.Fertman@Sun.COM>
Date: Tue, 10 Mar 2009 19:40:53 +0300
Subject: [Lustre-devel] LustreFS performance
In-Reply-To: <49B65524.6080707@sun.com>
References: <3376C558-E29A-4BB5-8C4C-3E8F4537A195@sun.com>
	<02FEAA2B-8D98-4C2D-9CE8-FF6E1EB135A2@sun.com>
	<8AD540D2-0B50-4630-B794-E65443352696@Sun.COM>
	<49B65524.6080707@sun.com>
Message-ID: <861E8C51-4422-4C51-9062-DC3916DB96D6@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mar 10, 2009, at 2:55 PM, Mallik Ragampudi wrote:

> Vitaly,
>
> This is very comprehensive. Few comments:
>
> 1) I think it would be good to start with LLT2 (lustre-iokit: ior- 
> survey) and get an out-of-the-box performance
> picture/comparison (1.6 and 2.0) from the whole cluster before  
> testing the individual layers.

LLT2 is about underlying local fs on servers, not Lustre.
the overall ior-survey is OSTT3 (it was wrongly mentioned as ost-survey
in the document header, sorry, it must be ior-survey as written
in the detailed section)

> 2) Can this plan be extended to include CMD performance testing as  
> well ? I would expect that most
> of your test cases apply for the CMD as well ?

sure, I will extend it.

> 3) I assume the "CPU" parameter in your methodology refers to # of  
> CPUs in MDS, right ?

to the server which is being tested at the moment, i.e. OST for OST*  
tests,
MDS fro MDS* tests. In the mixed section it refers to MDS indeed.

> 4) I am not sure if we can test 32 cores without hitting other  
> bottlenecks beyond 8 coress on the servers.

if we hit some bottleneck, we will get a problem to solve, what is  
good ;)
however, to see the bottleneck from these results, it is better to run  
MT
tests with different amount of CPUs (the same as for all the CPU  
tests, 1,2,8,32).

> This will cut down some combinations in the matrix.
>
> Thanks,
> Mallik
>

--
Vitaly
