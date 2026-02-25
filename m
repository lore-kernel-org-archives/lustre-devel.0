Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 82C01FD3762
	for <lustre-devel@archiver.kernel.org>; Wed, 25 Feb 2026 14:46:50 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4fLcq45kkTz23LP;
	Wed, 25 Feb 2026 06:46:24 -0800 (PST)
Received: from AS8PR04CU009.outbound.protection.outlook.com
 (mail-westeuropeazon11021139.outbound.protection.outlook.com [52.101.70.139])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange ECDHE (secp384r1) server-signature RSA-PSS (2048 bits)
 server-digest SHA256) (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4fLcpT2lvyz1y2x
 for <lustre-devel@lists.lustre.org>; Wed, 25 Feb 2026 06:45:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=xV+aNl4lneN5aFyX0TEXkW0VVQkJs6GTJJJQDKc3V7Q029xmcqbj8iSvet6JlbG8EWqq5nHchq4/ymWP46lw1ryF4osEpEtxdsymM6nZlEMciFTnFz+HhjeN8WYrC1WBiULbq/MA3Rme07lpfUkHMyo8YIoSJIk4CZm4eiVrVVOcD/x1IrRSSYs+xW+NVU6g7kru4UfqfOtKdtIozkq17cJK9T4KuOFCGY/40QVlFyVad7/BggInclYgtVuKlDB8nFFIPwKxekbVjCBzEmj6J0akeraOn+CB7C2ZW+eJMvD9giEPyofXZ4iZhzVPvWWUaUFPPhm4VzX9LN5/+q63PA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=DKUEvlurfS5V9PvGOEiW4e5pyaN0DgEIoaRhOtdpxX0=;
 b=qptWpMXGnGbsJAD8WKDWDe2XoZ0h9tmJUSTfuELH/EnYb9FhVnHl1DgMAKOVgKNUZBML41ExzBYbIuJtPIIUZj1v++sxJlcpft70mJzIlcc5c3o+ILsf90Tskvyi+esJNoee1bAX6coTwPNjHUjv0BHXJXwgzoKJDm1ZjoOiRVFU/rX0iWkScp//k2RSWP99dcqmx8rqNpY82VQE047VmnhKbA8D0yGtHg/yhhd/2CV+ZaYmCUq9DGrNg7d5wweBI2dlpvC9M4COuGZW4u13Q6qFx6u7SaRZsEPMIeXCktNOwBqWgK/zBDDHcveVUoQV34S1gcbtrGH/OWe2KMkOdg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=openchip.com; dmarc=pass action=none header.from=openchip.com;
 dkim=pass header.d=openchip.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=openchip.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=DKUEvlurfS5V9PvGOEiW4e5pyaN0DgEIoaRhOtdpxX0=;
 b=YxvAA9dygiDu2jTdP9gONAl6UDWGgbWO+gsbZ/FHZY3YXufh3kpPbpvPgUsmYoBOc2LvY2c56af/AvXbNl1seFIIV8HdsL1hVQW9VbRKK0z0ZRT2rMRVXiHM9jYHBEmDwdez5Cjj0Kf+u08aC/9o0P3IHTlfx6Q2L6anaWEij2waXraOj358+D1lwEGwrog1Y/X4Q3apIoji5cFCvsLHxinmEx3N/3Tv8c+9auwO28nJLYVxAlg9oZE94f8n0RRXeyZ3+vaJGfF0wf0Ii2VrECEdehoeQYMiiU1ggVJfO95yGbbBcsV1eDEUscPzdF1rfkyCD7CDprBPnZlVlUykRQ==
Received: from AM4P192MB3108.EURP192.PROD.OUTLOOK.COM (2603:10a6:20b:6e7::10)
 by AS8P192MB1775.EURP192.PROD.OUTLOOK.COM (2603:10a6:20b:527::5) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.9632.22; Wed, 25 Feb
 2026 14:45:49 +0000
Received: from AM4P192MB3108.EURP192.PROD.OUTLOOK.COM
 ([fe80::65f9:6768:38be:7c0a]) by AM4P192MB3108.EURP192.PROD.OUTLOOK.COM
 ([fe80::65f9:6768:38be:7c0a%6]) with mapi id 15.20.9654.007; Wed, 25 Feb 2026
 14:45:49 +0000
To: Andreas Dilger <adilger@thelustrecollective.com>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, Nick
 Brown <n.brown@epcc.ed.ac.uk>, surendrab <surendrab@cdac.in>
Thread-Topic: [lustre-devel] [RFC] RISC-V Architecture Support for Lustre -
 Patch Series Available
Thread-Index: AQHcpX2uN8JgksagukyKgUAO1ExGirWSipwAgADt3ew=
Date: Wed, 25 Feb 2026 14:45:49 +0000
Message-ID: <AM4P192MB3108E3121123CA56A593EC7A8275A@AM4P192MB3108.EURP192.PROD.OUTLOOK.COM>
References: <AM4P192MB31086DEE0D7ED656ADF8B3EE8274A@AM4P192MB3108.EURP192.PROD.OUTLOOK.COM>
 <08AF9B7E-CDF9-46D3-881A-D651D8D1F294@thelustrecollective.com>
In-Reply-To: <08AF9B7E-CDF9-46D3-881A-D651D8D1F294@thelustrecollective.com>
Accept-Language: en-IE, en-US
Content-Language: en-IE
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
msip_labels: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=openchip.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: AM4P192MB3108:EE_|AS8P192MB1775:EE_
x-ms-office365-filtering-correlation-id: 571fa4c1-3434-4181-d2ba-08de747c9174
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|366016|376014|1800799024|38070700021;
x-microsoft-antispam-message-info: FryMIxvtoV+yJSx7QLg1LVpBUBN4ax3YgbgntuDBbpngB0apfcXMgSdLZmkXT7yOWGwj4g3p06pA3At8VkpsHPjb76kiQGZ8iXYNvokBG7niVVDaTNt649ZJzvOwACr9BVW0wiVVpAA3jEfTIjKXNiv0iw4M1CRaOTFLF0YcUaVPY5JJapF/zCw9acrGat1BfLUpB5OLJ7CEbO4+OgpJDv3CSfWlK17oHP638FdFD4+8Q3tH2KK8wUzheOFCB03uTJ2DXSGQJRWRnDQrGek2TXy1kiBK4kEp54W3fiJFzadsNV8MDW6/uXKb6wc+tYQoixpm7cqvVQWa8zejGmunq+vKZwKcpjoF0XjfEDOhe2cdysjZ/33/ACdMzfYNV9WWhQAWgJez7oviOJ8lq4tiMEwnYYl+tGwc0ZCwA09HWxmeiXKut0Bps+0ZgraYHxKCwaUHAYJCfBk0Ydl8d4lRr++ajkFgdDNJBu2ttYhiLXn8QR89jQoG8mXOXvAbsTQZJY0XJHfZGYTxss1D/AtpO3s4/AIpM1unI+TWw4+E5kZ/EXMtFlVNXR3O/iG8pxv+qvYLHpOkrShPMhtmTPIyBxlmBEJWx5aWyMwgnNU7FV2C/QpAvj9F6U1pEli1lHNUkIX0avhz8qwqhe9R+7xUfFjNvfLBlMQoGv2ELiP4f6jf/RaxElUqaYCeH1aIRlVim7JCeXQ1vHo7eFyWfcMI8pJvhzYNDaSfE6/Qi9S0m+nbczBPo5rhKDd2pUpnJBjH93xP17BV8S3yPzkNO9wzfSmTPACKj+Gbwt/HVWMZ0ZA=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:AM4P192MB3108.EURP192.PROD.OUTLOOK.COM; PTR:; CAT:NONE;
 SFS:(13230040)(366016)(376014)(1800799024)(38070700021); DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?iso-8859-1?Q?yLb/wpSNeSCVMcr2ih7RHSzySLn5pPF4VosXSav4FUAOEhCJKV1CHLF+R4?=
 =?iso-8859-1?Q?KMX3saPh00wsgDk7A8eWShZhfJGELuR/ObY7TYtU6Nj2jIgbaWLyVlqt7s?=
 =?iso-8859-1?Q?24z7ov9lXzvc5AJiP1eM3PY5c+faEG1O/IsigkE9B7bjb1tmzROuGkneKE?=
 =?iso-8859-1?Q?4ZuMIYiXB7322aLJmvZ7qi+B6NgrO73MnzhHq69NxZ/jfxOxPwPkvlHEV8?=
 =?iso-8859-1?Q?DFiXYZ5eBnnug/czM4KH6r9eSwSvZMffs6MQQC49eUUk5ChT9aZEiBl9qg?=
 =?iso-8859-1?Q?4bWdMh2Gc01KX6ViZ/OruS/t+4+BWktT1n6PzevYf1S5iFX/QFOkGkGRFP?=
 =?iso-8859-1?Q?zxiTffP6+i9vScF6Ky6nhPnXX7Y3hbozoblyRTl1lWqoB8HAs6HlWHFBuq?=
 =?iso-8859-1?Q?aDe1mKoeSTjSqXReAR4bGlqGu7+HDJiNji8yknkKTZjVH+O7TfzdodGW8q?=
 =?iso-8859-1?Q?d99s80VH3Q3O3vW7YHORKLo7vji+P7+IC05U/ZzxrWJps5CwG2cnwpHroH?=
 =?iso-8859-1?Q?BtS+2Ie+pE3sy7A0NQLXoPh7GQ6Rwh/c27AldhL4rI8LCISQUJP8zS3K47?=
 =?iso-8859-1?Q?Bn7wNywxMiHra8DV80aVRJHPnVpQaNDTq1kGh+8wSsDX75M2wb9o66ApvA?=
 =?iso-8859-1?Q?bMFRs9jqeeLejcpzjjY5h9KM/yv6RyngqhPbmgeplJxvsOTcC+Ar3rHJwO?=
 =?iso-8859-1?Q?0uFYyDxrQKbl4sNR32fwHtlEc/1b3R5/dycVwv1ub0PW66dAnSGtobOYIc?=
 =?iso-8859-1?Q?xABxMwMaLs0Qf8fgwOHiR3Nkdk2r0n5nlt91JAE3N7jYiIT5rdDSfZqs57?=
 =?iso-8859-1?Q?+meaVzANb9ZjLu2RwgI3pBapCG7VpqxItxdSmmqRSwp/LgvEIWAH1q0RmA?=
 =?iso-8859-1?Q?eWmgGp6WzGUsbG+899uM5CrCVpL0aRlYa/wVWk/9WxcQnq+f9nuUCDPWez?=
 =?iso-8859-1?Q?PsR5FL8wfl/klriJFK+PgoG4cs1eAGCiSGt8WFYRoYSerm5S1V9ReFGgIu?=
 =?iso-8859-1?Q?F1XduxVzk5YonCOHvY0bMiyuC9E1j+qv9PY1hEn9OlPlqHHjWif7XIRc2M?=
 =?iso-8859-1?Q?kdedomCMbY4BBXTUcrrvqBTsftr8Qi71NtcD9QGUnQR5pBB7CcIqKz4xRX?=
 =?iso-8859-1?Q?NIHUGq6KA8er1HlB2ZQIHmarVLKAdLec2N+tuqLSSVESeXCynDYM+pT3Qh?=
 =?iso-8859-1?Q?5vBWo2BHEIT5enc37nN+OFqRLhQULIsJwxeRZ4hnzIh46f+il9NpwCdo1H?=
 =?iso-8859-1?Q?lc9mKS5MjJFa6sySRRzEp3Y+9mmU/6aZG9t1uNSiMIxKi1w3BLtRgXTFAR?=
 =?iso-8859-1?Q?wJ8aPWg/eYpd+384IOMbRAfvugE002VcQ3w+CUbub2Rojfp+ET5+dOyN6f?=
 =?iso-8859-1?Q?OXpe72C+5PgPACB2IvW4RpbFQTe1B8mk3Ekz9OoIRHSbi3rM2BxITR+AQo?=
 =?iso-8859-1?Q?mVQhcppcU6TV19Ec/zjofuQw9yPE6iVFmBs7AI3+vNPpXpgSLgMUc4zVIM?=
 =?iso-8859-1?Q?imE7etBHJD7Fu9iRGN8iYA34vCI6gI8rvLB+WzRGdWzssQ9G/Or6ZvGAyR?=
 =?iso-8859-1?Q?RLUMciuvuFpHJLpM6en9k2KHeEMxQdxdJ6NanEOpHsOLvRZbY0wpnkuNez?=
 =?iso-8859-1?Q?Lr8KyO6AVBueH0IIOQHVWpbsnGUoLZKFe9XNRrCheShRZ9vB7tRyZ0+QJC?=
 =?iso-8859-1?Q?6NNCHVTEt8ZghNE/5utiPxLe9NkNtPt+N1w+gK/D+xwwaCBOGprdN01VGF?=
 =?iso-8859-1?Q?XGnAlwqZujAFRL2I5euYyVs2E+NvaDGNgifCP3vfs/WDG2BUzUM8p9Gt/G?=
 =?iso-8859-1?Q?yF1QMZxkJg=3D=3D?=
MIME-Version: 1.0
X-OriginatorOrg: openchip.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: AM4P192MB3108.EURP192.PROD.OUTLOOK.COM
X-MS-Exchange-CrossTenant-Network-Message-Id: 571fa4c1-3434-4181-d2ba-08de747c9174
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Feb 2026 14:45:49.7925 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: dfdd4aff-e2c9-4e1a-8642-7f6cc6bbbe6d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: g9Arb7l0TP8aQOBCFjRhOaCJP2Um7V2xgAR9PiGf45b3YMaaMW9L9KsNaYPuaxcJ6yqHD6bulFjWArpB3GPCRsgGj0KS+b9GDE7kuA0Ezy8=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AS8P192MB1775
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
From: Abdul Halim | OPENCHIP via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Abdul Halim | OPENCHIP <abdul.halim@openchip.com>
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>


Hi Tim and Andreas,

Thank you for the feedback and great questions!

I will try to answer your questions below with best of my knowledge
and additional research :)


