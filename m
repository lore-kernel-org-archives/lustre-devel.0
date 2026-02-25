Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 94FEDF55431
	for <lustre-devel@archiver.kernel.org>; Wed, 25 Feb 2026 00:24:34 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4fLFMY6FX1z23Lr;
	Tue, 24 Feb 2026 16:09:45 -0800 (PST)
Received: from DM1PR04CU001.outbound.protection.outlook.com
 (mail-centralusazon11020129.outbound.protection.outlook.com [52.101.61.129])
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id
 4fLFLw6Fnwz20f0
 for <lustre-devel@lists.lustre.org>; Tue, 24 Feb 2026 16:09:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=mNAj98W4PFd02nh0qfGLZUUCypJ8pl2jlzE7FvKF7M7S/DlO6THnBio3XpUnZb3ufJVcftGahg8cQD+bd1TnopYiLsdwEXTD1xQYA+pvtxJHFSeMB/iLUj8+772iP1lmKwpyI1z5zJaY3MaxvLQ8L8yreA7ZEcTSSzRHT4btC6MJMRh6HGaCeywtgPx6fXbh3XJT8pMvRs5TBVQRjv1oQM7h+pZuENXlhAaFHmIy95jII/pOkWo0u6RoDpx+2jg3e4sN5WgJM7cqhQ4hgdq6Ea0pgT3YKxQpPxOnizSZJ+2vz8s8Gxv9H899gA1qP2fRYCdS1t389NJxpwVQZ/xc8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=qi6txb17LoShf6ERFGURxGlV5zm0I8qjawlqMjCe/94=;
 b=NcdGH9Fbpui6FiOSJP0CF4jHozNE5mNYCz+8tnhgE5SLYzh0F2HB/5uL1guhqeJZiQwAbUeLuNUMk1TaGmJ5WJvt7T3CKVvGBqxKK5DZtTy1cohcRkTVUBOv9NVz8sRZyQKGxR8jHHQQGx3d/Sudfafe4Eg57CeF1Z8mfz9ZL9FRDdFq7UFZuiCFBfAO5fk1ZOXCWaJN2tISW0kLVDW+2xYqOt7WoFvMFz9zbeEYRcsgEGfZRD+1iNqKgybN/ljU+fF9hKy2X5LrusN8JH6327jW4Bdmv5wDOI2VkEbkZwvdTHkqJejZ2510ZECgUTcgZULyP8xKDFO2WklSX/cN/A==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=thelustrecollective.com; dmarc=pass action=none
 header.from=thelustrecollective.com; dkim=pass
 header.d=thelustrecollective.com; arc=none
Received: from DS4PR04MB9822.namprd04.prod.outlook.com (2603:10b6:8:2e7::21)
 by LV0PR04MB9857.namprd04.prod.outlook.com (2603:10b6:408:32d::6) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.9654.10; Wed, 25 Feb
 2026 00:08:08 +0000
Received: from DS4PR04MB9822.namprd04.prod.outlook.com
 ([fe80::376d:31a9:6ea8:f4d9]) by DS4PR04MB9822.namprd04.prod.outlook.com
 ([fe80::376d:31a9:6ea8:f4d9%5]) with mapi id 15.20.9632.017; Wed, 25 Feb 2026
 00:08:08 +0000
To: Abdul Halim | OPENCHIP <abdul.halim@openchip.com>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, Nick
 Brown <n.brown@epcc.ed.ac.uk>, surendrab <surendrab@cdac.in>
Thread-Topic: [lustre-devel] [RFC] RISC-V Architecture Support for Lustre -
 Patch Series Available
