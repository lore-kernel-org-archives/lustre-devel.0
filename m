Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 3E537C02181
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Jan 2025 21:45:37 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Ydd0Y0kZwz1xPn;
	Wed, 22 Jan 2025 13:45:17 -0800 (PST)
Received: from outbound-ip168a.ess.barracuda.com
 (outbound-ip168a.ess.barracuda.com [209.222.82.36])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Ydd0N02V3z1wPR
 for <lustre-devel@lists.lustre.org>; Wed, 22 Jan 2025 13:45:07 -0800 (PST)
Received: from NAM10-MW2-obe.outbound.protection.outlook.com
 (mail-mw2nam10lp2049.outbound.protection.outlook.com [104.47.55.49]) by
 mx-outbound12-38.us-east-2a.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Wed, 22 Jan 2025 21:45:04 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=C32CWG1YFuvzom5zeNv8AaikMYDy5dYsaTz7iajxD7s2PbYYft9SkMU/c5fgKwf7QOkenkMmLrObCvanMaJNzl0IdrJv8uBMgS5MNd4xfBs7FIO+9VJNsGe/4JO1IUb/KVGETBty4ncDTlsKnwkRFem0EfPlHoTtMNmArDpE7c3PehwDI+ns0Z3JEhgoubeTWNIqwUyFZY32XqBK+8Sq0A0PEJzBVG+kspv9voluJNLJGx829ZBnf2cZKJ1K9CqkiLXvHRqjK4SvAa5behluy6LVEnHjnOnAwYvm/qVuv/rO4BQ+5em4LU/cMNhdMr2ZIYQttq8U4q/9Sp/9ChQZVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=w+SDNVontm80nXy2AYx6B1EDjfPMQF9cSKt9ojk+fDw=;
 b=auaSpomN0kQltJixbrWPQjMPvLOKSM7De5kJlqk1rOrEsNMZgoBcZiJ2Z0x4QOI7E5se43Hlugy+ij56WUHSOU0SjKgKnWMZrx7VOtAlQxy7q81szWsy91m500fURd5ZksGdgN5SCrAKYFXbv0JU/b8XMChCkbh6WAqZxmbAZ9DB1VlVHQGHfU5gg3fh7PVhv2kM4d9AGpRg3DORot2YBOCFMpl055wtoKTxdv6x8zoHUPHIyoZMwdYmTvydP2vBvm16DjJk0IJeu1F/ckiT2GcYjMJKsiqAN0WfcdtJO7jxQSMzoMvgtAVyC3OOXETMt5+YeR8EwOJ1Hh0/r1JQ5A==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=w+SDNVontm80nXy2AYx6B1EDjfPMQF9cSKt9ojk+fDw=;
 b=r3GdQoZ1zPgnQlXDOrAaQB/JQkQCkVjyNlRLCIA78qZRoV85k7YNO0lLTBX/fOnN0y4sXDQYn2dTWv0R0OmKcuxtHTDYJC7dPPTXfgbG9Qomm9Z0mcq7JymFKPmE4rxnX9p6z0BQdVN293UI9IAMQ2y4tiOUg1GE+L3qOQCb38c=
Received: from SN7PR19MB6567.namprd19.prod.outlook.com (2603:10b6:806:26d::11)
 by MN2PR19MB4078.namprd19.prod.outlook.com (2603:10b6:208:1e4::8)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8377.17; Wed, 22 Jan
 2025 21:44:57 +0000
Received: from SN7PR19MB6567.namprd19.prod.outlook.com
 ([fe80::db50:586b:7dda:cf04]) by SN7PR19MB6567.namprd19.prod.outlook.com
 ([fe80::db50:586b:7dda:cf04%6]) with mapi id 15.20.8356.017; Wed, 22 Jan 2025
 21:44:57 +0000
From: Oleg Drokin <green@whamcloud.com>
To: "neilb@suse.de" <neilb@suse.de>, "alexey.lyashkov@gmail.com"
 <alexey.lyashkov@gmail.com>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
