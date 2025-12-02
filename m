Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 852C9D12679
	for <lustre-devel@archiver.kernel.org>; Tue,  2 Dec 2025 22:13:23 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4dLYhG0Zqnz23wt;
	Tue, 02 Dec 2025 13:25:02 -0800 (PST)
Received: from CH5PR02CU005.outbound.protection.outlook.com
 (mail-northcentralusazon11022085.outbound.protection.outlook.com
 [40.107.200.85])
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id
 4dLYXw0vtFz23hv; Tue, 02 Dec 2025 13:18:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=axiGZ8b0o1Bw+VzM44VlkLbthS2ak3j1ny7O9IN8J54dr83G1q0jG4kESX6ZjZWnhpDx12bHSiE/wGwbmGqLUFGXc1muySe08k7ZcLS8Ci8flf286LP+CDP2a0vjdccaw3yp5rnXVQEiCCed1pH+JKEVjKEgCUflxFHVbQeuZVqzH2PN/euyo718mHiClvF/J1W6HVdN9DFCLKdQ5GhJiiG+TrpYYYEeCzh1x9x1QxM8uRMXyzNEH5uHFlpq3vtQsshxTgbbdy9ihlYwRJYcWhb1SYzXzjZyO7n6WspW6pQzGhB95CHQE64vV9ay8dNRtkpDJX6NR012rHE0Kzg97Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=8sSex5/9Zl1Fr+qzLLXZdRr0+oaM7v0yJZzAGIf0ZX0=;
 b=ZW4+US9H8HfQ6BUsbkrQpbdRHO2QaT3NU248FP/t/NFIzqmAofLk/NPrNKX1JDO6FigW025p9C4y27jrM53/1a+DyM9r/aeUCMm7lgkJ6zmmhOFl1h9uWTLAdFxOFoA7sZcYVMTBLuKc76umRr8X8YrQl6xdoC+mqDpzcWRPl+G/QqQ7IGRpKL3o1fJ3bRjwOvW5LO55fMOdn76mD//ZftMhfAY5WKX0dFeUWHroU6C+V/qod8Vt6c0aixFDn1GJ8dxcg0EKzOadFeQWRL8XqiDxOyPBvE38+i5CppogdQfQkvlzhN+sfXepkNToBuYQ3yV27PC5ju/Zd2PkFHuhyw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=thelustrecollective.com; dmarc=pass action=none
 header.from=thelustrecollective.com; dkim=pass
 header.d=thelustrecollective.com; arc=none
Received: from CH2PR04MB6966.namprd04.prod.outlook.com (2603:10b6:610:95::21)
 by SA1PR04MB8519.namprd04.prod.outlook.com (2603:10b6:806:330::10)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.9388.9; Tue, 2 Dec
 2025 21:17:36 +0000
Received: from CH2PR04MB6966.namprd04.prod.outlook.com
 ([fe80::9e9:f0b:349a:2a63]) by CH2PR04MB6966.namprd04.prod.outlook.com
 ([fe80::9e9:f0b:349a:2a63%5]) with mapi id 15.20.9366.012; Tue, 2 Dec 2025
 21:17:36 +0000
To: "lustre-announce@lists.lustre.org" <lustre-announce@lists.lustre.org>,
 "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>,
 "lustre-discuss@lists.lustre.org" <lustre-discuss@lists.lustre.org>,
 "lwg@lists.opensfs.org" <lwg@lists.opensfs.org>
