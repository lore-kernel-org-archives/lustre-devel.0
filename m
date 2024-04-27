Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id F0EC2C4345F
	for <lustre-devel@archiver.kernel.org>; Sat, 27 Apr 2024 13:23:33 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4VRVfD31Dyz1y5B;
	Sat, 27 Apr 2024 06:23:32 -0700 (PDT)
Received: from mx0a-00069f02.pphosted.com (mx0a-00069f02.pphosted.com
 [205.220.165.32])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4VRBWp22Myz1wgs
 for <lustre-devel@lists.lustre.org>; Fri, 26 Apr 2024 18:16:54 -0700 (PDT)
Received: from pps.filterd (m0246617.ppops.net [127.0.0.1])
 by mx0b-00069f02.pphosted.com (8.17.1.19/8.17.1.19) with ESMTP id
 43QKAW1E020320
 for <lustre-devel@lists.lustre.org>; Sat, 27 Apr 2024 01:16:53 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com;
 h=from : to : subject :
 date : message-id : references : in-reply-to : content-type :
 mime-version; s=corp-2023-11-20;
 bh=7jqYArHec8uAZpuHD8BiG/aV/heI7jIs/puOxB3Ww9g=;
 b=A9doYaH1sq8Cp6ZNBn0AJ11oF+MQYKeAPL1tO8KjRnyVJqiAgy7u84VrNU0MGpraSxFK
 hhCsLsv2lpbqKFOClJLpidmEUJJnrVTBSPQxUMAZtn884YaJy4Ok5uJWtSqF1lkJ9XWo
 xbUOCCo/m33KtOadWOSb4QbDtth1o1r4cws6Q4/Ht478NIGrC6j77Tv2b92jNL/Of+1D
 Frs5o7K0aNchbac/QEt/0qGUNnu7QE1xJivigCZcjR2F9BAXiRjJYnl0Weii7jvWyQbt
 m5d7FpHKYXrvX+0Iv1kAu9qWaUr8/W8WDfYkGCR8lnE7PEtslKtBCJYjJ+6cqaZALduz 2g== 
Received: from phxpaimrmta01.imrmtpd1.prodappphxaev1.oraclevcn.com
 (phxpaimrmta01.appoci.oracle.com [138.1.114.2])
 by mx0b-00069f02.pphosted.com (PPS) with ESMTPS id 3xm68vq1y8-1
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
 for <lustre-devel@lists.lustre.org>; Sat, 27 Apr 2024 01:16:53 +0000
Received: from pps.filterd
 (phxpaimrmta01.imrmtpd1.prodappphxaev1.oraclevcn.com [127.0.0.1])
 by phxpaimrmta01.imrmtpd1.prodappphxaev1.oraclevcn.com (8.17.1.19/8.17.1.19)
 with ESMTP id 43R19CHo030804
 for <lustre-devel@lists.lustre.org>; Sat, 27 Apr 2024 01:16:52 GMT
Received: from nam11-bn8-obe.outbound.protection.outlook.com
 (mail-bn8nam11lp2169.outbound.protection.outlook.com [104.47.58.169])
 by phxpaimrmta01.imrmtpd1.prodappphxaev1.oraclevcn.com (PPS) with ESMTPS id
 3xm45cat1a-1
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
 for <lustre-devel@lists.lustre.org>; Sat, 27 Apr 2024 01:16:52 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=CEYp1HBkgRTyoI0XiccbHHfsAQnKeGmICZZi6L5kx5Ff/Nb0ZoIAxm4p/n4EF+MhU0/pNn1uZv2WJd9cPCmbQWxL2dn/XvpKn/bGq+xc9y+HTSBxFugETNHWeCYGT86VbEq92lrkXg9spqhGA59kAukmqPfNMDMUhxho67WIr46lS1shfJjEIg2s0L0vfIA9E06lZ1Sy9SoQ2PGnYCuJH+oJM0SYvGVsQ9shVBtyvASdK8SZCuXUIK5QlrH1ObDQuO62jd937IG8e6mmLFj1x+djwJB4Yws1kWl7/C6tPMoK15oxZ/6C/SsB0g21rP3it7C2QadPrQdnWeRDbjBhJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=7jqYArHec8uAZpuHD8BiG/aV/heI7jIs/puOxB3Ww9g=;
 b=Kz0VL4eKs9XSQZAOhG7Km02x+mjgwWrHS1Xyhpk1+hMh3hvwmrsv9TjOVcYqmpehqDt3YcU+X7ge8aAMW/lo4DbtqeHA0gp91po5O3EAkwPfpJD1b4kaNcJtbvzW1k8+92FJ51eCREg1wyMh9hO1AHwfWb86kzNcYfxETbr977D8wh+1AdwWzgLR4POsxlYNMTp37fb+J10tb2YRDQSR0b5aSdIjALedln8MCbT9ha3qHAK6aQxBIg82vXLLwvJ5YUCECL0xtvuQ+uZPF3zHZfUGaK+eD2vYtOYce5G+39iKBH1CHN6GSXHRFz9OYzPJkBgHVYNcI8gVSqm9z1VNnQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=oracle.com; dmarc=pass action=none header.from=oracle.com;
 dkim=pass header.d=oracle.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=oracle.onmicrosoft.com; s=selector2-oracle-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=7jqYArHec8uAZpuHD8BiG/aV/heI7jIs/puOxB3Ww9g=;
 b=MV8YIqaBD7HvdTvD4C/iejdVAYcNg4W531bfx8onYr4aBB6IcvBmxNay9B9Wv6ml/P/a9Js+Jv/SrJEAD6HPN8XcH3Wl4/EGsKI8kkIWFZPHDCa68hjuiD7fbDRE6iepuvkezVLhW0NjiRjbW2YVDQJAkV5+J88I0/79g1PQwhI=
Received: from SN6PR10MB2813.namprd10.prod.outlook.com (2603:10b6:805:cc::12)
 by MW4PR10MB6372.namprd10.prod.outlook.com (2603:10b6:303:1e9::18)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.7519.22; Sat, 27 Apr
 2024 01:16:48 +0000
Received: from SN6PR10MB2813.namprd10.prod.outlook.com
 ([fe80::7500:d188:dcd1:3f28]) by SN6PR10MB2813.namprd10.prod.outlook.com
 ([fe80::7500:d188:dcd1:3f28%4]) with mapi id 15.20.7519.021; Sat, 27 Apr 2024
 01:16:48 +0000
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: [External] : [lustre-devel] OSC cache page retention issue
Thread-Index: AQHal+43sq2dftFewkWTQDQ9vkMTh7F6sXYmgACfxLY=
Date: Sat, 27 Apr 2024 01:16:48 +0000
Message-ID: <SN6PR10MB281345CCB9F2F3E94D9FCDA399152@SN6PR10MB2813.namprd10.prod.outlook.com>
References: <49a986ae-fd43-4ee0-bd01-44cf56359a4a@iodoctors.com>
 <SN6PR10MB281386AAAE5333F3A2D195D199162@SN6PR10MB2813.namprd10.prod.outlook.com>
