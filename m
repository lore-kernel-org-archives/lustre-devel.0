Return-Path: <SRS0=N6kG=GZ=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.4 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	PDS_BAD_THREAD_QP_64,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E3FEC433E0
	for <lustre-devel@archiver.kernel.org>; Fri, 22 Jan 2021 07:14:46 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 1680122D50
	for <lustre-devel@archiver.kernel.org>; Fri, 22 Jan 2021 07:14:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1680122D50
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=whamcloud.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9CEAD328E56;
	Thu, 21 Jan 2021 23:14:44 -0800 (PST)
Received: from NAM10-MW2-obe.outbound.protection.outlook.com
 (mail-mw2nam10on2063.outbound.protection.outlook.com [40.107.94.63])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A5F70328CA0
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 23:14:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=Ea0RKcoBn9A1cRhXAHrcAcIyMd/UwuyoCuYuDrKu+SE+2Ia7MXIpqClnaaqiu1XXuE9kUFMvBhKfvrmYS1MQh2pDXMRvA6NNZp1VuHpvFRhdFNrs1ORRri0E/pAXRXvipUcSEgF1D9d4ZxliW9woZ75+WPDsMHLIKN8BfX9Z/Dk5RjOUvIqhyMenr+cezVbM9mCkHvTA/AZbjxnr47ejLyc4VibgFKHZAtMWtejqZ3sij3deSjiF+lgLlxv4W4ugNOOfKFa5gaF6DRE8zJJCXC2oKZl+YYYKJA6akJhgW/TPbFYwQK0aUe7YrtD0BFfDA2TKF5GzcDYMwMMWvDGc/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=FLW/jpFrgP0k+iAqAGhkD5E9NRODlmGsZfpE3lGJRNo=;
 b=EBT4rzijkwqj7sKj1GpUOCEmaIiKCPClh5dAg22rLMYzhgncXEVNOKBn+BwzBqLFFOUVrNTvbWukYqAPy2HktwMgLQxHnf7m86EGZmOfCzM3kjJN2WVgtghivZozEqGRtSThZaeFr5FG5bcGPB4GlRkl71hRQRYh4O7/+x35+uaz1k+xZ5IzmVe1Hx5Z1gobYTwKGDcUpEVdeTPPb906yUYENEuJk4satFhIPUOXupYWfhrQ+PWDarLGff6jD6gb8sOBzIsqeiVlFufE0lmGHL01xnMgz9IgVQu+P1HSnkRawZdGF7raiM+Yab//TIS04qocefXPoEJngyscgn3eZA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=FLW/jpFrgP0k+iAqAGhkD5E9NRODlmGsZfpE3lGJRNo=;
 b=bfY2bjukTBLIA2uzhLfY6/Op11XGqO5ezrCPKLpe2EmTa6iW62fUQJZlPQ9qDjnkJqsiSuYzpvYixaF7NIeXsNvISahJlMYJLnN/lEJIxOeJty8DUOshwFA3G/Eb9Zs1ni67lK8qwKHPOGk6Hth2BgWIkrtT4zIadeT6Jg8FLy0=
Received: from MN2PR19MB3662.namprd19.prod.outlook.com (2603:10b6:208:193::28)
 by BLAPR19MB4595.namprd19.prod.outlook.com (2603:10b6:208:299::10)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.3784.13; Fri, 22 Jan
 2021 07:14:39 +0000
Received: from MN2PR19MB3662.namprd19.prod.outlook.com
 ([fe80::944:8292:35d7:98ca]) by MN2PR19MB3662.namprd19.prod.outlook.com
 ([fe80::944:8292:35d7:98ca%7]) with mapi id 15.20.3784.012; Fri, 22 Jan 2021
 07:14:39 +0000
From: Andreas Dilger <adilger@whamcloud.com>
To: James Simmons <jsimmons@casper.infradead.org>
Thread-Topic: [lustre-devel] Using generic radix trees for large allocations
Thread-Index: AQHW8CPbnCR3GC5dOUu/y014JPh8ZqozPDUA
Date: Fri, 22 Jan 2021 07:14:39 +0000
Message-ID: <C8588A51-61AD-41C4-A41E-9263CF66B1DF@whamcloud.com>
References: <20210121183224.GA4134678@casper.infradead.org>
In-Reply-To: <20210121183224.GA4134678@casper.infradead.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: casper.infradead.org; dkim=none (message not signed)
 header.d=none;casper.infradead.org; dmarc=none action=none
 header.from=whamcloud.com;
