From: di.wang <di.wang@oracle.com>
Date: Tue, 01 Jun 2010 08:12:58 -0400
Subject: [Lustre-devel] Lustre RPC visualization
In-Reply-To: <001601cb01a3$546c93d0$fd45bb70$%barton@oracle.com>
References: <000c01cae6ee$1d4693d0$57d3bb70$%barton@oracle.com>
	<4BD8E021.7050302@oracle.com> <4BD90FB9.5030702@tu-dresden.de>
	<4BD9CF75.8030204@oracle.com> <4BDE8C3C.2050505@tu-dresden.de>
	<699F57EF-52E6-41D1-A04B-3C39D469D133@oracle.com>
	<4BDF1199.2030007@tu-dresden.de> <4BDF1CC7.5020502@oracle.com>
	<4BDF24BC.9050701@tu-dresden.de> <4BDF2999.2000207@oracle.com>
	<4BEFBB07.4030403@tu-dresden.de>
	<1274788995.2261.110.camel@radar> <4BFC7177.9000808@oracle.com>
	<1275058473.21591.14.camel@radar> <4BFFA456.7030502@oracle.com>
	<C671351E-110C-4D2C-B216-4E8BE23A943A@oracle.com>
	<1FF3D25F-3369-462E-9651-62D56319612A@tu-dresden.de>
	<D29ED098-3DEB-4AF4-AA68-B52B4E2BF5EA@oracle.com>
	<4C04F3F0.9040708@oracle.com>
	<001601cb01a3$546c93d0$fd45bb70$%barton@oracle.com>
Message-ID: <4C04F94A.2050908@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Eric Barton wrote:
> I'd really like to see how vampire handles _all_ the trace data
> we can throw at it.  If 600 clients is a pain, how bad will it
> be at 60,000?   
>
> What in particular makes collecting traces from all the clients
> + servers hard?  How can/should we automate it or otherwise make
> it easier?
>   
Aha, I do not mean it is difficult to get all trace logs.

I had thought the current target is to make sure vampire can handle
the trace from "big" enough clusters.

Actually, I am not sure whether vampire(with this trace analyse) should 
work in
this way as we do now?  i.e. running job exclusively on the cluster, get 
rpctrace log, then get
graph by vampire?

Or I miss sth here? Michale, could you please explain a bit? What is 
your idea how vampire could help the end users? or the target here is 
just helping the developers and sysadmin to understand the system?

Thanks
WangDi
>     Cheers,
>               Eric
>
>   
>> -----Original Message-----
>> From: di.wang [mailto:di.wang at oracle.com]
>> Sent: 01 June 2010 12:50 PM
>> To: Robert Read
>> Cc: Michael Kluge; Eric Barton; Galen M. Shipman
>> Subject: Re: [Lustre-devel] Lustre RPC visualization
>>
>> Hello,
>>
>> IMHO, just run IOR with whatever parameters, and get rpctrace
>> log(probably only enable rpctrace) from 1 OST and some of clients
>> (probably 2 is enough).
>> Note: please make sure these 2 clients did communicate the OST during
>> the IOR.
>>
>> Michael, I do not think you need all the trace logs from the clients. right?
>>
>> Robert
>>
>> If there are available time slots for this test on Hyperion, who can
>> help to get these logs?
>>
>> Thanks
>> Wangdi
>>
>> Robert Read wrote:
>>     
>>> What should I run then? Do have scripts to capture this?
>>>
>>> robert
>>>
>>> On May 31, 2010, at 2:39 , Michael Kluge wrote:
>>>
>>>       
>>>> Hi Robert,
>>>>
>>>> 600 is a nice number. Plus the traces from the server an I am happy.
>>>>
>>>>
>>>> Michael
>>>>
>>>> Am 28.05.2010 um 17:53 schrieb Robert Read:
>>>>
>>>>         
>>>>> On May 28, 2010, at 4:09 , di.wang wrote:
>>>>>
>>>>>           
>>>>>> Hello, Michael
>>>>>>
>>>>>>             
>>>>>>> One good news: The Feature that Vampir can show something like a heat
>>>>>>> map (Eric asked about this) comes back with the release at ISC. It is
>>>>>>> now called "performance radar". It can produce a heat map for a
>>>>>>> counter
>>>>>>> and does some other things as well. I could send a picture around, but
>>>>>>> need at first an bigger trace (more hosts generating traces in
>>>>>>> parallel).
>>>>>>>
>>>>>>>               
>>>>>> Right now I do not have big clusters available to generate the trace.
>>>>>> I will see what I can do here.
>>>>>>             
>>>>> If ~600 clients is big enough we could generate that on Hyperion.
>>>>>
>>>>> robert
>>>>>
>>>>>           
>>>>>> Thanks
>>>>>> WangDi
>>>>>>             
>>>>>>>
>>>>>>>               
>>>>>>>>>                   
>>>>>>> ------------------------------------------------------------------------
>>>>>>>
>>>>>>> _______________________________________________
>>>>>>> Lustre-devel mailing list
>>>>>>> Lustre-devel at lists.lustre.org <mailto:Lustre-devel@lists.lustre.org>
>>>>>>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>>>>>>
>>>>>>>               
>>>>>           
>>>> --
>>>>
>>>> Michael Kluge, M.Sc.
>>>>
>>>> Technische Universit?t Dresden
>>>> Center for Information Services and
>>>> High Performance Computing (ZIH)
>>>> D-01062 Dresden
>>>> Germany
>>>>
>>>> Contact:
>>>> Willersbau, Room WIL A 208
>>>> Phone:  (+49) 351 463-34217
>>>> Fax:    (+49) 351 463-37773
>>>> e-mail: michael.kluge at tu-dresden.de <mailto:michael.kluge@tu-dresden.de>
>>>> WWW:    http://www.tu-dresden.de/zih
>>>>
>>>>         
>
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>   
