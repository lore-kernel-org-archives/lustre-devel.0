Return-Path: <SRS0=Iqmw=F3=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,MIME_HTML_MOSTLY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34D6AC433DB
	for <lustre-devel@archiver.kernel.org>; Wed, 23 Dec 2020 23:21:22 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id BB52322252
	for <lustre-devel@archiver.kernel.org>; Wed, 23 Dec 2020 23:21:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB52322252
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=whamcloud.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2FD0530D8F9;
	Wed, 23 Dec 2020 15:21:21 -0800 (PST)
Received: from NAM10-MW2-obe.outbound.protection.outlook.com
 (mail-mw2nam10on2057.outbound.protection.outlook.com [40.107.94.57])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E5D8E30BAE9
 for <lustre-devel@lists.lustre.org>; Wed, 23 Dec 2020 15:21:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=UbTGgaqxH8uXUR4QWQgvFU96+Rwx94TY0lfeCTweAO/bL9+8MIUr9MklC8EZryBmHLkPCiyp9TIG0hcjttaKcsSLg9uohc8VwPcbY1N/rK3d4fvCXsJrAiueBiHR7WkUxKssx3PRyRgUwoDBpHXCye6ZVRlehdvQ6Dhzxrv5eHz8FjsvDGeBaxmMiJVt/wjTsMsXSaKTQXYIOCSZmz96groiEZC4fZMjfTdk/zY7gUR6nhoyntgH+6ZLQAQsJBa0I+s+fmunnre7jbW1qRJd3xEoNq2sR8zxzktrc3o7ioyE80sVnzHv8+Qo7UKGT4Q8s6x+M2Fr2Nl7r0x6YT0qFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=M3J5d8fNiVAMIB/o9rAnF0oBL1xmjrT4fIsQ1LxGMVg=;
 b=nQrgn3xw2+6rNn0IdSMQSFB72q6pK+DcBnWBjOn0erYE0pcK6RQhXkIWxmw8OnrlK3GBqXZEtpeCLCO6O7PJSIz5OZgPgZXPCjdfQJzXTGN1Np5l+LzeNf4wUp+n9eDgiSStbn1RGNdDPogHYzKRkm602nGLaramwZEdeNYIqnC4Pi+8yFy6Omktkfi8H/0rOkKiqw9Fu9khIPTxPBQxd9u1t1WZsIPrH5zF/+CN7HVmDcssJlcyDt+ZrCCG2wEyZKea0OTgpDDW8+GR2kaj8PRvjTHX5SoNYlX2y6dP1L6Ei7th9S/0q+LhhnPdq/Wzmhv+LZTdsglDCztaevZSZA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=M3J5d8fNiVAMIB/o9rAnF0oBL1xmjrT4fIsQ1LxGMVg=;
 b=AUY4p4YTjnEA9sxtRkACtzLAvzMN2RMKSGTLNStMrDwcf215nWGGu7mCsVc/+0O6hVxcYDxvw1CaSu5jFanfSjReqo5+hsB9uus7WJ8HYEZcdUC9phH+HiP03avXy6a5G6sSBHAYzSAXmw8ig1q90CIFqRrJN4xEzH36pUGtvm8=
Received: from MN2PR19MB3662.namprd19.prod.outlook.com (2603:10b6:208:193::28)
 by MN2PR19MB3886.namprd19.prod.outlook.com (2603:10b6:208:1f1::7)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.3700.27; Wed, 23 Dec
 2020 23:21:16 +0000
Received: from MN2PR19MB3662.namprd19.prod.outlook.com
 ([fe80::944:8292:35d7:98ca]) by MN2PR19MB3662.namprd19.prod.outlook.com
 ([fe80::944:8292:35d7:98ca%7]) with mapi id 15.20.3700.026; Wed, 23 Dec 2020
 23:21:16 +0000
From: Andreas Dilger <adilger@whamcloud.com>
To: NeilBrown <neilb@suse.de>
Thread-Topic: An alternate approach to preparing lustre for upstream submission
Thread-Index: AQHWz3K+1EwFuQ5hNk2/xyxgS3eCMaoFZbiA
Date: Wed, 23 Dec 2020 23:21:16 +0000
Message-ID: <53FA16ED-D466-43C4-9958-6AE9452FA351@whamcloud.com>
References: <87o8j1j8e0.fsf@notabene.neil.brown.name>
In-Reply-To: <87o8j1j8e0.fsf@notabene.neil.brown.name>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: suse.de; dkim=none (message not signed)
 header.d=none;suse.de; dmarc=none action=none header.from=whamcloud.com;