Thread-Index: AQHbaF06daQEbe3e/kelMir67rT0hbMbs8GAgAAqWwCAAUdfgIAAgwkAgAAYFICAAIirAIAFBZWAgAAOLgA=
Date: Wed, 22 Jan 2025 21:44:57 +0000
Message-ID: <9a6b4df4e23db0255e0854c1c16bef89d9c35b02.camel@whamcloud.com>
References: <>, <7459DF85-7A0F-4DC8-9EC3-CA6F3C86234E@gmail.com>
 <173757925141.22054.738723965751021240@noble.neil.brown.name>
In-Reply-To: <173757925141.22054.738723965751021240@noble.neil.brown.name>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: SN7PR19MB6567:EE_|MN2PR19MB4078:EE_
x-ms-office365-filtering-correlation-id: 1c25adea-60db-46ee-decd-08dd3b2e03a9
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|366016|1800799024|376014|38070700018;
x-microsoft-antispam-message-info: =?utf-8?B?aVRmS3lTRVgwU1BiOGJmMTlidDRlZlNMalVqcHQ0N21jejJFb1JRT01mVlJF?=
 =?utf-8?B?R0wvRE0zVTRQQmw0RkJtK2VmaGV4dGZwU1J6ZE54dnNIZnVvWGVodHZqVUk4?=
 =?utf-8?B?cHJUU05OYW9hU2YxM2JqZlpKUmxXcEd5S0NpZmNNSDB4MmZJak85RmNkalpH?=
 =?utf-8?B?Rjl1NU9IMzVTdzFRYXJqTHE3M00rU25neW1WRXNnbVhsUFVMcHJiNXY2TWs1?=
 =?utf-8?B?UWZRd0lkcjFGQUtKMVYwYVBhSFp0S0wzUWp6UFdvY1RNTFVzQmh6MEQ4WWJa?=
 =?utf-8?B?Zi8ySzFzRGIzelJBOVdvMWZpaVZkeGhhK3BoaUQvWVd3RVRwZlZQcW5RMW8z?=
 =?utf-8?B?eVZ2UlgxSmZ1NjBheWdWMjlCdnAzYWI3Z0pTVlYrUDlleVBNZjQwMnFPc3J4?=
 =?utf-8?B?YmdhcDlBUkljeXdGNWtFYWRzQTRlbVJrV25RSW1qR0t5UjVGZy9NbTJXMDNn?=
 =?utf-8?B?S2ZtSWpZQWlESDc2Nys0dGNTbnZOWU1uaE9xUmlnZVpqUUJIQzFhUWhIV2tP?=
 =?utf-8?B?dFI1alVQenhobXpsQ2ZiTDF2Y0FWUHNpRGo0dHI1VDJXcHROc0pGMlpVcCtD?=
 =?utf-8?B?RXRjd2lHc09FOFJEa2lWaitLaFBGVEsyOStCR01FeVlZZkJOWkRrOFVNd1hM?=
 =?utf-8?B?Y3BKeUFBbkRJL2k5STdhL3FDV0hnYUtkdDc5RXBSMEhTUGdINkttM0g1d0tI?=
 =?utf-8?B?TDI4MUpISDJ2RVZETDdKUmlZMk9MWGhkUlpKaGkxMGlBdTRTdkRualJYS2Iz?=
 =?utf-8?B?WmZXRCtjV0hpTFd0MXBhTG9pTDN2Y0NKTFVCNEovRE51OUJGb1VLQnlKQWZl?=
 =?utf-8?B?OW9XY2dLNW9uc0tSR2pQZERrYzRNUFVLZTRVbG9FVy9jRjhGcFZOamY5cXNF?=
 =?utf-8?B?Vm5USHhqMnhmQVM3QkNpaGtmWWdhbWhKdnR3dGRhNjlKa1V4K2I4MUNaNUNV?=
 =?utf-8?B?Q0RWT1hLQ3YwS3JmR01HUWVOaTNoaSs2b1ZXbk9pSXBZNmNENitYT2hyZVVm?=
 =?utf-8?B?cGwwd1pwK3FjNkFKS1Q2R0p2ak93cytPNUgvUnNqRkg1aHhQa1VCTWFQb05G?=
 =?utf-8?B?d0pPd3R2VFBmSWFaQUFTZUphcTQwYjRWcTRMeXcwMGZhakROZWt4VEVJS0Jh?=
 =?utf-8?B?T3htcm0zdEoyOEQ0ZU5BMG5nTm1wdU85OUZuWTBPamJYYTJLYzMyOXBqMHYx?=
 =?utf-8?B?RFp6REFhMzNZaXM0NndrNXhCeUF5NHhJZlFyM08wRWp3eDFaWFUzbTFBK3BU?=
 =?utf-8?B?bGpjNXlRNjU4Y1REU1hVRmRjNXUyTWNHSTRGRk1tRXRucWE0WFZJVndHclZX?=
 =?utf-8?B?aHYrTStzaDRkWDRjQUdaNnJ0YU16RFcrZ1hFemQ1clAvMzRjNFlkRFpGVlhD?=
 =?utf-8?B?dVRncUlYQkJKOVpBYmYvVCtyb29VVjUraTZZT0RNRGhGVEI4WS9xSTVtTEUr?=
 =?utf-8?B?OFVqM3g1TjhGS3FUcllvVHk2OHQ2eWJJS3cxeHdhQUZQZ1k3ZnEwcFZwQVd1?=
 =?utf-8?B?TDhySlM3UzJtai9ud3RHenNoVDFIUncxVHF1TDUxUU5KY2tHUnNQbG9VRDVG?=
 =?utf-8?B?aDQzNWhjUHVRdzJCem5xUWFYbTdVMGVqbStoUGwwbVVyQ0RwUUlMU2tQRWZy?=
 =?utf-8?B?cUJtbDRVQWdYcHhraE1GdkZSZk9vVzZpRGxpZEE4OHBncWxVU1RoL3AxUnNN?=
 =?utf-8?B?bjJRRU0yZkpxYlNaVzJGdUNUMC9XQ2tERWhjSFgrZVhIakNSbEpKdzJnQ0Z1?=
 =?utf-8?B?Mm1BaFVtRW9zaHdIZW9TYXpNYjI5RDRlRGtERkNOVVJvTXRlVU9UQkpzQ3JK?=
 =?utf-8?B?ZkliTlltUmVrdXBhN3NXNWhqaUFpeWR5d09qbWl5THh4QWllaitpQ0Q4KzJN?=
 =?utf-8?B?a1dsd0hUbjVRSTY0R2xGTFJ4cUVucC9UL0FTaXlXNWNCWkNXc0IyR0J2RVRS?=
 =?utf-8?Q?z+fQ1/OQwEJMe8OsVCUpaH1aS3RDG+Ns?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:SN7PR19MB6567.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(366016)(1800799024)(376014)(38070700018); DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?cFkxZnNHdkJmalovMWJsbkFaQm9vU3FoQW9DcTRSanBXYlkwajZhUFp5amIw?=
 =?utf-8?B?eWwraDRUTzdENVJWbjJKWSt5SGJQWGI5amFjdlFMUW4wMlBmRG9sZWxvWjVX?=
 =?utf-8?B?SmtsUHBpMC8zMWhXb2xDSHhnUTR4LzQrQ0J6S3hDd2VHUEhvUTNnWEpHbGJw?=
 =?utf-8?B?RHBFUzQ3YllEMTJDMlhVcDdZUXJRd3JOaGU5SnRvd2tINE8xQUVqeHB3OG1F?=
 =?utf-8?B?dlZLemJsc0FDbmNWOHUyWWltU0NRaklGMVNYSkNrUkhYYUs0M0VFbnBtcDlk?=
 =?utf-8?B?cmdmRWthMzVCQUFRcHdMS0t2M2hhOWJ3SUJ5R3ZBWUFpOVRhSHA1K3BJM3hF?=
 =?utf-8?B?K05uWHg1QWdPRWIzekdzSEhnWFlJVGhMclVKK2dYWU83TjVGQUczWjgrRndq?=
 =?utf-8?B?OXVkb1ZVamtoMjBUMDg5NDJMT1dnMG0vZDJqcHV4d3NPMnBXQXprTDNYaFc1?=
 =?utf-8?B?Z1k3UVJTR1JmNm5vRHJ1TEZWMHlvQXBOZk85NHBVSzhTNERuNU5JYWpjQXJq?=
 =?utf-8?B?SVJYVEtVTzFZZGljZW53SkZrSkJXYVNPSURoWFpVU2craXM5YzZkN1htOGFp?=
 =?utf-8?B?dS95MWxTak85TmUrMDNTb0RuaGk2aUN5cmlXSWdiSUpDZFZ5NVBuWUE0NS95?=
 =?utf-8?B?ZEYvWEZUcURReUdzZXNMano1d3JMN2pmZ1RmTVRFVThhZ2ZacDh2NSs2MkR3?=
 =?utf-8?B?STlXTm5HVDROempkTTNTUXFSK1FNa05zZjVNYzdUQ2dkZUM1UUwzbHFHbHNz?=
 =?utf-8?B?M0VHME9UREZRTG5WdktMdkp1YmZNZ25yME13eUd1QTRKc1UrYm5GNHpFOVVS?=
 =?utf-8?B?NTNJUXk0ek9mTXNGQlFZYyt1aDVYNVpKTjlTbEN1NEtibFEvZ0F3VTM4TzFt?=
 =?utf-8?B?UTg0ZVpMa011UzM3L1JoNjJvcUxMN0NqY0gyRWZqd2o4Um1qV0NWMms0SUVN?=
 =?utf-8?B?U2JVVWhkdjdaMlNIUk5saFozMmpMbXBqbjNoOWZ2N1BHcmNlSUpHMkk4WHZq?=
 =?utf-8?B?ZXRRRFFpSXFKTnJWdHB1dEErRzJHZm9mSU9wV01MOUd6dEkrSHdXbkY4cjdl?=
 =?utf-8?B?c3ZJVW45aWhtcDQwSXB1UzMvYnAxTWRLclJJWk1COEptdnpWQVMveDV6ZjFL?=
 =?utf-8?B?b0toTGNUd3BDeVE2cTZucFUzVEpEbVZtRDBML0RJNml0NmlGdmV3UWU5TUdH?=
 =?utf-8?B?QU5yZmpIZlZodVU1VllYWnlMWVJqQ0xZVnRINDlDVWhyYnduWUF6K2dSeFRT?=
 =?utf-8?B?TzZPbGVpYUFSWUFBK2k0a2FOWEN0QjJ5NDIwd0lrMjZQbjM0YklnMWxNbDRn?=
 =?utf-8?B?SjNXY3lkZDVSWW5OVnlrT2kyRllvTUhERURoUXdPYm9XeHR1aENmZEJScy9B?=
 =?utf-8?B?WWhFVEs5LytOaGpUa3E5TzEveHo0aHIvOW9iTTVTYW4xdkJaWmtuamFuanoy?=
 =?utf-8?B?QVZCNWhDc0lMbnkzZk42U2lIcFZBOGhuVHVSSmJqTGJieUhpc0xlbWx0SEVw?=
 =?utf-8?B?SjFmV3BQM1MzNWlsRXVVbTVqQmJRcHdacUExU3JrK21EaW01NDE1aFZBcDQ5?=
 =?utf-8?B?QmNnSklMbW5FbUpuOThKV1lYRkQ0a083OFQ5ajJPc3daV2dOQmJ5QXpNamsz?=
 =?utf-8?B?bDZ6ZlFsZklRKzhPdVJYZXpZM3pkWmNCWnNMRFpXdEoxdGs1WW1PYXZ1dXgw?=
 =?utf-8?B?Yy9MSmpRUFl3dnVhUHJLVmVVUUgyYkgzOGVaM2ZqcEQ4WGRRZk9yblk1SmhF?=
 =?utf-8?B?RC9KODFNVmlycDhNWDZFRGFBME52RWhpaDJ0TVgvb09XZU14RktYMVJFSitK?=
 =?utf-8?B?YU1KUndYNVZIN0JhSzhteXcva3BmOTB1WWlHQm5pUDRPUk9XSWJPUkRya2NH?=
 =?utf-8?B?T2JwVmRiTUVQWjRFQXFMcnB0WGZRM2RMYTZkSzh6dldWK0R4dlNrY0tVQnlG?=
 =?utf-8?B?VXlob3VNZWNEQnlWc05LNU5UM3FlUzR5NFRlbVVFRkMyNFpuRG5tVGFacjBq?=
 =?utf-8?B?ME5URVFIUXRzMndKclhLWFVSalNNeTVIOVVmcmwxTXZHeDE5L0swaTFZUGJr?=
 =?utf-8?B?Vmk5M3BZaGJ3L2xxTGF5Wi9KUzdEcTRTdWJiQlBiWDM3Z1ZsemgzVmNmSVlv?=
 =?utf-8?Q?5e4ZiUZ0LwGDCKR2PGxE3jzRU?=