In-Reply-To: <SN6PR10MB281386AAAE5333F3A2D195D199162@SN6PR10MB2813.namprd10.prod.outlook.com>
Accept-Language: en-US
Content-Language: en-US
X-Hashtags: #NewslettersPlus
X-MS-Has-Attach: yes
X-MS-TNEF-Correlator: 
msip_labels: 
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: SN6PR10MB2813:EE_|MW4PR10MB6372:EE_
x-ms-office365-filtering-correlation-id: b86d0da8-57c6-4b65-b305-08dc6657b615
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230031|366007|1800799015|376005|38070700009;
x-microsoft-antispam-message-info: =?us-ascii?Q?l9gcgEFq5IJaZuuGg6gg0KnlvJIbQLwk2/TKP6k6hoy8X68ygrlhVyZOlNwV?=
 =?us-ascii?Q?2IIgv/S+tmfagft9Ov0BeVDemTS+0enRG+ImrF3/lu7XXf7fr+VBCDKYg8/Q?=
 =?us-ascii?Q?25FHgcMgjHGF8Mu8ANIv/vPajOXBtuwyb/LbsqpR80PzUORF/cEiDWeRjuJO?=
 =?us-ascii?Q?48zp1rmhirq4fI2xdKv8/9Ru1UeDgKQ57uSon0FcytJ7ak2MnkvBdeLJZUTz?=
 =?us-ascii?Q?ghPDecUs+TJd74uI5rApul400wh3MHyRM3zfgcQkSe5oeruCDF+py5Lf52/8?=
 =?us-ascii?Q?XOIszv5jp3Ex5GssLW5syceNIaZz2bvKT7jySyCSKZOnkEOiWxMnvpaZVtPZ?=
 =?us-ascii?Q?VRe2raE+yH5B8krXvDUsTXXLCvKOfmrkD2M1aVFL7gcs8LooFtbgdn9MvUiB?=
 =?us-ascii?Q?gXQXebl9ns/1S96wT1qQ6yL2ak/svMae+osAuydqBW5RsdHEhwL/g79xZBWC?=
 =?us-ascii?Q?0KUDUBH7k47AMNmAIBy32iXfvavIxT1hY8zCXi0ftfLLYf8ET/g4PxgTXXae?=
 =?us-ascii?Q?StGZaN3YxCY3bf7zrxc5n3VWapDL5s8Ey3OtArcV3bhTI3Rvsbi0GU1OgHnN?=
 =?us-ascii?Q?oC/5tGnFGsQQSjygUt5WKlGkMce83VsEmI2QSUr3/4ZPS9XLtnMZbXbY9J6Z?=
 =?us-ascii?Q?6pBCc3VULSqDGy0oqM1c/VBAAtL9cRGQs62I8VvCt1kaMJbXu6vvONZBBmnr?=
 =?us-ascii?Q?5WVZIimrY8OAu8X6vbcG0q8KnOehhNi6mZepAt3oSkycYDVQbej4d2RLOqob?=
 =?us-ascii?Q?zBIEigxxKsJupL38B3yo3B6qd1x/ae1G5bT/R/M/HK+vnGdpRb7ncXaioM9u?=
 =?us-ascii?Q?HjQScxX6et+XJJb5DGmmuycoJaa9SBGXAiD2rLC1aVCeCbbViFn2Ie59rVBK?=
 =?us-ascii?Q?098zoupnIcYcutbi7Ojr5t7gaGFhgZePXt2yuEJ1DJfbA9p9Hx3UWLgFMbJM?=
 =?us-ascii?Q?3/INv5Ehh4ABcqAmk6gPjBtJqYPkWgaBwerWIy69WWZ+AotUEGYqg0o++mXy?=
 =?us-ascii?Q?ytEAIhw/nTmwOmY2WvRdBCFnn180b8OyhEW+eQ7/T2X/HsEbNuw1Cp6PmkeR?=
 =?us-ascii?Q?7NQ6aOizPtG0f9gpDiI0W7zgu+f8ubSti7zyTFUNaWU2xDgrV+RToWXlyTYO?=
 =?us-ascii?Q?MPrfYeM4k9A1yoFUi4a1iWA0fMHD8sg+wsLaVXlvZNjZa2NpVNi8TchNMx83?=
 =?us-ascii?Q?SaBnTdIcFpUiYFMQPoHwCxym/uBbRD/ajLgSgTZ77T/1+lNSJGqBl9wIwH60?=
 =?us-ascii?Q?YStN/kLqgrbU+GqeQujaxTGj2VS4Gw9k5s+5FWPcjHyhI/jJYidftus8MbBC?=
 =?us-ascii?Q?KJI=3D?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:SN6PR10MB2813.namprd10.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230031)(366007)(1800799015)(376005)(38070700009); DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?3yS5Lx7e52JqH/soEfa9L4W5f1gLHE6IOturBRZKjv4KTwviHu87Qb1v+oRT?=
 =?us-ascii?Q?Nm2lb7/h8RFrMPgldcS/qGSgk0irQNS35ntgyOFKUkrKarb8pFgW7A8L/duF?=
 =?us-ascii?Q?bWvUPVypV7EHFu8H9jknLL7YYQNMc3kC1ttyFt2Af+IEK9XEC3JHToUNEpig?=
 =?us-ascii?Q?ffz1WdWcMb0ua7UnZgbo+jWZ0VXij8bj3DQJ8hr2ghbalZNfjDO3RO3bEnuM?=
 =?us-ascii?Q?hpJmiyoJubm7Qp/HyMk3m8V3zmrpw05WLF1wCnQGpXNlIhXwOy0mREgCR8oz?=
 =?us-ascii?Q?1BTTd1gAgLTSkx5ucFrkVMrialllxh4KSspsULV8QsoWrxUXCZpxT3WYpItB?=
 =?us-ascii?Q?5NtTOliqob7EH8rZYMr8Jg4locGJb7XXWWxeehC8i+XW+TNKmTupjF2QbSPX?=
 =?us-ascii?Q?NUdKBiaSWi3pjLjo0Uq9VsIfdLOC90Ks90cDkNKmZhb/Lg1e8IL4bTiR1QWH?=
 =?us-ascii?Q?+ArAWC9ZkuyhPeqCdo/epkUBscWxdwsumKuqjS3ICQAIZHhUkl3RxXDkov8o?=
 =?us-ascii?Q?EJWZJ5cb0ZVDvOYgrGQ1qeGPRw7BBhQLWQFyihXcDht6eJ+jTwJgnqzax2nq?=
 =?us-ascii?Q?5vutFhsLIHealg3VCQKLJRx4NqFGLQtVoQNVzAT2mt0w1gp0OMhxgSjslAVX?=
 =?us-ascii?Q?4tU0liukFcTuCxWoQJ5QTykEDuukzYaeCvbBXvmXZyZWCbI7rsupMq6/G7ah?=
 =?us-ascii?Q?zo1eitvx3IFp+Wl2fI85Y0zZmJz1QjkonQ0e0Uu7aA2vn8QFTBPiybH/tRub?=
 =?us-ascii?Q?UzlxC2l5FeGe3c1hdtAxMVfOAwT1ZRIj8jOsrCzIGvvSphCuW0GWgDF0mnxs?=
 =?us-ascii?Q?qfQkPmf64UWZ4mCsDDI3bwUNiy5nBOsNWS14QOVpWuQM2L23r1NZoaqG40Ow?=
 =?us-ascii?Q?qKqZ8EFghDhWKcqPiuAiY2D3rbz/6n04T9JnQaUyMrU63NPFFly64UCKu/Or?=
 =?us-ascii?Q?+PAtFJE1sSwoJXMIx6FRPjeWKro51cM3Tzk+513E1CCamfr57WW2/iHVp4kR?=
 =?us-ascii?Q?CqDDX0Ds9psN2gkIr9zd6xPSK1BDjAIatvhYdm78jKTRqG8aHxsw4uDQDnPT?=
 =?us-ascii?Q?AWQVUDQPibsawIWUIykpmGL9yRy4M/3QN3WkmhTQxEES97DqYmcY+Curu140?=
 =?us-ascii?Q?kWi/X6we4lS4pkIc6Ayj0tISO99yDiMsF/D9FnyUSpGA0eY0rMi6EkjBAuvX?=
 =?us-ascii?Q?AQ1LL2GoQ1Mw4VrqeVQ/nB9HbTLrD55leoQfTS0YkIbi8mpZkPpK+mStewLC?=
 =?us-ascii?Q?dtLfo2eg9bbXIi9Bm+3S8o9c1GybQE7PRymXdBkF7gWyDvJmyB1iCZOBtXbv?=
 =?us-ascii?Q?jpIWeeXHXsu587GsuQEprttiw/6m0LCrakQzvbnkop3gVdhFJlFJ5VFF805k?=
 =?us-ascii?Q?oPiFQVl+8JBp8zyEoXu5AFf9Nv6qFy/nlAsz/yuwWuAgx5gCE3BGKV6zWqyD?=
 =?us-ascii?Q?W/m4ZNYdUN7FehIG5k4jRQU6SO4nN46iA5i3gLpGWl0gAdENNzOeL9qr8GsV?=
 =?us-ascii?Q?IYr1df/dkiYIFMKP0iz6HUNouK0JScM0bj4VVZrAh43plj5ohUU1um2xn8xz?=
 =?us-ascii?Q?jsT/HYZfxFrl4iS5BrhMnNS4o3bMJeajZGlwefYW?=
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: H2iKDSRGftJC3Zx5SiqAxLNDe/HmoIMTj5l0JVslFrMjdWvDJs3T72OwDnWosrhRnZVoaEmYx7GW+GRvjtHEdpcV2VWNh0uTMUUYMOkzqNJdY1T7itPU3w+Sl769tNhBOPaqhiAFoy3Fc+QfnPsHVmHEfRBOes/ZGl6Q8/RtLMAxVl3PvkMfyGyT1kriCYvBPtQ/yZ0YxfRwvLepR5RrSck426rnh6yNnUkqAXikRVV6HzhCitzITo6RTC8HZuz45gxxh1bYC44miG/YkamlzX85BY19YJDXbGKhA4i2Mx8y4GItCYckvsYSfCh03niPMOKm0n6oBLpDxGihiCKVdDQG5YT1iuQAfilT6i1u43HkbOktB6XZ/v48RDWxj4G6tpZksKLFi2k91ph6m0BqmofbiUxYgne7bNqDHvs7d3hZwzCeQWzTiKjbGZFN3bXh+uQde3fZh7u2VoAFf1QTpgIeS0h1jrPWugkw1cJGZsdasksBErhoNR1IM/4SinRXetmtAVjSl97Ij6UBxD1pzcfOiCZJuXo+hYQ2LQz54UC291B5432mJGbXtRjj8O0VeXO3sovhgCMh6d7EzTJdl35lCqYGlCI/JKF7JJ55EmM=
X-OriginatorOrg: oracle.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: SN6PR10MB2813.namprd10.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b86d0da8-57c6-4b65-b305-08dc6657b615
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Apr 2024 01:16:48.2566 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 4e2c6054-71cb-48f1-bd6c-3a9705aca71b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Y229fCR+tuCdzyQORLh6/3u/tIVnktx5yIek3bCexeTEk+VTPLp63RwO9fubC/G2lgjpU7MEh9yLkw10KXbSZTZpzlW7sF76mbNL7VjZ1K4=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MW4PR10MB6372
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1011,Hydra:6.0.650,FMLib:17.11.176.26
 definitions=2024-04-26_21,2024-04-26_02,2023-05-22_02
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 phishscore=0
 suspectscore=0 mlxscore=0
 mlxlogscore=999 bulkscore=0 malwarescore=0 spamscore=0 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.12.0-2404010000
 definitions=main-2404270007
X-Proofpoint-GUID: 6NzuQca59f4fsECJYnA5NdNa9HI_d5C4
X-Proofpoint-ORIG-GUID: 6NzuQca59f4fsECJYnA5NdNa9HI_d5C4
X-Mailman-Approved-At: Sat, 27 Apr 2024 06:23:27 -0700
Subject: [lustre-devel] Fw: [External] :  OSC cache page retention issue
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
From: Patrick Farrell via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Patrick Farrell <patrick.farrell@oracle.com>
Content-Type: multipart/mixed; boundary="===============3139964631343228796=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============3139964631343228796==
Content-Language: en-US
Content-Type: multipart/related;
	boundary="_010_SN6PR10MB281345CCB9F2F3E94D9FCDA399152SN6PR10MB2813namp_";
	type="multipart/alternative"

--_010_SN6PR10MB281345CCB9F2F3E94D9FCDA399152SN6PR10MB2813namp_
Content-Type: multipart/alternative;
	boundary="_000_SN6PR10MB281345CCB9F2F3E94D9FCDA399152SN6PR10MB2813namp_"

--_000_SN6PR10MB281345CCB9F2F3E94D9FCDA399152SN6PR10MB2813namp_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Accidentally replied to John off-list
________________________________
From: Patrick Farrell <patrick.farrell@oracle.com>
Sent: Friday, April 26, 2024 11:15 AM
To: John Bauer <bauerj@iodoctors.com>
Subject: Re: [External] : [lustre-devel] OSC cache page retention issue

John,

Ah, this one...  OK, I'm intrigued today.

Most likely the issue is that our page cache shrinker doesn't work very wel=
l.  It's not something I've dug into in detail before, but that's the simpl=
e explanation - The kernel expresses memory pressure by calling shrinkers r=
egistered by kernel modules.  Lustre has a shrinker at the OSC level which =
is responsible for freeing pages from cache when there's memory pressure.

The relevant function is osc_cache_shrink_scan (which actually shrinks as w=
ell as scans).  Unfortunately it's devoid of any debug so without modifying=
 the code to add debug, you won't be able to get any info out of it.

I see a few possible issues - the shrinker will not remove more than one RP=
C worth of pages from a given OSC when the shrinker is called.  This is a p=
retty small amount, and it's probably actually smaller - the code comments =
note the shrinker only requests 128 pages at a time and Lustre just tries t=
o free what's asked for.

