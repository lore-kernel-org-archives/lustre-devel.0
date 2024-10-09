Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id CBA01CEE32D
	for <lustre-devel@archiver.kernel.org>; Wed,  9 Oct 2024 16:57:28 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4XNzZh5g7Fz1xGG;
	Wed,  9 Oct 2024 09:57:16 -0700 (PDT)
Received: from mx0b-00069f02.pphosted.com (mx0b-00069f02.pphosted.com
 [205.220.177.32])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4XNzZf3Ht6z1wSG
 for <lustre-devel@lists.lustre.org>; Wed,  9 Oct 2024 09:57:14 -0700 (PDT)
Received: from pps.filterd (m0246631.ppops.net [127.0.0.1])
 by mx0b-00069f02.pphosted.com (8.18.1.2/8.18.1.2) with ESMTP id 499GBZvr013494;
 Wed, 9 Oct 2024 16:57:12 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=
 content-type:date:from:in-reply-to:message-id:mime-version
 :references:subject:to; s=corp-2023-11-20; bh=3NKwCNaNh+rQf6cSDA
 gtuUMCxdAkAkIckpxZu5BV5fw=; b=Wgbb7A9rMS8S3eBgvfYTz4mX5vP6ncs+J6
 88CtvlRCP7qC9NZ0nVJYtt+7n9NHU0XRd0ZDQi3i7EHERmItc4KcExWzs3gL6Amn
 0LskBzZPtpKo082Ovz9Ja3Fqr9HICMbI1r8ofyehyytTE+3RoBixXmF0EOViiCIO
 rGdyocBV+ahFGnoqlyj0FcGEPGqRlKjTRR0buGAZhGn1z/rpbg2B0fYwwOq7CutY
 9RacchynSLmgpqigTavXqTBQpBi/UsWEIUL3/f5e4zugg1lPndP0D5g4aMTY8y8r
 hYfp9wUBmEEBsrzvgaBnMXE7l4iilXbN1kuadAUdI+VfvHM/MG0A==
Received: from phxpaimrmta03.imrmtpd1.prodappphxaev1.oraclevcn.com
 (phxpaimrmta03.appoci.oracle.com [138.1.37.129])
 by mx0b-00069f02.pphosted.com (PPS) with ESMTPS id 42300e0wc3-1
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
 Wed, 09 Oct 2024 16:57:12 +0000 (GMT)
Received: from pps.filterd
 (phxpaimrmta03.imrmtpd1.prodappphxaev1.oraclevcn.com [127.0.0.1])
 by phxpaimrmta03.imrmtpd1.prodappphxaev1.oraclevcn.com (8.18.1.2/8.18.1.2)
 with ESMTP id 499Gtxlu022957; Wed, 9 Oct 2024 16:57:11 GMT