Thread-Topic: Lustre 2.15.8 released
Thread-Index: AQHcXzzeMuvwAxFi7UOdu3VmIZv3PA==
Date: Tue, 2 Dec 2025 21:17:36 +0000
Message-ID: <CH2PR04MB696607CCAE004C2E4397FE19CCDFA@CH2PR04MB6966.namprd04.prod.outlook.com>
Accept-Language: en-CA, en-US
Content-Language: en-CA
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-ms-reactions: allow
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=thelustrecollective.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: CH2PR04MB6966:EE_|SA1PR04MB8519:EE_
x-ms-office365-filtering-correlation-id: 910cd8f4-a4c0-47d2-8a2d-08de31e83728
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230040|1800799024|366016|586017|376014|8096899003|38070700021; 
x-microsoft-antispam-message-info: =?us-ascii?Q?XWzSAraOKmmRNszmJ8L901+4WnHZzbBr1slxX8WLa6KwhXGSqesdmngPwzOY?=
 =?us-ascii?Q?hLxjivn1M+l7ibVnKb4WmyWvhcJ9awmO3kBJ2qG6OAbi+lgzUH/5dUV39fCC?=
 =?us-ascii?Q?H3UhPWsKwQX0MT7sngPien6apH2L+oRyZ0Wi4ajtyyX6Gh7F7URDxEoduYl0?=
 =?us-ascii?Q?d/N+6HLB0ODe10ZYeVR5aAncjxjvPivCi2Xv9ou79u9wTvER9GpcD0A8XdIa?=
 =?us-ascii?Q?2ZWVMoZ1Qz05yBqhJ+h9dADR+Latx3SCzNWoiXYeOr97wElnZNYT1h31Bajz?=
 =?us-ascii?Q?+NG+REPxygOoywvP+Vsc6Chfxqn15cW6xeDq1gFQ96bcGGS//w/eZb+S5qii?=
 =?us-ascii?Q?5aDLldsj7vu9SUPhZFd5+y6hZc3YoxeR9KSIS59w7tG9uHdcLMVx60ZPwG9d?=
 =?us-ascii?Q?3UyANPqvC1o8eV7I2WNUo+fYltxuqfJgFDNcNuB4Q8nziOIsmk8JC8UZL16W?=
 =?us-ascii?Q?NWUU0fdtkHUiMhqzLFkPnEMH5KI0WERZ11OJ79WoqJ76OPbl2CIpY06Ia5MD?=
 =?us-ascii?Q?nukoy4DElq+xIPZpsHmjTET6Wnibc8YWPUFk0X+fjZH0MvZ04HpqvCTlKqvM?=
 =?us-ascii?Q?4KZKYLAwoZCEQon0QTL85A/wxaWHTkM+84J7im6Y+wXUIw/FGZ5KtN972RAQ?=
 =?us-ascii?Q?9xldJrdghtSHzvlIew8Ny6t+vxAvZVwWKJCIshpcKVUjHoGaft1ife7Yl2BG?=
 =?us-ascii?Q?WqEq3xmc6k7JFHbpWLW+mcBM7m1Ew19p/hm7PT5e3D3U4GCIFnLWY9xtNR+w?=
 =?us-ascii?Q?yoygssSc6JoWNRR0fuRwxhgsCMV2pH1fLeQZZNkp4htzxz5UppIjUIydW4Cr?=
 =?us-ascii?Q?K6R2dbPHQHr9J7UI3Q6Z+8tTKknA0fHuhwRDNMtOtTxxaBv2eLLh1sy6eAty?=
 =?us-ascii?Q?jFI4xVumZ6N5mNYAzr4BX7q3YB+ffrK0b3IzxGP8CBNXS3ARiSkhu6+h9O7V?=
 =?us-ascii?Q?nywjvXI3j9Wsq77rk7GPPFxU3xIYhB6eF6sMHdX3fKb2BaH/TSRyp37uHLXH?=
 =?us-ascii?Q?Sc77fFff5nB9Zu7pYtkqA/z05xEsa4vaRUg1R8MxRmDNOJf3phyQF1mqS6I7?=
 =?us-ascii?Q?DrshCZU9XYOsajMDxWjpq9j57QgAcywuZLXZQ6v0ywGPQG6oYAWB0bmOQDCI?=
 =?us-ascii?Q?p+GTfMNfoiQT0U9LXhCXnVeQVWGQZr025xAkF7egjDt6REeGD167eCGbfskt?=
 =?us-ascii?Q?VotUrcGATd9ZpZpkbwxBGHqyj1eRkZMpZmgW9FwjQDpRxoBUucPQ+e/8N5Bt?=
 =?us-ascii?Q?lnyAgQ1uDdz3gCbqjb37o5sSQm0TJnOa6R0lvinKrcfrbqiWwjncQ55VI2ry?=
 =?us-ascii?Q?5Je4WqI+cetJzC3yfrOGBrRpMsw+/j85klThUIbqy5SRBzQ6+ZMT8KhXdHyh?=
 =?us-ascii?Q?gm77ijMkRa0ncQx8T9FRtehD/9TIwclWyzXko2ou0ewwbyo8Bu97/jpsnRrX?=
 =?us-ascii?Q?DOKoYFl87/wgQZ5mBPnBJeteR2eKh/T+?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:CH2PR04MB6966.namprd04.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(1800799024)(366016)(586017)(376014)(8096899003)(38070700021);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?Zsl8nLefXwZWGQHUhmMb58POJz0gQOrG8q4fqYJYIBxwZOoln48WP43szUz+?=
 =?us-ascii?Q?zEBKno5/DDNhjfFLqdYI8FQbwiv9omS47hdx6Iz5v3klUnqWkobWfWyx8MBK?=
 =?us-ascii?Q?e2AdAc31mLCi+yrbIBgtdds2RKlwKS/hOA4/Z0/ifq8KyQSfntbrqPYZ6qCG?=
 =?us-ascii?Q?mkFHJoPLWyBwA/Lc9TssW3nDh4uUw9e0tOnz52zS94uaPfdMistq9jWnZY1Y?=
 =?us-ascii?Q?fnJwg34qM2d4+yYaQj+O+94/0jeFPJ+uhhjJq7A+6wrg6mGGLZix5kAOqas9?=
 =?us-ascii?Q?hVguAn9HXimd9AROSskFIGK+Fyn/ZnDx4HiwqHgwypxVDQJOK1RTGAIT2ufO?=
 =?us-ascii?Q?geJI5URrOWq3GGJd6WIvYe1Vh6AVySC1WMuN7DLKbHr+gVU5tBbDEcCglMi1?=
 =?us-ascii?Q?6BnEtAfFezz7EP3NBXrfGnqDly26thYCrEng3R5VwbhVTByt1XACIIDDTAi8?=
 =?us-ascii?Q?tpfzkF3sMLxlboNWiBEy/VTeOZ5MmVf8L5AzT04PRrZ2E7SX3KEAa/pPbd0q?=
 =?us-ascii?Q?nLTWgKZwOV2+e6CSFNKluJ+WUDz9xdbweIb81/YBvoG2jNJ4djQDONAywZkX?=
 =?us-ascii?Q?DN6fndIPUSjTqHLeFSj68+Nt4Q4Kz5x5vsiEMto6J/VyUmgiNVoLSQE1bXz2?=
 =?us-ascii?Q?O2fBdbmUdd81NncJlEMrr0AECA95o+C1HrlXmsMKl7JUUC/6tQZW3Z9xPZBZ?=
 =?us-ascii?Q?4RbR/n+r7lretxCQfp7pgvHZdmfik29rqGNVUfU+m+MF5AvN85NxYp6zhIPC?=
 =?us-ascii?Q?DQCF641fPOV97g0pSK/1G1z3xmN18R9ed6RjfUsNr+PEYBg1g8ND8oijdBOM?=
 =?us-ascii?Q?UQ0EytjFAMwKTgDW4vMnCQhO9dLUvpt9RNu51nAKSY3PhcXvzTGfoQ+lSc5O?=
 =?us-ascii?Q?UVpOaPRHOhO/1bB+J2jHPBmH44FO7METCzuIXyWWDtA2yuIfi96B/rzFcOS2?=
 =?us-ascii?Q?1oFelr5xn9vpbVyIm8GMBEF8/tN9/l+qACGdcuKJsfC7j95KqOTEOMGLV/bF?=
 =?us-ascii?Q?1KZJaHsiUeHnN8e9gfFiurY6CUgRfueR0D39HqSNWD92iOkLFXqC+PH/zlUA?=
 =?us-ascii?Q?x1La4A8AZlF2WEuARTNpMM0xhW1/BFOTuXpO2tzz0N6SzrGOIYnZN/eS0sDw?=
 =?us-ascii?Q?4pmrahV0VKYLOR2h+2Ht7enkPFKPYcusO53jgmylZaEsMezeFCJ5/Quv95Fl?=
 =?us-ascii?Q?vWJawY0q/EMlqDHRM0DKwGfEQ1U7ZdC8mg3YFOvd4SA63g1F37O0HskDOW2j?=
 =?us-ascii?Q?Mjc/dbqL/pojvACzRLMbpniyyoMrmfQ4cGhRSoGRSnzY+oogzAznlG0szYMx?=
 =?us-ascii?Q?Px8yynYBiU6pGbQxZgCWRmxP/t8J4x5+LZlG0TDpv51eotiwhauJNqD+VM29?=
 =?us-ascii?Q?yszkGMuuZ6Nwdhm/00spWtVd+Trp3Ww50HeqoJzMS1LishHBubla7L/R+gq3?=
 =?us-ascii?Q?lKOQtNCQUGL3G+HBlcqKfQjthb4gqB4VFqehxn9oNQaKEHJeKa1+NAWnVy17?=
 =?us-ascii?Q?SEzrnU18UBtDIhHfaBRr2jVxe9ORKrkvJ58KGDs0JLxAX0JBkpiNokauG+r8?=
 =?us-ascii?Q?mNwCjVqNvqUF7friwUj+G5Jlnwnxv1ptSTClgv2TfcyMP3E9bqF8YsM/P0iT?=
 =?us-ascii?Q?aso2KMQzyOLGYwZ8xl4pPK4=3D?=
