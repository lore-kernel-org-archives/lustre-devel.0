Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 641DECCF9F8
	for <lustre-devel@archiver.kernel.org>; Mon,  3 Nov 2025 23:16:22 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d0nVh1QJ9z1y22;
	Mon, 03 Nov 2025 15:15:08 -0800 (PST)
Received: from outbound-ip191b.ess.barracuda.com
 (outbound-ip191b.ess.barracuda.com [209.222.82.124])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d0nVR5C9jz1x2L
 for <lustre-devel@lists.lustre.org>; Mon, 03 Nov 2025 15:14:55 -0800 (PST)
Received: from BYAPR05CU005.outbound.protection.outlook.com
 (mail-westusazon11020083.outbound.protection.outlook.com [52.101.85.83]) by
 mx-outbound-ea18-75.us-east-2b.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Mon, 03 Nov 2025 23:14:52 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=xLq+YD+oIgUYm5bgRVgW03/Pw+M8SeUts4sF6ZKJkRtED4TA65h0jJjd3FpXdwC0vOR8Pu8ozZGWKZU4rA56mnDKM8BKtaGRdxLktlaA1n6rOLc4ku4bFgIYZ0doKbDAznEUQOcG6BkIpXOO1Ih9m7kd/JY5pHVGTAAQXn1XIAhPq33MI34YGrQYU2/EZs5qHm+z2Ca72dMbeIfYoPOo/+nb4/6H5QbcqWFu4DtU2WJjBdYcQBKwC2iYfJZyaOWhVyU6vU4Ea8r3mfH1PQpoXW6jN4OXSvu9Tivynf7TYL8KTPqQD+K9vwAxR9R0YSgNfCZcZJlCzZalaRxvqzHogQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=U8nNVXH10LLNhh6FabX5MtDuCbqzaGM7DaEiF7icYm0=;
 b=zRuRYidR9a/YOrTL0Q2ejei789kVz+rtD8Kz+9nJVmfSEq5hbzdCUlymBUKz5sb9PM7AzCcLSfSmfSlQQyuZyC3Ylx6jchhv6JpCJ9vhCWwPNNa5gr18IrA+xFeVcO47xwfw1lJOXqlCnNWFsFdhaPK0gRmWHEf9KDBaTA000I5GpUhD1l+vYOTNCqOTw+WQtGLCsnoiPwHcxmVBQR46z51beNFBUuwB9jw3UOEKwjkMC6kf+CM6mRaQ7R289IKrE7KwzpfOOERQO7vyKCzgHP4iwbo58eHcnP0f5jupE0yX6Vwt5zT3DxuObY0zTmFBT0LuZURtGXf25cxceHq1Fg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=U8nNVXH10LLNhh6FabX5MtDuCbqzaGM7DaEiF7icYm0=;
 b=sF0ryFqCUZ97wo7eB/gnAsZuL84hBZejrf/o6TWad+ZMY2MQ5XFO1IIY3kMjrDPFI4Xhb6rtn8SqP9NjaZlNxB6y66haPnV1E3oZQb2vD8lvMV+1MntPwJNIWth2TgLXPSY+cj8+UpV8MVKN6OfLrBCuz5t4adO04NHruJ1eAzQ=
Received: from DM3PPF12B913643.namprd19.prod.outlook.com
 (2603:10b6:f:fc00::70b) by CY8PR19MB7225.namprd19.prod.outlook.com
 (2603:10b6:930:95::12) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.9275.16; Mon, 3 Nov
 2025 23:14:48 +0000
Received: from DM3PPF12B913643.namprd19.prod.outlook.com
 ([fe80::1dae:cea7:3265:124e]) by DM3PPF12B913643.namprd19.prod.outlook.com
 ([fe80::1dae:cea7:3265:124e%7]) with mapi id 15.20.9275.015; Mon, 3 Nov 2025
 23:14:48 +0000
To: "timday@amazon.com" <timday@amazon.com>, Andreas Dilger
 <adilger@whamcloud.com>, "lustre-devel@lists.lustre.org"
 <lustre-devel@lists.lustre.org>, "jinshan.xiong@gmail.com"
 <jinshan.xiong@gmail.com>, Alex Zhuravlev <bzzz@whamcloud.com>