x-originating-ip: [70.77.221.9]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a6a71bcb-0952-4cea-6afa-08d8a7997283
x-ms-traffictypediagnostic: MN2PR19MB3886:
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs: <MN2PR19MB3886E3134990ACA0E2EF5712A7DE0@MN2PR19MB3886.namprd19.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: eCnY06XJhrWPfwoxSHxC23QZt5MzRbNnIpChdpLfWUd7sk1i5sv5bkLAKNYeNzMMvnM7MkdIcZZ8E7JrFw2Kr4Nf7DPsM55J15ISQWtpDkVz/aNmZ+6XqmP1ua+0aCXPqfUghfQUp8Ioh9QBL8G0+zAUec305hi32IGk6bPlRTxgOnnMe66jiHWukfn8X0DLhBR8CakSKu6o2FApXFT0bf9nhFgRZ8Ft3/Ji/E+MGiQQ6qKld7Mr+X4/ao6DyCasWCrL9/Y5CZ3VZnnlxxzlXgWZEniaCnUc0V5yAV/o0+GPD7pJ5YB3bi+6wJ8IN9UqqdxJ31dWTbaGhaCLT/nVEHMGJii0GRsl65O6aZaaahXvDNR0TSeUmG4Z5lPKu+reSDKlVFFnxhssov5DLVkPfRqJePwaJntv9Uo1c1ysIcPCi+6qtlkG6yf5oJUnrqICOGMw/oJ/UaqAxUPEN91b0rZTamUDvt1VZqxHpKYb/W3Hag/XTnbPllwQLYoNv2LXBI/l5wUWukmKhT41f1LmKER9OibnYXeN9quSJmgbk5U=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MN2PR19MB3662.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(4636009)(396003)(366004)(136003)(346002)(39850400004)(376002)(36756003)(2616005)(4326008)(8936002)(53546011)(33656002)(478600001)(66946007)(6486002)(2906002)(6512007)(186003)(54906003)(26005)(5660300002)(107886003)(64756008)(8676002)(66476007)(66556008)(6506007)(91956017)(83380400001)(76116006)(966005)(6916009)(86362001)(316002)(71200400001)(66446008)(166002)(13693001)(45980500001);
 DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata: =?us-ascii?Q?5GLCPPrNgHoU5AJoWTxh9I4lq0AiYtI4o8Udwz7mC/xIGoaVQGnqvITSJpXJ?=
 =?us-ascii?Q?YTb7fYvsBR1ZApMjD2D4X4NNY7Uf8iibqUQ4iX6huUztRjSl1KPWBvTDi86Y?=
 =?us-ascii?Q?kMLP9YSFfGmj0oiLgPmg6GpEyk4QCPjXxAEBK4VhyfR9zvITsowwZx5Z3n1A?=
 =?us-ascii?Q?hJLzjHd7cI1dMOA280t56cZrznEJ20hfhgQPHx3O0GGIN13s3gJkOqminvgu?=
 =?us-ascii?Q?ltdaK9ieCTpmOAmIsKeBMm51PyLhGaoMjp1m41msWorI0xt16itrm+vPpKiA?=
 =?us-ascii?Q?+EX8TVM350qxMrvHAtyLUIpXYs3R9Hpy9v1wMio/naLzzks+C32SYzzZaKUX?=
 =?us-ascii?Q?rS6CaOmBUCjHa0/pYB3S0kh9WSKiWGmobcmnB8yYfFfDFSNHLg4ewSxnv6aO?=
 =?us-ascii?Q?m1cdVZXKNJIDvw1b3vQwD26FvWJPL2vT5uKAv8aXghLb0FHPRXQ43FP4S0gG?=
 =?us-ascii?Q?L6R7bFeaMfFdC+hgR+y5dxz+IrdTkrkUnO9r9WGgBxo53GzaMo12VUxKfKhq?=
 =?us-ascii?Q?ndFL86OKhEMfMRZKXtPpieBTqcr93HqJWWs3Xi0wtxtFHXhYp1sUQravux4x?=
 =?us-ascii?Q?dpf8G9LeJnD64q2vVgUrBRajE1zAaeHjQEPy2H0bKswcZH2g3JMC+rG/zEIV?=
 =?us-ascii?Q?OBYJqCaa9aNIvSf20HDmO4I9sS8A7wcdu/YekhFpl+YVpeSb7UfMwID1VEJj?=
 =?us-ascii?Q?TSgV5ETn9XumWVwA6y+I/9xvmzraOkT+6La8sPHQJT/ye5W6QSWX69a97YRL?=
 =?us-ascii?Q?vtYJe2eAXmcpmNTF+0z3Bn56DtFMrRiKmgcfoNXQ1HIYzoBSz7huuhEFHi4U?=
 =?us-ascii?Q?VqZAE1xU9F18yFtxDC5W9bkgv9o0oD6Rj8k08CywA2Q9TSufLTBrPknYUvyj?=
 =?us-ascii?Q?TJ8g4xwcv3QB2js65nLkuPHzixZEpTzvQ3Y1Rccbvk2Wfje0eKAEVe/tfihX?=
 =?us-ascii?Q?HkoUN7lwvOrcExiii5VVyRnX3GnwE6ZvA+2J+yrLks0TmysSPBZB7n7nEa3S?=
 =?us-ascii?Q?vCon?=
