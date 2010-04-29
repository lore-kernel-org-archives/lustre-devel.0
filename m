From: Michael Kluge <Michael.Kluge@tu-dresden.de>
Date: Thu, 29 Apr 2010 06:48:57 +0200
Subject: [Lustre-devel] Lustre RPC visualization
In-Reply-To: <4BD8E021.7050302@oracle.com>
References: <000c01cae6ee$1d4693d0$57d3bb70$@barton@oracle.com>
	<4BD8E021.7050302@oracle.com>
Message-ID: <4BD90FB9.5030702@tu-dresden.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi WangDi,

OK, thanks for input. I'll go ahead and try to write a converter. Could 
you please collect a set test traces that belong together from a couple 
servers and clients and put them somewhere so that I can download them?


Thanks, Michael

Am 29.04.2010 03:25, schrieb di.wang:
> Hello, Michael
>
> There is a logfile parser script in the attachment, which was written by
> Eric.
>
> This script is very simple, but it should help you understand how we
> retrieve time step information from lustre debug log. On the server
> side, if you enable rpc_trace log, whenever the request arrive/start
> being processed/end of processing, there will be corresponding records
> being written into the debug log. Basically, you can get all the time
> step information from these records (actually only two of these records
> would be enough).
>
>
> a.
> 00000100:00100000:0.0:1272313858.472660:0:31581:0:(service.c:1625:ptlrpc_server_handle_request())
> Handling RPC pname:cluuid+ref:pid:xid:nid:opc
> ll_mgs_00:7d4fb15c-1b1c-295f-e466-ea7d77089b52+10:4055:x1334115493386242:12345-0 at lo:400
>
>
> This record means the req will being handled, so you can get the start
> time stamp(1272313858.472660) operation type (opc: 400, ping), xid
> (1334115493386242), client nid(12345-0 at lo) and so on.
>
> b.
> 00000100:00100000:0.0:1272313858.472687:0:31581:0:(service.c:1672:ptlrpc_server_handle_request())
> Handled RPC pname:cluuid+ref:pid:xid:nid:opc
> ll_mgs_00:7d4fb15c-1b1c-295f-e466-ea7d77089b52+9:4055:x1334115493386242:12345-0 at lo:400
> Request procesed in 45us (77us total) trans 0 rc 0/0
>
> This record means the req is already being handled, so you can get the
> end time stamp(1272313858.472687), operation type (opc: 400, ping), xid
> (1334115493386242), client nid(12345-0 at lo) and so no.
>
> Note: (77us total) means how long it takes from the request arriving to
> the end of processing. so you can also get the request arriving time
> stamp here by (1272313858 - 77 = 1272312781).
>
>
> So with these information you can draw the graph Eric mentioned in his
> email. If you have any questions, please let me know.
>
> Thanks
> WangDi
>
>
> Eric Barton wrote:
>>
>> ------------------------------------------------------------------------
>>
>> Subject:
>> RE: Visualising Lustre RPCs
>> To:
>> "Michael Kluge" <Michael.Kluge@tu-dresden.de>, "wangdi"
>> <Tom.Wang@Sun.COM>
>>
>> To:
>> "Michael Kluge" <Michael.Kluge@tu-dresden.de>, "wangdi"
>> <Tom.Wang@Sun.COM>
>> CC:
>> <lustre-devel@lists.lustre.org>, "Galen M. Shipman" <gshipman@ornl.gov>
>>
>>
>> Michael,
>>
>> The previous Lustre RPC visualisation effort I mentioned at the LUG
>> used the
>>
>> Lustre debug log entries of type D_RPCTRACE. We disabled all but these
>>
>> log messages and then used the Lustre debug daemon to collect them while
>>
>> we ran I/O tests. We then ran a simple logfile parser which used just
>> the log entries
>>
>> for request arrival?
>>
>> , start of processing and end of processing to graph request
>>
>> queue depth (arrival->end) and the number of requests being serviced
>> by type
>>
>> over time ? e.g?
>>
>> read3d
>>
>> ?which shows request queue depth (vertical) over time (axis labelled
>> 20-25) by
>>
>> server (axis labelled 0-80).
>>
>> *From:* Michael Kluge [mailto:Michael.Kluge at tu-dresden.de]
>> *Sent:* 17 April 2010 6:26 AM
>> *To:* Galen M. Shipman; Eric Barton
>> *Subject:* Visualising Lustre RPCs
>>
>> Hi Galen, Eric,
>>
>> in order to get this little project started, I think what I need at
>> first to
>>
>> write a prototype for a converter are the following things:
>>
>> A set of test traces collected on maybe a handful of clients and some
>> servers
>>
>> is probably a good point to start with. It would be even better if we
>> know
>>
>> what is in this traces so that we have an expectation what kind of things
>>
>> we want to see on the Vampir displays. This little program that Eric
>> mentioned
>>
>> that can read the trace file would be very helpful as well. And as the
>> last
>>
>> idea I have right now, a technical contact. I might come up with a couple
>>
>> of question after I have taken the first look onto the original trace
>> data
>>
>> and before I start writing code.
>>
>> Regards, Michael
>>
>>
>> --
>>
>> Michael Kluge, M.Sc.
>>
>> Technische Universit?t Dresden
>> Center for Information Services and
>> High Performance Computing (ZIH)
>> D-01062 Dresden
>> Germany
>>
>> Contact:
>> Willersbau, Room WIL A 208
>> Phone: (+49) 351 463-34217
>> Fax: (+49) 351 463-37773
>> e-mail: michael.kluge at tu-dresden.de <mailto:michael.kluge@tu-dresden.de>
>> WWW: http://www.tu-dresden.de/zih