Received: from nam10-dm6-obe.outbound.protection.outlook.com
 (mail-dm6nam10lp2101.outbound.protection.outlook.com [104.47.58.101])
 by phxpaimrmta03.imrmtpd1.prodappphxaev1.oraclevcn.com (PPS) with ESMTPS id
 422uw8vhjd-1
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
 Wed, 09 Oct 2024 16:57:11 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=S7AatgvHcMropztv4yOMEdRlzx2Yix8FbQQ1fJowZX6Z2uuo9NIftnzfht62DcPx/1R/WnbRADp9b9Vyw7ovlpPRu1KT3y5OAASrXi1hG4kpmmlESUs7QYNrNVlZgzRi1Su1SuzIErbm//ahSTJagbXzOSJ87DkysHDZ44dUWT2HakBSJx+EwP8A6RSkeBirINnyc+C7ZFK20ztwc1rvZmDneFthNxiXn7AZMZyW21bHQU2bT3x8xz26VK9bca8i8FxNx0gYwaWq+jR7Jpp1QyuYIrhjlnKV0JEoKMSZyteNCZ5rWb5g/r4pKVPHYFQvO7LEVO0qbBbn/PGM+P+hLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=3NKwCNaNh+rQf6cSDAgtuUMCxdAkAkIckpxZu5BV5fw=;
 b=aXFNw+eZZvSkaE7ESVAelRrXRbHrqJBwta5tpS9N1DVBzlYxLLzuA9QAIpdraOVh+B2zbQ4JdrKi+ZG6jhEDoBCjuKU8ZqOCzTYQGFvFywzoB+efnLWrXooLx3IWdups8bJlsieqGaqN9wdTtE3tTKwNpkKxXZY477QTn1RWmbcL7Yib9ztrlbN9MPX2JIKWn6wh+W5Vct1c7bsgfQRMt10Bu1UB6rD+umc2FLvOYtHB55bUOlqCNeHN36Lxkp38Ob0jKhM0R+a9jtSRmuJyXPrk8iE6JZw3IVG1TqfNtBMuxb0cQ9W2Od/YoLqywqcH0BIEVU5IKckn47ZC9GiKqQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=oracle.com; dmarc=pass action=none header.from=oracle.com;
 dkim=pass header.d=oracle.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=oracle.onmicrosoft.com; s=selector2-oracle-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=3NKwCNaNh+rQf6cSDAgtuUMCxdAkAkIckpxZu5BV5fw=;
 b=jf2HNf3gR6/lohmdgElKykqTWmVFUOZmEbVtqS7y/a/GDsOVoZLAL8X5ndWYTx5tPIzl2ZwNU8ejNKFsBmlcX1yo6wxMfS+rMx7f3R6AIsSexM5OdvlijuIxyw+3O1CDIHsdc/19YBAcscfI8/mu6UK09p7V7L40/D42d9n6+RQ=
Received: from DS7PR10MB4848.namprd10.prod.outlook.com (2603:10b6:5:3a2::9) by
 BLAPR10MB5139.namprd10.prod.outlook.com (2603:10b6:208:307::20) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8048.18; Wed, 9 Oct
 2024 16:57:04 +0000
Received: from DS7PR10MB4848.namprd10.prod.outlook.com
 ([fe80::72f7:723b:4445:1d11]) by DS7PR10MB4848.namprd10.prod.outlook.com
 ([fe80::72f7:723b:4445:1d11%2]) with mapi id 15.20.8048.013; Wed, 9 Oct 2024
 16:57:04 +0000
From: Patrick Farrell <patrick.farrell@oracle.com>
To: muhammad uzair jawaid <muhammaduzairjawaid@gmail.com>,
 "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: [External] : [lustre-devel] IOR MPIRUN read low performance and
 values are not consistent
