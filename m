Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E1DD6C02194
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 07:34:01 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Ym1b60q7gz1xdy;
	Sat, 01 Feb 2025 23:33:54 -0800 (PST)
Received: from mail-ed1-f52.google.com (mail-ed1-f52.google.com
 [209.85.208.52])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Ym1b21pJNz1wkK
 for <lustre-devel@lists.lustre.org>; Sat, 01 Feb 2025 23:33:50 -0800 (PST)
Received: by mail-ed1-f52.google.com with SMTP id
 4fb4d7f45d1cf-5d4e2aa7ea9so7212172a12.2
 for <lustre-devel@lists.lustre.org>; Sat, 01 Feb 2025 23:33:50 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1738481628; x=1739086428; darn=lists.lustre.org;
 h=references:to:cc:in-reply-to:date:subject:mime-version:message-id
 :from:from:to:cc:subject:date:message-id:reply-to;
 bh=ybYwFBWbesvTL9GgzmyTkYCjfGqLPwI2DanMriYuycQ=;
 b=FY3IPF0pX+2Q4ayuLA0Ad2+LsxpTTbTe3T3Nov3me4bKnt4oWLfggKjzqwILtdflua
 TVd22wXIDilMf83XgwaijcAzDt6yOwy6xVNHxXMSjbRVOoszT5O3DK6iOUyrLdc1AJp8
 pjnaWogX6uY2B5tN65m5hQr6nWfEj6b89FfoxMgGmO7ixvhlJZ8fcrillHCW3gPRbG/3
 0pEwl/IsTt49V135J5wEqR54ObCkZsxDspq3/VTXre1MqJxPV21jteUREG4E4FrNKGs5
 HQtfSVkf2JRDTFQKmXqJ7esdS9qMN/6j/bkluS/KB7WHDR+Ut3b0ROMVyk5id0bbMfLx
 A9MA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1738481628; x=1739086428;
 h=references:to:cc:in-reply-to:date:subject:mime-version:message-id
 :from:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
 bh=ybYwFBWbesvTL9GgzmyTkYCjfGqLPwI2DanMriYuycQ=;
 b=pZdXSy5zKpJvo/k526acjOCRmJ0rE6I1WCyRDH7wGdnKxLtPr+ZvF93Ax7NypnztSr
 Tbx3T/73bq2P/B/RRZAbqgTAafGkqUTNXeD5oHMyjlzo5A8O8cSgbqXpPznL/ttEQLXI
 1MVU/zRrJXd8FbIN8/FoR6JKRW7+5RBw08hnzIB9d6IaHqsAJYXwgCXzq0ZmwU2TSD9Z
 UyGm0RGaBpCaxC9hq5ztkxgMgAr35QW/kE8/u41aVc/2Ad7gzYufSHng9fRU6ntT7VN1
 DUcp2B7CsgI9vNXji9utnQoBZO7/11nYyL/cLV9bA6aBZA+Xbno7TQghi0z3H63nARYP
 oekw==
X-Forwarded-Encrypted: i=1;
 AJvYcCUABY5B3ZPpG53S6giIK1glJlXWC8sXmAFmBD0XnPOeA/t0vQr3rVs/dRNx5/sPblOaYtAc2c+EFjhss/o=@lists.lustre.org
X-Gm-Message-State: AOJu0Yxj6sIdjahUSite8ijiMMzdF3k1bUQp8kAQW0We1ZknMqepoBh0
 F/huYeKyPlNOTfhromTDqopp3nq20ywayBZTlwynrDUBch4LV3AQ
X-Gm-Gg: ASbGnct4mfwOlLRt5qVW2AiKtIiowiEAQM4o/dpsAqIdKXKAhMW0ld7yADeRPdATQsa
 SaMl1yHVFevBgAEjKOqYAnERzSKdPPJ3Ob5H9d2Bwm3DrbYPWl6JjpJrt6P7DYN/U2j+nS/dZSn
 /LDwXIQQj16chldtFTPxjidw/dFbmgU9XBJs7SrkghaMh0kKujyEek/xLFHcnuONW0Mhn5SHL01
 5kMIEx9MCs1KRZUzxOwvdfsLoOdDzMMyH3IyA8PBbfx1SbFHXcVGJtyQG9HlZsgT5Rw9qxPs1NF
 VNlmM/oA5RAqgxsAXgiAH9yBJIYbAur6ka0e7Q==
