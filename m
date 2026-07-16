Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 3139CC44511
	for <lustre-devel@archiver.kernel.org>; Thu, 16 Jul 2026 15:21:22 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4h1GhC4N42z1xVT;
	Thu, 16 Jul 2026 08:10:51 -0700 (PDT)
Received: from outbound-ip191a.ess.barracuda.com
 (outbound-ip191a.ess.barracuda.com [209.222.82.58])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4h0zCL75m3z23NC
 for <lustre-devel@lists.lustre.org>; Wed, 15 Jul 2026 20:33:18 -0700 (PDT)
Received: from SA9PR02CU001.outbound.protection.outlook.com
 (mail-southcentralusazon11023135.outbound.protection.outlook.com
 [40.93.196.135]) by mx-outbound10-90.us-east-2a.ess.aws.cudaops.com
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Thu, 16 Jul 2026 03:32:57 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=zFmzBaAvddGsGB2lpYV0BObqrWgM/p1JKyPZu4Wf/rWYg0GEvI5REJ19pp2hDMhlDFZJo3c90X7/aa+SlwaVXJbumfQcJv8KxJ784IIyscQXfo2Smf8rLJ1HrsmE3C5PqzHZXoYS0w4LXWwkRWOoVmIdtb3mou1/kpMooSWgsrqd5HiEv02tXWpPsKPzgzX5VIdrPgVMhGJ2wBFIcJWbddzc+j/B8760e13vZjHWr3s0LYuaHrgEb0pSUGu4y8Z5P0PH5d1oV4kaNYYTsvzbCayneoOseFbQegVrZKZP0Kwn23mBPpTvhCPN2PQzbkx1LhikekFSdvORAd+4APksDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=BMBXeVAsQBNumQ9d0GAcIzf9kf7wpzqMQpdJHte//rQ=;
 b=s7KZ0KgLFqVqCuA7TpF+pBLUpbP5cN3QUbUlx6k43OB5R+llq8KdBb4V9WW4kNU0S/HQJQpymlVJTLPFd5jnxrDeHwyo+IQfZHM3DK/LYRlSBDhU//EKKfsCCX0igHJ3mLXeKoX8BSb9gxzqcrA5JUPAsSzvJNredrWDqsrWo0oCc4/hBz2jOSHct250I4K+0gwg3R2prtbEc4znnpr3R9hCnkkQSV0/tBdhULEetS7joFc8K2dVZfL4i+BGTSuIwj1HmTeqk0Bfc2ez4tnG70L+nl3DdAP44E8MajvXssPQO5Z5YRY6nwuSUTEDVlhEZovlmshbYp/ObOSLDBwOuw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=ddn.com; dmarc=pass action=none header.from=ddn.com; dkim=pass
 header.d=ddn.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ddn.com; s=selector2; 
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=BMBXeVAsQBNumQ9d0GAcIzf9kf7wpzqMQpdJHte//rQ=;
 b=S4vTltRL03WCr5zGI3f1NBCg3pfE8ypfsjiizJi51alqHwTOP6sR2Y83fVLKXIjuscCDDSlD2/QnsO5mjWaevxQRwzcVtGO0/lkmIoCB+zW+8OWvQFrz2CqL4onfwAeFdh3MBrOliK0eI3wp/HopFz7xb+SkvzQ/gu5efPttu7k=
Received: from LV3PR19MB8480.namprd19.prod.outlook.com (2603:10b6:408:215::17)
 by MW6PR19MB8084.namprd19.prod.outlook.com (2603:10b6:303:246::21)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.223.11; Thu, 16 Jul
 2026 03:32:52 +0000
Received: from LV3PR19MB8480.namprd19.prod.outlook.com
 ([fe80::92ec:1814:d9a3:246d]) by LV3PR19MB8480.namprd19.prod.outlook.com
 ([fe80::92ec:1814:d9a3:246d%5]) with mapi id 15.21.0202.014; Thu, 16 Jul 2026
 03:32:52 +0000