MIME-Version: 1.0
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MN2PR19MB3662.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a6a71bcb-0952-4cea-6afa-08d8a7997283
X-MS-Exchange-CrossTenant-originalarrivaltime: 23 Dec 2020 23:21:16.4546 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: u0k1vQHizmo9TnnQynPExENsakb9lrckA9QxQ4yGn6PBf+4rmd2zFQRJUM4WyvOl
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR19MB3886
Subject: Re: [lustre-devel] An alternate approach to preparing lustre for
 upstream submission
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============2071090971054456668=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============2071090971054456668==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_53FA16EDD46643C499586AE9452FA351whamcloudcom_"

--_000_53FA16EDD46643C499586AE9452FA351whamcloudcom_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

On Dec 10, 2020, at 21:04, NeilBrown <neilb@suse.de<mailto:neilb@suse.de>> =
wrote:
I've been exploring an alternate approach to preparing lustre code for
upstream submission.

Neil,
sorry for not responding to this email in a timely manner.  I'd read it whe=
n
you first posted it, but then thought "I should take time to read it closel=
y
and reply in a thoughtful manner" but it got lost in my inbox.

As you probably know, the approach we have been following is based on
the code that was removed from 'drivers/staging' a couple of years ago.
I reverted that removal patch and have ported all the relevant patches
from lustre "master" across to that tree, as well as other cleanups and
fixes.

A problem with this approach is that I find that I don't trust it.
I've found multiple examples of patches being ported across
incorrectly, of patches being missed, and of bugs introduced while the
code was in drivers/staging.
I've found and fixed a lot of issues.  I doubt that I've found them
all.
While I do some testing of this code, as does James, it is minimal
compared to the testing done on lustre/master.  And as we should all
remember: untested code is buggy code.

That was my concern with this approach also.  When Greg KH was keeping
it in the staging tree, it ended up getting drive-by patches from all kinds=
 of
developers that ended up adding bugs in patches that weren't reviewed or
tested.

Some time ago, we'd offered to run automated testing for the fs/linux-stagi=
ng
repo in our autotest, but that essentially requires running everything thro=
ugh
Gerrit, which is not the preferred workflow for upstream kernels.

People who use lustre don't only want correctness and performance, they
want confidence, and I'm not confident of this code.

My alternate approach is to use the code straight out of lustre/master,
transformed to match upstream requirements by a relatively simple
script.  There is clearly still room for the script to introduce
problems, but it is much less likely and any problems introduced are
less likely to go unnoticed.

I think you & James have been doing a great job cleaning up the code in
master to be more in line with the upstream client, and I agree continuing
in that direction (bringing the master into acceptable shape) is the only
feasible way to move forward.

I have written such a script, based largely on sed, unifdef, and spatch
(the latter from the coccinelle project).

Not all changes that I want can be achieved with these tools so I also
have a collection of patches to lustre which hopefully will be
submitted in due course.  Many are the same sorts of cleanups that I've
been submitting for a while.  Others are a bit different.  For example
I add a lot more "#ifdef HAVE_SERVER_SUPPORT" preprocessor directives
so that "unifdef" can strip out more server-only code.  I've also added
some "#ifndef UPSTREAM_LINUX" directives to remove code that cannot go
upstream, like the code for extracting a jobid from the environment.

I know Peng Tao had originally written such a script when he first pushed
the Lustre code into the upstream kernel, but I don't think it was ever
maintained after the initial push.  That would definitely make it more clea=
r
what deltas exist between master and the upstream kernel versions.