X-Google-Smtp-Source: AGHT+IFvXFVyaoDUyeEj4D30w8gIb//BwctyJ69V9gJGKovRjJ/LwXb2E+1dNitnpP1jGFhagdyL2Q==
X-Received: by 2002:a05:6402:40c9:b0:5d0:efaf:fb73 with SMTP id
 4fb4d7f45d1cf-5dc5efc5baamr19663880a12.15.1738481627978; 
 Sat, 01 Feb 2025 23:33:47 -0800 (PST)
Received: from smtpclient.apple ([178.19.96.90])
 by smtp.gmail.com with ESMTPSA id
 4fb4d7f45d1cf-5dc723e4c8esm5465219a12.23.2025.02.01.23.33.46
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
 Sat, 01 Feb 2025 23:33:47 -0800 (PST)
From: Alexey Lyahkov <alexey.lyashkov@gmail.com>
Message-Id: <6D210CD5-5748-4CB3-841B-E50FFF56A23F@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3776.700.51.11.1\))
Date: Sun, 2 Feb 2025 10:33:34 +0300
In-Reply-To: <173845071649.22054.5753395310812419468@noble.neil.brown.name>
To: NeilBrown <neilb@suse.de>
References: <660D26F8-92F1-45AD-803A-5AD47988640E@gmail.com>
 <173845071649.22054.5753395310812419468@noble.neil.brown.name>
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
Content-Type: multipart/mixed; boundary="===============0105826723977736720=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>


--===============0105826723977736720==
Content-Type: multipart/alternative;
	boundary="Apple-Mail=_5C24FC01-8311-44CA-AD85-5B7304ECE9E0"


--Apple-Mail=_5C24FC01-8311-44CA-AD85-5B7304ECE9E0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8



> On 2 Feb 2025, at 01:58, NeilBrown <neilb@suse.de> wrote:
>=20
> On Thu, 30 Jan 2025, Alexey Lyahkov wrote:
>>=20
>>=20
>>> On 29 Jan 2025, at 22:00, Day, Timothy <timday@amazon.com> wrote:
>>>=20
>>>>>>> That's why we'll
>>>>>>> still support running latest Lustre on older distros. =
Specifically, it'll be the Lustre
>>>>>>> code from a mainline kernel combined with our lustre_compat/ =
compatibility
>>>>>>> code. So normal Lustre releases will be derived directly from =
the in-tree kernel
>>>>>>> code. This provides a path for vendors to deploy bug fixes, =
custom features, and
>>>>>>> allows users to optionally run the latest and greatest Lustre =
code.
>>>>>>=20
>>>>>> And OOPS. Both codes (in-kernel and out-of-tree) have a same sort =
of defines in config.h which have conflicts with building for =
out-of-free Lustre.
>>>>>> Some examples for MOFED hacks to solve same problem you can see =
in the o2iblnd:
>>>>>>>>>=20
>>>>>> #if defined(EXTERNAL_OFED_BUILD) && =
!defined(HAVE_OFED_IB_DMA_MAP_SG_SANE)
>>>>>> #undef CONFIG_INFINIBAND_VIRT_DMA
>>>>>> #endif
>>>>>>>>>=20
>>>>>> As I remember this problem broke an ability to build a lustre as =
out-of-tree kernel on the ubuntu 18.06 with lustre in staging/.
>>>>>=20
>>>>> I think we should be able to validate the Lustre still builds as =
an
>>>>> out-of-tree module by re-using a lot of the testing we already
>>>>> do today in Jenkins/Maloo.
>>>>=20
>>>> Yes. Me do. But it needs many extra resources. Did Amazon ready to =
provide such HW resources for it?
>>>> Or who will be pay for it? It=E2=80=99s cost of the moving to the =
kernel.
>>>=20
>>> I suppose I disagree that this testing requires many extra
>>> resources. This is just validate the same things we validate
>>> today (i.e. that Lustre is functional on RHEL kernels). But the
>>> build process looks different.
>>>=20
>> Ah. So you don=E2=80=99t expect to do any performance testing?
>> Performance testing needs a 20 nodes cluster with IB HDR network =
(400G) and E1000 with NVMe drives as minimal.=20
>> Otherwise servers / network will be bottleneck.
>> And week or so for load to be sure no regression exist. Some problems =
can found just with 48h continuas load.
>> And that is minimal performance testing.
>> I don=E2=80=99t say about scale testing with 100+ client nodes.
>> You think we needs to drop it? If no - who will provide HW for such =
testing.
>=20
> We at SUSE have performance team.  We do some testing on upstream
> because that guards our future, but (I believe) we do most testing on
> our own releases to ensure we don't regress and to find problems =
before
> our customers.  The key observation is that Linus' upstream kernel
> doesn't have to be perfect.  There are regressions all the time.  That
> is why we have the -stable trees.  That is how distros like SUSE and
> Redhat make money.
>=20
Thanks, I know it. RedHat and SuSe makes unusable kernel in upstream and =
take a money to make it better.


