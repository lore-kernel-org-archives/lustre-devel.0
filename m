Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 788FDC369DC
	for <lustre-devel@archiver.kernel.org>; Wed, 30 Apr 2025 08:44:44 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZnW2f5Zqqz1xf4;
	Wed, 30 Apr 2025 01:44:42 -0700 (PDT)
Received: from outbound-ip191b.ess.barracuda.com
 (outbound-ip191b.ess.barracuda.com [209.222.82.124])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZnW2M6kKbz1xdc
 for <lustre-devel@lists.lustre.org>; Wed, 30 Apr 2025 01:44:27 -0700 (PDT)
Received: from NAM10-DM6-obe.outbound.protection.outlook.com
 (mail-dm6nam10lp2042.outbound.protection.outlook.com [104.47.58.42]) by
 mx-outbound23-128.us-east-2b.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Wed, 30 Apr 2025 08:44:25 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=n3jhm6TSjbjCLkP+vbsOPtzkb1PENJlCFFOiXZn3nW4/wpH1avFbguOEXdAic24kP/vi6tDDEaQ2GJGT61bbUlYtJNiHVGGFhcz/Ll4imSI33E6CYm4BMLA0IjIvwjIOm+XvmOEA2mu+VbGeUjp/U7BwdwvXZZr5gUuZRcgY++l/V4JzSlgfzrtbmypZhVw79I/zK6dWNGiw5d9zddImuu0I+X1JjxHXfAyM+AzQyw4tYRgUxuRLQXnmHptKo0l55aCDXW5Y4YvqHjxDpeRLntI2tYENRgeEKW26kYqMgVW3MP3SENAF724Ds7ic8YOBqQQ8/zookyJbkImT99j1sA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=xyzRETLzXXoatZNfJ6BxUq9eAcyeRkGeavIK+ziElj8=;
 b=vPfWKRwmNCEbjjrfbqkgQKF0BjujP/dUYwz5QF6ZuJxABmHSj9WZ7xddK/WgpuPnBI0A5I9ODkrE2/VJbyBBUw9s8EichzrliZZiD9/d9eR9iYczKgkA05IWwMXaWdf6NvhwKW6OZAuDXFLfP9dK3m0hkjoYq+0WdIjJc2zCnRHd17MfkyIReQ+TNvdTgHbaxDQOnZJH1sZc8zab8JHnsps8Cy803EeWKifc7JsoHv6bNEBka4z3gG69qWq4wR2hGt9UuW/bOQoooBn90++0AUMNkEvhUckV4fvtW7wtaZax0hKAaACme2DE299iWXS9Uz/lWZZQ1bIMhrSEc7vhmw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=ddn.com; dmarc=pass action=none header.from=ddn.com; dkim=pass
 header.d=ddn.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ddn.com; s=selector2; 
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=xyzRETLzXXoatZNfJ6BxUq9eAcyeRkGeavIK+ziElj8=;
 b=iTAN8PKhL94B5bYNsjExkoCWC8XNZMF7965YwgugGzKhrD3/waM0Hu5XT44btYfl+7wbuNIUxgZA77P1UOoNQYmlZnPzHTGB36/M6e3jystX2IUeAJWcPZRjDmlkv2KWcPQQA/KgcDGDNnvHY8B5Yf9El5nlApbHeIyjHRGdU5c=
Received: from MW4PR19MB5630.namprd19.prod.outlook.com (2603:10b6:303:189::12)
 by DM3PPF113084802.namprd19.prod.outlook.com (2603:10b6:f:fc00::70a)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8678.28; Wed, 30 Apr
 2025 08:44:21 +0000
Received: from MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::92fd:9b94:d9cd:81d2]) by MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::92fd:9b94:d9cd:81d2%5]) with mapi id 15.20.8699.012; Wed, 30 Apr 2025
 08:44:20 +0000
From: Andreas Dilger <adilger@ddn.com>
To: GEORGE ZHAO <georgezhaojobs@gmail.com>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: =?utf-8?B?W2x1c3RyZS1kZXZlbF0gTmV3IGNvbnRyaWJ1dG9yIGlucXVpcnkg4oCTIHN0?=
 =?utf-8?B?YXR1cyBvZiBMVS0xNjQzICjigJxyZXNlcnZlZCBzcGFjZeKAnSBpbiBzdGF0?=
 =?utf-8?Q?fs/df)_and_guidance_requested?=