FWIW, the shrinker doesn't appear to have any biasing towards OSCs which ar=
e more full.  So when called, it will try to free (probably) 128 pages from=
 the first OSC in the list, then move that OSC to the back of the list and =
stop.  If the kernel still needs memory, it will be called repeatedly.

So the idea at least is that the shrinker will rotate across the OSCs, free=
ing 128 pages each time.  It doesn't care how full they are.

Here's a possible framework for the problem.  I can't quite infer the strip=
ing and OSCs used by the files from your note - sorry, it's probably there =
but I'm struggling to figure it out - but...

If the file we wish were getting evicted is already in cache is on OSCs 0-3=
, and the new file is on OSCs, say, 0-16, so when we start, the caches for =
OSCs 0-3 are full and those for OSCs 4-16 are not, our shrinker design woul=
d not preferentially drain the full ones.  It would just start draining and=
 then balance the drain equally across all OSCs, so if the system as a whol=
e is at memory pressure, and the source of the memory pressure is using all=
 OSCs, any OSCs which are full will stay full - since they are being refill=
ed.  There will be no rebalancing of usage between those which are full and=
 those which are not.

Does this actually line up with your problem?  Or are the files on separate=
 OSCs?

Even if this isn't the issue, the problem is very likely something in our s=
hrinker implementation.

Regards,
Patrick


________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of Joh=
n Bauer <bauerj@iodoctors.com>
Sent: Friday, April 26, 2024 10:26 AM
To: lustre-devel@lists.lustre.org <lustre-devel@lists.lustre.org>
Subject: [External] : [lustre-devel] OSC cache page retention issue


 My first posting here.  I hope it proves to be interesting.

I have an issue that I had posted to lustre-discuss some time back and Andr=
eas Dilger recommended I post to lustre-devel.  I have a job that does I/O =
to 3 files on a Lustre file system.  The first file, SCRATCH, that gets wri=
tten and read in the first 50 seconds of the job. then nothing until rtc=3D=
2950 (rtc is real time clock, in seconds). The second file, SCR300, is writ=
ten and read thoughout the job.  I attach a couple of images below to indic=
ate the activity.  In each image, the bottom frame indicates how the file i=
s being accessed, reads and writes, over time.  The Y axis indicates the pa=
rt of the file being accessed and the X indicates the time when the access =
occured.  The top frame in each image is the amount of page cache used by e=
ach OSC that the given file is striped on ( 4x1M ), versus time.  The third=
 file is trivial ( 26MB in size and 41MB transferred ) and will not be ment=
ioned further.

What is of interest is that the 4 OSC's associated with SCRATCH do not give=
 up their cache page memory until rtc=3D2918, despite the file not being ac=
cessed from rtc=3D50 until rtc=3D2950, especially in light of the intense m=
emory pressure created by the reading and writing of the SCR300 file.

Thinking this was virtual memory related, I decided to plot all of the valu=
es in /proc/vmstat versus time while the job was running and see if somethi=
ng of interest was occurring at rtc=3D2918.  It turns out that the only thi=
ng of interest is the value slabs_scanned is constant until rtc=3D2918, the=
n has a spike, as shown in the 3rd image below.

For completeness, I have also included a plot of several /proc/meminfo valu=
es versus time ( the 4th image below ).

This was run on a dedicated 64GB node.  It can be seen in the meminfo plot =
that Lustre is using, at maximum, 50% of system memory.  The 4 OSC's of the=
 SCRATCH file are holding on to aggregate 22GB of memory of 32GB maximum us=
ed by Lustre.  The SCR300 file is left with 10GB of memory for repeated for=
ward and backward reading of a 70GB region of the 104GB file.  The SCR300 c=
ould really use the 22GB being held for SCRATCH.

Lustre version is 2.14.0_ddn98.

Single process, single host ( 2 NUMA nodes )

For completeness I have included a plot of memory info for each of the 2 NU=
MA nodes.  5th image below.  It can clearly be seen that memory on both num=
a nodes are active.

I should point out that this is not a new problem, nor unique to the curren=
t system I am running it on.  I had first observed it back in 2015 on an in=
ternal system at Cray Inc.  A plot of the SCRATCH file position activity is=
 shown in the 6th image below.  This was the actual MSC.Nastran job running=
, and there was  13150 seconds of I/O wait out of 18213 second run.  In thi=
s job, the 4 OSC's for the SCRATCH file never released their memory, despit=
e the file not being accessed for 18000 seconds ( 5 hours ).

Any light that could be cast upon this subject is welcomed.

John


The SCRATCH file activity and OSC memory usage

https://www.dropbox.com/scl/fi/mg55d6xv6hanmsebn4kvq/floorpan_SCRATCH.png?r=
lkey=3Drjkczx394n9mg54xtos87s0wd&st=3Dzx56loc2&dl=3D0<https://urldefense.co=
m/v3/__https://www.dropbox.com/scl/fi/mg55d6xv6hanmsebn4kvq/floorpan_SCRATC=
H.png?rlkey=3Drjkczx394n9mg54xtos87s0wd&st=3Dzx56loc2&dl=3D0__;!!ACWV5N9M2R=
V99hQ!Km2c9xVnQ_BpUQ_AOFMN3K5SjxMEuVgpx7NPRzEnGLLeS2Itg3w2y02BJJNx1gZOkbH3C=
M26NI-JpmsRcFSFtg$>

[https://www.dropbox.com/scl/fi/mg55d6xv6hanmsebn4kvq/floorpan_SCRATCH.png?=
rlkey=3Drjkczx394n9mg54xtos87s0wd&st=3Dyauwg1uo&dl=3D0]

The SCR300 file activity and OSC memory usage

https://www.dropbox.com/scl/fi/e8s4ku7zb2h6ndcwpsr3g/floorpan_SCR300.png?rl=
key=3Delxv51uqjxv7pqwj6w3o4tmew&st=3D1yapxmen&dl=3D0<https://urldefense.com=
/v3/__https://www.dropbox.com/scl/fi/e8s4ku7zb2h6ndcwpsr3g/floorpan_SCR300.=
png?rlkey=3Delxv51uqjxv7pqwj6w3o4tmew&st=3D1yapxmen&dl=3D0__;!!ACWV5N9M2RV9=
9hQ!Km2c9xVnQ_BpUQ_AOFMN3K5SjxMEuVgpx7NPRzEnGLLeS2Itg3w2y02BJJNx1gZOkbH3CM2=
6NI-Jpmsmo4TYdw$>

[https://www.dropbox.com/scl/fi/e8s4ku7zb2h6ndcwpsr3g/floorpan_SCR300.png?r=
lkey=3Delxv51uqjxv7pqwj6w3o4tmew&st=3Dcjwzzohl&dl=3D0]

The slabs_scanned from /proc/vmstat versus time.

https://www.dropbox.com/scl/fi/qwg2uml7hpi204cazfynw/floorpan_slabs_scanned=
.png?rlkey=3Dt4bhpobhwprhtlecbfsz1sy09&st=3Dmjepc6uw&dl=3D0<https://urldefe=
nse.com/v3/__https://www.dropbox.com/scl/fi/qwg2uml7hpi204cazfynw/floorpan_=
slabs_scanned.png?rlkey=3Dt4bhpobhwprhtlecbfsz1sy09&st=3Dmjepc6uw&dl=3D0__;=
!!ACWV5N9M2RV99hQ!Km2c9xVnQ_BpUQ_AOFMN3K5SjxMEuVgpx7NPRzEnGLLeS2Itg3w2y02BJ=
JNx1gZOkbH3CM26NI-Jpmtzuafs1Q$>

[https://www.dropbox.com/scl/fi/qwg2uml7hpi204cazfynw/floorpan_slabs_scanne=
d.png?rlkey=3Dt4bhpobhwprhtlecbfsz1sy09&st=3D74tmv31g&dl=3D0]


Info from /proc/meminfo plotted versus time.

https://www.dropbox.com/scl/fi/ddd99mrt26hto4fp81ayn/floorpan_meminfo.png?r=
lkey=3D401jpennt2u3343yjp2llaiqj&st=3D09qaagpk&dl=3D0<https://urldefense.co=
m/v3/__https://www.dropbox.com/scl/fi/ddd99mrt26hto4fp81ayn/floorpan_meminf=
o.png?rlkey=3D401jpennt2u3343yjp2llaiqj&st=3D09qaagpk&dl=3D0__;!!ACWV5N9M2R=
V99hQ!Km2c9xVnQ_BpUQ_AOFMN3K5SjxMEuVgpx7NPRzEnGLLeS2Itg3w2y02BJJNx1gZOkbH3C=
M26NI-Jpmt_FqjmRg$>

[https://www.dropbox.com/scl/fi/ddd99mrt26hto4fp81ayn/floorpan_meminfo.png?=
rlkey=3D401jpennt2u3343yjp2llaiqj&st=3Dirguyp12&dl=3D0]


Memory info for the 2 numa nodes versus time.

https://www.dropbox.com/scl/fi/g9auqkhzhhmp11m08hstl/floorpan_nodemem.png?r=
lkey=3Dbzbmjkvb6b1lgrgj4h9xxvbny&st=3Dihhu4c94&dl=3D0<https://urldefense.co=
m/v3/__https://www.dropbox.com/scl/fi/g9auqkhzhhmp11m08hstl/floorpan_nodeme=
m.png?rlkey=3Dbzbmjkvb6b1lgrgj4h9xxvbny&st=3Dihhu4c94&dl=3D0__;!!ACWV5N9M2R=
V99hQ!Km2c9xVnQ_BpUQ_AOFMN3K5SjxMEuVgpx7NPRzEnGLLeS2Itg3w2y02BJJNx1gZOkbH3C=
M26NI-JpmsL2pseug$>

[https://www.dropbox.com/scl/fi/g9auqkhzhhmp11m08hstl/floorpan_nodemem.png?=
rlkey=3Dbzbmjkvb6b1lgrgj4h9xxvbny&st=3Dihhu4c94&dl=3D0]


This is from the original job run back in 2015, internally at Cray Inc.  Th=
is was a 128GB system.

https://www.dropbox.com/scl/fi/5bwyqxjp8gi65c7qvnmcn/floorpan_orig.png?rlke=
y=3Dj629zrdnuwm4lwiqv9wh6mxrt&st=3D4bo6c1jy&dl=3D0<https://urldefense.com/v=
3/__https://www.dropbox.com/scl/fi/5bwyqxjp8gi65c7qvnmcn/floorpan_orig.png?=
rlkey=3Dj629zrdnuwm4lwiqv9wh6mxrt&st=3D4bo6c1jy&dl=3D0__;!!ACWV5N9M2RV99hQ!=
Km2c9xVnQ_BpUQ_AOFMN3K5SjxMEuVgpx7NPRzEnGLLeS2Itg3w2y02BJJNx1gZOkbH3CM26NI-=
Jpms-CIQn1A$>


