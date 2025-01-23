Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 9E7BEC02182
	for <lustre-devel@archiver.kernel.org>; Thu, 23 Jan 2025 04:51:59 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YdpSh72lvz1xNr;
	Wed, 22 Jan 2025 20:51:48 -0800 (PST)
Received: from mail-wm1-f51.google.com (mail-wm1-f51.google.com
 [209.85.128.51])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YdpSH6Srwz1whs
 for <lustre-devel@lists.lustre.org>; Wed, 22 Jan 2025 20:51:27 -0800 (PST)
Received: by mail-wm1-f51.google.com with SMTP id
 5b1f17b1804b1-436ce2ab251so2764875e9.1
 for <lustre-devel@lists.lustre.org>; Wed, 22 Jan 2025 20:51:27 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1737607879; x=1738212679; darn=lists.lustre.org;
 h=references:to:cc:in-reply-to:date:subject:mime-version:message-id
 :from:from:to:cc:subject:date:message-id:reply-to;
 bh=YSvYdpJD8OwV4zsqBCyhzH6BVVd0Ri4YXrMfnZRJT4s=;
 b=f/QC69QUqR0mEFlaGueedR2eVAFrb0U1An1VhjmnzB3YiWh9V7BTS+ZZjxQ4Slcnkp
 jVwOtGIviAlnZYab5w/yjsRXmIDXlHoVgx2/wVinpl1Tbgv2HZzT9LVqdy4qsedGgGpX
 LDs6aOkImja7v0B8AyxnF2r+p+Wgu940p6YWHB+byvcRUYfZP2ber3btLR1Ve2MngH0N
 Nt1OUcIDQSmQ2lv3LD7WJp1iYIiOH7+eSZB9L4TRMamSWYSlpSWgPg0szkVM+JqkeP76
 IWnqQR2rL4f9PzpC0An6uyxl8MuEfXA3zbQ8tTlfm0M3TZUm+Ahs+GsGBvkVL2Tm/sDA
 IAaw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1737607879; x=1738212679;
 h=references:to:cc:in-reply-to:date:subject:mime-version:message-id
 :from:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
 bh=YSvYdpJD8OwV4zsqBCyhzH6BVVd0Ri4YXrMfnZRJT4s=;
 b=psW74Dq+4ug28ZDPQiW7zWld0YBE8RxdpJkQaC2pZwk9EyYKLVBIxmyyGjA+sAYx6v
 Zrgss9dEwsCm3kgP5oG5d2jOclNgAlua/nrODbiZwcIP2qf6AtePCKn9P4EadQ3wJlbS
 T9B82XHrSZ+VZWG+m3HylyCnSYHKePH0EyP/z9QIUP7FkdrYrWEZCvdZw2nd0l59LihQ
 XBmGnryspunExHK50aIGTxlkrJXPGj9fUnF44gHk06zl9HVlyKHsG0lCybluvdXCbwOD
 vzrSW6du+nXeVkXi2Jr0dINnANMS20ESVyQKWc2M8zqVoVup4fQL6HoYVsIKJAz4UKWP
 IwOA==
X-Forwarded-Encrypted: i=1;
 AJvYcCUROEkVrTIpMFpawQgsrvEgh6DH+HCUYN606dpNx6uXD4rUtjxQp3OkuDrdbhgOB74kUXNbyZ7w7QIF1PU=@lists.lustre.org
X-Gm-Message-State: AOJu0Yz2kbAlvAsm61uBjZH+Mj2F/gr9B1KkSfQyuvb1Wsbgb09s3PCM
 rE/96iYA39XOzT+/ll7gnYQ5kYsHsGg77XUppP/jEHkFhx7lJglr
