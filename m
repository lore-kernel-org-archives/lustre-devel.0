Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E08A9C02185
	for <lustre-devel@archiver.kernel.org>; Sat, 18 Jan 2025 21:46:18 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Yb9CX0y0Qz1xPm;
	Sat, 18 Jan 2025 13:46:16 -0800 (PST)
Received: from smtp-fw-80008.amazon.com (smtp-fw-80008.amazon.com
 [99.78.197.219])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Yb9CN1mJjz1wl2
 for <lustre-devel@lists.lustre.org>; Sat, 18 Jan 2025 13:46:08 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
 t=1737236768; x=1768772768;
 h=from:to:cc:date:message-id:references:in-reply-to:
 content-id:content-transfer-encoding:mime-version:subject;
 bh=IKtmVcJwgEqYRmD07ICSzpn6mqEqsVKtOCcnWl2jyAo=;
 b=o+J1VJHOIfCTHeXzYQ8O3v5ZiUpSSMdfoXjeO0eONWXHWk2wHzsHCu0p
 P3IW1Wb/IZMlLZ95c3dFy3Ea0BwXZWgpEdkYp5OrRL4l74Sf2/fvbawSz
 /ohrWt81H6Z81UCxUWmKZ3CJGTSqZ1EUsXlb7U+W9OZD7a/kKjpyoaAvo Y=;
X-IronPort-AV: E=Sophos;i="6.13,216,1732579200"; d="scan'208";a="162477979"
Thread-Topic: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
Received: from pdx4-co-svc-p1-lb2-vlan3.amazon.com (HELO
 smtpout.prod.us-east-1.prod.farcaster.email.amazon.dev) ([10.25.36.214])
 by smtp-border-fw-80008.pdx80.corp.amazon.com with
 ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 18 Jan 2025 21:46:07 +0000
Received: from EX19MTAUEC002.ant.amazon.com [10.0.29.78:45299]
 by smtpin.naws.us-east-1.prod.farcaster.email.amazon.dev [10.0.25.228:2525]
 with esmtp (Farcaster)
 id 5a0fb688-c698-44b9-8f54-98d6c8ade817; Sat, 18 Jan 2025 21:46:06 +0000 (UTC)
X-Farcaster-Flow-ID: 5a0fb688-c698-44b9-8f54-98d6c8ade817
Received: from EX19D017UEA004.ant.amazon.com (10.252.134.70) by
 EX19MTAUEC002.ant.amazon.com (10.252.135.253) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1258.39;
 Sat, 18 Jan 2025 21:46:03 +0000
Received: from EX19D017UEA001.ant.amazon.com (10.252.134.93) by
 EX19D017UEA004.ant.amazon.com (10.252.134.70) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1258.39;
 Sat, 18 Jan 2025 21:46:02 +0000
Received: from EX19D017UEA001.ant.amazon.com ([fe80::bffb:623f:af5e:ebed]) by
 EX19D017UEA001.ant.amazon.com ([fe80::bffb:623f:af5e:ebed%3]) with
 mapi id 15.02.1258.039; Sat, 18 Jan 2025 21:46:02 +0000
From: "Day, Timothy" <timday@amazon.com>
To: Oleg Drokin <green@whamcloud.com>, "neilb@suse.de" <neilb@suse.de>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Index: AQHbaVeRqC+vmvhDK0+DNl/PAi9AJbMcvjsA
Date: Sat, 18 Jan 2025 21:46:02 +0000
Message-ID: <A2A33C79-3467-4E93-952D-9646346E0349@amazon.com>
References: <3139EEF5-91BF-4F8E-A112-1D66455AE3D2@amazon.com>
 <173716111777.22054.8452560203667698532@noble.neil.brown.name>
 <785a407c987a57ddf6bbfbed05230981af66cd26.camel@whamcloud.com>
In-Reply-To: <785a407c987a57ddf6bbfbed05230981af66cd26.camel@whamcloud.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [10.106.179.18]
Content-ID: <B505E8F401C64C48923BD78BE40EFD21@amazon.com>
MIME-Version: 1.0
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>



> On 1/17/25, 10:17 PM, "Oleg Drokin" <green@whamcloud.com <mailto:green@whamcloud.com>> wrote:
> > On Sat, 2025-01-18 at 11:45 +1100, NeilBrown wrote:
> > We need to demonstrate a process for, and commitment to, moving away
> > from the dual-tree model. We need patches to those parts of Lustre
> > that are upstream to land in upstream first (mostly).
>
>
> I think this is not very realistic.
> Large chunk (100%?) of users do not run not only the latest kernel
> release, they don't run the latest LTS either.
>
>
> When we were in staging last this manifested in random patches being
> landed and breaking the client completely and nobody noticing for
> months.
>
>
> Of course some automatic infrastructure could be built up to make it
> somewhat better, but it does not remove the problem of "nobody would
> run this mainline tree", I am afraid.