To: "adilger@thelustrecollective.com" <adilger@thelustrecollective.com>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: Reserve OBD_CONNECT2 flag for truncate(0) degraded layout replace
Thread-Index: AQHdFNBrD0w5S0wbxEKFkINsj4P6GQ==
Date: Thu, 16 Jul 2026 03:32:52 +0000
Message-ID: <LV3PR19MB8480BCD127068088198B9E07BDC72@LV3PR19MB8480.namprd19.prod.outlook.com>
Accept-Language: zh-CN, en-US
Content-Language: zh-CN
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
msip_labels: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=ddn.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: LV3PR19MB8480:EE_|MW6PR19MB8084:EE_
x-ms-office365-filtering-correlation-id: c80ded88-1903-4263-7e6c-08dee2eaeafa
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230040|1800799024|19092799006|10070799003|366016|376014|23010399003|11063799006|56012099006|18002099003|8096899003|10067099003|13003099007|38070700021;
x-microsoft-antispam-message-info: y+tXu6eJSTcyqUBqA70jGu+3Tez/6T+MCu03M34zEm793Qq5s303OamMWcIM9/SPZRp+Y1f1/SF2MAMMA91c0NIvOadVKtum7kJGiuyJkPNuQRLubEw8IUW8bt1tbnFlqlD23nV8VzDh4JaEigitlVkCFue1af1jZVxHc9zzZFA1Dtlm0tbZN+1ADUDg/quJD4Gq1YVcXk9LkkX8+P3rrzPy3e/2TzEedtwE09LKheRaRiEqFmPd/4i6Tt0aCg8Lor27fErmfr55Ed8Vpd9roLYhEQ/wZ96Bb3rz3/m3i3bhpPFyARh5On8syZadg50kLxg0FA3KCZlKBAOPq5i3iA6QCWOq8xnVjmu24O7E+FCjnpWPMwf0Rv/ZiVnjd6jNrXqOdcYA5X7kqFGgMp5KYk39G0x2P52LCGf6IKJkp7meY6fpM+hjFXWzXGv4cDbFcsgh6jFH07VTheKLleJmyJ1fH+ldCxGWR9MO6QGnipTWNSb0OPnI6IpMRGkhvJ2EZz35KqniyE05nhY8gVoQfKqSx2fCjc7hhgvlqsHgiIN1/4+ceEYfSccCjYcjH6P8S+THNCMyU6lZevj1UeonAvJGVjNX+uubQRZH6wIxcxLgVKvvV0bP1IctwonnZIijbwqm7UHx45lAWl1iHYV1pQJFsmVVahAebdzPQEX2ACc=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:zh-cn; SCL:1;
 SRV:; IPV:NLI; SFV:NSPM; H:LV3PR19MB8480.namprd19.prod.outlook.com; PTR:;
 CAT:NONE;
 SFS:(13230040)(1800799024)(19092799006)(10070799003)(366016)(376014)(23010399003)(11063799006)(56012099006)(18002099003)(8096899003)(10067099003)(13003099007)(38070700021);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?gb2312?B?azZmOHMvRkpHVlZ5WGdGNG5JYW9kUUZKUHdGYjBtRWJ2WmVycmNTakZTU1R2?=
 =?gb2312?B?M3BHTVphang5RHhLVFNBVVFnMXV5T3dqaXU0MGtYcDBJenFsTVVoaFh0N3RB?=
 =?gb2312?B?N0ZVY0dZNklpbzlJVUlMdUdUcHNMVXJFbUlOSGR3N0UvSmxGb052czc4Y0do?=
 =?gb2312?B?ZFpRYU1YNnJYNXhKazgva2tuNjVDQW45SURWbVZXZzN0NCtETXJjNUZxVHBY?=
 =?gb2312?B?MFZ6a1h0Nmtudjdnck1ERko2dlc3UmxEdFBQU2hpUTBkM3JFRitpQzZoUEF3?=
 =?gb2312?B?MzJPSngxKzZkZnMwMDRsTmFvZnlkK1l6MXNjTU9pa1NFRnlHVnF5QjJTRjhu?=
 =?gb2312?B?Y3RlakZtZ3R6Qm9sejJsWEpKcHR4RjZCS0dmME90bFYyd0J3alRDSHBpWXR0?=
 =?gb2312?B?TXBCK05XMW5EK2kwY1AxVU91QVEzay9RdytESzl6SHRTUGc2UjJJV0FtWk9P?=
 =?gb2312?B?dk5lU3pKN3h2UGIxZGVpTHUzVFl5K3NkYVZWb0V2Q3Vka3lPUDRpL3lycFpN?=
 =?gb2312?B?Y3d0VmR6STRDOXdMMmZSZjF3SkRpQW1tUTkxK3ZOenBhcjJpeGdMeWI4R2V6?=
 =?gb2312?B?MHU3bHJVOWJiRGx2aDJRRjNLKzBrRGVLTm9iVG51bWRyQUtBUFZsM3Foc2Q1?=
 =?gb2312?B?QW1iZmNCVVV4YjQxVTlwYUVnSEtvTzFvOUdhd0NMbi9iMG1nQVpkd1luZ3ZL?=
 =?gb2312?B?ZEhoa0lkTmhEL0gvS0VIdTlaZmNYNTIvNzgvZzNhdGRPUmo3NkR2Vm9NcGl5?=
 =?gb2312?B?SkFPbXdjME95bUZ2N2pERVR4MDJOT2dseHBCb09MUHUzN0tBU3VUcnUvQ3lD?=
 =?gb2312?B?NklWNEFUNDA5Q1pDWlE3eGRIVXpnU050Tm1Wek9mdmF4NzR3Q3BIL2VWVEhH?=
 =?gb2312?B?TUh4RVlDN0VueklEeWVuWDErZmRZMUxuM2VjL2IrT0VkNVRnSlk2dGRUNEVR?=
 =?gb2312?B?M1ZETGFRSkFnYVA3d1o5R3lRU1NQQUxBbUtFdVVZUm5ndDJXdXVMdzI4STJJ?=
 =?gb2312?B?bDFRMFAvUll4S0dTa2ZyRFRpazhwYmgxckxkVndZMDhydjk0T3dEWHBxNjVH?=
 =?gb2312?B?VlZ0UVhMU001QkthZFErTVRlVlhzT0hTZGdjcXlhWlVhT20wOGNDV0ZzNFJB?=
 =?gb2312?B?TnpUUkIyR0NGbE9wRTZlM2JPb2NDYmg3dDMvczc4RFZBODMzMU81bTd4ZG4v?=
 =?gb2312?B?NlJ5UHFxdU9QTEVlMTNCL1NzUGZQeUgxN3JzQVB6N1BvNmpLU2RWRWZTM0or?=
 =?gb2312?B?am4zekI3VHpIV1J4TVZtT2RPR2JUREVxUnl6MVJkQmZtSlZ5dHRaN251SG1J?=
 =?gb2312?B?d29Nd1RyTGVJcWppVTNqaExIMlBKUmNnR0gxdWtJenpJSkpYZ2QwQWxjWnNq?=
 =?gb2312?B?Zzllcnh6bUE3VGNoM2Ria1JXcDk2YnNpSHh2RkM2S2FFS1I3VWd0WERNQjVD?=
 =?gb2312?B?eDJRZy9halZoVDVxNHFRQ0pWanMzZEFmV0NUcjFhYSt2K2pqbzFHR0JGdWM2?=
 =?gb2312?B?TmVmRTFaNGZDbHNaaHJ4eVlIMXF2dERpck5TSkFYZitvNThhVkkza25OM2cx?=
 =?gb2312?B?MDlvOW95dmtFODk1SThGR2laZHU5WUN5MkVYRjZtdzdvckhiWUd6UEw3Q082?=
 =?gb2312?B?M2MrTjdvdms0WnNMUnludXpuMGlEYmlkb1FNWlJKZVZyelk4bUlTNHZYMmMw?=
 =?gb2312?B?L05lRDJpNXpOU0tNQk91dS9lRmNrNStja2xBdndIV3RPNkUzYVI0MFNEWGtZ?=
 =?gb2312?B?WGFsRExiZHdKSXlybThWTnhVWkRkOHZjQmd4a3I3bnd1SlRlWE5SMDl1ZklK?=
 =?gb2312?B?YytCcEpXVnJrMnl3Yk9RczJ4L1lCcEc5UHJnT3dLUHA2OGtma2k2S2ZxOUxr?=
 =?gb2312?B?c2tGdUs2VHl1YlBsY3huUkdDNEVJaWtlSENPL2Q0M1pBR3YxWXF3a3QvakxV?=
 =?gb2312?B?WExnT2gvajB6WlA4MG5PRVZPNjVyclpXc0c1RFFFdzNLZDRCSk1DNFZ5M3Q3?=
 =?gb2312?B?SDBEODNtTlVuY1h1dUJrOXhVZFlXUTdvd3d0YTdKektEYnFUZ2ZQQ2hlamtP?=
 =?gb2312?B?UEhnL0ZSaUluSnM1RXIrcDQvUlV5MFpQcUJNcWNPOG9wN2lpRFJxL0x6NDMx?=
 =?gb2312?B?RHl3NE41bnR6WncwNzl5UFR1emFDTUszVmJjRGlpQXNqWDljVFF5dit2YzJq?=
 =?gb2312?B?OGkwMjJlSkg1bDNBeWh1ZGxIYVdNSU03MjlQQmhrUGUzakxJVG0zU0lxa2p5?=
 =?gb2312?B?UTNIbFZXcTJRZUxlTXlrVDJqcmNBaEwvNlpsclBIUlV5VWpLZnZBNStJMHdh?=
 =?gb2312?B?RlorRWdMV1hqT0x0Z1hpdDJaWnJvRFVHWTVIY0RrS3lhaWV5RktwblpFaEV3?=
 =?gb2312?Q?guiSwKQUsLu4igNo=3D?=