Thread-Topic: [lustre-devel] RFC: Spill device for Lustre OSD
Thread-Index: AQHcTQ1Fb2jVZEEEh0eTrPomJf0YLbThlTCA
Date: Mon, 3 Nov 2025 23:14:48 +0000
Message-ID: <e2c69a503e80f3ba59d69f093bc8df519cdd7f66.camel@whamcloud.com>
References: <CABoqRjtUuma_HLj7GK=2qUEWXV4XB11eEN6yj6svPtn-q+d4fw@mail.gmail.com>
 <CFE3C4C8-104E-4F7F-A52E-21B8957FAC0F@amazon.com>
In-Reply-To: <CFE3C4C8-104E-4F7F-A52E-21B8957FAC0F@amazon.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: DM3PPF12B913643:EE_|CY8PR19MB7225:EE_
x-ms-office365-filtering-correlation-id: 39f4b328-ba72-4f4e-71aa-08de1b2ec8b7
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|1800799024|366016|376014|38070700021;
x-microsoft-antispam-message-info: =?utf-8?B?dmpqcmVmcGNabHRxbkc3MDBrN2VBVlVrT0hvaGtGektPL1F6S01NbjVidnFq?=
 =?utf-8?B?bU1kTVBPTEorNEt0OFVhWUEzSVZjMUdpaXMvVmxORUdENjFDUi9scVh4ZlNQ?=
 =?utf-8?B?Yjk1TGRGamVsUGJpbkY3NmYxYkJkcXY0M01iZW8xU05WRUhuU2hXWjBXV1Bs?=
 =?utf-8?B?ajh6RytpeFJIK2p0OHBwSDZmM1N6R21EUjFqajh2MGduL2NyRm5nQjJVbHF1?=
 =?utf-8?B?T0JHWE1mV3JZR3hNMlpUK3RiTU03V0NqY09ucFU1aDN5QTFaZjZWbE8zcm1H?=
 =?utf-8?B?VkszQURVa3dSWmpxL0dSS3Iwb0d0Sm9QbmQ0WDBpZkZxQ1lmTndscGRFYzVr?=
 =?utf-8?B?dnN5WldsMFpqTXRaTG5mS3o4aWJNdno4LzN1d0FIMFJoeS8vMDJ5MTJ0Y25B?=
 =?utf-8?B?NkRvTnphc2pTRkdNYytsSWlrQ0ZYNURYcmlhT2pHOHcyNHE0OCtJQTUzS0ZL?=
 =?utf-8?B?MjQ5V2x2WFlxK1Bka0QvMnoyL01HSzN5MTMxVU8zNHdPVlQ0UXdGZHRpVjFz?=
 =?utf-8?B?M0xNSnJEUnE2VElyWUJpblQ4ckw3VmhkK0lqSlhQWWF0TUZ2MHRBclFHRTVL?=
 =?utf-8?B?cytiSUk1dE9HenhjZWowWFM1ZVU4WDFtNzNESFB1WWFWOGNyN0NwRjJOUFRO?=
 =?utf-8?B?ZnJFazNmY2RRTWphbHJIY3ZLYzJHTkNVS2puRGZVd3VLK1UwRlVuVzNtMmUy?=
 =?utf-8?B?WkVmMW53TkRlUVZxY2hmc3BvYXVlM0cxMHo4SGcvRW4vNjRyMnFSNjNEMGIz?=
 =?utf-8?B?YkxJZGt3b1luVm9US1NCQitUUzIrZGd4SytscXpLenAvL0pqRUdETjhIYlc3?=
 =?utf-8?B?VVNXWVBEZi9uODJOY0VTZlB0VldWdFdYcDBpYUtnTWNYbWl0SmxNUmVlS2Zi?=
 =?utf-8?B?QnVFTEhnbE9LNHZpS2pZSWkyZExKTURMdUlDTFdIek0vcWdJTk9aTGFEWUxm?=
 =?utf-8?B?dmlRU1Vjbk12SFVZRGU3aGtJNVAyci8zelpBaDZkS1J4N3pSRWxIazNxQllD?=
 =?utf-8?B?R3RITHJXM3RTVG41c0dVRjhuMjBPSmJzbTJ6WDBCNVRPT3JVVXdXTm9IRnYx?=
 =?utf-8?B?aUp1cjNxUnVQdWRJWko2bTJYVXhtZDZiZWtybU9KQVB3QzRWa3Jkb0hORWow?=
 =?utf-8?B?M0QvZGRVY1B3aFB6K2dOL3FhWnd4OXZJOGphR3RKTkxmUTArN2tHQ1p0R21G?=
 =?utf-8?B?R0JESHlqc1NtUjJkN0dlZVVISGV1UnJkU3JiNWJIODNYYkR4SnQ0SG9kUVo2?=
 =?utf-8?B?T0ZSWWgxYjVKenpKYUJWRTl2RHQrTWVYRHJKeDFMZ0l0V2NncU9jKzdXSkIy?=
 =?utf-8?B?L3FLUzBjZ3h4aWhoVTNUc1h6cWdzd3NTU0NJQmVrVUhaS0lnMFQwWFQyanNZ?=
 =?utf-8?B?TFMvb3hscUdORlV1UFladkdhZnZ3NXpaOXl5TWcyYU9DVlNFU0JzMVF2TGpX?=
 =?utf-8?B?Rm5qcnNlaFpvdkJSa0tmc3JxdytWc1piQlpLdmpDOFlJYlFJYjdETjR5TWNk?=
 =?utf-8?B?eWlTcGlHS3l4YnpXeEdlaDhpUzhIZTR6Mi94TjhMOCtoNFkwRGdXRUJDbVVO?=
 =?utf-8?B?SFF2cENhcTZ1Y29GK2VIWWd0S2ZxQTk0WWI4ckp0S1o1RkRiUzNLWFh1Tnh3?=
 =?utf-8?B?eXRLTU1DRW5pdUx0ZWlrbXdRMFlNWmVra3MvZVduL1dubWFOb1RvRkJtM0VQ?=
 =?utf-8?B?bm5JR2dtNERnbE8wak5OdHZsRTdtZmtiRmgyTkNWSEdRRTQ4cVpBU1FZYTlm?=
 =?utf-8?B?NE9HUGxtY1VSaW55cjcvQ212dWZQbWtoZ1VuTXNSc0ExWGNzSHZveGRDZnZk?=
 =?utf-8?B?dEppWXBKZDYraTlGdWE4dHEvYWpTQTcrSTJOMGV1Y25BUUJnU2VMbklBNmpO?=
 =?utf-8?B?SW5FMCtkRGpqQWhqem9WUGZ0TWdsdVJ2YmtRZytCSms1Vjh6MU14RnBqUDZz?=
 =?utf-8?B?bDA0a1UxS1pKV3VqYldSbWFjTFBuejV0ckVmMXQvUGlzRGVhT3dMa3ZRRXg3?=
 =?utf-8?B?MmlSUkNJbjZDeXdrK241S0JSMXU4TUkvRjJZYXpLRUZSQkc0NDhDRFdtWDcy?=
 =?utf-8?Q?X3XObU?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:DM3PPF12B913643.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(1800799024)(366016)(376014)(38070700021); DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?Y0JkTUNmWmNkMk5vRVNTWlJuSG1XdkFybE1nZlc2OU5sb2s0YmNhaENDNHEr?=
 =?utf-8?B?Qy95MVQ1WDBqeGdLRUNUSWhFQjl0Unp3bnZBNDB6ck1WVkthMm9OMjZTdzlT?=
 =?utf-8?B?dW1hNE1TU1FVNTliMzBNRjFTM012TFRsV0Z0UENRZmpOVXMxQUJkQks3WWVx?=
 =?utf-8?B?WGlCRnY0enNxOEZuUVVIVThLaWV4anIzT0RoOGdPRkw4aWtXYWtrNXF6L1JY?=
 =?utf-8?B?SVFUOER1M2pZU3NHR0Z3dDBJVlpaMGM4bGJaekFLY0QzUDB5ckFFdXpMc1Zq?=
 =?utf-8?B?RElMc0lyVEthWmFiMjd0ZFZuMW94cS9Uem5OSWJDUXFvaWtzdEFGd3RqMXFF?=
 =?utf-8?B?RjRGbEp3ZDRlNWQ4MjFCUk93cFZPU2RQOUxtL3V5dlFXaVYzaEU1eStvRTZW?=
 =?utf-8?B?ZFhDMjNwMzJXMG50alVCUTRUQ3M3LzQ3L2Q4UHp5VHhHeVRCb0pQb2laWThW?=
 =?utf-8?B?R05SOThYMzF5bG5rN2k1T0duL0JzdHQwM1ovN0l5Uk9PTHMxMldGbjg3UVhl?=
 =?utf-8?B?VkZlME02QmRPSVZEeGlkbHJ1a3ZMTytOYnlqMWhkUHJHeXFWeVI5NUhyME50?=
 =?utf-8?B?QndSdklaa3BzZlZDUTIzSGxnSlhtaTd5K2laREFldEdQa0xxbUVKczZMNFRm?=
 =?utf-8?B?Yk0vRnNleHFuT0hPWmV5cE53MGY2Y25VbndLa1l3eGtLNHZ0dVRLUlhXZE9x?=
 =?utf-8?B?STVaeHRXZDFqdVNqT0NOMUdjS0plV29vUlRUbFNmeVFaaG40OXVlMVhKUkg1?=
 =?utf-8?B?OHd0aG1kd3dVVCtLcjBpbWhzblByQ01xRnlESENZTUdQRGgxZ0wvbDZHS1M0?=
 =?utf-8?B?VHpNS2pia3RsQ3lOTW9QWUd1YU9tZFE4M3BrdU5hdy8rS1lTV1RQcndveDVw?=
 =?utf-8?B?eU54ZUU5Q1FDZGdJUFQ1cEd5MkpGM1lwQmRZODd5SVNPVDNBZElvM05UcHAx?=
 =?utf-8?B?WnhHZ3lBMitWR0pRNzl2QXZiNWQrMEQrRjhidzhpU2FGd2tIMVNHMDhkeVoy?=
 =?utf-8?B?bW1EYjRuK1ZXSFkyTm1mZ01MUnVkaEV0M2lBKzErcmJKSkVqNnBhNnlnVk9y?=
 =?utf-8?B?Y0dKYTIya0dtSHhHR0o0UVpuRDlVd2Zad0ZmYjBqbEhRNTl1K056Nk55eER6?=
 =?utf-8?B?NVA0ZmkzL0xYUHN4M2t3eXM3eFFMWXlUbW1MUEtkTnJIOFE3R0RJYTdYMzRo?=
 =?utf-8?B?MnI0aElFZEZ1WU5kVHl1cC9vRWFEeWlLdGRaOWlMZVpHekVtSHFJMmxkZHNa?=
 =?utf-8?B?aUZVYXVBaWIxOGtvTFZkbkNWQ0NoR0F6d1hUYTY2YkJkdVFWbmFDdXRDTTJx?=
 =?utf-8?B?djEvU0lBdGJUdkRRRzVpdTlDTmJ1bmhpd0JTb2dqbzNvLzJNTDUrSnZSaWVu?=
 =?utf-8?B?QXdkZllYeE9vZEcrYVF1dFI2bVR2N0lGZytkelErMk9rWmtaY1VieHNpTzNm?=
 =?utf-8?B?KzFKUFg3NEJBWkdnN05UakVqckxWaVlTWnRydEpHRnV4K3piYkc5c1lOem8x?=
 =?utf-8?B?bzd6cVA0WTRscXNMOFVXSlR1L3NkUkVxbm50dFN3a3B3UnZuWnk5SzhmeEMr?=
 =?utf-8?B?cU1xZC9MVWlqNk1rYkZrWXFLZzFPZlpXR29IbDJGcXhnSXM5blAvVk5nZ1Rt?=
 =?utf-8?B?TjNoZk1EaU1lTTA4OWowVzEzZ01LWTgyL1J4SzlpdmY3dTltanVlY3M4ck5O?=
 =?utf-8?B?Y09UeDlxYTVFVU9BT0M5UnYyRlI1cURLZ1JDd0QwTzUvZlluTHZ3L3l5NUFB?=
 =?utf-8?B?STFXb3VzVFVTNDRURjZHZEpDWFQxVTRDaVN5K1dxZkE5aEZjYlNMTmhSeGFm?=
 =?utf-8?B?UjNmVXQzSEJ6aHoxOWQvdURLN1p3UXN4dWt4RmJLSXU4ODY4Vjh1Z2xhMVd0?=
 =?utf-8?B?YU9QUVBwbWk3S2hnMUpnNkdOSmxLd1E4UUpjMCttQmpkSU1yRUpmZXdpSmd2?=
 =?utf-8?B?ZklRWVJiaC9rTlJqSmNnYVZJcXg4ZW1MTW9KVDlTMS9lSkpRZUcwNjdTd1ht?=
 =?utf-8?B?NFJ0OVI5NDN0K2o3RG1qQUJUa2NYeFEvUThPTHo0aGM4N243NS96bXdacWVk?=
 =?utf-8?B?aXFrbjRXMEVCaEFvNk1uRmpVTTFFcGNyOWlvU3BGeWNlYVhXbjJ5UVZnUEVq?=
 =?utf-8?Q?/p7RdJR42tLJHDY135WnNsht7?=