X-Gm-Gg: ASbGncvjS4z4nJaVnTIuhCpptTqa1FSZws9OhHmRzGH2NfuIc/Kw4oHF2aFaH+LqM4Q
 sl2+Muqn2w7G8d64To1rBd0b6SUu4FkUJIqZCqRHf8SaBfVCX6iE14nc0uIWX9+ad4tmMPqsyPi
 pAaXhvjwVsVzEEHzMNsMJYaAFOhzhbcLgbO/D9I/R7jkOpvlmR1EUX5nsiofP0Kmzt8So2Q9Y+k
 yx31CdkalBjV5JAaNazEa84/3Ri9QSSCKSeJkKX7hvH16yx8S+kWVHXX1wC2HYJx2xOJKRgNScN
 IBZnV0gd6rJcmdE+Z+TtQBwBowJW2TlLkIiJNx+sB7uQ1co8QcOuY7obE6AZzA==
X-Google-Smtp-Source: AGHT+IHNqHaS8Bhjk1v/IHeVXWpLrjFZYfhowRi1Q+UvvF3/Bf1iChT1RETE/Ph0JqnYE85ggmzxrA==
X-Received: by 2002:a7b:c00f:0:b0:434:f5c0:32b1 with SMTP id
 5b1f17b1804b1-4389eecb1f5mr208221435e9.15.1737607879304; 
 Wed, 22 Jan 2025 20:51:19 -0800 (PST)
Received: from smtpclient.apple (vps-b708d385.vps.ovh.net. [57.129.16.80])
 by smtp.gmail.com with ESMTPSA id
 5b1f17b1804b1-438b31b78aasm47457855e9.29.2025.01.22.20.51.16
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
 Wed, 22 Jan 2025 20:51:18 -0800 (PST)
From: Alexey Lyahkov <alexey.lyashkov@gmail.com>
Message-Id: <339AF895-36E5-4FAF-B1E1-E69B2AB130EF@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3776.700.51.11.1\))
Date: Thu, 23 Jan 2025 07:51:04 +0300
In-Reply-To: <173757925141.22054.738723965751021240@noble.neil.brown.name>
To: NeilBrown <neilb@suse.de>
References: <7459DF85-7A0F-4DC8-9EC3-CA6F3C86234E@gmail.com>
 <173757925141.22054.738723965751021240@noble.neil.brown.name>
X-Mailer: Apple Mail (2.3776.700.51.11.1)
Subject: Re: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============0153671108843781672=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>


--===============0153671108843781672==
Content-Type: multipart/alternative;
	boundary="Apple-Mail=_F03CB6D3-EFC1-46AA-A0C2-8CAD7CD86C88"


--Apple-Mail=_F03CB6D3-EFC1-46AA-A0C2-8CAD7CD86C88
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8



> On 22 Jan 2025, at 23:54, NeilBrown <neilb@suse.de> wrote:
>=20
> On Mon, 20 Jan 2025, Alexey Lyahkov wrote:
>>=20
>>> On 19 Jan 2025, at 11:03, NeilBrown <neilb@suse.de> wrote:
>>>=20
>>> On Sun, 19 Jan 2025, Alexey Lyahkov wrote:
>>>> Neil,
>>>>>=20
>>>>>=20
>>>>>>=20
>>>>>> It does not hep that there are what 3? 4? trees, not "dual-tree" =
by any
>>>>>> stretch of imagination.
>>>>>>=20
>>>>>> There's DDN/whamcloud (that's really two trees), there's HPE, =
LLNL
>>>>>> keeps their fork still I think (thought it's mostly backports?). =
There
>>>>>> are likely others I am less exposed to.
>>>>>=20
>>>>> "dual-tree" maybe isn't the best way of describing what was wrong =
with
>>>>> the previous approach.  "upstream-first" is one way of describing =
how it
>>>>> should be run, though that needs to be in understood correctly.
>>>>>=20
>>>>> Patches should always flow upstream first, then flow downstream =
into
>>>>> distro.  So I write a patch in my own devel tree.  I post it or =
submit a
>>>>> pull request and eventually it is accepted into the maintainers
>>>>> "testing" tree (upsream from me).  There it gets more testing and =
moves
>>>>> to the maintainers "next" tree from which it is pulled into =
linux-next
>>>>> for integration testing.  Then it goes upstream to Linus (possibly
>>>>> through an intermediary).  =46rom Linus it goes to -stable and to =
various
>>>>> distros etc.  Individual patches are selected for further =
backporting to
>>>>> all sorts of different LTS tree.
>>>>>=20
>>>>> Occasionally there are short-cuts.  I might submit a patch from my =
tree
>>>>> to a SUSE kernel before it is accepted upstream, or maybe even =
before it
>>>>> is sent if it is urgent.  But these are not the norm.
>>>>>=20
>>>>> But you know all this I expect.  It isn't about the total number =
of
>>>>> trees. It is about the flow of patches which must all flow through =
Linus.
>>>>> And developers must develop against current linus, or something =
very
>>>>> close to that.  Developing against an older kernel is simply =
making more
>>>>> work for yourself.
>>>>=20
>>>> This will don=E2=80=99t work. Let explain situation in past.
>>>=20
>>> No.  I'm not at all interested in explanations of why it won't work.
>>>=20
>>> I'm only interested in suggestions of how to make it work, and =
offers of
>>> help.
>>>=20
>> If you have a good way how to solve such situation, which had crazy =
brain in past.
>> Please share a way how to avoid lustre source code fragmentation =
because of freeze a code at the different stage in different =
distributions.
>> Ubuntu might have a modern lustre with 6.5 kernel, but Redhat had =
frozen a lustre version in 3 releases in past and these clients not =
compatible each other.
>> And not compatible with installed server.
>> So question - who will do such support ? Did you have an ideas how to =
solve this problem?
>>=20
>=20
> sorry - I didn't mean to go quite on you - I've been busy :-)
>=20
> It's not entirely clear to me what the problem is.
> You talk about clients not being compatible with each other or with =
the
> server, but Andreas has said that there is good compatibility between
> different versions so I wonder if that is really (still) an issue.