> Yes, we want to be doing correctness and performance testing on
> mainline, but we don't need to ensure we block any regressions.  We =
only
> need to eventually find regressions and then fix them.  Hopefully we
> find and fix before the regression gets to any of our customers =
(though
> it reality our customers find quite a few of our regressions).

So
1) Lustre perf team needs more work - to have run performance testing on =
mainstream, and LTS branches. To find a regressions.
2) Lustre developers needs to look to these regressions, and fix this =
time to time.
3) Once it=E2=80=99s not blocking for quality, Lustre client quality is =
poor for linux kernel, bugs and performance issues. It blocked to use =
this from kernel mainline.
4) and Lustre client and server separation introduce a problems with =
development.

(1) - mean extra peoples needs hired and extra HW needs to involve.
(2,4) - extra peoples needs hire.
(3) - any real customer still needs to use Lustre from repository =
outside of linux kernel, so lustre code in the linux kernel don=E2=80=99t =
used in the real production.
If no=20

What is benefits to spent these money ? Just avoid some non priority =
task with porting to the new kernel which needs to be done onece per =
several years.
(When new SuSe or RedHat release created).

It looks anyone don=E2=80=99t understand - Lustre porting to the new =
kernel not so hard work and not a priority. Single problem remember from =
begin - just change page to folio.
Lustre have inside own MM stack, once it designed to work on the =
different platforms - MacOS, Windows /yes, in some private branch had =
Windows native client but it for Lustre 2.1 as I remember/, FreeBSD=E2=80=A6=
. Currently large portion of compatibility and portability code had =
removed after first  step to moving to kernel upstream.
But again - Lustre have own page tree, own paging daemon, for server =
side it have own =E2=80=98VFS=E2=80=99 stack on MD servers, and own data =
path with preallocated page buffer on OST. It have own network stack =
(LNet) with own routing / forwarding and protocol conversions (LNet =
router).
But problems related to cache coherency between clients, distributed =
transactions for MD - much harder.


>>=20
>>=20
>>>>> All we'd need to do it kick off test/build
>>>>> sessions once the merge window closes. Based on the MOFED
>>>>> example you gave, it seems like this is solvable.
>>>>=20
>>>> Sure, All can be solved. But what are cost for this and cost for =
support these changes?
>>>> And next question - who will pay for this cost? Who will provide an =
HW for extra testing?
>>>> So second face of =E2=80=9Cno cost for kernel API changes=E2=80=9D =
- it will be a problems with back porting these changes and extra =
testing.
>>>=20
>>> I don't think the backporting will be more burdensome
>>> than porting Lustre to new kernels. And we don't have to
>>> urgently backport each upstream release to older kernels.
>> Neil B, say we needs to move all development to the mainstream.  =
It=E2=80=99s
>> mean kernel upstream will be same as =E2=80=98master=E2=80=99 branch =
now.
>> So each change needs to be back ported to older kernels to sync with
>> servers work and make ready for lustre release.
>> Otherwise we will have a ton changes needs to be backported on each
>> lustre release.=20
>> I see no differences with porting to upstream, except this porting
>> from mainline to old kernels should be handled ASAP do avoid lustre
>> release delay, while porting to the mainstream may delayed as it not
>> critical for customers.
>=20
> Porting to upstream doesn't work.  The motivation isn't strong enough
> and people leave it then forget it and you get too much divergence and
> it become harder so people do it even less.  People have tried.  =
People
> have failed.
>=20
Porting to upstream had work for last 20years from product start.
Yes, this is not for each kernel release, but it=E2=80=99s don=E2=80=99t =
needs.



