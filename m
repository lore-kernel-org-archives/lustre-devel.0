From: Yong Fan <Yong.Fan@Sun.COM>
Date: Tue, 10 Mar 2009 17:28:46 +0800
Subject: [Lustre-devel] statahead_performance.pdf - Adobe Reader
In-Reply-To: <002901c9a0dd$22249850$666dc8f0$@com>
References: <070201c9a0c4$d6fe8b50$84fba1f0$@com> <49B544FA.9020009@sun.com>
	<002901c9a0dd$22249850$666dc8f0$@com>
Message-ID: <49B632CE.4040500@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Sorry, some test resources budgeting limit delayed the test
a little. This is the last test result:
TCP2, IB and Routed IB were tested on the same cluster
with the same scale. TPC1 was tested on another cluster.

Regards,
--
Fan Yong
> Fan Yong,
>
> I don't think the factor of ~2 can be explained simply by node
> performance.  But why debate the point when it will be simpler
> to repeat the measurements (i.e. repeating the tests exactly
> with the same parameters e.g. # dirents) using 1GigE on the
> same nodes that were used to measure IB.
>
>     Cheers,
>               Eric
>
>   
>> -----Original Message-----
>> From: Yong.Fan at Sun.COM [mailto:Yong.Fan at Sun.COM]
>> Sent: 09 March 2009 4:34 PM
>> To: Eric Barton
>> Cc: lustre-devel at lists.lustre.org
>> Subject: Re: statahead_performance.pdf - Adobe Reader
>>
>> Eric Barton ??:
>>     
>>> Fan Yong,
>>>
>>> The attached PDF shows the results you gathered in a form
>>> that makes it easier to understand the results and helps
>>> comparison.  Please could you review it for correctness.
>>>
>>>
>>>       
>> Yes, it is much help to understand the performance improvement
>> by statahead with the chart.
>>
>> But I think the first chart for "Statahead Dirents/second" maybe
>> some misguide, since the TCP result and IB result are from different
>> hardware environment (I mean the CPU and memory), that the speed
>> of stating under IB is faster than TCP case is meaningless.
>>
>> Relatively, the second chart for "Statahead Speedup" is more useful,
>> which is relatively independent from hardware (CPU and memory).
>> It gives the trend of upper bound on performance improvement from
>> statahead under different network configure, and different dir/file ratio.
>>
>>
>> Thanks!
>> --
>> Fan Yong
>>     
>>>     Cheers,
>>>               Eric
>>>
>>>
>>>       
>
>
>   

-------------- next part --------------
A non-text attachment was scrubbed...
Name: statahead_performance.ods
Type: application/vnd.oasis.opendocument.spreadsheet
Size: 32448 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090310/633988a7/attachment.ods>