x-originating-ip: [70.77.221.9]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: d6c5d350-12ba-4304-193c-08d8bea561be
x-ms-traffictypediagnostic: BLAPR19MB4595:
x-microsoft-antispam-prvs: <BLAPR19MB4595DAE3AA8D1FC63F7436DEA7A09@BLAPR19MB4595.namprd19.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: pSkrz2XDqSfRlOZI8niTGYjGsK6aR2Iy4gFxjNVwQwSyoTb/gHZqHNOsb/ZzUwxc2+uL7f66AAl+sFJlpgU+Hw4sNJf37k6wuH0KMiAryVhIoj59Sns5tTXU2gRWT4n17FFMuXyGloG457fo1GKc/G5rgqqZk+F00qFjz9TF4GsmFOmvAVWsX0ygPJ+m4ClnMUpnUH00BOoJbogGi+50Aths1NcQlletY2MxgKq1o2/LvRRmkGyrdbs+EmsJMScSiOICJJBAFzNGGj0V8NRfqw1ROst2uA9XAiu6dl9uKZ14K8LX6tWkRM/6GX98z7qbVPV2ol+CHMCucdNwaJeZEUS/YSw9aTpPHFBTpEQ75MCW6w/aWs+Z1znLlMoV5a6+nwsPB8P0dG6Xxu1KxMGmxlQAJI7EHxoB+ddifIidOxkRcLLpm9hV9UExQG59qProiiaX7HPT7DMV3g8nUDg7us8LT79iDM/D/ZUfjPM6DuXW/BaiO6mksMSW1wbcLkcG4Qt6z6Tx+9fQrqGSqy/qLbpTtsSSaPpflfNXlYijlTrwTdqlReTMJlaQu5KCRX95CydOSiqGZuLt7lVElzu0dQ==
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MN2PR19MB3662.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(4636009)(366004)(39850400004)(376002)(396003)(346002)(136003)(6512007)(2906002)(166002)(2616005)(6506007)(21615005)(478600001)(8676002)(186003)(83380400001)(53546011)(26005)(6916009)(316002)(64756008)(66446008)(33656002)(966005)(71200400001)(6486002)(66476007)(91956017)(66556008)(4326008)(76116006)(66946007)(5660300002)(86362001)(36756003)(8936002)(13693001)(41533002)(45980500001);
 DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata: =?us-ascii?Q?sGHZTKYRoPdv3vs0Ay1wo7+IRKycP5HXKWu7MulQPdUkRL+v0fY1wpNG91RQ?=
 =?us-ascii?Q?5r/qA4SuZImtLhWXyBgUBZKcMfeaBK5kAg4x0r0Itrn7F772tPpLIIoTllw0?=
 =?us-ascii?Q?PaA++s0R/lRaRzIAiKxL3yTDAAGE81EB4pBore79bhzNvD2y86etoHj2D7fE?=
 =?us-ascii?Q?wWp6XkSUBU84ha+JLulDm63JFeek0Wi0MJiHmaXzpNWfv5b9V5TKKe6dwkk+?=
 =?us-ascii?Q?q2dnebYU9WX2IpemhbKzYo+mum2GBjJWFleSBMz8YxyYCcKmL1KIpFlZKgUA?=
 =?us-ascii?Q?3pjYNs+RYMwCUBYSrQy/XpqbfuI1i4ygPsGLiROB2PTVlj3SMA6v4BlTEqbZ?=
 =?us-ascii?Q?lfi60Zj0WuJfVx91CFioUBlq/npRqwyUdowV9CSqwoMJP8bHC1U0Y0FX1D5d?=
 =?us-ascii?Q?3oicYocSyW49hP8ojb4yx7bLWL3ASwPfYwJCCEgfQQ+27DDKV1DJBLBjcUMD?=
 =?us-ascii?Q?IcYsW4gnIokllOJbyMlXAmlVMTs9KuxK7uGUhlyiKE31FfNXSitv2N96iTzy?=
 =?us-ascii?Q?8+nnqCexfTN2hx+mcRJiyWCueizNFQEzNCuD//fW160wUrFsJByoQHdmM559?=
 =?us-ascii?Q?WLctFu3mEyN8CC6ijAUNeK9yucJlHS7fUbOsgwWAq3fuMXERRykzaMcYR2Bd?=
 =?us-ascii?Q?bY1qnoP4gtkVSfVQoIzcoD8l1aWmnz1EtCghEjJeQVTpo+bxUZyvfoQJS6QV?=
 =?us-ascii?Q?DcKgChEnILbfrdzzo8TT8YTir8diypKO2f+t4RmUX9WkfxjH2HmYpZFBzum3?=
 =?us-ascii?Q?t4+77kU3O1iV/PcRGJOW0TF8CagJMfDk2yD05Pk+HedHSysuDz7lZZZ9EByo?=
 =?us-ascii?Q?Wp5lk9MAjVWQaxEcyrJUJgPOJa6rCE5pj67AAz53HB79TnYnRs4huPDLUwdm?=
 =?us-ascii?Q?kbZZUWDuCp3NL75O5NvB2bPdbC8MhNmqQHLJrCEVvl+ksJETuhsOuw3avl4q?=
 =?us-ascii?Q?dj/NOEbH4Y+cREDg26SfUhthlDQpM/INFvn3kFfcPIl+bKiNji1g1jmzcL5W?=
 =?us-ascii?Q?ufNH?=