You can see my current lustre tree at
  https://github.com/neilbrown/lustre/tree/lustre-next
This contains 119 patches on top of master, some of which have already
been submitted to gerrit, others could be easily, others need a lot of
work first. The last patch adds the "copy-client" script.

We are (finally) getting close to releasing 2.14.0 (definitely later than w=
e had
hoped), and that will open up the gates again for the code cleanup patches
to land.  While there have definitely been some bugs introduced from those
patches, like you wrote above they eventually are found with proper testing=
,
and we benefit from removing many layers of cruft from the old code.

In
  https://github.com/neilbrown/linux/tree/lustre/lustre-next
you can find a very recent linux/master tree with two patches added.
The first was auto-generated by the script from lustre/lustre-next.
The second fixes some compile errors with fscrypt() (though it may
actually break the code, I don't know).

Note that the copied LNET code is TCP-only.  I left out the o2ib code
as I don't think we need that for the first code drop.

Apart from providing the code mentioned above, this little project has
also helped me form a clearer picture of what needs to be done before
upstream submission is worth attempting.  My list includes:

- IPv6 support.  I have a lot of patches which add support for extended
  NIDs which can store IPv6 addresses.  There is more to be done here
  (and thanks to Andreas for his review which I haven't responded to
  yet).
  One awkwardness in the conversion that I haven't addressed at all yet
  is ptlrpc/nodemap_range.c.  This allows a range of IP address to have
  a particular nodemap.  This might make sense for IPv4, but makes
  somewhat less sense for IPv6.
  I'm storing IPv6 addresses in network-byte-order (which is the normal
  way to store addresses), and that make ranges particularly cumbersome.
  One idea is to use netmasks rather than ranges to define subsets, for
  IPv6 at least.

Could you please file a ticket in Jira to track that issue.  Definitely nod=
emaps
have become important at some sites for management of multiple clients,
so we don't want to lose that functionality.

- fscrypt.  There is a comment in lustre-core.m4 which suggests that
   lustre does not support file name encryption, and so cannot use
   the fscrypt support in Linux.  If I understand that correctly, then
   this needs to be rectified.

This is planned to be fixed in 2.15, it just wasn't ready in time for the f=
eature
cutoff for 2.14.  The 2.14 release only has file data encryption.

- I want to deprecate libcfs as there isn't anywhere convenient to put
  it - as a whole - in the linux kernel. It currently contains a
  mixture of things:
  =3D back-compat code, which Linux obviously doesn't needed

  - workitem.c and hash.c which are being replaced by
    workqueue and rhashables

  - cpt code, which is largely used by lnet, so can go in lnet/lnet

  - heap tree, which can go in lustre/ptlrpc as it is only used by nrs.

  - fail.c error injection.  It would be nice to convert lustre to
    use the error-injection in linux/lib.  This is a completely
    different user-space interface management.
    Is the current interface seen as a "stable api", or is it only
    used by lustre/tests (which can obviously be changed).

There aren't (or shouldn't be) any users of fail_loc outside of the test
framework.  That said, we do need some kind of interoperability for
testing new/old clients/servers together, so there can't be a wholesale
removal of this functionality.

  - tracefile/debug.  I think this should be changed to use
    tracepoints. I believe the capabilities are similar, though the
    details are different.  I think I've raised this before and had an
    explanation of why people aren't keen.  Maybe it is time to revisit
    that.
    LU-8980 was closed "Won't Fix" with no explanatory comment...

I think the issue here was that the patches to wrap CDEBUG() with
tracepoints was really unwieldy.  On the flip side, there are a *lot* of
CDEBUG() messages, and converting them all to tracepoints would
be lots of work, since each tracepoint is essentially "hand rolled".
Also, enabling/disabling CDEBUG is easy for users to do for collecting
debug logs to analyze a problem, while the same can't be said for
tracepoints.

IMHO, I don't think there is a requirement to remove CDEBUG() to go
upstream.  Lots of other kernel components have similar debug macros
to enable/disable messages in the kernel.  The big difference is the ring
buffer for tracefile.  If we could use some other pre-existing ring buffer
for that (which was under development at some point, but I don't know
if it ever made it into the kernel) then we could drop the parts that I
think raise objections.

  - libcfs_string - I've converted nearly all of this to use
    functionality already in Linux.  Only cfs_str2mask() remains.

That is mostly part of CDEBUG/tracefile and could be moved there.

  - adler32 - hopefully this can be copied to crypto/ in linux.

