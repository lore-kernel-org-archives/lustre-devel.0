Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 51B4CC54FD3
	for <lustre-devel@archiver.kernel.org>; Fri, 20 Feb 2026 13:49:35 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4fHWm40qnVz1y68;
	Fri, 20 Feb 2026 05:48:04 -0800 (PST)
Received: from outbound-ip168b.ess.barracuda.com
 (outbound-ip168b.ess.barracuda.com [209.222.82.102])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4fHWlr2RMGz20fl
 for <lustre-devel@lists.lustre.org>; Fri, 20 Feb 2026 05:47:52 -0800 (PST)
Received: from CH4PR04CU002.outbound.protection.outlook.com
 (mail-northcentralusazon11023135.outbound.protection.outlook.com
 [40.107.201.135]) by mx-outbound20-116.us-east-2b.ess.aws.cudaops.com
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Fri, 20 Feb 2026 13:47:33 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=PQlsrYxbeGWYFuJMY5evQn+NeOjc/zggf73c+OD8w96RnEXKe64x/zdbz2nJgPkUgd3EPVdaTdcSURRtRG87ZoD1qdm41xzJivuFjgP5JaZLc6CAXlAB/hSvR5mVpsQKIqdFAWKri4SiyXgE2R7S02VO1VGzcE7RBIv6WjZFX2t9WewYe6CU7hxgHGnNhuFh6O5dG4tvPgB6oo44k7R/ja1PIN5L9a6Nac1Tk50ZLq+Zauw782Vd+nyEJ+9mx9WX6BecI5fZ1+hCgxKcjefIWbPKt7/AM78CI8oBeqDRLkwHirz2EpXKY4oB/lkyz2Km/cdtACK59wbpC1eB1RdQyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=pwgqsutxDWuAOjOzGstYlmyXzzQXIfBr3z7h37BGAzc=;
 b=jwLnsQpFn5HPfT60EgwLJAGQ999FI3scKyEHrtghuY2u14MkkQkyGa7kYAd8wdW8sMwvAPPiDFWwMy5iVanlyWkniUNPcRlmJDXN+eutaIahJSRVhfO3cm21vdS3FQsMBo/GTdx+eKH9QoGNvwwcnFbOU9P8/vB0ZbjRvA67tTTHr3xyeNTiqkKqJ1KUD+6ZfaQIHcA+TvmoXlv7TDAzk3jyBmmPctsUFRjDgTB+QzhOi6JNbcE2bRc7pxpt7qFZjqHSogv/pA8tGt6pGPrepIlEe6LPwUYrQ5IZJb8gcA3OoIbkTQCzma/W+Ce5Ak4W68K7FZC4lIp1yNQ+WV4vGQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=ddn.com; dmarc=pass action=none header.from=ddn.com; dkim=pass
 header.d=ddn.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ddn.com; s=selector2; 
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=pwgqsutxDWuAOjOzGstYlmyXzzQXIfBr3z7h37BGAzc=;
 b=U0OjsRKDeekm0mNcuEZggCNcrzt6tSjxHy061nuiHV7MWVv8Gb3Pl+ht+mMbYhIv4BjJwfpkzHM6TsRR/4V75IWcUjOvSfQ5Yacs6k8NYkqmm78GReE7kp04zCvbT7PgmlHm2Mj7iOI++yoHZIJ09yoLr/m9XBa03dFvw+kXO3s=
Received: from LV2PR19MB5791.namprd19.prod.outlook.com (2603:10b6:408:178::15)
 by LV8PR19MB8571.namprd19.prod.outlook.com (2603:10b6:408:267::18)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.9632.16; Fri, 20 Feb
 2026 13:47:30 +0000
Received: from LV2PR19MB5791.namprd19.prod.outlook.com
 ([fe80::ca33:bce8:6a03:3655]) by LV2PR19MB5791.namprd19.prod.outlook.com
 ([fe80::ca33:bce8:6a03:3655%5]) with mapi id 15.20.9632.015; Fri, 20 Feb 2026
 13:47:30 +0000
To: Whamcloud - All Staff <all.staff@whamcloud.com>,
 "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: Crowd downtime notification
Thread-Index: AQHcom9nWd4PYdwOSEquSgsvs6eXow==
Date: Fri, 20 Feb 2026 13:47:25 +0000
Message-ID: <LV2PR19MB57914E51339DBB45E95BD4A4CD68A@LV2PR19MB5791.namprd19.prod.outlook.com>
References: <SA0PR19MB46346DDF4A24FF1937F75192D56AA@SA0PR19MB4634.namprd19.prod.outlook.com>
 <LV2PR19MB571738E0622C6E8E2DCC8DA2CD75A@LV2PR19MB5717.namprd19.prod.outlook.com>
 <LV2PR19MB571793A9C0C77422EE40FFF9CD46A@LV2PR19MB5717.namprd19.prod.outlook.com>