x-ms-exchange-transport-forked: True
MIME-Version: 1.0
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MN2PR19MB3662.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: d6c5d350-12ba-4304-193c-08d8bea561be
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Jan 2021 07:14:39.0925 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: bGRUQOlzGixIuqaF74zQlmWSIVhB3KNsD6BGzc5hSpFBkVo+Wl8Zn0jqWyD53VMw
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BLAPR19MB4595
Subject: Re: [lustre-devel] Using generic radix trees for large allocations
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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
Cc: Lustre-devel <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============7847252238094375253=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============7847252238094375253==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_C8588A5161AD41C4A41E9263CF66B1DFwhamcloudcom_"

--_000_C8588A5161AD41C4A41E9263CF66B1DFwhamcloudcom_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

On Jan 21, 2021, at 11:32, James Simmons <jsimmons@casper.infradead.org<mai=
lto:jsimmons@casper.infradead.org>> wrote:

 One of the challenging issues for very large scale file systems is the
performance crash when you cross about 670 stripe count. This is due to
the memory allocations going from kmalloc to vmalloc. Once you start to
use vmalloc to allocate the ptlrpc message buffers all the allocating
start to serialize on a global spinlock.
 Looking for a solution the best one I found so far have been using the
generic radix tree API. You have to allocate a page worth of data at a
time so its cluncky for use but I think we could make it work. What do
you think?

https://www.kernel.org/doc/html/latest/core-api/generic-radix-tree.html

I think the first thing to figure out here is whether vmalloc() of the repl=
y buffer is
the problem for sure.  670 stripes is only a 16KB layout, which I'd think w=
ould be
handled by kmalloc() almost all of the time, unless memory is very fragment=
ed.
It would also be worthwhile to see if the __GFP_ZERO of this allocation is =
a
source of performance problems?  While I wouldn't recommend to disable this
to start, at least checking if memset() shows up in the profile would be us=
eful.

I definitely recall some strangeness in the MDT reply code for very large r=
eplies
that may mean it is retrying the message if it is too large on the first se=
nd.
There are probably some improvements to commit v2_5_56_0-71-g006f258300
"LU-3338 llite: Limit reply buffer size" to better chose the reply buffer s=
ize if large
layouts are commonly returned. I think it just bails and limits the layout =
buffer to
a max of PAGE_SIZE or similar, instead of having a better algorithm.