Content-ID: <6D25B8DBB3535D4E9784C7C8BB1C6437@namprd19.prod.outlook.com>
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: MSy/2WE+xR5awlEUGwOS9Xoi07tUqgp/urV+/kCcelOOFyukiCxtoyDn0xfixaK2ZWt3DfoBfSrk+cbi/GVznxs8rNONBNAsFbGZgQ9xftI37ZQBptXtGVO0TbSZmJlXUGJEi6sGJBu0yEupGFyWbuROB7CXleUkIlis2fePqc3bure05Y4a/jWaihHnHrmaHq5Ng6ALbmiE9OMAn4lShBn7IUL2tWXdEhShTgsLAHKllCKHlV8NSL7wQoDbl0PJ3eYNdstgcquxLzxdmYLsdGf1vaGR0LK9TrQ3ysKncVME73m/2y05IpD9Po/P60MvirVOhBdfUZjie+fSxfytWPP5KjLrKubAd9fSvStfikWXc7bhj9aTCRvKMN/W06Rmq+2B75KzSo8S0JUxC61nz0vHxEP24TQ9YVj3F30/WFsBGRQ5hFwEp37c2a1251ncLSbDujB3tbgVLJHldARR3+jP0VSxOwygZ3Cj66ZBkZEWhFqXepy6hKd97pkEIrsbie2jkX5mYjApgaY3W+s+AAJiug6okSszdJBmt6DLdsTSttrRTRo7Z3I0ie5245FBk4cogJbb91Wzr026uPBw5QjI6WDOlCkuhXgXyDP/g6jj1HkVVKyDpa/wCSpa4Y2uzvlmhq5EETwjTcHLwOJ/wA0joNYyI9EL2GeswFDy9RE=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: DM3PPF12B913643.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 39f4b328-ba72-4f4e-71aa-08de1b2ec8b7
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Nov 2025 23:14:48.2944 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: cUPpGNB+cVY4syX9HNWWbdPLcjtRl87l03/BrEKMEM/jaRLSkiiT+sPkNS1JpPh+
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CY8PR19MB7225
X-BESS-ID: 1762211692-104683-23126-23479-1
X-BESS-VER: 2019.3_20251103.1604
X-BESS-Apparent-Source-IP: 52.101.85.83
X-BESS-Parts: H4sIAAAAAAACA4uuVkqtKFGyUioBkjpK+cVKVoYW5hZAVgZQMNUsOcnE2NTSwi
 QxxcLQwMzCwsjMMtEoMcUgzdIoMdFEqTYWAO846WBBAAAA
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.268689 [from 
 cloudscan14-105.us-east-2a.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.00 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: Re: [lustre-devel] RFC: Spill device for Lustre OSD
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
From: Oleg Drokin via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Oleg Drokin <green@whamcloud.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

On Mon, 2025-11-03 at 21:59 +0000, Day, Timothy via lustre-devel wrote:
> 
> 
> This begs the question: if we're already doing this work to support
> writing Lustre objects to any arbitrary filesystem via VFS and we're
> only
> intending to support OSTs with this proposal, why not implement
> an OST-only VFS OSD and handle tiering in the filesystem layer?

The problem with pure VFS is it does not actually provide us what we
want.
So OSD talks to the underlying FS via VFS + some more stuff (we do have
the hidden mount for ldiskfs after all).
The "more stuff" is things like expanded transaction boundaries beyond
what posix requires so we can update more than one thing.
If Linux VFS provided all these abilities we would not need to really
know much about the underlying disk fs I suspect.

But currently it's just a way to add OSTs, not move objects laterally
from one OST to another and hence this proposal I imagine - where OSTs
would grow "warts" for less wanted data.

I am not sure it's a much better idea than the already existing HSM
capabilities we have that would allow you to have "offline" objects
that would be pulled back in when used, but are otherwise just visible
in the metadata only.
The underlying capabilities are pretty rich esp. if we also take into
account the eventual WBC stuff.

If the argument is "but OSTs know best what stuff is used" (which I am
not sure I buy, after all before you could use something off OSTs you
need to open a file I would hope) even then OSTs could just signal a
list of "inactive objects" that then a higher level system would take
care of by relocatiing somewhere more sensical and changing the layout
to indicate those objects now live elsewhere.

The plus here is you don't need to attach this "Wart" to every OST and
configure it everywhere and such, but rather have a central location
that is centrally managed.

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