[https://www.dropbox.com/scl/fi/5bwyqxjp8gi65c7qvnmcn/floorpan_orig.png?rlk=
ey=3Dj629zrdnuwm4lwiqv9wh6mxrt&st=3Dcb2sd1bc&dl=3D0]

The SCR300 file for the original job back in 2015

https://www.dropbox.com/scl/fi/sr969igg0c1hvzn0kaq47/floorpan_orig_SCR300.p=
ng?rlkey=3Dq4rg34s78ytxal4dx4k3b26rd&st=3Do2kzxa2z&dl=3D0<https://urldefens=
e.com/v3/__https://www.dropbox.com/scl/fi/sr969igg0c1hvzn0kaq47/floorpan_or=
ig_SCR300.png?rlkey=3Dq4rg34s78ytxal4dx4k3b26rd&st=3Do2kzxa2z&dl=3D0__;!!AC=
WV5N9M2RV99hQ!Km2c9xVnQ_BpUQ_AOFMN3K5SjxMEuVgpx7NPRzEnGLLeS2Itg3w2y02BJJNx1=
gZOkbH3CM26NI-JpmsuNAOxkQ$>

[https://www.dropbox.com/scl/fi/sr969igg0c1hvzn0kaq47/floorpan_orig_SCR300.=
png?rlkey=3Dq4rg34s78ytxal4dx4k3b26rd&st=3Do2kzxa2z&dl=3D0]

--_000_SN6PR10MB281345CCB9F2F3E94D9FCDA399152SN6PR10MB2813namp_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
<style type=3D"text/css" style=3D"display:none;"> P {margin-top:0;margin-bo=
ttom:0;} </style>
</head>
<body dir=3D"ltr">
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
Accidentally replied to John off-list</div>
<div id=3D"appendonsend"></div>
<hr style=3D"display:inline-block;width:98%" tabindex=3D"-1">
<div id=3D"divRplyFwdMsg" dir=3D"ltr"><font face=3D"Calibri, sans-serif" st=
yle=3D"font-size:11pt" color=3D"#000000"><b>From:</b> Patrick Farrell &lt;p=
atrick.farrell@oracle.com&gt;<br>
<b>Sent:</b> Friday, April 26, 2024 11:15 AM<br>
<b>To:</b> John Bauer &lt;bauerj@iodoctors.com&gt;<br>
<b>Subject:</b> Re: [External] : [lustre-devel] OSC cache page retention is=
sue</font>
<div>&nbsp;</div>
</div>
<style type=3D"text/css" style=3D"display:none">
<!--
p
	{margin-top:0;
	margin-bottom:0}
-->
</style>
<div dir=3D"ltr">
<div class=3D"x_elementToProof" style=3D"font-family:Aptos,Aptos_EmbeddedFo=
nt,Aptos_MSFontService,Calibri,Helvetica,sans-serif; font-size:12pt; color:=
rgb(0,0,0)">
John,</div>
<div class=3D"x_elementToProof" style=3D"font-family:Aptos,Aptos_EmbeddedFo=
nt,Aptos_MSFontService,Calibri,Helvetica,sans-serif; font-size:12pt; color:=
rgb(0,0,0)">
<br>
</div>
<div class=3D"x_elementToProof" style=3D"font-family:Aptos,Aptos_EmbeddedFo=
nt,Aptos_MSFontService,Calibri,Helvetica,sans-serif; font-size:12pt; color:=
rgb(0,0,0)">
Ah, this one...&nbsp; OK, I'm intrigued today.</div>
<div class=3D"x_elementToProof" style=3D"font-family:Aptos,Aptos_EmbeddedFo=
nt,Aptos_MSFontService,Calibri,Helvetica,sans-serif; font-size:12pt; color:=
rgb(0,0,0)">
<br>
</div>
<div class=3D"x_elementToProof" style=3D"font-family:Aptos,Aptos_EmbeddedFo=
nt,Aptos_MSFontService,Calibri,Helvetica,sans-serif; font-size:12pt; color:=
rgb(0,0,0)">
Most likely the issue is that our page cache shrinker doesn't work very wel=
l.&nbsp; It's not something I've dug into in detail before, but that's the =
simple explanation - The kernel expresses memory pressure by calling shrink=
ers registered by kernel modules.&nbsp; Lustre
 has a shrinker at the OSC level which is responsible for freeing pages fro=
m cache when there's memory pressure.</div>
<div class=3D"x_elementToProof" style=3D"font-family:Aptos,Aptos_EmbeddedFo=
nt,Aptos_MSFontService,Calibri,Helvetica,sans-serif; font-size:12pt; color:=
rgb(0,0,0)">
<br>
</div>
<div class=3D"x_elementToProof" style=3D"font-family:Aptos,Aptos_EmbeddedFo=
nt,Aptos_MSFontService,Calibri,Helvetica,sans-serif; font-size:12pt; color:=
rgb(0,0,0)">
The relevant function is osc_cache_shrink_scan (which actually shrinks as w=
ell as scans).&nbsp; Unfortunately it's devoid of any debug so without modi=
fying the code to add debug, you won't be able to get any info out of it.</=
div>
<div class=3D"x_elementToProof" style=3D"font-family:Aptos,Aptos_EmbeddedFo=
nt,Aptos_MSFontService,Calibri,Helvetica,sans-serif; font-size:12pt; color:=
rgb(0,0,0)">
<br>
</div>
<div class=3D"x_elementToProof" style=3D"font-family:Aptos,Aptos_EmbeddedFo=
nt,Aptos_MSFontService,Calibri,Helvetica,sans-serif; font-size:12pt; color:=
rgb(0,0,0)">
I see a few possible issues - the shrinker will not remove more than one RP=
C worth of pages from a given OSC when the shrinker is called.&nbsp; This i=
s a pretty small amount, and it's probably actually smaller - the code comm=
ents note the shrinker only requests
 128 pages at a time and Lustre just tries to free what's asked for.<br>
<br>
</div>
<div class=3D"x_elementToProof" style=3D"font-family:Aptos,Aptos_EmbeddedFo=
nt,Aptos_MSFontService,Calibri,Helvetica,sans-serif; font-size:12pt; color:=
rgb(0,0,0)">
FWIW, the shrinker doesn't appear to have any biasing towards OSCs which ar=
e more full.&nbsp; So when called, it will try to free (probably) 128 pages=
 from the first OSC in the list, then move that OSC to the back of the list=
 and stop.&nbsp; If the kernel still needs
 memory, it will be called repeatedly.<br>
<br>
So the idea at least is that the shrinker will rotate across the OSCs, free=
ing 128 pages each time.&nbsp; It doesn't care how full they are.</div>
<div class=3D"x_elementToProof" style=3D"font-family:Aptos,Aptos_EmbeddedFo=
nt,Aptos_MSFontService,Calibri,Helvetica,sans-serif; font-size:12pt; color:=
rgb(0,0,0)">
<br>
</div>
<div class=3D"x_elementToProof" style=3D"font-family:Aptos,Aptos_EmbeddedFo=
nt,Aptos_MSFontService,Calibri,Helvetica,sans-serif; font-size:12pt; color:=
rgb(0,0,0)">
Here's a possible framework for the problem.&nbsp; I can't quite infer the =
striping and OSCs used by the files from your note - sorry, it's probably t=
here but I'm struggling to figure it out - but...<br>
<br>
</div>
<div class=3D"x_elementToProof" style=3D"font-family:Aptos,Aptos_EmbeddedFo=
nt,Aptos_MSFontService,Calibri,Helvetica,sans-serif; font-size:12pt; color:=
rgb(0,0,0)">
If the file we wish were getting evicted is already in cache is on OSCs 0-3=
, and the new file is on OSCs, say, 0-16, so when we start, the caches for =
OSCs 0-3 are full and those for OSCs 4-16 are
<b>not</b>,&nbsp;our shrinker design <b>would not preferentially drain the =
full ones</b>.&nbsp; It would just start draining and then balance the drai=
n equally across all OSCs, so if the system as a whole is at memory pressur=
e, and the source of the memory pressure is
 using all OSCs, any OSCs which are full <b>will stay full</b>&nbsp;- since=
 they are being refilled.&nbsp; There will be no rebalancing of usage betwe=
en those which are full and those which are not.<br>
<br>
Does this actually line up with your problem?&nbsp; Or are the files on sep=
arate OSCs?</div>
<div class=3D"x_elementToProof" style=3D"font-family:Aptos,Aptos_EmbeddedFo=
nt,Aptos_MSFontService,Calibri,Helvetica,sans-serif; font-size:12pt; color:=
rgb(0,0,0)">
<br>
</div>
<div class=3D"x_elementToProof" style=3D"font-family:Aptos,Aptos_EmbeddedFo=
nt,Aptos_MSFontService,Calibri,Helvetica,sans-serif; font-size:12pt; color:=
rgb(0,0,0)">
Even if this isn't the issue, the problem is very likely something in our s=
hrinker implementation.</div>
<div class=3D"x_elementToProof" style=3D"font-family:Aptos,Aptos_EmbeddedFo=
nt,Aptos_MSFontService,Calibri,Helvetica,sans-serif; font-size:12pt; color:=
rgb(0,0,0)">
<br>
</div>
<div class=3D"x_elementToProof" style=3D"font-family:Aptos,Aptos_EmbeddedFo=
nt,Aptos_MSFontService,Calibri,Helvetica,sans-serif; font-size:12pt; color:=
rgb(0,0,0)">
Regards,</div>
<div class=3D"x_elementToProof" style=3D"font-family:Aptos,Aptos_EmbeddedFo=
nt,Aptos_MSFontService,Calibri,Helvetica,sans-serif; font-size:12pt; color:=
rgb(0,0,0)">
Patrick</div>
<div class=3D"x_elementToProof" style=3D"font-family:Aptos,Aptos_EmbeddedFo=
nt,Aptos_MSFontService,Calibri,Helvetica,sans-serif; font-size:12pt; color:=
rgb(0,0,0)">
<br>
</div>
<div class=3D"x_elementToProof" style=3D"font-family:Aptos,Aptos_EmbeddedFo=
nt,Aptos_MSFontService,Calibri,Helvetica,sans-serif; font-size:12pt; color:=
rgb(0,0,0)">
<br>
</div>
<div id=3D"x_appendonsend"></div>
<hr tabindex=3D"-1" style=3D"display:inline-block; width:98%">
<div id=3D"x_divRplyFwdMsg" dir=3D"ltr"><font face=3D"Calibri, sans-serif" =
color=3D"#000000" style=3D"font-size:11pt"><b>From:</b> lustre-devel &lt;lu=
stre-devel-bounces@lists.lustre.org&gt; on behalf of John Bauer &lt;bauerj@=
iodoctors.com&gt;<br>
<b>Sent:</b> Friday, April 26, 2024 10:26 AM<br>
<b>To:</b> lustre-devel@lists.lustre.org &lt;lustre-devel@lists.lustre.org&=
gt;<br>
<b>Subject:</b> [External] : [lustre-devel] OSC cache page retention issue<=
/font>
<div>&nbsp;</div>
</div>
<div>
<p>&nbsp;My first posting here.&nbsp; I hope it proves to be interesting.<b=
r>
</p>
<p>I have an issue that I had posted to lustre-discuss some time back and A=
ndreas Dilger recommended I post to lustre-devel.&nbsp; I have a job that d=
oes I/O to 3 files on a Lustre file system.&nbsp; The first file, SCRATCH, =
that gets written and read in the first 50
 seconds of the job. then nothing until rtc=3D2950 (rtc is real time clock,=
 in seconds). The second file, SCR300, is written and read thoughout the jo=