> Backporting from upstream to an older kernel isn't that hard. =20
> I do a
> lot of it and with the right tools it is mostly easy.  One of the
> biggest difficulties is when we try to backport only a selection of
> patches because we might miss an important dependency.  Sometimes it =
is
> worth it to avoid churn, sometime it is best to apply everything
> relevant.  I assume that for the selection of kernels that whamcloud =
(or
> whoever) want to support, they would backport everything that could
> apply.  I think that would be largely mechanical.
>=20
> Maybe it would be good for me to paint a more details picture of what =
I
> imagine would happen - assuming we do take the path of landing all of
> lustre, both client and server, upstream.
>=20
> - we would change the kernel code in lustre-release so that it was
>  exactly what we plan to submit upstream.
> - we submit it and once accepted we have identical code in upstream
>  linux and lustre-release
> - we fork lustre-release to a new package called (e.g.) lustre-tools =
and=20
>  remove all kernel code leaving just utils and documentation and=20
>  test code.  The kinode.c kernel module that is in =
lustre/tests/kernel/
>  would need to go upstream with the rest of the kernel code I think.
>  lustre-tools would be easily accessible and buildable by anyone who
>  wants to test lustre
> - we fork lustre-release to another new package lustre-backports
>  and remove all non-kernel code from there.  We configure it to build
>  out-of-tree modules with names like "backport-lustre" "backport-lnet"
>  and provide modprobe.conf files that alias the standard names to
>  these.  That should allow to over-ride the distributed modules (if
>  any) when people choose to use backports.
> - upstream commits which touch lustre or lnet are automatically add to
>  lustre-backports and someone is notified to help when they don't =
apply
>=20
> With this:
> Anyone who wants to test or use the lustre included with a particular
> kernel can do with with only the lustre-tools package.  Anyone who
> wants to use the latest lustre code with an older kernel can build and
> use lustre-backports.
>=20
> There are probably rough-edges with this but I suspect they can be =
filed
> down.
>=20
> thanks,
> NeilBrown


--Apple-Mail=_5C24FC01-8311-44CA-AD85-5B7304ECE9E0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=utf-8