Thread-Index: AQHbGmIyfwXjPpC56kq+6ibZXJetx7J+oX9Z
Date: Wed, 9 Oct 2024 16:57:04 +0000
Message-ID: <DS7PR10MB484817F4528A406204D6F194997F2@DS7PR10MB4848.namprd10.prod.outlook.com>
References: <CAEdZt_0e+TTsodA-gzma+j9arUTyDpv6g+WbAj7v14ewwNBOSQ@mail.gmail.com>
In-Reply-To: <CAEdZt_0e+TTsodA-gzma+j9arUTyDpv6g+WbAj7v14ewwNBOSQ@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
msip_labels: 
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: DS7PR10MB4848:EE_|BLAPR10MB5139:EE_
x-ms-office365-filtering-correlation-id: e8d5f5f1-8f99-401f-08fe-08dce88366ec
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|376014|1800799024|366016|38070700018;
x-microsoft-antispam-message-info: =?us-ascii?Q?xgHmayyIYVKga+uSbaJpktL9V+Sw/WgO3o4kUq5V6jZcMy3olP9X9zOk/bV1?=
 =?us-ascii?Q?ZrbwxnKjOPfB7f1OyUgw1BSGz6d5CrXZkYL02Sz/6fSe8PBpbge8rC296axK?=
 =?us-ascii?Q?/NH44Pfh6oGxiaX3DuTuismUecAKtWUBRyEnVeBzVWxvMcaaHDzbG5Luiwwa?=
 =?us-ascii?Q?rVNEaA2wlomXoPTU6I+PljWmTB59l9NbfGAMFW4DrvDo05L3MFFRllsGDYcm?=
 =?us-ascii?Q?h6MLRD0EaQFCNgnAe9YjkEXIqEI9ObG/kpJb1E2LhngR4FKQRrFXIBBcipmu?=
 =?us-ascii?Q?bU21VPTuMEsKIyxRtm8jWJFYUD6P+7ANaKHmck9vUnjtWImxRWnaldZsDSOI?=
 =?us-ascii?Q?+6vQtF+b4oMbbuABux3bp+rt9cRRe0iRL6AoPI2OH40NMeM69sWmYjJ0fGmF?=
 =?us-ascii?Q?Nod7mqxDCklNwqHxOPOLTsyVKW3lA+Vd05BFKz6nEVXCnXr1ouo/0qDpvjra?=
 =?us-ascii?Q?zrAICYDZWm/c+9OQUDdZIMal1hNTbIy8zG1OfWQYlgMtBomkjYpfdJZCFEO6?=
 =?us-ascii?Q?WjAr6FsmYDrnDasSweaMi6I1nP1OOjUvF/zJPdtkq5JHtFnb2sN6ap2bxp6v?=
 =?us-ascii?Q?Rt6o+rVlsM4zb74LVumGHdJJIeairZhgxXvXCHIvDmaChXyaeGZvi0ZWepKB?=
 =?us-ascii?Q?V4T1P7IW+6sne0yczevHKR9U8nCF6VvXhGLsx526gqBUjGUPzzQYEsHkHIWN?=
 =?us-ascii?Q?8hKHoC1HNkRvDadlxKXzkahHVCVN6XqLX7OISYGj51kYICDi4qZfat8MOug/?=
 =?us-ascii?Q?/lkBL+y/LkmUd9Zoh9b13dYRnhvZXI+kBg1z52r2UrgM3zEtkiP3zDcyVomB?=
 =?us-ascii?Q?4JknzwM1NSbcZbJIWyAvR2PLwAO+es+IdkYQbkyqmQjZjodfiNMewyhfVC7a?=
 =?us-ascii?Q?90bh5rNa+ifvmRclCpKwUAL91ekT+pZckpfq0rT6Y5dD2qHteCGc6sgt0CzU?=
 =?us-ascii?Q?elrg2mYLUczTJPeLGHmBES09/cQVNGWqudb/ATTyj7iw5B3YUwwgya3ul2Py?=
 =?us-ascii?Q?Ab4hcNZaDCDoGRePVWsnuZQqqA9c8Q6esZ1Dxyh0MNGtVqQhh40Y4XmXNpHd?=
 =?us-ascii?Q?2JqSURxfWPJbP3bIGxJWFN1ffKg6dbe3NfV3uJ5+axDWCGI89hqYF2c57Hl/?=
 =?us-ascii?Q?yTK0WWxyQ7xYNg0gae8fVtnV7dtv4g0+iz1u9eGZmC34k2GzPPopOmoyANof?=
 =?us-ascii?Q?FMPx+RgODHOFXQB+PkHCRqj/QZ/wjCMFDnHchoJFtl/PKWHGGhW+ht3EEp8p?=
 =?us-ascii?Q?YNj6/2kPDJpo8YHbXU7xo6VsAd/JYnk18BZOiV6ZO0XX0fiyHhW+4UY/swkQ?=
 =?us-ascii?Q?54Gwuyh1RfrklvDIMw6QaGkdISbixpAHKWZulfoRAZhs2Q=3D=3D?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:DS7PR10MB4848.namprd10.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(376014)(1800799024)(366016)(38070700018); DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?t1mw6GmZdGaD3chQuUBlG1B4wk2y0PDlBEhlEDRqEfXP9O9MpzVpQ1jfjCWi?=
 =?us-ascii?Q?2oAz8V72xVEYc1WFwYXHv3H4kn95NkgE44bZQWrWLqKUyFO6PjSW6CO9+yMa?=
 =?us-ascii?Q?g4MbLiNDkEoWADF+HeQsbsFn5zGjfbmJZsfL+8zA8N3NMypoIWJmC3fJnAiN?=
 =?us-ascii?Q?V9J0gGcZVYdzxDYt9x0SGUS1DcX7PTudaj4MsyAfckkyGJeirX+b5JL+Qxi9?=
 =?us-ascii?Q?uk9bVekp2VKBb+T4QyyEvk7rDc1QV24K90RCGK6fbL8qL3IOM0+MnGhTUSqK?=
 =?us-ascii?Q?EcBFjiHCQ5FAdgs0tayLUHsvdhSiHnz2WkTAT7VB+MZOtBYG06Jk58yZGiEt?=
 =?us-ascii?Q?sEEUfKWEno6ACXGd4qABFoSPBAOiz5k+52WTC8UcaP/+0PO29zZxDhQqgID9?=
 =?us-ascii?Q?Pbgin3dRe1SiAq4EXb7EGoNufhnrNhbXOnYmKbjBfxHoOAL+Fh2wQqwfmqH9?=
 =?us-ascii?Q?1rpVTGGN+wKJf8shhGcHhYfnO3x+4JZ9E9BN8Rbr6tdqh1T4BxGEqA/0v51v?=
 =?us-ascii?Q?gb63uUhv7NEMvlM7QrUa3r0BY/jF6m4GVVXM5On9oT0Rh8o0ANkBvBzVJT2x?=
 =?us-ascii?Q?EtrtqBM4EbkeOKM+0V21Io7IWMw9RsW44pJGutQKFRmQrA/VLmPoQaHwsERh?=
 =?us-ascii?Q?45XzvMw8feYTh07FC0Eux5w9ufVlrio856+6nbIIsvql53TDfQJvNTxKdJYx?=
 =?us-ascii?Q?09O2YXanwGyWnGw5cMY7O3+oDmwWiiuqva5UJg7eUbHLjQfpkaFmochDLMkH?=
 =?us-ascii?Q?nGN2pkiSKJBgq8pPNpenUJdqB3jdCST1FGS/ceWDoo5dszi6VV8ShBl5ZIOg?=
 =?us-ascii?Q?YfdMwEct8mwwgCub3xVgklvcrnuPvKWkPDO/mejoAAbuWkc9WAUzALDgAWdM?=
 =?us-ascii?Q?NiPavgkhBsdYVJa1qLk7h/51dtMMFF5r5Rdb84EwYJNj/5fRhhmjAXzkFKH4?=
 =?us-ascii?Q?Ar/0bK/OR1+dsiaKi6rcexEW415f9voyVEN5xGOIKV4sWWY4501CBxUSEVRn?=
 =?us-ascii?Q?PEgTR8o/J3bKbdgQnJ5wWjbRJr893f779bjP+h90e2W73N+rq/AAttWxIB+U?=
 =?us-ascii?Q?0Qu+v5AYb/xsQkIy9MEOHJzb9BIK02komZXL5ui8772imhbs0OckwiYuvHM1?=
 =?us-ascii?Q?LNrpAtD1bhmv/wHTIKBbAYIYGfE+X7AZWw/bBBJYzpxZoxsgo7I3eOKq2fYp?=
 =?us-ascii?Q?UbHkYQ2oFJ/RkZkZ4knGTriejQN9UZjiSt0Nt+axjPEuo9QEuyob7MAvsbeL?=
 =?us-ascii?Q?Hna+NZ59nYrXJJoWS+kqad3IQAZW6wPrWYlIXCmS9FPtarbNEWT1nwOIGdCu?=
 =?us-ascii?Q?fMwkzs36ZZzH/+LRnicGUNukEDstmR9WfB83tXJrpkAPwuYRv0nd6dPym6Cq?=
 =?us-ascii?Q?JSAT/shKjs83YrcRlb05QUnBp3HVR10C73P1LwD5xOwKbpZjVXKco1bY6/Jp?=
 =?us-ascii?Q?ir9FrGNIBmte9EGrFkGk1IsVvzsvmpzzb6GNEUvLYldb2ECjJEf0KXmjfKiA?=
 =?us-ascii?Q?AWutyN3QnFTx1NKDGcKHf9IWax3k1nVjlh0Py3dBJN4MrvVifENHIc1hkzLK?=
 =?us-ascii?Q?8936UHC/wxpiEPmiwPYmX507Ln02TVC3tXU6Nw2X?=
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: klfkiPeJVtynbR/NP6ELiuB98zpHNxIr2coNqKihn+n08Aa039LFnmZzMTq2MgdC1QVTldQsT2UbiKLSHLCYwoPS2cdDcF+YXpuEfEE7SXxP8l3QajiSXNRc7QD/QhhxHXCmUQGQOM3fScfPWhmHz5atwU2QtMIgN7Q2WQNjKkIplay0AF7h/ewJLlcrXIxwn7OKE6CUWrkEI0JKAVB+o4cfRuKIzpbX0p365WwF3aCdHo+IRBr44Pp1Mi7W1GyK+rMvdz5cv40S+aQc/lasaVWGsdBC9dBjfRybQr6FrHzW+WirN2pDA3cKfeuNORF3H2R/oRs0h33/9Flz1z/MsOsLPeM2YNgKgr91O8iuoR3OfImzX8rUdYYOPpv3v+gxexiRpaOi2QDYXxHV5KhTHLspRzxey/TA9Uq2okqdL9XPs8a94DTjrm6yLgEp9gjHxTthZ7m4U8hlEiq9tWugoINM7EFgA9vuEtxORxlC0VXwr6SlpXp1sjJNwIZH/P1Jar/+fVxvU4EEBnjEBpi1ZMjOBCDfa304O6q2DZKzLBIEuVKOw9zsGYtjkQYtvkaiFcTiShCDiwvx3G6I+DTUKfv9FDU7bjsvpuw/MrLtKWU=
X-OriginatorOrg: oracle.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: DS7PR10MB4848.namprd10.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e8d5f5f1-8f99-401f-08fe-08dce88366ec
X-MS-Exchange-CrossTenant-originalarrivaltime: 09 Oct 2024 16:57:04.4492 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 4e2c6054-71cb-48f1-bd6c-3a9705aca71b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: AxCV3RCkzewhEaGfj72Vz04vRws52N9kDCDW2VOHLSJfphugZx9wIWM5NAffjwkZzUQoxP7h1QxI5hsqs2uHKxenC+3YCIu5Hb7d3bb9dFU=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BLAPR10MB5139
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1051,Hydra:6.0.680,FMLib:17.12.62.30
 definitions=2024-10-09_14,2024-10-09_02,2024-09-30_01
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 malwarescore=0
 adultscore=0 mlxscore=0
 spamscore=0 phishscore=0 bulkscore=0 suspectscore=0 mlxlogscore=999
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.12.0-2409260000
 definitions=main-2410090101