In times gone by, we also had a patch to improve vmalloc() performance, but
unfortunately they were rejected upstream because "we don't want developers
using vmalloc() and if the performance is bad they will avoid it", or simil=
ar.

Now that kvmalloc() is a widey-used interface in the code, maybe improving
vmalloc() performance is of interest again (i.e. removing the single global=
 lock)?
One simple optimization was to linearly use the vmalloc address space from
start to end, instead of trying to have a "smart" usage of the address spac=
e.  It
is 32TiB in size, so takes a while to exhaust (probably several days under =
normal
usage), so the first pass through is "free".


It isn't clear to me what your goal with the radix tree is?  Do you intend =
to replace
vmalloc() usage in Lustre with a custom memory allocator based on this, or =
is the
goal to optimize the kernel vmalloc() allocation using the radix tree code?

I think the use of a custom memory allocator in Lustre would be far more na=
sty than
lots of the things that are raised as objections to upstream inclusion, so =
I think it
would be a step backward.  Optimizing vmalloc() in upstream kernels (if cha=
nges
are accepted) would be a better use of time.  For the few sites that have m=
any OSTs,
they can afford a kernel patch on the client (likely they have a custom ker=
nel from
their system vendor anyway), and the other 99% of users will not need it.


I think a more practical approach might be to have a pool of preallocated r=
eply
buffers (using vmalloc()) that is kept on the client.  That would avoid the=
 overhead
of vmalloc/vfree each time, and not need intrusive code changes.  In the li=
kely
case of a small layout for a file (even if _some_ layouts are very large), =
the saved
RPC replay buffer can be kmalloc'd normally and copied over.  I don't think=
 there
will be real-world workloads where a client is keeping thousands of differe=
nt files
open with huge layouts, so it is likely that the number of large buffers in=
 the reply
pool will be relatively small.

Cheers, Andreas
--
Andreas Dilger
Principal Lustre Architect
Whamcloud







--_000_C8588A5161AD41C4A41E9263CF66B1DFwhamcloudcom_
Content-Type: text/html; charset="us-ascii"
Content-ID: <44EC223C876F8743B8C7EB64DA24FDA7@namprd19.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
</head>
<body style=3D"word-wrap: break-word; -webkit-nbsp-mode: space; line-break:=
 after-white-space;" class=3D"">
On Jan 21, 2021, at 11:32, James Simmons &lt;<a href=3D"mailto:jsimmons@cas=
per.infradead.org" class=3D"">jsimmons@casper.infradead.org</a>&gt; wrote:<=
br class=3D"">
<div>
<blockquote type=3D"cite" class=3D""><br class=3D"Apple-interchange-newline=
">
<div class=3D"">
<div class=3D"">&nbsp;One of the challenging issues for very large scale fi=
le systems is the<br class=3D"">
performance crash when you cross about 670 stripe count. This is due to<br =
class=3D"">
the memory allocations going from kmalloc to vmalloc. Once you start to<br =
class=3D"">
use vmalloc to allocate the ptlrpc message buffers all the allocating<br cl=
ass=3D"">
start to serialize on a global spinlock.<br class=3D"">
&nbsp;Looking for a solution the best one I found so far have been using th=
e<br class=3D"">
generic radix tree API. You have to allocate a page worth of data at a<br c=
lass=3D"">
time so its cluncky for use but I think we could make it work. What do<br c=
lass=3D"">
you think?<br class=3D"">
<br class=3D"">
<a href=3D"https://www.kernel.org/doc/html/latest/core-api/generic-radix-tr=
ee.html" class=3D"">https://www.kernel.org/doc/html/latest/core-api/generic=
-radix-tree.html</a><br class=3D"">
</div>
</div>
</blockquote>
<br class=3D"">
</div>
<div>I think the first thing to figure out here is whether vmalloc() of the=
 reply buffer is</div>