Thread-Index: AQHbuWBdMjuMy7/D2k+hWVlMgxwYmrO75VQA
Date: Wed, 30 Apr 2025 08:44:20 +0000
Message-ID: <DC413C4A-68E7-4830-BAE7-ED34E094FCD1@ddn.com>
References: <CAFhHJgkiiieEWpva9wtgNzr1iWbbc494BWxK9=9sqdEVkHhTHA@mail.gmail.com>
In-Reply-To: <CAFhHJgkiiieEWpva9wtgNzr1iWbbc494BWxK9=9sqdEVkHhTHA@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3826.200.121)
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=ddn.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: MW4PR19MB5630:EE_|DM3PPF113084802:EE_
x-ms-office365-filtering-correlation-id: 4cdc1654-a49d-4579-5cec-08dd87c33388
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230040|1800799024|366016|376014|8096899003|13003099007|7053199007|3613699012|38070700018;
x-microsoft-antispam-message-info: =?utf-8?B?R2lSdUNnQWNEdkJOODR2SnUvSjJ3NGJMVEhOSHBuVzlrKytFNkVMNlZhZHBN?=
 =?utf-8?B?Y1hISldLOVRpUHBCcHlCdlJ6VCtDS2ZQelVpaGpNeFFacCtXWS9IMUFjd3Bt?=
 =?utf-8?B?SDRIcDdHc1llTklwbXV4WElYakxIb3hDWG9FQXVnaGgvckxYRWE2WW9FV09I?=
 =?utf-8?B?UGRtYXNtYmdrYTRFUlVObGdRdldTaE8zQUhMUnhTQXZFN2t5eFRDaCtMZUx1?=
 =?utf-8?B?QkV4eHM0WUdFai96NHFGV2VDd2tZZVhpNHFvdE5qN1pCcU1sTDJoVXY0d2FJ?=
 =?utf-8?B?Qk1pM2VDdVh1eWxVczRnV1hoVS9sN2pyUm5LSFQ4UkFrQXY4aHFqK2J1VEcv?=
 =?utf-8?B?VHp3bytYN01CbnZ2YWd6SzFsWGs4YXQwdDlZKzFLR0lrdEpXQ3BSUE52SlFM?=
 =?utf-8?B?QlJIazBJSDhhTUtRV1NDb3Roa1o2T21YajI5OUlpVk50VjFsaWpvVzJyYkJ0?=
 =?utf-8?B?UVhVUDdaY0MvRDV3TUJIUTROdEozYUpkUmltcFd3M3lnRS9rUzBDZXFMT1Q2?=
 =?utf-8?B?TUkzWXJsc1U5aUZNVFcyQW5ZZlZlWEZWdHJGMk4xY0JUVUdwcWttZlJPdlhr?=
 =?utf-8?B?ZXdDYmg2WVRFRUtjVWt3L21jZDNBYVR4SFFYekZQM1dHV2Y4MWFkVUpTYy8z?=
 =?utf-8?B?OE41TXJXQ1U3UnkrME83Um5GU2pTU2pIbjJrWDJ2d2VRbVdzSWtsV1grOE1K?=
 =?utf-8?B?cndFT2RDR2o0UjlpRGgxWUtqSzR2RVFLY3ZaODlobExZRzJtWlN0WnVOczJa?=
 =?utf-8?B?dDEveERuS3FEL3BRQ2xmSk11Kzd0cVpxQWpCamZiemtURmJxOXd5eVpEa2kx?=
 =?utf-8?B?L1JUZ254OGlCeFg5TENIaXd1QUlpQU1hQ21Qa212bXlsbzRwOWRrNkgwVVM1?=
 =?utf-8?B?c0JxM3RITGVVZVgzUWIzbXJEOTdwREdhSk1ZZkdPbERuYUd6ZUJjVnJxbHBn?=
 =?utf-8?B?V1YyWTRYWmhCdGtSWDc1VXFnU0cxc0JVMzRweXllZlI4WjRNS0pwYytCTklD?=
 =?utf-8?B?dHFCWWNVVVVtdExGdi9DdVdTdjBKQ1FBYUNBRW1MeVo2TDVneVEzemZCU1Bj?=
 =?utf-8?B?VGVvMUFyRmg4U2IxaTN4YnVxRUFNUnJhSW5GV1hoVTJCb3BDcjZZbzU0Z0U2?=
 =?utf-8?B?L09KTHdNc3c0SWV5QngxK2xySmc1eEp0V0xxeWRtWk1EMG95cXp2b0IxQzJG?=
 =?utf-8?B?R1p3d2hCWGp1ZmFjM3hwMi9TSHhUTmhQenhPU3BvZEFiSmZEQmJyWXZQbEtC?=
 =?utf-8?B?UHFvWmY1RkdnRGowQy9BSXRVcDNCRFYyM2VzN3Z3VmpHT2RFZ3BqOG9zY0JD?=
 =?utf-8?B?MDV1cHpHTnNuNnhuVTIyeTZta1ZsT2IxNW15TFU4T2Flayt3bzFtSC9LVVEy?=
 =?utf-8?B?RDRTVHpYV3R3YW9tRXI0S1VtVlZad0FzZGVqY3l3bDBZYjFMUnFPeXJOT1Rx?=
 =?utf-8?B?c3A3NVl5cCtRbU5jMkwrbjNCekgydkFiK1pUeFhiUUJnMnVtUzJWNi94OXlP?=
 =?utf-8?B?czM4WVZ4K1czZVdMRlgxYzEvV3dubTRHdU9acnMwcE9PcVp0bGJjTDQ4dGJ6?=
 =?utf-8?B?SnhpelkxM2dIQVpJMjdKWUpGL3pDMTZjWExqS3BJUUNpTFFFVmRqM3dZcTVo?=
 =?utf-8?B?QkIzNEY3RUMrejVHYVhleGZSOW4zUzEvZHhMM3puYTREeFlucm9SLzc0dkc3?=
 =?utf-8?B?a3pJUjhJOENoT2RVbk8xTUw0d3d1RkxqL1RwUXFlSXkwNGVKNFpWZkJmbCtN?=
 =?utf-8?B?NUZMQk9XeWNZRU93YUV1TWE4TDlsWFpyZlNDWHV4VEhBNzFoL0QzY2NXTHZr?=
 =?utf-8?B?Zm9XNlU5WEgzdVJ2dTNUYUZ0ZE0wOTl0K1Z2by9qKzRQbTgxVEw4S2RBTEFJ?=
 =?utf-8?B?a2d2WWE3QU9mMC8rY3htc1EwdWI4OTNPTDNSN3Z2M2VkaVNZb3hkUUZtL01o?=
 =?utf-8?Q?3P843A63bKDVmk60E4PZcc0rpRNXXvqL?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MW4PR19MB5630.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(1800799024)(366016)(376014)(8096899003)(13003099007)(7053199007)(3613699012)(38070700018);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?RjZYZ1p6SmExTCs2dGFPaXlKNHh6TS9La0dPVmptaklxTzUzSVV5djFnVGdB?=
 =?utf-8?B?L0MzbXRFWkhZTFZUUDZhdTlyZmQyQ09MVzRlSUZVaFlpOWlSa29HcDFrRWNN?=
 =?utf-8?B?TjVPN09WTmJkM2pPRGFkUFVITXVVQVJiT0FHb040U1FvcXZqaDh3MnArRFZu?=
 =?utf-8?B?OXFVR2pnNUFWaTExZ2pJQWRFRE5jeU1xUGltc0N1TFNoTDBUMEJGaTRZeVNz?=
 =?utf-8?B?SDgwcXJmdHFIUmRBTW5xQzJIcDhHc3Y4bldCZUVYMnpudVlLR29UQXhkZGFK?=
 =?utf-8?B?Q0VqdWxXTy9qbExTSlEyUUpUZWdBR3lIbC9STzcyY3lFeGhTdE56UmNaQmkx?=
 =?utf-8?B?QVpzUzRmb1p6Q3p5YTJxUlJJV2ExMFhRNXRCYzlZNENva0hTRFVMcWQ2QU9V?=
 =?utf-8?B?NFNBWXJ5VnFNZ21US1lZa3MzOFhpVXJqWlhwTEphUkV5dUZDZFhkZG9ZanBN?=
 =?utf-8?B?L0tYNC9jRk52cWcydS9aTldjRFZlQXFycXpadFE4VGRuQkxRZFdMS3RzRTRZ?=
 =?utf-8?B?Znd2MFcvQmlYQWwzWFp1QnVOMTNZWU9CcUFKZGp6YVZkM0FTd1Uyd2l4TFpt?=
 =?utf-8?B?TVVmQzluZG9BUFpObGVDYmhaeXY0VG9JVWtvSFN6cVd2SWZIWDlRNW1OUUQx?=
 =?utf-8?B?bzI0S0FtblpSZkVncmhJTjJRbzd1WXdYcnZMQlI5akN1dUpNZGh1alRyaUZ3?=
 =?utf-8?B?ZFowWGJWR1k4Mk1RcmFLeGxzUHJHTHFrNlJGYXlMSS9XeFBydlRoV1oyVmdr?=
 =?utf-8?B?M2toRnBhYmtQK2ZLVGZPb1FjT2xTMitGZnNRR3NyRFhBdDRWcStkTkx6RTJs?=
 =?utf-8?B?S1pXeUFLbFk1UG1pMzJrYTh6QjltdGNqL2Fvc3VNRG1wNE9oRnhVbms2VWVa?=
 =?utf-8?B?Yklab1RvSVlnUTFIU2YrQ3NpeUZIRHVTYlpSbVBWaHVraE5tcCtMMi9BU2R0?=
 =?utf-8?B?OUtvOEV2MnJvelN1bWVIQ1pUeHYzRCtRc0ZuZlE3N094Wi80R1h0cVNzd3M4?=
 =?utf-8?B?bktKNTZpd3cvQ2lRZ3R1c2JuT2h1aVJMMFlEWitEMWFsQkRrYkRlZkE5cG10?=
 =?utf-8?B?WEZVOU01ODFPbVRLMVFtelBsRVVWNUp4WjJ0UXRPekdDSGRESkpndVpBdnZv?=
 =?utf-8?B?REx3dmU3UktZUGdPZURPbE5VQkNEOTBvbGh1ejE4K2N5bGZ4OXBmSHRKYklS?=
 =?utf-8?B?dlgrcWZOQ2hrejBoSVF5SFh2SkdmbFVjMkVnVTB0VnlTRHZXaUZpdk00R0Nk?=
 =?utf-8?B?MEt1SWtseVJZc1VLNU5Pa1l2SDc5UjlSTytQQnBmci81U05QU3pUeUdCSjhC?=
 =?utf-8?B?RVk3cU92VVF1VlBsQXhlWXloRXhQeU12QzBiOG9lSDRvRUh0TGk3L3JXQkVF?=
 =?utf-8?B?MFlFeGJjSXVrR2Ziejl6d2tFUEtmNkJWN0NiZHlhTUdON2FPWko5SHFiVXRa?=
 =?utf-8?B?SUVpQ2ZPMlhRNytuTG11QjF3Nmh0WktvaFdRQ2lsRzVFUVM0YzB5TTB1UENX?=
 =?utf-8?B?NklmMVR6cTBOdSttRTJveWd0YVlyOXRpOHJnajkxR3pyR0l0S1ZrYVJDS2Ny?=
 =?utf-8?B?cTZlYWV2b1V3MW4yd25tcmUrZTFFeTRJTDhLTVRoRi9VNFpTVHN5b1ZneGxm?=
 =?utf-8?B?ek54VXZmNlVuamdOSGd0ZmMrUzJWN0hsODRzK3NlK2dSQjZZSm9LY1c4WjBp?=
 =?utf-8?B?UGtieE4wdzJNY0R2ZjF5OFFlL2xMZVBwYjhkMHpianArcitZYmZacm8yL1Qv?=
 =?utf-8?B?NGFHOEJnaDRjSnliZmdWT1U5TjVUdTJOVVVxeVBKWDRSV005QS9xTnVMZTN3?=
 =?utf-8?B?Ym5jb0l6ZDBtQ1o2L2kwckc3OE54dmZ1OGc5bExiam9nTWtyR3Roc2h3WEhY?=
 =?utf-8?B?cHVoUnZpVkxPenl3U0FjZFIwa3h6WTU3M1VFRm8yd3VTSEl4SXd3Y2ttcjh4?=
 =?utf-8?B?OVJKRGtsSlVqRG9BZXpBT3hpamYrS3VNVWdBMTF6NTFDVjllYmszWExZVDE2?=
 =?utf-8?B?TnhETGxwTDhkUElDbHpFU2dCNXdQclVlaGlSRHBWM3M2ZU9TVlp3Yit0bUI0?=
 =?utf-8?B?a0g0bmJnK0ZwQUFkR3pDNTZQVkl6dTVXckM4aXlaRnJvZU9VbW5KTlJqeUUr?=
 =?utf-8?Q?CsSZmrM297Fomzkr4d4B3AwK+?=
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: PtezjWZs4sapJfSI4eb5jVUcpg/pNAWrFfBqNu+DgOdOkuj4q9VAdiG1WYHYd/37OPw/pY5XAs7AUS2kdTWbCP9QoiGYT8nbctBP6Ph7W/CQ1lQU48x7LFd5K76WXXNX9/bYj3PtixJk8i8rW8LQjTrQ6U/WJavZPBY66RSvYTQ0kyhPvfQ+P5BxeW3Sb0agWePPYOshLNr/aZyOeGR1P6hGr963H606LU8bi13q59h5Xd7q38UPo3jEBRi5gsr0lmYrfg+kvplqjYbFXFSqXmuB4ACqXAW/E8uJkHFHKJAPftJAfbuB+QdDsdlm3eOkFS8MleRDFvn45EQa0zJlQNU6z1fmsNXlezO9V5POfyLJX4veCqD//L1fZXFuZ3y6PlNuJXTTp/X9fxWxLRyKzHbxiF658sq1TuGdgEbC85Jx5B5JPuNgjFvjGdSRedHCc7Nm/W14ahmslolXZmDpC13+mfGmimLFLG471VsZ5SU3wrcGm9ve5byWKOxPTWsrx3u0B98kV4FsLkx0+G/G8p9GUrzejFAqn64px3buIB8RlRLe/U++gF+jY25VQ8eLs686YjRWrTLk0VUksQp3LSQ/Yyijh8JsxI+lvUxcGcucCEXReyL9JT3YCP+3S06fgcxpnMHZUdPo3rv3ZsBrrQ==
X-OriginatorOrg: ddn.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MW4PR19MB5630.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 4cdc1654-a49d-4579-5cec-08dd87c33388
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Apr 2025 08:44:20.8966 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: eTs9vvzWjLofg5EbccT2GbKUCRvOAK+X7Hjd7DSRuyUs0OPUhUneNSSobSg4PeW0
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM3PPF113084802
X-BESS-ID: 1746002665-106016-7603-2842-1
X-BESS-VER: 2019.1_20250429.1615
X-BESS-Apparent-Source-IP: 104.47.58.42
X-BESS-Parts: H4sIAAAAAAACAzXLuwqAMAyF4XfJ7BBjGlNfRRyaXnARBzsI4rvbwS6HnwPf+k
 C+KyxQ2w5wXrAQe2y1t1MsasRAidghYkk8+5JTmXRUE2N4h+73evyenes+BlUZPelUbG
 YJmdFECYWQKQrBu313F1ZMgQAAAA==