<html><head><meta http-equiv=3D"content-type" content=3D"text/html; =
charset=3Dutf-8"></head><body style=3D"overflow-wrap: break-word; =
-webkit-nbsp-mode: space; line-break: after-white-space;"><br =
id=3D"lineBreakAtBeginningOfMessage"><div><br><blockquote =
type=3D"cite"><div>On 2 Feb 2025, at 01:58, NeilBrown =
&lt;neilb@suse.de&gt; wrote:</div><br =
class=3D"Apple-interchange-newline"><div><meta charset=3D"UTF-8"><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;">On Thu, 30 Jan 2025, Alexey Lyahkov =
wrote:</span><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;"><blockquote type=3D"cite" style=3D"font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: 400; letter-spacing: normal; orphans: auto; text-align: =
start; text-indent: 0px; text-transform: none; white-space: normal; =
widows: auto; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><br><br><blockquote type=3D"cite">On 29 Jan =
2025, at 22:00, Day, Timothy &lt;timday@amazon.com&gt; =
wrote:<br><br><blockquote type=3D"cite"><blockquote =
type=3D"cite"><blockquote type=3D"cite"><blockquote type=3D"cite">That's =
why we'll<br>still support running latest Lustre on older distros. =
Specifically, it'll be the Lustre<br>code from a mainline kernel =
combined with our lustre_compat/ compatibility<br>code. So normal Lustre =
releases will be derived directly from the in-tree kernel<br>code. This =
provides a path for vendors to deploy bug fixes, custom features, =
and<br>allows users to optionally run the latest and greatest Lustre =
code.<br></blockquote><br>And OOPS. Both codes (in-kernel and =
out-of-tree) have a same sort of defines in config.h which have =
conflicts with building for out-of-free Lustre.<br>Some examples for =
MOFED hacks to solve same problem you can see in the =
o2iblnd:<br><blockquote type=3D"cite"><blockquote =
type=3D"cite"><blockquote =
type=3D"cite"><br></blockquote></blockquote></blockquote>#if =
defined(EXTERNAL_OFED_BUILD) &amp;&amp; =
!defined(HAVE_OFED_IB_DMA_MAP_SG_SANE)<br>#undef =
CONFIG_INFINIBAND_VIRT_DMA<br>#endif<br><blockquote =
type=3D"cite"><blockquote type=3D"cite"><blockquote =
type=3D"cite"><br></blockquote></blockquote></blockquote>As I remember =
this problem broke an ability to build a lustre as out-of-tree kernel on =
the ubuntu 18.06 with lustre in staging/.<br></blockquote><br>I think we =
should be able to validate the Lustre still builds as an<br>out-of-tree =
module by re-using a lot of the testing we already<br>do today in =
Jenkins/Maloo.<br></blockquote><br>Yes. Me do. But it needs many extra =
resources. Did Amazon ready to provide such HW resources for it?<br>Or =
who will be pay for it? It=E2=80=99s cost of the moving to the =
kernel.<br></blockquote><br>I suppose I disagree that this testing =
requires many extra<br>resources. This is just validate the same things =
we validate<br>today (i.e. that Lustre is functional on RHEL kernels). =
But the<br>build process looks different.<br><br></blockquote>Ah. So you =
don=E2=80=99t expect to do any performance testing?<br>Performance =
testing needs a 20 nodes cluster with IB HDR network (400G) and E1000 =
with NVMe drives as minimal.<span =
class=3D"Apple-converted-space">&nbsp;</span><br>Otherwise servers / =
network will be bottleneck.<br>And week or so for load to be sure no =
regression exist. Some problems can found just with 48h continuas =
load.<br>And that is minimal performance testing.<br>I don=E2=80=99t say =
about scale testing with 100+ client nodes.<br>You think we needs to =
drop it? If no - who will provide HW for such =
testing.<br></blockquote><br style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><span style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;">We at =
SUSE have performance team. &nbsp;We do some testing on =
upstream</span><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;"><span style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;">because that guards our =
future, but (I believe) we do most testing on</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;"><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;">our own releases to ensure we don't regress =
and to find problems before</span><br style=3D"caret-color: rgb(0, 0, =
0); font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><span style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;">our =
customers. &nbsp;The key observation is that Linus' upstream =
kernel</span><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;"><span style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;">doesn't have to be =
perfect. &nbsp;There are regressions all the time. &nbsp;That</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;"><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;">is why we have the -stable trees. =
&nbsp;That is how distros like SUSE and</span><br style=3D"caret-color: =
rgb(0, 0, 0); font-family: Helvetica; font-size: 12px; font-style: =
normal; font-variant-caps: normal; font-weight: 400; letter-spacing: =
normal; text-align: start; text-indent: 0px; text-transform: none; =
white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><span style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;">Redhat =
make money.</span><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;"><br style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;"></div></blockquote><div>Thanks, I know it. RedHat and SuSe makes =
unusable kernel in upstream and take a money to make it =
better.</div><div><br></div><div><br></div><blockquote =
type=3D"cite"><div><span style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;">Yes, we =
want to be doing correctness and performance testing on</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;"><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;">mainline, but we don't need to ensure we =
block any regressions. &nbsp;We only</span><br style=3D"caret-color: =
rgb(0, 0, 0); font-family: Helvetica; font-size: 12px; font-style: =
normal; font-variant-caps: normal; font-weight: 400; letter-spacing: =
normal; text-align: start; text-indent: 0px; text-transform: none; =
white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><span style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;">need to =
eventually find regressions and then fix them. &nbsp;Hopefully =
we</span><br style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;"><span style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;">find and fix before the =
regression gets to any of our customers (though</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;"><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;">it reality our customers find quite a few =
of our =
regressions).</span></div></blockquote><div><br></div><div>So</div><div>1)=
 Lustre perf team needs more work - to have run performance testing on =
