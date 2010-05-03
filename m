From: Michael Kluge <Michael.Kluge@tu-dresden.de>
Date: Mon, 03 May 2010 22:04:11 +0200
Subject: [Lustre-devel] Lustre RPC visualization
In-Reply-To: <4BDF2999.2000207@oracle.com>
References: <000c01cae6ee$1d4693d0$57d3bb70$%barton@oracle.com>
	<4BD8E021.7050302@oracle.com> <4BD90FB9.5030702@tu-dresden.de>
	<4BD9CF75.8030204@oracle.com> <4BDE8C3C.2050505@tu-dresden.de>
	<699F57EF-52E6-41D1-A04B-3C39D469D133@oracle.com>
	<4BDF1199.2030007@tu-dresden.de> <4BDF1CC7.5020502@oracle.com>
	<4BDF24BC.9050701@tu-dresden.de> <4BDF2999.2000207@oracle.com>
Message-ID: <4BDF2C3B.8050505@tu-dresden.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

OK, sounds reasonable. I can put the number of ignored messages in an 
additional counter. That should make the generated trace file more 
descriptive.

Regards, Michael

Am 03.05.2010 21:52, schrieb di.wang:
>> Anyway, what can get lost? Any kind of
>> message on the servers and clients? I think I'd like to know what
>> cases have to be handled while I try to track individual RPC's on
>> their way.
> Any records can get lost here. Unfortunately, there are not any messages
> indicate the missing happened. :(
> (Usually, I would check the time stamp in the log, i.e. no records for a
> "long" time, for example several seconds, but this is not the accurate
> way).
>
> I guess you can just ignore these uncompleted records in your first
> step? Let's see how these incomplete log will
> impact the profiling result, then we will decide how to deal with this?
>
