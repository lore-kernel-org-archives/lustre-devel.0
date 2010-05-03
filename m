From: di.wang <di.wang@oracle.com>
Date: Mon, 03 May 2010 15:52:57 -0400
Subject: [Lustre-devel] Lustre RPC visualization
In-Reply-To: <4BDF24BC.9050701@tu-dresden.de>
References: <000c01cae6ee$1d4693d0$57d3bb70$%barton@oracle.com>
	<4BD8E021.7050302@oracle.com> <4BD90FB9.5030702@tu-dresden.de>
	<4BD9CF75.8030204@oracle.com> <4BDE8C3C.2050505@tu-dresden.de>
	<699F57EF-52E6-41D1-A04B-3C39D469D133@oracle.com>
	<4BDF1199.2030007@tu-dresden.de> <4BDF1CC7.5020502@oracle.com>
	<4BDF24BC.9050701@tu-dresden.de>
Message-ID: <4BDF2999.2000207@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Michael Kluge wrote:
>>> One more question: RPC 1334380768266400 (in the log WangDi sent me)
>>> has on the client side only a "Sending RPC" message, thus missing the
>>> "Completed RPC". The server has all three (received,start work, done
>>> work). Has this RPC vanished on the way back to the client? There is
>>> no further indication what happend. The last timestamp in the client
>>> log is:
>>> 1272565368.228628
>>> and the server says it finished the processing of the request at:
>>> 1272565281.379471
>>> So the client log has been recorded long enough to contain the
>>> "Completed RPC" message for this RPC if it arrived ever ...
>>>       
>> Logically, yes. But in some cases, some debug logs might be abandoned
>> for some reasons(actually, it happens not rarely), and probably you need
>> maintain an average time from server "Handled RPC" to client "Completed
>> RPC", then you just guess the client "Completed RPC" time in this case.
>>     
>
> Oh my gosh ;) I don't want to start speculations about the helpfulness 
> of incomplete debug logs. Anyway, what can get lost? Any kind of message 
> on the servers and clients?  I think I'd like to know what cases have to 
> be handled while I try to track individual RPC's on their way.
>   
Any records can get lost here. Unfortunately, there are not any messages 
indicate the missing happened. :(
(Usually, I would check the time stamp in the log, i.e. no records for a 
"long" time, for example several seconds, but this is not the accurate way).

I guess you can just ignore these uncompleted records in your first 
step?  Let's see how these incomplete log will
impact the profiling result, then we will decide how to deal with this?

Thanks
Wangdi
>
> Regards, Michael
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>   