For CI/CD and Test
------------------

All of our porting and testing work was done using QEMU RISC-V VMs.
This approach could be integrated into existing Lustre CI runners
without requiring new physical hardware.

We currently don't have physical RISC-V hardware. We can share QEMU
RISC-V VM setup scripts/docs for Jenkins integration if needed. This
could bootstrap RISC-V testing on existing x86_64 runners until native
hardware becomes available.

Beyond module loading, we've done full mount/read/write with multiple
RISC-V VM clients and successful FIO and IOR benchmarks as well.
We haven't run runtests/sanity/sanity-lnet but these should work
without any issues. We will do these tests before submitting patches.


> does it normally use large PAGE_SIZE (e.g. 64 KiB)?

No. Linux on RISC-V uses 4 KiB pages (standard PAGE_SIZE), same as
x86. The architecture supports multiple virtual memory modes (Sv39,
Sv48, Sv57) but all use 4 KiB base pages. Superpages (2 MiB, 1 GiB)
are supported for huge pages, following the same model as x86_64.

Reference: Linux kernel docs, arch/riscv/vm-layout.rst [1]


> does it use little-endian (preferred) or big-endian?

Little-endian. RISC-V was designed as little-endian from the start,
intentionally matching x86 to reduce porting complexity. The ISA spec
states: "RISC-V was originally specified as little-endian to resemble
other familiar, successful computers, for example, x86."