Thread-Index: AQHcpX2uN8JgksagukyKgUAO1ExGirWSipwA
Date: Wed, 25 Feb 2026 00:08:08 +0000
Message-ID: <08AF9B7E-CDF9-46D3-881A-D651D8D1F294@thelustrecollective.com>
References: <AM4P192MB31086DEE0D7ED656ADF8B3EE8274A@AM4P192MB3108.EURP192.PROD.OUTLOOK.COM>
In-Reply-To: <AM4P192MB31086DEE0D7ED656ADF8B3EE8274A@AM4P192MB3108.EURP192.PROD.OUTLOOK.COM>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=thelustrecollective.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: DS4PR04MB9822:EE_|LV0PR04MB9857:EE_
x-ms-office365-filtering-correlation-id: 32a096a2-a8ba-4f3a-a2f1-08de7401f4ee
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|376014|1800799024|366016|38070700021;
x-microsoft-antispam-message-info: =?us-ascii?Q?/OnQ0NjzmRrq3GwlMqvHm3nCKG4DkTdopY45e1kXwnvkoE2tbMAxVKJ/gkkm?=
 =?us-ascii?Q?Ufyqj3p3ZDUFlKiyaNVJMvGwTP+NNJtvdQRC74tA0KlmbHXbJ2f8II29xpJQ?=
 =?us-ascii?Q?HL4Dp5fGI6OdFkOLANJGknG05k/E0xihFAB6sIzjs7qwZcPbvZoUqejqjx1+?=
 =?us-ascii?Q?j86zk5ZJMFUbjebtCjkfen4mPRVQXsT1giNWgmE2NvwuEMYyc2wbDDcYcQia?=
 =?us-ascii?Q?iRrUdD9RFGXQiWOsUDy5sdqsjDYkoocXpQSBtLBTaNVTFm9w5XfKlN2P129w?=
 =?us-ascii?Q?jsyr85OLfmhj/99LQR/6A4k4a1uH6gthg8LLs1G3mDfsu3h51FGLnZ6B+ZXq?=
 =?us-ascii?Q?3pgaJXrjAnb6eAU0JV9S7ZEB8vHVynFJDNLVQ+ZJxy6Khp4gJ5B71l0FZgs9?=
 =?us-ascii?Q?WOxNIAxOVbqdeOZ3d7U/CDP/sj+6J4Qs7564cDCeBgNB/aTLDMG7yWnArhVq?=
 =?us-ascii?Q?IltTf0A+OwuKHMD/tRjDZr7cNBOeCYy5qfxxnxqVQuh0pQcNwXfnYlpcUoaX?=
 =?us-ascii?Q?DkB9NdTfqQSpKdR3nE6Z59N89xUzRXAGor289YYY8PlwMjQBA9yCKSdpFYSE?=
 =?us-ascii?Q?USoGohonRNwdG9A9DzK2xK9EfLzFzVfpvSpxfxI52BQG05dmEI5zg2ClJxb7?=
 =?us-ascii?Q?yxgQOsKmLLVsvIe5snvRbmPglUTB40ujRPgAPAjBwFUK4aviPhlcpuZGmR1R?=
 =?us-ascii?Q?FwU/6Ab6TMIX+Qa/e2Cs0f2/LhlbT6aSDqpSLvic/+K4G3KKbwPB5ulGVqZA?=
 =?us-ascii?Q?73T6/haJ+ZxCvkCniTc7LPzVb/gJu61AikXti5cs74KwQswXEQ7zJptpoifO?=
 =?us-ascii?Q?mA70oYq+4+0o2/3dk1Yax+Ca56sDJaca9XfpjsqZ+DWFUP9Qm3xydRs0SgTh?=
 =?us-ascii?Q?Rwgu0UCp0JJknaOX9sDYgIO671k6CrIzcvxrwkbG+j7mzdoYbTXE3L0X2vdi?=
 =?us-ascii?Q?duOyWYyjPc6K6Vzo3HjzfO/QujkEzKh6GzPpoRHV+SSs998NnhyX9XDTcNrs?=
 =?us-ascii?Q?PMyylJI3yXrahvi1S7KL69RMs14Y5xJPvTyY3Jd1Fjf2dDvsD4IH4HxKZCIn?=
 =?us-ascii?Q?RiQYwbZJ19oIEQj7i8f3+A1YlO0y0qvtNHtKtZahsztRrNjz/9NEi1KXSoLW?=
 =?us-ascii?Q?99Sd9WebM88RRyCR9KKzz3Mokq3rmianC2rCRkiK/MhuyHOzTAmV5662CaU6?=
 =?us-ascii?Q?j6vTd4XORCwPsGeaJSKM2WsAO4+JFIbWEwx4RuG6BI800OujsIbfSlLlUSWw?=
 =?us-ascii?Q?ZJTrEjg+8QnmhdSwlDDGvJpvskXm/Mi+aZEsSDmVpggJF0AuW0Hqso88FJxA?=
 =?us-ascii?Q?y4gW9fbYL7F5R7MeuDaoRVf/gZ77iuRkykQ5TGfDqGhPdvZ2xLEDIeBdHsLl?=
 =?us-ascii?Q?ep/7GfXVfFvcyKbIj3Xm6gXsTjzRiwoqnlIUacRlRgsoHLjZq/FN+tbWenGp?=
 =?us-ascii?Q?h6EaFm3xJzvowq+L2aSPFkOYwiSZdLK63PcsYgzHUpTkZjFH8wfsU5kCvEGf?=
 =?us-ascii?Q?Y0DH3HU1TZu6+Oqe/9DUFX/MRej/Eo0JFwvpIUWa1P8Ig3PkFVSCKSVBOtur?=
 =?us-ascii?Q?JiF8FeMGC9yc3oZNET0jPzuZuMS3FHMOZMUUTQ4R6xiu86bztVVEVaSKqUhR?=
 =?us-ascii?Q?b6L4qfub3ZJXARnFmD5ALS8=3D?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:DS4PR04MB9822.namprd04.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(376014)(1800799024)(366016)(38070700021); DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?GDckNuxBMlQ6tO7imZgBktS2iBqdePhMcoN5EkM97DHXLxHpN8nwxMWAkyGH?=
 =?us-ascii?Q?PHfMXFbzT2oeYliWGCgWvRlD3IFKKr3s6nycw37x6lMZMV15w+zfKzraNCLw?=
 =?us-ascii?Q?zxw1c0uFSiDVthmTZS0BmgZqAU8e2PXd/FM3qs+66z4ldxvbk89S2HK++l/r?=
 =?us-ascii?Q?Umo9U8abeqY/ofM97ztxNFlef5eOo5CL6Qy0avM1ckt9ixNwUOQkXaChnPTz?=
 =?us-ascii?Q?nGh8otPo+oE/rIoAxK1aAe8N4D83OOMOZCfv2xVgxLoGXtSDbjMKBvJ2djc6?=
 =?us-ascii?Q?ztuv9IIlW/RNiKZs3JmFCgQU+V/Vnr+wyIzKXIuuPEu0AvXp2460CVvz4577?=
 =?us-ascii?Q?y84AOE+eX+sGdBxZbHPrmDykW6wiG1hmIDeFrw5tygEl3P8R+kYRTclJClIm?=
 =?us-ascii?Q?99PbAHjiZoKfAUOLSi7czMAk3ubR5EMpu7wTYNdy2HYqnB4EhEIS370dyOiI?=
 =?us-ascii?Q?SLuGUF3A/q/yexskC/hqm8YWfaVAxqjvSFb+tKvuI+xcV9T0NmsbNECVIVv3?=
 =?us-ascii?Q?t6jx41Mg/hNPgAQ3B1mKt3pvJLFONU0OsBahKiuPUNtjlx10TbBXi9sTbn1k?=
 =?us-ascii?Q?/ub+/Qg5eNLV5pcZxNbTnAFcSZMxd6uLBxQnJiOZZrBaPvpJtHkDeLOiOnU6?=
 =?us-ascii?Q?HLpf83q4tJyx2xwTACrxcRSEvNCytZ88V6eyRXPCp1DnX0WzuHPtaZofkquu?=
 =?us-ascii?Q?gCqahW2copOCkq7L8P3MzE3HBOb5OGkiTcZw2gozAxvd8mFke8yVD4+JavYE?=
 =?us-ascii?Q?3o2Zr4TLgFD3mnrhCmDDdU5GNWeb+f2hl8VrOOjOP2wtFcOFz3PO0jHiJIVu?=
 =?us-ascii?Q?buMoQ+3EYiZUsEgqNSdONSX7ewK8MzWX9lOlLKT/+TR8y0dUi6RdWID0VjeK?=
 =?us-ascii?Q?xx9vn68C1tXPJC1KADvoZBkFBnWPTf2wDrOkYM0jbQVm75PaV01gEehqNz8e?=
 =?us-ascii?Q?3eIy6bkDrKemBLSFu4vOm2SQYUxdgk+VICT39fxza+1ZyaEKABZDpQ4BP+JF?=
 =?us-ascii?Q?VnZezHmmDjY17RH4MMMZbrI0sRaw9yGS4V5eZgGkcwzWyWdWfZ1vsjF+m3wd?=
 =?us-ascii?Q?U1ICCe7MfNY6W5EcPywgybTmGczxOPPifA6xXraM+jQdG63NCmGsHkoP7Li9?=
 =?us-ascii?Q?MTdOt5wppkdv/wZzFCnJsOhBOrUwb+rTQ2iJhMy59cjyOX+Lf4q/6i+YvX1T?=
 =?us-ascii?Q?jwTHH2HBK7vVe/AloRjscwJ0e6n9qgjl4cfc5SmVoV72MJi6XELA/J1JYMNh?=
 =?us-ascii?Q?uW7djGTSuEco02rr3uaL3mbZehliHovW3GJMoIi0iMOSvbW2OU6ru89Fqe3Q?=
 =?us-ascii?Q?YemQgk3IY/OCAIxT3vEdd2+xMZpLFCqrRm/UVB1wR2XVk0KopVhq/cL3+5KS?=
 =?us-ascii?Q?6eI7nJuuxO7bRjXxJTNXVZnUmT5bwHKr5Z3+F0K2EIh4wH6d1bkdGs54cRK1?=
 =?us-ascii?Q?FLs60NGkiNRvNYzqgGBAgXnqLN3Ymsiu30FfvVFYTHNkbOC9rMADLsCwEovE?=
 =?us-ascii?Q?v+fZRQzKFnzczajtzOs7bJcmlu9Jtnl1twDxn9mRF8+2G5Z/il/9KYrovoQR?=
 =?us-ascii?Q?qCsEsyuj/L0g34Rti84jju4Gjs8uxSQut5JBJXr3H7yn2tVQ/evQ/OzIyenm?=
 =?us-ascii?Q?S3e6OzIjhgkybGtPF1AJJHSBUE9PRcavVW2MdCqyZJtGhdCtsjgR7csPI0+S?=
 =?us-ascii?Q?tSyfTk7/ypkJuMPrftYOF77bUpMCqv2SujztVmzAlVGQm5ukRcCGYr4sFeD2?=
 =?us-ascii?Q?Qt0uC5U+ZHNmaA1fDq/qebxhGe1Q8zSBwMqsxYDgeZDRCqw/niL3?=