b.&nbsp; I attach a couple of images below to indicate the activity.&nbsp; =
In each image, the bottom frame indicates how
 the file is being accessed, reads and writes, over time.&nbsp; The Y axis =
indicates the part of the file being accessed and the X indicates the time =
when the access occured.&nbsp; The top frame in each image is the amount of=
 page cache used by each OSC that the given
 file is striped on ( 4x1M ), versus time.&nbsp; The third file is trivial =
( 26MB in size and 41MB transferred ) and will not be mentioned further.<br=
>
</p>
<p>What is of interest is that the 4 OSC's associated with SCRATCH do not g=
ive up their cache page memory until rtc=3D2918, despite the file not being=
 accessed from rtc=3D50 until rtc=3D2950, especially in light of the intens=
e memory pressure created by the reading
 and writing of the SCR300 file.</p>
<p>Thinking this was virtual memory related, I decided to plot all of the v=
alues in /proc/vmstat versus time while the job was running and see if some=
thing of interest was occurring at rtc=3D2918.&nbsp; It turns out that the =
only thing of interest is the value slabs_scanned
 is constant until rtc=3D2918, then has a spike, as shown in the 3rd image =
below.</p>
<p>For completeness, I have also included a plot of several /proc/meminfo v=
alues versus time ( the 4th image below ).</p>
<p>This was run on a dedicated 64GB node.&nbsp; It can be seen in the memin=
fo plot that Lustre is using, at maximum, 50% of system memory.&nbsp; The 4=
 OSC's of the SCRATCH file are holding on to aggregate 22GB of memory of 32=
GB maximum used by Lustre.&nbsp; The SCR300 file
 is left with 10GB of memory for repeated forward and backward reading of a=
 70GB region of the 104GB file.&nbsp; The SCR300 could really use the 22GB =
being held for SCRATCH.<br>
</p>
<p>Lustre version is 2.14.0_ddn98.</p>
<p>Single process, single host ( 2 NUMA nodes )</p>
<p>For completeness I have included a plot of memory info for each of the 2=
 NUMA nodes.&nbsp; 5th image below.&nbsp; It can clearly be seen that memor=
y on both numa nodes are active.<br>
</p>
<p>I should point out that this is not a new problem, nor unique to the cur=
rent system I am running it on.&nbsp; I had first observed it back in 2015 =
on an internal system at Cray Inc.&nbsp; A plot of the SCRATCH file positio=
n activity is shown in the 6th image below.&nbsp;
 This was the actual MSC.Nastran job running, and there was&nbsp; 13150 sec=
onds of I/O wait out of 18213 second run.&nbsp; In this job, the 4 OSC's fo=
r the SCRATCH file never released their memory, despite the file not being =
accessed for 18000 seconds ( 5 hours ).<br>
</p>
<p>Any light that could be cast upon this subject is welcomed.</p>
<p>John</p>
<p><br>
</p>
<p class=3D"">The SCRATCH file activity and OSC memory usage</p>
<p class=3D""><a class=3D"x_x_moz-txt-link-freetext" href=3D"https://urldef=
ense.com/v3/__https://www.dropbox.com/scl/fi/mg55d6xv6hanmsebn4kvq/floorpan=
_SCRATCH.png?rlkey=3Drjkczx394n9mg54xtos87s0wd&amp;st=3Dzx56loc2&amp;dl=3D0=
__;!!ACWV5N9M2RV99hQ!Km2c9xVnQ_BpUQ_AOFMN3K5SjxMEuVgpx7NPRzEnGLLeS2Itg3w2y0=
2BJJNx1gZOkbH3CM26NI-JpmsRcFSFtg$">https://www.dropbox.com/scl/fi/mg55d6xv6=
hanmsebn4kvq/floorpan_SCRATCH.png?rlkey=3Drjkczx394n9mg54xtos87s0wd&amp;st=
=3Dzx56loc2&amp;dl=3D0</a><br>
</p>
<img alt=3D"https://www.dropbox.com/scl/fi/mg55d6xv6hanmsebn4kvq/floorpan_S=
CRATCH.png?rlkey=3Drjkczx394n9mg54xtos87s0wd&amp;st=3Dyauwg1uo&amp;dl=3D0" =
width=3D"835" height=3D"577" data-outlook-trace=3D"F:2|T:2" src=3D"cid:part=
1.CirZiDN8.WrdBSuIK@iodoctors.com">
<p class=3D"">The SCR300 file activity and OSC memory usage</p>
<p class=3D""><a class=3D"x_x_moz-txt-link-freetext" href=3D"https://urldef=
ense.com/v3/__https://www.dropbox.com/scl/fi/e8s4ku7zb2h6ndcwpsr3g/floorpan=
_SCR300.png?rlkey=3Delxv51uqjxv7pqwj6w3o4tmew&amp;st=3D1yapxmen&amp;dl=3D0_=
_;!!ACWV5N9M2RV99hQ!Km2c9xVnQ_BpUQ_AOFMN3K5SjxMEuVgpx7NPRzEnGLLeS2Itg3w2y02=
BJJNx1gZOkbH3CM26NI-Jpmsmo4TYdw$">https://www.dropbox.com/scl/fi/e8s4ku7zb2=
h6ndcwpsr3g/floorpan_SCR300.png?rlkey=3Delxv51uqjxv7pqwj6w3o4tmew&amp;st=3D=
1yapxmen&amp;dl=3D0</a><br>
</p>
<p><img alt=3D"https://www.dropbox.com/scl/fi/e8s4ku7zb2h6ndcwpsr3g/floorpa=
n_SCR300.png?rlkey=3Delxv51uqjxv7pqwj6w3o4tmew&amp;st=3Dcjwzzohl&amp;dl=3D0=
" width=3D"835" height=3D"577" data-outlook-trace=3D"F:2|T:2" src=3D"cid:pa=
rt2.sFjbsa1k.fMZj1r6C@iodoctors.com"></p>
<p>The slabs_scanned from /proc/vmstat versus time.<br>
</p>
<p><a class=3D"x_x_moz-txt-link-freetext" href=3D"https://urldefense.com/v3=
/__https://www.dropbox.com/scl/fi/qwg2uml7hpi204cazfynw/floorpan_slabs_scan=
ned.png?rlkey=3Dt4bhpobhwprhtlecbfsz1sy09&amp;st=3Dmjepc6uw&amp;dl=3D0__;!!=
ACWV5N9M2RV99hQ!Km2c9xVnQ_BpUQ_AOFMN3K5SjxMEuVgpx7NPRzEnGLLeS2Itg3w2y02BJJN=
x1gZOkbH3CM26NI-Jpmtzuafs1Q$">https://www.dropbox.com/scl/fi/qwg2uml7hpi204=
cazfynw/floorpan_slabs_scanned.png?rlkey=3Dt4bhpobhwprhtlecbfsz1sy09&amp;st=
=3Dmjepc6uw&amp;dl=3D0</a><br>
</p>
<p><img alt=3D"https://www.dropbox.com/scl/fi/qwg2uml7hpi204cazfynw/floorpa=
n_slabs_scanned.png?rlkey=3Dt4bhpobhwprhtlecbfsz1sy09&amp;st=3D74tmv31g&amp=
;dl=3D0" width=3D"835" height=3D"577" data-outlook-trace=3D"F:2|T:2" src=3D=
"cid:part3.18o8qJM4.9WWhdyGO@iodoctors.com"></p>
<p><br>
</p>
<p>Info from /proc/meminfo plotted versus time.<br>
</p>
<p><a class=3D"x_x_moz-txt-link-freetext" href=3D"https://urldefense.com/v3=
/__https://www.dropbox.com/scl/fi/ddd99mrt26hto4fp81ayn/floorpan_meminfo.pn=
g?rlkey=3D401jpennt2u3343yjp2llaiqj&amp;st=3D09qaagpk&amp;dl=3D0__;!!ACWV5N=
9M2RV99hQ!Km2c9xVnQ_BpUQ_AOFMN3K5SjxMEuVgpx7NPRzEnGLLeS2Itg3w2y02BJJNx1gZOk=
bH3CM26NI-Jpmt_FqjmRg$">https://www.dropbox.com/scl/fi/ddd99mrt26hto4fp81ay=
n/floorpan_meminfo.png?rlkey=3D401jpennt2u3343yjp2llaiqj&amp;st=3D09qaagpk&=
amp;dl=3D0</a><br>
</p>
<p><img alt=3D"https://www.dropbox.com/scl/fi/ddd99mrt26hto4fp81ayn/floorpa=
n_meminfo.png?rlkey=3D401jpennt2u3343yjp2llaiqj&amp;st=3Dirguyp12&amp;dl=3D=
0" width=3D"835" height=3D"577" data-outlook-trace=3D"F:2|T:2" src=3D"cid:p=
art4.V4uqDP91.8TiLBxS9@iodoctors.com"></p>
<p><br>
</p>
<p>Memory info for the 2 numa nodes versus time.<br>
</p>
<p><a class=3D"x_x_moz-txt-link-freetext" href=3D"https://urldefense.com/v3=
/__https://www.dropbox.com/scl/fi/g9auqkhzhhmp11m08hstl/floorpan_nodemem.pn=
g?rlkey=3Dbzbmjkvb6b1lgrgj4h9xxvbny&amp;st=3Dihhu4c94&amp;dl=3D0__;!!ACWV5N=
9M2RV99hQ!Km2c9xVnQ_BpUQ_AOFMN3K5SjxMEuVgpx7NPRzEnGLLeS2Itg3w2y02BJJNx1gZOk=
bH3CM26NI-JpmsL2pseug$">https://www.dropbox.com/scl/fi/g9auqkhzhhmp11m08hst=
l/floorpan_nodemem.png?rlkey=3Dbzbmjkvb6b1lgrgj4h9xxvbny&amp;st=3Dihhu4c94&=
amp;dl=3D0</a></p>
<img alt=3D"https://www.dropbox.com/scl/fi/g9auqkhzhhmp11m08hstl/floorpan_n=
odemem.png?rlkey=3Dbzbmjkvb6b1lgrgj4h9xxvbny&amp;st=3Dihhu4c94&amp;dl=3D0" =
width=3D"734" height=3D"553" data-outlook-trace=3D"F:2|T:2" src=3D"cid:part=
5.xq4jzCzP.Pljh85Qa@iodoctors.com">
<p><br>
</p>
<p>This is from the original job run back in 2015, internally at Cray Inc.&=
nbsp; This was a 128GB system.<br>
</p>
<p><a class=3D"x_x_moz-txt-link-freetext" href=3D"https://urldefense.com/v3=
/__https://www.dropbox.com/scl/fi/5bwyqxjp8gi65c7qvnmcn/floorpan_orig.png?r=
lkey=3Dj629zrdnuwm4lwiqv9wh6mxrt&amp;st=3D4bo6c1jy&amp;dl=3D0__;!!ACWV5N9M2=
RV99hQ!Km2c9xVnQ_BpUQ_AOFMN3K5SjxMEuVgpx7NPRzEnGLLeS2Itg3w2y02BJJNx1gZOkbH3=
CM26NI-Jpms-CIQn1A$">https://www.dropbox.com/scl/fi/5bwyqxjp8gi65c7qvnmcn/f=
loorpan_orig.png?rlkey=3Dj629zrdnuwm4lwiqv9wh6mxrt&amp;st=3D4bo6c1jy&amp;dl=
=3D0</a><br>
</p>
<p><br>
</p>
<p><img alt=3D"https://www.dropbox.com/scl/fi/5bwyqxjp8gi65c7qvnmcn/floorpa=
n_orig.png?rlkey=3Dj629zrdnuwm4lwiqv9wh6mxrt&amp;st=3Dcb2sd1bc&amp;dl=3D0" =
width=3D"823" height=3D"598" data-outlook-trace=3D"F:2|T:2" src=3D"cid:part=
6.0Ipctt0h.sUPojb5x@iodoctors.com"><br>
</p>
<p>The SCR300 file for the original job back in 2015<br>
</p>
<p><a class=3D"x_x_moz-txt-link-freetext" href=3D"https://urldefense.com/v3=
/__https://www.dropbox.com/scl/fi/sr969igg0c1hvzn0kaq47/floorpan_orig_SCR30=
0.png?rlkey=3Dq4rg34s78ytxal4dx4k3b26rd&amp;st=3Do2kzxa2z&amp;dl=3D0__;!!AC=
WV5N9M2RV99hQ!Km2c9xVnQ_BpUQ_AOFMN3K5SjxMEuVgpx7NPRzEnGLLeS2Itg3w2y02BJJNx1=
gZOkbH3CM26NI-JpmsuNAOxkQ$">https://www.dropbox.com/scl/fi/sr969igg0c1hvzn0=
kaq47/floorpan_orig_SCR300.png?rlkey=3Dq4rg34s78ytxal4dx4k3b26rd&amp;st=3Do=
2kzxa2z&amp;dl=3D0</a></p>
<img alt=3D"https://www.dropbox.com/scl/fi/sr969igg0c1hvzn0kaq47/floorpan_o=
rig_SCR300.png?rlkey=3Dq4rg34s78ytxal4dx4k3b26rd&amp;st=3Do2kzxa2z&amp;dl=
=3D0" width=3D"826" height=3D"613" data-outlook-trace=3D"F:2|T:2" src=3D"ci=
d:part7.0OHwAi9q.aC028Ps6@iodoctors.com"><br>
<p></p>
</div>
</div>
</body>
</html>