MIME-Version: 1.0
X-OriginatorOrg: thelustrecollective.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: CH2PR04MB6966.namprd04.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 910cd8f4-a4c0-47d2-8a2d-08de31e83728
X-MS-Exchange-CrossTenant-originalarrivaltime: 02 Dec 2025 21:17:36.0159 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 4c9dec06-8f2c-4233-98d5-ca3cb36218fc
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: 8pbxn8fVBP9+IMYGrok/++UAZwhEuEwQskDwIM91eFE+QLpDzAreWGhv2ew4/CmJ3y22Kyr3KdDbpwFtftJuGhzl8aXlIQm6cR75oevQl7I=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SA1PR04MB8519
Subject: [lustre-devel] Lustre 2.15.8 released
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
From: Peter Jones via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Peter Jones <pjones@thelustrecollective.com>
Content-Type: multipart/mixed; boundary="===============4558303674232540508=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============4558303674232540508==
Content-Language: en-CA
Content-Type: multipart/alternative;
	boundary="_000_CH2PR04MB696607CCAE004C2E4397FE19CCDFACH2PR04MB6966namp_"

--_000_CH2PR04MB696607CCAE004C2E4397FE19CCDFACH2PR04MB6966namp_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

We are pleased to announce that the Lustre 2.15.8 Release has been declared=
 GA and is available for download<https://downloads.whamcloud.com/public/lu=