X-BESS-Outbound-Spam-Score: 0.10
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.264255 [from 
 cloudscan10-131.us-east-2a.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 HTML_MESSAGE           BODY: HTML included in message 
 0.10 BSF_SC0_SA085          META: Custom Rule SA085 
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.10 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=HTML_MESSAGE, BSF_SC0_SA085, BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: Re: [lustre-devel] 
 =?utf-8?q?New_contributor_inquiry_=E2=80=93_statu?=
 =?utf-8?q?s_of_LU-1643_=28=E2=80=9Creserved_space=E2=80=9D_in_statfs/df?=
 =?utf-8?q?=29_and_guidance_requested?=
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
Content-Type: multipart/mixed; boundary="===============5875053761732150530=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============5875053761732150530==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_DC413C4A68E74830BAE7ED34E094FCD1ddncom_"

--_000_DC413C4A68E74830BAE7ED34E094FCD1ddncom_
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64

SGkgR2VvcmdlLA0KdGhhbmtzIGZvciB5b3VyIGludGVyZXN0LiAgVGhlcmUgYXJlIGRlZmluaXRl
bHkgYSBudW1iZXIgb2Ygb3BlbiB0aWNrZXRzIGluIHRoZSAiZWFzeSIgKGFuZCAibWVkaXVtIikg
Y2F0ZWdvcmllcyB0aGF0IHlvdSBjb3VsZCB3b3JrIG9uLCB0aG91Z2ggdGhlcmUgaGF2ZSBiZWVu
IGEgbnVtYmVyIG9mIGludGVybnMgYW5kIG5ldyBoaXJlcyB3b3JraW5nIG9uIHRob3NlIHRpY2tl
dHMgcmVjZW50bHkgYW5kIGZld2VyIGFyZSBub3cgYXZhaWxhYmxlLg0KDQpMVS0xNjQzIGhhcHBl
bnMgdG8gYmUgdGhlIG9sZGVzdCAiZWFzeSIgdGlja2V0LCBidXQgZG9uJ3QgbGV0IHRoYXQgZ3Vp
ZGUgeW91ciBzZWxlY3Rpb24uICBJIHdvdWxkIHN1Z2dlc3QgeW91IHRha2UgYSBsb29rIHRocm91
Z2ggdGhlIHdob2xlIGxpc3QgYW5kIHBpY2sgc29tZXRoaW5nIHRoYXQgaXMgb2YgaW50ZXJlc3Qg
dG8geW91IGFuZC9vciBtYXRjaGVzIHlvdXIgZXhwZXJpZW5jZSBsZXZlbC4NCg0KLSBMVS0xNjcz
ODxodHRwczovL2ppcmEud2hhbWNsb3VkLmNvbS9icm93c2UvTFUtMTY3Mzg+IC0gSW1wcm92ZSBt
b3VudC5sdXN0cmUgd2l0aCBtYW55IE1HUyBOSURzPGh0dHBzOi8vamlyYS53aGFtY2xvdWQuY29t
L2Jyb3dzZS9MVS0xNjczOD46IHRoaXMgaXMgcGFydGx5IGEgdXNlcnNwYWNlIChtb3VudC5sdXN0
cmUpIGNoYW5nZSBhbmQgcGFydGx5IGluIHRoZSBrZXJuZWwgKHRob3VnaCBub3QgaW5jcmVkaWJs
eSBjb21wbGV4KS4gIFRoaXMgaXMgYWN0dWFsbHkgaW4gdGhlICJ1c2VmdWwiIGNhdGVnb3J5IHRo
YXQgcHJvdmlkZXMgaW1wcm92ZWQgZnVuY3Rpb25hbGl0eSBmb3Igc29tZXRoaW5nIHRoYXQgaXMg
c2VlbiByZWd1bGFybHkuDQoNCg0KSWYgeW91IGFyZSBmZWVsaW5nIG1vcmUgYWR2ZW50dXJvdXMs
IHlvdSBtaWdodCBsb29rIGF0IG9uZSBvZiB0aGUgIm1lZGl1bSIgdGlja2V0cywgd2hpY2ggbWF5
IG5vdCBiZSB0b28gZGlmZmljdWx0Og0KLSBMVS03ODgwPGh0dHBzOi8vamlyYS53aGFtY2xvdWQu
Y29tL2Jyb3dzZS9MVS03ODgwPiAtIGFkZCBPU1QvTURUIHBlcmZvcm1hbmNlIHN0YXRpc3RpY3Mg
dG8gb2JkX3N0YXRmczxodHRwczovL2ppcmEud2hhbWNsb3VkLmNvbS9icm93c2UvTFUtNzg4MD46
ICB0aGlzIGlzIGEgdmVyeSB1c2VmdWwgZmVhdHVyZSB0aGF0IHdvdWxkIGFsbG93IGNsaWVudHMv
dXNlciBhcHBsaWNhdGlvbnMgdG8gcHJvYmUgdGhlIElPIGxvYWQgb24gT1NUcywgYW5kIHNlbGYt
b3B0aW1pemUgY2hlY2twb2ludCBJTyB0byB0aW1lcyB3aGVuIHRoZSBPU1RzIGFyZSBsZXNzIGJ1
c3kNCi0gTFUtMTMxMjM8aHR0cHM6Ly9qaXJhLndoYW1jbG91ZC5jb20vYnJvd3NlL0xVLTEzMTIz
PiAtIEFkZCBsaXN0IG9mIGNsaWVudCBOSURzIHRvIGpvYl9zdGF0cyBvdXRwdXQ8aHR0cHM6Ly9q
aXJhLndoYW1jbG91ZC5jb20vYnJvd3NlL0xVLTEzMTIzPjogdGhpcyB3b3VsZCBhc3NvY2lhdGUg
YWxsIG9mIHRoZSBjbGllbnRzIHRoYXQgYXJlIGNvbnRyaWJ1dGluZyB0byB0aGUgam9iX3N0YXRz
IGZvciBhIHNwZWNpZmljIEpvYklELCBhbmQgd291bGQgYmUgdXNlZnVsIGZvciBkZWJ1Z2dpbmcg
YW5kIG1vbml0b3JpbmcvDQoNCk9uIEFwciAyOSwgMjAyNSwgYXQgMTc6NDEsIEdFT1JHRSBaSEFP
IDxnZW9yZ2V6aGFvam9ic0BnbWFpbC5jb20+IHdyb3RlOg0KDQpJJ20gYSBzdG9yYWdlIGVuZ2lu
ZWVyIGFuZCBhIEx1c3RyZSBiZWdpbm5lciB3aG8ganVzdCBmaWd1cmVkIG91dCBob3cgdG8gZGVw
bG95IGl0LiBEaWQgcmVhZCBhIGxvdCBhYm91dCBpdCB0aG91Z2guDQpNeSBnb2FsIGlzIHVzaW5n
IEx1c3RyZSB0byBzdXBwb3J0IEhQQy9NTCB3b3JrbG9hZC4gQW5kIEkgYmVsaWV2ZSBkb2luZyBz
b21lIHRhc2tzIHdvdWxkIGhlbHAgbWUgcHJvY2VlZCBiZXR0ZXIuDQoNCkFzIHdpa2kgc3VnZ2Vz
dGVkLCBJIGZvdW5kIGFuICJlYXN5IiB0aWNrZXQgTFUtMTY0Mzog4oCcUmVxdWVzdCB0byByZW1v
dmUgZGlzcGxheSBvZiByZXNlcnZlZCBzcGFjZSBmcm9tIHN0YXRmcyAoZGYpIHRvdGFsIHNwYWNl
LuKAnQ0KSXMgaXQgc3RpbGwgdW5jbGFpbWVkPw0KSWYgaXQncyBhbHJlYWR5IGluIHByb2dyZXNz
LCBvciB0aGVyZSdzIGEgaGlnaGVyIHByaW9yaXR5IGlzc3VlIHRoYXQgY291bGQgdXNlIGhlbHAs
IHBsZWFzZSBwb2ludCBtZSBpbiB0aGUgcmlnaHQgZGlyZWN0aW9uLg0KDQpUaGFua3MgaW4gYWR2
YW5jZSBmb3IgYW55IGFkdmljZS4NCg0KQmVzdCByZWdhcmRzLA0KR2VvcmdlDQpfX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXw0KbHVzdHJlLWRldmVsIG1haWxp
bmcgbGlzdA0KbHVzdHJlLWRldmVsQGxpc3RzLmx1c3RyZS5vcmcNCmh0dHA6Ly9saXN0cy5sdXN0
cmUub3JnL2xpc3RpbmZvLmNnaS9sdXN0cmUtZGV2ZWwtbHVzdHJlLm9yZw0KDQpDaGVlcnMsIEFu
ZHJlYXMNCuKAlA0KQW5kcmVhcyBEaWxnZXINCkx1c3RyZSBQcmluY2lwYWwgQXJjaGl0ZWN0DQpX
aGFtY2xvdWQvRERODQoNCg0KDQoNCg==

--_000_DC413C4A68E74830BAE7ED34E094FCD1ddncom_
Content-Type: text/html; charset="utf-8"
Content-ID: <56B4B9D521E58042BD892EE248B733AD@namprd19.prod.outlook.com>
Content-Transfer-Encoding: base64

PGh0bWw+DQo8aGVhZD4NCjxtZXRhIGh0dHAtZXF1aXY9IkNvbnRlbnQtVHlwZSIgY29udGVudD0i
dGV4dC9odG1sOyBjaGFyc2V0PXV0Zi04Ij4NCjwvaGVhZD4NCjxib2R5IHN0eWxlPSJvdmVyZmxv
dy13cmFwOiBicmVhay13b3JkOyAtd2Via2l0LW5ic3AtbW9kZTogc3BhY2U7IGxpbmUtYnJlYWs6
IGFmdGVyLXdoaXRlLXNwYWNlOyI+DQpIaSBHZW9yZ2UsDQo8ZGl2PnRoYW5rcyBmb3IgeW91ciBp
bnRlcmVzdC4gJm5ic3A7VGhlcmUgYXJlIGRlZmluaXRlbHkgYSBudW1iZXIgb2Ygb3BlbiB0aWNr
ZXRzIGluIHRoZSAmcXVvdDtlYXN5JnF1b3Q7IChhbmQgJnF1b3Q7bWVkaXVtJnF1b3Q7KSBjYXRl
Z29yaWVzIHRoYXQgeW91IGNvdWxkIHdvcmsgb24sIHRob3VnaCB0aGVyZSBoYXZlIGJlZW4gYSBu
dW1iZXIgb2YgaW50ZXJucyBhbmQgbmV3IGhpcmVzIHdvcmtpbmcgb24gdGhvc2UgdGlja2V0cyBy
ZWNlbnRseSBhbmQgZmV3ZXIgYXJlIG5vdyBhdmFpbGFibGUuPC9kaXY+DQo8ZGl2Pjxicj4NCjwv
ZGl2Pg0KPGRpdj5MVS0xNjQzIGhhcHBlbnMgdG8gYmUgdGhlIG9sZGVzdCAmcXVvdDtlYXN5JnF1
b3Q7IHRpY2tldCwgYnV0IGRvbid0IGxldCB0aGF0IGd1aWRlIHlvdXIgc2VsZWN0aW9uLiAmbmJz
cDtJIHdvdWxkIHN1Z2dlc3QgeW91IHRha2UgYSBsb29rIHRocm91Z2ggdGhlIHdob2xlIGxpc3Qg
YW5kIHBpY2sgc29tZXRoaW5nIHRoYXQgaXMgb2YgaW50ZXJlc3QgdG8geW91IGFuZC9vciBtYXRj
aGVzIHlvdXIgZXhwZXJpZW5jZSBsZXZlbC48L2Rpdj4NCjxkaXY+PGJyPg0KPC9kaXY+DQo8ZGl2
Pi0mbmJzcDs8YSBjbGFzcz0iaXNzdWUtbGluayIgZGF0YS1pc3N1ZS1rZXk9IkxVLTE2NzM4IiBo
cmVmPSJodHRwczovL2ppcmEud2hhbWNsb3VkLmNvbS9icm93c2UvTFUtMTY3MzgiIGlkPSJrZXkt
dmFsIiByZWw9Ijc1NTgyIj5MVS0xNjczODwvYT4mbmJzcDstJm5ic3A7PGEgY2xhc3M9Imlzc3Vl
LWxpbmsiIGRhdGEtaXNzdWUta2V5PSJMVS0xNjczOCIgaHJlZj0iaHR0cHM6Ly9qaXJhLndoYW1j
bG91ZC5jb20vYnJvd3NlL0xVLTE2NzM4Ij5JbXByb3ZlIG1vdW50Lmx1c3RyZQ0KIHdpdGggbWFu
eSBNR1MgTklEczwvYT46IHRoaXMgaXMgcGFydGx5IGEgdXNlcnNwYWNlIChtb3VudC5sdXN0cmUp
IGNoYW5nZSBhbmQgcGFydGx5IGluIHRoZSBrZXJuZWwgKHRob3VnaCBub3QgaW5jcmVkaWJseSBj
b21wbGV4KS4gJm5ic3A7VGhpcyBpcyBhY3R1YWxseSBpbiB0aGUgJnF1b3Q7dXNlZnVsJnF1b3Q7
IGNhdGVnb3J5IHRoYXQgcHJvdmlkZXMgaW1wcm92ZWQgZnVuY3Rpb25hbGl0eSBmb3Igc29tZXRo
aW5nIHRoYXQgaXMgc2VlbiByZWd1bGFybHkuPC9kaXY+DQo8ZGl2Pjxicj4NCjwvZGl2Pg0KPGRp
dj48YnI+DQo8L2Rpdj4NCjxkaXY+SWYgeW91IGFyZSBmZWVsaW5nIG1vcmUgYWR2ZW50dXJvdXMs
IHlvdSBtaWdodCBsb29rIGF0IG9uZSBvZiB0aGUgJnF1b3Q7bWVkaXVtJnF1b3Q7IHRpY2tldHMs
IHdoaWNoIG1heSBub3QgYmUgdG9vIGRpZmZpY3VsdDo8L2Rpdj4NCjxkaXY+LSZuYnNwOzxhIGNs
YXNzPSJpc3N1ZS1saW5rIiBkYXRhLWlzc3VlLWtleT0iTFUtNzg4MCIgaHJlZj0iaHR0cHM6Ly9q
aXJhLndoYW1jbG91ZC5jb20vYnJvd3NlL0xVLTc4ODAiPkxVLTc4ODA8L2E+Jm5ic3A7LSZuYnNw
OzxhIGNsYXNzPSJpc3N1ZS1saW5rIiBkYXRhLWlzc3VlLWtleT0iTFUtNzg4MCIgaHJlZj0iaHR0
cHM6Ly9qaXJhLndoYW1jbG91ZC5jb20vYnJvd3NlL0xVLTc4ODAiPmFkZCBPU1QvTURUIHBlcmZv
cm1hbmNlIHN0YXRpc3RpY3MgdG8gb2JkX3N0YXRmczwvYT46DQogJm5ic3A7dGhpcyBpcyBhIHZl
cnkgdXNlZnVsIGZlYXR1cmUgdGhhdCB3b3VsZCBhbGxvdyBjbGllbnRzL3VzZXIgYXBwbGljYXRp
b25zIHRvIHByb2JlIHRoZSBJTyBsb2FkIG9uIE9TVHMsIGFuZCBzZWxmLW9wdGltaXplIGNoZWNr
cG9pbnQgSU8gdG8gdGltZXMgd2hlbiB0aGUgT1NUcyBhcmUgbGVzcyBidXN5PC9kaXY+DQo8ZGl2
Pi0mbmJzcDs8YSBjbGFzcz0iaXNzdWUtbGluayIgZGF0YS1pc3N1ZS1rZXk9IkxVLTEzMTIzIiBo
cmVmPSJodHRwczovL2ppcmEud2hhbWNsb3VkLmNvbS9icm93c2UvTFUtMTMxMjMiPkxVLTEzMTIz
PC9hPiZuYnNwOy0mbmJzcDs8YSBjbGFzcz0iaXNzdWUtbGluayIgZGF0YS1pc3N1ZS1rZXk9IkxV
LTEzMTIzIiBocmVmPSJodHRwczovL2ppcmEud2hhbWNsb3VkLmNvbS9icm93c2UvTFUtMTMxMjMi
PkFkZCBsaXN0IG9mIGNsaWVudCBOSURzIHRvIGpvYl9zdGF0cyBvdXRwdXQ8L2E+Og0KIHRoaXMg
d291bGQgYXNzb2NpYXRlIGFsbCBvZiB0aGUgY2xpZW50cyB0aGF0IGFyZSBjb250cmlidXRpbmcg
dG8gdGhlIGpvYl9zdGF0cyBmb3IgYSBzcGVjaWZpYyBKb2JJRCwgYW5kIHdvdWxkIGJlIHVzZWZ1
bCBmb3IgZGVidWdnaW5nIGFuZCBtb25pdG9yaW5nLzxiciBpZD0ibGluZUJyZWFrQXRCZWdpbm5p
bmdPZk1lc3NhZ2UiPg0KPGRpdj48YnI+DQo8ZGl2Pg0KPGRpdj5PbiBBcHIgMjksIDIwMjUsIGF0
IDE3OjQxLCBHRU9SR0UgWkhBTyAmbHQ7Z2Vvcmdlemhhb2pvYnNAZ21haWwuY29tJmd0OyB3cm90
ZTo8L2Rpdj4NCjwvZGl2Pg0KPGJsb2NrcXVvdGUgdHlwZT0iY2l0ZSI+DQo8ZGl2Pg0KPGRpdj4N
CjxkaXY+DQo8ZGl2IGRpcj0ibHRyIj4NCjxkaXY+PGJyPg0KPC9kaXY+DQo8ZGl2PkknbSBhIHN0
b3JhZ2UgZW5naW5lZXIgYW5kIGEgTHVzdHJlJm5ic3A7YmVnaW5uZXIgd2hvIGp1c3QgZmlndXJl
ZCBvdXQgaG93IHRvIGRlcGxveSBpdC4gRGlkIHJlYWQgYSBsb3QgYWJvdXQgaXQgdGhvdWdoLjwv
ZGl2Pg0KPGRpdj5NeSBnb2FsIGlzIHVzaW5nIEx1c3RyZSB0byBzdXBwb3J0Jm5ic3A7SFBDL01M
IHdvcmtsb2FkLiBBbmQgSSBiZWxpZXZlIGRvaW5nIHNvbWUgdGFza3Mgd291bGQgaGVscCBtZSBw
cm9jZWVkIGJldHRlci48L2Rpdj4NCjxkaXY+PGJyPg0KPC9kaXY+DQo8ZGl2PkFzIHdpa2kgc3Vn
Z2VzdGVkLCBJIGZvdW5kIGFuICZxdW90O2Vhc3kmcXVvdDsgdGlja2V0IExVLTE2NDM6IOKAnFJl
cXVlc3QgdG8gcmVtb3ZlIGRpc3BsYXkgb2YgcmVzZXJ2ZWQgc3BhY2UgZnJvbSBzdGF0ZnMgKGRm
KSB0b3RhbCBzcGFjZS7igJ08L2Rpdj4NCjxkaXY+SXMgaXQgc3RpbGwgdW5jbGFpbWVkPyZuYnNw
OzwvZGl2Pg0KPGRpdj5JZiBpdCdzIGFscmVhZHkgaW4gcHJvZ3Jlc3MsIG9yIHRoZXJlJ3MgYSBo
aWdoZXIgcHJpb3JpdHkgaXNzdWUgdGhhdCBjb3VsZCB1c2UgaGVscCwgcGxlYXNlIHBvaW50IG1l
IGluIHRoZSByaWdodCBkaXJlY3Rpb24uPC9kaXY+DQo8ZGl2Pjxicj4NCjwvZGl2Pg0KPGRpdj5U
aGFua3MgaW4gYWR2YW5jZSBmb3IgYW55IGFkdmljZS48YnI+DQo8YnI+DQpCZXN0IHJlZ2FyZHMs
PC9kaXY+DQo8ZGl2Pkdlb3JnZTwvZGl2Pg0KPC9kaXY+DQo8L2Rpdj4NCjwvZGl2Pg0KX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX188YnI+DQpsdXN0cmUtZGV2
ZWwgbWFpbGluZyBsaXN0PGJyPg0KbHVzdHJlLWRldmVsQGxpc3RzLmx1c3RyZS5vcmc8YnI+DQpo
dHRwOi8vbGlzdHMubHVzdHJlLm9yZy9saXN0aW5mby5jZ2kvbHVzdHJlLWRldmVsLWx1c3RyZS5v
cmc8YnI+DQo8L2Rpdj4NCjwvYmxvY2txdW90ZT4NCjwvZGl2Pg0KPGJyPg0KPGRpdj4NCjxkaXYg
ZGlyPSJhdXRvIiBzdHlsZT0iY2FyZXQtY29sb3I6IHJnYigwLCAwLCAwKTsgY29sb3I6IHJnYigw
LCAwLCAwKTsgbGV0dGVyLXNwYWNpbmc6IG5vcm1hbDsgdGV4dC1hbGlnbjogc3RhcnQ7IHRleHQt
aW5kZW50OiAwcHg7IHRleHQtdHJhbnNmb3JtOiBub25lOyB3aGl0ZS1zcGFjZTogbm9ybWFsOyB3
b3JkLXNwYWNpbmc6IDBweDsgLXdlYmtpdC10ZXh0LXN0cm9rZS13aWR0aDogMHB4OyB0ZXh0LWRl
Y29yYXRpb246IG5vbmU7IG92ZXJmbG93LXdyYXA6IGJyZWFrLXdvcmQ7IC13ZWJraXQtbmJzcC1t
b2RlOiBzcGFjZTsgbGluZS1icmVhazogYWZ0ZXItd2hpdGUtc3BhY2U7Ij4NCjxkaXYgZGlyPSJh
dXRvIiBzdHlsZT0iY2FyZXQtY29sb3I6IHJnYigwLCAwLCAwKTsgY29sb3I6IHJnYigwLCAwLCAw
KTsgbGV0dGVyLXNwYWNpbmc6IG5vcm1hbDsgdGV4dC1hbGlnbjogc3RhcnQ7IHRleHQtaW5kZW50
OiAwcHg7IHRleHQtdHJhbnNmb3JtOiBub25lOyB3aGl0ZS1zcGFjZTogbm9ybWFsOyB3b3JkLXNw
YWNpbmc6IDBweDsgLXdlYmtpdC10ZXh0LXN0cm9rZS13aWR0aDogMHB4OyB0ZXh0LWRlY29yYXRp
b246IG5vbmU7IG92ZXJmbG93LXdyYXA6IGJyZWFrLXdvcmQ7IC13ZWJraXQtbmJzcC1tb2RlOiBz
cGFjZTsgbGluZS1icmVhazogYWZ0ZXItd2hpdGUtc3BhY2U7Ij4NCjxkaXY+Q2hlZXJzLCBBbmRy
ZWFzPC9kaXY+DQo8ZGl2PuKAlDwvZGl2Pg0KPGRpdj5BbmRyZWFzIERpbGdlcjwvZGl2Pg0KPGRp
dj5MdXN0cmUgUHJpbmNpcGFsIEFyY2hpdGVjdDwvZGl2Pg0KPGRpdj5XaGFtY2xvdWQvREROPC9k
aXY+DQo8L2Rpdj4NCjxiciBjbGFzcz0iQXBwbGUtaW50ZXJjaGFuZ2UtbmV3bGluZSI+DQo8L2Rp
dj4NCjxiciBjbGFzcz0iQXBwbGUtaW50ZXJjaGFuZ2UtbmV3bGluZSI+DQo8YnIgY2xhc3M9IkFw
cGxlLWludGVyY2hhbmdlLW5ld2xpbmUiPg0KPC9kaXY+DQo8YnI+DQo8L2Rpdj4NCjwvYm9keT4N
CjwvaHRtbD4NCg==

--_000_DC413C4A68E74830BAE7ED34E094FCD1ddncom_--

--===============5875053761732150530==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============5875053761732150530==--