Content-ID: <92493145FD3C424E94DCCBBCE073F7CF@namprd19.prod.outlook.com>
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: T+eQdrzYXxFUsW83kioRqFYmqsSQmwuNLV5sSWQTbG95wefkwvaZkZwH39yMg52t/uKBHySSCsoCqGFAtzcXnJpmjKbENFiPpRc/9RzpDjbeH3vXNOKjVc6zXykL6s8aJgTjVYBfMRMZ0HgnAGRoLwDLJeT1w201dzxUM87zD+sJrKZ7vBs1m7XJGY2+IhkZ++bBzqKHOnWfj2q8GzMUzf4r13LsRnZA/ea0w10HmqXu+CqUdJJvIbCdtZrnt5V437ynqL4U6GGah+6rp1c6JqUz3nQX/J5vEGA/gZz/4pxmrIlFa1DewT895m13g15Bp+8bF/ijUJ3/FSKehoelRCUBut0Ls/XyaYyn6qWpjwI/vitacmPMamr25NHhhzJ2zMWzqnKhe45Qgbwe4wThC+PIJas2wDUmddcXEIKkQAebhUCMCYoDrOpEJ265yBZvz0GdfZ517hiGdaPLFmizCCGsKGz1WUyHU7BvGSb9OSThD4mqJpe3DhdYu6Sk875A/4X9KEhjbTAp93NHolbZHMGXzBSbPpYgDPkLOPMXiWQnyYLL8/hOHEmH7ciRCGkj5BSJvHMGXeuMt4bVQTeZ/ZdPm3REGgKOGPQ0sO6mt+SYfPMRnad9kp9plg5nxVEAH0eqX/7dzw3IBqEaa535V3wqUVqNcV5OdayDP6EV87A=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: SN7PR19MB6567.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 1c25adea-60db-46ee-decd-08dd3b2e03a9
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Jan 2025 21:44:57.2387 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: eDN2v6BA8V1PRyGGUtPngED4qeZyI+c+BQWWdJeWIGJYF9k6HFTJMrGibJBocz2B
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR19MB4078
X-BESS-ID: 1737582304-103110-11446-7649-1
X-BESS-VER: 2019.1_20250122.1822
X-BESS-Apparent-Source-IP: 104.47.55.49
X-BESS-Parts: H4sIAAAAAAACA4uuVkqtKFGyUioBkjpK+cVKVkbGlhZAVgZQ0Dg1zdQsOdnA1C
 IpydIkMTExKdHCyMLczNzCwtTQ2DhNqTYWALlaCqtBAAAA
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.261985 [from 
 cloudscan12-61.us-east-2a.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.00 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
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
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

T24gVGh1LCAyMDI1LTAxLTIzIGF0IDA3OjU0ICsxMTAwLCBOZWlsQnJvd24gd3JvdGU6DQoNCj4g
SXQncyBub3QgZW50aXJlbHkgY2xlYXIgdG8gbWUgd2hhdCB0aGUgcHJvYmxlbSBpcy4NCj4gWW91
IHRhbGsgYWJvdXQgY2xpZW50cyBub3QgYmVpbmcgY29tcGF0aWJsZSB3aXRoIGVhY2ggb3RoZXIg
b3Igd2l0aA0KPiB0aGUNCj4gc2VydmVyLCBidXQgQW5kcmVhcyBoYXMgc2FpZCB0aGF0IHRoZXJl
IGlzIGdvb2QgY29tcGF0aWJpbGl0eSBiZXR3ZWVuDQo+IGRpZmZlcmVudCB2ZXJzaW9ucyBzbyBJ
IHdvbmRlciBpZiB0aGF0IGlzIHJlYWxseSAoc3RpbGwpIGFuIGlzc3VlLg0KDQpQcm9ibGVtcyBh
cmUgbXVsdGlmYWNldGVkLg0KT25lIGlzIHRoYXQgeWVzIHdlIGhhdmUgYWxsIHNvcnRzIG9mIGNv
bXBhdGliaWxpdHkgaW4gdGhlIHByb3RvY29sLCBidXQNCmFzIHlvdSBwb2ludGVkIG91dCBlbHNl
d2hlcmUsIHRoZXJlJ3Mgbm8gZm9ybWFsIHByb3RvY29sIGRlZmluaXRpb24sIHNvDQppdCdzIGp1
c3QgIndoYXRldmVyIHRoZSBjb2RlIGRvZXMiIHdoaWNoIGRvZXMgZGlmZmVyIGZyb20gdmVyc2lv
biB0bw0KdmVyc2lvbiBhdCB0aW1lcyBhbmQgd2UgZG8gaGF2ZSBvY2Nhc2lvbmFsIGludGVyb3Ag
aXNzdWVzLiBXZSB0ZW5kIHRvDQpjYXRjaCB0aG9zZSBpbiB0ZXN0aW5nIChzb21ldGltZXMgbGF0
ZSwgYW5kIHNvbWV0aW1lcyBwYXRjaCBpcyBjbGllbnQNCnNpZGUgdG9vKSwgYnV0IHRoZSBvYnZp
b3VzIGxpbWl0YXRpb24gaGVyZSBpcyB3ZSBvbmx5IHNlZSBpdCB3aGVyZSB3ZQ0KdGVzdHMgYW5k
IHRoZSBvZmZpY2lhbCBndWFyYW50ZWUgaXMgYSBwcmV0dHkgbmFycm93IHdpbmRvdywgYW5kIHdl
DQpjYW5ub3QgaGF2ZSBhbiB1bmxpbWl0ZWQgdGVzdCBtYXRyaXggZXhwbG9zaW9uIHRvIHRlc3Qg
YWdhaW5zdCBldmVyeQ0KbWFpbmxpbmUga2VybmVsIGdvaW5nIGJhY2sgNyBvciB3aGF0ZXZlciB5
ZWFycy4NCiANClRoZW4gdGhlcmUgYXJlIGFsbCB0aGUgZmVhdHVyZXMgcGVvcGxlIHdhbnQgYW5k
IHN0dWZmLCBhbmQgaGF2aW5nIGFuDQpvdXRkYXRlZCBpbiB0cmVlIGNsaWVudCBpbnRlcmZlcmVz
IHdpdGggYW4gdXAgdG8gZGF0ZSBvdXQgb2YgdHJlZQ0KY2xpZW50IGJ1aWxkaW5nLiBBbmQgY3Jl
YXRpbmcgcGF0Y2hlcyB0byByYW5kb20gb2xkIGtlcm5lbHMgdG8gYnJpbmcNCnRoZW0gdXAgdG8g
ZGF0ZSBpcyBub3QgdmVyeSBleGNpdGluZywgYW5kIG9mIGNvdXJzZSB0aGVyZSdzIHRoZSBleHRy
YQ0KZnVuIG9mIHRoZW4gZ2V0dGluZyBkaXN0cm8gcGVvcGxlIHRvIGV2ZW4gYWNjZXB0IHRob3Nl
IHBhdGNoZXMuDQoNCj4gS2VlcGluZyBkaWZmZXJlbnQga2VybmVscyB1cCB0byBkYXRlIHdpdGgg
bmV3IHVwZGF0ZXMgaXMgc29tZXRoaW5nDQo+IHRoYXQNCj4gdGhlIGxpbnV4LXN0YWJsZSB0ZWFt
IGRvZXMgYWxsIHRoZSB0aW1lLsKgIFdlIGRvIGl0IGF0IFNVU0UgdG8uwqAgSXQNCj4gaXNuJ3QN
Cj4gdGhhdCBoYXJkLg0KPiBZb3UgaWRlbnRpZnkgd2hpY2ggcGF0Y2hlcyAqbmVlZCogdG8gYmUg
YmFja3BvcnRlZCAoaWRlYWxseSB3aGVuIHRoZQ0KPiBwYXRjaCBpcyBjcmVhdGVkIGJ1dCB0aGF0
IGlzbid0IGFsd2F5cyBlYXN5KSBhbmQgeW91IHVzZSB0b29scyB0bw0KPiBoZWxwDQo+IHlvdSBi
YWNrcG9ydCB0aGVtLg0KDQpUaGlzIHByb2JhYmx5IG1ha2VzIGJhY2twb3J0aW5nIGZlYXR1cmVz
IG5vdCB2ZXJ5IGNvbnZlbmllbnQgKGFuZA0KZGlzdHJvIHBlb3BsZSB3b3VsZCBwdXNoIGJhY2sg
d2l0aCAib2ggbm8sIHN0YWJpbGl0eS9idWcgZml4ZXMgb25seQ0KcGxlYXNlISINCih0aGVyZSBh
cmUgYmVuZWZpdHMgdG9vIG9mIGNvdXJzZSwgb25jZSB5b3UgbWFuYWdlIHRvIHB1c2ggc29tZXRo
aW5nDQp0aHJvdWdoIHRvIHRoZSBkaXN0cm8gcGVvcGxlLCBwZW9wbGUgYXJlIG9mdGVuIG11Y2gg
YmV0dGVyIGF0IGZvbGxvd2luZw0KdGhlIGRpc3RybyBrZXJuZWwgdXBkYXRlcykNCg0KPiBDZXJ0
YWlubHkgdGhlcmUgaXMgZWZmb3J0IGludm9sdmVkLCBidXQgbWFpbnRhaW5pbmcgYSBwYWNrYWdl
IHRoYXQNCj4gd29ya3MNCj4gb24gYSBsYXJnZSBzZXQgb2Yga2VybmVscyBhbHNvIGludm9sdmVz
IGVmZm9ydC7CoCBJdCBpc24ndCBjbGVhciB0byBtZQ0KPiB0aGF0IGl0IGlzICptb3JlKiBlZmZv
cnQsIGp1c3QgKmRpZmZlcmVudCogZWZmb3J0Lg0KDQp5ZXMuDQpBbHNvICJ3b3JrcyIgaXMgc3Vj
aCBhIG5lYnVsb3VzIHdvcmQgaW4gdGhpcyBjb250ZXh0IGFzIEkganVzdCBnb3QNCnJoZWw4LjEw
IGFuZCByaGVsOS41IHdpdGggYWxsIHNvcnRzIG9mIGV4dHJhIGRlYnVnIG5vdCBub3JtYWxseSBl
bmFibGVkDQpieSBkaXN0cm8gcGVvcGxlIGludG8gbXkgdGVzdCByaWdzIGFuZCBmaXJld29ya3Mg
ZW5zdWVkIChkaWZmZXJlbnQgb25lcw0KZm9yIHRob3NlIGRpZmZlcmVudCB2ZXJzaW9ucykuDQpf
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpsdXN0cmUtZGV2
ZWwgbWFpbGluZyBsaXN0Cmx1c3RyZS1kZXZlbEBsaXN0cy5sdXN0cmUub3JnCmh0dHA6Ly9saXN0
cy5sdXN0cmUub3JnL2xpc3RpbmZvLmNnaS9sdXN0cmUtZGV2ZWwtbHVzdHJlLm9yZwo=