--_000_SN6PR10MB281345CCB9F2F3E94D9FCDA399152SN6PR10MB2813namp_--

--_010_SN6PR10MB281345CCB9F2F3E94D9FCDA399152SN6PR10MB2813namp_
Content-Type: image/png; name="floorpan_SCRATCH.png"
Content-Description: floorpan_SCRATCH.png
Content-Disposition: inline; filename="floorpan_SCRATCH.png"; size=10874;
	creation-date="Fri, 26 Apr 2024 15:27:15 GMT";
	modification-date="Sat, 27 Apr 2024 01:16:34 GMT"
Content-ID: <part1.CirZiDN8.WrdBSuIK@iodoctors.com>
Content-Transfer-Encoding: base64

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

--_010_SN6PR10MB281345CCB9F2F3E94D9FCDA399152SN6PR10MB2813namp_
Content-Type: image/png; name="floorpan_SCR300.png"
Content-Description: floorpan_SCR300.png
Content-Disposition: inline; filename="floorpan_SCR300.png"; size=19578;
	creation-date="Fri, 26 Apr 2024 15:27:15 GMT";
	modification-date="Sat, 27 Apr 2024 01:16:34 GMT"
Content-ID: <part2.sFjbsa1k.fMZj1r6C@iodoctors.com>
Content-Transfer-Encoding: base64

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
Ukqpe9T/BSD3xcjr3t55AAAAAElFTkSuQmCC

--_010_SN6PR10MB281345CCB9F2F3E94D9FCDA399152SN6PR10MB2813namp_
Content-Type: image/png; name="floorpan_slabs_scanned.png"
Content-Description: floorpan_slabs_scanned.png
Content-Disposition: inline; filename="floorpan_slabs_scanned.png"; size=6968;
	creation-date="Fri, 26 Apr 2024 15:27:15 GMT";
	modification-date="Sat, 27 Apr 2024 01:16:34 GMT"
Content-ID: <part3.18o8qJM4.9WWhdyGO@iodoctors.com>
Content-Transfer-Encoding: base64

iVBORw0KGgoAAAANSUhEUgAAA0MAAAJBCAIAAAALHfkHAAAa/0lEQVR42u3daXLbSLqGUS+dy/Ny
egesiIqKDkoEMr8cAORwTrw/btuwTKFk6bkcwD/v9//MzMzMbMb9cQrMzMzMlJyZmZmZKTkzMzMz
U3JmZmZmSs7MzMzMlJyZmZmZKTmz1f41/uv+P2uD/EfsfjO+FR1c/cd9GZgpOTMRoOSUXP+SO7x5
1SVXkX1mpuTMRICSU3KVNyN48yKHRQrP14OZkjMTAUpOyfW8GfFKi2Rc+hhfD2ZKzkwEKDklN2jJ
+c9tpuTMtvsZn31Mqu7p5J+/deez1OMfJ3vYFZ9p6WkpOvLwsIqTeUU2XVpyHjw1U3JmMu7gZ+HZ
r3R/7nmvp6h3/Otu/kzjNVl6ZMuZ7Hjv1w0l5x+1mZIz2y7j0k8kOuyb4M/RbCGV3pi+n1TksO6f
afXBjb84csl1ecWDkjNTcmaeO9X0AzLYFocH9/ox3P2T6v6Z1h0cuRnZO+r6hlfHu0uVnJmSM7Nx
Sy5y/J0l1/53tfRWlzgrPYHVn3L8qZONJdf+H1fJmSk5M691qLljpug5dsEn/l/6WofSj9/4mbaX
XOSurIlKrvoePiVnpuTMrDh9il4HUF1yd/Zc6Z1AO5dc4iZ1vMdUyZkpOTPrnHQVP8jbSy57Y7p8
UkXd0P3ZbB0fXb2ncjo+o9FVSMyUnJnd/fy5+A/yjiV36Ssh2u8BUnIDlpy75cyUnJnVl1z8uhgX
vd6ie45UfKY3Z1/LDa47e91f81t0I71bl5mSM7PMj7S6R1cjV9bN/i1dEqTok0pfT67iM7qu5M4+
r3hMD15yve5yi1yQ2b99MyVntuZrHdrf4+GKI6/4pN7N7/FwW8m9L3urifbnUA5YctedBDNTcmZz
xFxFW0SSpe6dpi76pM6OrH7NxKUlF7+1737vu3rFHVqNrVZ0AzScmZIzMzMzMyVnZmZmpuTMzMzM
TMmZmZmZmZIzs3u+KYTft8puPpP+05iZkjMzuaDkzEzJmZmZmZmSMzMzMzMlZ2ZmZqbkzMzMzEzJ
mZmZmZmSMzMzMzMlZ2ZmZqbkzMzMzEzJmZmZmZmSMzMzM1NyZmZmZqbkzMzMzEzJmZmZmZmSMzMz
M1NyZmZmZrZByb1+yh4QOSb9xw8/SMtf0esAMzMzs5lKLttYr3PBDxIpuREOMDMzM5uv5A5z5+yA
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
p+QAUHIoueGuDBy5TEnFo6uuQgKAkkPJ3Xdl4OxFfQe8rq8rAwOg5JSckgs10JjvteXdugBQckpu
9+vJmX9aAEoOJafklBwASg4lZ0oOACWn5JScKTkAlJySU3JKDgAlh5JTckoOACWn5JScKTkAlJyS
U3IGgJJDySk5JQeAkkPJmZIDQMkpOSVnSg4AJafklJySA0DJoeSUnJIDQMkpOSVnSg4AJafklJyS
A0DJoeSUnJIDQMmh5EzJAaDklJySMyUHgJJTckpOyQGg5FBySk7JAaDklJySMyUHgJJTckpOyQGg
5FBySk7JAaDkUHKm5ABQckpOyZmSA0DJKTklp+QAUHIoOSWn5ABQckpOyZmSA0DJKTklp+QAUHIo
OSWn5ABQcig5U3IAKDklp+RMyQGg5JScklNyACg5lJySU3IAKDklp+RMyQGg5JScklNyACg5lJyS
U3IAKDmUnCk5AJScklNypuQAUHJKTskpOQCUHEpOySk5AJScklNypuQAUHJKTskpOQCUHEpOySk5
AJQcSs6UHABKTskpOVNyACg5JafklBwASg4lp+SUHABKTskpOVNyACg5JafklBwASg4lp+SUHABK
DiVnSg4AJafklJwpOQCUnJJTckoOACWHklNySg4AJafklJwpOQCUnJJTckoOACWHklNySg4AJYeS
MyUHgJJTckrOlBwASk7JKTklB4CSQ8kpOSUHgJJTckrOlBwASk7JLV9yr5+yB/w65nUufUDjzbji
ACUHoORQcjOVXLaxqkOtqORGOEDJASg5lNx8JXeYO2cHfB6WrcPIwYfHnHXYpQcoOQAlh5Kb/nly
FeFVmmWRj5Ztwb4HKDkAJYeSW7bkwo9LnpZc9nFPJQeAklNySq7P0+aqSy7+TLtxSu7otgGg5FBy
U5Vc5P627GGHJVfxRDr3yQGg5JSckuuccekGqvsISg4AJafklNxNGafkAFByKLnhrgwcuUxJ9rl0
dR/BVUgAUHJKTsn1uTJw9pWnRXfIuTIwAEoOJfdMyQVfuBp5GcTjb8bl3boAUHJKbvHryZl/WgBK
DiWn5JQcAEoOJWdKDgAlp+SUnCk5AJScklNySg4AJYeSU3JKDgAlp+SUnCk5AJScklNyBoCSQ8kp
OSUHgJJDyZmSA0DJKTklZ0oOACWn5JSckgNAyaHklJySA0DJKTklZ0oOACWn5JSckgNAyaHklJyS
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
C61R+Xt+P/FuXaUnZOefOErOzMzMbNYpOTMzMzMlZ2ZmZmZKzszMzMyUnJmZmZmSMzMzMzMlZ2Zm
ZmZKzszMzEzJOQtmZmZmSs7MzMzMlJyZmZmZKTkzMzMzJWdmZmZmSs7MzMzMlJyZmZmZkjMzMzMz
JWdmZmZmSs7MzMzMlJyZmZmZkjMzMzMzJWdmZmZmSs7MzMxMyZmZmZmZkjMzMzMzJWdmZmZmSs7M
zMxMyZmZmZmZkjMzMzMzJWdmZmam5MzMzMxMyZmZmZmZkjMzMzMzJWdmZmam5MzMqvf6kP7d7AF9
b0D8I78K9brlZmZKzsyUnJIzMyVnZnZBzKVLrksMKTkzU3JmZvuWXN09hUrOzJScma1ccp+/2D22
Hi85MzMlZ2ZKLnRnXiKqRrtPLv44bMvjv77qzJScmdm1MZcuubM0CT5NbYqSO7v9dZ2q58yUnJnZ
iCVXWkJTl1zdpybmzJScmdl9JZcOu3QJZe+amqjkin79hkg1MyVnZnZhyfV6ZcM4z5O74vaLOTMl
Z2Z2ScllH059F14xOP2Q4g4l5wFWMyVnZnbr3XLxkmt8cpiS87VnpuTMzDrfLRd/UWpFvig5JWem
5MzMLi+50mM6Pv1/7efJmZmSMzObpuQ2vE8u+KIHX3hmSs7M7KqYaz9g20dX364nZ6bkzMzmKjmv
eCg9G77qzJScmdklJdf3mD1LLv7ItZkpOTMzMzNTcmZmZmam5MzMzMyUnJmZmZnNsX8AZ3I5MRkN
wNMAAAAASUVORK5CYII=