mainstream, and LTS branches. To find a regressions.</div><div>2) Lustre =
developers needs to look to these regressions, and fix this time to =
time.</div><div>3) Once it=E2=80=99s not blocking for quality, Lustre =
client quality is poor for linux kernel, bugs and performance issues. It =
blocked to use this from kernel mainline.</div><div>4) and Lustre client =
and server separation introduce a problems with =
development.</div><div><br></div><div>(1) - mean extra peoples needs =
hired and extra HW needs to involve.</div><div>(2,4) - extra peoples =
needs hire.</div><div>(3) - any real customer still needs to use Lustre =
from repository outside of linux kernel, so lustre code in the linux =
kernel don=E2=80=99t used in the real production.</div><div>If =
no&nbsp;</div><div><br></div><div>What is benefits to spent these money =
? Just avoid some non priority task with porting to the new kernel which =
needs to be done onece per several years.</div><div>(When new SuSe or =
RedHat release created).</div><div><br></div><div>It looks anyone =
don=E2=80=99t understand - Lustre porting to the new kernel not so hard =
work and not a priority. Single problem remember from begin - just =
change page to folio.</div><div>Lustre have inside own MM stack, once it =
designed to work on the different platforms - MacOS, Windows /yes, in =
some private branch had Windows native client but it for Lustre 2.1 as I =
remember/, FreeBSD=E2=80=A6. Currently large portion of compatibility =
and portability code had removed after first &nbsp;step to moving to =
kernel upstream.</div><div>But again - Lustre have own page tree, own =
paging daemon, for server side it have own =E2=80=98VFS=E2=80=99 stack =
on MD servers, and own data path with preallocated page buffer on OST. =
It have own network stack (LNet) with own routing / forwarding and =
protocol conversions (LNet router).</div><div>But problems related to =
cache coherency between clients, distributed transactions for MD - much =
harder.</div><div><br></div><div><br></div><blockquote =
type=3D"cite"><div><blockquote type=3D"cite" style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: 400; letter-spacing: normal; orphans: auto; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; widows: auto; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><br><br><blockquote type=3D"cite"><blockquote =
type=3D"cite"><blockquote type=3D"cite">All we'd need to do it kick off =
test/build<br>sessions once the merge window closes. Based on the =
MOFED<br>example you gave, it seems like this is =
solvable.<br></blockquote><br>Sure, All can be solved. But what are cost =
for this and cost for support these changes?<br>And next question - who =
will pay for this cost? Who will provide an HW for extra testing?<br>So =
second face of =E2=80=9Cno cost for kernel API changes=E2=80=9D - it =
will be a problems with back porting these changes and extra =
testing.<br></blockquote><br>I don't think the backporting will be more =
burdensome<br>than porting Lustre to new kernels. And we don't have =
to<br>urgently backport each upstream release to older =
kernels.<br></blockquote>Neil B, say we needs to move all development to =
the mainstream. &nbsp;It=E2=80=99s<br>mean kernel upstream will be same =
as =E2=80=98master=E2=80=99 branch now.<br>So each change needs to be =
back ported to older kernels to sync with<br>servers work and make ready =
for lustre release.<br>Otherwise we will have a ton changes needs to be =
backported on each<br>lustre release.<span =
class=3D"Apple-converted-space">&nbsp;</span><br>I see no differences =
with porting to upstream, except this porting<br>from mainline to old =
kernels should be handled ASAP do avoid lustre<br>release delay, while =
porting to the mainstream may delayed as it not<br>critical for =
customers.<br></blockquote><br style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><span style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;">Porting =
to upstream doesn't work. &nbsp;The motivation isn't strong =
enough</span><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;"><span style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;">and people leave it then =
forget it and you get too much divergence and</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;"><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;">it become harder so people do it even less. =
&nbsp;People have tried. &nbsp;People</span><br style=3D"caret-color: =
rgb(0, 0, 0); font-family: Helvetica; font-size: 12px; font-style: =
normal; font-variant-caps: normal; font-weight: 400; letter-spacing: =
normal; text-align: start; text-indent: 0px; text-transform: none; =
white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><span style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;">have =
failed.</span><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;"><br></div></blockquote><div>Porting to upstream had work for last =
20years from product start.</div><div>Yes, this is not for each kernel =
release, but it=E2=80=99s don=E2=80=99t =
needs.</div><div><br></div><div><br></div><br><blockquote =
type=3D"cite"><div><span style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline =
!important;">Backporting from upstream to an older kernel isn't that =
hard. &nbsp;</span></div></blockquote><blockquote type=3D"cite"><div><span=
 style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;">I do a</span><br style=3D"caret-color: =