MIME-Version: 1.0
X-Exchange-RoutingPolicyChecked: juwrrlXZUZOmuKdxq9pm9RnjXTqMSHKjRD2Gp1eDHyMZAxSTJCRSz1XZchAovmQxJAsj5Z3WXe+ocL0pvt2p7Dd9VCfmS8J5i3CeynlEqu1Xn4jfw8Q+oemsFN2Ccj1IjgeA2CVJObY+gPAH/DTGAjVlVMDgIJjn0scribSluPp41A8vg5gvisBgdciYFEB1iwKWCg1X66wtLsqhqMlC4XU+sXS8iPPa1Xb4q8celE+0es5VTq8bIZ/8gx8WgoWhxbWsPXNBFs+koZt99/hOyVEt9hmtWcZgqK19nHB7dvd9SivrCDDhmggreMT4htKoYUNwEExO05VckkTwq/+KOw==
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: 22+SXQmDzGnkYT0674db4EpmGTxF9xoRwJMDFK29c/t1I6uFfNMtPl/Ht5IlDc0rCY8QSsztv8oeAPV2ptQuHvpKc0qNWMX0TidC/kj/yYbmkqf0SgQspMduAWrRk7u6KZV9lCn5zStIPi4htU92kvKvNoPNN4Z1IB52TRdSF29iW+nH9ftCu6ah29StmI36u2EgFcnpcP5VB/3WbXpJYOVik8JptV9JfI+RVEtQEBWHcKBRcCS1VjvOeUgKPhW8y3DOjzGre6DFaBE3Hhfge3SlO7exoQrdiumflMV7UfmOll3OdQlCPgOZi018SsMMuZktiMrZB2DrBfClRJI82H6YMYr/B1MN0DjHazQyrWHcuCrJKEfD2jw+kJGpqUiLTPrtwCaSKTvSkKZqd78XzaGwQl1ynmkROMB+/sKOF26Ag2PhpmrPJ4Hh3x0W8Snvk1FNGj4yMPbwZiHG+GmUlXTYdPgThTBgoJRAFBSlXPlLueEVc+LmgvlTmb8kX1fsC014cx64/+aoazUI1Dypv8wsWxspAHtEPaeIuUU7S/FX//5E91HN6x/f/vRkcKaVuyPMQYpXlh++JV4Jtu7/zowdvt7Hhs94zIc78CQ2BWaL++vRRpk/oBtIdwD/rZVs4YNRwE06wvdCAjhcFaQHCw==
X-OriginatorOrg: ddn.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: LV3PR19MB8480.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c80ded88-1903-4263-7e6c-08dee2eaeafa
X-MS-Exchange-CrossTenant-originalarrivaltime: 16 Jul 2026 03:32:52.5581 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: BO4o51sKJsRq7BEzqI8rsolAPaP5IHM9V+ch9zCfNAKLM+kilE7Xe4dAZK1Do033
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MW6PR19MB8084
X-BESS-ID: 1784172777-102650-7720-33270-1
X-BESS-VER: 2019.1_20260702.2137
X-BESS-Apparent-Source-IP: 40.93.196.135
X-BESS-Parts: H4sIAAAAAAACAzXMMQ4CMQwEwL+4vgLbcXDuK4jCiR1dgyhIgYT4Oy6OZrVaaf
 b2gXgv2GFlbvB8wY7YNNuRI5baqxBz6ypF4uJ1sIW2QUydHL7b3x/rcfor1nb6MqZN8U
 7dNDwUZcR0a6ScN5b+/gMq0BaBgQAAAA==
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.274677 [from 
 cloudscan11-208.us-east-2a.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 HTML_MESSAGE           BODY: HTML included in message 
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.00 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=HTML_MESSAGE, BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
X-Mailman-Approved-At: Thu, 16 Jul 2026 08:08:41 -0700
Subject: [lustre-devel] Reserve OBD_CONNECT2 flag for truncate(0) degraded
 layout replace
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
From: Keguang Xu via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Keguang Xu <kxu@ddn.com>
Content-Type: multipart/mixed; boundary="===============7960146449628285450=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============7960146449628285450==
Content-Language: zh-CN
Content-Type: multipart/alternative;
	boundary="_000_LV3PR19MB8480BCD127068088198B9E07BDC72LV3PR19MB8480namp_"

--_000_LV3PR19MB8480BCD127068088198B9E07BDC72LV3PR19MB8480namp_
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64

SGkgQW5kcmVhcywNCg0KSSdkIGxpa2UgdG8gcmVzZXJ2ZSBhIG5ldyBPQkRfQ09OTkVDVDIgYml0
IGZvciBhbiB1cGNvbWluZyBmZWF0dXJlIChjdXJyZW50bHkgZHJhZnRlZCBhcyBPQkRfQ09OTkVD
VDJfTEFZT1VUX1JFUExBQ0VELCBtYXliZSAweDQwMDAwMDAwMDAwMFVMTCA/KS4NCg0KRmVhdHVy
ZQ0KUGxlYXNlIGNoZWNrIGh0dHBzOi8vamlyYS53aGFtY2xvdWQuY29tL2Jyb3dzZS9MVS0yMDIx
MSwgb24gdHJ1bmNhdGUoMCksIGlmIHRoZSBjdXJyZW50IGZpbGUgbGF5b3V0IGhhcyB1bmF2YWls
YWJsZS9kZWdyYWRlZCBzdHJpcGVzIChlLmcuIE9TVCBtYXJrZWQgZGVncmFkZWQpLCB0aGUgTURT
IG1heSByZXBsYWNlIHRoZSBsYXlvdXQgKG9ycGhhbiArIHN3YXBfbGF5b3V0cykgc28gdGhlIGNs
aWVudCBjYW4gY29udGludWUgd2l0aCBhIHVzYWJsZSBsYXlvdXQuIEFmdGVyIGEgc3VjY2Vzc2Z1
bCByZXBsYWNlLCB0aGUgc2V0YXR0ciByZXBseSByZXR1cm5zIHRoZSBuZXcgTE9WRUEuDQpUaGUg
Y2xpZW50IG11c3QgZGlzY2FyZCB0aGUgb2xkIHBhZ2UvT1NDIGNhY2hlIGR1cmluZyBsYXlvdXQg
YXBwbHksIGluc3RlYWQgb2YgZG9pbmcgQ0xfRlNZTkNfTE9DQUwgd3JpdGViYWNrIHRvIHRoZSBv
bGQgKHBvc3NpYmx5IGRlZ3JhZGVkKSBzdHJpcGVzLiBPdGhlcndpc2UgbGF5b3V0IGNoYW5nZSBm
YWlscyB3aXRoIC1FSU5WQUwsIHdoaWxlIHRoZSBNRFMgaGFzIGFscmVhZHkgY29tbWl0dGVkIHRy
dW5jYXRlICsgbGF5b3V0IHJlcGxhY2UuDQoNCldoeSBhIG5ldyBjb25uZWN0IGZsYWcgaXMgbmVl
ZGVkDQpUaGlzIGJlaGF2aW9yIHJlcXVpcmVzIGNvb3JkaW5hdGVkIGNsaWVudC9NRFMgc3VwcG9y
dDoNCg0KICAqICAgTmV3IE1EUyArIG9sZCBjbGllbnQ6IGlmIHRoZSBNRFMgcmVwbGFjZXMgdGhl
IGxheW91dCBhbnl3YXksIHRoZSBvbGQgY2xpZW50IHN0aWxsIHdyaXRlYmFja3Mgb24gbGF5b3V0
IGNoYW5nZSBhbmQgY2FuIGZhaWwgdHJ1bmNhdGUgd2l0aCAtRUlOVkFMLCBsZWF2aW5nIHNlcnZl
ci9jbGllbnQgc3RhdGUgaW5jb25zaXN0ZW50Lg0KICAqDQpXaXRoIGEgY29ubmVjdCBmbGFnLCB0
aGUgTURTIGNhbiBza2lwIGxheW91dCByZXBsYWNlIHVubGVzcyB0aGUgY2xpZW50IGFkdmVydGlz
ZWQgc3VwcG9ydCwgYW5kIHRoZSBjbGllbnQga25vd3MgdG8gZGlzY2FyZC1wcnVuZS4NCg0KVGhh
bmtzLA0KS2VndWFuZyBYdQ0KDQo=

--_000_LV3PR19MB8480BCD127068088198B9E07BDC72LV3PR19MB8480namp_
Content-Type: text/html; charset="gb2312"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dgb2312">
<style type=3D"text/css" style=3D"display:none;"> P {margin-top:0;margin-bo=
ttom:0;} </style>
</head>
<body dir=3D"ltr">
<div class=3D"elementToProof" style=3D"margin-top: 8px; margin-bottom: 8px;=
 font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helv=
etica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">
Hi Andreas,</div>
<div class=3D"elementToProof" style=3D"margin-top: 8px; margin-bottom: 8px;=
 font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helv=
etica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">
<br>
</div>
<div class=3D"elementToProof" style=3D"margin-top: 8px; margin-bottom: 8px;=
 color: rgb(0, 0, 0);">
<span style=3D"font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService,=
 Calibri, Helvetica, sans-serif; font-size: 12pt;">I'd like to reserve a ne=
w
</span><span style=3D"font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontS=
ervice, Calibri, Helvetica, sans-serif; font-size: 10pt;"><code>OBD_CONNECT=
2</code></span><span style=3D"font-family: Aptos, Aptos_EmbeddedFont, Aptos=
_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt;">
 bit for an upcoming feature (currently drafted as </span><span style=3D"fo=
nt-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helveti=
ca, sans-serif; font-size: 10pt;"><code>OBD_CONNECT2_LAYOUT_REPLACED,
</code></span><span style=3D"font-family: Aptos, Aptos_EmbeddedFont, Aptos_=
MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt;"><code styl=
e=3D"font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, =
Helvetica, sans-serif;">maybe</code></span><span style=3D"font-family: Apto=
s, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-serif;=
 font-size: 10pt;"><code>&nbsp;</code></span><span style=3D"font-family: mo=
nospace; font-size: 10pt;">0x400000000000ULL
 ?</span><span style=3D"font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFon=
tService, Calibri, Helvetica, sans-serif; font-size: 12pt;">).</span></div>
<div class=3D"elementToProof" style=3D"margin-top: 8px; margin-bottom: 8px;=
 font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helv=
etica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">
<b><br>
</b></div>
<div class=3D"elementToProof" style=3D"margin-top: 8px; margin-bottom: 8px;=
 font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helv=
etica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">
<b>Feature</b></div>
<div class=3D"elementToProof" style=3D"margin-top: 8px; margin-bottom: 8px;=
 font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helv=
etica, sans-serif; color: rgb(0, 0, 0);">
<span style=3D"font-size: 12pt;">Please check <a href=3D"https://jira.whamc=
loud.com/browse/LU-20211" target=3D"_blank" id=3D"OWA5e1e30d6-ab92-5f2f-6ab=
3-b224f17a6aa1" class=3D"fui-Link ___1q1shib f2hkw1w f3rmtva f1ewtqcl fyind=
8e f1k6fduh f1w7gpdv fk6fouc fjoy568 figsok6 f1s184ao f1mk8lai fnbmjn9 f1o7=
00av f13mvf36 f1cmlufx f9n3di6 f1ids18y f1tx3yz7 f1deo86v f1eh06m1 f1iescvh=
 fhgqx19 f1olyrje f1p93eir f1nev41a f1h8hb77 f1lqvz6u f10aw75t fsle3fq f17a=
e5zn OWAAutoLink" title=3D"https://jira.whamcloud.com/browse/lu-20211" rel=
=3D"noreferrer noopener">
https://jira.whamcloud.com/browse/LU-20211</a>, on truncate(0), if the curr=
ent file layout has unavailable/degraded stripes (e.g. OST marked degraded)=
, the
</span><span style=3D"font-size: 10pt;">MDS</span><span style=3D"font-size:=
 12pt;"> may replace the layout (orphan +
</span><span style=3D"font-size: 10pt;"><code>swap_layouts</code></span><sp=
an style=3D"font-size: 12pt;">) so the client can continue with a usable la=
yout. After a successful replace, the setattr reply returns the new
</span><span style=3D"font-size: 10pt;">LOVEA</span><span style=3D"font-siz=
e: 12pt;">.</span></div>
<div class=3D"elementToProof" style=3D"margin-top: 8px; margin-bottom: 8px;=
 font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helv=
etica, sans-serif; color: rgb(0, 0, 0);">
<span style=3D"font-size: 12pt;">The client must discard the old page/OSC c=
ache during layout apply, instead of doing
</span><span style=3D"font-size: 10pt;"><code>CL_FSYNC_LOCAL</code></span><=
span style=3D"font-size: 12pt;"> writeback to the old (possibly degraded) s=
tripes. Otherwise layout change fails with
</span><span style=3D"font-size: 10pt;"><code>-EINVAL</code></span><span st=
yle=3D"font-size: 12pt;">, while the
</span><span style=3D"font-size: 10pt;">MDS</span><span style=3D"font-size:=
 12pt;"> has already committed truncate + layout replace.</span></div>
<div class=3D"elementToProof" style=3D"margin-top: 8px; margin-bottom: 8px;=
 font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helv=
etica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">
<b><br>
</b></div>
<div class=3D"elementToProof" style=3D"margin-top: 8px; margin-bottom: 8px;=
 font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helv=
etica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">
<b>Why a new connect flag is needed</b></div>
<div class=3D"elementToProof" style=3D"margin-top: 8px; margin-bottom: 8px;=
 font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helv=
etica, sans-serif; color: rgb(0, 0, 0);">
<span style=3D"font-size: 12pt;">This behavior requires coordinated client/=
</span><span style=3D"font-size: 10pt;">MDS</span><span style=3D"font-size:=
 12pt;"> support:</span></div>
<ul>
<li style=3D"font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, C=
alibri, Helvetica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0); margin=
-top: 0px; margin-bottom: 0px;">
New <span style=3D"font-size: 10pt;" role=3D"presentation">MDS</span> + old=
 client: if the
