From: Michael Kluge <Michael.Kluge@tu-dresden.de>
Date: Thu, 24 Jun 2010 10:01:14 +0200
Subject: [Lustre-devel] Lustre RPC visualization
In-Reply-To: <3BF1EC13-3865-41C8-B860-E190EF0DE876@oracle.com>
References: <000c01cae6ee$1d4693d0$57d3bb70$%barton@oracle.com>
	<4BDE8C3C.2050505@tu-dresden.de>
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
	<4C04F94A.2050908@oracle.com>
	<7B05EBAF-67C5-4EE1-B1EC-CB1C554BEA3E@oracle.com>
	<4DBE6FF1-62B0-484C-81F8-B231E332BFB5@tu-dresden.de>
	<1BFD6845-6D5A-459F-8164-4F75FD759060@tu-dresden.de>
	<B25C28C7-7D9C-4BAC-9218-A9CAEB0C21E6@orr! acle.com>
	<1276783329.499.322.camel@radar>
	<4169315E-9A94-4430-8970-92068222EF15@oracle.com! >
	<4C1E7D95.80100@tu-dresden.de>
	<96A6F62D-08C6-4A3D-9C2A-785F0DA00428@tu-dresden.de>
	<4B610316-4D3A-4087-B4AD-15F94615D3C3@clusterstor.com>
	<313DF9B2-FDA8-4862-9FC6-DB674EF4B68D@tu-dresden.de>
	<3BF1EC13-3865-41C8-B860-E190EF0DE876@oracle.com>
Message-ID: <44E9F0A8-5850-4FAA-992C-2C57D4F54AEE@tu-dresden.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

> While Alexey's comment is correct, in that there can be multiple Lustre client mounts on a single node, this is generally only used for testing.  For client connections the UUID is just a random value like "f4726b1e-f7eb-479f-b163-784ea45adf32", so using the NID is much more useful to the viewer in the vast majority of cases.

Well, what I can do with OTF and Vampir is to use a process hierarchy. So for each NID I can have a couple of UUID as 'child processes'. Like the way one looks at hybrid MPI & OpenMP programs. Where we have MPI processes and treat OpenMP threads as child processes.

> If you wanted to distinguish the multiple mounts from a single client it would be best to just do this internally by tracking both the NID and the UUID, but only printing the NID on the output.  For the rare case where requests have the same NID but a different UUID you could show this as "NID:2", "NID:3" or similar.  That preserves the distinction between client connections, while not making the output completely useless.

Yes, that fits into the statement above.

> Even better than plain numeric NIDs would be to do IP->hostname conversion for the case of TCP and IB LNDs, if this works.

Well, typically I only have the debug log. Which might be incomplete. I don't think I have something that can do this conversion reliably?


Michael


>> Am 23.06.2010 um 12:29 schrieb Alexey Lyashkov:
>> 
>>> I think better to use client UUID instead of NID as client identification. Because in your's case - you can't separate info from two clients which run on same node.
>>> 
>>> 
>>> On Jun 22, 2010, at 19:12, Michael Kluge wrote:
>>> 
>>>> The remaining problems of the counter calculations have been fixed. There is a screenshot attached showing some values. The code is in a gforge server that we operate here in Dresden (gforge.zih.tu-dresden.de). The converter runs on Linux and on MAC OS X and you need Vampir to take a look at the OTF trace file.
>>>> 
>>>> Eric, Galen, for the moment I think I am done with the stuff I promised you at LUG this year? Are there any more ideas?
>>>> 
>>>> 
>>>> Michael
>>>> 
>>>> 
>>>> 
>>>> <lustre3.png>
>>>> 
>>>> 
>>>> 
>>>> 
>>>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>> 
>>> 
>>> 
>>> --------------------------------------
>>> Alexey Lyashkov
>>> alexey.lyashkov at clusterstor.com
>>> 
>>> 
>>> 
>>> 
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
>> Phone:  (+49) 351 463-34217
>> Fax:    (+49) 351 463-37773
>> e-mail: michael.kluge at tu-dresden.de
>> WWW:    http://www.tu-dresden.de/zih
>> 
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
> 
> 
> Cheers, Andreas
> --
> Andreas Dilger
> Lustre Technical Lead
> Oracle Corporation Canada Inc.
> 
> 


-- 

Michael Kluge, M.Sc.

Technische Universit?t Dresden
Center for Information Services and
High Performance Computing (ZIH)
D-01062 Dresden
Germany

Contact:
Willersbau, Room WIL A 208
Phone:  (+49) 351 463-34217
Fax:    (+49) 351 463-37773
e-mail: michael.kluge at tu-dresden.de
WWW:    http://www.tu-dresden.de/zih

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100624/77e1f513/attachment.htm>