Content-ID: <2B1701BFF545324690B483F8E006D9B6@namprd04.prod.outlook.com>
MIME-Version: 1.0
X-OriginatorOrg: thelustrecollective.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: DS4PR04MB9822.namprd04.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 32a096a2-a8ba-4f3a-a2f1-08de7401f4ee
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Feb 2026 00:08:08.5835 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 4c9dec06-8f2c-4233-98d5-ca3cb36218fc
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: CmZWdaxCqEZmTcMxt4dFIEcRP4yBeMcg2ud35IsotuBcSTVU5vxzJCevjEn7wkmYGQJ59c6fg72VOHcxdPmE4OIGrboQKAaxCBg5HxUEQi0=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: LV0PR04MB9857
Subject: Re: [lustre-devel] [RFC] RISC-V Architecture Support for Lustre -
 Patch Series Available
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
From: Andreas Dilger via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Andreas Dilger <adilger@thelustrecollective.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

On Feb 24, 2026, at 04:09, Abdul Halim <abdul.halim@openchip.com> wrote:
> 
> Hello Lustre developers and maintainers,
> 
> I am writing to inquire about any existing plans to support the RISC-V
> architecture in future Lustre releases, and to share our work on enabling
> Lustre client functionality on RISC-V 64-bit systems.

[snip many good reasons for supporting RISC-V]

