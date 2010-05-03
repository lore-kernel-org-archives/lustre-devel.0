From: di.wang <di.wang@oracle.com>
Date: Mon, 03 May 2010 14:58:15 -0400
Subject: [Lustre-devel] Lustre RPC visualization
In-Reply-To: <4BDF1199.2030007@tu-dresden.de>
References: <000c01cae6ee$1d4693d0$57d3bb70$@barton@oracle.com>
	<4BD8E021.7050302@oracle.com> <4BD90FB9.5030702@tu-dresden.de>
	<4BD9CF75.8030204@oracle.com> <4BDE8C3C.2050505@tu-dresden.de>
	<699F57EF-52E6-41D1-A04B-3C39D469D133@oracle.com>
	<4BDF1199.2030007@tu-dresden.de>
Message-ID: <4BDF1CC7.5020502@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Michael Kluge wrote:
> Hi Andreas,
>
> Am 03.05.2010 15:20, schrieb Andreas Dilger:
>> On 2010-05-03, at 04:41, Michael Kluge wrote:
>>> I have a small problem understanding the logical order of the events.
>>> Here is one example from the logs where the client reports an RPC as
>>> completed before the server says that it has finished the RPC handling.
>>> The difference is about 1.5 ms.
>>>
>>> Is that due to the fact that the server waits until the client has
>>> ack'ed the result of the RPC? Or are the clocks between the servers not
>>> well synchronized? Or are the timestamps in the logfile sometimes not
>>> correct (log message could not be flushed or whatever)?
>>
>> The timestamps on the log messages are only as accurate as the clocks on
> > the nodes.  Lustre can run without synchronized clocks, using the 
> client
> > clock as the basis for the timestamps, but Lustre makes no effort to
> > synchronize the client clocks.  For that you need to use NTP (easiest)
>>  or adjust the timestamps in the logs based on messages like this.
>
> OK, so logically the "Completed RPC" on the client side is supposed to 
> show up after the server has written his "Handled RPC" to its log (if 
> clocks are snyc'ed perfectly).
Yes.
>
> One more question: RPC 1334380768266400 (in the log WangDi sent me) 
> has on the client side only a "Sending RPC" message, thus missing the 
> "Completed RPC". The server has all three (received,start work, done 
> work). Has this RPC vanished on the way back to the client? There is 
> no further indication what happend. The last timestamp in the client 
> log is:
> 1272565368.228628
> and the server says it finished the processing of the request at:
> 1272565281.379471
> So the client log has been recorded long enough to contain the 
> "Completed RPC" message for this RPC if it arrived ever ...
Logically, yes. But in some cases, some debug logs might be abandoned 
for some reasons(actually, it happens not rarely), and probably you need 
maintain an average time from server "Handled RPC" to client "Completed 
RPC", then you just guess the client "Completed RPC" time in this case.

Thanks
WangDi

>
>
> Regards, Michael
>