Yes, the code is already in the kernel, it just isn't available via CryptoA=
PI.

- move stuff out of /proc
   I understand that part of this is statistics, which don't fit in
   debugfs as that is root-only, and don't fit in /sys at that is
   one-value-per-file.
   Firstly I'd like to resolve everything that is not stats.
   James has a netlink proposal for stats.
   NFS uses /proc/self/mountstats to present stats info.

IMHO, each filesystem/subsystem having its own proc-like virtual
filesystem to export stats/tunables from the kernel is not a win over just
using /proc (probably a net loss because each one implements the same
boilerplate code to "avoid using /proc"), but that seems to have been what
happened in the end.

I plan to create some jira issues to cover:
 - moving code out of libcfs
 - fault injection
 - adding more HAVE_SERVER_SUPPORT and UPSTREAM_LINUX directives

and start submitting some of the patches I have, and work on some more.

I'll probably keep my existing linux-lustre tree (based on
drivers/staging) up to date, as there is still valuable stuff in there
to be ported across, and being able to 'diff' the two (with filtering)
helps.

Yes, keeping track of the deltas is definitely interesting for both trackin=
g what may
still be needed to port to master, as well as the off chance that there may=
 be bugs
fixed in the staging tree that weren't in master.

Cheers, Andreas
--
Andreas Dilger
Principal Lustre Architect
Whamcloud







--_000_53FA16EDD46643C499586AE9452FA351whamcloudcom_
Content-Type: text/html; charset="us-ascii"
Content-ID: <49A37C7493D8554CBDCF70339A3AC280@namprd19.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
</head>
<body style=3D"word-wrap: break-word; -webkit-nbsp-mode: space; line-break:=
 after-white-space;" class=3D"">
On Dec 10, 2020, at 21:04, NeilBrown &lt;<a href=3D"mailto:neilb@suse.de" c=
lass=3D"">neilb@suse.de</a>&gt; wrote:
<div>
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div class=3D"">I've been exploring an alternate approach to preparing lust=
re code for<br class=3D"">
upstream submission.<br class=3D"">
</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
Neil,</div>
<div>sorry for not responding to this email in a timely manner. &nbsp;I'd r=
ead it when</div>
<div>you first posted it, but then thought &quot;I should take time to read=
 it closely</div>
<div>and reply in a thoughtful manner&quot; but it got lost in my inbox.</d=
iv>
<div><br class=3D"">
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div class=3D"">As you probably know, the approach we have been following i=
s based on<br class=3D"">
the code that was removed from 'drivers/staging' a couple of years ago.<br =
class=3D"">
I reverted that removal patch and have ported all the relevant patches<br c=
lass=3D"">
from lustre &quot;master&quot; across to that tree, as well as other cleanu=
ps and<br class=3D"">
fixes.<br class=3D"">
<br class=3D"">
A problem with this approach is that I find that I don't trust it.<br class=
=3D"">
I've found multiple examples of patches being ported across<br class=3D"">
incorrectly, of patches being missed, and of bugs introduced while the<br c=
lass=3D"">
code was in drivers/staging.<br class=3D"">
I've found and fixed a lot of issues. &nbsp;I doubt that I've found them<br=
 class=3D"">
all.<br class=3D"">
While I do some testing of this code, as does James, it is minimal<br class=
=3D"">
compared to the testing done on lustre/master. &nbsp;And as we should all<b=
r class=3D"">
remember: untested code is buggy code.<br class=3D"">
</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
That was my concern with this approach also. &nbsp;When Greg KH was keeping=
</div>
<div>it in the staging tree, it ended up getting drive-by patches from all =
kinds of</div>
<div>developers that ended up adding bugs in patches that weren't reviewed =
or</div>
<div>tested.</div>
<div><br class=3D"">
</div>
<div>Some time ago, we'd offered to run automated testing for the fs/linux-=
staging</div>
<div>repo in our autotest, but that essentially requires running everything=
 through</div>