X-Proofpoint-GUID: xAn5UqiHHcUBNQarYbAQRJ9NMw3UoUCA
X-Proofpoint-ORIG-GUID: xAn5UqiHHcUBNQarYbAQRJ9NMw3UoUCA
Subject: Re: [lustre-devel] [External] : IOR MPIRUN read low performance and
 values are not consistent
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
Content-Type: multipart/mixed; boundary="===============9216206526979762995=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============9216206526979762995==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_DS7PR10MB484817F4528A406204D6F194997F2DS7PR10MB4848namp_"

--_000_DS7PR10MB484817F4528A406204D6F194997F2DS7PR10MB4848namp_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Muhammad,

Looking at your attached, both IOR and fio (mpirun is not the application, =
it's an execution framework) are configured to use 12 processes.  I encoura=
ge you to double check your CPU usage, what you're saying doesn't track unl=
ess something's very strangely configured.  It might be you've forced all t=
he ranks to use 1 CPU or similar, but otherwise, it should be 12 CPUs.

You're using direct IO for IOR, so my best answer for your question about w=
hy read is much slower is you're perhaps seeing cache effects on your stora=
ge hardware.  Note FIO is using libaio, which is not the same as direct IO =
- it queues IOs rather than doing each one individually.  An iodepth of 128=
 with 256M block sizes is a total IO outstanding of 32 GB, and I think that=
's 32 GB per process.

In contrast, IOR is 12 * 128MB =3D 1.5 GB total IO outstanding.  Very diffe=
rent.

I'd encourage you to do some much simpler testing - single process with sma=
ller amounts - and see what the results look like and build your understand=
ing from that.

It would also be informative to not use Lustre and see what the IO behavior=
 of your individual OSTs is when used as block devices.  (Obviously this re=
quires reformatting)

Best of luck,
-Patrick
________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of muh=
ammad uzair jawaid <muhammaduzairjawaid@gmail.com>
Sent: Wednesday, October 9, 2024 10:44 AM
To: lustre-devel@lists.lustre.org <lustre-devel@lists.lustre.org>
Subject: [External] : [lustre-devel] IOR MPIRUN read low performance and va=
lues are not consistent

Hi,

I have 2 question

1) I run tests using fio and mpirun. The write speed for both are same but =
the read speed of mpirun is very low as compared to fio. My fio test gave a=
round 8GB whereas my IOR test gave only 1.5GB.  I see on top utility mpirun=
 read is only using 1 cpu whereas fio uses 12 cpus.