Lustre have good compatibility, but not at all cases. It have tested =
with +/-1 release only.
I remember a several cases then it caused a probles with clients more =
than one release old.
As about Andreas, Andreas don=E2=80=99t work with client support for =
long time so don=E2=80=99t know about all problems in this area.

>=20
> Keeping different kernels up to date with new updates is something =
that
> the linux-stable team does all the time.  We do it at SUSE to.  It =
isn't
> that hard.
> You identify which patches *need* to be backported (ideally when the
> patch is created but that isn't always easy) and you use tools to help
> you backport them.
So Lustre developers needs control all stable kernels and think which =
patch needs back ported and send it to Distro owner=20
And for each LTS kernels on the kernel.org <http://kernel.org/>.. I =
think it increase a work dramatically.

>=20
> Certainly there is effort involved, but maintaining a package that =
works
> on a large set of kernels also involves effort.  It isn't clear to me
> that it is *more* effort, just *different* effort.
>=20
> NeilBrown

Alex=

--Apple-Mail=_F03CB6D3-EFC1-46AA-A0C2-8CAD7CD86C88
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=utf-8

<html><head><meta http-equiv=3D"content-type" content=3D"text/html; =
charset=3Dutf-8"></head><body style=3D"overflow-wrap: break-word; =
-webkit-nbsp-mode: space; line-break: after-white-space;"><br =
id=3D"lineBreakAtBeginningOfMessage"><div><br><blockquote =
type=3D"cite"><div>On 22 Jan 2025, at 23:54, NeilBrown =
&lt;neilb@suse.de&gt; wrote:</div><br =
class=3D"Apple-interchange-newline"><div><div>On Mon, 20 Jan 2025, =
Alexey Lyahkov wrote:<br><blockquote type=3D"cite"><br><blockquote =
type=3D"cite">On 19 Jan 2025, at 11:03, NeilBrown &lt;neilb@suse.de&gt; =
wrote:<br><br>On Sun, 19 Jan 2025, Alexey Lyahkov wrote:<br><blockquote =
type=3D"cite">Neil,<br><blockquote type=3D"cite"><br><br><blockquote =
type=3D"cite"><br>It does not hep that there are what 3? 4? trees, not =
"dual-tree" by any<br>stretch of imagination.<br><br>There's =
DDN/whamcloud (that's really two trees), there's HPE, LLNL<br>keeps =
their fork still I think (thought it's mostly backports?). There<br>are =
likely others I am less exposed to.<br></blockquote><br>"dual-tree" =
maybe isn't the best way of describing what was wrong with<br>the =
previous approach. &nbsp;"upstream-first" is one way of describing how =
it<br>should be run, though that needs to be in understood =
correctly.<br><br>Patches should always flow upstream first, then flow =
downstream into<br>distro. &nbsp;So I write a patch in my own devel =
tree. &nbsp;I post it or submit a<br>pull request and eventually it is =
accepted into the maintainers<br>"testing" tree (upsream from me). =
&nbsp;There it gets more testing and moves<br>to the maintainers "next" =
tree from which it is pulled into linux-next<br>for integration testing. =
&nbsp;Then it goes upstream to Linus (possibly<br>through an =
intermediary). &nbsp;=46rom Linus it goes to -stable and to =
various<br>distros etc. &nbsp;Individual patches are selected for =
further backporting to<br>all sorts of different LTS =
tree.<br><br>Occasionally there are short-cuts. &nbsp;I might submit a =
patch from my tree<br>to a SUSE kernel before it is accepted upstream, =
or maybe even before it<br>is sent if it is urgent. &nbsp;But these are =
not the norm.<br><br>But you know all this I expect. &nbsp;It isn't =
about the total number of<br>trees. It is about the flow of patches =
which must all flow through Linus.<br>And developers must develop =
against current linus, or something very<br>close to that. =
&nbsp;Developing against an older kernel is simply making more<br>work =
for yourself.<br></blockquote><br>This will don=E2=80=99t work. Let =
explain situation in past.<br></blockquote><br>No. &nbsp;I'm not at all =
interested in explanations of why it won't work.<br><br>I'm only =
interested in suggestions of how to make it work, and offers =
of<br>help.<br><br></blockquote>If you have a good way how to solve such =
situation, which had crazy brain in past.<br>Please share a way how to =
avoid lustre source code fragmentation because of freeze a code at the =
different stage in different distributions.<br>Ubuntu might have a =
modern lustre with 6.5 kernel, but Redhat had frozen a lustre version in =
3 releases in past and these clients not compatible each other.<br>And =
not compatible with installed server.<br>So question - who will do such =
support ? Did you have an ideas how to solve this =
problem?<br><br></blockquote><br>sorry - I didn't mean to go quite on =
you - I've been busy :-)<br><br>It's not entirely clear to me what the =
problem is.<br>You talk about clients not being compatible with each =
other or with the<br>server, but Andreas has said that there is good =
compatibility between<br>different versions so I wonder if that is =
really (still) an =
issue.<br></div></div></blockquote><div><br></div><div>Lustre have good =
compatibility, but not at all cases. It have tested with +/-1 release =
only.</div><div>I remember a several cases then it caused a probles with =
clients more than one release old.</div><div>As about Andreas, Andreas =
don=E2=80=99t work with client support for long time so don=E2=80=99t =
know about all problems in this area.</div><div><br></div><blockquote =
type=3D"cite"><div><div><br>Keeping different kernels up to date with =
new updates is something that<br>the linux-stable team does all the =
time. &nbsp;We do it at SUSE to. &nbsp;It isn't<br>that hard.<br>You =
identify which patches *need* to be backported (ideally when =
the<br>patch is created but that isn't always easy) and you use tools to =
help<br>you backport them.<br></div></div></blockquote><div>So Lustre =
developers needs control all stable kernels and think which patch needs =
back ported and send it to Distro owner&nbsp;</div><div>And for each LTS =
kernels on the <a href=3D"http://kernel.org">kernel.org</a>.. I think it =
increase a work dramatically.</div><div><br></div><blockquote =
type=3D"cite"><div><div><br>Certainly there is effort involved, but =
maintaining a package that works<br>on a large set of kernels also =
involves effort. &nbsp;It isn't clear to me<br>that it is *more* effort, =
just *different* =
effort.<br><br>NeilBrown<br></div></div></blockquote></div><br><div>Alex</=
div></body></html>=

--Apple-Mail=_F03CB6D3-EFC1-46AA-A0C2-8CAD7CD86C88--

--===============0153671108843781672==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============0153671108843781672==--