<div>Gerrit, which is not the preferred workflow for upstream kernels.</div=
>
<div><br class=3D"">
</div>
<div>
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div class=3D"">People who use lustre don't only want correctness and perfo=
rmance, they<br class=3D"">
want confidence, and I'm not confident of this code.<br class=3D"">
<br class=3D"">
My alternate approach is to use the code straight out of lustre/master,<br =
class=3D"">
transformed to match upstream requirements by a relatively simple<br class=
=3D"">
script. &nbsp;There is clearly still room for the script to introduce<br cl=
ass=3D"">
problems, but it is much less likely and any problems introduced are<br cla=
ss=3D"">
less likely to go unnoticed.<br class=3D"">
</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
I think you &amp; James have been doing a great job cleaning up the code in=
</div>
<div>master to be more in line with the upstream client, and I agree contin=
uing</div>
<div>in that direction (bringing the master into acceptable shape) is the o=
nly</div>
<div>feasible way to move forward.</div>
<div><br class=3D"">
</div>
<div>
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div class=3D"">I have written such a script, based largely on sed, unifdef=
, and spatch<br class=3D"">
(the latter from the coccinelle project).<br class=3D"">
<br class=3D"">
Not all changes that I want can be achieved with these tools so I also<br c=
lass=3D"">
have a collection of patches to lustre which hopefully will be<br class=3D"=
">
submitted in due course. &nbsp;Many are the same sorts of cleanups that I'v=
e<br class=3D"">
been submitting for a while. &nbsp;Others are a bit different. &nbsp;For ex=
ample<br class=3D"">
I add a lot more &quot;#ifdef HAVE_SERVER_SUPPORT&quot; preprocessor direct=
ives<br class=3D"">
so that &quot;unifdef&quot; can strip out more server-only code. &nbsp;I've=
 also added<br class=3D"">
some &quot;#ifndef UPSTREAM_LINUX&quot; directives to remove code that cann=
ot go<br class=3D"">
upstream, like the code for extracting a jobid from the environment.<br cla=
ss=3D"">
</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
I know Peng Tao had originally written such a script when he first pushed</=
div>
<div>the Lustre code into the upstream kernel, but I don't think it was eve=
r</div>
<div>maintained after the initial push. &nbsp;That would definitely make it=
 more clear</div>
<div>what deltas exist between master and the upstream kernel versions.<br =
class=3D"">
<div class=3D"">
<div class=3D""><br class=3D"">
</div>
</div>
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div class=3D"">You can see my current lustre tree at<br class=3D"">
&nbsp;&nbsp;<a href=3D"https://github.com/neilbrown/lustre/tree/lustre-next=
" class=3D"">https://github.com/neilbrown/lustre/tree/lustre-next</a><br cl=
ass=3D"">
This contains 119 patches on top of master, some of which have already<br c=
lass=3D"">
been submitted to gerrit, others could be easily, others need a lot of<br c=
lass=3D"">
work first.&nbsp;The last patch adds the &quot;copy-client&quot; script.<br=
 class=3D"">
</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
We are (finally) getting close to releasing 2.14.0 (definitely later than w=
e had</div>
<div>hoped), and that will open up the gates again for the code cleanup pat=
ches</div>
<div>to land. &nbsp;While there have definitely been some bugs introduced f=
rom those</div>
<div>patches, like you wrote above they eventually are found with proper te=
sting,</div>
<div>and we benefit from removing many layers of cruft from the old code.</=
div>
<div>
<div class=3D"">
<div class=3D""><br class=3D"">
</div>
</div>
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div class=3D"">In<br class=3D"">
&nbsp;&nbsp;<a href=3D"https://github.com/neilbrown/linux/tree/lustre/lustr=
e-next" class=3D"">https://github.com/neilbrown/linux/tree/lustre/lustre-ne=
xt</a><br class=3D"">
you can find a very recent linux/master tree with two patches added.<br cla=
ss=3D"">
The first was auto-generated by the script from lustre/lustre-next.<br clas=
s=3D"">
The second fixes some compile errors with fscrypt() (though it may<br class=
=3D"">
actually break the code, I don't know).<br class=3D"">
<br class=3D"">
Note that the copied LNET code is TCP-only. &nbsp;I left out the o2ib code<=
br class=3D"">
as I don't think we need that for the first code drop.<br class=3D"">
<br class=3D"">
Apart from providing the code mentioned above, this little project has<br c=
lass=3D"">
also helped me form a clearer picture of what needs to be done before<br cl=
ass=3D"">
upstream submission is worth attempting. &nbsp;My list includes:<br class=
=3D"">
<br class=3D"">
- IPv6 support. &nbsp;I have a lot of patches which add support for extende=
d<br class=3D"">
&nbsp;&nbsp;NIDs which can store IPv6 addresses. &nbsp;There is more to be =
done here<br class=3D"">
&nbsp;&nbsp;(and thanks to Andreas for his review which I haven't responded=
 to<br class=3D"">
&nbsp;&nbsp;yet).<br class=3D"">
&nbsp;&nbsp;One awkwardness in the conversion that I haven't addressed at a=
ll yet<br class=3D"">
&nbsp;&nbsp;is ptlrpc/nodemap_range.c. &nbsp;This allows a range of IP addr=
ess to have<br class=3D"">
&nbsp;&nbsp;a particular nodemap. &nbsp;This might make sense for IPv4, but=
 makes<br class=3D"">
&nbsp;&nbsp;somewhat less sense for IPv6.<br class=3D"">
&nbsp;&nbsp;I'm storing IPv6 addresses in network-byte-order (which is the =
normal<br class=3D"">
&nbsp;&nbsp;way to store addresses), and that make ranges particularly cumb=
ersome.<br class=3D"">
&nbsp;&nbsp;One idea is to use netmasks rather than ranges to define subset=
s, for<br class=3D"">
&nbsp;&nbsp;IPv6 at least.<br class=3D"">
</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
Could you please file a ticket in Jira to track that issue. &nbsp;Definitel=
y nodemaps</div>
<div>have become important at some sites for management of multiple clients=
,</div>
<div>so we don't want to lose that functionality.</div>
<div><br class=3D"">
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div class=3D"">- fscrypt. &nbsp;There is a comment in lustre-core.m4 which=
 suggests that<br class=3D"">