rgb(0, 0, 0); font-family: Helvetica; font-size: 12px; font-style: =
normal; font-variant-caps: normal; font-weight: 400; letter-spacing: =
normal; text-align: start; text-indent: 0px; text-transform: none; =
white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><span style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;">lot of =
it and with the right tools it is mostly easy. &nbsp;One of =
the</span><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;"><span style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;">biggest difficulties is =
when we try to backport only a selection of</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;"><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;">patches because we might miss an important =
dependency. &nbsp;Sometimes it is</span><br style=3D"caret-color: rgb(0, =
0, 0); font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><span style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;">worth =
it to avoid churn, sometime it is best to apply everything</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;"><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;">relevant. &nbsp;I assume that for the =
selection of kernels that whamcloud (or</span><br style=3D"caret-color: =
rgb(0, 0, 0); font-family: Helvetica; font-size: 12px; font-style: =
normal; font-variant-caps: normal; font-weight: 400; letter-spacing: =
normal; text-align: start; text-indent: 0px; text-transform: none; =
white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><span style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline =
!important;">whoever) want to support, they would backport everything =
that could</span><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;"><span style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;">apply. &nbsp;I think =
that would be largely mechanical.</span><br style=3D"caret-color: rgb(0, =
0, 0); font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><br style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><span style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;">Maybe =
it would be good for me to paint a more details picture of what =
I</span><br style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;"><span style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;">imagine would happen - =
assuming we do take the path of landing all of</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;"><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;">lustre, both client and server, =
upstream.</span><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;"><br style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;"><span style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;">- we would change the =
kernel code in lustre-release so that it was</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;"><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;">&nbsp;exactly what we plan to submit =
upstream.</span><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;"><span style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;">- we submit it and once =
accepted we have identical code in upstream</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;"><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;">&nbsp;linux and lustre-release</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;"><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;">- we fork lustre-release to a new package =
called (e.g.) lustre-tools and<span =
class=3D"Apple-converted-space">&nbsp;</span></span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;"><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;">&nbsp;remove all kernel code leaving just =
utils and documentation and<span =
class=3D"Apple-converted-space">&nbsp;</span></span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;"><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;">&nbsp;test code. &nbsp;The kinode.c kernel =
module that is in lustre/tests/kernel/</span><br style=3D"caret-color: =
rgb(0, 0, 0); font-family: Helvetica; font-size: 12px; font-style: =
normal; font-variant-caps: normal; font-weight: 400; letter-spacing: =
normal; text-align: start; text-indent: 0px; text-transform: none; =
white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><span style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline =
!important;">&nbsp;would need to go upstream with the rest of the kernel =
code I think.</span><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;"><span style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;">&nbsp;lustre-tools would =
be easily accessible and buildable by anyone who</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;"><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;">&nbsp;wants to test lustre</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;"><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;">- we fork lustre-release to another new =
package lustre-backports</span><br style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><span style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline =
!important;">&nbsp;and remove all non-kernel code from there. &nbsp;We =
configure it to build</span><br style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><span style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline =
!important;">&nbsp;out-of-tree modules with names like "backport-lustre" =
"backport-lnet"</span><br style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><span style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline =
!important;">&nbsp;and provide modprobe.conf files that alias the =
standard names to</span><br style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><span style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline =
!important;">&nbsp;these. &nbsp;That should allow to over-ride the =
distributed modules (if</span><br style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><span style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline =
!important;">&nbsp;any) when people choose to use backports.</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;"><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;">- upstream commits which touch lustre or =
lnet are automatically add to</span><br style=3D"caret-color: rgb(0, 0, =
0); font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><span style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline =
!important;">&nbsp;lustre-backports and someone is notified to help when =
they don't apply</span><br style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><br style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><span style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;">With =
this:</span><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;"><span style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;">Anyone who wants to test =
or use the lustre included with a particular</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;"><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;">kernel can do with with only the =
lustre-tools package. &nbsp;Anyone who</span><br style=3D"caret-color: =
rgb(0, 0, 0); font-family: Helvetica; font-size: 12px; font-style: =
normal; font-variant-caps: normal; font-weight: 400; letter-spacing: =
normal; text-align: start; text-indent: 0px; text-transform: none; =
white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><span style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;">wants =
to use the latest lustre code with an older kernel can build =
and</span><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;"><span style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;">use =
lustre-backports.</span><br style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><br style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><span style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;">There =
are probably rough-edges with this but I suspect they can be =
filed</span><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;"><span style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: 400; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;">down.</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;"><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;"><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: 400; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;">thanks,</span><br style=3D"caret-color: =
rgb(0, 0, 0); font-family: Helvetica; font-size: 12px; font-style: =
normal; font-variant-caps: normal; font-weight: 400; letter-spacing: =
normal; text-align: start; text-indent: 0px; text-transform: none; =
white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;"><span style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: 400; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline =
!important;">NeilBrown</span></div></blockquote></div><br></body></html>=

--Apple-Mail=_5C24FC01-8311-44CA-AD85-5B7304ECE9E0--

--===============0105826723977736720==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============0105826723977736720==--