I don't think there needs much "convincing" for Lustre to add support
for RISC-V.  The main obstacle for doing this successfully is that
Lustre developers do not have access to RISC-V hardware for testing.

Advancing RISC-V from "it works *right now*" over to "it is supported"
needs someone to host hardware that can build new patches/releases under
development and run testing on an ongoing basis. That avoids regressions,
provides much needed coverage to find occasional failures caused by race
conditions, and ensures these systems continue to work going forward. 


Realistically, having 6-8 RISC-V machines running VMs should have enough
capability to keep up with patches under development to at least build
and run basic client testing - runtests, sanity, sanity-lnet, and maybe
more as time permits (patch production is definitely not uniform).  Each
host could run several VMs (4 cores, 4 GiB RAM, some NVMe for the builds),
doing a build and testing it as much as it can.

Unless you have a fundamental objection to doing so, it probably makes
sense to start with x86_64 server VMs (4 cores, 4 GiB RAM, 1TB NVMe or
16GiB ramdisk MDS+OSTs) just to isolate runtime issues to RISC-V clients
until they are robust, and then add RISC-V servers afterward (once manual
test/fix is finished, and pending additional test hardware).

I'm not very familiar with RISC-V, so some important questions:
- does it normally use large PAGE_SIZE (e.g. 64 KiB)?  Large pages mostly
  work (also used on aarch64), but occasionally needs fixes.