&nbsp;&nbsp;&nbsp;lustre does not support file name encryption, and so cann=
ot use<br class=3D"">
&nbsp;&nbsp;&nbsp;the fscrypt support in Linux. &nbsp;If I understand that =
correctly, then<br class=3D"">
&nbsp;&nbsp;&nbsp;this needs to be rectified.<br class=3D"">
</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
This is planned to be fixed in 2.15, it just wasn't ready in time for the f=
eature</div>
<div>cutoff for 2.14. &nbsp;The 2.14 release only has file data encryption.=
</div>
<div><br class=3D"">
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div class=3D"">- I want to deprecate libcfs as there isn't anywhere conven=
ient to put<br class=3D"">
&nbsp;&nbsp;it - as a whole - in the linux kernel. It currently contains a<=
br class=3D"">
&nbsp;&nbsp;mixture of things:<br class=3D"">
&nbsp;&nbsp;=3D back-compat code, which Linux obviously doesn't needed<br c=
lass=3D"">
<br class=3D"">
&nbsp;&nbsp;- workitem.c and hash.c which are being replaced by<br class=3D=
"">
&nbsp;&nbsp;&nbsp;&nbsp;workqueue and rhashables<br class=3D"">
<br class=3D"">
&nbsp;&nbsp;- cpt code, which is largely used by lnet, so can go in lnet/ln=
et<br class=3D"">
<br class=3D"">
&nbsp;&nbsp;- heap tree, which can go in lustre/ptlrpc as it is only used b=
y nrs.<br class=3D"">
<br class=3D"">
&nbsp;&nbsp;- fail.c error injection. &nbsp;It would be nice to convert lus=
tre to<br class=3D"">
&nbsp;&nbsp;&nbsp;&nbsp;use the error-injection in linux/lib. &nbsp;This is=
 a completely<br class=3D"">
&nbsp;&nbsp;&nbsp;&nbsp;different user-space interface management.<br class=
=3D"">
&nbsp;&nbsp;&nbsp;&nbsp;Is the current interface seen as a &quot;stable api=
&quot;, or is it only<br class=3D"">
&nbsp;&nbsp;&nbsp;&nbsp;used by lustre/tests (which can obviously be change=
d).<br class=3D"">
</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
There aren't (or shouldn't be) any users of fail_loc outside of the test</d=
iv>
<div>framework. &nbsp;That said, we do need some kind of interoperability f=
or</div>
<div>testing new/old clients/servers together, so there can't be a wholesal=
e</div>
<div>removal of this functionality.<br class=3D"">
<div class=3D"">
<div class=3D""><br class=3D"">
</div>
</div>
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div class=3D"">&nbsp;&nbsp;- tracefile/debug. &nbsp;I think this should be=
 changed to use<br class=3D"">