In-Reply-To: <LV2PR19MB571793A9C0C77422EE40FFF9CD46A@LV2PR19MB5717.namprd19.prod.outlook.com>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach: yes
X-MS-TNEF-Correlator: 
x-ms-reactions: allow
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=ddn.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: LV2PR19MB5791:EE_|LV8PR19MB8571:EE_
x-ms-office365-filtering-correlation-id: 435fc2c7-22da-428c-2069-08de7086974e
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230040|19092799006|1800799024|366016|6049299003|376014|38070700021|13003099007|4053099003|8096899003;
x-microsoft-antispam-message-info: =?us-ascii?Q?t892BfJZBex4D37QgcVzkUoBL0gyJAj1Iuu0yeIvln5nVLSS7U18TolG6N++?=
 =?us-ascii?Q?RH5iSbOTDO5YUHK0qVrBHfHZn3jUjNSm5Dz6d0ngD7I0rZXo6vT8cL5aXwvY?=
 =?us-ascii?Q?o3dNouc7GBbGFe+Fft12PQclw2JvXdOFcLkMJe6fDKH9ZEOhnGzwfTdzYlcv?=
 =?us-ascii?Q?iiephszn7fSbpMEWqC9Qg9wDamYL91AiClFVvLE4ozaLNvH3xQMB9BYQJNyG?=
 =?us-ascii?Q?esXYDSuQS1dL4uZfpyLUJehqh6jeCrA3RcyN02sH3jWbKRtKJlzAM8dFL8ua?=
 =?us-ascii?Q?6E5xCNbAEbcIjSS8/aklUBuNKGL8otMF8S8MtFReUXBZq72UKGRQzaGZVKV3?=
 =?us-ascii?Q?RUszBchl09wxEc3sSW5Y1z7wnfxvfk1cKAOn9O6W5AXTWs5RDwmR8g2yV40m?=
 =?us-ascii?Q?i2BOiJ/6wE/f8vD/qG/86Zdj+9BbH6jtwxziTFGEyN627tXxReKrCHELx8+h?=
 =?us-ascii?Q?l2WiGDqQcxBLTKOKWZ2AbXGECsLfXTjjnJ2uCpTglGYJHRq6d7N7TKM/zAzE?=
 =?us-ascii?Q?dD4yTrEk0eHhmwm1n0/6l54Ekp+J0aB4ig5xpIkNV/FIeqRDJLj3wYwTzznj?=
 =?us-ascii?Q?dKZjhWJMgZ2/IaQq88wM58Y0kyMXt+bhpkePBnqcaON3TANQoZaTLvku5ztl?=
 =?us-ascii?Q?t0l190Tu2QKa83DgIUtLL5V77VwcMuk6na4vocRgIjrmNwOM1FSzjIRxOeVR?=
 =?us-ascii?Q?tAPk2svB/I5EPV4VADUVGmWp/jeSk4qb8AiYepGUde+EAC9LtfJqLBvZjYpO?=
 =?us-ascii?Q?HlISS2cjndKWC3kWFTd+DyUH6+bPNA3CnpnQ0UcopLHM0REWsDiz8cKa71Ut?=
 =?us-ascii?Q?h50IqFJvaGxd+DgIUNrht9wOeubpGF0U13bvA+H5OUdazXmHzshRUO9BaB0M?=
 =?us-ascii?Q?GSm1G9tohMg1GPgTQBbci93LY8LprgSYKRWzjTTozgq7K+avy9Bz6z3e6JHD?=
 =?us-ascii?Q?E8+nLuLt0c9I7SoAC6RTNJf955BknPIWhcqk9olL9wGLa9t7x0ZN8Gj0Y3hJ?=
 =?us-ascii?Q?YFJOC1b1bfY6OL40mVie9hHObwOEEXrsOZyt1VQyM3b/9bSL/UsQ0341te3H?=
 =?us-ascii?Q?/u3LChQdQ1jj+H9nXOShpHKX0vKdGlqpIIE89Kg5fPfI3SF5Opl5e7/o36Td?=
 =?us-ascii?Q?fdDfKicVbj7olGt4Wt4WBIWInon4DEn6rTSlOTp19xH65J6czRZzix3hjuiG?=
 =?us-ascii?Q?qpsBAiZi6HkK4KImN+UFx2XkLiYXrYL+o5pu2lCcLeMCYNKjzOLqxJIm6gON?=
 =?us-ascii?Q?iN86LXJ6oryjt77eQZQ5ukBSHahOORiACfcacH7qzaqq1ZP+Cb15xsyph9Jl?=
 =?us-ascii?Q?BFkXhNhGyvn0iwq+EDgqR3J/xJ8mFyS/ijeNwUUFbW+oB5bW5adSlKqVXlIg?=
 =?us-ascii?Q?63WpD59qyydJ7xi72gXsY+lnJwfJ4prqaHmdGh4xrOjaqBEBCWFDUuIhwJbJ?=
 =?us-ascii?Q?5A/F7m5DUzt0dmEKLGhjOAcj2SkuxKe75G1jGtgIIEP36jR0M2zFq+YeKDpU?=
 =?us-ascii?Q?IrsvW7871yOxyG+mmx+8mzKj9rU1bC37L/OgylfCRXPNEZ7PALo72j2g7zKV?=
 =?us-ascii?Q?X5myUBobZGliIcXUZdzXIYSeAR98kHycNR7Cuzvn?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:LV2PR19MB5791.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(19092799006)(1800799024)(366016)(6049299003)(376014)(38070700021)(13003099007)(4053099003)(8096899003);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?EqJUS51aM9AiFJsSx0iL3rgybz5MiLLufjrKpX+O4pze10PYchNV4EtxO+Gn?=
 =?us-ascii?Q?9pvmGaYbTNZDTIvGaknHRHvRfxZjIfA+mz1+ZuQCwlsU+Bkma30RwueP57q5?=
 =?us-ascii?Q?KsOB9bTbBsWdQFRJ6nO1gzIFg4stccClyzRwqfqZ2kvCGLAc1uXcNo6yC83N?=
 =?us-ascii?Q?nf0mL+5ebzp05rXTPzKCx/7pw8suWMTv8Wmxv01t3ts40wlUg1+b/k4N8TZI?=
 =?us-ascii?Q?ZFyTsaV33d/1m7lqDq2ij7unuGlrqese5H0ZGkOPJI8DKJaJ5dMSNYBTo9qd?=
 =?us-ascii?Q?TDJQcezoMooMYBu7Jqb/y+3ohisIFruaY3cyqXQBcRKuARLl7RF373HKKs4A?=
 =?us-ascii?Q?/MzU1NtgRW2DKHmTqTcXa81rX5Hqi+5A4j837ePcpyVPJ51UTuihhT/Ye3OM?=
 =?us-ascii?Q?msh2/Nq0BawBoZ5GRARv3mZbhju0fu96au/fp7ClZdcF1F/gS7Aju8hnH/uG?=
 =?us-ascii?Q?OshLtygBSPrI00R4vAYPe4Cydar+ZSJhawmVIxR6VSJKaNl1dJbf78PgDFwp?=
 =?us-ascii?Q?jQ+I+p6FZGUE1oOfdipRWC6ZTaDbzg8bT8QsywEnXLZnlZG5i0vYJwFNy91C?=
 =?us-ascii?Q?lRLSV7EwROCVPlbp1Jl2BzK5fVyIqXW8tgQPq0AWzEijnrer2qQMa5ZinXrE?=
 =?us-ascii?Q?WQrWLWnQ23owT1zTccAuS2st2ftqIiYpYgu0f+BeVwzU9+tkRIhSC1hrnt9N?=
 =?us-ascii?Q?k2aWtJI4H/GdzIxpXZL+s4g4RPHwacUZN9Rb4fM3QLkRdNwV3lhCyfNGnYoe?=
 =?us-ascii?Q?QlvMbmERm2qa2SI477LUPLFVtjXVPK9DL1UpzFYoitRBlcADsPkw5beALg/S?=
 =?us-ascii?Q?ARlnX9+7j01CDBHQxf/miZIAyfHUQt6wz3OmwExuWSMhs0GF4gO9+EooBKqZ?=
 =?us-ascii?Q?mN4tt8PYghld5FtLsRo8La+vTpbDqVXdlj4ECZbaVheWcBgaRINF4pXB+DLA?=
 =?us-ascii?Q?x4iQh/NUslk8LT8pyquT/WjODUpM4GKKmzTC/oOoB4Mc21hCtIhBNxiWvKo2?=
 =?us-ascii?Q?hGPdnz/pfXpsiF7ZTFGV1C4kB6OeooTmyPNGiKM0ZY1/GelnxkTjKVkXzigV?=
 =?us-ascii?Q?PHbq7aWEuRk3/dGyP1iQW3fbCKSrLyt3cVfVrLEbJaWcepiMEpjEdW+Eu43P?=
 =?us-ascii?Q?7zkde8uHyOcd/z6HNVc4S1snslrFFYRo5PxXF+FFrvtEjQnKX6GHbUFHk/aZ?=
 =?us-ascii?Q?EZ1UGvEyt7L0UF8Qy4yqp/w/DVEh6tbGI7kXJjSzMmNqGt4b3il249U0Xeic?=
 =?us-ascii?Q?20GcJ4l/9tQXoLy0EQhsxLN1es4F3xqnr/cvOXEnF7s43KHMtfn0LYMGTl7y?=
 =?us-ascii?Q?7mn1u4itpC+QWcPwViX2N6AKt6mx1X8VEtKu4rfZSt2vW0JeNrUgfklNh/4h?=
 =?us-ascii?Q?DNVxRel300mLQX1otd6GlEsMZJxVLjMddNLONRwv+SoOxTPZnW9TV3KwDTrD?=
 =?us-ascii?Q?d3WQgmWbVpIIohCyi0wXnK05VvDjHsavrVa/HzOua53bppbxDqnegc3Af3PP?=
 =?us-ascii?Q?yoQlzgm0fOe2d0PO5QP0C2EpOVEhO723aDDVg3MJ9XnDvIsrIzYZztEvMgYo?=
 =?us-ascii?Q?VE/W+/C9b2cImpd6z6H/XzzYksbwLZwrNBAxVDUWcPXTt3TRW20x91XRLJj6?=
 =?us-ascii?Q?WH/8WldXapIGVE+KAjfIFXWfx/wHa+/VCounJ4sWTuoJFje4iGvSYGksv/Ol?=
 =?us-ascii?Q?uwBSYfsGWhUWFg1f+5b4lClHDyiHbnryUlXUpDHrJ+FcHqnp?=
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: VB88UQDP4/k7AxJ2B9zWsZJ4ENr+6dBAYd93od1ZLB4eLuHsI3GfE04PijAMTCTFXycLNfsKoKjNdUJayndyRCa10t3xqqwEtqTMlikCZL/3vtxaHL5sX6Lu938/0XT1YMIsnWSk/VJce70yq2HgEQVTJWe3ACMdpj5YSJugJJ2ClMNDWX/JVdBXkts7bKQdvabCea/hfQ4Q6l50K3DVALP8nxOOaEZwcFX4cOJnrL34euCuVhYSQvoA4Be82S2O4eB8H/dzNTexMuvwme4Vx2zJym+O+G4Aas4loWgSNQ5tC6P5tqeZ7SHnN+LRscjS0eG07xvHvYaWo2n60A+LI+sM3UXnwbzJsxq5S+caly0g34HNkdAoZFqPkWWaOrxgXV4ZirOu1DLNgm8jcUK5UxtyDtY64VfVvwN4ZLkVh7ZExFCF7f2HhJUgC8hpy0/y4c78+wappNgO2j6lBm+AY4lBfLHsmE5xeTyYQx1SjkybO9U7c7I5MHE4haAOASySw1VNuzPGyJD7zwAJCLNcJR4g/yGXiz/Kiqv+/Qk9+kD8ABm4W6QgDfifvST+tRDsoEJCDIZBn4GwItM/6c4nS4xf2g/23sM+FDkAJ34Xt8uhf22Z97O/FXB/AUYT4qUAfgCR89R7iWTY3hRDmLB3bQ==
X-OriginatorOrg: ddn.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: LV2PR19MB5791.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 435fc2c7-22da-428c-2069-08de7086974e
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Feb 2026 13:47:29.8330 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: 8wwIEGKwBmpRUt8i0qSP/pkipMQYzpR28Uz6mK0/qrgz6NWihrYyF93qZs/tabINOBuZ9stc7uA2a/X3toFYoA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: LV8PR19MB8571
X-BESS-ID: 1771595253-105236-7696-4542-1
X-BESS-VER: 2019.1_20260219.1808
X-BESS-Apparent-Source-IP: 40.107.201.135
X-BESS-Parts: H4sIAAAAAAACA02OvQrDMAyE38VzBlmSbSmvUjpYkdMs/YFmKJS8ezy40OU4Dr
 6Pu3xD++xhDnvPKTzfYRaEXra+FeQEFZGykSymBUwzOLWq2WuCcEw/fNvvA4/IhYdAC6
 /MS8xFSvTaxH1FZ1IXI5f4J3g9bkOADDEOgUXVlMmxLtY4sySm5Mn7x4LQLBzXE21yx7
 HCAAAA