<div>the problem for sure. &nbsp;670 stripes is only a 16KB layout, which I=
'd think would be</div>
<div>handled by kmalloc() almost all of the time, unless memory is very fra=
gmented.</div>
<div>It would also be worthwhile to see if the __GFP_ZERO of this allocatio=
n is a</div>
<div>source of performance problems? &nbsp;While I wouldn't recommend to di=
sable this</div>
<div>to start, at least checking if memset() shows up in the profile would =
be useful.</div>
<div><br class=3D"">
</div>
<div>I definitely recall some strangeness in the MDT reply code for very la=
rge replies</div>
<div>that may mean it is retrying the message if it is too large on the fir=
st send.</div>
<div>There are probably some improvements to commit v2_5_56_0-71-g006f25830=
0</div>
<div>&quot;LU-3338 llite: Limit reply buffer size&quot; to better chose the=
 reply buffer size if large</div>
<div>layouts are commonly returned. I think it just bails and limits the la=
yout buffer to</div>
<div>a max of PAGE_SIZE or similar, instead of having a better algorithm.</=
div>
<div><br class=3D"">
</div>
<div><br class=3D"">
</div>
<div>In times gone by, we also had a patch to improve vmalloc() performance=
, but</div>
<div>unfortunately they were rejected upstream because &quot;we don't want =
developers</div>
<div>using vmalloc() and if the performance is bad they will avoid it&quot;=
, or similar.</div>
<div><br class=3D"">
</div>
<div>Now that kvmalloc() is a widey-used interface in the code, maybe impro=
ving</div>
<div>vmalloc() performance is of interest again (i.e. removing the single g=
lobal lock)?</div>
<div>One simple optimization was to linearly use the vmalloc address space =
from</div>
<div>start to end, instead of trying to have a &quot;smart&quot; usage of t=
he address space. &nbsp;It</div>
<div>is 32TiB in size, so takes a while to exhaust (probably several days u=
nder normal</div>
<div>usage), so the first pass through is &quot;free&quot;.</div>
<div><br class=3D"">
</div>
<div><br class=3D"">
</div>
<div>It isn't clear to me what your goal with the radix tree is? &nbsp;Do y=
ou intend to replace</div>
<div>vmalloc() usage in Lustre with a custom memory allocator based on this=
, or is the</div>
<div>goal to optimize the kernel vmalloc() allocation using the radix tree =
code?</div>
<div><br class=3D"">
</div>
<div>I think the use of a custom memory allocator in Lustre would be far mo=
re nasty than</div>
<div>lots of the things that are raised as objections to upstream inclusion=
, so I think it</div>
<div>would be a step backward. &nbsp;Optimizing vmalloc() in upstream kerne=
ls (if changes</div>
<div>are accepted) would be a better use of time. &nbsp;For the few sites t=
hat have many OSTs,</div>
<div>they can afford a kernel patch on the client (likely they have a custo=
m kernel from</div>
<div>their system vendor anyway), and the other 99% of users will not need =
it.</div>
<div><br class=3D"">
</div>
<div><br class=3D"">
</div>
<div>I think a more practical approach might be to have a pool of prealloca=
ted reply</div>
<div>buffers (using vmalloc()) that is kept on the client. &nbsp;That would=
 avoid the overhead</div>
<div>of vmalloc/vfree each time, and not need intrusive code changes. &nbsp=
;In the likely</div>
<div>case of a small layout for a file (even if _some_ layouts are very lar=
ge), the saved</div>
<div>RPC replay buffer can be kmalloc'd normally and copied over. &nbsp;I d=
on't think there</div>
<div>will be real-world workloads where a client is keeping thousands of di=
fferent files</div>
<div>open with huge layouts, so it is likely that the number of large buffe=
rs in the reply</div>
<div>pool will be relatively small.</div>
<br class=3D"">
<div class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div>Cheers, Andreas</div>
<div>--</div>
<div>Andreas Dilger</div>
<div>Principal Lustre Architect</div>
<div>Whamcloud</div>
<div><br class=3D"">
</div>
<div><br class=3D"">
</div>
<div><br class=3D"">
</div>
</div>
</div>
</div>
</div>
</div>
<br class=3D"Apple-interchange-newline">
<br class=3D"Apple-interchange-newline">
</div>
<br class=3D"">
</body>
</html>

--_000_C8588A5161AD41C4A41E9263CF66B1DFwhamcloudcom_--

--===============7847252238094375253==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============7847252238094375253==--