&nbsp;&nbsp;&nbsp;&nbsp;tracepoints. I believe the capabilities are similar=
, though the<br class=3D"">
&nbsp;&nbsp;&nbsp;&nbsp;details are different. &nbsp;I think I've raised th=
is before and had an<br class=3D"">
&nbsp;&nbsp;&nbsp;&nbsp;explanation of why people aren't keen. &nbsp;Maybe =
it is time to revisit<br class=3D"">
&nbsp;&nbsp;&nbsp;&nbsp;that.<br class=3D"">
&nbsp;&nbsp;&nbsp;&nbsp;LU-8980 was closed &quot;Won't Fix&quot; with no ex=
planatory comment...<br class=3D"">
</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
I think the issue here was that the patches to wrap CDEBUG() with</div>
<div>tracepoints was really unwieldy. &nbsp;On the flip side, there are a *=
lot* of</div>
<div>CDEBUG() messages, and converting them all to tracepoints would</div>
<div>be lots of work, since each tracepoint is essentially &quot;hand rolle=
d&quot;.</div>
<div>Also, enabling/disabling CDEBUG is easy for users to do for collecting=
</div>
<div>debug logs to analyze a problem, while the same can't be said for</div=
>
<div>tracepoints.</div>
<div><br class=3D"">
</div>
<div>IMHO, I don't think there is a requirement to remove CDEBUG() to go</d=
iv>
<div>upstream. &nbsp;Lots of other kernel components have similar debug mac=
ros</div>
<div>to enable/disable messages in the kernel. &nbsp;The big difference is =
the ring</div>
<div>buffer for tracefile. &nbsp;If we could use some other pre-existing ri=
ng buffer</div>
<div>for that (which was under development at some point, but I don't know<=
/div>
<div>if it ever made it into the kernel) then we could drop the parts that =
I</div>
<div>think raise objections.</div>
<div><br class=3D"">
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div class=3D"">&nbsp;&nbsp;- libcfs_string - I've converted nearly all of =
this to use<br class=3D"">
&nbsp;&nbsp;&nbsp;&nbsp;functionality already in Linux. &nbsp;Only cfs_str2=
mask() remains.<br class=3D"">
</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
That is mostly part of CDEBUG/tracefile and could be moved there.</div>
<div><br class=3D"">
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div class=3D"">&nbsp;&nbsp;- adler32 - hopefully this can be copied to cry=
pto/ in linux.<br class=3D"">
</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
Yes, the code is already in the kernel, it just isn't available via CryptoA=
PI.</div>
<div><br class=3D"">
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div class=3D"">- move stuff out of /proc<br class=3D"">
&nbsp;&nbsp;&nbsp;I understand that part of this is statistics, which don't=
 fit in<br class=3D"">
&nbsp;&nbsp;&nbsp;debugfs as that is root-only, and don't fit in /sys at th=
at is<br class=3D"">
&nbsp;&nbsp;&nbsp;one-value-per-file.<br class=3D"">
&nbsp;&nbsp;&nbsp;Firstly I'd like to resolve everything that is not stats.=
<br class=3D"">
&nbsp;&nbsp;&nbsp;James has a netlink proposal for stats.<br class=3D"">
&nbsp;&nbsp;&nbsp;NFS uses /proc/self/mountstats to present stats info.<br =
class=3D"">
</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
IMHO, each filesystem/subsystem having its own proc-like virtual</div>
<div>filesystem to export stats/tunables from the kernel is not a win over =
just</div>
<div>using /proc (probably a net loss because each one implements the same<=
/div>
<div>boilerplate code to &quot;avoid using /proc&quot;), but that seems to =
have been what</div>
<div>happened in the end.</div>
<div><br class=3D"">
</div>
<div>
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div class=3D"">I plan to create some jira issues to cover:<br class=3D"">
&nbsp;- moving code out of libcfs<br class=3D"">
&nbsp;- fault injection<br class=3D"">
&nbsp;- adding more HAVE_SERVER_SUPPORT and UPSTREAM_LINUX directives<br cl=
ass=3D"">
<br class=3D"">
and start submitting some of the patches I have, and work on some more.<br =
class=3D"">
<br class=3D"">
I'll probably keep my existing linux-lustre tree (based on<br class=3D"">
drivers/staging) up to date, as there is still valuable stuff in there<br c=
lass=3D"">
to be ported across, and being able to 'diff' the two (with filtering)<br c=
lass=3D"">
helps.<br class=3D"">
</div>
</div>
</blockquote>
<br class=3D"">
</div>
<div>Yes, keeping track of the deltas is definitely interesting for both tr=
acking what may</div>
<div>still be needed to port to master, as well as the off chance that ther=
e may be bugs</div>
<div>fixed in the staging tree that weren't in master.</div>
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

--_000_53FA16EDD46643C499586AE9452FA351whamcloudcom_--

--===============2071090971054456668==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============2071090971054456668==--