- does it use little-endian (preferred) or big-endian?  We haven't had any
  "primary" big-endian architectures for ages, so it needs work to fix.
- does it have strong or weak memory ordering?  There is likely code that
  depend on x86 memory ordering semantics and will need to be fixed over
  time.  ARM has weaker memory ordering semantics and fixes are sometimes
  needed.  Lustre has been around a long time and race condition testing
  is pretty robust, so I don't think this will be a huge issue.

> OUR WORK: LUSTRE 2.17.0 ON RISC-V
> ---------------------------------
> 
> We have successfully built and tested the Lustre 2.17.0 client on RISC-V
> 64-bit with a minimal set of patches. This work demonstrates that Lustre
> can be ported to RISC-V with relatively low effort, as also shown in
> recent academic work by Billa et al. at SCA/HPCAsiaWS '26 [2].
> 
> Patch Summary:
> 
> Our patch series consists of 8 small patches targeting:
> 
>   - Build system:      RISC-V SUBARCH mapping in autoconf
>   - RPM/DKMS:          Architecture-agnostic paths
>   - LNet:              RISC-V hypervisor detection handling
>   - llite:             Guard for prefetchw() (x86-specific instruction)
>   - Erasure coding:    Enable optimized paths for RISC-V
>   - Debug tools:       RISC-V target in crash tools
> 
> Total impact: 9 files changed, 19 insertions(+), 8 deletions(-)

Great.  There shouldn't be any issue accepting such trivial patches, even
before the testing systems can be brought online.

> Test Environment:
> 
>   - Primary:    Ubuntu 24.04 RISC-V, Linux kernel 6.8.4
>   - Validation: Fedora 42 x86_64, Linux kernel 6.16.4
>   - Result:     All 16 client kernel modules compile and load successfully

Beyond loading the kernel modules, have you run any testing on the code?
Running runtests, sanity, and sanity-lnet would be the minimum to show
that this code is functional beyond just "it compiles, ship it" ;-).

> QUESTIONS FOR THE COMMUNITY
> ---------------------------
> 
>   1. Are there any existing plans or ongoing efforts to add RISC-V
>      support to Lustre?

Lustre is an open development community.  These things happen when someone
makes them happen... IIRC there was an email to lustre-discuss a few months
ago, but nothing came of it AFAIK.  You are the one with the most interest
to get this working and keep it working, so it falls on you to do the work.

>   2. Would the maintainers be interested in reviewing our patch series
>      for potential inclusion?

Definitely yes.  The best way to make progress is to submit the patches.

>   3. Are there specific testing requirements or coding standards we
>      should address before formal submission?

There will be a lot of automated testing on the patches, but it will all
be done on x86_64 and aarch64 systems, so that will only ensure the patches
do not *break* those architectures, they won't show that RISC-V is *working*.

> NEXT STEPS
> ----------
> 
> We are prepared to:
> 
>   - Submit the patches via Gerrit for formal review
>   - Create a Jira ticket to track this feature request
>   - Provide additional testing data as needed
>   - Collaborate with maintainers on any required changes
> 
> The patches are available in our repository and we can submit them in
> whatever format is most convenient for the review process.

Great.  There are resources for contributors, but feedback on the content
and process is also welcome, since it is sometimes neglected:

https://wiki.lustre.org/Development - overview
https://wiki.lustre.org/Submitting_Changes - submission process overview
https://wiki.lustre.org/Using_Gerrit - details on pushing patches
https://wiki.lustre.org/Commit_Comments - details on commit message format


> REFERENCES
> ----------
> 
> [1] Nick Brown, "RISC-V HPC Gap Analysis", RISC-V International, Oct 2025
>     https://riscv.atlassian.net/wiki/spaces/OLRR/pages/895778831/HPC+Gap+analysis
> 
> [2] Surendra Billa et al., "Porting Lustre File System to RISC-V
>     Architecture", SCA/HPCAsiaWS '26, ACM
>     https://dl.acm.org/doi/10.1145/3784828.3785406
> 
> 
> Thank you for your time and consideration. We look forward to your
> feedback and the opportunity to contribute to Lustre's architecture
> support.
> 
> Best regards,
> 
> Abdul Halim
> OpenChip
> abdul.halim@openchip.com

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