2) why the result in mpirun/fio read and write are not constant? I have iso=
lated CPUS on numa 1 and my network interfaces are also on numa 1. On every=
 run I see a different value which can deviate upto 4 GB .

I am attaching my test in a text file.
My setup is 2 lustre servers having 3 OSS and 1 MGS/MDS and 1 lustre client=
.  I am using rdma rocev2. 1 NIC card 100Gbps Connectx5 on each server.

Thanks for the help.
Best regards
Muhammad Uzair Jawaid

--_000_DS7PR10MB484817F4528A406204D6F194997F2DS7PR10MB4848namp_
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
<div class=3D"elementToProof" style=3D"text-align: left; text-indent: 0px; =
margin: 0px; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, C=
alibri, Helvetica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">
Muhammad,</div>
<div style=3D"text-align: left; text-indent: 0px; margin: 0px; font-family:=
 Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-s=
erif; font-size: 12pt; color: rgb(0, 0, 0);">
<br>
</div>
<div class=3D"elementToProof" style=3D"text-align: left; text-indent: 0px; =
margin: 0px; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, C=
alibri, Helvetica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">
Looking at your attached, both IOR and fio (mpirun is not the application, =
it's an execution framework) are configured to use 12 processes.&nbsp; I en=
courage you to double check your CPU usage, what you're saying doesn't trac=
k unless something's very strangely configured.&nbsp;
 It might be you've forced all the ranks to use 1 CPU or similar, but other=
wise, it should be 12 CPUs.</div>
<div class=3D"elementToProof" style=3D"text-align: left; text-indent: 0px; =
margin: 0px; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, C=
alibri, Helvetica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">
<br>
You're using direct IO for IOR, so my best answer for your question about w=
hy read is much slower is you're perhaps seeing cache effects on your stora=
ge hardware.&nbsp; Note FIO is using libaio, which is not the same as direc=
t IO - it queues IOs rather than doing
 each one individually.&nbsp; An iodepth of 128 with 256M block sizes is a =
total IO outstanding of 32 GB, and I think that's 32 GB per process.</div>
<div class=3D"elementToProof" style=3D"text-align: left; text-indent: 0px; =
margin: 0px; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, C=
alibri, Helvetica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">
<br>
</div>
<div class=3D"elementToProof" style=3D"text-align: left; text-indent: 0px; =
margin: 0px; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, C=
alibri, Helvetica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">
In contrast, IOR is 12 * 128MB =3D 1.5 GB <i>total</i>&nbsp;IO outstanding.=
&nbsp; Very different.</div>
<div class=3D"elementToProof" style=3D"text-align: left; text-indent: 0px; =
margin: 0px; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, C=
alibri, Helvetica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">
<br>
</div>
<div class=3D"elementToProof" style=3D"text-align: left; text-indent: 0px; =
margin: 0px; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, C=
alibri, Helvetica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">
I'd encourage you to do some much simpler testing - single process with sma=
ller amounts - and see what the results look like and build your understand=
ing from that.</div>
<div class=3D"elementToProof" style=3D"text-align: left; text-indent: 0px; =
margin: 0px; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, C=
alibri, Helvetica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">
<br>
</div>
<div class=3D"elementToProof" style=3D"text-align: left; text-indent: 0px; =
margin: 0px; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, C=
alibri, Helvetica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">
It would also be informative to <b>not</b>&nbsp;use Lustre and see what the=
 IO behavior of your individual OSTs is when used as block devices.&nbsp; (=
Obviously this requires reformatting)</div>
<div class=3D"elementToProof" style=3D"text-align: left; text-indent: 0px; =
margin: 0px; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, C=
alibri, Helvetica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">
<br>
</div>
<div class=3D"elementToProof" style=3D"text-align: left; text-indent: 0px; =
margin: 0px; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, C=
alibri, Helvetica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">
Best of luck,</div>
<div class=3D"elementToProof" style=3D"text-align: left; text-indent: 0px; =
margin: 0px; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, C=
alibri, Helvetica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">
-Patrick</div>
<div id=3D"appendonsend"></div>
<hr style=3D"display:inline-block;width:98%" tabindex=3D"-1">
<div id=3D"divRplyFwdMsg" dir=3D"ltr"><font face=3D"Calibri, sans-serif" st=
yle=3D"font-size:11pt" color=3D"#000000"><b>From:</b> lustre-devel &lt;lust=
re-devel-bounces@lists.lustre.org&gt; on behalf of muhammad uzair jawaid &l=
t;muhammaduzairjawaid@gmail.com&gt;<br>
<b>Sent:</b> Wednesday, October 9, 2024 10:44 AM<br>
<b>To:</b> lustre-devel@lists.lustre.org &lt;lustre-devel@lists.lustre.org&=
gt;<br>
<b>Subject:</b> [External] : [lustre-devel] IOR MPIRUN read low performance=
 and values are not consistent</font>
<div>&nbsp;</div>
</div>
<div>
<div dir=3D"ltr">Hi,<br>
<br>
I have 2 question<br>
<br>
1) I run tests using fio and mpirun. The write speed for both are same but =
the read speed of mpirun is very low as compared to fio. My fio test gave a=
round 8GB whereas my IOR test gave only 1.5GB.&nbsp; I see on top utility m=
pirun read is only using 1 cpu whereas
 fio uses 12 cpus.&nbsp;<br>
<br>
2) why the result in mpirun/fio read and write are not constant? I have iso=
lated CPUS on numa 1 and my network&nbsp;interfaces are also on numa 1. On =
every run I see a different value which can deviate upto 4 GB .&nbsp;<br>
<br>
I am attaching my test in a text file.<br>
My setup is 2 lustre servers having 3 OSS and 1 MGS/MDS and 1 lustre client=
.&nbsp; I am using rdma rocev2. 1 NIC card 100Gbps Connectx5 on each server=
.<br>
<br>
Thanks for the help.<br>
Best regards<br>
Muhammad Uzair Jawaid</div>
</div>
</body>
</html>

--_000_DS7PR10MB484817F4528A406204D6F194997F2DS7PR10MB4848namp_--

--===============9216206526979762995==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============9216206526979762995==--
