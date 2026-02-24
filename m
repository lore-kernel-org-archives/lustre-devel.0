Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 06C88E9B250
	for <lustre-devel@archiver.kernel.org>; Tue, 24 Feb 2026 11:10:18 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4fKw3x1DQxz20ft;
	Tue, 24 Feb 2026 03:10:05 -0800 (PST)
Received: from PA4PR04CU001.outbound.protection.outlook.com
 (mail-francecentralazon11023108.outbound.protection.outlook.com
 [40.107.162.108])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange ECDHE (secp384r1) server-signature RSA-PSS (2048 bits)
 server-digest SHA256) (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4fKw330hN2z1y5q
 for <lustre-devel@lists.lustre.org>; Tue, 24 Feb 2026 03:09:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=miLT5LZx1ZOgyV3PHHn6nWgOey/rIvxzR6tZm0xnk/8hFIVKmq/YJE7HryfZoo3NCvstJ5XfDwz2Nrz5AuX0MeMINHYLmIFWFDp0P+hVcD+c4A3CYfnDHr5T3V11VviXGjd8F1E5tHSej4/E57goySy3Qe1H1Zkf/lnqRVcMFjOyPqc0XuoqbIdAI27W1YKFIupAek81WM0O7OqmOHhIvI9DJrSJop+VwvfDDXjtFlTdxObj7FGNukMmDsVjg2LD+9WXKvdguDI3A0zpldWcIDnFm+ttV834OXo7+x+7cwb97FICtMrlrXPR6YKL0rhRLvn9VKggE98Zo07t8XA/uA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=1FAxVzNej8bwtA/tBSlLg3eOYknGZyIo4H0nXiapS3U=;
 b=rYLwHpnV/uUrv+//qoHKmUgHkVl+JbaHZ6VOD6d/pQ7J1PPv9H2vcPaTrfvfNn8yqiNqXqyL31M1FuTn6IU+LdJyuXfqEcPoUnwhu5GloVscBXOYtn8wpWy2FJHZ9HSanhIMCstU21wKosX0Gt/Ie0OmLZAF/pvXWfBxgONc8oF7+IT21mP/OykauVTwR/4ZPe11wHvtrhsHCetsoO4ZP28LaGJexA1zokPStM8dyS4cLAhBI9Jd77LKTUpTE+I432ZhuNr8pqvQcxFj2Vk2qwjABWgW9Y4SP00XbRlCOnl5WV1/3YVFjFMv2gWtDU8fgHp+DCTiOTj93TvAwBKjew==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=openchip.com; dmarc=pass action=none header.from=openchip.com;
 dkim=pass header.d=openchip.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=openchip.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=1FAxVzNej8bwtA/tBSlLg3eOYknGZyIo4H0nXiapS3U=;
 b=khlf0n6nsXBcKaMqGl6sCXhtHC1Mfyd5qpk4pDZDAPuoNqNH6L1KF+goqCCD5rRL8rAKPdGIHzK476wMUMXb73i1cZ1BZk5qMA2Lo9T06iLOV43veP7YRtXJTgjw6Qel2tnjxLc82eFjrQQVOC9qfEnMaUUIKiaX6Mu2kAqBcfZoIgh35G0N4xPj9WHJNxaDnZYm+T2rlT8BaR40lpx290kHWdUPyMBY7nEYOiSkVQe9DSkIRRqVnUH/iofyBCJdro7LphrXddbKFMhylsOjCwwkyKYNCIFs8jRg3hRt5TtPE/q5Nu4FQGrQIgS+YEGv88t6tdcLn2IIazuqbWrG8Q==
Received: from AM4P192MB3108.EURP192.PROD.OUTLOOK.COM (2603:10a6:20b:6e7::10)
 by DU4P192MB2349.EURP192.PROD.OUTLOOK.COM (2603:10a6:10:55e::17) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.9632.21; Tue, 24 Feb
 2026 11:09:15 +0000
Received: from AM4P192MB3108.EURP192.PROD.OUTLOOK.COM
 ([fe80::65f9:6768:38be:7c0a]) by AM4P192MB3108.EURP192.PROD.OUTLOOK.COM
 ([fe80::65f9:6768:38be:7c0a%6]) with mapi id 15.20.9632.017; Tue, 24 Feb 2026
 11:09:15 +0000
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
CC: Nick Brown <n.brown@epcc.ed.ac.uk>, surendrab <surendrab@cdac.in>
Thread-Topic: [RFC] RISC-V Architecture Support for Lustre - Patch Series
 Available
Thread-Index: AQHcpX2uN8JgksagukyKgUAO1ExGig==
Date: Tue, 24 Feb 2026 11:09:15 +0000
Message-ID: <AM4P192MB31086DEE0D7ED656ADF8B3EE8274A@AM4P192MB3108.EURP192.PROD.OUTLOOK.COM>
Accept-Language: en-IE, en-US
Content-Language: en-IE
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
msip_labels: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=openchip.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: AM4P192MB3108:EE_|DU4P192MB2349:EE_
x-ms-office365-filtering-correlation-id: bef0c83c-74c5-42f6-6180-08de73952603
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230040|366016|1800799024|376014|13003099007|38070700021|8096899003; 
x-microsoft-antispam-message-info: =?iso-8859-1?Q?e5xcQsF1MmG4t66IvzOYAuBudvB+/e/7jOwpX7Oz/vLEpgCPlQPrPG18O9?=
 =?iso-8859-1?Q?PEYn3zOef/Mb0XCh6hN7/ou+j9Pj7sO2EUgepMlpD12vS0/Pk3tad7BS4U?=
 =?iso-8859-1?Q?i50WtHPsZrD7AlyuVbg6dBlJ/C95N+wj/rxU0Pq7iJdSThgJWEgn4oy0lG?=
 =?iso-8859-1?Q?mTzpr9H3VNX77gqR1a20J0eZ0I7aCVkDXYVxMZkAjHa45kUQ1JvJeFEza8?=
 =?iso-8859-1?Q?tnriN5JOesV0eeFErxAR9sMLmXoyZaUPOWeCLwVkPqHWIftOWo5wH/hLZf?=
 =?iso-8859-1?Q?zX7Eh6mF9/50aIdtNYJ4uuvamEI0rT/fP4ZAOGnDbnjfu8ETSsfRKo08MB?=
 =?iso-8859-1?Q?xepNgT/nkIojDfLY3YI9exjnrSIHwahIa+k0TYpeVWgI//NbMwQLLs029Y?=
 =?iso-8859-1?Q?oOQBFku1Tm1bnsoHssh5p9R9hj9dbylJ+VO+wpn4BpMc3fJoLn07IWTSOz?=
 =?iso-8859-1?Q?Qt9luuYy/JL1RZOrxXMZD7pc4caEMDpsySxKy++XxH5/BJxM2Qz5IpJWaG?=
 =?iso-8859-1?Q?DGY/ILexdzkXdWV3u9K0786Gw6DKlV/lYzJdK047wsk8aA1CCPoe/pBTBn?=
 =?iso-8859-1?Q?spF/v8h7gtAdVYIdoVG0obSMbb4JTRvCobkH+wyDqk6u5K/4+/1NKn2160?=
 =?iso-8859-1?Q?rdn9NjQslvNLJXpXRL4O+AHuRtvKb+zMOZkzy7uR5XQ59TJPdqETLUElCv?=
 =?iso-8859-1?Q?ITopZq2l2w90+hFXU7FMPpltp5bLV0tp5pu7bQnLPwDHSiZehOTNTXxxJe?=
 =?iso-8859-1?Q?tHnrGbSyKTfJVF6RdGRJ+BpVWTAI3fvMvMO1UpFvBZf4u6EaunBvJnYH+N?=
 =?iso-8859-1?Q?VA+G2F/hogrrHU6D+jAXqoVYL+h1Y/wzMlBylQRnwlFcE4eNQQOkElPNCk?=
 =?iso-8859-1?Q?tndzS8ALoC4OCGGgPwXSwijE451nzAVR/YOO3ayJpwfNB8BAyQ4Sn1/sN2?=
 =?iso-8859-1?Q?WyN1WW2+mQxoC4pcMufwFXPHeufIQ+WhL7cS0tOnVJKWvm7ZmyhOvJ10Yy?=
 =?iso-8859-1?Q?9njzKtk+Bo/xxCMUzZoAlSIk+lttsQ//UJB4qo9ut7oOS1er9w4NY9Cs+v?=
 =?iso-8859-1?Q?qRye1y2gFYXqGJlAHUFwcyage6yw1l/yWSHf9Q5HR+J1ExO+Gfb4eQslAD?=
 =?iso-8859-1?Q?VDJTY/CuOGwAL5crFhcwnQ/IwRZHXJRLmYAtOt1r/nzJSNyxmwtvI5HQmu?=
 =?iso-8859-1?Q?10SkipY2A+V0oDrdDpW5627t8KEvL0eY1SeirExuHo8ZKKYo7uoWoFndkM?=
 =?iso-8859-1?Q?VxQqowDjJ1BRzAX4AG4ulrO4GaQmScQqlSPlVagZ31X6uBVXjeaEyLgewo?=
 =?iso-8859-1?Q?DCyYpoYkSYSCUQqw607PAW+GdeGbefj/Gl5gJg6gmcdXEzDgdBvaJlcqFP?=
 =?iso-8859-1?Q?ukqaaZBf08VzjAlUKU8z36OSnbPZUNOuefq+IiZGyPZdPclu3A/aISUU/z?=
 =?iso-8859-1?Q?+ZklgZFC9WH2r0qVUtTpLH+nV9m7m7kwyieta5ebLiwbxH8NfMzw3YZavX?=
 =?iso-8859-1?Q?n/85Zxd21Z749rBmETe7E6zj2R+2O3LKyKjzPqjWkNXOVbfNJBmf0VX1IF?=
 =?iso-8859-1?Q?JDAFaWjwTWobJ4cYjGTdUxWGPOIQ2CyEnvmNijpEO6u9ast47Eml/kubtt?=
 =?iso-8859-1?Q?AD1bG5YKTHWzO4IuMmoDJtqpu5tm1qhlx3?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:AM4P192MB3108.EURP192.PROD.OUTLOOK.COM; PTR:; CAT:NONE;
 SFS:(13230040)(366016)(1800799024)(376014)(13003099007)(38070700021)(8096899003);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?iso-8859-1?Q?3jArA/ztzqqRi466myp9SEFr6REXeoDJSbH+94ANMqXteSDQZ9W0C3yUUO?=
 =?iso-8859-1?Q?Fjq8HYXqiU+ddnNZd0rjx/CM+UHDLapvn5CE4iVGBcJfUFLbuE8WoHdcNB?=
 =?iso-8859-1?Q?RSiWQGCMck4hlOwOfbFAyCqoq/Yi01DCqAZNIfx4tU9lMNFkR2ynC4AIyQ?=
 =?iso-8859-1?Q?L94IZqsNx3Fj+l9hZpcNqiIEXRcyMivmGinUtBquQhME8O36xN65O3Xeu4?=
 =?iso-8859-1?Q?uGeAsp6e+79d8WRGoMQ97Y0tx324Mkfc+JLqWPSqEgcBGsLEc2mi93ewHE?=
 =?iso-8859-1?Q?b0tQoFD45eVwf6s0atuJE5ARGnCA2bzhPcXhaUKnaYp/NMBd20dEfLSFEO?=
 =?iso-8859-1?Q?0znyJYc7AN0jovYFWXUOzp+RM45cFwB+gYSgKFY17zSE2ni+0r/ywRJG+6?=
 =?iso-8859-1?Q?urzU6e8cRw30N93n/NTmOoIGyJnLO48hO5fYMBh3bBwkXuckC8YKbunM2O?=
 =?iso-8859-1?Q?zMrr8YOIOR+3OLyrZVodeozBwA5KphxEQ4QiParUVCf/btO55Iio4QlDCJ?=
 =?iso-8859-1?Q?cWuE6U85sZLQumW1O9H/yYAAIozzCRTyU1SUJqu+stBLvkiVsFSl7M0kyX?=
 =?iso-8859-1?Q?D5MUdXVKhXGVG1hFl7S1dT9t/Lt1YVindt1fgy8TJlPPSYQv/5JKRnD2f8?=
 =?iso-8859-1?Q?rylv64iEc8AI0uWCD0+KOlw4C+zzGWi77Z9Lzbrp2FE7rhU+KvQ9tmyuxK?=
 =?iso-8859-1?Q?NygHu3IVjpLLeL4F+IT1qYM8iAC+7umN+BQkBLQeg1REY/Hi0g7UVydRnv?=
 =?iso-8859-1?Q?HmsZ/tyVsaoDBAXDrQ6ewVVa94+PuKbGJTbOBJ+kyOKSUWILg/JuhUAFZo?=
 =?iso-8859-1?Q?XDKKLN6iNhf+Pr8waSrzJC/T5/YkZTt9K4tEaJdvtsFVquqov/b8ferhED?=
 =?iso-8859-1?Q?CHb9lAj0AJ7QCpYMktKvhReljA2g0DBKrpk7Q1SEzyREPVs5DhRcotlI3c?=
 =?iso-8859-1?Q?wkzPC6Sy5LNBATi4ML0LmQOCW59tDJFs5C3rZYEjHXXpmeGgz2rsDCH7is?=
 =?iso-8859-1?Q?hpTtRdSrzxaDzVP0wamzQTEcLIES8m7z5ju781kcLGsfNYlldmVVnctq7c?=
 =?iso-8859-1?Q?BIEQGDp+MQuNzkrvcdfJzos93ULF/QodXa8EPdo6y91PVA28HOWy96jZ8g?=
 =?iso-8859-1?Q?1Cf8rbHTxI3BXuQcg2L7v8WRtFZlR8FGoG+oeMFJo4GPqN6aLjhzusuWSB?=
 =?iso-8859-1?Q?PLrstCiqcCBtrzDQgO7cfOevTAEoQMp7/XmeDI/zAoNzD4+XOJQtsh2u0Y?=
 =?iso-8859-1?Q?sH5GDJ2xKTIikZfRg7/B9JY+OF1yydaJOlbnfHs0Z+OWA0dyt2hTPg3nHu?=
 =?iso-8859-1?Q?VCgPNblZ3g4k8+iXC/i+3R8l4uKRsZuHmqy1I26FZO8ASC2SjPhwtKN7j0?=
 =?iso-8859-1?Q?gh6pl7rYjk4jz0hDd8eXy5ROgxPRtb5cXImvf7QCdGr4i5kNIl2G1uX39v?=
 =?iso-8859-1?Q?uVTsKZpu5yWmTNCxunCC/PCaW7P7PRhEpBM2H/M6h+BJs5zTbcyjpmDSer?=
 =?iso-8859-1?Q?NPjaa8HM/iOcSFEYo6TvS1NxzLdg6+SC+2oBsaDLc2saUcp0aa28EHTh2b?=
 =?iso-8859-1?Q?fVI6O30cbFkP7NN+oe3P9Tvd1etFgFtkfvm1aFAwUiUDn1Gn2SQUE+t00P?=
 =?iso-8859-1?Q?qsZaizRb7q5okDhHvDzYEvXCxxxsMeSTZ7yW6tN0AntnbkPPAA1KsWwB0+?=
 =?iso-8859-1?Q?uPQwFRTn7PVxmZTBKOdMWPTFMewVvOREWzTrpnAp5Qluh3764DL0ZqDBb3?=
 =?iso-8859-1?Q?nGzbPcORsS4FxP0YYrESUGRiJQbn1an+xR9hnkmCek3znF?=
MIME-Version: 1.0
X-OriginatorOrg: openchip.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: AM4P192MB3108.EURP192.PROD.OUTLOOK.COM
X-MS-Exchange-CrossTenant-Network-Message-Id: bef0c83c-74c5-42f6-6180-08de73952603
X-MS-Exchange-CrossTenant-originalarrivaltime: 24 Feb 2026 11:09:15.7948 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: dfdd4aff-e2c9-4e1a-8642-7f6cc6bbbe6d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: n1ZsnyoAhg/XvG2dgDPpwKzH06ehif4MJ077hWtSmMB/gP+TGIRhh4yNiPcpNDhjnBj+flz+jRGKTezCSeGgyX49WfrxjIZcPrFO6Xf3iPg=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DU4P192MB2349
Subject: [lustre-devel] [RFC] RISC-V Architecture Support for Lustre - Patch
 Series Available
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
Content-Type: multipart/mixed; boundary="===============5482952854125363482=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============5482952854125363482==
Content-Language: en-IE
Content-Type: multipart/alternative;
	boundary="_000_AM4P192MB31086DEE0D7ED656ADF8B3EE8274AAM4P192MB3108EURP_"

--_000_AM4P192MB31086DEE0D7ED656ADF8B3EE8274AAM4P192MB3108EURP_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hello Lustre developers and maintainers,

I am writing to inquire about any existing plans to support the RISC-V
architecture in future Lustre releases, and to share our work on enabling
Lustre client functionality on RISC-V 64-bit systems.


BACKGROUND: WHY RISC-V SUPPORT MATTERS FOR LUSTRE
-------------------------------------------------

RISC-V is gaining significant momentum in the HPC community, with projects
like the European Processor Initiative (EPI), EPAC, and commercial offering=
s
from SiFive targeting high-performance computing workloads. However, a
critical gap exists in the RISC-V HPC ecosystem: there is currently no
high-performance parallel file system support for RISC-V.

This gap has been formally identified in the RISC-V HPC Gap Analysis by
Nick Brown [1], which explicitly recommends:

    "We should prioritise optimisation of parallel filesystems,
     including Lustre, for RISC-V"

Adding RISC-V support to Lustre would:

  1. Signal RISC-V readiness for production HPC - Lustre is the de facto
     standard for HPC storage, powering ~70% of TOP500 systems

  2. Align with open-source values - Both Lustre and RISC-V share a
     commitment to open-source collaboration

  3. Enable new deployment scenarios - RISC-V-based compute nodes
     connecting to existing Lustre infrastructure


OUR WORK: LUSTRE 2.17.0 ON RISC-V
---------------------------------

We have successfully built and tested the Lustre 2.17.0 client on RISC-V
64-bit with a minimal set of patches. This work demonstrates that Lustre
can be ported to RISC-V with relatively low effort, as also shown in
recent academic work by Billa et al. at SCA/HPCAsiaWS '26 [2].

Patch Summary:

Our patch series consists of 8 small patches targeting:

  - Build system:      RISC-V SUBARCH mapping in autoconf
  - RPM/DKMS:          Architecture-agnostic paths
  - LNet:              RISC-V hypervisor detection handling
  - llite:             Guard for prefetchw() (x86-specific instruction)
  - Erasure coding:    Enable optimized paths for RISC-V
  - Debug tools:       RISC-V target in crash tools

Total impact: 9 files changed, 19 insertions(+), 8 deletions(-)

Test Environment:

  - Primary:    Ubuntu 24.04 RISC-V, Linux kernel 6.8.4
  - Validation: Fedora 42 x86_64, Linux kernel 6.16.4
  - Result:     All 16 client kernel modules compile and load successfully


QUESTIONS FOR THE COMMUNITY
---------------------------

  1. Are there any existing plans or ongoing efforts to add RISC-V
     support to Lustre?

  2. Would the maintainers be interested in reviewing our patch series
     for potential inclusion?

  3. Are there specific testing requirements or coding standards we
     should address before formal submission?


NEXT STEPS
----------

We are prepared to:

  - Submit the patches via Gerrit for formal review
  - Create a Jira ticket to track this feature request
  - Provide additional testing data as needed
  - Collaborate with maintainers on any required changes

The patches are available in our repository and we can submit them in
whatever format is most convenient for the review process.


REFERENCES
----------

[1] Nick Brown, "RISC-V HPC Gap Analysis", RISC-V International, Oct 2025
    https://riscv.atlassian.net/wiki/spaces/OLRR/pages/895778831/HPC+Gap+an=
alysis

[2] Surendra Billa et al., "Porting Lustre File System to RISC-V
    Architecture", SCA/HPCAsiaWS '26, ACM
    https://dl.acm.org/doi/10.1145/3784828.3785406


Thank you for your time and consideration. We look forward to your
feedback and the opportunity to contribute to Lustre's architecture
support.

Best regards,

Abdul Halim
OpenChip
abdul.halim@openchip.com




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

--_000_AM4P192MB31086DEE0D7ED656ADF8B3EE8274AAM4P192MB3108EURP_
Content-Type: text/html; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Diso-8859-=
1">
<style type=3D"text/css" style=3D"display:none;"> P {margin-top:0;margin-bo=
ttom:0;} </style>
</head>
<body dir=3D"ltr">
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
Hello Lustre developers and maintainers,</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
I am writing to inquire about any existing plans to support the RISC-V</div=
>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
architecture in future Lustre releases, and to share our work on enabling</=
div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
Lustre client functionality on RISC-V 64-bit systems.</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
BACKGROUND: WHY RISC-V SUPPORT MATTERS FOR LUSTRE</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<b>-------------------------------------------------</b></div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
RISC-V is gaining significant momentum in the HPC community, with projects<=
/div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
like the European Processor Initiative (EPI), EPAC, and commercial offering=
s</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
from SiFive targeting high-performance computing workloads. However, a</div=
>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
critical gap exists in the RISC-V HPC ecosystem: there is currently no</div=
>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
high-performance parallel file system support for RISC-V.</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
This gap has been formally identified in the RISC-V HPC Gap Analysis by</di=
v>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
Nick Brown [1], which explicitly recommends:</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; &nbsp; &quot;We should prioritise optimisation of parallel filesyste=
ms,</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; &nbsp; &nbsp;including Lustre, for RISC-V&quot;</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
Adding RISC-V support to Lustre would:</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; 1.&nbsp;Signal RISC-V readiness for production HPC - Lustre is the d=
e facto</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; &nbsp; &nbsp;standard for HPC storage, powering ~70% of TOP500 syste=
ms</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; 2.&nbsp;Align with open-source values - Both Lustre and RISC-V share=
 a</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; &nbsp; &nbsp;commitment to open-source collaboration</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; 3.&nbsp;Enable new deployment scenarios - RISC-V-based compute nodes=
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; &nbsp; &nbsp;connecting to existing Lustre infrastructure</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
OUR WORK: LUSTRE 2.17.0 ON RISC-V</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<b>---------------------------------</b></div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
We have successfully built and tested the Lustre 2.17.0 client on RISC-V</d=
iv>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
64-bit with a minimal set of patches. This work demonstrates that Lustre</d=
iv>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
can be ported to RISC-V with relatively low effort, as also shown in</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
recent academic work by Billa et al. at SCA/HPCAsiaWS '26 [2].</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
Patch Summary:</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
Our patch series consists of 8 small patches targeting:</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; -&nbsp;Build system: &nbsp; &nbsp; &nbsp;RISC-V SUBARCH mapping in a=
utoconf</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; -&nbsp;RPM/DKMS: &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Architecture-agno=
stic paths</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; -&nbsp;LNet: &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;RISC-V =
hypervisor detection handling</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; -&nbsp;llite: &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Guard for pr=
efetchw() (x86-specific instruction)</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; -&nbsp;Erasure coding: &nbsp; &nbsp;Enable optimized paths for RISC-=
V</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; -&nbsp;Debug tools: &nbsp; &nbsp; &nbsp; RISC-V target in crash tool=
s</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
Total impact: 9 files changed, 19 insertions(+), 8 deletions(-)</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
Test Environment:</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; -&nbsp;Primary: &nbsp; &nbsp;Ubuntu 24.04 RISC-V, Linux kernel 6.8.4=
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; -&nbsp;Validation: Fedora 42 x86_64, Linux kernel 6.16.4</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; -&nbsp;Result: &nbsp; &nbsp; All 16 client kernel modules compile an=
d load successfully</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
QUESTIONS FOR THE COMMUNITY</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<b>---------------------------</b></div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; 1.&nbsp;Are there any existing plans or ongoing efforts to add RISC-=
V</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; &nbsp; &nbsp;support to Lustre?</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; 2.&nbsp;Would the maintainers be interested in reviewing our patch s=
eries</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; &nbsp; &nbsp;for potential inclusion?</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; 3.&nbsp;Are there specific testing requirements or coding standards =
we</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; &nbsp; &nbsp;should address before formal submission?</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
NEXT STEPS</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<b>----------</b></div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
We are prepared to:</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; -&nbsp;Submit the patches via Gerrit for formal review</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; -&nbsp;Create a Jira ticket to track this feature request</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; -&nbsp;Provide additional testing data as needed</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; -&nbsp;Collaborate with maintainers on any required changes</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
The patches are available in our repository and we can submit them in</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
whatever format is most convenient for the review process.</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
REFERENCES</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<b>----------</b></div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
[1] Nick Brown, &quot;RISC-V HPC Gap Analysis&quot;, RISC-V International, =
Oct 2025</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; &nbsp;&nbsp;<a style=3D"margin: 0px;" data-linkindex=3D"0" title=3D"=
https://riscv.atlassian.net/wiki/spaces/OLRR/pages/895778831/HPC+Gap+analys=
is" class=3D"ms-outlook-linkify OWAAutoLink" id=3D"OWAb5b0d5de-4950-559d-e3=
01-5124963f5dcb" target=3D"_blank" href=3D"https://riscv.atlassian.net/wiki=
/spaces/OLRR/pages/895778831/HPC+Gap+analysis">https://riscv.atlassian.net/=
wiki/spaces/OLRR/pages/895778831/HPC+Gap+analysis</a></div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
[2] Surendra Billa et al., &quot;Porting Lustre File System to RISC-V</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; &nbsp; Architecture&quot;, SCA/HPCAsiaWS '26, ACM</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
&nbsp; &nbsp;&nbsp;<a style=3D"margin: 0px;" data-linkindex=3D"1" title=3D"=
https://dl.acm.org/doi/10.1145/3784828.3785406" class=3D"ms-outlook-linkify=
 OWAAutoLink" id=3D"OWAfd028089-0d6e-e236-6ddf-7eb585f77c10" target=3D"_bla=
nk" href=3D"https://dl.acm.org/doi/10.1145/3784828.3785406">https://dl.acm.=
org/doi/10.1145/3784828.3785406</a></div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
Thank you for your time and consideration. We look forward to your</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
feedback and the opportunity to contribute to Lustre's architecture</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
support.</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
Best regards,</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
Abdul Halim</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
OpenChip</div>
<div style=3D"direction: ltr; line-height: 19px; margin: 0px; font-family: =
&quot;Aptos Mono&quot;, Aptos_EmbeddedFont, Aptos_MSFontService, monospace;=
 font-size: 12pt; color: rgb(0, 0, 0);" class=3D"elementToProof">
abdul.halim@openchip.com</div>
<div style=3D"direction: ltr; margin: 0px; font-family: Aptos, Aptos_Embedd=
edFont, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12p=
t; color: rgb(0, 0, 0);" class=3D"elementToProof">
<br>
</div>
<div style=3D"font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, =
Calibri, Helvetica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);" clas=
s=3D"elementToProof">
<br>
</div>
<div style=3D"font-size:9pt; color:#000000;"><br>
<br>
The content, data, and any attached documents to this email are addressed e=
xclusively to the addressee and are confidential and/or may be subject to a=
 non-disclosure agreement. Any use, forwarding, disclosure, and/or copying,=
 in whole or in part, without authorization
 is prohibited. If you have received this email in error, we apologize and,=
 please notify the sender or Openchip immediately, and delete it from your =