stre/lustre-2.15.8/>. You can also grab the source from git<https://git.wha=
mcloud.com/?p=3Dfs/lustre-release.git;a=3Dcommit;h=3Dee228420b7fa12f183bceb=
9864ff083cb07e8964>

Details of changes since 2.15.7<https://wiki.lustre.org/Lustre_2.15.7_Chang=
elog> can be found in the 2.15.8 changelog<https://wiki.lustre.org/Lustre_2=
.15.8_Changelog>.

The following are notable changes since 2.15.7:

RHEL 9.7 is now supported for clients   (LU-19451<https://jira.whamcloud.co=
m/browse/LU-19451>)

Please log any issues found in the issue tracking system<https://jira.whamc=
loud.com/>.

Thanks to all those who have contributed to the creation of this release.

The next LTS release will be 2.15.9



--_000_CH2PR04MB696607CCAE004C2E4397FE19CCDFACH2PR04MB6966namp_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
</head>
<body>
<pre style=3D"background-color: rgb(255, 255, 255);"><div style=3D"text-ali=
gn: left; text-indent: 0px; white-space: pre-wrap; font-size: 12pt; color: =
rgb(0, 0, 0);">We are pleased to announce that the Lustre 2.15.8 Release ha=
s been declared GA and is available for <a href=3D"https://downloads.whamcl=
oud.com/public/lustre/lustre-2.15.8/" data-outlook-id=3D"f403f206-ae79-4c10=
-98c0-155fd1b1ac11">download</a>. You can also grab the source from <span s=
tyle=3D"background-color: rgb(255, 255, 255);"><a href=3D"https://git.whamc=
loud.com/?p=3Dfs/lustre-release.git;a=3Dcommit;h=3Dee228420b7fa12f183bceb98=
64ff083cb07e8964" data-outlook-id=3D"312b0639-8dc7-4df8-b578-3b40d07ee810">=
git</a></span>=0A=
=0A=
Details of changes since <a href=3D"https://wiki.lustre.org/Lustre_2.15.7_C=
hangelog" data-outlook-id=3D"6efcfcc5-beac-4f8d-9594-cee0a6cd3b25">2.15.7</=
a> can be found in the 2.15.8 <a href=3D"https://wiki.lustre.org/Lustre_2.1=
5.8_Changelog" data-outlook-id=3D"cc2d7e57-f82a-4e4c-bd67-3d4c8db018d9">cha=
ngelog</a>.=0A=
=0A=
The following are notable changes since 2.15.7:=0A=
=0A=
RHEL 9.7 is now supported for clients &nbsp; (<a href=3D"https://jira.whamc=
loud.com/browse/LU-19451" data-outlook-id=3D"0c3bd4fe-b800-42aa-8d6a-167419=
909396">LU-19451</a>)=0A=
=0A=
Please log any issues found in the <a href=3D"https://jira.whamcloud.com/" =
data-outlook-id=3D"5355eef2-caa9-40fd-b7a7-1701e4c27efa">issue tracking sys=
tem</a>.=0A=
=0A=
Thanks to all those who have contributed to the creation of this release.=
=0A=
=0A=
The next LTS release will be 2.15.9</div></pre>
<div dir=3D"ltr" style=3D"font-family: Aptos, Arial, Helvetica, sans-serif;=
 font-size: 12pt; color: rgb(0, 0, 0);">
<br>
</div>
<div dir=3D"ltr" style=3D"font-family: Aptos, Arial, Helvetica, sans-serif;=
 font-size: 12pt; color: rgb(0, 0, 0);">
<br>
</div>
</body>
</html>

--_000_CH2PR04MB696607CCAE004C2E4397FE19CCDFACH2PR04MB6966namp_--

--===============4558303674232540508==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============4558303674232540508==--