X-BESS-Outbound-Spam-Score: 0.50
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.271279 [from 
 cloudscan20-206.us-east-2b.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 BSF_SC0_MISMATCH_TO    META: Envelope rcpt doesn't match header 
 0.00 HTML_MESSAGE           BODY: HTML included in message 
 0.50 BSF_SC7_SA578_CH       META: Custom Rule SA578_CH 
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.50 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=BSF_SC0_MISMATCH_TO, HTML_MESSAGE, BSF_SC7_SA578_CH,
 BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: [lustre-devel] Crowd downtime notification
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
From: Krupal Solanki via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Krupal Solanki <ksolanki@ddn.com>
Content-Type: multipart/mixed; boundary="===============6487699046761395858=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============6487699046761395858==
Content-Language: en-US
Content-Type: multipart/related;
	boundary="_004_LV2PR19MB57914E51339DBB45E95BD4A4CD68ALV2PR19MB5791namp_";
	type="multipart/alternative"

--_004_LV2PR19MB57914E51339DBB45E95BD4A4CD68ALV2PR19MB5791namp_
Content-Type: multipart/alternative;
	boundary="_000_LV2PR19MB57914E51339DBB45E95BD4A4CD68ALV2PR19MB5791namp_"

--_000_LV2PR19MB57914E51339DBB45E95BD4A4CD68ALV2PR19MB5791namp_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable



ANNOUNCEMENT:
APPLICATION
Crowd (id.whamcloud.com)
[cid:image001.png@01DBD9EB.62A7AEE0]
SEVERITY
Planned
REASON
Upgrade to 5.2.11
WHEN:
START
Saturday, Feb 21, 2026
07:00 AM (UTC)

DURATION
4 hours
DETAILS:
Crowd service will be unavailable, and authentication services will be temp=
orarily paused. This will impact login to Atlassian products like Jira, con=
fluence etc

We are performing essential upgrades to improve the performance, stability,=
 and security of the Crowd platform.
WHAT TO DO:
No action needed.
FOR THOSE WHO WANT TO KNOW MORE:
 For additional information refer the Crowd<https://wiki.whamcloud.com/disp=
lay/PUB/Crowd+5.2.11+Upgrade> Upgrade<https://wiki.whamcloud.com/display/PU=
B/Crowd+5.2.11+Upgrade> page.
FOR SUPPORT:
If you have any concerns or questions, email us at dl-exa-devops@whamcloud.=
com


--_000_LV2PR19MB57914E51339DBB45E95BD4A4CD68ALV2PR19MB5791namp_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
</head>
<body>
<div style=3D"direction: ltr; font-family: Aptos; font-size: 12pt; color: b=
lack;"><br>
</div>
<div id=3D"mail-editor-reference-message-container">
<div id=3D"mail-editor-reference-message-container">
<div id=3D"mail-editor-reference-message-container">
<table class=3D"MsoNormalTable" id=3D"table_0" cellspacing=3D"0" cellpaddin=
g=3D"0" style=3D"margin-right: auto; margin-left: auto; width: 683.796875px=
; box-sizing: border-box; border-collapse: collapse; border-spacing: 0px;">
<tbody>
<tr>
<td rowspan=3D"3" class=3D"MsoNormalTable" style=3D"border-width: 1pt; bord=
er-style: solid; border-color: windowtext; background-color: rgb(83, 129, 5=
3); padding: 0in 5.4pt; vertical-align: top; width: 158.046875px; height: 8=
7px; box-sizing: border-box;">
<p class=3D"MsoNormal" style=3D"line-height: normal; margin: 0in; font-fami=
ly: Calibri, sans-serif; font-size: 11pt;">
<span style=3D"color: white;"><b>&nbsp;</b></span></p>
<p class=3D"MsoNormal" style=3D"line-height: normal; margin: 0in; font-fami=
ly: Calibri, sans-serif; font-size: 11pt;">
<span style=3D"color: white;"><b>ANNOUNCEMENT:</b></span></p>
</td>
<td class=3D"MsoNormalTable" style=3D"border-width: 1pt 1pt 1pt medium; bor=
der-style: solid solid solid none; border-color: windowtext windowtext wind=
owtext currentcolor; padding: 0in 5.4pt; width: 121.96875px; height: 37px; =
box-sizing: border-box;">
<p class=3D"MsoNormal" style=3D"line-height: normal; margin: 0in; font-fami=
ly: Calibri, sans-serif; font-size: 11pt;">
<span style=3D"color: rgb(0, 112, 192);"><b>APPLICATION</b></span></p>
</td>
<td class=3D"MsoNormalTable" style=3D"border-width: 1pt 1pt 1pt medium; bor=
der-style: solid solid solid none; border-color: windowtext windowtext wind=
owtext currentcolor; padding: 0in 5.4pt; word-break: break-word; width: 223=
px; height: 37px; box-sizing: border-box;">
<p class=3D"MsoNormal" style=3D"line-height: normal; margin: 0in; font-fami=
ly: Calibri, sans-serif; font-size: 11pt;">
<span style=3D"color: rgb(0, 0, 0);">Crowd (id.whamcloud.com)</span></p>
</td>
<td rowspan=3D"3" class=3D"MsoNormalTable" style=3D"border-width: 1pt 1pt 1=
pt medium; border-style: solid solid solid none; border-color: windowtext w=
indowtext windowtext currentcolor; padding: 0in 5.4pt; word-break: break-wo=
rd; width: 179.78125px; height: 87px; box-sizing: border-box;">
<p class=3D"MsoNormal" style=3D"line-height: 105%; margin: 0in 0in 8pt; fon=
t-family: Calibri, sans-serif; font-size: 11pt;">
<img src=3D"cid:image001.png@01DBD9EB.62A7AEE0" id=3D"Picture_x0020_2" widt=
h=3D"156" height=3D"66" style=3D"width: 1.6354in; height: 0.6979in; margin-=
top: 0px; margin-bottom: 0px;"></p>
</td>
</tr>
<tr>
<td class=3D"MsoNormalTable" style=3D"border-width: medium 1pt 1pt medium; =
border-style: none solid solid none; border-color: currentcolor windowtext =
windowtext currentcolor; padding: 0in 5.4pt; width: 121.96875px; height: 25=
px; box-sizing: border-box;">
<p class=3D"MsoNormal" style=3D"line-height: normal; margin: 0in; font-fami=
ly: Calibri, sans-serif; font-size: 11pt;">
<span style=3D"color: rgb(0, 112, 192);"><b>SEVERITY</b></span></p>
</td>
<td class=3D"MsoNormalTable" style=3D"border-width: medium 1pt 1pt medium; =
border-style: none solid solid none; border-color: currentcolor windowtext =
windowtext currentcolor; padding: 0in 5.4pt; word-break: break-word; width:=
 223px; height: 25px; box-sizing: border-box;">
<p class=3D"MsoNormal" style=3D"line-height: normal; margin: 0in; font-fami=
ly: Calibri, sans-serif; font-size: 11pt;">
<b>Planned</b></p>
</td>
</tr>
<tr>
<td class=3D"MsoNormalTable" style=3D"border-width: medium 1pt 1pt medium; =
border-style: none solid solid none; border-color: currentcolor windowtext =
windowtext currentcolor; padding: 0in 5.4pt; width: 121.96875px; height: 25=
px; box-sizing: border-box;">
<p class=3D"MsoNormal" style=3D"line-height: normal; margin: 0in; font-fami=
ly: Calibri, sans-serif; font-size: 11pt;">
<span style=3D"color: rgb(0, 112, 192);"><b>REASON</b></span></p>
</td>
<td class=3D"MsoNormalTable" style=3D"border-width: medium 1pt 1pt medium; =
border-style: none solid solid none; border-color: currentcolor windowtext =
windowtext currentcolor; padding: 0in 5.4pt; word-break: break-word; width:=
 223px; height: 25px; box-sizing: border-box;">
<p class=3D"MsoNormal" style=3D"line-height: normal; margin: 0in; font-fami=
ly: Calibri, sans-serif; font-size: 11pt;">
<span style=3D"color: rgb(0, 0, 0);">Upgrade to 5.2.11</span></p>
</td>
</tr>
<tr>
<td class=3D"MsoNormalTable" style=3D"border-width: medium 1pt; border-styl=
e: none solid; border-color: currentcolor windowtext; background-color: gra=
y; padding: 0in 5.4pt; vertical-align: top; width: 158.046875px; height: 25=
px; box-sizing: border-box;">
<p class=3D"MsoNormal" style=3D"line-height: normal; margin: 0in; font-fami=
ly: Calibri, sans-serif; font-size: 11pt;">
<span style=3D"color: white;"><b>WHEN:</b></span></p>
</td>
<td class=3D"MsoNormalTable" style=3D"border-width: medium 1pt 1pt medium; =
border-style: none solid solid none; border-color: currentcolor windowtext =
windowtext currentcolor; padding: 0in 5.4pt; width: 121.96875px; height: 25=
px; box-sizing: border-box;">
<p class=3D"MsoNormal" style=3D"line-height: normal; margin: 0in; font-fami=
ly: Calibri, sans-serif; font-size: 11pt;">
<span style=3D"color: rgb(0, 112, 192);"><b>START</b></span></p>
</td>
<td class=3D"MsoNormalTable" style=3D"border-width: medium 1pt 1pt medium; =
border-style: none solid solid none; border-color: currentcolor windowtext =
windowtext currentcolor; padding: 0in 5.4pt; word-break: break-word; width:=
 223px; height: 25px; box-sizing: border-box;">
<p class=3D"MsoNormal" style=3D"line-height: normal; margin: 0in; font-fami=
ly: Calibri, sans-serif; font-size: 11pt;">
Saturday, Feb 21, 2026</p>
</td>
<td class=3D"MsoNormalTable" style=3D"border-width: medium 1pt 1pt medium; =
border-style: none solid solid none; border-color: currentcolor windowtext =
windowtext currentcolor; padding: 0in 5.4pt; word-break: break-word; width:=
 179.78125px; height: 25px; box-sizing: border-box;">
<p class=3D"MsoNormal" style=3D"line-height: normal; margin: 0in; font-fami=
ly: Calibri, sans-serif; font-size: 11pt;">
07:00 AM (UTC)</p>
</td>
</tr>
<tr>
<td class=3D"MsoNormalTable" style=3D"text-align: center; border-width: med=
ium 1pt 1pt; border-style: none solid solid; border-color: currentcolor win=
dowtext windowtext; background-color: gray; padding: 0in 5.4pt; vertical-al=
ign: top; width: 158.046875px; height: 25px; box-sizing: border-box;">
<p class=3D"MsoNormal" style=3D"text-align: center; line-height: normal; ma=
rgin: 0in; font-family: Calibri, sans-serif; font-size: 11pt;">
<span style=3D"color: white;"><b>&nbsp;</b></span></p>
</td>
<td class=3D"MsoNormalTable" style=3D"border-width: medium 1pt 1pt medium; =
border-style: none solid solid none; border-color: currentcolor windowtext =
windowtext currentcolor; padding: 0in 5.75pt; width: 121.96875px; height: 2=
5px; box-sizing: border-box;">
<p class=3D"MsoNormal" style=3D"line-height: normal; margin: 0in; font-fami=
ly: Calibri, sans-serif; font-size: 11pt;">
<span style=3D"color: rgb(0, 112, 192);"><b>DURATION</b></span></p>
</td>
<td colspan=3D"2" class=3D"MsoNormalTable" style=3D"border-width: medium 1p=
t 1pt medium; border-style: none solid solid none; border-color: currentcol=
or windowtext windowtext currentcolor; padding: 0in 5.4pt; width: 402.78125=
px; height: 25px; box-sizing: border-box;">
<p class=3D"MsoNormal" style=3D"line-height: normal; margin: 0in; font-fami=
ly: Calibri, sans-serif; font-size: 11pt;">
4 hours</p>
</td>
</tr>
<tr>
<td class=3D"MsoNormalTable" style=3D"border-width: medium 1pt 1pt; border-=
style: none solid solid; border-color: currentcolor windowtext windowtext; =
background-color: gray; padding: 0in 5.4pt; vertical-align: top; width: 158=
.046875px; height: 155px; box-sizing: border-box;">
<p class=3D"MsoNormal" style=3D"line-height: normal; margin: 0in; font-fami=
ly: Calibri, sans-serif; font-size: 11pt;">
<span style=3D"color: white;"><b>DETAILS:</b></span></p>
</td>
<td colspan=3D"3" class=3D"MsoNormalTable" style=3D"border-width: medium 1p=
t 1pt medium; border-style: none solid solid none; border-color: currentcol=
or windowtext windowtext currentcolor; padding: 0in 5.75pt; width: 524.75px=
; height: 155px; box-sizing: border-box;">
<p class=3D"MsoNormal" style=3D"text-align: left; text-indent: 0px; line-he=
ight: normal; margin-right: 0in; margin-left: 0in;">
<span style=3D"font-family: Calibri, sans-serif; font-size: 11pt; color: rg=
b(0, 0, 0);">Crowd service will be
<b>unavailable</b>, and authentication services will be temporarily paused.=
 This will impact login to Atlassian products like Jira, confluence etc</sp=
an></p>
<p class=3D"MsoNormalTable" style=3D"text-align: left; text-indent: 0px;"><=
span style=3D"font-family: Calibri, sans-serif; font-size: 11pt; color: rgb=
(0, 0, 0);">We are performing essential upgrades to improve the performance=
, stability, and security of the Crowd
 platform.</span><span style=3D"font-family: Aptos, sans-serif; font-size: =
11pt;">&nbsp;</span><span style=3D"font-family: Calibri, sans-serif; font-s=
ize: 11pt;">&nbsp;&nbsp;&nbsp;</span></p>
</td>
</tr>
<tr>
<td class=3D"MsoNormalTable" style=3D"border-width: medium 1pt 1pt; border-=
style: none solid solid; border-color: currentcolor windowtext windowtext; =
background-color: gray; padding: 0in 5.4pt; vertical-align: top; width: 158=
.046875px; height: 41px; box-sizing: border-box;">
<p class=3D"MsoNormal" style=3D"line-height: normal; margin: 0in; font-fami=
ly: Calibri, sans-serif; font-size: 11pt;">
<span style=3D"color: white;"><b>WHAT TO DO:</b></span></p>
</td>
<td colspan=3D"3" class=3D"MsoNormalTable" style=3D"border-width: medium 1p=
t 1pt medium; border-style: none solid solid none; border-color: currentcol=
or windowtext windowtext currentcolor; padding: 0in 5.4pt; width: 524.75px;=
 height: 41px; box-sizing: border-box;">
<p class=3D"MsoNormal" style=3D"line-height: normal; margin: 0in;"><span st=
yle=3D"font-family: Calibri, sans-serif; font-size: 11pt; color: black;">No=
 action needed.&nbsp;</span></p>
</td>
</tr>
<tr>
<td class=3D"MsoNormalTable" style=3D"border-width: medium 1pt 1pt; border-=
style: none solid solid; border-color: currentcolor windowtext windowtext; =
background-color: gray; padding: 0in 5.4pt; vertical-align: top; width: 158=
.046875px; height: 56px; box-sizing: border-box;">
<p class=3D"MsoNormal" style=3D"line-height: normal; margin: 0in; font-fami=
ly: Calibri, sans-serif; font-size: 11pt;">
<span style=3D"color: white;"><b>FOR THOSE WHO WANT TO KNOW MORE:</b></span=
></p>
</td>
<td colspan=3D"3" class=3D"MsoNormalTable" style=3D"border-width: medium 1p=
t 1pt medium; border-style: none solid solid none; border-color: currentcol=
or windowtext windowtext currentcolor; padding: 0in 5.4pt; width: 524.75px;=
 height: 56px; box-sizing: border-box;">
<p class=3D"MsoNormal" style=3D"line-height: normal; margin: 0in; font-fami=
ly: Calibri, sans-serif; font-size: 11pt;">
&nbsp;For additional information refer the <a href=3D"https://wiki.whamclou=
d.com/display/PUB/Crowd+5.2.11+Upgrade" data-outlook-id=3D"3ba03351-406e-43=
9e-adad-199bd804863f" style=3D"margin-top: 0px; margin-bottom: 0px;">
Crowd</a><span style=3D"color: rgb(70, 120, 134);"><u><a href=3D"https://wi=
ki.whamcloud.com/display/PUB/Crowd+5.2.11+Upgrade" data-outlook-id=3D"b19c2=
a4f-6c0f-4d0e-9ad6-79b295a224b2" style=3D"margin-top: 0px; margin-bottom: 0=
px;">&nbsp;Upgrade</a></u></span>&nbsp;page.</p>
</td>
</tr>
<tr>
<td class=3D"MsoNormalTable" style=3D"border-width: medium 1pt 1pt; border-=
style: none solid solid; border-color: currentcolor windowtext windowtext; =
background-color: gray; padding: 0in 5.4pt; vertical-align: top; width: 158=
.046875px; height: 49px; box-sizing: border-box;">
<p class=3D"MsoNormal" style=3D"line-height: normal; margin: 0in; font-fami=
ly: Calibri, sans-serif; font-size: 11pt;">
<span style=3D"color: white;"><b>FOR SUPPORT:</b></span></p>
</td>
<td colspan=3D"3" class=3D"MsoNormalTable" style=3D"border-width: medium 1p=
t 1pt medium; border-style: none solid solid none; border-color: currentcol=
or windowtext windowtext currentcolor; padding: 0in 5.4pt; width: 524.75px;=
 height: 49px; box-sizing: border-box;">
<p class=3D"MsoNormal" style=3D"line-height: normal; margin: 0in; font-fami=
ly: Calibri, sans-serif; font-size: 11pt;">
If you have any concerns or questions, email us at dl-exa-devops@whamcloud.=
com&nbsp;</p>
</td>
</tr>
</tbody>
</table>
<p class=3D"MsoNormal" style=3D"line-height: 105%; margin: 0in 0in 8pt; fon=
t-family: Calibri, sans-serif; font-size: 11pt;">
<span style=3D"font-family: Aptos, sans-serif; font-size: 12pt; line-height=
: 105%;">&nbsp;</span></p>
</div>
</div>
</div>
</body>
</html>

--_000_LV2PR19MB57914E51339DBB45E95BD4A4CD68ALV2PR19MB5791namp_--

--_004_LV2PR19MB57914E51339DBB45E95BD4A4CD68ALV2PR19MB5791namp_
Content-Type: image/png; name="image001.png"
Content-Description: image001.png
Content-Disposition: inline; filename="image001.png"; size=24011;
	creation-date="Tue, 10 Jun 2025 16:38:14 GMT";
	modification-date="Fri, 20 Feb 2026 13:40:15 GMT"
Content-ID: <image001.png@01DBD9EB.62A7AEE0>
Content-Transfer-Encoding: base64

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
AAAAAAAAAAAAAAAAAAA=

--_004_LV2PR19MB57914E51339DBB45E95BD4A4CD68ALV2PR19MB5791namp_--

--===============6487699046761395858==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============6487699046761395858==--