--_010_SN6PR10MB281345CCB9F2F3E94D9FCDA399152SN6PR10MB2813namp_
Content-Type: image/png; name="floorpan_meminfo.png"
Content-Description: floorpan_meminfo.png
Content-Disposition: inline; filename="floorpan_meminfo.png"; size=12388;
	creation-date="Fri, 26 Apr 2024 15:27:15 GMT";
	modification-date="Sat, 27 Apr 2024 01:16:34 GMT"
Content-ID: <part4.V4uqDP91.8TiLBxS9@iodoctors.com>
Content-Transfer-Encoding: base64

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
OZIjOZKTJInkSI7kSE6SRHIkR3KG5CRJJ5ScbQrJGZKTJJEcyZGcITlJEsmRHMmRnCRJJEdyJEdy
kiSSIzmSMyQnSSI5kiM5kvOokySRHMmRHMlJkkjOYiA5Q3KSJJIjOZIzJCdJIjmSIzmSkySJ5EiO
5EhOkkRyJEdyhuQkSSRHciRHch5mkiSSIzmSIzlJEsmJ5AzJSZJIjuRIzpCcJInkSI7kSE6SJJIj
OZIjOUkSyZEcyRmSkySRHMmRHMlJkkRyJEdyF5WcB54kieRIjuRITpJEciI5Q3KSJJIjOZIzJCdJ
IjmSIzmSkySJ5EiO5EhOkkRyJEdyZork3g5EIkkiOZIjOZKTJJGcSM6QnCSJ5EiO5E4xP5nGLy3y
60hOkrS35GxWSI7k+pTW8otITpJEciRHcjF+TTn/338qSy72q0lOkkRyJEdyO0qufJ74iSQnSdpK
ct4tR3JPeHWV5CRJJEdyJHfD98ltJLnUFSA5SRLJkRzJ1dSVs11Ve8H3w9knJ0kiOZIjucPePEdy
kiSSIzmSu8PHILxPTpJ0ScZ9Yk4k96hXV6dIzlFIJEkkR3Ikd95PPFQvypGBJUkkR3IktznmRl54
LV+ab+uSJJEcyZHc7YfkJEmzJfd+kxzJGZKTJJEcyZGcITlJEsmRHMmRnCRJJEdyJEdykiSSIzmS
MyQnSSI5kiM5kvOQkySRHMmRHMlJkkiO5EjOkJwkieRIjuQMyUmSSI7kSI7kJEkiOZIjuXNKzqNO
kkRyJEdyl5Sc3XKSJJIjOZIjOUkSydmmkJwhOUkSyZEcyRmSkySRHMmRHMlJkkRyJEdyJCdJIjmS
IzlDcpIkkiM5kiM5jzpJEsmRHMmRnCSJ5GxTSM6QnCSJ5EiO5AzJSZJIjuRIjuQkSSI5kiM5kpMk
kRzJkZwhOUkSyZEcyZGcR50kaZLkbFZIzpCcJInkSI7kDMlJkkiO5EiO5CRJIjmSIzmSkyTdVnI2
KyRnSE6SRHIkR3KG5CRJJEdyJEdykiSRHMmRHMlJkkiO5EjOkJwkieRIjuRIzkNOkkRyJEdyJCdJ
IjmbFZIzJCdJIjmSIzlDcpIkkiO5oyT38/NDXSQnSSI5kruq5P6GXyQnSSI5kruq5HiO5CRJJEdy
15Yc0pGcJInkSO4yn3j4KcZkJCdJIjmSO/tnV39qwRnJSZJIjuROfRQSniM5SRLJkdy1jycHcyQn
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
GZKTJN1AcrYpJGdITpJEciRHcobkJEkkR3IkR3KSJJEcyZEcyUmSSI7kSM6QnCSJ5EiO5EjOo06S
RHIkR3IkJ0kiOdsUkjMkJ0kiOZIjOUNykiSSIzmSIzlJkkiO5EiO5CRJJEdyJGemSM6jTpJEciRH
cheWnEeaJInkSI7kSE6SRHI2KyRnSE6SRHIkR3KG5CRJJEdyJEdykiSRHMmRHMlJkkiO5EjOkJwk
ieRIjuRITpIkkiM5kiM5SRLJieQMyUmSSI7kSM6QnCSJ5EiO5EhOkqS85P4wzmaF5AzJSZJIjuRI
zpCcJInkSI7kSE6SJJIjOZIjOUkSyZEcyRmSkySdCXMkR3KG5CRJJEdyJGdITpJEciRHciQnSVJQ
cjYrJGdITpJEciRHcobkJEkkR3IkR3KSJAUlJ5IzJCdJIjmSIzlDcpIkkiM5kiM5SZJIjuRIjuQk
SSRHciRnSE6SRHIkR3Ik55EmSSI5kiM5kpMkkZxIzpCcJInkSI7kDMlJkkiO5EiO5CRJIjmSIzmS
kySRHMmRnCE5SRLJkRzJPVdyHnWSJJIjOZIjOUkSydmmkJwhOUkSyZEcyZ1qfj7a9HJ+fkdykiSS
IzmSm8a4EclVL+cnFclJkkiO5EhuVHKf/xE5c8flfJ1OcpIkkiM5kptPui3OEz+R5CRJJEdyJEdy
kiSRHMmR3PaSS71/juQkSSRHciQ3LLmfYvbJSZJIjuRIjuRITpJEciRHct4nJ0kSyZEcyc09j6OQ
SJJIjuRIbtsjA0e+pKHvchwZWJJEciRHcleVnG/rkiQdKDkLgeTMbuOBJ0kiOZIjOZKTJMkGheQM
yUmSSI7kSM6QnCSJ5EiO5EhOkiSSIzmSO6fkfGJckkRyJEdyJCdJIjkbFJIzO0ruD+M88CRJJEdy
JEdykiSSE8kZkpMkkRzJkZyJSM5jTJJEciRHciQnSSI5kZwhOUkSyZEcyRmSkySRHMmRHMlJkkRy
JEdyJCdJIjmSIzlDcpIkkiM5kiM5SZJIjuRIjuQkSSQnkjMkJ0kiOZIjOUNykiSSIzmSu6nkPMAk
SSRHciRHcpIkkrNZITlDcpIkkiM5kjMkJ0kiOZIjubsudx93kCSRHMmRHMlJkkRyJGd2lpxHlyRJ
JEdyJCdJkkjOkJwkSSRHcobkJEkiOZIjOUmSRHIkR3KSJJEcyRmSkySJ5EiO5CRJEsmRHMlJkiSS
MyQnSRLJkZypjiRJIjmSIzlJkkRyhuQkSSI5kjMkJ0kSyZEcyUmSJJIjOZKTJInkSM6QnCRJJEdy
JCdJkkiO5EhOkiSRnCE5SZJIjuQMyUmSRHIkR3KSJInkSI7kJEkiOZIzJCdJEsmRHMlJkiSSI7mt
5ud3U39EkiSRHMntxbgI5lp+RJIkkRzJbSy53P8d/hFJkkRyJLcL4yKYa/yR/+31+nckqSlPHfpc
GURyZlfJfRquMLQnqcA4Twv6lNx6CyKSI7lZkvt+89zXwywIO2OMyf2lZ0xuPSE5kiO56fvk/pEk
SbtEciQ3X3LBY5o8Z2lbCBaIBWJpWCAWiAVCciTnYWaBWCCWhgVigVgOJGdqhxSJuK0gP480S8MC
sUAsDQvEArFASO6wIwMXJBc5MrBHmqVhgVggloYFYoFYICS3K+aCL5u2fsGXMcYYYwzJGWOMMcaQ
nNlyZ97EH7nca9PV16NvtlgiL7IP3vxrLZ/4mnD7FSb4HoznrB5N9/sTnk8ib9R58hqSfJXssVsc
ktv7DXazfuQGkhs/w6U1/7TlM76pvs0C6djk3Hv16LstT1sgyfdqWyC2OCS34TpXfUfd4I9cayH0
3epLL5avr/fY4uZfa/mUF8ijVpjc9uOxq0d1gTzt+aTjGeNRa8j6Cj98i0Nyewhm5he23kVy1Vt9
m8USvyFNN/+6y6fvmt97hWk9yNHtHz6t29QnPJ/MXQGesECes4aQHMkd+XIJyZGcFYbkggvkaatH
32GwnrxAHvsEQnIkd8z75EiO5KwwTS8mPkdywe307VcPkhuU3HO2OCRHcju9rSH5BlWSI7mHrzAb
7T+4k2s9n2xxe++3QJ68hpAcyV31fR4kdyfJPXOFKX9w9YGrR8eRm7wtzAKxhpAcyZEcyZHcudTy
8NfOPJ+QHMmR3KnfvBxZXe5xFJLWNwPd7Cgk1av9tKOQDL66+r7dURWa/sB7yEFq4l9UffvVY4fb
e6cF8vAtDsnt/bHNvg/u3e8TD++HHRn44Qf2rC4QRwaefmNvcNzXxz6fWEOsISR3utUuvofmNt/W
9d7r22buZNl7L5+O5+K7LpDdvlnoHsp/5vOJb+tqXSBP3uKQnDHGGGPMVYfkjDHGGGNIzhhjjDHG
kJwxxhhjjCE5Y4wxxhiSM8YYY4wxJGeMMcYYY0jOGGOMMYbkLAVjjDHGGJIzxhhjjDEkZ4wxxhhj
SM4YY4wxhuSMMcYYYwzJGWOMMcYYkjPGGGOMITljjDHGGENyxhhjjDGG5IwxxhhjDMkZY4wxxpCc
McYYY4whOWOMMcYYQ3LGGGOMMSRnjDHGGGNIzhhjjDHGkJwxxhhjjCE5Y4wxxhiSM8YYY4wxJGeM
McYYY0jOGGOMMYbkjDHGGGMMyRljjDHGGJIzxhhjjDEkZ4wxxhhDcsYY0z0/H5X/tXqGuVcgfsk/
jc265sYYQ3LGGJIjOWMMyRljzAaYK0tuCoZIzhhDcsYY81zJ9e0pJDljDMkZY+4suc8Tp2PrcMkZ
YwzJGWNILrQzr4Cqs+2Ti78OO/L6r7XOGJIzxphtMVeWXI4mwbepXUJyuevf51SeM4bkjDHmjJJr
ldClJdd302DOGJIzxpj9JFeGXVlC1V1TF5Jc0+k7INUYQ3LGGLOh5GZ9suE875Pb4vrDnDEkZ4wx
m0iu+nLqu/GIweWXFJ8gOS+wGkNyxhiz6265uOQG3xxGctY9Y0jOGGMm75aLfyi1gy8kR3LGkJwx
xmwuudbzTHz7/73fJ2eMITljjLmM5B64Ty74oQcrnjEkZ4wxW2Fu/AyPfXX17XhyxpCcMcZcS3I+
8dC6NKx1xpCcMcZsIrm553mm5OKvXBtjSM4YY4wxxpCcMcYYY4whOWOMMcYYkjPGGGOMMdeY/wIP
6HD3zb7IOwAAAABJRU5ErkJggg==