Big-endian is technically possible via privileged mode bits (mstatus),
but all mainstream Linux distributions (Fedora, Ubuntu, Debian) and
hardware run little-endian only.

Reference: RISC-V ISA Manual, Volume I, Section 1.5 [2]


> does it have strong or weak memory ordering?

Weak memory ordering (RVWMO - RISC-V Weak Memory Ordering). This is
similar to ARM's relaxed memory model. Since Lustre already runs on
ARM64 which has similar weak ordering, existing ARM fixes should
largely cover RISC-V as well.

Reference: RISC-V ISA Manual, Chapter 14 "RVWMO Memory Consistency
           Model", and Appendix A "Weak Memory Ordering" [2]


Once again, thank you for your positive feedback. In coming weeks,
we'll prepare our patches and submit to Lustre Gerrit for review
and validation.


References:

[1] Linux kernel RISC-V documentation
    https://www.kernel.org/doc/html/latest/arch/riscv/vm-layout.html

[2] RISC-V Instruction Set Manual, Volume I: Unprivileged ISA
    https://github.com/riscv/riscv-isa-manual/releases/


Best regards,
Abdul Halim


________________________________________
From: Andreas Dilger <adilger@thelustrecollective.com>
Sent: Wednesday, February 25, 2026 00:08
To: Abdul Halim | OPENCHIP <abdul.halim@openchip.com>
Cc: lustre-devel@lists.lustre.org <lustre-devel@lists.lustre.org>; Nick Bro=
wn <n.brown@epcc.ed.ac.uk>; surendrab <surendrab@cdac.in>
Subject: Re: [lustre-devel] [RFC] RISC-V Architecture Support for Lustre - =
Patch Series Available