system.
<br>
<br>
El contenido, los datos y cualquier documento adjunto a este correo electr=
=F3nico est=E1n dirigidos exclusivamente al destinatario y son confidencial=
es y/o pueden estar sujetas a un acuerdo de no revelaci=F3n. Est=E1 prohibi=
do cualquier uso, reenv=EDo, divulgaci=F3n o
 copia, total o parcial, sin autorizaci=F3n. Si has recibido este correo po=
r error, te pedimos disculpas y agradecemos que lo notifiques de inmediato =
al remitente o a Openchip, y lo elimines de tu sistema.
<br>
<br>
El contingut, les dades i qualsevol document adjunt a aquest correu electr=
=F2nic estan dirigits exclusivament al destinatari i s=F3n confidencials i/=
o poden estar subjectes a un acord de no revelaci=F3. Est=E0 prohibit quals=
evol =FAs, reenviament, divulgaci=F3 o c=F2pia,
 total o parcial, sense autoritzaci=F3. Si has rebut aquest correu per erro=
r, et demanem disculpes i agra=EFm que ho notifiquis d'immediat al remitent=
 o a Openchip, i l'eliminis&nbsp;del teu sistema
</div>
</body>
</html>

--_000_AM4P192MB31086DEE0D7ED656ADF8B3EE8274AAM4P192MB3108EURP_--

--===============5482952854125363482==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============5482952854125363482==--