<span style=3D"font-size: 10pt;" role=3D"presentation">MDS</span> replaces =
the layout anyway, the old client still writebacks on layout change and can=
 fail truncate with
<span style=3D"font-size: 10pt;" role=3D"presentation"><code>-EINVAL</code>=
</span>, leaving server/client state inconsistent.</li><li style=3D"font-fa=
mily: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, s=
ans-serif; font-size: 12pt; color: rgb(0, 0, 0); margin-top: 0px; margin-bo=
ttom: 0px;">
<div class=3D"elementToProof" role=3D"presentation">With a connect flag, th=
e <span style=3D"font-size: 10pt;">
MDS</span> can skip layout replace unless the client advertised support, an=
d the client knows to discard-prune.</div>
</li></ul>
<div class=3D"elementToProof" style=3D"margin-top: 8px; margin-bottom: 8px;=
 font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helv=
etica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">
<br>
</div>
<div class=3D"elementToProof" style=3D"margin-top: 8px; margin-bottom: 8px;=
 font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helv=
etica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">
Thanks,</div>
<div class=3D"elementToProof" style=3D"margin-top: 8px; margin-bottom: 8px;=
 font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helv=
etica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">
Keguang Xu</div>
<div style=3D"font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, =
Calibri, Helvetica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">
<br>
</div>
</body>
</html>

--_000_LV3PR19MB8480BCD127068088198B9E07BDC72LV3PR19MB8480namp_--

--===============7960146449628285450==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============7960146449628285450==--