--_010_SN6PR10MB281345CCB9F2F3E94D9FCDA399152SN6PR10MB2813namp_
Content-Type: image/png; name="floorpan_nodemem.png"
Content-Description: floorpan_nodemem.png
Content-Disposition: inline; filename="floorpan_nodemem.png"; size=21109;
	creation-date="Fri, 26 Apr 2024 15:27:15 GMT";
	modification-date="Sat, 27 Apr 2024 01:16:34 GMT"
Content-ID: <part5.xq4jzCzP.Pljh85Qa@iodoctors.com>
Content-Transfer-Encoding: base64

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
1Ps4H2L71AAAAABJRU5ErkJggg==

--_010_SN6PR10MB281345CCB9F2F3E94D9FCDA399152SN6PR10MB2813namp_
Content-Type: image/png; name="floorpan_orig.png"
Content-Description: floorpan_orig.png
Content-Disposition: inline; filename="floorpan_orig.png"; size=10698;
	creation-date="Fri, 26 Apr 2024 15:27:15 GMT";
	modification-date="Sat, 27 Apr 2024 01:16:34 GMT"
Content-ID: <part6.0Ipctt0h.sUPojb5x@iodoctors.com>
Content-Transfer-Encoding: base64

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
judngdIt157MKnG83dIKYzYvrGp704KBqtqec8xv1PgVKnlOLPX5Q2KW/RYizVvzl/vUE+bWLf+o
asvSTha1wnyckyXy61brLKWUd52Wn9Cw4475XRpfuAAs8lnGLe2zzII/BUtb87Df94S5e8s/Vohi
aSIiIiIrh6WJiIiIsDQRERERYWkiIiIiLE1EREREWJqIiIgISxMRERERliYiIiIiLE1ERESEpYmI
iIgISxMRERFhaSIiIiLC0kRERERYmoiIiIiwNBERERFhaSIiIiIsTURERERYmoiIiAhLExERERGW
JiIiIsLSRERERISliYiIiAhLExEREWFpIiIiIsLSRERERFiaiIiIiLA0EREREZYmIiIiIixNRERE
RFiaiIiICEsTEREREZYmIiIiwtJEREREhKWJyO3y9Y32s90N5jYgvuevJLNaLiLC0kSEpbE0EWFp
IkLUwpY2RXRYmoiwNBGRZ1parYePpYkISxORu1ra9weni9TlliYiwtJE5I2W1rjVuHhfWvze6Mg9
WWedCEsTEalrTdvS9rQjOCzsFpa21/6ag3I1EZYmInK2pWUt59aWVvtoRE2EpYmIzLG0trS1Lafb
pXQjS0s9foKAighLExGWVrS0WbME1hmXdkT7iZoISxMRSWtN9xbnJ1nttn2b7w2W5qanCEsTEZnW
nRa3tMHBWCzNuSfC0kREEt1p8cmbBTVhaSxNhKWJiAxZWnabiUPpnz0uTURYmojIEpb2wr604AQC
J54ISxMRqYja+AavveP5US9NhKWJiKxjaWYPZI+Gs06EpYmIpC1t7jbvtLT43WQRYWkiIiIiwtJE
REREWJqIiIiIsDQRERER+X/5H4NEShU4FouSAAAAAElFTkSuQmCC

--_010_SN6PR10MB281345CCB9F2F3E94D9FCDA399152SN6PR10MB2813namp_
Content-Type: image/png; name="floorpan_orig_SCR300.png"
Content-Description: floorpan_orig_SCR300.png
Content-Disposition: inline; filename="floorpan_orig_SCR300.png"; size=18151;
	creation-date="Fri, 26 Apr 2024 15:27:15 GMT";
	modification-date="Sat, 27 Apr 2024 01:16:34 GMT"
Content-ID: <part7.0OHwAi9q.aC028Ps6@iodoctors.com>
Content-Transfer-Encoding: base64

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
Pbi2bzfPdl2Dhct7dzkZuuPKH8y1fbt5Mn94y1xLvv8fsPLz92dcw7UNuFa+E2eXi6iO6eZx7Rqu
tR400n54Kxey9bVre3Fti7199wvvcA3Xplptl26eb937uIZrx3Mt/4e3dUSJPB9eXJu/8mv3Z1wj
tv4O/7VWS35r9O0R/9pnOIzbCzUSbvbtVn67gTxaL//K+eHt41r+zZ58/+87GXolGIVk7f5sII+3
c63jus6Fw+TuO/CgYXLnbPa9Vj7DuKADBw79SzO7jNfa2hKn3ezXVsPkHrO3H3DYxLX9xNZx885k
Tf7Zah6n1u/xeVZ+worFbfaNVr6jGUjycp5z7UozoVAH13Ju9uT7/6l7+xmHTVwTEREReUtwTURE
RATXRERERATXRERERHBNRERERHBNRERERHBNREREBNdEREREBNdEREREcE1EREREcE1EREREcE1E
REQE10REREQE10RERERwTURERERwTURERERwTURERATXRERERATXRERERHBNRERERHBNRERERHBN
REREBNdEREREBNdEREREcM0mEBEREcE1EREREcE1EREREVwTEREREVwTEREREVwTERERwTURERER
wTURERERXBMRERERXBORI/PnR5V/e/uAsStQv+Q/jTVqzUVEcE1EcA3XRATXRESKcClzbYh4cE1E
cE1E5HCu9fX54ZqI4JqIbM+1nz8cLqrlXBMRwTUReTXXCmchk/eu1Z82fXK61l4ngmsiIgN8U+ba
N39UXjq2Bde+rX8fRqFNBNdERJZxrZU7W3Ot76URmwiuiYgM5lpZb2Xu3HYybcS1pp9PkKiI4JqI
4NpTro26pSDPtWsR609sIrgmItLvm9uzn1fj8LnlM4Bv4JrzoSK4JiIyvoOtnmsPL9jCNfueCK6J
iPR0sNXf8tlhFFzDNRFcExEZw7XWxwy87v7sa9dEBNdERHJx7YW9a5V3G9jxRHBNROSR2J4/4LUn
Qy/jrongmohIQq651aB1a9jrRHBNRKSfa2Mf806u1Z9oFhFcExERERFcExEREcE1EREREcE1ERER
EWnI/wHWADQTpqXryQAAAABJRU5ErkJggg==

--_010_SN6PR10MB281345CCB9F2F3E94D9FCDA399152SN6PR10MB2813namp_--

--===============3139964631343228796==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============3139964631343228796==--