[You don't often get email from adilger@thelustrecollective.com. Learn why =
this is important at https://aka.ms/LearnAboutSenderIdentification ]



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

do not *break* those architectures, they won't show that RISC-V is *working=
*.



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

>     https://riscv.atlassian.net/wiki/spaces/OLRR/pages/895778831/HPC+Gap+=
analysis

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





The content, data, and any attached documents to this email are addressed e=
xclusively to the addressee and are confidential and/or may be subject to a=
 non-disclosure agreement. Any use, forwarding, disclosure, and/or copying,=
 in whole or in part, without authorization is prohibited. If you have rece=
ived this email in error, we apologize and, please notify the sender or Ope=
nchip immediately, and delete it from your system.

El contenido, los datos y cualquier documento adjunto a este correo electr=
=F3nico est=E1n dirigidos exclusivamente al destinatario y son confidencial=
es y/o pueden estar sujetas a un acuerdo de no revelaci=F3n. Est=E1 prohibi=
do cualquier uso, reenv=EDo, divulgaci=F3n o copia, total o parcial, sin au=
torizaci=F3n. Si has recibido este correo por error, te pedimos disculpas y=
 agradecemos que lo notifiques de inmediato al remitente o a Openchip, y lo=
 elimines de tu sistema.

El contingut, les dades i qualsevol document adjunt a aquest correu electr=
=F2nic estan dirigits exclusivament al destinatari i s=F3n confidencials i/=
o poden estar subjectes a un acord de no revelaci=F3. Est=E0 prohibit quals=
evol =FAs, reenviament, divulgaci=F3 o c=F2pia, total o parcial, sense auto=
ritzaci=F3. Si has rebut aquest correu per error, et demanem disculpes i ag=
ra=EFm que ho notifiquis d'immediat al remitent o a Openchip, i l'eliminis =
del teu sistema
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