I think there's a decent chunk of users on newer kernels. Ubuntu 22/24 is
on (a bit past latest) LTS 6.8 kernel [1], AL2023 is on previous LTS 6.1 [2], and
working on upcoming LTS 6.12 [3].

When a patch lands in lustre-release/master, it could be around 1 - 1.5 years
before it lands in a proper Lustre release. At that point, it might see real
production usage.

If a patch landed in a hypothetical upstream client, it might be around 6
months until a production kernel is using that client.

So I think it's mostly a matter of convincing people to use an upstream
client. I don't think people wanted to use the staging client because it
didn't work well and wasn't stable. And vendors don't want to work on
something that no one uses. It the client is "good enough" and people
are confident it'll continue to be updated, I think they will use it. The
staging client was neither of those things.

So I think the problem at hand is molding the existing development
practices to allow us to deliver an upstream client that has a baseline of
functionality and stability. And at the same time, supporting older vendor
kernels. I don't think it'd be a quick transition, but I think it's a tractable
problem.

[1] Ubuntu kernels - https://ubuntu.com/kernel/lifecycle
[2] AL2023 6.1 - https://github.com/amazonlinux/linux/commit/ef9660091712fa9edd137180b8925ea6316c8043
[3] AL2023 6.12 - https://github.com/amazonlinux/linux/commits/amazon-6.12.y/mainline/

> It does not hep that there are what 3? 4? trees, not "dual-tree" by any
> stretch of imagination.
>
>
> There's DDN/whamcloud (that's really two trees), there's HPE, LLNL
> keeps their fork still I think (thought it's mostly backports?). There
> are likely others I am less exposed to.

I think most non-community Lustre release are derived from the
community release and periodically rebased. I think AWS,
Whamcloud, LLNL, Microsoft would fall into that bucket. And I
doubt DDN and HPE significantly diverge from community Lustre. But
if someone is diverging significantly from community Lustre, I think
they are opting into a significant maintenance burden regardless of
what we do with lustre-release/master.

> Sure, only one of those trees is considered "community Lustre", but if
> it will detach too much from what majority of developers really runs
> and gets paid to do - the "community Lustre" contributions probably
> would diminish greatly, I am afraid.

As long as the community Lustre development process is sane, I think
most organizations will opt to continue deriving their releases from
it and opt to continue contributing releases upstream. We just need
to make sure we get buy-in from the people contributing to Lustre.

> The past situation of "oh, this new enterprise linux comes with a
> community lustre version, so the first step to get something usable is
> to rip it entirely off and then apply the new good version" is not
> exactly desirable either I am afraid.
>
>
> And solving this problem is mostly outside of hands of individual
> developers no matter how cool I think it would be to actually have an
> up to date Lustre in the mainline linux kernel.
>
> > That means we need the model for supporting older kernels to be
> > completely
> > based on libcfs holding compatibility code with no kernel-version
> > #ifdefs in the code.
> >
> > We need a strong separation between server and client so that we can
> > justify everything that goes upstream as being to support the client,
> > and when we add server support to that, it just adds files. Possibly
> > we
> > could patch a few files to add server support, but we need to
> > maintain
> > those as patches, not as alternate versions of upstream files.
> >
> > We need to quickly reach a point where a lustre release is:
> >
> > - a verbatim copy of relevant files from a chosen upstream release,
> > or just a dependency on that kernel source.
> > - a bunch of extra files that might one day go upstream: server code
> > and LNet protocol code
> > - a *few* patches to integrate that code
> > - some number of patches which have since gone upstream - bugfixes
> > etc.
> > - libcfs which contains a compat layer for older kernels.
> > - user-space code, documentation, test scripts, etc for which there
> > is no expectation of upstreaming to linux kernel.
>
>
> All these sound like an awful lot of dedicated developer-hours.
>
>
> > Maybe the question for LSF is : what is a sufficient demonstration of
> > commitment?
> >
> > The big question for us is : how are we going to transition our
> > infrastructure to this model?
>
>
> and who would pay for it.
>
>
> This in the end was the downfall of the previous attempt. There never
> was any serious funding behind the effort so it became an afterthought
> for most.
>
>
> > It would be nice to have a timeline for getting the second and third
> > bullet points down to zero. Obviously it would be aspirational at
> > best,
> > but a list of steps could be useful.
> >
> > Thanks,
> > NeilBrown
> >
>
>
> Bye,
> Oleg
>


_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
